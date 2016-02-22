module('game.battle.effect', package.seeall)

local _class = require('util.class').class
local _Animation = require('game.battle.ani').Animation
local _status_data = require('data.effect').status
local _dead_data = require('data.effect').dead

local _const = require('data.const')

local _aniUpdate = _Animation.inst_meta.update

--各类显示特效都放在这
local function _effectClean(self)
  self.scene:removeObject(self)
end

--[[
纯显示效果，如子弹碰撞、击中、跑步等等
]]
Effect = _class(_Animation)

Effect.ctor = function(self, scene, x, y, z, sdata)
  self.scene = scene
  
  self.__super_ctor__(self, sdata)
  self.x, self.y = x, y
  self.z = z or _const.SCENE_Z_EFFECT
  self.node = self.ani_sprite
  scene:addObject(self)
  
  self:play('play')
end

Effect.inst_meta.clean = _effectClean

Effect.inst_meta.update = function(self, dt)
  if _aniUpdate(self, dt) then
    _effectClean(self)
  end
end


-----status

--[[
加速效果
]]
--[[
Acceleration = _class(_Animation)

local function _accelerationCalcInterval(obj, value)
  local sec = obj.ability.interval*(1-value*0.01)
  obj.attack_interval = sec * _const.ABILITY_INTERVAL_SEC_COEFF
  if obj.attack_left > obj.attack_interval then
    obj.attack_left = obj.attack_interval
  end
end

Acceleration.ctor = function(self, obj, value)
  local sdata = _status_data.acceleration
  self.__super_ctor__(self, sdata, nil, obj.node)
  self:play('play')
  self.sdata = sdata
  self._obj = obj
  obj.status[sdata.id] = self
  _accelerationCalcInterval(obj, value)
end

local function _accelerationStop(self)
  self.ani_sprite:removeFromParent()
  local obj = self._obj
  obj.attack_interval = obj.ability.interval * _const.ABILITY_INTERVAL_SEC_COEFF
  obj.status[self.sdata.id] = nil
end

Acceleration.inst_meta.stop = _accelerationStop

Acceleration.inst_meta.reset = function(self, value)
  if value==0 then
    _accelerationStop(self)
  else
    _accelerationCalcInterval(self._obj, value)
  end
end

Acceleration.inst_meta.update = function(self, dt)
  _aniUpdate(self, dt)
end
]]

--[[
无敌效果
]]
Invincible = _class(_Animation)

Invincible.ctor = function(self, obj, sec)
  local sdata = _status_data.invincible
  self.__super_ctor__(self, sdata, nil, nil, obj.ani_sprite)
  self:play('play')
  self.sdata = sdata
  self._obj = obj
  self._sec = sec
  obj.invincible_count = obj.invincible_count + 1
  obj.status[sdata.id] = self
end

local function _invincibleStop(self)
  local obj = self._obj
  self:play('exit')
  obj.invincible_count = obj.invincible_count - 1
  obj.status[self.sdata.id] = nil
end

Invincible.inst_meta.stop = _invincibleStop

Invincible.inst_meta.reset = function(self, sec)
  self._sec = sec
end

Invincible.inst_meta.update = function(self, dt)
  local t = self._sec - dt
  if t <= 0 then
    _invincibleStop(self)
    return
  end
  _aniUpdate(self, dt)
  self._sec = t
end




--[[
冰冻效果
]]
--[[
Frozen = _class(_Animation)

Frozen.ctor = function(self, obj, sec)
  local sdata = _status_data.frozen
  self.__super_ctor__(self, sdata, nil, obj.node)
  self.sdata = sdata
  self._obj = obj
  self._sec = sec
  obj.status[sdata.id] = self
  obj.move_x, obj.move_y = 0, 0
end

local function _frozenStop(self)
  self.ani_sprite:removeFromParent()
  self._obj.status[self.sdata.id] = nil
end

Frozen.inst_meta.stop = _frozenStop

Frozen.inst_meta.reset = function(self, sec)
  self._sec = sec
end

Frozen.inst_meta.update = function(self, dt)
  local t = self._sec - dt
  if t <= 0 then
    _frozenStop(self)
    return
  end
  _aniUpdate(self, dt)
  self._sec = t
  return true
end
]]

--------死亡效果
DeadShatter = _class(_Animation)

DeadShatter.ctor = function(self, char)
  self.scene = char.scene
  
  self.__super_ctor__(self, _dead_data.shatter)
  self.x, self.y, self.z = char.x, char.y, char.z
  self.node = self.ani_sprite
  self.scene:addObject(self)
  
  self:play('dead')
end

DeadShatter.inst_meta.clean = _effectClean

DeadShatter.inst_meta.update = function(self, dt)
  if _aniUpdate(self, dt) then
    _effectClean(self)
  end
end

--构造Animation的object结构
local _dead_object = {
}

DeadCut = _class(_Animation)

--用于构造Animation的数据table
DeadCut.ctor = function(self, char, spf, ani_name, v1x,v1y, v2x,v2y, v3x,v3y, v4x,v4y)
  self.scene = char.scene
  
  _dead_object[1] = spf
  self.__super_ctor__(self, _dead_object, _dead_data.cut.animations)
  self.ani_sprite:setQuad(v1x,v1y, v2x,v2y, v3x,v3y, v4x,v4y)
  
  self.x, self.y, self.z = char.x, char.y, char.z
  self.node = self.ani_sprite
  self.scene:addObject(self)
  
  self:play(ani_name)
  --TODO: 临时处理
  if ani_name=='dead_top' then
    self._ani_name = ani_name
    self._x, self._y = self.x, self.y
    self._tx, self._ty = self.x-50, self.y+100
  end
end

DeadCut.inst_meta.clean = _effectClean

--TODO: 临时模仿抛物线掉落
local _drop = {
  0.5,
  height=100,
  a=-100, b=0, c=100
}
  
DeadCut.inst_meta.update = function(self, dt)
  if _aniUpdate(self, dt) then
    _effectClean(self)
  elseif self._ani_name then
    --TODO: 来自金钱掉落，考虑整合到ani中
    --[[
      利用3个点拟合关于高度的抛物线，规范化后的时间范围[-1,1]
      三个点的(time,h)为(-1,0),(0,_GOLD_DROP_HEIGHT),(1,0)
      以此得出抛物线h=a*t^2+b*t+c，a~c对应 _GOLD_DROP_A~C
      h+y作为显示的y坐标
    ]]
    local t = self._ani_t
    local r = t/_drop[1]
    local rr = 2*r - 1
    local h = (_drop.a*rr + _drop.b)*rr + _drop.c
    self.x = self._x*(1-r) + self._tx*r
    self.y = self._y*(1-r) + self._ty*r + h
  end
end

DeadApart = _class(_Animation)

--用于构造Animation的数据table
DeadApart.ctor = function(self, char, spf, is_left)
  self.scene = char.scene
  
  local sdata = _dead_data.apart
  _dead_object[1] = spf
  self.__super_ctor__(self, _dead_object, sdata.animations)
  
  if is_left then
    self.ani_sprite:setQuad(0,0, 0.5,0, 0.5,1, 0,1)
    self._tx, self._ty = char.x+sdata.left_dx, char.y+sdata.left_dy
  else
    self.ani_sprite:setQuad(0.5,0, 1,0, 1,1, 0.5,1)
    self._tx, self._ty = char.x+sdata.right_dx, char.y+sdata.right_dy
  end
  
  self.x, self.y, self.z = char.x, char.y, char.z
  self.node = self.ani_sprite
  self.scene:addObject(self)
  
  self:play('dead')
end

DeadApart.inst_meta.clean = _effectClean

DeadApart.inst_meta.update = function(self, dt)
  if _aniUpdate(self, dt) then
    _effectClean(self)
    return
  end
    
  local kdt = _dead_data.apart.k * dt
  local x, y = self.x, self.y
  local dx, dy = self._tx -x, self._ty -y
  self.x = x + dx*kdt
  self.y = y + dy*kdt
end

DeadFire = _class(_Animation)

DeadFire.ctor = function(self, char)
  self.scene = char.scene
  
  self.__super_ctor__(self, _dead_data.fire)
  self.x, self.y, self.z = char.x, char.y, char.z
  self.node = self.ani_sprite
  self.scene:addObject(self)
  
  self:play('dead')
end

DeadFire.inst_meta.clean = _effectClean

DeadFire.inst_meta.update = function(self, dt)
  if _aniUpdate(self, dt) then
    _effectClean(self)
  end
end


DeadCrush = _class(_Animation)

DeadCrush.ctor = function(self, char)
  self.scene = char.scene
  --死亡最后一帧动画
  local ani_dead = char.sdata.object.animations.dead
  _dead_object[1] = ani_dead[#ani_dead][2]
  self.__super_ctor__(self, _dead_object, _dead_data.crush.animations)
  
  self.x, self.y, self.z = char.x, char.y, char.z
  self.node = self.ani_sprite
  self.scene:addObject(self)
  
  self:play('dead')
end

DeadCrush.inst_meta.clean = _effectClean

DeadCrush.inst_meta.update = function(self, dt)
  if _aniUpdate(self, dt) then
    _effectClean(self)
  end
end


DeadNone = _class(_Animation)

DeadNone.ctor = function(self, char)
  self.scene = char.scene
  --死亡最后一帧动画
  local ani_dead = char.sdata.object.animations.dead
  _dead_object[1] = ani_dead[#ani_dead][2]
  self.__super_ctor__(self, _dead_object, _dead_data.none.animations)
  
  self.x, self.y, self.z = char.x, char.y, char.z
  self.node = self.ani_sprite
  self.scene:addObject(self)
  
  self:play('dead')
end

DeadNone.inst_meta.clean = _effectClean

DeadNone.inst_meta.update = function(self, dt)
  if _aniUpdate(self, dt) then
    _effectClean(self)
  end
end

