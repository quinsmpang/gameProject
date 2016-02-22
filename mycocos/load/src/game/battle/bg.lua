module('game.battle.bg', package.seeall)

local _sprite_frames = require('game.mgr_spf').sprite_frames

local _HEIGHT = require('config').design.height
local _SPR_HEIGHT = _HEIGHT  --背景图的高度

--[[
负责背景层渲染、滚动
scene: 所属场景
node: 
sprites: {
  1-num, ext: 背景图片sprite
  ext_on: 若ext图片显示中，显示在索引图片之上
}
curr_bg
curr_times_left
curr_pic_left
saved_bg, saved_times_left
]]
BG = require('util.class').class()

local _BG = {
  cave={spr='bg/cave.png', ext='bg/cave_ext.png', next='sea', times=4},
  sea={spr='bg/sea.png', ext='bg/sea_ext.png', next='stone', times=4},
  stone={spr='bg/stone.png', ext='bg/stone_ext.png', next='sanc', times=4},
  sanc={spr='bg/sanctuary.png', ext='bg/sanctuary_ext.png', next='cave', times=4},
  bonus={spr='bg/bonus.png', ext='bg/bonus_ext.png', next='bonus', times=1},
}

local _setupCurrBG

BG.ctor = function(self, scene)
  self.scene = scene
  self.node = cc.Node:create()
  
  self.sprites = {
    --1~n, ext: 各个sprite
    --ext_on: 不为nil，表示在 index=ext_on 的sprite上显示
  }
  local num = math.ceil(_HEIGHT / _SPR_HEIGHT) + 1
  for i=1, num do
    local spr = cc.Sprite:create()
    self.node:addChild(spr)
    self.sprites[i] = spr
    spr:setAnchorPoint(0, 0)
  end
  local sp_ext = cc.Sprite:create()
  sp_ext:setAnchorPoint(0, 0)
  self.node:addChild(sp_ext, 1)
  self.sprites.ext = sp_ext
  
  _setupCurrBG(self, _BG['cave'])
  self.saved_bg = nil
  self.saved_times_left = nil
  
  --self.fade_sec = nil
  --self.fade_sec_inv = nil
  --self.fade_t = nil
  --self.fade_from = nil
  --self.fade_to = nil
end

_setupCurrBG = function(self, bg)
  self.curr_bg = bg
  self.curr_times_left = bg.times
  self.curr_pic_left = _SPR_HEIGHT
  
  local frame = _sprite_frames[bg.spr].frame
  local y = 0
  for i, spr in ipairs(self.sprites) do
    spr:setSpriteFrame(frame)
    spr:setPosition(0, y)
    y = y + _SPR_HEIGHT
  end
  self.sprites.ext:setVisible(false)
end

BG.inst_meta.save = function(self)
  self.saved_bg = self.curr_bg
  self.saved_times_left = self.curr_times_left
end

BG.inst_meta.restore = function(self)
  if not self.saved_bg then return end
  
  _setupCurrBG(self, self.saved_bg)
  self.curr_times_left = self.saved_times_left
  self.saved_bg, self.saved_times_left = nil
end

BG.inst_meta.switch = function(self, name)
  local bg = _BG[name]
  if bg then
    _setupCurrBG(self, bg)
  end
end

BG.inst_meta.fadeOut = function(self, sec)
  if sec > 0 then
    self.fade_sec = sec
    self.fade_sec_inv = 1/sec
    self.fade_t = 0
    self.fade_from = 255
    self.fade_to = 0
  end
end

BG.inst_meta.fadeIn = function(self, sec)
  if sec > 0 then
    self.fade_sec = sec
    self.fade_sec_inv = 1/sec
    self.fade_t = 0
    self.fade_from = 0
    self.fade_to = 255
  end
end

local function _updateFade(self, dt)
  local t = self.fade_t + dt
  
  local alpha
  if t < self.fade_sec then
    local r = t * self.fade_sec_inv
    alpha = self.fade_from*(1-r) + self.fade_to*r
    self.fade_t = t
  else
    alpha = self.fade_to
    self.fade_sec = nil
  end
  
  local sprs = self.sprites
  for i, spr in ipairs(sprs) do
    spr:setOpacity(alpha)
  end
  sprs.ext:setOpacity(alpha)
end

BG.inst_meta.scrollDown = function(self, v, dt)
  if self.fade_sec then
    _updateFade(self, dt)
  end
  local curr_bg = self.curr_bg
  local pic_left = self.curr_pic_left
 
  pic_left = pic_left - v*dt
  if pic_left <= 0 then
    pic_left = pic_left + _SPR_HEIGHT
    
    local sprs = self.sprites
    local sp1 = sprs[1]
    local n = #sprs
    local y = 0
    for i=1, n-1 do
      local sp = sprs[i+1]
      sp:setPosition(0, y)
      sprs[i] = sp
      y = y + _SPR_HEIGHT
    end
    sp1:setPosition(0, y)
    sprs[n] = sp1
    
    if sprs.ext_in then
      local ext_in = sprs.ext_in - 1
      if ext_in > 0 then
        sprs.ext_in = ext_in
        sprs.ext:setPosition(0, _SPR_HEIGHT*(ext_in-1))
      else
        sprs.ext:setVisible(false)
        sprs.ext_in = nil
      end
    end
    
    local times_left = self.curr_times_left - 1
    if times_left > 0 then
      self.curr_times_left = times_left
    else
      local next_bg = _BG[curr_bg.next]
      if next_bg ~= curr_bg then
        local sp_ext = sprs.ext
        sp_ext:setSpriteFrame(_sprite_frames[curr_bg.ext].frame)
        sp_ext:setPosition(0, _SPR_HEIGHT*(n-1))
        sp_ext:setVisible(true)
        sprs.ext_in = n
      end
      
      curr_bg = next_bg
      self.curr_bg = next_bg
      self.curr_times_left = next_bg.times
    end
    
    sp1:setSpriteFrame(_sprite_frames[curr_bg.spr].frame)
  end --pic_left<=0
  
  self.node:setPosition(0, pic_left - _SPR_HEIGHT)
  self.curr_pic_left = pic_left
end
