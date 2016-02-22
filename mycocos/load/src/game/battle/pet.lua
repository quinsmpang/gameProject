module('game.battle.pet', package.seeall)

local _Animation = require('game.battle.ani').Animation
local _pets_data = require('data.pets').pets
local _const = require('data.const')
local _player = require('game.player')

Pet = require('util.class').class(_Animation)

local _pets_tbl

Pet.ctor = function(self, scene, id)
  self.scene = scene
  
  local sdata = _pets_data[id]
  self.__super_ctor__(self, sdata.object)
  self.node = self.ani_sprite
  self.x, self.y = 0, 0
  scene:addObject(self)
  
  self:play('walk')
  
  local tbl = _pets_tbl[id]
  self.heroAffect = tbl.affect
  self.heroUnaffect = tbl.unaffect
  self.teamJoin = tbl.join
  self.teamLeave = tbl.leave
  
  local lv = _player.get().pets[id].level
  tbl.buff(self, sdata, lv)
end

Pet.inst_meta.clean = function(self)
  self.scene:removeObject(self)
end

Pet.inst_meta.update = _Animation.inst_meta.update

--[[
应在ctor内设置
Pet.inst_meta.heroAffect
Pet.inst_meta.heroUnaffect
Pet.inst_meta.teamJoin
Pet.inst_meta.teamLeave
]]
_pets_tbl = {
  
  [30001]={
    --无敌道具时间加成，进阶剑士免疫弓箭伤害
    buff=function(self, sdata, lv)
      self._buff = sdata.buff_1st + sdata.buff_level*(lv-1)
    end,
    affect=function(self, hero)
      if hero.sdata.id == 18001 then
        local g, t = hero.guard, _const.HIT_TYPE_ARROW
        g[t] = g[t] + 1
      end
    end,
    unaffect=function(self, hero)
      if hero.sdata.id == 18001 then
        local g, t = hero.guard, _const.HIT_TYPE_ARROW
        g[t] = g[t] - 1
      end
    end,
    join=function(self, team)
      local b = team.bonus
      b.item_invincible_sec = b.item_invincible_sec + self._buff
    end,
    leave=function(self, team)
      local b = team.bonus
      b.item_invincible_sec = b.item_invincible_sec - self._buff
    end,
  },
  
  [30002]={
    --冲刺道具时间加成，进阶弓手可射出5支箭。
    buff=function(self, sdata, lv)
      self._buff = sdata.buff_1st + sdata.buff_level*(lv-1)
    end,
    affect=function(self, hero)
      if hero.sdata.id == 14001 then
        hero.attack_alternate = true
      end
    end,
    unaffect=function(self, hero)
      if hero.sdata.id == 14001 then
        hero.attack_alternate = false
      end
    end,
    join=function(self, team)
      local b = team.bonus
      b.item_rush_sec = b.item_rush_sec + self._buff
    end,
    leave=function(self, team)
      local b = team.bonus
      b.item_rush_sec = b.item_rush_sec - self._buff
    end,
  },
  
  [30003]={
    --炸弹道具的威力加成 进阶法师可以施放两个火球。
    buff=function(self, sdata, lv)
      self._buff = sdata.buff_1st + sdata.buff_level*(lv-1)
    end,
    affect=function(self, hero)
      if hero.sdata.id == 17001 then
        hero.attack_alternate = true
      end
    end,
    unaffect=function(self, hero)
      if hero.sdata.id == 17001 then
        hero.attack_alternate = false
      end
    end,
    join=function(self, team)
      local b = team.bonus
      b.item_bomb_percent = b.item_bomb_percent + self._buff
    end,
    leave=function(self, team)
      local b = team.bonus
      b.item_bomb_percent = b.item_bomb_percent + self._buff
    end,
  },
  
  [30004]={
    --获得金币的量百分比加成，绿巨人的技能间隔时间缩短(百分比?)。
    buff=function(self, sdata, lv)
      local percent = sdata.buff_1st + sdata.buff_level*(lv-1)
      self._buff = percent * 0.01
    end,
    affect=function(self, hero)
      if hero.sdata.id == 19001 then
        local minus_sec = hero.ability.interval * self._buff * _const.ABILITY_INTERVAL_SEC_COEFF
        hero.attack_interval = hero.attack_interval - minus_sec
      end
    end,
    unaffect=function(self, hero)
      if hero.sdata.id == 19001 then
        local minus_sec = hero.ability.interval * self._buff * _const.ABILITY_INTERVAL_SEC_COEFF
        hero.attack_interval = hero.attack_interval + minus_sec
      end
    end,
    join=function(self, team)
      local b = team.bonus
      b.golds_percent = b.golds_percent + self._buff
    end,
    leave=function(self, team)
      local b = team.bonus
      b.golds_percent = b.golds_percent - self._buff
    end,
  },
  
  [30005]={
    --英雄攻击力增加百分比
    buff=function(self, sdata, lv)
      local percent = sdata.buff_1st + sdata.buff_level*(lv-1)
      self._buff = percent * 0.01
    end,
    affect=function(self, hero)
      local add = hero.ability.power * self._buff
      hero.attack_power = hero.attack_power + add
    end,
    unaffect=function(self, hero)
      local add = hero.ability.power * self._buff
      hero.attack_power = hero.attack_power - add
    end,
    join=function(self, team)
    end,
    leave=function(self, team)
    end,
  },
}
