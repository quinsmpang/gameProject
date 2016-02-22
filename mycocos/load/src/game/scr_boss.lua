module('game.scr_boss', package.seeall)

local _mgr_scr = require('game.mgr_scr')
--local _mgr_evt = require('game.mgr_evt')
local _misc = require('util.misc')

local _player = require('game.player')
local _control = require('game.control')
local _Team = require('game.battle.team').Team

--[[
布局层次
layer 本屏幕node
 scene(z=0) 战斗场景node
 battle ui(z=1) 暂停按钮、体力、按钮等信息
 暂停、复活、升级界面等
 (z=3) 关卡开始、boss警告等效果
 战斗中弹框
 debug_ui(z=1000) 显示碰撞框等调试信息
 guide_ui(z=2000) 新手引导
]]

local _pet_id = {30001, 30002, 30003, 30004, 30005}

--[[
hero_id 当前英雄id
layer

ui_battle
ui_golds
ui_gold_added
ui_btn_pause

scene (battle.scene)
stage
team 当前team
result 传给team记录结果的table

ui_level
ui_alarm
]]
local _data = {}

--战斗需要的回调函数表
local _cb_battle

----
local function _startBattle()
  if _data.scene then
    _data.scene:stop()
    _data.scene:getCocosNode():removeFromParent()
    _data.scene = nil
  end
  
  local scene = require('game.battle.scene').Scene()
  _data.layer:addChild(scene:getCocosNode())
  _data.scene = scene
  
  --调试碰撞框
  if require('config').debug_coll then
    _data.debug_coll = require('game.battle.dbg_coll').DebugColl(scene)
    _data.layer:addChild(_data.debug_coll:getCocosNode(), 1000)
  end
  
  _data.stage = require('game.battle.stage').StageBosses(scene)
  scene:start(_data.stage, _cb_battle)
  
  local team = _Team(_data.scene, 1, _data.ui_golds, _data.ui_gold_added)
  _data.team = team
  _data.result = {}
  team.user_result = _data.result
  
  team:setPet(_player.get().pets.cur)
  team:addHero(_data.hero_id)
  _data.scene:addTeam(team)
  
  _control.start(_data.ui_battle, team, _cb_battle, true)
  --不触发任务
  --_mgr_evt.publish('battle.start', _data.scene)
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
  
  if _data.scene then
    --_mgr_evt.publish('battle.stop', _data.scene)
    _control.stop()
    _data.scene:stop()
    _data.stage, _data.team, _data.result = nil
    _player.save()
  end
end

--暂停按钮按下触发
local function _onButtonPause()
  _data.scene:pause()
  _control.pause()
  
  local paused = require('game.ui.petpaused')
  --设置已获得的id
  for i=1, _data.stage:getBossIndex()-1 do
    paused.setData(_pet_id[i])
  end
  local dlg = paused.create(
    function(ret_code)
      _mgr_scr.popDialog()
      _data.ui_battle:setVisible(true)
      if ret_code == paused.RET_RESUME then
        _data.scene:unpause()
        _control:resume()
      elseif ret_code == paused.RET_TO_MAIN then
        --看是否需减少次数。
        local boss_index = _data.stage:getBossIndex()
        require('game.ui.pkboss').checkPkNumConsumed(boss_index)
        --以防不减少时，使用的道具没及时保存即强退
        _player.save()
        _mgr_scr.popScreen('scr_boss')
      end
    end)
  _mgr_scr.pushDialog(dlg)
  _data.ui_battle:setVisible(false)
end


local function _showResult()
  local rst = _data.result
  local boss_index = _data.stage:getBossIndex()
  --
  _data.ui_battle:setVisible(false)
  
  local ud = _player.get()
  ud.golds = ud.golds + rst.golds
  _player.setDirty()
  
  local dlg = require('game.ui.pkboss').PKBoss{
    modal = true,
    ani = true,
    index = boss_index,
    cbHome = function()
      _mgr_scr.popScreen('scr_boss', 
        boss_index>1 and 'got_debris') --获取到碎片时加入got_debris
    end,
    cbAgain = function()
      --再次挑战，见 scr_main.onShow
      _mgr_scr.popScreen('scr_boss', 'on_challenge')
    end,
  }
end

--[[
复活队伍(从scr_battle复制过来的，有修改相应改说明)
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

local function _confirmRevive()
  _data.ui_battle:setVisible(false)
  
  local panel = require('game.ui.panel')
  local dlg = panel.Panel{
    modal=false,
    ani=false,
    type_panel=panel.DIED,

    endback=_showResult,
    cb_die=function()
      _revive(0, true) --全队复活、无冲刺
    end,
    died_tip='',
  }
end

-------------------------------
--游戏需要的函数
local function _cbSetDistance(num)
end

local function _cbOnDead()
end

local function _cbOnFinished()
  if not _data.stage:isEnd() then
    _confirmRevive()
  else
    _showResult()
  end
end

local function _cbPopPrisonerDialog(hero_id, cb_result)
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
  --[[
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
  ]]
end

local function _cbPopItemBag(op_hang, cbOk, cbCancel)
  _data.scene:pause(op_hang)
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
end

local function _cbHideLevel()
end

local function _cbShowBossAlarm()
end

local function _cbHideBossAlarm()
end

local function _cbShowPetDebris(index)
  local id = _pet_id[index]
  if not id then return end
  
  local bg = cc.Sprite:create()
  bg:setSpriteFrame('ui/pkmodel/shine_bg.png')
  local size = bg:getContentSize()
  local x, y = size.width*0.5, size.height*0.5
  
  local star = cc.Sprite:create()
  star:setSpriteFrame('ui/pkmodel/shine_star.png')
  local pet = cc.Sprite:create()
  pet:setSpriteFrame(string.format('ui/heros/%d.png', id))
  local debris = cc.Sprite:create()
  debris:setSpriteFrame('ui/pkmodel/font_debris.png')
  
  star:setPosition(x, y)
  bg:addChild(star)
  pet:setPosition(x, y)
  pet:setLocalZOrder(1)
  bg:addChild(pet)
  debris:setPosition(x, y)
  debris:setLocalZOrder(2)
  bg:addChild(debris)
  
  star:runAction(
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.FadeOut:create(0.3),
        cc.FadeIn:create(0.3)
  ) ) )
  
  size = require('config').design
  x, y = size.width*0.5, size.height*0.5
  bg:setPosition(x, y)
  _data.layer:addChild(bg, 3)
  
  bg:setScale(0)
  x, y = _data.ui_btn_pause:getPosition()
  bg:runAction(
    cc.Sequence:create(
      cc.ScaleTo:create(0.3, 1),
      cc.DelayTime:create(2),
      cc.MoveTo:create(0.5, {x=x, y=y}),
      cc.CallFunc:create(function()
          bg:removeFromParent()
      end)
  ) )
end

local function _cbItemBomb()
  --TODO: 同control，先写死，暂不合并
  _data.team:useItemBomb()
end

local function _cbItemRush()
  --TODO: 同control，先写死，暂不合并
  local spr = _data.ui_battle:getChildByName('spr_rush')
  _data.team:useItemRush(5, spr,
    ccui.Helper:seekWidgetByNameOnNode(spr, 'bar_rush')
  )
end

local function _cbItemInvincible()
  --TODO: 同control，先写死，暂不合并
  local spr = _data.ui_battle:getChildByName('spr_invincible')
  _data.team:useItemInvincible(10, spr,
    ccui.Helper:seekWidgetByNameOnNode(spr, 'bar_invincible')
  )
end


_cb_battle = {
  setDistance = _cbSetDistance,
  onDead = _cbOnDead,
  onFinished = _cbOnFinished,
  
  popPrisonerDialog = _cbPopPrisonerDialog,
  popItemBag = _cbPopItemBag,
  popTip = _mgr_scr.popupTip,
  
  showLevel = _cbShowLevel,
  hideLevel = _cbHideLevel,
  showBossAlarm = _cbShowBossAlarm,
  hideBossAlarm = _cbHideBossAlarm,
  
  showPetDebris = _cbShowPetDebris,
  --TODO: xxx
  itemRush = _cbItemRush,
  itemBomb = _cbItemBomb,
  itemInvincible = _cbItemInvincible,
}

--------------------------
local function _onEnter()
  local panel = cc.CSLoader:createNode('ui/battle.csb')
  _data.layer:addChild(panel, 1)
  _data.ui_battle = panel
  
  local h = ccui.Helper
  local s = h.seekWidgetByNameOnNode
  _data.ui_golds = s(h, panel, 'bmf_golds')
  
  _data.ui_gold_added = s(h, panel, 'bmf_gold_added')
  _data.ui_gold_added:setVisible(false)
  
  s(h, panel, 'bmf_distance'):setVisible(false)
  s(h, panel, 'img_tip_bg'):setVisible(false)
  
  _data.ui_btn_pause = s(h, panel, 'btn_pause')
  _data.ui_btn_pause:addTouchEventListener(
    _misc.createClickCB(_onButtonPause) )
  
  ccui.Helper:seekNodeByNameOnNode(panel, 'pause_particle'):setVisible(false)

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
