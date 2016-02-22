module('game.battle.miracle', package.seeall)

local _player = require('game.player')
local _miracle_sdata = require('data.miracle').data

local function _get_attack_inc(hero_ids)
  return function(table, lv, sdata)
    local buff = sdata.buff_level * lv * 0.01
    local h = table.heros
    for i,id in ipairs(hero_ids) do
      h[id] = buff + (h[id] or 0)
    end
  end
end

local _miracle_tbl = {
  { --游戏获得金币加成%。
    id=1,
    setup=function(table, lv, sdata)
      local buff = sdata.buff_level * lv *0.01
      table.golds_percent = table.golds_percent + buff
    end,
  },
  { --结算时分数加成%。
    id=2,
    setup=function(table, lv, sdata)
      local buff = sdata.buff_level * lv *0.01
      table.score_percent = table.score_percent + buff
    end,
  },
  { --使用炸弹道具效果持续时间增加x秒。
    id=3,
    setup=function(table, lv, sdata)
      local buff = sdata.buff_level * lv *0.01
      table.item_bomb_percent = table.item_bomb_percent + buff
    end,
  },
  { --使用无敌道具效果持续时间增加x秒。
    id=4,
    setup=function(table, lv, sdata)
      local buff = sdata.buff_level * lv
      table.item_invincible_sec = table.item_invincible_sec + buff
    end,
  },
  { --使用冲刺道具效果持续时间增加x秒。
    id=5,
    setup=function(table, lv, sdata)
      local buff = sdata.buff_level * lv
      table.item_rush_sec = table.item_rush_sec + buff
    end,
  },
  { --使用剑士和进阶剑士攻击力加成x%。
    id=6,
    setup=_get_attack_inc{10001,18001},
  },
  { --使用弓手和进阶弓手攻击力加成x%。
    id=7,
    setup=_get_attack_inc{11001,14001},
  },
  { --使用法师和进阶法师攻击力加成x%。
    id=8,
    setup=_get_attack_inc{12001,17001},
  },
  { --使用博士和绿巨人攻击力加成x%。
    id=9,
    setup=_get_attack_inc{16001,19001},
  },
  { --使用斧手和进阶斧手攻击力加成x%。
    id=10,
    setup=_get_attack_inc{13001,15001},
  },
  { --使用守护者和进阶守护者攻击力加成x%。
    id=11,
    setup=_get_attack_inc{10002,10003},
  },
  { --使用蚁人和进阶蚁人攻击力加成x%。
    id=12,
    setup=_get_attack_inc{10004,10005},
  },
}

function setupBonus(table)
  local pd = _player.get().miracle
  for i, m in ipairs(_miracle_tbl) do
    m.setup(table, pd[i].level, _miracle_sdata[i])
  end
end
