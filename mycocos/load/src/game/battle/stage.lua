module('game.battle.stage', package.seeall)

local _stage = require('data.stage')
local _Enemy = require('game.battle.enemy').Enemy
local _item = require('game.battle.item')
local _enemys_data = require('data.enemy').enemys

local _mgr_evt = require('game.mgr_evt')
local _mgr_snd = require('game.mgr_snd')
local _mrandom = math.random

local _const = require('data.const')
local _player = require('game.player')
local _design = require('config').design
local _effect = require('game.battle.effect')
local _effects_data = require('data.effect')

--出怪点间隔，位置
local _SPAWN_X_DIFF = _stage.STAGE_SPAWN_X_DIFF
local _SPAWN_Y_UP = _stage.STAGE_SPAWN_Y_UP
local _SPAWN_COUNT = _stage.STAGE_SPAWN_COUNT

--boss警告时间
local _BOSS_ALARM_SEC = _stage.STAGE_BOSS_ALARM_SEC

local _BONUS_LIGHT_R = 0.1*30/_design.fps

local _levels_data = _stage.levels
local _bosses_data = _stage.bosses

--初次游戏时只允许救的英雄id
local _first_game_ids = {10001}
--全部英雄id
local _hero_ids = {}
for id,h in pairs(require('data.hero').heros) do
  _hero_ids[#_hero_ids +1] = id
end



--检查是否已结束
local function _checkEnd(self)
  local scene = self.scene
  for team,_ in pairs(scene.teams) do
    if #team.heros==0 
      and team.heros_potential<=0 
    then
      scene:removeTeam(team)
      scene.ui_func.onDead(team)
    end
  end
  if not next(scene.teams) then
    --应是优先级最低的，不必考虑其它
    self.scene:postChecker(
      _const.CHECKER_PRIO_STAGE,
      function()
        self.scene:gotoFinished()
      end)
    return true
  end
end

local function _checkPrisoner(self)
  local scene = self.scene
  local dist = scene.distance
  if dist >= self._prisoner_next_distance then
    _item.Prisoner(scene,
        _hero_ids[_mrandom(#_hero_ids)],
        _mrandom(_SPAWN_COUNT)*_SPAWN_X_DIFF, 
        dist + _SPAWN_Y_UP)
    self._prisoner_next_distance = dist + self._prisoner_diff
  end
end

local function _checkEnemy(self)
  local scene = self.scene
  local dist = scene.distance
  local enemy = self.sdata.enemy
  
  if dist >= self._enemy_next_distance then
    local ratio = self._enemy_hp_ratio
    local percents = enemy[1]
    for i=1, enemy.number do
      local v = _mrandom(100)
      local e
      for i,p in ipairs(percents) do
        if v <= p then
          e = enemy[2][i]
          break
        end
        v = v - p
      end
      
      local eid = e[1]
      local ehp = e.hp or _enemys_data[eid].hp
      if ratio then
        ehp = ehp * ratio
      end
      _Enemy(scene, eid,
          _mrandom(_SPAWN_COUNT) * _SPAWN_X_DIFF,
          dist + _SPAWN_Y_UP,
          ehp, e.acc, e.items)
    end
    --更新下次距离
    local diff = enemy.diff
    self._enemy_next_distance = dist + _mrandom(diff[1], diff[2])
  end
end

local function _getEvtTeam(self)
  return function(evt)
    local prisoner = self.sdata.prisoner
    --选人数最小队伍计算
    local min = #prisoner.diff_by_number
    for team,_ in pairs(self.scene.teams) do
      local n = #(team.heros)
      if n<min then min=n end
    end
    if min<=0 then return end
    local diff = prisoner.diff_by_number[min]
    self._prisoner_diff = diff
    --新距离与现有距离，选较小者
    local next_dist = self.scene.distance + diff
    if self._prisoner_next_distance > next_dist then
      self._prisoner_next_distance = next_dist
    end
  end
end

--[[
负责设置普通关卡的敌人、boss、俘虏等信息
]]
Stage = require('util.class').class()


Stage.ctor = function(self, scene)
  self.scene = scene
  
  --本关速度
  self.velocity = 0
  
  --当前打到的关卡，记录用
  self.level = 0
  --当前关，若为奖励关则为nil
  self.curr_level = 0
  --本关配置数据
  --self.sdata = _levels_data[i]
  --self.update = nil
  --self._t = 0
  
  --敌人hp加成
  --self._enemy_hp_ratio = 1
  --boss剩余数
  --self._boss_left
  --self._bosses
  
  --本关允许弹框的英雄，若为nil则全部允许
  --self._allow_ids
  --下个俘虏出现需走距离
  --self._prisoner_next_distance
  --当前diff项
  --self._prisoner_diff
  --下个敌人出现需走距离
  --self._enemy_next_distance
  --当前杀敌数
  --self._enemy_killed
  
  --事件监听
  --self._evt_team
  --self._evt_enemy
end

local _normalClean

local _normalLevelBegin
local _normalUpdatePreLevel
local _normalLevelSetup
local _normalUpdateLevel
local _normalUpdatePreBoss
local _normalUpdateBoss
local _normalLevelEnd
local _normalUpdatePostLevel

local _normalGetEvtEnemy
local _normalGetEvtEnemyInBoss

local _normalBonusBegin
local _normalUpdatePreBonus
local _normalBonusSetup
local _normalUpdateBonus
local _normalBonusEnd
local _normalUpdatePostBonus

Stage.inst_meta.getLevel = function(self)
  return self.level
end

Stage.inst_meta.allowJoin = function(self, hero_id)
  local allow = self._allow_ids
  return not allow or allow[hero_id]
end

--默认无操作，触发各项条件时，设置相应函数
Stage.inst_meta.update = function(self)
end

Stage.inst_meta.start = function(self)
  self.level = 0
  self.curr_level = 0
  _normalLevelBegin(self)
end

Stage.inst_meta.stop = function(self)
  _normalClean(self)
  self.level = 0
  self.curr_level = 0
  self.velocity = 0
end


_normalClean = function(self)
  self.update = nil
  self.sdata = nil
  self._t = nil
  self._enemy_hp_ratio = nil
  
  if self.curr_level then
    if self._evt_team then
      _mgr_evt.unsubscribe('team.hero_changed', self._evt_team)
      _mgr_evt.unsubscribe('team.changed', self._evt_team)
      self._evt_team = nil
    end
    if self._evt_enemy then
      _mgr_evt.unsubscribe('enemy.killed', self._evt_enemy)
      self._evt_enemy = nil
    end
  else
    self._eff_vortex = nil
    self._t_switch = nil
  end
end


_normalLevelBegin = function(self)
  self.level = self.level + 1
  self.curr_level = self.level
  
  self.velocity = _const.VELOCITY_INBETWEEN
  
  self.scene.ui_func.showLevel(self.level)
  self._t = 4
  self.update = _normalUpdatePreLevel
end

_normalUpdatePreLevel = function(self, dt)
  self._t = self._t - dt
  if self._t > 0 then
    return
  end
  
  self._t = nil
  self.scene.ui_func.hideLevel()
  _normalLevelSetup(self)
  for team,_ in pairs(self.scene.teams) do
    team:stageStart()
  end
end

_normalLevelEnd = function(self)
  _normalClean(self)
  for team,_ in pairs(self.scene.teams) do
    team:stageEnd()
  end
  
  self.velocity = _const.VELOCITY_INBETWEEN
  self._t = 4
  self.update = _normalUpdatePostLevel
end

_normalUpdatePostLevel = function(self, dt)
  self._t = self._t - dt
  if self._t > 0 then
    return
  end
  
  self._t = nil
  _normalBonusBegin(self)
end

_normalBonusBegin = function(self)
  self.curr_level = nil
  self.velocity = _const.VELOCITY_INBETWEEN
  
  local scene = self.scene
  scene.ui_func.showLevel()
  --进入奖励关
  self._eff_vortex = _effect.Effect(scene, 
    _design.width*0.5, scene.distance+_design.height*0.5, 0,
    _effects_data.vortex_in)
   
  self.scene.bg:save()
  self.scene.bg:fadeOut(1)
  self._t = 3
  self._t_switch = 1
  self.update = _normalUpdatePreBonus
end

_normalUpdatePreBonus = function(self, dt)
  local scene = self.scene
  self._t = self._t - dt
  if self._t > 0 then
    self._eff_vortex.x = _design.width*0.5
    self._eff_vortex.y = scene.distance + _design.height*0.5
    if self._t_switch then
      self._t_switch = self._t_switch - dt
      if self._t_switch <= 0 then
        self._t_switch = nil
        scene.bg:switch('bonus')
        scene.bg:fadeIn(1)
      end
    end
    return
  end
  
  self._t = nil
  scene.ui_func.hideLevel()
  _normalBonusSetup(self)
  for team,_ in pairs(scene.teams) do
    team:stageStart()
  end
end

_normalBonusEnd = function(self)
  _normalClean(self)
  for team,_ in pairs(self.scene.teams) do
    team:stageEnd()
  end
  
  self.velocity = _const.VELOCITY_INBETWEEN
  
  --奖励关卡切到下一正常关
  local scene = self.scene
  self._eff_vortex = _effect.Effect(scene,
    _design.width*0.5, scene.distance+_design.height*0.5, 0,
    _effects_data.vortex_out)
  
  scene.bg:fadeOut(1)
  self._t = 3
  self._t_switch = 1
  self.update = _normalUpdatePostBonus
end

_normalUpdatePostBonus = function(self, dt)
  self._t = self._t - dt
  if self._t > 0 then
    local scene = self.scene
    self._eff_vortex.x = _design.width*0.5
    self._eff_vortex.y = scene.distance + _design.height*0.5
    if self._t_switch then
      self._t_switch = self._t_switch - dt
      if self._t_switch <= 0 then
        self._t_switch = nil        
        scene.bg:restore()
        scene.bg:fadeIn(1)
      end
    end
    return
  end
  
  self._t = nil
  _normalLevelBegin(self)
end

_normalUpdateBonus = function(self, dt)
  --奖励关卡
  _checkEnemy(self)
  self._t = self._t - dt
  if self._t <= 0 then
    _normalBonusEnd(self)
    return
  end
  
  if _mrandom() < _BONUS_LIGHT_R then
    local scene = self.scene
    local x = _mrandom(_design.width) - 1
    local y = _design.height*0.25 + _mrandom(_design.height)*0.5
    _effect.Effect(scene, x, y+scene.distance, 0, _effects_data.bonus_light)
  end
end

_normalBonusSetup = function(self)
  local sdata = _levels_data.bonus
  self.sdata = sdata
  self.velocity = sdata.velocity
  self._t = sdata.seconds
  --敌人
  local diff = sdata.enemy.diff
  self._enemy_next_distance = self.scene.distance + _mrandom(diff[1], diff[2])
  self.update = _normalUpdateBonus
end

_normalLevelSetup = function(self)
  local level = self.level
  if level > #_levels_data then
    --超出关数后，每关血量多10%
    self._enemy_hp_ratio = 1 + (level - #_levels_data)*0.1
    level = #_levels_data
  end
    
  local sdata = _levels_data[level]
  self.sdata = sdata
  self.velocity = sdata.velocity
  self._boss_left = nil
  self._bosses = {}
  
  local scene = self.scene
  local distance
  --初始放俘虏
  local prisoner = sdata.prisoner
  distance = scene.distance + prisoner.first_distance
  for i=1, prisoner.first_number do
    _item.Prisoner(scene,
        _hero_ids[_mrandom(#_hero_ids)],
        _mrandom(1, _SPAWN_COUNT)*_SPAWN_X_DIFF, 
        distance)
  end
  
  local min = #prisoner.diff_by_number
  for team,_ in pairs(scene.teams) do
    local n = #(team.heros)
    if n<min then min=n end
  end
  self._allow_ids = not _player.get().is_second_game and _first_game_ids or nil
  self._prisoner_diff = prisoner.diff_by_number[(min and min>0) and min or 1]
  self._prisoner_next_distance = scene.distance + self._prisoner_diff
  
  self._evt_team = _getEvtTeam(self)
  _mgr_evt.subscribe('team.hero_changed', self._evt_team)
  _mgr_evt.subscribe('team.changed', self._evt_team)
  
  --第一个敌人以俘虏出现计算
  local diff = sdata.enemy.diff
  self._enemy_next_distance = distance + _mrandom(diff[1], diff[2])
  
  self._enemy_killed = 0
  self._evt_enemy = _normalGetEvtEnemy(self)
  _mgr_evt.subscribe('enemy.killed', self._evt_enemy)
  
  --
  self.update = _normalUpdateLevel
end


_normalGetEvtEnemy = function(self)
  return function(evt, enemy, sdata)
    self._enemy_killed = self._enemy_killed + 1
    
    local thief = self.sdata.thief
    if _mrandom(100) <= thief.init_percent then
      local scene = self.scene
      _Enemy(scene, thief.id,
        _mrandom(_SPAWN_COUNT) * _SPAWN_X_DIFF,
        scene.distance + _SPAWN_Y_UP,
        thief.hp, thief.acc, thief.items)
      _mgr_snd.playEffect('sound/alarm.mp3')
    end
  end
end

_normalUpdateLevel = function(self, dt)
  if _checkEnd(self) then
    return
  end
  --正常战斗
  _checkPrisoner(self)
  _checkEnemy(self)
  --
  local boss = self.sdata.boss
  local killed = self._enemy_killed
  if killed >= boss[1] then
    --boss警告出现
    self.scene.ui_func.showBossAlarm()
    self._t = _BOSS_ALARM_SEC
    _mgr_snd.playEffect('sound/alarm.mp3')
    self.update = _normalUpdatePreBoss
    
    _mgr_evt.unsubscribe('enemy.killed', self._evt_enemy)
  end
end

_normalGetEvtEnemyInBoss = function(self)
  return function(evt, enemy, sdata)
    local bosses = self._bosses
    if bosses[enemy] then
      bosses[enemy] = nil
      self._boss_left = self._boss_left -1
    end
  end
end

_normalUpdatePreBoss = function(self, dt)
  if _checkEnd(self) then
    return
  end
  --boss警告
  self._t = self._t - dt
  if self._t > 0 then
    return
  end
  
  self._t = nil
  self.scene.ui_func.hideBossAlarm()
  --
  local scene = self.scene
  local bosses = self._bosses
  local ratio = self._enemy_hp_ratio
  for i, boss_data in ipairs(self.sdata.boss[2]) do
    local eid = boss_data[1]
    local ehp = boss_data.hp or _enemys_data[eid].hp
    if ratio then
      ehp = ehp * ratio
    end
    local e = _Enemy(scene, eid,
      _mrandom(_SPAWN_COUNT) * _SPAWN_X_DIFF,
      scene.distance + _SPAWN_Y_UP,
      ehp, boss_data.acc, boss_data.items)
    bosses[e] = true
  end
  self._boss_left = #self.sdata.boss[2]
  self.update = _normalUpdateBoss
  
  self._evt_enemy = _normalGetEvtEnemyInBoss(self)
  _mgr_evt.subscribe('enemy.killed', self._evt_enemy)
  
  _mgr_evt.publish('battle.boss_showed', scene)
end

_normalUpdateBoss = function(self, dt)
  if _checkEnd(self) then
    return
  end
  --boss战斗
  _checkPrisoner(self)
  
  --boss战结束
  if self._boss_left <= 0 then
    _normalLevelEnd(self)
    _mgr_evt.publish('battle.boss_died', self.scene)
  end
end



--[[
 挑战boss模式的设置
]]
StageBosses = require('util.class').class()


StageBosses.ctor = function(self, scene)
  self.scene = scene
  --当前boss，start时设，但不清除。getBossIndex可得。
  self.curr_index = 0
  
  --本关配置数据
  --self.sdata = _bosses_data[i]
  --本关速度
  self.velocity = 0
  --self.update
  --self._t
  --self._boss_left, self._bosses
  
  --本关允许弹框的英雄，若为nil则全部允许
  --self._allow_ids
  --下个俘虏出现需走距离
  --self._prisoner_next_distance
  --当前diff项
  --self._prisoner_diff
  
  --事件监听
  --self._evt_team
  --self._evt_enemy
end

local _bossesClean

local _bossesBegin
local _bossesUpdatePre
local _bossesSetup
local _bossesUpdate
local _bossesEnd
local _bossesUpdatePost

local _bossesGetEvtEnemy

StageBosses.inst_meta.getBossIndex = function(self)
  return self.curr_index
end

StageBosses.inst_meta.isEnd = function(self)
  return self.curr_index > #_bosses_data
end

StageBosses.inst_meta.allowJoin = function(self, hero_id)
  local allow = self._allow_ids
  return not allow or allow[hero_id]
end

StageBosses.inst_meta.update = function(self, dt)
end

StageBosses.inst_meta.start = function(self)
  self.curr_index = 0
  _bossesBegin(self)
end

StageBosses.inst_meta.stop = function(self)
  _bossesClean(self)
  self.curr_index = 0
  self.velocity = 0
end

_bossesClean = function(self)
  self.sdata = nil
  self.velocity = 0
  self.update = nil
  self._t = nil
  
  if self._evt_team then
    _mgr_evt.unsubscribe('team.hero_changed', self._evt_team)
    _mgr_evt.unsubscribe('team.changed', self._evt_team)
    self._evt_team = nil
  end
  if self._evt_enemy then
    _mgr_evt.unsubscribe('enemy.killed', self._evt_enemy)
    self._evt_enemy = nil
  end
end

_bossesBegin = function(self)
  self.curr_index = self.curr_index + 1
  
  if self.curr_index > #_bosses_data then
    self.scene:postChecker(
      _const.CHECKER_PRIO_STAGE,
      function()
        local scene = self.scene
        --触发team将结果保存起来
        for team,_ in pairs(scene.teams) do
          scene:removeTeam(team)
        end
        scene:gotoFinished()
      end)
    return
  end
  self.velocity = _const.VELOCITY_INBETWEEN
  
  --boss出现
  self.scene.ui_func.showBossAlarm()
  self._t = _BOSS_ALARM_SEC
  _mgr_snd.playEffect('sound/alarm.mp3')
  
  self.update = _bossesUpdatePre
end

_bossesUpdatePre = function(self, dt)
  self._t = self._t - dt
  if self._t > 0 then
    return
  end
  
  self._t = nil
  self.scene.ui_func.hideBossAlarm()
  _bossesSetup(self)
  for team,_ in pairs(self.scene.teams) do
    team:stageStart()
  end
  --第二个boss开始，随机获得能力
  if self.curr_index > 1 then
    local ui_func = self.scene.ui_func
    local r = _mrandom()
    if r < 0.3 then
      ui_func.popTip('获得了短暂的无敌能力')
      ui_func.itemInvincible()
    elseif r < 0.6 then
      ui_func.popTip('获得了使用一次炸弹')
      ui_func.itemBomb()
    else
      ui_func.popTip('获得了短暂的冲刺')
      ui_func.itemRush()
    end
  end
end

_bossesGetEvtEnemy = function(self)
  return function(evt, enemy, sdata)
    local bosses = self._bosses
    if bosses[enemy] then
      bosses[enemy] = nil
      self._boss_left = self._boss_left -1
    end
  end
end

_bossesSetup = function(self)
  local sdata = _bosses_data[self.curr_index]
  
  self.sdata = sdata
  self.velocity = sdata.velocity
  
  local scene = self.scene
  local distance
  --初始放俘虏
  local prisoner = sdata.prisoner
  distance = scene.distance + prisoner.first_distance
  for i=1, prisoner.first_number do
    _item.Prisoner(scene,
        _hero_ids[_mrandom(#_hero_ids)],
        _mrandom(1, _SPAWN_COUNT)*_SPAWN_X_DIFF, 
        distance)
  end
  
  local min = #prisoner.diff_by_number
  for team,_ in pairs(scene.teams) do
    local n = #(team.heros)
    if n<min then min=n end
  end
  self._allow_ids = not _player.get().is_second_game and _first_game_ids or nil
  self._prisoner_diff = prisoner.diff_by_number[(min and min>0) and min or 1]
  self._prisoner_next_distance = scene.distance + self._prisoner_diff
  
  ---放boss
  local bosses = {}
  for i, boss_data in ipairs(sdata.boss) do
    local e = _Enemy(scene, boss_data[1],
      _mrandom(_SPAWN_COUNT) * _SPAWN_X_DIFF,
      scene.distance + _SPAWN_Y_UP,
      boss_data.hp, boss_data.acc, boss_data.items)
    bosses[e] = true
  end
  self._boss_left = #sdata.boss
  self._bosses = bosses
  _mgr_evt.publish('battle.boss_showed', scene)
  
  ---
  self._evt_team = _getEvtTeam(self)
  _mgr_evt.subscribe('team.hero_changed', self._evt_team)
  _mgr_evt.subscribe('team.changed', self._evt_team)
  
  self._evt_enemy = _bossesGetEvtEnemy(self)
  _mgr_evt.subscribe('enemy.killed', self._evt_enemy)
  
  self.update = _bossesUpdate
end

_bossesUpdate = function(self, dt)
  if _checkEnd(self) then
    return
  end
  
  _checkPrisoner(self)
  if self._boss_left <= 0 then
    _bossesEnd(self)
    _mgr_evt.publish('battle.boss_died', self.scene)
  end
end

_bossesEnd = function(self)
  _bossesClean(self)
  for team,_ in pairs(self.scene.teams) do
    team:stageEnd()
  end
  
  self.velocity = _const.VELOCITY_INBETWEEN
  self._t = 2
  self.update = _bossesUpdatePost
  --显示碎片动画
  self.scene.ui_func.showPetDebris(self.curr_index)
end

_bossesUpdatePost = function(self, dt)
  self._t = self._t - dt
  if self._t > 0 then
    return
  end
  
  self._t = nil
  _bossesBegin(self)
end



