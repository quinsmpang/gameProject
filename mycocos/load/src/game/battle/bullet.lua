module('game.battle.bullet', package.seeall)

local _const = require('data.const')
local _bullets_data = require('data.bullet').bullets
local _Animation = require('game.battle.ani').Animation
local _aniUpdate = _Animation.inst_meta.update

local _normalize = require('util.calc').normalize


local _clean = function(self)
  local scene = self.scene
  scene:removeObject(self)
  scene.coll:removeColl(self)
end

--[[
负责普通子弹的显示、逻辑
scene:
sdata: 所关联的 data.bullet.bullets内的静态数据

x, y:
node:
coll_left, coll_right, coll_top, coll_bottom:

power:
cancel_left:

team: 对英雄所发的子弹，需附加该项
]]
Bullet = require('util.class').class(_Animation)

Bullet.ctor = function(self, scene, id, x, y, power, distance, vec_x, vec_y, speed, coll_type, flipy)
  self.scene = scene
  local sdata = _bullets_data[id]
  self.sdata = sdata
  
  self.__super_ctor__(self, sdata.object, nil, nil, nil, flipy)
  self.x, self.y = x, y
  self.z = sdata.z
  self.node = self.ani_sprite
  scene:addObject(self)
  self:play('fly')
    
  local coll = sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  if not flipy then
    self.coll_top = coll[3]
    self.coll_bottom = coll[4]
  else
    self.coll_top = -coll[4]
    self.coll_bottom = -coll[3]
  end
  scene.coll:addColl(self, coll_type)
  
  self.power = power
  self.cancel_left = sdata.cancel_count
  self.hit_left = sdata.hit_count
  self._target_attacked = false
  
  self._distance = distance
  self._speed = speed
  self._length = 0
  
  self._speed_x, self._speed_y = _normalize(vec_x, vec_y, speed)
  
  --self.team 产生者注入
end

Bullet.inst_meta.clean = _clean

Bullet.inst_meta.update = function(self, dt)
  local len = self._length
  if len > self._distance then
    _clean(self)
    return
  end
  self._length = len + self._speed * dt
  _aniUpdate(self, dt)
  self.x = self.x + self._speed_x * dt
  self.y = self.y + self._speed_y * dt
end

--与敌方子弹碰撞
Bullet.inst_meta.cancelled = function(self, count)
  local c = self.cancel_left - count
  self.cancel_left = c
  if c <= 0 then
    _clean(self)
  end
end

--判断是否能打中敌人
Bullet.inst_meta.canAttack = function(self, target)
  local t = self._target_attacked
  return not t or not t[target]
end

--攻击了敌人
Bullet.inst_meta.attacked = function(self, target)
  local hit_left = self.hit_left - 1
  self.hit_left = hit_left
  
  if hit_left <= 0 then
    self.scene.coll:removeColl(self)
  else
    local t = self._target_attacked
    if not t then
      t = {}
      self._target_attacked = t
    end
    t[target] = true
  end
  
  --攻击硬直，但不叠加
  local hit_stub = self.sdata.hit_stub
  if hit_stub and hit_stub>0 
    and not rawget(self, 'update')
  then
    self.update = function(self, dt)
      hit_stub = hit_stub - dt
      if hit_stub <= 0 then
        if self.hit_left <= 0 then
          _clean(self)
        else
          self.update = nil
        end
      end
    end
  end
end

--反射
Bullet.inst_meta.reflect = function(self, collx, colly, colltype)
  self.scene.coll:removeColl(self)
  
  local function doReflect()
    self._speed_y = -self._speed_y
    self:toggleFlipy()
    self:play('fly')
    local top = self.coll_top
    self.coll_top = -self.coll_bottom
    self.coll_bottom = -top
    self.scene.coll:addColl(self, colltype)
    
    self.y = colly
    self._length = 0
  end

  local total = self:getTotal('reflect')
  if total==0 then
    doReflect()
    return true
  end
  
  --播放反射动画期间替换原update，结束后恢复
  local refy = self.y
  local t = 0
  local tinv = 1/total
  self.update = function(self, dt)
    if not _aniUpdate(self, dt) then
      t = t + dt
      local r = t*tinv
      self.y = refy*(1-r) + colly*r
      return
    end
        
    self.update = nil
    doReflect()
  end
  
  self:play('reflect')
  return true
end

--[[
scene:
sdata: 所关联的 data.bullet.bullets内的静态数据

x, y:
node:
coll_left, coll_right, coll_top, coll_bottom:

power:
team: 英雄所发的需存在
]]
Dropper = require('util.class').class(_Animation)

Dropper.ctor = function(self, scene, id, x, power, distance, down, time, coll_type)
  self.scene = scene
  local sdata = _bullets_data[id]
  self.sdata = sdata
  
  local ystart = scene.distance + scene.height
  local node = cc.Node:create()
  self.__super_ctor__(self, sdata.object, nil, node)
  self.x, self.y = x, ystart
  self.z = _const.SCENE_Z_EFFECT
  self.node = node
  scene:addObject(self)
  self:play('drop')
  
  self.coll_left = -distance*0.5
  self.coll_right = distance*0.5
  self.coll_top = distance*0.5
  self.coll_bottom = -distance*0.5
  self._colltype = coll_type
  
  self._is_dropping = true
  self._ystart = ystart
  self._yend = ystart - down
  self._t, self._time = 0, time
  
  self.power = power
  self.distance = distance
  self.cancel_left = sdata.cancel_count
  self._target_attacked = {}
  
  --self.team 产生者注入
end

Dropper.inst_meta.clean = _clean

Dropper.inst_meta.update = function(self, dt)
  _aniUpdate(self, dt)
  if self._is_dropping then
    local t = self._t + dt
    local r = t/self._time
    self.y = self._ystart*(1-r) + self._yend*r
    if r<1 then
      self._t = t
    else
      self._is_dropping = false
      self._t = nil --表示爆炸中
      self.scene.coll:addColl(self, self._colltype)
      self.node:setScale(self.distance * self.sdata.spframe_distance_inv)
      self:play('explode')
      self.z = 0
    end
  elseif self._t then
    local t = self._t
    if t > 0 then
      t = self._t - dt
      if t <= 0 then
        _clean(self)
      end
      self._t = t
    end
  elseif self:isEnd() then
    if not self.sdata.keep_pic then
      _clean(self)
    else
      self.z = -1
      self.scene.coll:removeColl(self)
      --保留裂痕的时间
      self._t = self.scene.effect_sec or 0
    end
  end
end

Dropper.inst_meta.cancelled = function(self, c)
end

Dropper.inst_meta.canAttack = Bullet.inst_meta.canAttack

Dropper.inst_meta.attacked = function(self, target)
  self._target_attacked[target] = true
end

Dropper.inst_meta.reflect = function(self, collx, colly, colltype)
end



--[[
爆炸溅射
scene:
sdata: 所关联的 data.bullet.bullets内的静态数据

x, y:
node:
coll_left, coll_right, coll_top, coll_bottom:

power:
team: 英雄所发的需存在
]]
local _Sputter = require('util.class').class(_Animation)

_Sputter.ctor = function(self, scene, id, x, y, power, coll_type, from_attacked)
  self.scene = scene
  local sdata = _bullets_data[id]
  self.sdata = sdata
  
  self.__super_ctor__(self, sdata.object, nil, nil, nil)
  self.x, self.y = x, y
  self.z = sdata.z
  self.node = self.ani_sprite
  scene:addObject(self)
  self:play('sputter')
    
  local coll = sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  self.coll_top = coll[3]
  self.coll_bottom = coll[4]
  scene.coll:addColl(self, coll_type)
  
  self.power = power
  self._target_attacked = {[from_attacked]=true}
  
  --self.team 产生者注入
end

_Sputter.inst_meta.clean = _clean

_Sputter.inst_meta.update = function(self, dt)
  if _aniUpdate(self, dt) then
    _clean(self)
  end
end

_Sputter.inst_meta.cancelled = Bullet.inst_meta.cancelled

_Sputter.inst_meta.canAttack = Bullet.inst_meta.canAttack

_Sputter.inst_meta.attacked = function(self, target)
  self._target_attacked[target] = true
  --溅射无击中特效
  return true
end

_Sputter.inst_meta.reflect = function(self, collx, colly, colltype)
end

--[[
追踪弹
scene:
sdata: 所关联的 data.bullet.bullets内的静态数据

x, y:
node:
coll_left, coll_right, coll_top, coll_bottom:

power:
team: 英雄所发的需存在
]]
Tracer = require('util.class').class(_Animation)

Tracer.ctor = function(self, scene, id, x, y, power, distance, param, coll_type, flipy)
  self.scene = scene
  local sdata = _bullets_data[id]
  self.sdata = sdata
  
  self.__super_ctor__(self, sdata.object, nil, nil, nil, flipy)
  self.x, self.y = x, y
  self.z = sdata.z
  self.node = self.ani_sprite
  scene:addObject(self)
  self:play('fly')
    
  local coll = sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  if not flipy then
    self.coll_top = coll[3]
    self.coll_bottom = coll[4]
  else
    self.coll_top = -coll[4]
    self.coll_bottom = -coll[3]
  end
  scene.coll:addColl(self, coll_type)
  
  self.power = power
  self.coll_type = coll_type
  self.cancel_left = sdata.cancel_count
  self.hit_left = sdata.hit_count
  self._target_attacked = false
  
  self._distance = distance
  self._speed = param.speed
  self._turn_k = param.turn_k
  self._length = 0
  --
  local vx, vy = _normalize(param.vector[1], param.vector[2])
  self._vec_x, self._vec_y = vx, vy
  --2dx所需是角度，57.296=360/(2*pi)
  --资源（旋转为0）对应于垂直向上（90度），且顺时针为正方向。
  local rad = math.atan2(vy, vx)
  self.node:setRotation(90 - rad*57.296)
  --
  self._do_trace = true
  self._tracer = nil
  --self.team 产生者注入
end

Tracer.inst_meta.clean = _clean

Tracer.inst_meta.update = function(self, dt)
  local len = self._length
  if len > self._distance then
    _clean(self)
    return
  end
  --
  local sp = self._speed
  local vx, vy = self._vec_x, self._vec_y
  if self._do_trace then
    local tracer = self._tracer
    --更新，找最近敌人
    if not tracer or not tracer._coll_valid then
      local dist2, x, y = math.huge, self.x, self.y
      tracer = nil
      for i,e in ipairs(self.scene.coll.type2colls[_const.COLL_TYPE_ENEMY]) do
        if e._coll_valid then
          local dx, dy = e.x-x, e.y-y
          local d2 = dx*dx + dy*dy
          if d2 < dist2 then
            tracer = e
            dist2 = d2
          end
        end
      end
      self._tracer = tracer
    end
    --更新方向和旋转
    if tracer then
      local dx, dy = _normalize(tracer.x-self.x, tracer.y-self.y, self._turn_k)
      vx, vy = _normalize(vx+dx, vy+dy)
      self._vec_x, self._vec_y = vx, vy
      --2dx所需是角度，57.296=360/(2*pi)
      --资源（旋转为0）对应于垂直向上（90度），且顺时针为正方向。
      local rad = math.atan2(vy, vx)
      self.node:setRotation(90 - rad*57.296)
    end
  end --end self._do_trace
  
  self.x = self.x + sp*vx * dt
  self.y = self.y + sp*vy * dt
  self._length = len + sp * dt
  _aniUpdate(self, dt)
end

Tracer.inst_meta.cancelled = Bullet.inst_meta.cancelled

Tracer.inst_meta.canAttack = Bullet.inst_meta.canAttack

local _bulletAttacked = Bullet.inst_meta.attacked
Tracer.inst_meta.attacked = function(self, target, collx, colly)
  _bulletAttacked(self, target)
  
  local follow_id = self.sdata.bullet_follow
  if follow_id then
    local s = _Sputter(self.scene, follow_id, collx, colly, 
      self.power *0.5, self.coll_type, target)
    s.team = self.team
    --无须显示击中特效
    return true
  end
end

Tracer.inst_meta.reflect = function(self, collx, colly, colltype)
  self.scene.coll:removeColl(self)
  
  local function doReflect()
    self._do_trace = false
    local vx, vy = -self._vec_x, -self._vec_y
    self._vec_x, self._vec_y = vx, vy
    local rad = math.atan2(vy, vx)
    self.node:setRotation(90 - rad*57.296)
    
    local top = self.coll_top
    self.coll_top = -self.coll_bottom
    self.coll_bottom = -top
    self.scene.coll:addColl(self, colltype)
    
    self.y = colly
    self._length = 0
  end

  local total = self:getTotal('reflect')
  if total==0 then
    doReflect()
    return true
  end
  
  --播放反射动画期间替换原update，结束后恢复
  local refy = self.y
  local t = 0
  local tinv = 1/total
  self.update = function(self, dt)
    if not _aniUpdate(self, dt) then
      t = t + dt
      local r = t*tinv
      self.y = refy*(1-r) + colly*r
      return
    end
        
    self.update = nil
    doReflect()
  end
  
  self:play('reflect')
  return true
end


 
--[[
条状发射物
scene:
sdata: 所关联的 data.bullet.bullets内的静态数据

x, y:
node:
coll_left, coll_right, coll_top, coll_bottom:

power:
team: 英雄所发的需存在
]]
Strip = require('util.class').class(_Animation)

Strip.ctor = function(self, scene, id, x, y, power, distance, speed, vec_x, vec_y, coll_type, flipy)
  self.scene = scene
  local sdata = _bullets_data[id]
  self.sdata = sdata
  
  self.__super_ctor__(self, sdata.object, nil, nil, nil, flipy)
  self.x, self.y = x, y
  self.z = sdata.z
  self.node = self.ani_sprite
  scene:addObject(self)
  self:play('fly')
    
  local coll = sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  if not flipy then
    self.coll_top = coll[3]
    self.coll_bottom = coll[4]
  else
    self.coll_top = -coll[4]
    self.coll_bottom = -coll[3]
  end
  scene.coll:addColl(self, coll_type)
  
  self.power = power
  self.coll_type = coll_type
  self.cancel_left = sdata.cancel_count
  self.hit_left = sdata.hit_count
  self._target_attacked = false
  
  self.power = power
  self.cancel_left = sdata.cancel_count
  self.hit_left = sdata.hit_count
  self._target_attacked = false
  
  self._distance = distance
  self._speed = speed
  self._length = 0
  self._speed_x, self._speed_y = _normalize(vec_x, vec_y, speed)
  
  --
  self._flip = flipy
  self._ey = 0
  self.ani_sprite:setScaleY(0)
  
  --self.team 产生者注入
end

Strip.inst_meta.clean = _clean

local function _stripUpdateIn(self, dt)
  local delta = self._speed *dt
  local ey = self._ey - delta
  if ey <= 0 then
    _clean(self)
    return
  end
  
  self._ey = ey
  local sdata = self.sdata
  local ratio = ey * sdata.spframe_y_inv
  if self._flip then
    self.ani_sprite:setScaleY(-ratio)
    self.y = self.y - delta
  else
    self.ani_sprite:setScaleY(ratio)
    self.y = self.y + delta
  end
end

local function _stripUpdateFly(self, dt)
  local len = self._length
  if len > self._distance then
    self.scene.coll:removeColl(self)
    self.update = _stripUpdateIn
    return
  end
  
  _aniUpdate(self, dt)
  self.x = self.x + self._speed_x * dt
  self.y = self.y + self._speed_y * dt
  self._length = len + self._speed * dt
end

Strip.inst_meta.update = function(self, dt)
  local len = self._length
  if len > self._distance then
    self.scene.coll:removeColl(self)
    self.update = _stripUpdateIn
    return
  end
  
  _aniUpdate(self, dt)

  local sp = self._speed
  local sdata = self.sdata
  local ey = self._ey + sp*dt
  if ey >= sdata.spframe_y then
    ey = sdata.spframe_y
    self.update = _stripUpdateFly
  end
  
  local ratio = ey * sdata.spframe_y_inv
  if self._flip then
    self.ani_sprite:setScaleY(-ratio)
    self.coll_bottom = -ey
  else
    self.ani_sprite:setScaleY(ratio)
    self.coll_top = ey
  end
  self._ey = ey
  self._length = len + self._speed * dt
end

Strip.inst_meta.cancelled = function(self, count)
  local c = self.cancel_left - count
  self.cancel_left = c
  if c <= 0 then
    self.scene.coll:removeColl(self)
    self.update = _stripUpdateIn
  end
end

Strip.inst_meta.canAttack = Bullet.inst_meta.canAttack

Strip.inst_meta.attacked = function(self, target)
  --攻击无硬直
  local hit_left = self.hit_left - 1
  self.hit_left = hit_left
  
  if hit_left <= 0 then
    self.scene.coll:removeColl(self)
    self.update = _stripUpdateIn
  else
    local t = self._target_attacked
    if not t then
      t = {}
      self._target_attacked = t
    end
    t[target] = true
  end
end

Strip.inst_meta.reflect = function(self, collx, colly, colltype)
end
 
--[[
attacher: 关联的node，随之而移动
param:

主动结束时，调用 attacher.onFlameEnd(attacher, self)
]]
Flame = require('util.class').class(_Animation)

Flame.ctor = function(self, scene, id, attacher, param, power, distance, coll_type, flipy)
  self.scene = scene
  local sdata = _bullets_data[id]
  self.sdata = sdata
  
  self.__super_ctor__(self, sdata.object, nil, nil, nil, flipy)
  self.x, self.y = attacher.x+param.offset[1], attacher.y+param.offset[2]
  self.z = sdata.z
  self.node = self.ani_sprite
  scene:addObject(self)
  self:play('shoot')
  
  local coll = sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  if not flipy then
    self.coll_top = coll[3]
    self.coll_bottom = coll[4]
  else
    self.coll_top = -coll[4]
    self.coll_bottom = -coll[3]
  end
  scene.coll:addColl(self, coll_type)
  
  self.power = power
  
  self._distance = distance
  self._target_attacked = {}
  self._attacher = attacher
  self._param = param
  self._flip = flipy
  self._t = 0
  self._t_rehit = param.sec_rehit
  self.ani_sprite:setScaleY(0)
end

Flame.inst_meta.clean = _clean

Flame.inst_meta.update = function(self, dt)
  local param = self._param
  local attacher = self._attacher
  
  local ratio
  local t = self._t + dt
  if t <= param.sec_out then
    ratio = t * param.sec_out_inv
  elseif t <= param.sec_keep then
    ratio = 1
  elseif t <= param.sec_in then
    ratio = (param.sec_in - t) * param.sec_in_inv
  else
    _clean(self)
    attacher.onFlameEnd(attacher, self)
    return
  end
  
  self._t = t
  
  local coll = ratio * self._distance
  if self._flip then
    coll = -coll
    self.coll_bottom = coll
    self.ani_sprite:setScaleY(coll * self.sdata.spframe_y_inv)
  else
    self.coll_top = coll
    self.ani_sprite:setScaleY(coll * self.sdata.spframe_y_inv)
  end
  _aniUpdate(self, dt)
  
  self.x = attacher.x + param.offset[1]
  self.y = attacher.y + param.offset[2]
  
  t = self._t_rehit - dt
  if t <= 0 then
    t = param.sec_rehit
    local targets = self._target_attacked
    for n,v in pairs(targets) do
      targets[n] = nil
    end
  end
  self._t_rehit = t
end

Flame.inst_meta.cancelled = function(self, c)
end

Flame.inst_meta.canAttack = function(self, target)
  return not self._target_attacked[target]
end

Flame.inst_meta.attacked = function(self, target)
  self._target_attacked[target] = true
  --攻击无硬直
end

Flame.inst_meta.reflect = function(self, collx, colly, colltype)
end


--[[
attacher: 关联的node，随之而移动
param:

主动结束时，调用 attacher.onBallEnd(attacher, self)
]]
Ball = require('util.class').class(_Animation)

Ball.ctor = function(self, scene, id, attacher, param, power, coll_type, flipy)
  self.scene = scene
  local sdata = _bullets_data[id]
  self.sdata = sdata
  
  self.__super_ctor__(self, sdata.object, nil, nil, nil, flipy)
  self.x, self.y = attacher.x+param.offset[1], attacher.y+param.offset[2]
  self.z = sdata.z
  self.node = self.ani_sprite
  scene:addObject(self)
  self:play('shoot')
  
  local coll = sdata.collision
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  if not flipy then
    self.coll_top = coll[3]
    self.coll_bottom = coll[4]
  else
    self.coll_top = -coll[4]
    self.coll_bottom = -coll[3]
  end
  scene.coll:addColl(self, coll_type)
  
  self.power = power
  self.cancel_left = sdata.cancel_count
  
  self._target_attacked = {}
  self._attacher = attacher
  self._param = param
  self._flip = flipy
  self._t = param.sec
  self._t_rehit = param.sec_rehit
end

Ball.inst_meta.clean = _clean

Ball.inst_meta.update = function(self, dt)
  local param = self._param
  local attacher = self._attacher
  
  local t = self._t - dt
  if t <= 0 then
    _clean(self)
    attacher.onBallEnd(attacher, self)
    return
  end
  
  self._t = t
  _aniUpdate(self, dt)
  
  self.x = attacher.x + param.offset[1]
  self.y = attacher.y + param.offset[2]
  
  t = self._t_rehit - dt
  if t <= 0 then
    t = param.sec_rehit
    local targets = self._target_attacked
    for n,v in pairs(targets) do
      targets[n] = nil
    end
  end
  self._t_rehit = t
end

Ball.inst_meta.cancelled = function(self, count)
  local c = self.cancel_left - count
  self.cancel_left = c
  if c <= 0 then
    local attacher = self._attacher
    _clean(self)
    attacher.onBallEnd(attacher, self)
  end
end

Ball.inst_meta.canAttack = function(self, target)
  return not self._target_attacked[target]
end

Ball.inst_meta.attacked = function(self, target)
  self._target_attacked[target] = true
  --攻击无硬直
end

Ball.inst_meta.reflect = function(self, collx, colly, colltype)
end
