module('game.task', package.seeall)

local _const = require('data.const')
local _task_sdata = require('data.task').tasks
local _task_text = require('data.text').task

local _enemy_sdata = require('data.enemy').enemys

local _player = require('game.player')
local _mgr_evt = require('game.mgr_evt')

local _popupTip = require('game.mgr_scr').popupTip
local _strfmt = string.format


--[[
game.player.data.tasks={
  max_index=0,
  --最多 _const.TASK_MAX 项
  {
    index=任务静态数据位置,
    number=已达成目的数,
  },
}
]]


--战斗过程中的数据
local _curr_tasks = {
  --scene battle.scene.Scene
  --[[
   1..n 
   {
     sdata=任务对应的静态数据
     number=当前完成度，
            战斗前从player_data获得，
            提交时再更新到player
     --各具体任务的内部记录
     evt_name, evt_cb
     --特定任务实现的数据
     _xxx
   }
  ]]
}


---
local function _formatSimple(sdata, prefix)
  local text = _strfmt('%s%s%s',
        prefix or '',
        _task_text.calc[sdata.calc],
        _strfmt(_task_text.target[sdata.target], sdata.number)
      )
  return text
end

local function _formatTargetKill(sdata, prefix)
  local target_text
  local fmt = _task_text.target[sdata.target]
  if sdata.extra then
    local ename = _enemy_sdata[sdata.extra].name
    target_text = _strfmt(fmt[true], sdata.number, ename)
  else
    target_text = _strfmt(fmt[false], sdata.number)
  end
  
  local text = _strfmt('%s%s%s',
        prefix or '',
        _task_text.calc[sdata.calc],
        target_text
      )
  return text
end


local function _stopSimple(task)
  _mgr_evt.unsubscribe(task.evt_name, task.evt_cb)
  task.evt_name, task.evt_cb = nil
end

local function _startSimple(task, evt_name, evt_cb, number)
  _mgr_evt.subscribe(evt_name, evt_cb)
  task.evt_name, task.evt_cb = evt_name, evt_cb
  if number then
    task.number = number
  end
end

local function _getTargetRunEvtFunc(task)
  local coeff = _const.DISTANCE_METER_COEFF
  return function(evt, scene, dt)
    local n = task._origin_number + scene.distance *coeff
    local dist = task.sdata.number
    if n < dist then
      task.number = n
    else
      task.number = dist
      _mgr_evt.unsubscribe(task.evt_name, task.evt_cb)
      _popupTip(
        _formatSimple(task.sdata, _task_text.tip_done_prefix)
      )
      _mgr_evt.publish('task.done')
    end
  end
end

local function _getTargetKillEvtFunc(task)
  return function(evt, enemy, enemy_sdata)
    local sdata = task.sdata
    if not sdata.extra
      or enemy_sdata.id == sdata.extra
    then
      task.number = task.number + 1
      if task.number >= sdata.number then
        _mgr_evt.unsubscribe(task.evt_name, task.evt_cb)
        _popupTip(
          _formatTargetKill(task.sdata, _task_text.tip_done_prefix)
        )
        _mgr_evt.publish('task.done')
      end
    end
  end
end

local function _getTargetRescuedEvtFunc(task)
  return function(evt, hero_sdata)
    task.number = task.number + 1
    if task.number >= task.sdata.number then
      _mgr_evt.unsubscribe(task.evt_name, task.evt_cb)
      _popupTip(
        _formatSimple(task.sdata, _task_text.tip_done_prefix)
      )
      _mgr_evt.publish('task.done')
    end
  end
end
        
--[[
各类任务的处理函数
format(sdata, prefix) 
  任务的文字描述
  sdata: 任务的静态数据
  prefix: [可选]，描述前的文本
  返回描述
start(task) 开始检查触发
stop(task): 停止检查触发
  task: 在_curr_tasks内的某项
]]
local _proc = {
  [_const.TASK_TARGET_RUN] = {
    [_const.TASK_CALC_ONE_BATTLE] = {
      format = _formatSimple,
      stop = _stopSimple,
      start = function(task)
        task._origin_number = 0
        _startSimple(task, 'battle.play_update',
          _getTargetRunEvtFunc(task), 0)
      end,
    },
    [_const.TASK_CALC_ACCUMULATION] = {
      format = _formatSimple,
      stop = _stopSimple,
      start = function(task)
        task._origin_number = task.number
        _startSimple(task, 'battle.play_update',
          _getTargetRunEvtFunc(task) )
      end,
    },
  },--target_run

  [_const.TASK_TARGET_KILL] = {
    [_const.TASK_CALC_ONE_BATTLE] = {
      format = _formatTargetKill,
      stop = _stopSimple,
      start = function(task)
        _startSimple(task, 'enemy.killed',
          _getTargetKillEvtFunc(task), 0)
      end,
    },
    [_const.TASK_CALC_ACCUMULATION] = {
      format = _formatTargetKill,
      stop = _stopSimple,
      start = function(task)
        _startSimple(task, 'enemy.killed',
          _getTargetKillEvtFunc(task) )
      end,
    },
  },--target_kill

  [_const.TASK_TARGET_RESCUE] = {
    [_const.TASK_CALC_ONE_BATTLE] = {
      format = _formatSimple,
      stop = _stopSimple,
      start = function(task)
        _startSimple(task, 'hero.rescued',
          _getTargetRescuedEvtFunc(task), 0)
      end,
    },
    [_const.TASK_CALC_ACCUMULATION] = {
      format = _formatSimple,
      stop = _stopSimple,
      start = function(task)
        _startSimple(task, 'hero.rescued',
          _getTargetRescuedEvtFunc(task) )
      end,
    },
  },--target_rescue
}

-----

local function _setNextTask(tasks, index)
  if tasks.max_index >= #_task_sdata then
    return false
  end
  local nidx = tasks.max_index + 1
  tasks.max_index = nidx
  tasks[index] = {index=nidx, number=0}
  return true
end

local function _compactTasks(tasks)
  local pos = 1
  for i=1, _const.TASK_MAX do
    local t = tasks[i]
    if t then
      tasks[i] = nil
      tasks[pos] = t
      pos = pos + 1
    end
  end
end
    
local function _replaceDoneTasks(tasks)
  local r = 0
  
  for i, t in ipairs(tasks) do
    local sdata = _task_sdata[t.index]
    if t.number >= sdata.number then
      --cclog('task %d done and replacing', sdata.index)
      if not _setNextTask(tasks, i) then
        tasks[i] = nil
      end
      r = r+1
    end
  end
  _compactTasks(tasks)
  
  return r
end

----
local function _evtBattleStart(evt, scene)
  _curr_tasks.scene = scene
  
  local tasks = _player.get().tasks
  for i, t in ipairs(tasks) do
    local sdata = _task_sdata[t.index]
    _curr_tasks[i] = {
      sdata = sdata,
      number = t.number,
    }
  end
  
  for i, t in ipairs(_curr_tasks) do
    local sdata = t.sdata
    _proc[sdata.target][sdata.calc].start(t)
  end
end

local function _evtBattleStop(evt, scene)
  for i, t in ipairs(_curr_tasks) do
    local sdata = t.sdata
    _proc[sdata.target][sdata.calc].stop(t)
  end
  _curr_tasks.scene = nil
end

------
--[[
获取任务信息
返回
{
  {
    desc=任务的描述
    number=目标数量
    todo=剩余数量
    reward=奖励
    is_one_battle=true|false
  },
  ...
}
]]
function getInfo()
  local info = {}
  for i,t in ipairs(_curr_tasks) do
    local sdata = t.sdata
    
    local d = {}
    d.desc = _proc[sdata.target][sdata.calc].format(sdata)
    d.number = sdata.number
    local todo = sdata.number - t.number
    d.todo = (todo>=0 and todo or 0)
    d.reward = sdata.reward
    d.is_one_battle = (sdata.calc == _const.TASK_CALC_ONE_BATTLE)
    
    info[i] = d
  end
  return info
end

--检查任务是否已完成
function isTaskDone(index)
  local t = _curr_tasks[index]
  if not t then
    error('task.isTaskDone: index out of range', 2)
  end
  
  return (t.number >= t.sdata.number)
end

--[[
跳过指定任务
curr_index是当前任务的索引(即1~_const.TASK_MAX)
]]
function skipTask(index)
  local t = _curr_tasks[index]
  if not t then
    error('task.skipTask: index out of range', 2)
  end
  
  --已完成的任务不能跳过(战斗结束后再跳过)
  if t.number >= t.sdata.number then
    error('task.skipTask: cannot skip task which is done')
  end
  
  --
  local sdata = t.sdata
  _proc[sdata.target][sdata.calc].stop(t)
  --加入新任务，或调整原任务位置
  local tasks = _player.get().tasks
  if _setNextTask(tasks, index) then
    local new_task = tasks[index]
    sdata = _task_sdata[new_task.index]
    t.sdata, t.number = sdata, new_task.number
    _proc[sdata.target][sdata.calc].start(t)
  else
    --向上移（最后一个会设为nil）
    for i=index, #tasks do
      local nxt = i+1
      tasks[i] = tasks[nxt]
      _curr_tasks[i] = _curr_tasks[nxt]
    end
  end
  
  _player.setDirty()
end

--
local function _commitToPlayer()
  local tasks = _player.get().tasks
  local dirty
  
  for i, t in ipairs(_curr_tasks) do
    local pt = tasks[i]
    if pt.number ~= t.number then
      pt.number = t.number
      dirty = true
      --cclog('task:%d commit %d', t.sdata.index, t.number)
    end
  end
  
  return dirty
end

--[[
获取本次战斗完成的任务数、及其对应奖励。
更新改动到用户数据。
]]
function getBattleResultAndCommit()
  local done, reward = 0, 0
  for i, t in ipairs(_curr_tasks) do
    local sdata = t.sdata
    if t.number >= sdata.number then
      done = done + 1
      reward = reward + sdata.reward
    end
  end
  if reward > 0 then
    local ud = _player.get()
    ud.golds = ud.golds +reward
    _player:setDirty()
  end
  
  if _commitToPlayer() then
    _replaceDoneTasks(_player.get().tasks)
    _player.setDirty()
  end
  
  for i, t in ipairs(_curr_tasks) do
    _curr_tasks[i] = nil
  end
  return done, reward
end


------------
function init()
  _mgr_evt.subscribe('battle.start', _evtBattleStart)
  _mgr_evt.subscribe('battle.stop', _evtBattleStop)
end

function free()
  _mgr_evt.unsubscribe('battle.start', _evtBattleStart)
  _mgr_evt.unsubscribe('battle.stop', _evtBattleStop)
end


--[[
检查用户数据中tasks的合法性，不合法的去除，不足的补初始值
]]
function check(tasks)
  local dirty = false
  local TASK_MAX = _const.TASK_MAX
  
  if type(tasks) ~= 'table' then
    tasks, dirty = {max_index=0}, true
  end
  --检查索引
  if tasks.max_index<0 or tasks.max_index>#_task_sdata then
    tasks.max_index, dirty = 0, true
  end
  
  --检查数量
  if tasks[TASK_MAX+1] then
    tasks[TASK_MAX+1], dirty = nil, true
  end
  --剔除非法任务和重复任务
  for i=1, TASK_MAX do
    local t = tasks[i]
    if type(t) ~= 'table'
      or type(t.index)~='number' or t.index<1 or t.index>tasks.max_index
      or type(t.number)~='number' or t.number<0 or t.number >= _task_sdata[t.index].number
    then
      tasks[i], dirty = nil, true
    else
      for j=1, i-1 do
        if tasks[j] and tasks[j].index==t.index then
          tasks[i], dirty = nil, true
          break
        end
      end
    end
  end
  if dirty then --此条件可能无剔除也进入，但不影响正确
    _compactTasks(tasks)
  end
  
  --若不足补更多任务
  while #tasks < TASK_MAX do
    if not _setNextTask(tasks, #tasks+1) then
      break
    end
  end
  
  return tasks, dirty
end

