module('data.charge')

--[[
每个基础项至少有
{
  name=xx, --内部约定的支付信息
  rmb=xx, --价格，单位元
}
]]

--复活
revive = {
  name='revive',
  rmb=10,
  tip= "满英雄复活",
}

--解锁
unlock = {
  --[[
  [10001]={
    name='unlock_1',
  },]]
  [10002]={
    name='unlock_6',
    golds=300000,
    tip= "解锁守护者",
    tip_failed='金币不足',
    cost = "花费300000金币即可解锁"
  },
  [10003]={
    name='unlock_6',
    golds=300000,
    tip= "解锁守护者",
    tip_failed='金币不足',
    cost = "花费300000金币即可解锁"
  },
  [10004]={
    name='unlock_7',
    golds=400000,
    tip= "解锁蚁人",
    tip_failed='金币不足',
    cost = "花费400000金币即可解锁"
  },
  [10005]={
    name='unlock_7',
    golds=400000,
    tip= "解锁蚁人",
    tip_failed='金币不足',
    cost = "花费400000金币即可解锁"
  },
  [11001]={
    name='unlock_2',
    rmb=8,
    tip= "解锁弓箭手",
    cost = "花费8元即可解锁"
  },
  [12001]={
    name='unlock_3',
    rmb=8,
    tip= "解锁法师",
    cost = "花费8元即可解锁"
  },
  [13001]={
    name='unlock_5',
    tip= "解锁斧手",
    tip_failed='需达到要求才能解锁',
    cost = "排行榜进入黄金组即可解锁"
  },
  [14001]={
    name='unlock_2',
    rmb=8,
    tip= "解锁弓箭手",
    cost = "花费8元即可解锁"
  },
  [15001]={
    name='unlock_5',
    tip= "解锁斧手",
    tip_failed='需达到要求才能解锁',
    cost = "排行榜进入黄金组即可解锁"
  },
  [16001]={
    name='unlock_4',
    rmb=10,
    tip= "解锁绿巨人",
    cost = "花费10元即可解锁"
  },
  [17001]={
    name='unlock_3',
    rmb=8,
    tip= "解锁法师",
    cost = "花费8元即可解锁"
  },
  [18001]={
    name='unlock_1',
    rmb=8,
    tip= "解锁剑士",
    cost = "花费8元即可解锁"
  },
  [19001]={
    name='unlock_4',
    rmb=10,
    tip= "解锁绿巨人",
    cost = "花费10元即可解锁"
  },
}

--满级
max_level = {
  [10001]={
    name='max_level_1',
    rmb=8,
    tip= "剑士立即满级",
  },
  [10002]={
    name='max_level_6',
    rmb=10,
    tip= "守护者立即满级",
  },
  [10004]={
    name='max_level_7',
    rmb=10,
    tip='蚁人立即满级',
  },
  [11001]={
    name='max_level_2',
    rmb=8,
    tip= "弓箭手立即满级",
  },
  [12001]={
    name='max_level_3',
    rmb=8,
    tip= "法师立即满级",
  },
  [13001]={
    name='max_level_5',
    rmb=10,
    tip= "斧手立即满级",
  },
  [16001]={
    name='max_level_4',
    rmb=10,
    tip= "绿巨人立即满级",
  },
}

--登录礼包
login_bag = {
  name = 'login_bag',
  rmb = 10,
  golds = 40000,
  items = {
    bomb = 3,
    invincible = 3,
  },
  tip= "登录礼包花费",
}

--新手礼包
newbie_bag = {
  name = 'newbie_bag',
  rmb = 10,
  golds = 40000,
  items = {
    invincible = 3,
    rush = 3,
  },
  tip= "新手礼包花费",
}

--道具礼包
item_bag = {
  name = 'item_bag',
  rmb = 10,
  items = {
    bomb = 4,
    invincible = 4,
    rush = 4,
  },
  tip= "道具礼包花费",
}

--豪华礼包
luxury_bag = {
  name = 'luxury_bag',
  rmb = 10,
  golds = 100000,
  items = {
    bomb = 2,
    invincible = 2,
    rush = 2,
  },
  tip= "豪华礼包花费",
}

--金币礼包
gold_bag = {
  name = 'gold_bag',
  rmb = 10,
  golds = 200000,
  tip= {
    tip_1="购买",
    tip_2="金币",
  },
}

--挑战礼包
challenge_bag = {
  name = 'challenge_bag',
  rmb = 10,
  pk_num = 3,
  tip= "挑战礼包花费",
}

--感恩礼包
thank_bag = {
  name = 'thank_bag',
  rmb = 0.1,
  tip= "感恩礼包花费",
}

--补签
resign = {
  name = 'resign',
  sign = {
    {level = 1,rmb = 5},
    {level = 2,rmb = 10}
  }
}

