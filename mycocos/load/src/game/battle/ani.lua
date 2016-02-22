module('game.battle.ani', package.seeall)

local _sprite_frames = require('game.mgr_spf').sprite_frames
local _mgr_snd = require('game.mgr_snd')

local _color_tbl = {r=0,g=0,b=0}

--[[
协助创建对象并处理动画格式
对象描述格式(desc)为
{
  {'frame',ax,ay} --若存在，设定初始显示帧及锚点(左上角0,0)
  init={ --若存在，设置初始数据
    position={x,y,z},
    scale={sx,sy},
    rotate=angle,
    rotation_range={0,180}, --范围内随机角度旋转
    visible=true|false, --
    color={r,g,b},
    alpha=255,
  },
}
动画数据(ani_data)为
{
  animation_name = {
    loop=true|false, --是否循环，不存在相当于false
    sound='sound_file', --若存在则播放声音
    { --每帧的信息
      sec, --持续的秒数
      {'frame',ax, ay}, --若存在,是sprite_frame及锚点。同desc
      init={...}, --若存在，指定该帧设置的初始位置。同desc
      actions = { --若存在，每帧插值更新
        rotate={0,360},
        position={{xs,ys,zs},{xd,yd,zd}},
        scale={0,1},
        scale_x={0,1},
        scale_y={0,1},
        alpha={0,255},
        color={{rs,gs,bs},{re,ge,be}},
      }
    }
    ...
  },
},
]]

Animation = require('util.class').class()

local function _initPosition(sprite, param)
  sprite:setPosition(param[1], param[2])
  sprite:setLocalZOrder(param[3])
end
local function _initScale(sprite, param, flipy)
  sprite:setScaleX(param[1])
  local sy = param[2]
  sprite:setScaleY(flipy and -sy or sy)
end
local function _initRotate(sprite, param)
  sprite:setRotation(param)
end
local function _initRotationRange(sprite, param)
  local angle = math.random(param[1], param[2])
  sprite:setRotation(angle)
end
local function _initAlpha(sprite, param)
  sprite:setOpacity(param)
end
local function _initVisible(sprite, param)
  sprite:setVisible(param)
end
local function _initColor(sprite, param)
  local c = _color_tbl
  c.r=param[1]
  c.g=param[2]
  c.b=param[3]
  sprite:setColor(c)
end
local _INIT_FUNC = {
  position = _initPosition,
  scale = _initScale,
  rotate = _initRotate,
  rotation_range = _initRotationRange,
  alpha = _initAlpha,
  visible = _initVisible,
  color = _initColor,
}

local function _setupFrame(sprite, frame, index, flipy)
  local pic = frame[index]
  if pic then
    local spf = _sprite_frames[pic[1]]
    sprite:setSpriteFrame(spf.frame)
    sprite:setAnchorPoint(pic[2]*spf.width_inv, 1-pic[3]*spf.height_inv)
  end
  local init = frame.init
  if init then
    for n,param in pairs(init) do
      _INIT_FUNC[n](sprite, param, flipy)
    end
  end
end

--[[
  desc: 对象描述格式，构造sprite的描述，见顶部说明和data.hero/enemy内的object
  ani_data: 动画描述，见顶部描述和data.hero/enemy/effect的描述
            若ani_data为nil，将用desc.animations
  parent: 父节点，若不为nil，则parent:addChild
  spr: 动画所关联的节点，若为nil则自建一个，到ani_sprite
  spr_self: spr是否自己创建
  flipy: y轴翻转，若为true，所有scale/scaley相关的init和actions都会乘以-1
]]
Animation.ctor = function(self, desc, ani_data, parent, spr, flipy)
  if spr then
    self.spr_self = false
  else
    spr = cc.Sprite:create()
    self.spr_self = true
  end
  if parent then
    parent:addChild(spr)
  end
  if flipy then
    spr:setScaleY(-1)
  end
  if desc then
    _setupFrame(spr, desc, 1, flipy)
  end
  self.ani_sprite = spr
  self._ani_data = ani_data or (desc and desc.animations)
  --self._ani_curr = nil
  --self._ani_frame_index = 1
  --self._ani_coeff = 1
  self._ani_t = 0
  self._flipy = (not not flipy) --确保true or false
end

Animation.inst_meta.isEnd = function(self)
  local ani = self._ani_curr
  return (not ani or self._ani_frame_index>#ani)
end

Animation.inst_meta.stop = function(self)
  self._ani_curr = nil
end

Animation.inst_meta.toggleFlipy = function(self)
  self._flipy = not self._flipy
  local spr = self.ani_sprite
  spr:setScaleY(-spr:getScaleY())
end

Animation.inst_meta.getTotal = function(self, name)
  local ani_data = self._ani_data
  local ani = ani_data and ani_data[name]
  if not ani then
    cclog('Animation.getTotal: %s not found', name)
    return 0
  end
  
  local t = 0
  for i, frame in ipairs(ani) do
    t = t + frame[1]
  end
  return t
end

local function _actionPosition(node, param, ratio)
  local p1, p2 = param[1], param[2]
  local x = p1[1]*(1-ratio) + p2[1]*ratio
  local y = p1[2]*(1-ratio) + p2[2]*ratio
  local z = p1[3]*(1-ratio) + p2[3]*ratio
  node:setPosition(x, y)
  node:setLocalZOrder(z)
end
local function _actionScale(node, param, ratio, flipy)
  local scale = param[1]*(1-ratio) + param[2]*ratio
  if not flipy then
    node:setScale(scale)
  else
    node:setScaleX(scale)
    node:setScaleY(-scale)
  end
end
local function _actionScaleX(node, param, ratio)
  node:setScaleX(param[1]*(1-ratio) + param[2]*ratio)
end
local function _actionScaleY(node, param, ratio, flipy)
  local scale = param[1]*(1-ratio) + param[2]*ratio
  node:setScaleY(flipy and -scale or scale)
end
local function _actionAlpha(node, param, ratio)
  node:setOpacity(param[1]*(1-ratio) + param[2]*ratio)
end
local function _actionRotate(node, param, ratio)
  node:setRotation(param[1]*(1-ratio) + param[2]*ratio)
end
local function _actionColor(node, param, ratio)
  local c = _color_tbl
  local p1, p2 = param[1], param[2]
  c.r = p1[1]*(1-ratio) + p2[1]*ratio
  c.g = p1[2]*(1-ratio) + p2[2]*ratio
  c.b = p1[3]*(1-ratio) + p2[3]*ratio
  node:setColor(c)
end
local _ACTION_FUNC = {
  position = _actionPosition,
  scale = _actionScale,
  scale_x = _actionScaleX,
  scale_y = _actionScaleY,
  alpha = _actionAlpha,
  rotate = _actionRotate,
  color = _actionColor,
}

Animation.inst_meta.play = function(self, name, acc_coeff)
  local ani_data = self._ani_data
  local ani = ani_data and ani_data[name]
  if not ani then
    cclog('Animation.play: %s not found', name)
    self._ani_curr = nil
    return
  end
  
  self._ani_curr = ani
  self._ani_frame_index = 1
  self._ani_coeff = acc_coeff or 1
  self._ani_t = 0
  
  local node, flipy = self.ani_sprite, self._flipy
  local frame = ani[1]
  _setupFrame(node, frame, 2, flipy)
  if frame.actions then
    for n,param in pairs(frame.actions) do
      _ACTION_FUNC[n](node, param, 0, flipy)
    end
  end
  
  if ani.sound then
    _mgr_snd.playEffect(ani.sound)
  end
end

Animation.inst_meta.update = function(self, dt)
  local ani, index = self._ani_curr, self._ani_frame_index
  if not ani or index>#ani then
    return true
  end
  
  local frame = ani[index]
  local t = self._ani_t + dt
  local time = frame[1] * self._ani_coeff
  
  local node, flipy = self.ani_sprite, self._flipy
  while t > time do
    index = index + 1
    if index > #ani then
      if not ani.loop then
        _setupFrame(node, frame, 2, flipy)
        if frame.actions then
          for n,param in pairs(frame.actions) do
            _ACTION_FUNC[n](node, param, 1, flipy)
          end
        end
        self._ani_frame_index = index
        return true
      end
      index = 1
    end
    t = t - time
    frame = ani[index]
    time = frame[1] * self._ani_coeff
    _setupFrame(node, frame, 2, flipy)
  end
  
  if frame.actions then
    local ratio = t/time
    for n,param in pairs(frame.actions) do
      _ACTION_FUNC[n](node, param, ratio, flipy)
    end
  end
  self._ani_frame_index = index
  self._ani_t = t
  return false
end



