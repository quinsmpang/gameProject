module('game.battle.coll', package.seeall)

local assert = assert
local _const = require('data.const')
local _TYPE_HERO = _const.COLL_TYPE_HERO
local _TYPE_HERO_BULLET = _const.COLL_TYPE_HERO_BULLET
local _TYPE_ENEMY = _const.COLL_TYPE_ENEMY
local _TYPE_ENEMY_BULLET = _const.COLL_TYPE_ENEMY_BULLET
local _TYPE_ITEM = _const.COLL_TYPE_ITEM

--[[
负责碰撞分类、检测
碰撞矩形为 AABB。

所加入coll的需求：
有数据成员
  x, y: 当前位置
  coll_left, coll_right: 碰撞左、右边相对于 x 的偏移，left<right
  coll_top, coll_bottom: 碰撞上、下边相对 y 的偏移, bottom<top
  操作过程中，会附加_coll_xxx 数据:
   _coll_type: 类型
   _coll_valid: 是否有效
   _coll_index: 所在类型数组的index
   
]]
Collision = require('util.class').class()

Collision.ctor = function(self, scene)
  self.scene = scene

  self.type2colls = {
    [_TYPE_HERO] = {};
    [_TYPE_HERO_BULLET] = {};
    [_TYPE_ENEMY] = {};
    [_TYPE_ENEMY_BULLET] = {};
    [_TYPE_ITEM] = {};
  }
  --coll:flag 0表示新增，<0表示移走，>0表示移走又以另一类型加入
  self._coll_tmp = {}
end

Collision.inst_meta.addColl = function(self, coll, type)
  assert(type>=_TYPE_HERO and type<=_TYPE_ITEM, 'Collision:addColl-type invalid')
  local tmp = self._coll_tmp
  if coll._coll_type ~= nil then
    if coll._coll_valid or tmp[coll]>=0 then
      assert(coll._coll_type==nil, 'Collision:addColl-coll is already added')
    end
    --移走但未处理又添加
    tmp[coll] = type
  else
    coll._coll_type = type
    tmp[coll] = 0
  end
end

Collision.inst_meta.removeColl = function(self, coll)
  --未加入
  if not coll._coll_type then return end
  --加到 _coll_tmp但未处理
  if not coll._coll_index then
    coll._coll_type = nil
    self._coll_tmp[coll] = nil
    return
  end
  
  coll._coll_valid = false
  self._coll_tmp[coll] = -1
end

local function _mergePending(self)
  local type2colls = self.type2colls
  local tmp = self._coll_tmp
  for coll,flag in pairs(tmp) do
    local colls = type2colls[coll._coll_type]
    if flag == 0 then
      local n = #colls + 1
      colls[n] = coll
      coll._coll_index = n
      coll._coll_valid = true
    else --移走或重新加入
      --将最后的coll搬到要移走的位置
      local idx, n = coll._coll_index, #colls
      local back = colls[n]
      colls[idx] = back
      back._coll_index = idx
      colls[n] = nil
      coll._coll_type, coll._coll_index, coll._coll_valid = nil
      --移到新类型
      if flag > 0 then
        colls = type2colls[flag]
        local n = #colls + 1
        colls[n] = coll
        coll._coll_type = flag
        coll._coll_index = n
        coll._coll_valid = true
      end
    end
    tmp[coll] = nil
  end
end

--碰撞发生的处理函数
--暂放在这里紧凑些，有好的结构再改进
local _collHeroBulletEnemy
local _collHeroBulletEnemyBullet
local _collHeroItem
local _collHeroEnemy
local _collHeroEnemyBullet
  
local _mmax=math.max
local _mmin=math.min
local function _checkOnePair(self, type1, type2, proc)
  local x1, y1, l1,r1,t1,b1
  local x2, y2, l2,r2,t2,b2
  for i1, c1 in ipairs(self.type2colls[type1]) do
    if c1._coll_valid then
      for i2, c2 in ipairs(self.type2colls[type2]) do
        if c2._coll_valid then
          y1, y2 = c1.y, c2.y
          t1, b1 = y1+c1.coll_top, y1+c1.coll_bottom
          t2, b2 = y2+c2.coll_top, y2+c2.coll_bottom
          if b1<t2 and b2<t1 then
            x1, x2 = c1.x, c2.x
            l1, r1 = x1+c1.coll_left, x1+c1.coll_right
            l2, r2 = x2+c2.coll_left, x2+c2.coll_right
            if l1<r2 and l2<r1 then
              local x = (_mmax(l1,l2) + _mmin(r1,r2)) * 0.5
              local y = (_mmax(b1,b2) + _mmin(t1,t2)) * 0.5
              proc(self, c1, c2, x, y)
              if not c1._coll_valid then
                break
              end
            end
          end
        end --if c2 valid
      end --for type2
    end --if c1 valid
  end--for type1
end

Collision.inst_meta.mergePending = _mergePending

--碰撞检测
Collision.inst_meta.check = function(self)
  if next(self._coll_tmp) then
    _mergePending(self)
  end
  --按特定顺序判断
  _checkOnePair(self, _TYPE_HERO_BULLET, _TYPE_ENEMY, _collHeroBulletEnemy)
  _checkOnePair(self, _TYPE_HERO_BULLET, _TYPE_ENEMY_BULLET, _collHeroBulletEnemyBullet)
  _checkOnePair(self, _TYPE_HERO, _TYPE_ITEM, _collHeroItem)
  _checkOnePair(self, _TYPE_HERO, _TYPE_ENEMY, _collHeroEnemy)
  _checkOnePair(self, _TYPE_HERO, _TYPE_ENEMY_BULLET, _collHeroEnemyBullet)
end

--各类碰撞处理

local _cancelled = require('data.effect').cancelled
local _hit = require('data.effect').hit
local _effect = require('game.battle.effect')

--飞行物属性相消关系
local _BREL_PASS = 0
local _BREL_LESS = 1
local _BREL_EQUAL = 2
local _BREL_GREATER = 3

local _CANCEL_TYPE_REL = {
  [_const.CANCEL_TYPE_SWORD] = {
    [_const.CANCEL_TYPE_SWORD] = _BREL_EQUAL,
    [_const.CANCEL_TYPE_ARROW] = _BREL_EQUAL,
    [_const.CANCEL_TYPE_MAGIC] = _BREL_PASS,
    [_const.CANCEL_TYPE_NONE] = _BREL_PASS,
    [_const.CANCEL_TYPE_ALL] = _BREL_LESS,
  },
  [_const.CANCEL_TYPE_ARROW] = {
    [_const.CANCEL_TYPE_SWORD] = _BREL_EQUAL,
    [_const.CANCEL_TYPE_ARROW] = _BREL_EQUAL,
    [_const.CANCEL_TYPE_MAGIC] = _BREL_LESS,
    [_const.CANCEL_TYPE_NONE] = _BREL_PASS,
    [_const.CANCEL_TYPE_ALL] = _BREL_LESS,
  },
  [_const.CANCEL_TYPE_MAGIC] = {
    [_const.CANCEL_TYPE_SWORD] = _BREL_PASS,
    [_const.CANCEL_TYPE_ARROW] = _BREL_GREATER,
    [_const.CANCEL_TYPE_MAGIC] = _BREL_EQUAL,
    [_const.CANCEL_TYPE_NONE] = _BREL_PASS,
    [_const.CANCEL_TYPE_ALL] = _BREL_LESS,
  },
  [_const.CANCEL_TYPE_NONE] = {
    [_const.CANCEL_TYPE_SWORD] = _BREL_PASS,
    [_const.CANCEL_TYPE_ARROW] = _BREL_PASS,
    [_const.CANCEL_TYPE_MAGIC] = _BREL_PASS,
    [_const.CANCEL_TYPE_NONE] = _BREL_PASS,
    [_const.CANCEL_TYPE_ALL] = _BREL_PASS,
  },
  [_const.CANCEL_TYPE_ALL] = {
    [_const.CANCEL_TYPE_SWORD] = _BREL_GREATER,
    [_const.CANCEL_TYPE_ARROW] = _BREL_GREATER,
    [_const.CANCEL_TYPE_MAGIC] = _BREL_GREATER,
    [_const.CANCEL_TYPE_NONE] = _BREL_PASS,
    [_const.CANCEL_TYPE_ALL] = _BREL_PASS,
  },
}

_collHeroBulletEnemyBullet = function(self, hbullet, ebullet, collx, colly)
  local htype, etype = hbullet.sdata.cancel_type, ebullet.sdata.cancel_type
  local rel = _CANCEL_TYPE_REL[htype][etype]
  if rel == _BREL_PASS then
    return
  elseif rel == _BREL_LESS then
    hbullet:clean()
    _effect.Effect(self.scene, collx, colly, nil, _cancelled[htype])
  elseif rel == _BREL_GREATER then
    ebullet:clean()
    _effect.Effect(self.scene, collx, colly, nil, _cancelled[etype])
  else
    local hleft, eleft = hbullet.cancel_left, ebullet.cancel_left
    local c = (hleft<=eleft and hleft or eleft)
    hbullet:cancelled(c)
    ebullet:cancelled(c)
    _effect.Effect(self.scene, collx, colly, nil, _cancelled[htype])
  end
end

_collHeroItem = function(self, hero, item)
  item:touched(hero)
end

local _KNOCK_BACK = _const.KNOCK_BACK
local _KNOCK_DEAD = _const.KNOCK_DEAD

_collHeroEnemy = function(self, hero, enemy, collx, colly)
  local ktype = enemy.knock_type
  if ktype==_KNOCK_BACK then
    enemy:knockBack(hero.sdata.knock_back)
  elseif hero.invincible_count == 0 then
    local scene = self.scene
    local eff = _effect.Effect(self.scene, collx, colly, nil, _hit.knock_dead)
    hero:dead()
    if hero.team then
      hero.team:removeHero(hero)
    end
  end
end

_collHeroBulletEnemy = function(self, hbullet, enemy, collx, colly)
  if hbullet:canAttack(enemy) then
    local htype = hbullet.sdata.hit_type
    local guard = enemy.sdata.guard
    if guard and guard[htype] then
      _effect.Effect(self.scene, collx, colly, nil, _hit.guard)
      hbullet:attacked(enemy)
    elseif enemy.bullet_reflect 
      and hbullet:reflect(collx, colly, _const.COLL_TYPE_ENEMY_BULLET)
    then
      _effect.Effect(self.scene, collx, colly, nil, _hit.reflect)
    else
      if not hbullet:attacked(enemy, collx, colly) then
        _effect.Effect(self.scene, collx, colly, nil, _hit[htype])
      end
      enemy:hurt(hbullet.power, hbullet.team, hbullet.sdata)
    end
  end
end

_collHeroEnemyBullet = function(self, hero, ebullet, collx, colly)
  local has_effect = ebullet:attacked(hero, collx, colly)
  local etype = ebullet.sdata.hit_type
  if hero.guard[etype] > 0 then
    _effect.Effect(self.scene, collx, colly, nil, _hit.guard)
  elseif hero.invincible_count <= 0 then
    local scene = self.scene
    if not has_effect then
      local eff = _effect.Effect(self.scene, collx, colly, nil, _hit[etype])
    end
    hero:dead()
    if hero.team then
      hero.team:removeHero(hero)
    end
  end
end
