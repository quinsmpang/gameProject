module('data.miracle')

--[[
{
levelup_gold_base: 升级费用的基础值，
  从 n-1升到n 级，需用 levelup_gold_base*n
buff_level: 每级的buff值，n级buff=buff_level*n
  具体含义、作用见 game.ui.miracle_panel, game.battle.miracle
}
]]
data={
  {
    id = 1,
    name = "贪婪",
    max_level = 30,
    levelup_gold_base = 300*20,
    buff_level = 1,
  },
  {
    id = 2,
    name = "得分王",
    max_level = 30,
    levelup_gold_base = 300*20,
    buff_level = 1,
  },
  {
    id = 3,
    name = "炸弹超人",
    max_level = 30,
    levelup_gold_base = 300*20,
    buff_level = 1,
  },
  {
    id = 4,
    name = "无敌超人",
    max_level = 30,
    levelup_gold_base = 300*20,
    buff_level = 0.1,
  },
  {
    id = 5,
    name = "冲刺超人",
    max_level = 30,
    levelup_gold_base = 300*20,
    buff_level = 0.1,
  },
  {
    id = 6,
    name = "剑士专精",
    max_level = 30,
    levelup_gold_base = 500*20,
    buff_level = 1,
  },
  {
    id = 7,
    name = "弓手专精",
    max_level = 30,
    levelup_gold_base = 500*20,
    buff_level = 1,
  },
  {
    id = 8,
    name = "法师专精",
    max_level = 30,
    levelup_gold_base = 500*20,
    buff_level = 1,
  },
  {
    id = 9,
    name = "绿巨人专精",
    max_level = 30,
    levelup_gold_base = 500*20,
    buff_level = 1,
  },
  {
    id = 10,
    name = "斧手专精",
    max_level = 30,
    levelup_gold_base = 500*20,
    buff_level = 1,
  },
  {
    id = 11,
    name = "守护者专精",
    max_level = 30,
    levelup_gold_base = 500*20,
    buff_level = 1,
  },
  {
    id = 12,
    name = "蚁人专精",
    max_level = 30,
    levelup_gold_base = 500*20,
    buff_level = 1,
  },
}

