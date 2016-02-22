module('game.battle.hero', package.seeall)

local _Animation = require('game.battle.ani').Animation
local _bullet = require('game.battle.bullet')
local _heros_data = require('data.hero').heros
local _const  = require('data.const')
local _effect = require('game.battle.effect')


--[[
处理一个角色的动作、逻辑及状态
scene: 
sdata: data.hero.heros内的数据
ability: 对应的能力值
team: 所属的team

x, y: 记录位置。Scene object、Collsion coll所需
node: Scene object 要求
coll_xxx: Collision coll所需
]]

Hero = require('util.class').class(_Animation)

local _aniUpdate = _Animation.inst_meta.update
local _fsm

Hero.ctor = function(self, scene, id, ability, x, y)
  local sdata = _heros_data[id]
  local node =  cc.Node:create()
  self.__super_ctor__(self, sdata.object, nil, node)
  
  self.node = node
  self.x, self.y = x, y
  scene:addObject(self)
  
  self.scene = scene
  self.sdata = sdata
  self.ability = ability
  --self.team = team teamJoin时设

  local coll = sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  self.coll_top = coll[3]
  self.coll_bottom = coll[4]
  scene.coll:addColl(self, _const.COLL_TYPE_HERO)
    
  self.status = {}
  self.attack_interval = ability.interval * _const.ABILITY_INTERVAL_SEC_COEFF
  self.attack_left = self.attack_interval
  self.attack_power = ability.power
  self.attack_distance = ability.distance
  
  --self.cross_level 是否前一关卡过关者，team注入
  self.disable_attack = (self.attack_interval<=0)
  self.invincible_count = 0
  self.guard = {
    [_const.HIT_TYPE_SWORD] = 0,
    [_const.HIT_TYPE_ARROW] = 0,
    [_const.HIT_TYPE_MAGIC] = 0,
  }
  --true则用attack_alternate的信息攻击
  self.attack_alternate = false
  
  self._ani_add = {}
  
  self.fsm_data = {self=self}
  _fsm:start(self.fsm_data)
end

Hero.inst_meta.teamJoined = function(self, team)
  self.team = team
  --[[
  --加速status处理(力量加成无效果)
  local status = self.sdata.status
  if status then
    team:addStatus(status, self.ability.power)
  end
  ]]
end

Hero.inst_meta.teamLeaved = function(self, team)
  self.team = nil
  self.disable_attack = true
  --[[
  --力量加成无效果
  local status = self.sdata.status
  if status then
    team:removeStatus(status, self.ability.power)
  end
  ]]
end

--附加动画，以node为父对象. ani是battle.ani._Animation实例
Hero.inst_meta.addAnimation = function(self, ani)
  self._ani_add[ani] = ani
end

Hero.inst_meta.update = function(self, dt)
  _fsm:call(self.fsm_data, 'update', dt)
end

Hero.inst_meta.clean = function(self)
  if not self.team then
    _fsm:stop(self.fsm_data)
    self.scene:removeObject(self)
    self.scene.coll:removeColl(self)
  end
end

--攻击逻辑
local _attack_func

local function _updateGeneral(self, dt)
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
  return disable_update
end

_fsm = require('util.class').fsmComplete{
  _init = 'action';
  
  action = {
    _enter = function(fsm, data, curr)
      data.self:play('walk')
    end;
    
    update = function(fsm, data, curr, dt)
      local self = data.self      
      
      if _updateGeneral(self,dt) then return end
      
      _aniUpdate(self, dt)
      --无攻击的处理。。。
      if self.disable_attack then
        return
      end
      self.attack_left = self.attack_left - dt
      if self.attack_left <= 0 then
        self.attack_left = self.attack_left + self.attack_interval
        local att_info = self.attack_alternate 
                        and self.sdata.attack_alternate
                        or self.sdata.attack
        local att_tbl, att_data = _attack_func[att_info[1]](self, att_info[2])
        if att_tbl then
          fsm:toState(data, 'attack', att_tbl, att_data)
        end
      end
    end;
  };

  attack = {
    _enter = function(fsm, data, curr, att_tbl, att_data)
      local st = data[curr._depth]
      st.att_tbl = att_tbl
      st.att_data = att_data
    end;
    
    _exit = function(fsm, data, curr)
      local self, st = data.self, data[curr._depth]
      st.att_tbl.exit(self, st.att_data)
      st.att_tbl, st.att_data = nil
    end;
  
    update = function(fsm, data, curr, dt)
      local self, st = data.self, data[curr._depth]
      _updateGeneral(self, dt)
      if st.att_tbl.update(self, dt, st.att_data) then
        fsm:toState(data, 'action')
        return
      end
      _aniUpdate(self, dt)
    end;
  };
  
  dead = {
    _enter = function(fsm, data, curr)
      local self = data.self
      self.scene.coll:removeColl(self)
      self:play('dead')
      self.z = 0
      for n,status in pairs(self.status) do
        status:stop()
      end
      for ani,_ in pairs(self._ani_add) do
        ani.ani_sprite:removeFromParent()
        self._ani_add[ani] = nil
      end
    end;

    update = function(fsm, data, curr, dt)
      _aniUpdate(data.self, dt)
    end;
  };
}

Hero.inst_meta.dead = function(self)
  _fsm:toState(self.fsm_data, 'dead')
end

--[[
Hero.inst_meta.setAcceleration = function(self, value)
  --cclog('acc:%d', value)
  assert(value>=0 and value<100, 'Hero.setAcceleration: value not in [1,100)')
  local status = self.status.acceleration
  if status then
    status:reset(value)
  elseif value>0 then
    _effect.Acceleration(self, value)
  end
end
]]

Hero.inst_meta.setInvincible = function(self, sec)
  local status = self.status.invincible
  if status then
    status:reset(sec)
  elseif sec>0 then
    _effect.Invincible(self, sec)
  end
end

--[[
Hero.inst_meta.setAttackDouble = function(self, sec)
  local status = self.status.attack_double
  if status then
    status:reset(sec)
  elseif sec>0 then
    _effect.AttackDouble(self, sec)
  end
end
]]

--攻击函数
local function _attackBullet(self, param)
  local Bullet = _bullet.Bullet
  local team = self.team
  for i, b in ipairs(param) do
    local vec, off = b.vector, b.offset
    local bullet = Bullet(self.scene, b.id,
          self.x+off[1], self.y+off[2], 
          self.attack_power, self.attack_distance,
          vec[1], vec[2], b.speed, _const.COLL_TYPE_HERO_BULLET)
    bullet.team = team
  end
end

local function _attackDropper(self, param)
  local m = _bullet.Dropper(self.scene, param.id, self.x,
    self.attack_power, self.attack_distance,
    param.down, param.time,
    _const.COLL_TYPE_HERO_BULLET)
  m.team = self.team
end

local function _attackTracer(self, param)
  local Tracer = _bullet.Tracer
  local team = self.team
  for i, b in ipairs(param) do
    local off = b.offset
    local t = Tracer(self.scene, b.id,
          self.x+off[1], self.y+off[2], 
          self.attack_power, self.attack_distance,
          b, _const.COLL_TYPE_HERO_BULLET)
    t.team = team
  end
end

local function _fireTracer(self, param)
  local team = self.team
  local off = param.offset
  local t = _bullet.Tracer(self.scene, param.id,
        self.x+off[1], self.y+off[2], 
        self.attack_power, self.attack_distance,
        param, _const.COLL_TYPE_HERO_BULLET)
  t.team = team
end

local _att_tracers_tbl = {
  exit = function(self, info)
  end,
  update = function(self, dt, info)
    local t = info.t - dt
    if t > 0 then
      info.t = t
      return
    end
    
    local param = info.param
    local index = info.pending
    _fireTracer(self, param[index])
    if index < #param then
      index = index + 1
      info.t = param[index].delay + t
      info.pending = index
      return
    end
    
    return true
  end,
}

local function _attackTracers(self, param)
  _fireTracer(self, param[1])
  local p2 = param[2]
  if p2 then
    return _att_tracers_tbl, {
      param=param,
      t=p2.delay,
      pending=2,
    }
  end
end

local function _fireStrip(self, param)
  local team = self.team
  local vec, off = param.vector, param.offset
  local strip = _bullet.Strip(self.scene, param.id,
        self.x+off[1], self.y+off[2], 
        self.attack_power, self.attack_distance,
        param.speed, vec[1], vec[2], _const.COLL_TYPE_HERO_BULLET)
  strip.team = team
end

local _att_strips_tbl = {
  exit = function(self, info)
  end,
  update = function(self, dt, info)
    local t = info.t - dt
    if t > 0 then
      info.t = t
      return
    end
    
    local param = info.param
    local index = info.pending
    _fireStrip(self, param[index])
    if index < #param then
      index = index + 1
      info.t = param[index].delay + t
      info.pending = index
      return
    end
    
    return true
  end,
}

local function _attackStrips(self, param)
  _fireStrip(self, param[1])
  local p2 = param[2]
  if p2 then
    return _att_strips_tbl, {
      param=param,
      t=p2.delay,
      pending=2,
    }
  end
end

local _att_flame_tbl = {
  exit = function(self, flames)
    for f in pairs(flames) do
      f:clean()
    end
    self.onFlameEnd = nil
  end,
  update = function(self, dt, flames)
    return not self.onFlameEnd
  end,
}

local function _attackFlame(self, param)
  local flames = {}
  for i,p in ipairs(param) do  
    local f = _bullet.Flame(self.scene, p.id,
      self, p, self.attack_power, self.attack_distance,
      _const.COLL_TYPE_HERO_BULLET)
    f.team = self.team
    flames[f] = true
  end
  
  self.onFlameEnd = function(self,f)
    flames[f] = nil
    if not next(flames) then
      self.onFlameEnd = nil
    end
  end
  return _att_flame_tbl, flames
end

local _att_ball_tbl = {
  exit = function(self, ball)
    if self.onBallEnd then
      ball:clean()
      self.onBallEnd = nil
    end
  end,
  update = function(self, dt, ball)
    return not self.onBallEnd
  end,
}

local function _attackBall(self, param)
  local b = _bullet.Ball(self.scene, param.id,
    self, param, self.attack_power,
    _const.COLL_TYPE_HERO_BULLET)
  b.team = self.team
  
  self.onBallEnd = function(self,b)
    self.onBallEnd = nil
  end
  return _att_ball_tbl, b
end

_attack_func = {
  bullet = _attackBullet,
  dropper = _attackDropper,
  tracer = _attackTracer,
  tracers = _attackTracers,
  strips = _attackStrips,
  flame = _attackFlame,
  ball = _attackBall,
}

