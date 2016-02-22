local _config = require('config')
local _math = math
module('data.stage')

local _HEIGHT = _config.design.height

--出怪点信息
STAGE_SPAWN_X_DIFF = 48
STAGE_SPAWN_Y_UP = _config.design.height + 20
STAGE_SPAWN_COUNT = _math.ceil(_config.design.width / STAGE_SPAWN_X_DIFF) - 1

STAGE_BOSS_ALARM_SEC = 3

--[[
关卡数据，每项含义
{
  index=1, --内部用，本项在表的位置（1开始算）
  velocity=250, --本关速度
  prisoner={ --俘虏配置
    first_distance = 800, --开始防止距离
    first_number = 2, --开始放的个数
    diff_by_number = {}, --根据英雄个数决定下个营救的距离
  },
  thief={ --出盗贼几率配置
    init_percent = 5, --每杀一个敌人出现盗贼的概率
    id=20012, --盗贼id
    hp=xx, acc=xx, --一般不设，默认敌人数据的hp、加速=1
  },
  enemy={
    diff={l,h}, --每次出怪的随机间隔
    number=1, --每次出怪数
    {50, 40, 10}, --每项的百分比概率(加起来应为100)
    {
      {20001,hp=20,acc=0.5,items={...}}, 
      {20002},
      {20003,hp=100},
    }, --对应上一项概率值的怪物数值，分别是{id, hp=可选数字, acc=可选攻击间隔, items=可选掉落道具}
  },
  --杀怪达到30，出boss 20013
  boss={30, {20013,hp=xxx,acc=xxx}},
}
]]
levels={
  --奖励关卡数据
  bonus = {
    velocity=300,
    seconds = 10,
    enemy={
      diff={100, 200},
      number=1,
      {100},
      {
        {20012},
      },
    },
  },

  --各关数据
  {
    index=1,
    velocity=250,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={300,500},
      number=1,
      {50, 50},
      {
        {20000},
        {20001}
      },
    },
    boss={30,
      {
        {20013}
      }
    },
  },
  
  {
    index=2,
    velocity=300,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={150,250},
      number=1,
      {30, 30, 20, 20},
      {
        {20000},
        {20001},
        {20002},
        {20003}
      },
    },
    boss={50,
      {
        {20014}
      }
    },
  },
  
  {
    index=3,
    velocity=320,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={300,500},
      number=2,
      {30, 30, 20, 20},
      {
        {20001},
        {20002},
        {20003},
        {20004}
      },
    },
    boss={70,
      {
        {20015}
      }
    },
  },
  
  {
    index=4,
    velocity=340,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={200,450},
      number=2,
      { 20, 20, 20, 20, 10, 
        10
      },
      { 
        {20001},
        {20002},
        {20003},
        {20004},
        {20005},
        {20006}
      },
    },
    boss={80,
      {
        {20016}
      }
    },
  },
  
  {
    index=5,
    velocity=360,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={150,400},
      number=2,
      { 15, 15, 15, 15, 15, 
        10, 10, 5,
      },
      { 
        {20001},
        {20002},
        {20003},
        {20004},
        {20005},
        {20006},
        {20007},
        {20008}
      },
    },
    boss={90,
      {
        {20017}
      }
    },
  },
  
  {
    index=6,
    velocity=380,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={100,300},
      number=2,
      { 15, 15, 15, 10, 10, 
        10, 10, 5, 5, 5
      },
      {
        {20001},
        {20002},
        {20003},
        {20004},
        {20005},
        {20006},
        {20007},
        {20008},
        {20009},
        {20010}
      },
    },
    boss={100, 
      {
        {20013},
        {20016}
      }
    },
  },
  
  {
    index=7,
    velocity=400,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={100,280},
      number=2,
      { 15, 15, 10, 10, 10,
        10, 10, 5, 5, 5,
        5
      },
      {
        {20001},
        {20002},
        {20003},
        {20004},
        {20005},
        {20006},
        {20007},
        {20008},
        {20009},
        {20010},
        {20011},
      },
    },
    boss={110,
      {
        {20014},
        {20016}
      }
    },
  },
  
  {
    index=8,
    velocity=400,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={100,260},
      number=2,
      { 15, 15, 10, 10, 10,
        10, 10, 5, 5, 5,
        5
      },
      { 
        {20001},
        {20002},
        {20003},
        {20004},
        {20005},
        {20006},
        {20007},
        {20008},
        {20009},
        {20010},
        {20011},
      },
    },
    boss={120, 
      {
        {20015},
        {20016}
      }
    },
  },
  
  {
    index=9,
    velocity=400,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={100,230},
      number=2,
      { 15, 15, 10, 10, 10,
        10, 10, 5, 5, 5,
        5
      },
      { 
        {20001},
        {20002},
        {20003},
        {20004},
        {20005},
        {20006},
        {20007},
        {20008},
        {20009},
        {20010},
        {20011},
      },
    },
    boss={130, 
      {
        {20016},
        {20016}
      }
    },
  },
  
  {
    index=10,
    velocity=400,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 2,
      diff_by_number = {2000, 2000, 3000, 4000, 4000},
    },
    thief={
      init_percent=2,
      id=20012,
    },
    enemy={
      diff={100,200},
      number=2,
      { 15, 15, 10, 10, 10,
        10, 10, 5, 5, 5,
        5
      },
      { 
        {20001},
        {20002},
        {20003},
        {20004},
        {20005},
        {20006},
        {20007},
        {20008},
        {20009},
        {20010},
        {20011},
      },
    },
    boss={140, 
      {
        {20017},
        {20016}
      }
    },
  },
} --levels


--[[
挑战boss数据
{
  index=1, --内部用，本项在表的位置（1开始算）
  velocity=250, --本关速度
  prisoner={ --俘虏配置
    first_distance = 800, --开始防止距离
    first_number = 2, --开始放的个数
    diff_by_number = {}, --根据英雄个数决定下个营救的距离
  },
  --20013, hp为指定值，没指定用配置数据，acc若指定为攻击间隔的加速
  boss={{20013,hp=xxx,acc=xxx}},
}
]]
bosses={
  {
    index=1,
    velocity=250,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 1,
      diff_by_number = {4000, 4000, 6000, 8000, 8000},
    },
    boss={
      {20018, hp=3000, acc=0.9}
    },
  },
  {
    index=2,
    velocity=280,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 1,
      diff_by_number = {4000, 4000, 6000, 8000, 8000},
    },
    boss={
      {20014, hp=4800, acc=0.8}
    },
  },
  {
    index=3,
    velocity=320,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 1,
      diff_by_number = {4000, 4000, 6000, 8000, 8000},
    },
    boss={
      {20015, hp=9000, acc=0.7}
    },
  },
  {
    index=4,
    velocity=350,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 1,
      diff_by_number = {4000, 4000, 6000, 8000, 8000},
    },
    boss={
      {20016, hp=6300, acc=0.6}
    },
  },
  {
    index=1,
    velocity=350,
    prisoner={
      first_distance = _HEIGHT,
      first_number = 1,
      diff_by_number = {4000, 4000, 6000, 8000, 8000},
    },
    boss={
      {20017, hp=16000, acc=0.5}
    },
  },
} --bosses
