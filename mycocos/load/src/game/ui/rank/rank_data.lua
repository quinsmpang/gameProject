module('game.ui.rank.rank_data', package.seeall)

NOVICE    = 1 --新手组
BRONZE    = 2 --青铜组
SILVER    = 3 --白银组
GOLD      = 4 --黄金组
PLATINUM  = 5 --白金组
DIAMOND   = 6 --钻石组

GROUP_UP   = 1  --升组
GROUP_DOWN = -1 --降组
GROUP_FLAT = 0  --平

GIFT_NO    = 0  --不可领取
GIFT_GET   = 1  --可领取
GIFT_OK    = 2  --已领取

REFRESH    = 3 --N次没刷新记录提示鼓励界面

--排名规则(给机器人定制的规则)
--[[
注意:
最小分数和最大分数只是给机器人配置的数据 并不会影响玩家最大分数
也不会因此而跳组攀升  玩家数据直接跟机器人做比较而排名
]]
ruler = 
{--            最小排名        最大排名        奖励金币         升降组                最小分数           最大分数
  --新手组
  [NOVICE] = 
          {
            {rank_min = 1,   rank_max = 1,   gold = 9000,    group = GROUP_UP,   score_min = 2501,   score_max = 3000},
            {rank_min = 2,   rank_max = 2,   gold = 8000,    group = GROUP_UP,   score_min = 2001,   score_max = 2500},
            {rank_min = 3,   rank_max = 3,   gold = 6000,    group = GROUP_UP,   score_min = 1501,   score_max = 2000},
            {rank_min = 4,   rank_max = 5,   gold = 5000,    group = GROUP_UP,   score_min = 1001,   score_max = 1500},
            {rank_min = 6,   rank_max = 10,  gold = 4000,    group = GROUP_UP,   score_min = 601,    score_max = 1000},
            {rank_min = 11,  rank_max = 20,  gold = 3000,    group = GROUP_UP,   score_min = 301,    score_max = 600},
            {rank_min = 21,  rank_max = 30,  gold = 1000,    group = GROUP_UP,   score_min = 101,    score_max = 300},
            {rank_min = 31,  rank_max = 50,  gold = 1000,    group = GROUP_FLAT, score_min = 0,      score_max = 100}
          },
   --青铜组
   [BRONZE] = 
          {
            {rank_min = 1,   rank_max = 1,   gold = 13000,    group = GROUP_UP,   score_min = 13001,   score_max = 16000},
            {rank_min = 2,   rank_max = 2,   gold = 10000,    group = GROUP_UP,   score_min = 11001,   score_max = 13000},
            {rank_min = 3,   rank_max = 3,   gold = 9000,     group = GROUP_UP,   score_min = 9001,    score_max = 11000},
            {rank_min = 4,   rank_max = 5,   gold = 8000,     group = GROUP_UP,   score_min = 7001,    score_max = 8000},
            {rank_min = 6,   rank_max = 10,  gold = 6000,     group = GROUP_UP,   score_min = 6001,    score_max = 7000},
            {rank_min = 11,  rank_max = 20,  gold = 5000,     group = GROUP_UP,   score_min = 5001,    score_max = 6000},
            {rank_min = 21,  rank_max = 30,  gold = 4000,     group = GROUP_FLAT, score_min = 4001,    score_max = 5000},
            {rank_min = 31,  rank_max = 50,  gold = 3000,     group = GROUP_FLAT, score_min = 3001,    score_max = 4000}
          },
   --白银组
   [SILVER] = 
          {
            {rank_min = 1,   rank_max = 1,   gold = 19000,    group = GROUP_UP,   score_min = 30001,    score_max = 32000},
            {rank_min = 2,   rank_max = 2,   gold = 15000,    group = GROUP_UP,   score_min = 28001,    score_max = 30000},
            {rank_min = 3,   rank_max = 3,   gold = 13000,    group = GROUP_UP,   score_min = 26001,    score_max = 28000},
            {rank_min = 4,   rank_max = 5,   gold = 10000,    group = GROUP_UP,   score_min = 24001,    score_max = 26000},
            {rank_min = 6,   rank_max = 10,  gold = 9000,     group = GROUP_UP,   score_min = 22001,    score_max = 24000},
            {rank_min = 11,  rank_max = 20,  gold = 8000,     group = GROUP_UP,   score_min = 20001,    score_max = 22000},
            {rank_min = 21,  rank_max = 30,  gold = 6000,     group = GROUP_FLAT, score_min = 18001,    score_max = 20000},
            {rank_min = 31,  rank_max= 50,   gold = 5000,     group = GROUP_DOWN, score_min = 16001,    score_max = 18000}
          },
   --黄金组
   [GOLD] = 
          {
            {rank_min = 1,   rank_max = 1,   gold = 25000,    group = GROUP_UP,   score_min = 39001,   score_max = 40000},
            {rank_min = 2,   rank_max = 2,   gold = 23000,    group = GROUP_UP,   score_min = 38001,   score_max = 39000},
            {rank_min = 3,   rank_max = 3,   gold = 19000,    group = GROUP_UP,   score_min = 37001,   score_max = 38000},
            {rank_min = 4,   rank_max = 5,   gold = 15000,    group = GROUP_UP,   score_min = 36001,   score_max = 37000},
            {rank_min = 6,   rank_max = 10,  gold = 13000,    group = GROUP_UP,   score_min = 35001,   score_max = 36000},
            {rank_min = 11,  rank_max = 20,  gold = 10000,    group = GROUP_UP,   score_min = 34001,   score_max = 35000},
            {rank_min = 21,  rank_max = 30,  gold = 9000,     group = GROUP_FLAT, score_min = 33001,   score_max = 34000},
            {rank_min = 31,  rank_max= 50,   gold = 8000,     group = GROUP_DOWN, score_min = 32001,   score_max = 33000}
          },
   --白金组
   [PLATINUM] = 
          {
            {rank_min = 1,   rank_max = 1,   gold = 31000,    group = GROUP_UP,   score_min = 47001,   score_max = 48000},
            {rank_min = 2,   rank_max = 2,   gold = 28000,    group = GROUP_UP,   score_min = 46001,   score_max = 47000},
            {rank_min = 3,   rank_max = 3,   gold = 25000,    group = GROUP_UP,   score_min = 45001,   score_max = 46000},
            {rank_min = 4,   rank_max = 5,   gold = 23000,    group = GROUP_UP,   score_min = 44001,   score_max = 45000},
            {rank_min = 6,   rank_max = 10,  gold = 19000,    group = GROUP_UP,   score_min = 43001,   score_max = 44000},
            {rank_min = 11,  rank_max = 20,  gold = 15000,    group = GROUP_FLAT, score_min = 42001,   score_max = 43000},
            {rank_min = 21,  rank_max = 30,  gold = 13000,    group = GROUP_FLAT, score_min = 41001,   score_max = 42000},
            {rank_min = 31,  rank_max= 50,   gold = 10000,    group = GROUP_DOWN, score_min = 40001,   score_max = 41000}
          },
   --钻石组
   [DIAMOND] = 
          {
            {rank_min = 1,   rank_max = 1,   gold = 38000,    group = GROUP_FLAT,   score_min = 55001,   score_max = 56000},
            {rank_min = 2,   rank_max = 2,   gold = 35000,    group = GROUP_FLAT,   score_min = 54001,   score_max = 55000},
            {rank_min = 3,   rank_max = 3,   gold = 31000,    group = GROUP_FLAT,   score_min = 53001,   score_max = 54000},
            {rank_min = 4,   rank_max = 5,   gold = 28000,    group = GROUP_FLAT,   score_min = 52001,   score_max = 53000},
            {rank_min = 6,   rank_max = 10,  gold = 25000,    group = GROUP_FLAT,   score_min = 51001,   score_max = 52000},
            {rank_min = 11,  rank_max = 20,  gold = 23000,    group = GROUP_FLAT,   score_min = 50001,   score_max = 51000},
            {rank_min = 21,  rank_max = 30,  gold = 19000,    group = GROUP_FLAT,   score_min = 49001,   score_max = 50000},
            {rank_min = 31,  rank_max= 50,   gold = 15000,    group = GROUP_DOWN,   score_min = 48001,   score_max = 49000}
          }
}
icon =
{
    [NOVICE]   = {path = "ui/rank/icon_novice.png",  name = "新手组"},
    [BRONZE]   = {path = "ui/rank/icon_bronze.png",  name = "青铜组"},
    [SILVER]   = {path = "ui/rank/icon_silver.png",  name = "白银组"},
    [GOLD]     = {path = "ui/rank/icon_gold.png",    name = "黄金组"},
    [PLATINUM] = {path = "ui/rank/icon_platinum.png",name = "白金组"},
    [DIAMOND]  = {path = "ui/rank/icon_diamond.png", name = "钻石组"}
}


