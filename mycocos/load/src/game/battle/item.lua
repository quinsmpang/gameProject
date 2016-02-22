module('game.battle.item', package.seeall)

local _mgr_snd = require('game.mgr_snd')
local _sprite_frames = require('game.mgr_spf').sprite_frames
local _Animation = require('game.battle.ani').Animation

local _effect = require('game.battle.effect')
local _data_effect = require('data.effect')

local _golds = require('data.item').golds
local _draw_coin = require('data.item').draw_coin
local _heros = require('data.hero').heros
local _prisoner = require('data.item').prisoner
local _data_items = require('data.item').items

local _const = require('data.const')

local _TYPE_ITEM = _const.COLL_TYPE_ITEM
local _GOLD_COLLECT_Z = _const.SCENE_Z_EFFECT

local _GOLD_DROP_A = _golds.drop.a
local _GOLD_DROP_B = _golds.drop.b
local _GOLD_DROP_C = _golds.drop.c

local _GOLD_RANGE_LEFT = _golds.range.left
local _GOLD_RANGE_RIGHT = _golds.range.right
local _GOLD_RANGE_BOTTOM = _golds.range.bottom
local _GOLD_RANGE_TOP = _golds.range.top
local _GOLD_RANGE_MINX = _golds.range.minx
local _GOLD_RANGE_MAXX = _golds.range.maxx


--各类道具：掉落金钱、俘虏都放在此

--[[ 掉落的金钱
scene:
x, y:
node:
coll_left, coll_right, coll_top, coll_bottom:
]]
Gold = require('util.class').class(_Animation)

local _aniUpdate = _Animation.inst_meta.update
local _updateGoldDropping
local _updateGoldWaitPick
local _updateGoldAttracting
local _updateGoldCollecting


Gold.ctor = function(self, scene, x, y, tx, ty, sdata)
  self.scene = scene
  self.sdata = sdata
  
  self.__super_ctor__(self, sdata, _golds.animations)
  self.x, self.y, self.z = x, y, 0
  self.node = self.ani_sprite
  scene:addObject(self)
  
  local coll = sdata.coll
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  self.coll_top = coll[3]
  self.coll_bottom = coll[4]
  
  self._x, self._y = self.x, self.y
  self._tx, self._ty = tx, ty
  self._t, self._total = 0, _golds.drop[1]
  self.update = _updateGoldDropping
  --self._team 被获取后，记录所属队伍
end

_updateGoldDropping = function(self, dt)
  local att = self.scene.item_attractor
  if att then
    self.scene.coll:addColl(self, _TYPE_ITEM)
    self._t, self._total = 0, _golds.attract
    self._x, self._y = self.x, self.y
    self.update = _updateGoldAttracting
    return
  end
  
  --[[
    利用3个点拟合关于高度的抛物线，规范化后的时间范围[-1,1]
    三个点的(time,h)为(-1,0),(0,_GOLD_DROP_HEIGHT),(1,0)
    以此得出抛物线h=a*t^2+b*t+c，a~c对应 _GOLD_DROP_A~C
    h+y作为显示的y坐标
  ]]
  local drop = _golds.drop
  local t = self._t + dt
  self._t = t
  local r = t/self._total
  local rr = 2*t/self._total - 1
  local h = (_GOLD_DROP_A*rr + _GOLD_DROP_B)*rr + _GOLD_DROP_C
  self.x = self._x*(1-r) + self._tx*r
  self.y = self._y*(1-r) + self._ty*r + h
  if r < 1 then return end
  
  self.scene.coll:addColl(self, _TYPE_ITEM)
  self.update = _updateGoldWaitPick
end

_updateGoldWaitPick = function(self, dt)
  local att = self.scene.item_attractor
  if att then
    self._t, self._total = 0, _golds.attract
    self._x, self._y = self.x, self.y
    self.update = _updateGoldAttracting
  end
end

_updateGoldAttracting = function(self, dt)
  local att = self.scene.item_attractor
  if not att then
    self.update = _updateGoldWaitPick
    return
  end
  
  local t = 0
  local total_inv = 1/_golds.attract

  t = self._t + dt
  local r = t /self._total
  if r>1 then r=1 end
  self.x = self._x*(1-r) + att.x*r
  self.y = self._y*(1-r) + att.y*r
  self._t = t
end

local function _goldClean(self)
  self.scene:removeObject(self)
  self.scene.coll:removeColl(self)
end

Gold.inst_meta.clean = _goldClean

_updateGoldCollecting = function(self, dt)
  if not self:isEnd() then
    _aniUpdate(self, dt)
  else
    local t = self._t + dt
    local r = t/self._total
    self.x = self._x*(1-r) + self._tx*r
    self.y = self._y*(1-r) + (self.scene.distance+self._ty)*r
    self._t = t
    if r >= 1 then
      self._team:addGolds(self.sdata.value)
      _goldClean(self)
    end
  end
end


Gold.inst_meta.touched = function(self, hero)
  local team = hero.team
  if not team then return end
  
  self.scene.coll:removeColl(self)
  self.z = _GOLD_COLLECT_Z
  self:play('collect_up')
  
  self._x, self._y = self.x, self.y
  self._tx, self._ty = team.gold_x, team.gold_y
  self._t, self._total = 0, _golds.move[1]
  self.update = _updateGoldCollecting
  self._team = team
end


-----
DrawCoin = require('util.class').class(_Animation)

local _updateDrawCoinDropping
local _updateDrawCoinWaitPick
local _updateDrawCoinAttracting

DrawCoin.ctor = function(self, scene, x, y, tx, ty, sdata)
  self.scene = scene
  self.sdata = sdata
  
  self.__super_ctor__(self, sdata)
  self.x, self.y, self.z = x, y, 0
  self.node = self.ani_sprite
  scene:addObject(self)
  
  self._effect = _Animation(sdata.effect, nil, self.node)
  self._effect:play('shine')
  
  local coll = sdata.coll
  self.coll_left = coll[1]
  self.coll_right = coll[2]
  self.coll_top = coll[3]
  self.coll_bottom = coll[4]
  
  self._x, self._y = self.x, self.y
  self._tx, self._ty = tx, ty
  self._t, self._total = 0, _golds.drop[1]
  self.update = _updateDrawCoinDropping
end

DrawCoin.inst_meta.clean = _goldClean

DrawCoin.inst_meta.touched = function(self, hero)
  local team = hero.team
  if not team then return end
  
  _goldClean(self)
  local ui_func = self.scene.ui_func
  if ui_func then
    _mgr_snd.playEffect('sound/coin1.mp3')
    ui_func.addChance(self.x, self.y - self.scene.distance)
  end
end

_updateDrawCoinDropping = function(self, dt)
  _aniUpdate(self._effect, dt)
  
  local att = self.scene.item_attractor
  if att then
    self.scene.coll:addColl(self, _TYPE_ITEM)
    self._t, self._total = 0, _golds.attract
    self._x, self._y = self.x, self.y
    self.update = _updateDrawCoinAttracting
    return
  end
  
  local drop = _golds.drop
  local t = self._t + dt
  self._t = t
  local r = t/self._total
  local rr = 2*t/self._total - 1
  local h = (_GOLD_DROP_A*rr + _GOLD_DROP_B)*rr + _GOLD_DROP_C
  self.x = self._x*(1-r) + self._tx*r
  self.y = self._y*(1-r) + self._ty*r + h
  if r < 1 then return end
  
  self.scene.coll:addColl(self, _TYPE_ITEM)
  self.update = _updateDrawCoinWaitPick
end

_updateDrawCoinWaitPick = function(self, dt)
  _aniUpdate(self._effect, dt)
  local att = self.scene.item_attractor
  if att then
    self._t, self._total = 0, _golds.attract
    self._x, self._y = self.x, self.y
    self.update = _updateDrawCoinAttracting
  end
end

_updateDrawCoinAttracting = function(self, dt)
  _aniUpdate(self._effect, dt)
  local att = self.scene.item_attractor
  if not att then
    self.update = _updateDrawCoinWaitPick
    return
  end
  
  local t = 0
  local total_inv = 1/_golds.attract

  t = self._t + dt
  local r = t /self._total
  if r>1 then r=1 end
  self.x = self._x*(1-r) + att.x*r
  self.y = self._y*(1-r) + att.y*r
  self._t = t
end


--在x，y附近掉落道具
--item_tbl形式如data.item.prisoner.items 和 data.enemy.enemys内的配置
function createItemsAround(scene, x, y, item_tbl)
  if not scene.can_drop then
    return
  end
  
  local random, floor = math.random, math.floor
  local tbl
  local rand = random()
  for i,it in ipairs(item_tbl) do
    if rand < it.p then
      tbl = it[1]
      break
    end
    rand = rand - it.p
  end

  local l, r = x+_GOLD_RANGE_LEFT, x+_GOLD_RANGE_RIGHT
  local minx, maxx = _GOLD_RANGE_MINX, _GOLD_RANGE_MAXX+scene.width
  if l<minx then l=minx end
  if r>maxx then r=maxx end
  local b, t = y+_GOLD_RANGE_BOTTOM, y+_GOLD_RANGE_TOP
  local w, h = r-l, t-b
    
  if tbl.type == 'golds' then
    local G = Gold
    for i,num in ipairs(tbl) do
      if num > 0 then
        local sdata = _golds[i]
        for j=1,num do
          local px = l + floor(random(w))
          local py = b + floor(random(h))
          G(scene, x, y, px, py, sdata)
        end
      end
    end
  elseif tbl.type == 'draw' then
    local D = DrawCoin
    for i=1,tbl[1] do
      local px = l + floor(random(w))
      local py = b + floor(random(h))
      D(scene, x, y, px, py, _draw_coin)
    end
  end
end

--[[ 俘虏
scene:
sdata: data.hero.heros内的数据
x, y:
node:
coll_left, coll_right, coll_top, coll_bottom:
]]
Prisoner = require('util.class').class(_Animation)

Prisoner.ctor = function(self, scene, hero_id, x, y)
  self.scene = scene
  
  self.__super_ctor__(self, _prisoner.fence)
  self.x, self.y = x, y
  local node = self.ani_sprite
  self.node = node
  scene:addObject(self)
  
  self.sdata = _heros[hero_id]
  self._hero = _Animation(_prisoner.hero, self.sdata.object.animations, node)
  self._word = _Animation(_prisoner.word, nil, node)
    
  local tmp = _prisoner.collision
  self.coll_left = tmp[1]
  self.coll_right = tmp[2]
  self.coll_top = tmp[3]
  self.coll_bottom = tmp[4]
  scene.coll:addColl(self, _TYPE_ITEM)
  
  self:play('imprison')
  self._hero:play('stand')
  self._word:play('imprison')
end


Prisoner.inst_meta.clean = function(self)
  self.scene:removeObject(self)
  self.scene.coll:removeColl(self)
end

Prisoner.inst_meta.update = function(self, dt)
  self._hero:update(dt)
  self._word:update(dt)
end



local function _prisonerReward(self, team)
  local scene = self.scene
    
  self:play('rescue')
  self._hero.ani_sprite:setLocalZOrder(_prisoner.hero.z_rescued)
  self._word:play('rescue')
  
  createItemsAround(scene, self.x, self.y, _prisoner.items)
  
  if scene.mgr_evt then
    scene.mgr_evt.publish('hero.rescued', self.sdata)
  end
end

local function _prisonerJoin(self, team)
  local scene = self.scene
  local h = team:addHero(self.sdata.id, self.x, self.y) 
  scene:removeObject(self)
  _mgr_snd.playEffect(_prisoner.sound_join)
  local ani = _Animation(nil, _prisoner.word.animations, h.node)
  h:addAnimation(ani)
  ani:play('join')
  
  if scene.mgr_evt then
    scene.mgr_evt.publish('hero.rescued', self.sdata)
  end
end

Prisoner.inst_meta.touched = function(self, hero)
  local team = hero.team
  if not team then return end
  
  self.scene.coll:removeColl(self)
  
  team:askHeroJoin(
    self.sdata.id, 
    function(ok)
      if ok then
        _prisonerJoin(self, team)
      else
        _prisonerReward(self, team)
      end
    end
  )
end


--[[
炸弹道具
]]
Bomb = require('util.class').class(_Animation)

local function _bombPos(range, distance)
  local rand = math.random
  return rand(range[1], range[2]), 
        distance + rand(range[3], range[4])
end

Bomb.ctor = function(self, team, power_ratio)
  local scene = team.scene
  local sdata = _data_items.bomb
  
  self.scene = scene
  self.__super_ctor__(self, sdata.object)
  
  self.x, self.y = _bombPos(sdata.range, scene.distance)
  self.z = _const.SCENE_Z_ITEM
  self.node = self.ani_sprite
  scene:addObject(self)
  
  local coll = sdata.collision
  self.coll_left, self.coll_right, self.coll_top, self.coll_bottom
    = coll[1], coll[2], coll[3], coll[4]
  scene.coll:addColl(self, _const.COLL_TYPE_HERO_BULLET)
  
  self.power = sdata.power * power_ratio
  self.cancel_left = sdata.cancel_count
  self.team = team
  self.sdata = sdata
  self._target_attacked = {}
  
  self._left = sdata.times
  self:play('explode')
end

Bomb.inst_meta.clean = function(self)
  --scene的clean不处理
end

Bomb.inst_meta.cleanFromTeam = function(self)
  local scene = self.scene
  scene.coll:removeColl(self)
  scene:removeObject(self)
end

Bomb.inst_meta.isEnd = function(self)
  return self._left <= 0
end

Bomb.inst_meta.cancelled = function(self, c)
end

Bomb.inst_meta.canAttack = function(self, target)
  return not self._target_attacked[target]
end

Bomb.inst_meta.attacked = function(self, target)
  self._target_attacked[target] = true
end

Bomb.inst_meta.reflect = function(self, collx, colly, colltype)
end

Bomb.inst_meta.update = function(self, dt)
  if not _aniUpdate(self, dt) then
    return
  end
  
  local left = self._left - 1
  self._left = left
  if left <= 0 then
    return
  end
  
  local targets = self._target_attacked
  for n, t in pairs(targets) do
    targets[n] = nil
  end
  
  self.x, self.y = _bombPos(self.sdata.range, self.scene.distance)
  self:play('explode')
end


--[[
冲撞道具
]]
Rush = require('util.class').class(_Animation)

--[[
local function _bombPos(range, distance)
  local rand = math.random
  return rand(range[1], range[2]), 
        distance + rand(range[3], range[4])
end
]]

Rush.ctor = function(self, team, x, y)
  local scene = team.scene
  local sdata = _data_items.rush
    
  self.scene = scene
  
  local spf = _sprite_frames[sdata.bg[1]]
  local bg = cc.Sprite:createWithSpriteFrame(spf.frame)
  bg:setAnchorPoint(sdata.bg[2]*spf.width_inv, 1-sdata.bg[3]*spf.height_inv)
  bg:setScale(sdata.bg[4])
  
  self.__super_ctor__(self, sdata.object, nil, bg)
  
  local off = sdata.offset
  self.x, self.y, self.z = x+off[1], y+off[2], 0
  self.node = bg
  scene:addObject(self)
  
  local coll = sdata.collision
  self.coll_left, self.coll_right, self.coll_top, self.coll_bottom
    = coll[1], coll[2], coll[3], coll[4]
  scene.coll:addColl(self, _const.COLL_TYPE_HERO_BULLET)
  
  scene.velocity_desire = sdata.velocity
  
  self.power = sdata.power
  self.cancel_left = sdata.cancel_count
  self.team = team
  self.sdata = sdata
  
  self:play('play')
end

Rush.inst_meta.clean = function(self)
  --scene的clean不处理
end

Rush.inst_meta.cleanFromTeam = function(self)
  local scene = self.scene
  scene.velocity_desire = nil
  scene.coll:removeColl(self)
  scene:removeObject(self)
end

Rush.inst_meta.cancelled = function(self, c)
end

Rush.inst_meta.canAttack = function(self, target)
  return true
end

Rush.inst_meta.attacked = function(self, target)
  --不显示特效
  _mgr_snd.playEffect(self.sdata.hit_sound)
  return true
end

Rush.inst_meta.reflect = function(self, collx, colly, colltype)
end

Rush.inst_meta.updatePosition = function(self, x, y)
  local off = self.sdata.offset
  self.x, self.y = x+off[1], y+off[2]
end

Rush.inst_meta.update = _aniUpdate


