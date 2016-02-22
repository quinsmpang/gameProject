module('game.player', package.seeall)

local _task = require('game.task')

--[==[
单个玩家的数据
{
  golds=number,
  max_score=number,
  max_distance=number,
  is_second_game=boolean, --是否第二次或之后的游戏（不用引导就算是第二次）
  unreal_day = number,--仅仅用于签到测试
  rank_day = number,--仅仅用于排行榜测试
  cur_time = number,--记录当次登录的时间  每次进入游戏只获取一次
  --[[
   level: id:级数，0表示未解锁（不能选择出战,营救弹提示）
          普通、进阶角色的解锁状态是相同的，处理逻辑保证
   unlock: 营救解锁，为false则营救时不自动加入，需付费xxxx
  ]]
  heros_level={id:lv},
  heros_unlock={id:boolean},
  
  --道具计数 name:number
  items={
    bomb=0,
    invincible=1,
    rush=0,
  }
  
  tasks={}, --见task的实现
  guide={}, --见guide_logic的实现

  --每日签到
  sign={
    day ={[1],...[7]},7天是否已领标志
    cur_day,当前连续第几天
    last_time,上一次登录时间(时间戳)
  }

  --排行榜
  rank={
    last_time = number,上一次登录时间(时间戳) 注:与签到时间分开是为了防止共用时间戳出现网络不好的时候刷新签到时间出现领取不了的bug
    first = boolean,-是否第一次登录
    update = boolean,-是否可以刷新
    play = boolean,是否有玩过游戏(领取奖励条件之一)
    refresh = number,是否3次没有刷新记录 为3时候触发
    gift =  领取数据显示
    {
        isget = boolean,-领取奖励状态
        rank_type = number,组别
        number = number,个人排名(基于组别的排名)
        gold = number,奖励金币
        play = boolean,当天是否有玩过游戏
    }
    info = 
    {
        name = string,名字
        rank_type = number,个人组别
        number = number,个人排名(基于组别的排名)
        gold = number,奖励金币
        score = number,分数(每日最高分数 会被刷新)
        group = number,升降
    }
    [rank_type] = 组别(新手组...)
        {
          {单条数据
              number = number,排名,
              gold   = number,奖励金币
              name   = string,名字
              score  = number,分数
              group  = number,升降
          },
          ...
        },
       ...单组数据
  }
  
  --宠物系统
  pets = { 
    [pet_id] = { --宠物id
        debris = number,合成碎片
        level = number,等级, 0表示未合成
    },
    level_debris = number, 宠物升级碎片 所有宠物共用
    cur = number, 当前出场的宠物id，为空未设
    test_debris = number,用于测试碎片
  }
  
  --挑战次数
  pk_num = number

  --奇迹
  miracle = {
    [id] = {
      level = number,等级
    },
    ...
  }

  --是否购买过某种礼包(只购买一次)
  cost_gift = {}
}
]==]
local _FILE = 'data.dat'
local _ENCRYPT = '\x42\x03\x98\xf3\x56\x13\xe4\xcc\xcc\x77\xa9'
local _DATA_KEY = 'data'

local _dirty
local _data = {
}

--检查英雄加入锁、等级
local function _checkHeros(info)
  local dirty
  
  local data_heros = require('data.hero').heros
  --处理营救解锁状况
  if type(info.heros_unlock) ~= 'table' then
    info.heros_unlock, dirty = {}, true
  end
  local unlocks = info.heros_unlock
  for id,h in pairs(data_heros) do
    local ulck = unlocks[id]
    if type(ulck) ~= 'boolean' then
      ulck, dirty = h.unlock, true
      unlocks[id] = ulck
    end
    --自身已解锁，其对应的解锁角色（若存在）也应匹配
    local counter_id = h.unlock_cascade_id
    if counter_id and unlocks[counter_id]~=ulck then
      unlocks[counter_id], dirty = ulck, true
    end
  end
  
  --处理级数
  if type(info.heros_level)~='table' then
    info.heros_level, dirty = {}, true
  end
  local lvs = info.heros_level
  local mmax, mmin = math.max, math.min
  local data_abl = require('data.ability').heros
  for id,h in pairs(data_heros) do
    local lv = lvs[id]
    if type(lv)~='number' then
      lv, dirty = 0, true
    end
    --若已解锁，级数至少为1
    local min = h.min_level
    if unlocks[id] then
      min = mmax(1, min)
    else
      lv = 0
    end
    --对应角色的级数必须一致
    local counter_lv = lvs[h.advance_id or h.primitive_id]
    if counter_lv and type(counter_lv)=='number' then
      min = mmax(min, counter_lv)
    end
    lv = mmax(min, mmin(lv, #data_abl[id]))
    if lv ~= lvs[id] then
      lvs[id], dirty = lv, true
    end
  end
  
  return dirty
end

--TODO: 将items相关的移到其它地方？
local function _checkItems(info)
  local dirty = false
  
  if type(info.items) ~= 'table' then
    info.items, dirty = {}, true
  end
  
  local items = info.items
  if type(items.bomb)~='number' or items.bomb<0 then
    items.bomb, dirty = 0, true
  end
  if type(items.invincible)~='number' or items.invincible<0 then
    items.invincible, dirty = 0, true
  end
  if type(items.rush)~='number' or items.rush<0 then
    items.rush, dirty = 0, true
  end
  
  return dirty
end


local function _checkPets(info)
  local dirty = false
  local pets = info.pets
  if type(pets)~='table' then
    pets = {}
    info.pets, dirty = pets, true
  end
  
  local sdata = require('data.pets').pets
  for id,data in pairs(sdata) do
    local t = pets[id]
    if type(t) ~= 'table' then
      t = {}
      pets[id], dirty = t, true
    end
    if type(t.level)~='number' 
      or t.level < 0 or t.level > sdata[id].max_level 
    then
      t.level, dirty = 0, true
    end
    if type(t.debris)~='number' or t.debris<0 then
      t.debris, dirty = 0, true
    end
  end

  if type(pets.level_debris)~='number' or pets.level_debris<0 then
    pets.level_debris, dirty = 0, true
  end
  if pets.cur ~= nil and 
    (type(pets.cur)~='number' or not sdata[pets.cur]) 
  then
    pets.cur, dirty = nil, true
  end
  
  return dirty
end


local function _check(info)
  local dirty = false
  
  if type(info) ~= 'table' then
    info, dirty = {}, true
  end
  
  if type(info.golds)~='number' or info.golds<0 then
    info.golds, dirty = 0, true
  end
  if type(info.max_distance)~='number' or info.max_distance<0 then
    info.max_distance, dirty = 0, true
  end
  if type(info.max_score)~='number' or info.max_score<0 then
    info.max_score, dirty = 0, true
  end
  if type(info.is_second_game) ~= 'boolean' then
    info.is_second_game, dirty = false, true
  end
  if type(info.rank_day)~='number' then
    info.rank_day, dirty = 0, true
  end
  if type(info.unreal_day)~='number' then
    info.unreal_day, dirty = 0, true
  end
  info.cur_time = nil --每次都初始化一下
  
  if type(info.cost_gift)~='table' then
    info.cost_gift, dirty = {}, true
  end
  

  if type(info.pk_num)~='number' or info.pk_num<0 then
    info.pk_num, dirty = 3, true--默认是3次机会
  end
    
  dirty = _checkPets(info) or dirty
  dirty = _checkHeros(info) or dirty
  dirty = _checkItems(info) or dirty
  
  ----
  local d
  info.tasks, d = _task.check(info.tasks)
  dirty = d or dirty
  info.guide, d = require('game.guide_logic').check(info.guide)
  dirty = d or dirty
  info.sign, d = require('game.ui.sign').check(info.sign)
  dirty = d or dirty
  info.rank, d = require('game.ui.rank.rank_logic').check(info.rank)
  dirty = d or dirty
  info.miracle, d = require('game.ui.miracle').check(info.miracle)
  dirty = d or dirty
     
  return info, dirty
end


function init()
  local wp = cc.FileUtils:getInstance():getWritablePath()
  storage.init(wp .. _FILE, _ENCRYPT)
  
  local ok, info = pcall(storage.get, _DATA_KEY)
  if not ok then
    print(info)
    info = nil
  end
  _data, _dirty = _check(info)
  
  _task.init()
end

function free()
  storage.free()
  _task.free()
  _data = {}
  _dirty = false
end

function get()
  return _data
end

function setDirty()
  _dirty = true
end

function save()
  if _dirty then
    storage.set(_DATA_KEY, _data)
    _dirty = false
  end
end



---for test
--[[
local function _printData(info)
  print('----')
  print('golds:', info.golds)
  print('max_golds:', info.max_golds)
  print('max_distance:', info.max_distance)
  print('max_score:', info.max_score)
  print('heros_level:')
  for id, lv in pairs(info.heros_level) do
    print('  ', id, ':', lv)
  end
end

function test()
  init()
  
  local info = get(1234)
  _printData(info)
  
  info.golds = 150
  info.max_score = 2000
  info.max_distance = 4000
  info.heros_level[10001] = 40
  _dirty = true
  save(1234)
  
  _users[1234] = nil
  info = nil
  info = get(1234)
  _printData(info)
  
  remove(1234, true)
  free()
end

function testStorage()
  local wp = cc.FileUtils:getInstance():getWritablePath()
  print(wp)
  storage.init(wp .. '/wb.dat')
  
  storage.set('abc', 'abcdefg')
  print('get abc:', storage.get('abc'))
  storage.remove('abc')
  print('get abc:', storage.get('abc'))
  
  local t = {
    'n1', 'n2',
    golds=100,
    score=50,
    isok = true,
    nt={[10001]='a', b=20.3}
  }
  storage.set('123', t)
  t = storage.get('123')
  for n,v in pairs(t) do
    if type(v)~='table' then
      print(n, v)
    else
      print(n)
      for nn,vv in pairs(v) do
        print('  ', nn, vv)
      end
    end
  end
  storage.remove('123')
    
  storage.free()
end
]]
