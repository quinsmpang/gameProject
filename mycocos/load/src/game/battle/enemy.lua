module('game.battle.enemy', package.seeall)

local _const = require('data.const')
local _enemys_data = require('data.enemy').enemys
local _Animation = require('game.battle.ani').Animation
local _effect = require('game.battle.effect')
local _jump_down = require('data.effect').jump_down
local _boss_tag = require('data.effect').boss_tag
local _boss_dying = require('data.effect').boss_dying
local _ani_dead_cut = require('data.effect').dead.cut.animations
local _bullet = require('game.battle.bullet')
local _createItemsAround = require('game.battle.item').createItemsAround
local _next, _abs, _min = next, math.abs, math.min


-- k*待后退距离 = 当前后退速度
local _KNOCK_BACK_K = 10
local _KNOCK_BACK_MIN_SPEED = 20
local _KNOCK_BACK_MAX = require('config').design.height - 10
--
local _MOVE_FOLLOW_TARGET_TIME = 1
--
local _HURT_COLOR = {r=255, g=0, b=0, a=255}
local _NORMAL_COLOR = {r=255, g=255, b=255, a=255}
--
local _JUMP_BACK_MARGIN = 50

--各类敌人暂都实现在这里
Enemy = require('util.class').class(_Animation)

local _aniUpdate = _Animation.inst_meta.update
local _fsm

Enemy.ctor = function(self, scene, id, x, y, hp, acc_coeff, items)
  self.scene = scene
  local sdata = _enemys_data[id]
  self.sdata = sdata
  
  self.x, self.y = x, y
  self.node = cc.Node:create()
  self.__super_ctor__(self, sdata.object, nil, self.node)
  scene:addObject(self)
  
  local coll = sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  self.coll_top = coll[3]
  self.coll_bottom = coll[4]
  scene.coll:addColl(self, _const.COLL_TYPE_ENEMY)
  
  --
  self.bullet_reflect = false
  self.disable_attack = (sdata.attack_interval <=0)
  self.knock_type = sdata.knock_type
  --击中后退前的硬直时间
  --self._hit_stub = nil
  self._knock_back = 0
  self.hp_max = hp or sdata.hp
  self.hp = self.hp_max
  
  self.status = {}
  
  if not acc_coeff then acc_coeff=1 end
  self.acc_coeff = acc_coeff
  self.attack_interval = sdata.attack_interval * acc_coeff
  self.attack_left = self.attack_interval
  self.move_x, self.move_y = 0, 0
  
  self.items = items
  self._ani_add = {}
  
  self.fsm_data = {self=self}
  _fsm:start(self.fsm_data)
  
  --boss标记暂放这里，如有需要移到别处
  if sdata.boss then
    local ani = _Animation(_boss_tag, nil, self.node)
    self:addAnimation(ani)
    ani:play('play')
  end
end

Enemy.inst_meta.clean = function(self)
  self.scene:removeObject(self, true)
  self.scene.coll:removeColl(self)
end

--附加动画，以node为父对象. ani是battle.ani._Animation实例
Enemy.inst_meta.addAnimation = function(self, ani)
  self._ani_add[ani] = ani
end

Enemy.inst_meta.update = function(self, dt)
  _fsm:call(self.fsm_data, 'update', dt)
end

local function _knockBack(self, back, coeff)
  local kb = self._knock_back
  if not coeff then
    coeff = self.sdata.knock_back_coeff
  end
  local amount =  coeff * back
  if kb<=0 and amount>0 then
    self.ani_sprite:setColor(_HURT_COLOR)
    self._knock_back = amount
  elseif amount > kb then
    self._knock_back = amount
  end
end

Enemy.inst_meta.knockBack = function(self, back, coeff)
  --撞击马上取消硬直
  self._hit_stub = nil
  _knockBack(self, back, coeff)
end

Enemy.inst_meta.hurt = function(self, power, team, hsdata)
  local hp_prev = self.hp
  local hp
  if not hsdata.kill_instant_not_boss or self.sdata.boss then
    hp = hp_prev -  power
  else
    --非boss秒杀的情况
    hp = 0
  end
  self.hp = hp
  if hp <= 0 then
    _fsm:toState(self.fsm_data, 'dead', hsdata.kill_type, hsdata.disable_dead_ani)
    team:addScore(self.sdata.score)
    _createItemsAround(self.scene,
              self.x, self.y, self.items or self.sdata.items)
    local mgr_evt = self.scene.mgr_evt
    if mgr_evt then
      mgr_evt.publish('enemy.killed', self, self.sdata)
    end
  else
    local stub = hsdata.hit_stub
    if not self._hit_stub and self._knock_back <=0 then
      self._hit_stub = stub
    end
    
    _knockBack(self, hsdata.knock_back, hsdata.knock_back_coeff)
    
    local sdata = self.sdata
    if sdata.boss then
      local thresold = self.hp_max*0.2
      if hp_prev>thresold and hp<=thresold then
        local ani = _Animation(_boss_dying, nil, nil, self.ani_sprite)
        self:addAnimation(ani)
        ani:play('play')
      end
    end
    --TODO:暂只有冰冻，有需要再加
    --[[
    local status = hsdata.status
    if status then
      local immune = sdata.immune
      if (not immune or not immune.frozen)
          and math.random() < status.p 
      then
        self:setFrozen(status.value)
      end
    end
    ]]
  end
end

--[[
Enemy.inst_meta.setFrozen = function(self, sec)
  local status = self.status.frozen
  if status then
    status:reset(sec)
  elseif sec > 0 then
    _effect.Frozen(self, sec)
    --放到Frozen里？
    if _fsm:isIn(self.fsm_data, 'attack') then
      _fsm:toState(self.fsm_data, 'action')
    end
  end
end
]]

local function _updateGeneral(self, dt)
  local stub = self._hit_stub
  local kb = self._knock_back
  if stub then
    stub = stub - dt
    if stub <= 0 then
      dt = -stub
      stub = nil
    end
    self._hit_stub = stub
  end
  --硬直结束才后退
  if not stub then
    if kb > 0 then
      local kbsp = _KNOCK_BACK_K * kb
      if kbsp < _KNOCK_BACK_MIN_SPEED then
        kbsp = _KNOCK_BACK_MIN_SPEED
      end
      local back = kbsp * dt
      kb = kb - back
      if kb <= 0 then
        kb = 0
        self.ani_sprite:setColor(_NORMAL_COLOR)
      end
      self._knock_back = kb
      self.y = _min(self.y+back, self.scene.distance +_KNOCK_BACK_MAX)
    end
  end
  
  for ani,_ in pairs(self._ani_add) do
    ani:update(dt)
    if ani:isEnd() then
      ani.ani_sprite:removeFromParent()
      self._ani_add[ani] = nil
    end
  end
  local disable_update = false
  for n,status in pairs(self.status) do
    if status:update(dt) then
      disable_update = true
    end
  end
  --状态禁止、硬直中，不行动
  if not disable_update and not stub then
    _aniUpdate(self, dt)
    
    local width = self.scene.width
    self.x = self.x+self.move_x*dt
    if self.x <= 0 then
      self.x, self.move_x = 0, -self.move_x
    elseif self.x >= width then
      self.x, self.move_x = width, -self.move_x
    end
    self.y = self.y+self.move_y*dt
  end
  return disable_update
end

--移动逻辑、攻击处理、死亡效果表
local _move_func
local _attack_tbl
local _dead_func

_fsm = require('util.class').fsmComplete{
  _init = 'action';
  
  action = {
    _enter = function(fsm, data, curr)
      data.self:play('walk')
    end;
    
    update = function(fsm, data, curr, dt)
      local self = data.self
      if _updateGeneral(self, dt) then return end
      local jump_back = self.sdata.jump_back
      if jump_back and self.y <= self.scene.distance +jump_back[1] then
        fsm:toState(data, 'jump_back')
        return
      end
      
      --无攻击的处理
      if not self.disable_attack then
        self.attack_left = self.attack_left - dt
        if self.attack_left <= 0 then
          self.attack_left = self.attack_left + self.attack_interval
          self.move_x, self.move_y = 0, 0
          fsm:toState(data, 'attack')
          return
        end
      end
      
      local move = self.sdata.move
      _move_func[move[1]](self, move, dt)
    end;
  };
  
  jump_back = {
    _enter = function(fsm, data, curr)
      local self, st = data.self, data[curr._depth]
      self:play('jump_back')
      local scene, jump = self.scene, self.sdata.jump_back
      scene.coll:removeColl(self)
      st.x, st.y = self.x, self.y
      st.tx = math.random(_JUMP_BACK_MARGIN, scene.width-_JUMP_BACK_MARGIN)
      st.ty = scene.distance + scene.height + jump[2]
      st.t, st.total = 0, jump[3]
    end;
    
    _exit = function(fsm, data, curr)
      local self, st = data.self, data[curr._depth]
      self.scene.coll:addColl(self, _const.COLL_TYPE_ENEMY)
      st.x, st.y, st.tx, st.ty, st.t, st.total = nil
    end;
    
    update = function(fsm, data, curr, dt)
      local self, st = data.self, data[curr._depth]
      _aniUpdate(self, dt)
      local t = st.t + dt
      local r = t/st.total
      self.x = st.x*(1-r) + st.tx*r
      self.y = st.y*(1-r) + st.ty*r
      if r < 1 then
        st.t = t
      else
        _effect.Effect(self.scene, self.x, self.y, 0, _jump_down)
        fsm:toState(data, 'action')
      end
    end;
  };

  attack = {
    _enter = function(fsm, data, curr)
      local self, st = data.self, data[curr._depth]
      local attacks = self.sdata.attacks
      local att = attacks[math.random(#attacks)]
      local _attack_tbl = _attack_tbl[att[1]]
      _attack_tbl.enter(self, st, att[2])
      st._attack_tbl = _attack_tbl
    end;
    
    _exit = function(fsm, data, curr)
      local self, st = data.self, data[curr._depth]
      st._attack_tbl.exit(self, st)
      for n,v in pairs(st) do st[n]=nil end
    end;
  
    update = function(fsm, data, curr, dt)
      local self, st = data.self, data[curr._depth]
      --异常中不可后跳?
      local jump_back = self.sdata.jump_back
      if jump_back and self.y <= self.scene.distance +jump_back[1] then
        fsm:toState(data, 'jump_back')
        return
      end
      --攻击中忽略异常状态
      _updateGeneral(self, dt)
      if st._attack_tbl.update(self, st, dt) then
        fsm:toState(data, 'action')
      end
    end;
  };

  dead = {
    _enter = function(fsm, data, curr, kill_type, disable_dead_ani)
      data.kill_type = kill_type
      local self = data.self
      self.scene.coll:removeColl(self)
      self.move_x, self.move_y = 0, 0
      self.z = 0
      for n,status in pairs(self.status) do
        status:stop()
      end
      for ani,_ in pairs(self._ani_add) do
        if ani.spr_self then
          ani.ani_sprite:removeFromParent()
        end
        self._ani_add[ani] = nil
      end
      --死亡即停止硬直、击退
      self._hit_stub = nil
      self._knock_back = 0
      self.ani_sprite:setColor(_NORMAL_COLOR)
      if disable_dead_ani then
        _dead_func[data.kill_type](self)
        self.scene:removeObject(self)
      else
        self:play('dead')
      end
    end;

    update = function(fsm, data, curr, dt)
      local self = data.self
      _updateGeneral(self, dt)
      --结束硬直才播放死亡动画
      if self:isEnd() then
        _dead_func[data.kill_type](self)
        self.scene:removeObject(self)
      end
    end;
  };
} --_fsm

--辅助函数，寻找x方向离自己最近的目标
local function _findClosestTarget(self)
  local target
  local x, dx = self.x, self.scene.width
  for team,_ in pairs(self.scene.teams) do
    local d = _abs(x - team.heros[0].x)
    if d < dx then
      dx, target = d, team
    end
  end
  return target
end

--[[
移动逻辑
组合不多，暂不按x、y拆分
]]
local function _moveFixedFixed(self, param)
  self.move_x = param[2]
  self.move_y = (self.y<self.scene.distance+param[4] and param[3] or 0)
end

local function _moveRandomFixed(self, param)
  if self.move_x == 0 then
    self.move_x = (math.random()<0.5 and param[2] or -param[2])
  end
  self.move_y = (self.y<self.scene.distance+param[4] and param[3] or 0)
end

local function _moveFollowFixed(self, param, dt)
  local target = self._move_follow_target
  if not target or #target.heros==0 or self._move_follow_sec<=0 then
    target = _findClosestTarget(self)
    self._move_follow_target = target
    if target then
      self._move_follow_sec = _MOVE_FOLLOW_TARGET_TIME
      local x, tx = self.x, target.heros[0].x
      self.move_x = (x < tx and param[2]
                  or (x > tx and -param[2] or 0))
    else
      self.move_x = 0
    end
  else
    self._move_follow_sec = self._move_follow_sec - dt
    local x, tx = self.x, target.heros[0].x
    self.move_x = (x < tx and param[2]
                or (x > tx and -param[2] or 0))
  end
  self.move_y = (self.y<self.scene.distance+param[4] and param[3] or 0)
end

local function _moveFixedKeep(self, param)
  self.move_x = param[2]
  local dist = self.scene.distance
  if self.move_y==0 then
    self.move_y = (self.y<dist+param[4] and param[3] or 0)
  elseif self.y > dist+param[5] then
    self.move_y = 0
  end
end

local function _moveRandomKeep(self, param)
  if self.move_x == 0 then
    self.move_x = (math.random()<0.5 and param[2] or -param[2])
  end
  local dist = self.scene.distance
  if self.move_y==0 then
    self.move_y = (self.y<dist+param[4] and param[3] or 0)
  elseif self.y > dist+param[5] then
    self.move_y = 0
  end
end

local function _moveFollowKeep(self, param)
  local target = self._move_follow_target
  if not target or #target.heros==0 or self._move_follow_sec<=0 then
    target = _findClosestTarget(self)
    self._move_follow_target = target
    if target then
      self._move_follow_sec = _MOVE_FOLLOW_TARGET_TIME
      local x, tx = self.x, target.heros[0].x
      self.move_x = (x < tx and param[2]
                  or (x > tx and -param[2] or 0))
    else
      self.move_x = 0
    end
  else
    self._move_follow_sec = self._move_follow_sec - dt
    local x, tx = self.x, target.heros[0].x
    self.move_x = (x < tx and param[2]
                or (x > tx and -param[2] or 0))
  end
  local dist = self.scene.distance
  if self.move_y==0 then
    self.move_y = (self.y<dist+param[4] and param[3] or 0)
  elseif self.y > dist+param[5] then
    self.move_y = 0
  end
end

local function _moveThief(self, param)
  if not self._thief_laugh_ then
    if self.y > self.scene.distance + param[4] then
      self.move_x, self.move_y = param[2], param[3]
    else
      self.move_x, self.move_y = 0, 0
      self:play('laugh')
      self._thief_laugh_ = true
    end
  elseif self:isEnd() then
    self.move_x, self.move_y = param[2], param[3]
  end
end

_move_func = {
  fixed_fixed = _moveFixedFixed,
  random_fixed = _moveRandomFixed,
  follow_fixed = _moveFollowFixed,
  fixed_keep = _moveFixedKeep,
  random_keep = _moveRandomKeep,
  follow_keep = _moveFollowKeep,
  thief_move = _moveThief,
}


--[[
 攻击逻辑函数
]]

local function _attackBulletEnter(self, st, param)
  self.move_x, self.move_y = 0, 0
  st.param = param
  self:play('pre_bullet', self.acc_coeff)
end

local function _attackBulletExit(self, st)
end

local function _attackBulletUpdate(self, st, dt)
  if not self:isEnd() then
    return
  end
  
  local target = _findClosestTarget(self)
  --有目标且未越过
  if target then
    target = target.heros[1]
    if target then
      local Bullet = _bullet.Bullet
      for i, b in ipairs(st.param) do
        local off = b.offset
        local start_x, start_y = self.x+off[1], self.y+off[2]
        
        local vec_x, vec_y
        local vector = b.vector
        if vector then
          vec_x, vec_y = vector[1], vector[2]
        else
          local tx, ty = target.x, target.y
          local vecoff = b.vecoff
          if vecoff then
            if self.x < tx then
              tx = tx - vecoff[1]
            else
              tx = tx + vecoff[1]
            end
            ty = ty + vecoff[2]
          end
          vec_x, vec_y = tx-start_x, ty-start_y
        end
        --仅当未越过玩家才发射
        if vec_y < 0 then
          Bullet(self.scene, b.id,
                start_x, start_y, 
                b.power, b.distance, vec_x, vec_y, b.speed,
                _const.COLL_TYPE_ENEMY_BULLET, true)
        end
      end --for
    end
  end
  return true
end

local function _attackKnockEnter(self, st, param)
  self.move_x, self.move_y = 0, 0
  st.param = param
  st.knocking = false
  self:play('pre_knock', self.acc_coeff)
end

local function _attackKnockExit(self, st)
  self.knock_type = self.sdata.knock_type
  self.bullet_reflect = false
  local coll = self.sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  self.coll_top = coll[3]
  self.coll_bottom = coll[4]
end

local function _attackKnockUpdate(self, st, dt)
  if not st.knocking then
    if self:isEnd() then
      self:play('knock')
      st.knocking = true
      self.knock_type = _const.KNOCK_DEAD
      self.bullet_reflect = true
      local coll = st.param.collision
      self.coll_left = coll[1]
      self.coll_right = coll[2]
      self.coll_top = coll[3]
      self.coll_bottom = coll[4]
    end
    return
  end
    
  return self:isEnd()
end

local function _attackDashEnter(self, st, param)
  self.move_x, self.move_y = 0, 0
  st.dashing = false
  st.param = param
  self:play('pre_dash', self.acc_coeff)
end

local function _attackDashExit(self, st)
  self.move_x, self.move_y = 0, 0
  self.knock_type = self.sdata.knock_type
  local coll = self.sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  self.coll_top = coll[3]
  self.coll_bottom = coll[4]
end

local function _attackDashUpdate(self, st)
  if not st.dashing then
    if self:isEnd() then
      self:play('dash')
      st.dashing = true
      self.knock_type = _const.KNOCK_DEAD
      local coll = st.param.collision
      self.coll_left = coll[1]
      self.coll_right = coll[2]
      self.coll_top = coll[3]
      self.coll_bottom = coll[4]
      --敌人只向下
      self.move_y = -st.param.speed
    end
  end
end

local function _attackFlamingEnter(self, st, param)
  self.move_x, self.move_y = 0, 0
  st.flamming = false
  st.param = param
  self:play('pre_flaming', self.acc_coeff)
end


local function _attackFlamingExit(self, st)
  if st.flame then
    st.flame:clean()
    st.flame = nil
    self.onFlameEnd = nil
  end
end

local function _attackFlamingUpdate(self, st, dt)
  if not st.flamming then
    if self:isEnd() then
      self:play('flaming')
      st.flamming = true
      local param = st.param
      st.flame = _bullet.Flame(self.scene, param.id,
        self, param, 
        1, param._distance, _const.COLL_TYPE_ENEMY_BULLET, true)
      self.onFlameEnd = function(self,flame)
        self.onFlameEnd = nil
      end
    end
    return false
  else
    return not self.onFlameEnd
  end
end

_attack_tbl = {
  bullet = {
    enter = _attackBulletEnter,
    update = _attackBulletUpdate,
    exit = _attackBulletExit,
  },
  knock = {
    enter = _attackKnockEnter,
    update = _attackKnockUpdate,
    exit = _attackKnockExit,
  },
  dash = {
    enter = _attackDashEnter,
    update = _attackDashUpdate,
    exit = _attackDashExit,
  },
  flaming = {
    enter = _attackFlamingEnter,
    update = _attackFlamingUpdate,
    exit = _attackFlamingExit,
  },
}


--[[
死亡效果处理
]]
local function _deadCut(enemy)
  --取敌人死亡最后一帧
  local ani_dead = enemy.sdata.object.animations.dead
  local spf = ani_dead[#ani_dead][2]
  if math.random() < 0.5 then
    _effect.DeadCut(enemy, spf, 'dead_left', 0,0, 0.75,0, 0,1, 0.25,1)
    _effect.DeadCut(enemy, spf, 'dead_right', 0.75,0, 1,0, 0.25,1, 1,1)
  else
    _effect.DeadCut(enemy, spf, 'dead_bottom', 0,0.25, 0,0, 1,0, 1,0.5)
    _effect.DeadCut(enemy, spf, 'dead_top', 0,1, 0,0.25, 1,0.5, 1,1)
  end
end

local function _deadApart(enemy)
  local ani_dead = enemy.sdata.object.animations.dead
  local spf = ani_dead[#ani_dead][2]
  _effect.DeadApart(enemy, spf, true)
  _effect.DeadApart(enemy, spf, false)
end

_dead_func = {
  [_const.KILL_TYPE_NONE] = _effect.DeadNone,
  [_const.KILL_TYPE_SHATTER] = _effect.DeadShatter,
  [_const.KILL_TYPE_CUT] = _deadCut,
  [_const.KILL_TYPE_FIRE] = _effect.DeadFire,
  [_const.KILL_TYPE_CRUSH] = _effect.DeadCrush,
  [_const.KILL_TYPE_APART] = _deadApart,
}
