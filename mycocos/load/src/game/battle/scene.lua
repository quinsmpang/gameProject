module('game.battle.scene', package.seeall)

local _mgr_snd = require('game.mgr_snd')
local _design = require('config').design
local _const = require('data.const')
local _mgr_evt = require('game.mgr_evt')
local _effect = require('data.effect')
local _Animation = require('game.battle.ani').Animation


--[[
战斗场景逻辑，也作为场景内所有数据的存放入口及公共交互区。
公共成员：
layer: 顶层node，2dx的Layer

width, height: 宽高，便于引用
distance: 已前进距离（屏幕底部对应的距离）
ui_func: 游戏中导致界面更新的处理函数
 {
   setDistance(num)
   onDead(team)  --一队死亡
   onFinished(param) --全部死亡
   popPrisonerDialog(id,cbfunc)
   popTip(text)
   ...
 }
mgr_evt: 
stage: game.battle.Stage实例

can_drop: 怪物是否掉落
effect_sec: 若存在，表示效果持续时间（如陨石的裂缝）
item_attractor: 若为对象，道具自动往其飞行

bg: 背景，game.battle.bg.BG的实例
coll: 碰撞检测，game.battle.coll.Collision实例
teams: {team:team}，玩家所有队伍，元素是game.battle.team.Team实例
objects: {obj:valid}，true:有效; false:待清除
  记录除玩家角色外，场上所有物体（敌人、物品、子弹...）。
  需支持以下功能：
    x,y: 直接访问，获取其位置;
    node: 该object的2dx node;
    update(dt): 如果can_update，则每帧调用这来更新逻辑；
    clean(): 到场景下方一定距离后被调用做清除;
    
显示层次：
layer 战斗场景node
 bg(z=-2)
 攻击痕迹(z=-1)
 道具(z=0)
 敌人,英雄,子弹(屏高-y坐标)
 效果(data.const.SCENE_Z_EFFECT)
]]
Scene = require('util.class').class()

local _Z_SUBS = _design.height + 500
local _OBJ_CLEAN_DOWN = -200
--local _VELOCITY_NORMAL = _const.VELOCITY_NORMAL
--local _VELOCITY_RUN = _const.VELOCITY_RUN
local _VELOCITY_ACC = _const.VELOCITY_ACC

local _fsm

Scene.ctor = function(self)
  self.layer = cc.Layer:create()
  
  self.width, self.height = _design.width, _design.height
  self.distance = 0
  --self.ui_func = nil
  --self.mgr_evt = nil
  --self.stage = nil
  self.can_drop = true
  --self.effect_sec = nil
  self.item_attractor = false
  
  self.velocity = 0
  --self.velocity_desire = nil
  
  self.objects = {}
  self._obj_tmp = {}
  
  self.bg = require('game.battle.bg').BG(self)
  self.layer:addChild(self.bg.node, -2)
  
  self.coll = require('game.battle.coll').Collision(self)
  self.teams = {}
  
  --是否update中，某些操作不应在update中进行
  self._updating = false
  --update末尾检查的操作, { {prio, func}, ... }
  self._post_checker = nil
  
  --外部接管的状态，见game.guide
  self._inject_state = nil
  self.fsm_data = {
    self=self
  }
  _fsm:start(self.fsm_data)
end

Scene.inst_meta.getCocosNode = function(self)
  return self.layer
end

--同一object不能重复添加删除
Scene.inst_meta.addObject = function(self, obj)
  self.layer:addChild(obj.node)
  if self._updating then
    self._obj_tmp[obj] = true
    --位置、z值在updateScene会调整
  else
    self.objects[obj] = true
    local dy = obj.y - self.distance
    obj.node:setPosition(obj.x, dy)
    obj.node:setLocalZOrder(obj.z or _Z_SUBS-dy)
  end
end

Scene.inst_meta.removeObject = function(self, obj)
  if self._updating then
    --标记已清除，稍后再移走
    if self.objects[obj] then
      self.objects[obj] = false
      self._obj_tmp[obj] = false
      obj.node:removeFromParent()
    elseif self._obj_tmp[obj] then
      self._obj_tmp[obj] = nil
      obj.node:removeFromParent()
    end
  else
    if self.objects[obj] then
      self.objects[obj] = nil
      obj.node:removeFromParent()
    end
  end
end


local function _doChecker(self)
  local chk = self._post_checker
  while #chk > 0 do
    local n = #chk
    local c = chk[n]
    chk[n] = nil
    if not c[2]() then
      break
    end
  end
end

--[[
提交消息，在非update时检查
必须在update中提交
priority: 优先级，按从小到大处理，相同的先到先处理。
func返回true表示允许处理下一个，
 否则等待，到调用endChecker继续处理下一个。
TODO: 是否能屏蔽此处操作
]]
Scene.inst_meta.postChecker = function(self, priority, func)
  assert(self._updating, 'Scene:postUpdate not in update')
  local chk = self._post_checker
  local idx = 1
  for i=#chk,1,-1 do
    local c = chk[i]
    if c[1] <= priority then
      chk[i+1] = c
    else
      idx = i+1
      break
    end
  end
  chk[idx] = {priority, func}
end

Scene.inst_meta.endChecker = _doChecker


local function _mergePendingObjects(self)
  local objs = self.objects
  local objt = self._obj_tmp
  for obj,flag in pairs(objt) do
    objs[obj] = flag or nil
    objt[obj] = nil
  end
end

--更新摄像头位置: 调整所有objects的显示位置和z order
--清除越过屏幕下方一定距离的objects
local function _updateScene(self)
  local off = self.distance
  local objs = self.objects
  for obj, valid in pairs(objs) do
    if valid then
      local dy = obj.y - off
      if dy > _OBJ_CLEAN_DOWN then
        obj.node:setPosition(obj.x, dy)
        obj.node:setLocalZOrder(obj.z or _Z_SUBS-dy)
      else
        obj:clean()
      end
    end
  end
end

--设置速度
local function _updateVelocity(self, dt)
  local curr = self.velocity
  local dst = self.velocity_desire or self.stage.velocity
  if curr < dst then
    curr = curr + _VELOCITY_ACC*dt
    if curr > dst then curr=dst end
  elseif curr > dst then
    curr = curr - _VELOCITY_ACC*dt
    if curr<dst then curr=dst end
  end
  self.velocity = curr
end

local function _getUpdateOfPlaying(self, st)
  local logic_dt = 1/require('config').design.fps
  return function()
    self._updating = true
    
    self.coll:check()
    self.distance = self.distance + self.velocity *logic_dt
    self.bg:scrollDown(self.velocity, logic_dt)
    for team,_ in pairs(self.teams) do
      team:update(logic_dt)
    end
    for obj,valid in pairs(self.objects) do
      if valid then obj:update(logic_dt) end
    end
    
    self.stage:update(logic_dt)
    
    self.coll:mergePending()
    _mergePendingObjects(self)
    _updateScene(self)
    _updateVelocity(self, logic_dt)
    
    self.ui_func.setDistance(self.distance)
  
    _mgr_evt.publish('battle.play_update', self, logic_dt)
    self._updating = false
    _doChecker(self)
  end
end

local function _getUpdateOfDead(self)
  local logic_dt = 1/require('config').design.fps
  return function()
    self._updating = true
    self.coll:check()
    for team,_ in pairs(self.teams) do
      team:update(logic_dt)
    end
    for obj,valid in pairs(self.objects) do
      if valid then obj:update(logic_dt) end
    end
    self.coll:mergePending()
    _mergePendingObjects(self)
    _updateScene(self)
    _updateVelocity(self, logic_dt)
    self._updating = false
    _doChecker(self)
  end
end

local function _getUpdateOfInjecting(self)
  local logic_dt = 1/require('config').design.fps
  
  return function()
    self._updating = true
    self.bg:scrollDown(self.velocity, logic_dt)
    for team,_ in pairs(self.teams) do
      team:update(logic_dt)
    end
    for obj,valid in pairs(self.objects) do
      if valid then obj:update(logic_dt) end
    end
    self.coll:mergePending()
    _mergePendingObjects(self)
    _updateScene(self)
    _updateVelocity(self, logic_dt)
    
    local done = self._inject_state.onUpdate(self, logic_dt, self.teams[1])
    
    self._updating = false
    if done then
      _fsm:toState(self.fsm_data, 'playing')
    end
    _doChecker(self)
  end
end

local function _getUpdateOfUnpausing(self)
  local data = self.fsm_data
  
  if data._unpausing then
    data._unpausing.ani_sprite:removeFromParent()
    data._unpausing = nil
  end
  
  local ani = _Animation(_effect.unpausing, nil, self.layer)
  ani.ani_sprite:setPosition(300, 200)
  ani.ani_sprite:setLocalZOrder(_const.SCENE_Z_EFFECT)
  ani:play('play')
  
  data._unpausing = ani
  
  return function(dt)
    if ani:update(dt) then
      ani.ani_sprite:removeFromParent()
      data._unpausing = nil
      _fsm:toState(data, 'playing')
    end
  end
end


_fsm = require('util.class').fsmComplete{
  _init = 'stopped';
  
  stopped = { --未运行
    _enter = function(fsm, data, curr)
      local self = data.self
      for team, _ in pairs(self.teams) do
        team:stop()
        self.teams[team] = nil
      end
    end
  };--stopped
  
  play = {--游戏
    --[[data约定：
      func --当前运行的定时函数
      pause --当前暂停计数，0表示进行中
    ]]
    _enter = function(fsm, data, curr)
      data.pause = 0
      local self = data.self
      self.distance = 0
      self._post_checker = {}
      if self._inject_state then
        --有新手引导的，完成再启动
        curr.injecting._enter(fsm, data, curr.injecting)
        return curr.injecting
      else
        self.stage:start()
        curr.playing._enter(fsm, data, curr.playing)
        return curr.playing
      end
    end;
    
    _exit = function(fsm, data, curr)
      local self = data.self
      self.stage:stop()
      self._post_checker = nil
      self.layer:unscheduleUpdate()
      data.pause, data.func = nil
    end;
    
    --处理暂停切换，需data中有func
    pause = function(fsm, data, curr)
      if data.pause > 0 then
        data.pause = data.pause + 1
        return true 
      end
      data.self.layer:unscheduleUpdate()
      data.pause = 1
    end;
    unpause = function(fsm, data, curr)
      if data.pause <= 0 then
        return true 
      end
      data.pause = data.pause - 1
      if data.pause <= 0 then
        data.self.layer:scheduleUpdateWithPriorityLua(data.func, 0)
        data.pause = 0
      end
    end;
    
    injecting = { --注入新手引导
      _enter = function(fsm, data, curr)
        local self = data.self
        self._inject_state.onStart(self, self.teams[1])
        data.func = _getUpdateOfInjecting(self)
        self.layer:scheduleUpdateWithPriorityLua(data.func, 0)
      end;
      _exit = function(fsm, data, curr)
        local self = data.self
        self._inject_state.onEnd(self, self.teams[1])
        self._inject_state = nil
        --引导结束，对应 play._enter的启动
        self.stage:start()
      end;
    };--play.injecting
  
    unpausing = { --解除暂停中
      _enter = function(fsm, data, curr)
        data.func = _getUpdateOfUnpausing(data.self)
      end;
      pause = function(fsm, data, curr)
        if data.pause <= 0 then
          --解除暂停中又再暂停，重新设置动画
          data.func = _getUpdateOfUnpausing(data.self)
        end
        return true --上层pause继续处理
      end;
    };--play.unpausing
  
    playing = { --进行中
      _enter = function(fsm, data, curr)
        local self, st = data.self, data[curr._depth]
        data.func = _getUpdateOfPlaying(self, st)
        self.layer:scheduleUpdateWithPriorityLua(data.func, 0)
      end;
      
      pause = function(fsm, data, curr, internal)
        if not internal then
          fsm:toState(data, 'unpausing')
        end
        return true --上层pause继续处理
      end;
      
      gotoFinished = function(fsm, data, curr)
        fsm:toState(data, 'finished')
      end;
    };--play.playing
    
    finished = {
      _enter = function(fsm, data, curr)
        local self = data.self
        data.func = _getUpdateOfDead(data.self)
        self.layer:scheduleUpdateWithPriorityLua(data.func, 0)
        self.ui_func.onFinished()
      end;
      
      returnToPlay = function(fsm, data, curr)
        fsm:toState(data, 'playing')
      end;
    };--play.finished
  };--play
}


Scene.inst_meta.start = function(self, stage, ui_func, inject_state)
  if not _fsm:isIn(self.fsm_data, 'play') then
    self.stage = stage
    self.ui_func = ui_func
    self.mgr_evt = _mgr_evt
    self._inject_state = inject_state
    _fsm:toState(self.fsm_data, 'play')
    _mgr_snd.pushMusic('music/battle.mp3')
  end
end

Scene.inst_meta.stop = function(self)
  if not _fsm:isIn(self.fsm_data, 'stopped') then
    _fsm:toState(self.fsm_data, 'stopped')
    self.ui_func = nil
    self.mgr_evt = nil
    self.stage = nil
    _mgr_snd.popMusic()
  end
end


--不应在游戏update中加入、移除
Scene.inst_meta.addTeam = function(self, team)
  assert(not self._updating, 'Scene.addTeam in update')
  assert(not self.teams[team], 'Scene.addTeam team already in scene')
  self.teams[team] = team
  team:start()
  _mgr_evt:publish('team.changed', team, true)
end

Scene.inst_meta.removeTeam = function(self, team)
  --assert(not self._updating, 'Scene.removeTeam in update')
  --TODO: 仅stage update处理，暂保证不出错
  if self.teams[team] then
    self.teams[team] = nil
    team:stop()
    _mgr_evt:publish('team.changed', team, false)
  end
end

Scene.inst_meta.pause = function(self, internal)
  assert(not self._updating, 'Scene.pause in update')
  _fsm:message(self.fsm_data, 'pause', internal)
end

Scene.inst_meta.unpause = function(self)
  assert(not self._updating, 'Scene.unpause in update')
  _fsm:message(self.fsm_data, 'unpause')
end

Scene.inst_meta.gotoFinished = function(self)
  assert(not self._updating, 'Scene.gotoFinished in update')
  _fsm:message(self.fsm_data, 'gotoFinished')
end

Scene.inst_meta.returnToPlay = function(self)
  assert(not self._updating, 'Scene.returnToPlay in update')
  _fsm:message(self.fsm_data, 'returnToPlay')
end

