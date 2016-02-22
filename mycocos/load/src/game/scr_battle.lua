module('game.scr_battle', package.seeall)

local _mgr_scr = require('game.mgr_scr')
local _mgr_evt = require('game.mgr_evt')
local _misc = require('util.misc')

local _player = require('game.player')
local _task = require('game.task')
local _text = require('data.text')
local _control = require('game.control')
local _Team = require('game.battle.team').Team
local _guide_logic = require('game.guide_logic')
local _luckydraw_data = require('game.ui.luckydraw.luckydraw_data')

local _const = require('data.const')
local _DIST_METER = _const.DISTANCE_METER_COEFF

--[[
布局层次
layer 本屏幕node
 scene(z=0) 战斗场景node
 battle ui(z=1) 暂停按钮、体力、按钮等信息
 暂停、复活、升级界面等
 (z=3) 关卡开始、boss警告
 战斗中弹框
 debug_ui(z=1000) 显示碰撞框等调试信息
 guide_ui(z=2000) 新手引导
]]


--[[
hero_id 当前英雄id
layer

ui_battle
ui_golds
ui_gold_added
--ui_vit
--ui_vit_add
ui_distance
ui_tip_bg
ui_tip
ui_btn_pause

scene (battle.scene)
team 当前team
result 传给team记录结果的table

ui_level
ui_alarm

tip_curr
tip_left

--初次营救新英雄，体验数据
rescue_origin_ids
rescue_left
rescue_update
]]
local _data = {}

--战斗需要的回调函数表
local _cb_battle

----
local function _clearRescueInfo()
  _data.rescue_origin_ids = nil
  _data.rescue_left = nil
  _data.rescue_update = nil
end


local _tip_table = {
  {100, 'ui/battle/tip_bg_1.png', _text.battle_tip._100},
  {300, 'ui/battle/tip_bg_1.png', _text.battle_tip._300},
  {600, 'ui/battle/tip_bg_2.png', _text.battle_tip._600},
  {1000, 'ui/battle/tip_bg_2.png', _text.battle_tip._1000},
  {1500, 'ui/battle/tip_bg_3.png', _text.battle_tip['_1500+']},
}
local _BATTLE_TIP_SEC = 2
local _BATTLE_TIP_DIFF = 500

local function _checkBattleTip(dist, dt)
  local curr = _data.tip_curr
  local item = _tip_table[curr]
  if dist >= item[1] then
    local str
    if curr < #_tip_table then
      str = item[3]
      _data.tip_curr = curr + 1
      --最后一项是前一项 + _BATTLE_TIP_DIFF 得到
      if _data.tip_curr == #_tip_table then
        _tip_table[_data.tip_curr][1] = item[1] + _BATTLE_TIP_DIFF
      end
    else
      --最后一项是格式化提示，且其下次位置提示需更新
      str = string.format(item[3], item[1])
      item[1] = item[1] + _BATTLE_TIP_DIFF
    end
  
    local tip, bg = _data.ui_tip, _data.ui_tip_bg
    tip:setString(str)
    
    bg:loadTexture(item[2], ccui.TextureResType.plistType)
    bg:setVisible(true)
    
    _data.tip_left = _BATTLE_TIP_SEC
    return
  end
  
  if _data.tip_left > 0 then
    local t = _data.tip_left - dt
    if t <= 0 then
      _data.ui_tip_bg:setVisible(false)
    end
    _data.tip_left = t
  end
end

local function _updateBattle(evt_name, scene, dt)
  local dist = scene.distance *_DIST_METER
  _checkBattleTip(dist, dt)
  --营救引导体验
  local _checkRescue = _data.rescue_update
  if _checkRescue then
    _checkRescue(dt)
  end
end

local function _pauseButtonStart()
  local _forever = cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.4, 1.2), cc.ScaleTo:create(0.4, 1)))
  _data.ui_btn_pause:runAction(_forever)
  _data.ui_pause_particle:setVisible(true)
--  _data.ui_btn_pause:runAction(
--    cc.RepeatForever:create(
--    --cc.Repeat:create(
--      cc.Sequence:create(
--        cc.ScaleTo:create(0.4, 1.2),
--        cc.ScaleTo:create(0.4, 1)
--    --    ) ,8
--        )
--  ) )
end

local function _pauseButtonStop()
  _data.ui_btn_pause:stopAllActions()
  _data.ui_btn_pause:setScale(1)
  _data.ui_pause_particle:setVisible(false)
end

local function _startBattle()
  if _data.scene then
    _data.scene:stop()
    _data.scene:getCocosNode():removeFromParent()
    _data.scene = nil
  end
  --是否有进入过战斗(用于排行榜奖励条件)
  _player.get().rank.play = true
  local scene = require('game.battle.scene').Scene()
  _data.layer:addChild(scene:getCocosNode())
  _data.scene = scene
  
  --调试碰撞框
  if require('config').debug_coll then
    _data.debug_coll = require('game.battle.dbg_coll').DebugColl(scene)
    _data.layer:addChild(_data.debug_coll:getCocosNode(), 1000)
  end
  
  --local guide = require('game.guide_logic').checkBattleGuide(2000)
  scene:start(
    require('game.battle.stage').Stage(scene),
    _cb_battle) --,guide)
  
  local team = _Team(_data.scene, 1, _data.ui_golds, _data.ui_gold_added)
  _data.team = team
  _data.result = {}
  team.user_result = _data.result
  
  team:setPet(_player.get().pets.cur)
  team:addHero(_data.hero_id)
  _data.scene:addTeam(team)
  
  local _td,_tm,_tu,_tc = _control.start(_data.ui_battle, team, _cb_battle)
  --[[
  if guide then
    guide.touchForward(_td, _tm, _tu, _tc)
  end
  ]]
  
  _mgr_evt.publish('battle.start', _data.scene)
  
  _data.ui_tip_bg:setVisible(false)
  _data.tip_curr, _data.tip_left = 1, 0
  _data.gift_next = _BATTLE_GIFT_DIFF
  _mgr_evt.subscribe('battle.play_update', _updateBattle)
  
  _mgr_evt.subscribe('task.done', _pauseButtonStart)
end


local function _stopBattle()
  if _data.ui_level then
    _data.ui_level:removeFromParent()
    _data.ui_level = nil
  end
  if _data.ui_alarm then
    _data.ui_alarm:removeFromParent()
    _data.ui_alarm = nil
  end
  _data.ui_tip_bg:setVisible(false)
  
  _pauseButtonStop()
  
  if _data.scene then
    _mgr_evt.unsubscribe('task.done', _pauseButtonStart)
    _mgr_evt.unsubscribe('battle.play_update', _updateBattle)
    _mgr_evt.publish('battle.stop', _data.scene)
    
    _control.stop()
    _data.scene:stop()
    --startBattle时再清
    --_data.scene = nil
    _data.team = nil
    _data.result = nil
    _player.save()
  end
end

--暂停按钮按下触发
local function _onButtonPause()
  _data.scene:pause()
  
  _control.pause()
  
  _pauseButtonStop()
  
  local paused = require('game.ui.paused')
  local dlg = paused.create(
    function(ret_code)
      _mgr_scr.popDialog()
      _data.ui_battle:setVisible(true)
      if ret_code == paused.RET_RESUME then
        _data.scene:unpause()
        _control:resume()
      elseif ret_code == paused.RET_TO_MAIN then
            _player.save()
            _player.setDirty()
            _mgr_scr.popScreen()
            --[[取名
            if _player.get().rank.info.name then
                _player.save()
                _player.setDirty()
                _mgr_scr.popScreen()
            else
                local panel = require('game.ui.rank.rank_panel')
                local dlg = panel.RankPanel(
                    {
                      modal=true,
                      ani=true,
                      type_panel=panel.TAKENAME,
                      cb_enter = function()
                            _player.save()
                            _mgr_scr.popScreen()
                      end
                    })
            end
            --]]
      end
    end)
  _mgr_scr.pushDialog(dlg)
  _data.ui_battle:setVisible(false)
end


--[[
  将原来在team的保存结果移处理
  在 onFinished 触发，故处理顺序与原来一致
  看情况，将其移到显示结果界面或其它。。。
]]
local function _saveResult()
  local r = _data.result
  
  local ud = _player.get()
  ud.golds = ud.golds + r.golds
  
  if r.distance > ud.max_distance then
    ud.max_distance = r.distance
    _player.setDirty()
  end
  if r.score > ud.max_score then
    ud.max_score = r.score
    _player.setDirty()
  end
  
  --更新排行榜分数值
  local rank_logic = require('game.ui.rank.rank_logic')
  rank_logic.battleResult(r.score)
end

--显示战斗结果
local function _showResult()
  local rst = _data.result
  _stopBattle()  --会同时触发任务系统统计更新
  local done, reward = _task.getBattleResultAndCommit()
  _player.save()
  
  local f = string.format
  local player = _player.get()
  local result_data = {
    my_score = f('%d', rst.score),
    my_distance = f('%d米', rst.distance *_DIST_METER),
    history_score = f('%d', player.max_score),
    history_distance = f('%d米', player.max_distance *_DIST_METER),
    task = f('%d', done),
    reward = f('%dG', reward),
  }
  
  --
  _data.ui_battle:setVisible(false)
  
  local toMain = function()
    --通知从结算界面退出
    _mgr_scr.popScreen(nil, 'done_result')
  end
  
  local battleAgain = function()
    local battle = function(hero_id)
      _mgr_scr:popDialog()
      _data.ui_battle:setVisible(true)
      _data.hero_id = hero_id
      _startBattle()
    end
    local heros_panel = require('game.ui.heropanel').create{
      init_id = _data.hero_id,
      demo_bg_alpha = 192,
      guide_level_up = true,
      cb_back = toMain,
      cb_strike = battle,
      cb_advance_strike = battle,
    }
    heros_panel.z = 2
    _mgr_scr.pushDialog(heros_panel)
  end
  local function checkName()
        if _player.get().rank.info.name then
            battleAgain()
        else
            local panel = require('game.ui.rank.rank_panel')
            local dlg = panel.RankPanel(
                {
                  modal=true,
                  ani=true,
                  type_panel=panel.TAKENAME,
                  cb_enter = function()
                        battleAgain()
                  end
                })
        end
  end
  local dlg = require('game.ui.result').Result{
    cb_close = toMain,
    cb_again = battleAgain,--checkName,
  }
  dlg:setResultData(result_data)

end


--[[
复活队伍
rush: 是否冲刺
full_team: true:队伍复活 false:单人复活 nil:不复活(冲刺完死亡)
]]
local function _revive(rush, full_team)
  assert(not (rush<=0 and full_team==nil), '_revive: invalid config')
  
  local team = _data.team
  
  if full_team then
    --TODO: 队伍复活的英雄id，暂写死这里
    local heros = {
      18001, 18001, 14001, 17001, 19001
    }
    for i, hero_id in ipairs(heros) do
      team:addHero(hero_id)
    end
  else
    --单人复活、最后冲刺都是初始所选角色
    team:addHero(_data.hero_id)
  end
  
  team:setPet(_player.get().pets.cur)
  _data.scene:addTeam(team)
  _data.scene:returnToPlay()
  _data.ui_battle:setVisible(true)
  
  --让control控制冲刺
  _control.teamRevive(
    rush>0 and rush or nil, 
    (full_team==nil)  --是否暂时复活
  )
end

local function _getReviveTip()
  local fmt = _text.revive
  local rst = _data.result
  local ud = _player.get()

  --破纪录
  if rst.distance < ud.max_distance
    and rst.distance > ud.max_distance*0.8
  then
    return string.format(fmt.break_distance, 
      (ud.max_distance - rst.distance)*_DIST_METER)
  end
  --单场任务
  for i, t in ipairs(_task.getInfo()) do
    if t.is_one_battle 
      and not _task.isTaskDone(i)
    then
      return string.format(fmt.finish_task, t.desc)
    end
  end
  --其余随机
  local func = {
    --100米
    function(scene, rst, fmt)
      local dist = math.floor(rst.distance *_DIST_METER)
      local left = 100 - math.fmod(dist, 100)
      if left==0 then left=100 end
      return string.format(fmt.next_hundred, left, dist+left)
    end,
    --下一关
    function(scene, rst, fmt)
      return string.format(fmt.next_level, scene.stage:getLevel())
    end,
    --救英雄
    function(scene, rst, fmt)
      return fmt.rescue_hero
    end,
    --杀敌
    function(scene, rst, fmt)
      return fmt.kill_enemy
    end,
  }
  return func[math.random(#func)](_data.scene, rst, fmt)
end

local _showLottery

--复活提示框
local function _confirmRevive()
  _data.ui_battle:setVisible(false)
  
  local panel = require('game.ui.panel')
  local dlg = panel.Panel{
    modal=false,
    ani=false,
    type_panel=panel.DIED,

    endback=_showLottery,--_showResult
    cb_die=function()
      _revive(0, true) --全队复活、无冲刺
    end,
    died_tip=_getReviveTip(),
  }
end

--触发抽奖
_showLottery = function()
  _data.ui_battle:setVisible(false)
  
  if not _luckydraw_data.isStart() then
    --_confirmRevive()
    _showResult()
    return
  end
  
  local panel = require('game.ui.luckydraw.luckydraw_panel')
  local dlg = panel.Panel{
    modal=true,
    ani=true,
    cb_enter = function()
      local d = _luckydraw_data.data
      local rush = d.final_rush
      local full_team
      if d.group>0 then
        full_team = true
      elseif d.single>0 then
        full_team = false
      end
      if rush<=0 and full_team==nil then
        --_confirmRevive()
        _showResult()
      else
        _revive(rush, full_team)
      end
    end
  }
end

---初次营救，英雄体验逻辑
local function _firstRescue(cb_result)
  local node = cc.CSLoader:createNode('ui/unlock_trail.csb')
  local box = node:getChildByName('btn_ok'):getBoundingBox()
  _mgr_scr.pushDialog{
    node=node,
    block_bottom=true,
    pop_effect=true,
    reposition_center=true,
    z=1,
  }

  _guide_logic.checkRescueGuide(
    1,
    box,
    --
    function()
      _mgr_scr.popDialog()
      cb_result(false)
      
      --用指定英雄体验一段时间，之后恢复体验前的
      local team = _data.team
      local t = {}
      for i,h in ipairs(_data.team.heros) do
        t[#t+1] = h.sdata.id
      end
      
      team:removeAllHeros()
      local heros = {
        18001, 18001, 14001, 17001, 19001
      }
      for i, hero_id in ipairs(heros) do
        team:addHero(hero_id)
      end
      _mgr_scr.popupTip(_text.guide.rescue_tip_start)
      
      _data.rescue_origin_ids = t
      _data.rescue_left = 8
      _data.rescue_update = function(dt)
        local t = _data.rescue_left - dt
        if t > 0 then
          _data.rescue_left = t
          return
        end
        
        team:removeAllHeros()
        for i, id in ipairs(_data.rescue_origin_ids) do
          team:addHero(id)
        end
        _clearRescueInfo()
        _mgr_scr.popupTip(_text.guide.rescue_tip_end)
      end
    end
  )
end

-------------------------------
--游戏需要的函数
local function _cbSetDistance(num)
  _data.ui_distance:setString(string.format('%.0f米', num *_DIST_METER))
end

local function _cbOnDead()
  --死亡时，营救体验结束
  _clearRescueInfo()
end

local function _cbOnFinished()
  _saveResult()
  _control.teamDied()
  --_showLottery()
  _confirmRevive()
end

local function _cbPopPrisonerDialog(hero_id, cb_result)
  --初次引导，硬来。。。
  if _guide_logic.needRescueGuide() then
    _firstRescue(cb_result)
    return
  end
  
  local panel = require('game.ui.panel')
  local dlg = panel.Panel{
    modal=true,
    ani=true,
    type_panel=panel.UNLOCK,
    hero_id=hero_id,
    cb_enter=function()
        cb_result(true)
    end,
    endback=function()
        cb_result(false)
    end
  }
  --[[旧营救界面
  local Dialogue = require('game.ui.dialogue').Dialogue
  local dlg = Dialogue{
      modal=true,
      ani=true,
      hero_id=hero_id,
      cb_yes=function()
        cb_result(true)
      end,
      cb_no=function()
        cb_result(false)
      end,
    }
  --]]
end

local function _cbPopItemBag(internal, cbOk, cbCancel)
  _data.scene:pause(internal)
  _control.pause()
  
  local panel = require('game.ui.panel')
  local dlg = panel.Panel{
    modal=true,
    ani=true,
    
    type_panel=panel.REWARD,
    cb_enter=function()
      _data.scene:unpause()
      _control.resume()
      _cb_battle.resetItems()
      if cbOk then cbOk() end
    end;
    
    endback=function()
      _data.scene:unpause()
      _control.resume()
      if cbCancel then cbCancel() end
    end,
  }
end

local function _cbShowLevel(level)
  local lv = require('game.ui.checkpoint').create(level)
  _data.layer:addChild(lv, 1)
  _data.ui_level = lv
end

local function _cbHideLevel()
  if _data.ui_level then
    local ui = _data.ui_level
    _data.ui_level = nil
    local w = require('config').design.width
    ui:runAction(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=-w,y=0}),
        cc.CallFunc:create(
          function()
            ui:removeFromParent()
          end
    ) ) )
  end
end

local function _cbShowBossAlarm()
  local alarm = require('game.ui.warning').create()
  _data.layer:addChild(alarm, 1)
  _data.ui_alarm = alarm
end

local function _cbHideBossAlarm()
  if _data.ui_alarm then
    local ui = _data.ui_alarm
    _data.ui_alarm = nil
    local w = require('config').design.width
    ui:runAction(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=w,y=0}),
        cc.CallFunc:create(
          function()
            ui:removeFromParent()
          end
    ) ) )
  end
end

local function _cbAddChance(x, y)
  _luckydraw_data.addChance()
  --显示抽奖币动画
  local coin = cc.Sprite:create()
  coin:setSpriteFrame('effect/draw_coin2.png')
  local light = cc.Sprite:create()
  light:setSpriteFrame('effect/draw_coin_light.png')
  coin:addChild(light, -1)
  local text = cc.Sprite:create()
  text:setSpriteFrame('effect/draw_coin_text.png')
  coin:addChild(text)
  _data.layer:addChild(coin, 3)
  
  light:setPosition(38, 38)
  light:setScale(2)
  light:setOpacity(0)
  light:runAction(
    cc.Sequence:create(
      cc.DelayTime:create(0.5),
      cc.Spawn:create(
        cc.ScaleTo:create(0.2, 4),
        cc.FadeIn:create(0.2)
      ),
      cc.Spawn:create(
        cc.ScaleTo:create(0.6, 2),
        cc.FadeOut:create(0.6)
      )
  ) )
    
  text:setPosition(38, 76)
  text:runAction(
    cc.Sequence:create(
      cc.DelayTime:create(0.5),
      cc.Spawn:create(
        cc.MoveBy:create(0.8, {x=0, y=50}),
        cc.FadeOut:create(0.8)
  ) ) )

  light:setVisible(false)
  text:setVisible(false)
  
  coin:setScale(0.5)
  coin:setPosition(x, y)
  coin:runAction(
    cc.Sequence:create(
      cc.Spawn:create(
        cc.ScaleTo:create(0.5, 1),
        cc.MoveBy:create(0.5, {x=0, y=100})
      ),
      cc.CallFunc:create(function()
        light:setVisible(true)
        text:setVisible(true)
      end),
      cc.FadeOut:create(0.8),
      cc.CallFunc:create(function()
          coin:removeFromParent()
      end)
  ) )
end


_cb_battle = {
  setDistance = _cbSetDistance,
  onDead = _cbOnDead,
  onFinished = _cbOnFinished,
  
  popPrisonerDialog = _cbPopPrisonerDialog,
  popItemBag = _cbPopItemBag,
  popTip = _mgr_scr.popupTip,
  --resetItems = 
  addChance = _cbAddChance,
  showLevel = _cbShowLevel,
  hideLevel = _cbHideLevel,
  showBossAlarm = _cbShowBossAlarm,
  hideBossAlarm = _cbHideBossAlarm,
}

--------------------------
local function _onEnter()
  --战斗ui
  local panel = cc.CSLoader:createNode('ui/battle.csb')
  _data.layer:addChild(panel, 1)
  _data.ui_battle = panel
  
  local h = ccui.Helper
  local s = h.seekWidgetByNameOnNode
  _data.ui_golds = s(h, panel, 'bmf_golds')
  
  _data.ui_gold_added = s(h, panel, 'bmf_gold_added')
  _data.ui_gold_added:setVisible(false)
  
  _data.ui_distance = s(h, panel, 'bmf_distance')
  
  _data.ui_tip_bg = s(h, panel, 'img_tip_bg')
  _data.ui_tip = s(h, panel, 'bmf_tip')
  _data.ui_tip_bg:setVisible(false)
  
  _data.ui_btn_pause = s(h, panel, 'btn_pause')
  _data.ui_btn_pause:addTouchEventListener(
    _misc.createClickCB(_onButtonPause) )
  
  _data.ui_pause_particle = ccui.Helper:seekNodeByNameOnNode(panel, 'pause_particle')
  _data.ui_pause_particle:setVisible(false)

  --进入即启动战斗
  _startBattle()
end

local function _onExit()
  _stopBattle()
  for n,v in pairs(_data) do
    _data[n] = nil
  end
end

function create(hero_id)
  _data.layer = cc.Layer:create()
  _data.hero_id = hero_id
  return {
    node = _data.layer;
    onEnter = _onEnter;
    onExit = _onExit;
    onKeyBack = _onButtonPause;
  }
end
