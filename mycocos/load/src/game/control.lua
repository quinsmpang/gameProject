module('game.control', package.seeall)

--负责游戏战斗的操作

local _mgr_scr = require('game.mgr_scr')
local _mgr_evt = require('game.mgr_evt')
local _player = require('game.player')
local _misc = require('util.misc')
local _Team = require('game.battle.team').Team

local _const = require('data.const')
local _guide_logic = require('game.guide_logic')

local _data = {
--[[
ui_battle 战斗ui的顶层node
team 控制的team
is_paused
final_rush 临死前的冲刺次数

listener
touch_id 上次按下的id
touch_x, touch_y 上次按下的位置
touch_positive 上次移动的x方向 true:右 false:左 nil:无
]]
}

local function _touchDown(touch)
  if _data.is_paused then return false end
  if _data.touch_id then return true end
  
  local tid = touch:getId()
  local pos = _data.ui_battle:convertToNodeSpace(touch:getLocation())
  local x, y = pos.x, pos.y
  _data.touch_id = tid
  _data.touch_x, _data.touch_y = x, y
  _data.touch_positive = nil
  return true
end

local function _touchUp(touch)
  if not _data.touch_id then return end
  
  local tid = touch:getId()
  if tid ~= _data.touch_id then return end
  
  _data.touch_id = nil
  _data.team:moveOffsetX(0, true)
end

local function _touchMoved(touch)
  if not _data.touch_id then return end
  
  local tid = touch:getId()
  if tid ~= _data.touch_id then return end
  
  local pos = _data.ui_battle:convertToNodeSpace(touch:getLocation())
  local x, y = pos.x, pos.y
  local diff = x - _data.touch_x
  local diff_pst = _data.touch_positive
  
  _data.touch_x, _data.touch_y = x, y
  if diff < 0 then
    _data.touch_positive = false
    _data.team:moveOffsetX(diff, diff_pst or diff_pst==nil)
  elseif diff > 0 then
    _data.touch_positive = true
    _data.team:moveOffsetX(diff, not diff_pst)
  else
    _data.touch_positive = nil
    _data.team:moveOffsetX(0, true)
  end
  
end


---------------------
local _item = {
  --ui_invincible_spr
  --ui_invincible_bar
  --ui_rush_spr
  --ui_rush_bar
  
  --ui_button_bomb
  --ui_num_bomb
  --ui_button_invincible
  --ui_num_invincible
  --ui_button_rush
  --ui_num_rush
  
  --ui_guide_item
  --guide_point_to 显示时，赋为ui_button_xxx，否则为nil
}

local _DISTANCE_ITEM_GUIDE = 50
local _DISTANCE_METER_COEFF = require('data.const').DISTANCE_METER_COEFF
local _BOSS_GUIDE_X = 420

local function _itemHideBossGuide(point_to)
  local pt = _item.guide_point_to
  if pt and 
    (not point_to or pt==point_to)
  then
    _item.guide_point_to = nil
    _item.ui_guide_item:stopAllActions()
    _item.ui_guide_item:setVisible(false)
  end
end


local function _itemSetNumber()
  local items = _player.get().items
  
  local strfmt = string.format
  _item.ui_num_bomb:setString(strfmt('%d', items.bomb))
  _item.ui_num_invincible:setString(strfmt('%d', items.invincible))
  _item.ui_num_rush:setString(strfmt('%d', items.rush))
end

local function _itemUseBomb()
  if _data.is_paused or _data.final_rush then
    return 
  end
  
  _itemHideBossGuide(_item.ui_button_bomb)
  
  local team = _data.team
  local sec = team:checkUseItemBomb()
  if sec then
    local items = _player.get().items
    
    local function use()
      items.bomb = items.bomb - 1
      _player.setDirty()
      _itemSetNumber()
      team:useItemBomb()
    end
    if items.bomb > 0 then
      use()
    else
      _data.ui_func.popItemBag(true, use)
    end
  end
end

local function _itemUseInvincible()
  if _data.is_paused or _data.final_rush then
    return 
  end
  
  _itemHideBossGuide(_item.ui_button_invincible)
  
  local team = _data.team
  local sec = team:checkUseItemInvincible(10)
  if sec then
    local items = _player.get().items
    
    local function use()
      items.invincible = items.invincible - 1
      _player.setDirty()
      _itemSetNumber()
      team:useItemInvincible(sec, _item.ui_invincible_spr, _item.ui_invincible_bar)
    end
    if items.invincible > 0 then
      use()
    else
      _data.ui_func.popItemBag(true, use)
    end
  end
end

local function _itemUseRush()
  if _data.is_paused or _data.final_rush then
    return 
  end
  
  _itemHideBossGuide(_item.ui_button_rush)
  
  local team = _data.team
  local sec = team:checkUseItemRush(5)
  if sec then
    local items = _player.get().items
    
    local function use()
      items.rush = items.rush - 1
      _player.setDirty()
      _itemSetNumber()
      team:useItemRush(sec, _item.ui_rush_spr, _item.ui_rush_bar)
    end
    if items.rush > 0 then
      use()
    else
      _data.ui_func.popItemBag(true, use)
    end
  end
end

local _itemCheckGuide
_itemCheckGuide = function(evt, scene, dt)
  local dist = scene.distance * _DISTANCE_METER_COEFF
  if dist >= _DISTANCE_ITEM_GUIDE then
    scene:postChecker(
      _const.CHECKER_PRIO_ITEM_GUIDE,
      function()
        _mgr_evt.unsubscribe('battle.play_update', _itemCheckGuide)
        local items = _player.get().items
        items.bomb = items.bomb + 1
        _itemSetNumber()
        _guide_logic.checkItemGuide(scene, 2000, _item.ui_button_bomb, 
          function() 
            _itemUseBomb()
            scene:endChecker()
          end)
      end)
  end
end


local function _itemCheckBossGuide(evt)
  if evt == 'battle.boss_showed' then
    local t = {
      _item.ui_button_bomb,
      _item.ui_button_invincible,
      _item.ui_button_rush
    }
    local to = t[math.random(#t)]
    _item.guide_point_to = to
    local y = to:getPositionY()
    local g = _item.ui_guide_item
    g:setPosition(_BOSS_GUIDE_X, y)
    g:setVisible(true)
    g:runAction(
      cc.RepeatForever:create(
        cc.Sequence:create(
          cc.MoveBy:create(0.5, {x=-30, y=0}),
          cc.MoveBy:create(0.5, {x=30, y=0})
        )
      )
    )
  elseif evt == 'battle.boss_died' then
    _itemHideBossGuide()
  end
end

local function _itemSetup(ui_battle)
  local h = ccui.Helper
  local s = h.seekWidgetByNameOnNode
  local node
  
  node = ui_battle:getChildByName('spr_invincible')
  node:setVisible(false)
  _item.ui_invincible_spr = node
  _item.ui_invincible_bar = s(h, node, 'bar_invincible')
  
  node = ui_battle:getChildByName('spr_rush')
  node:setVisible(false)
  _item.ui_rush_spr = node
  _item.ui_rush_bar = s(h, node, 'bar_rush')
  
  node = s(h, ui_battle, 'btn_item_bomb')
  _item.ui_button_bomb = node
  node:addTouchEventListener(
    _misc.createClickCB(_itemUseBomb) )
  _item.ui_num_bomb = s(h, ui_battle, 'bmf_item_bomb')
  
  node = s(h, ui_battle, 'btn_item_invincible')
  _item.ui_button_invincible = node
  node:addTouchEventListener(
    _misc.createClickCB(_itemUseInvincible) )
  _item.ui_num_invincible = s(h, ui_battle, 'bmf_item_invincible')
  
  node = s(h, ui_battle, 'btn_item_rush')
  _item.ui_button_rush = node
  node:addTouchEventListener(
    _misc.createClickCB(_itemUseRush) )
  _item.ui_num_rush = s(h, ui_battle, 'bmf_item_rush')
  
  node = ui_battle:getChildByName('spr_guide_item')
  node:setVisible(false)
  _item.ui_guide_item = node
  
  _data.ui_func.resetItems = _itemSetNumber
  _itemSetNumber()
  
  if not _data.ignore_guide then
    if _guide_logic.needItemGuide() then
      _mgr_evt.subscribe('battle.play_update', _itemCheckGuide)
    end
    _mgr_evt.subscribe('battle.boss_showed', _itemCheckBossGuide)
    _mgr_evt.subscribe('battle.boss_died', _itemCheckBossGuide)
  end
end


local function _itemFree()
  if not _data.ignore_guide then
    _mgr_evt.unsubscribe('battle.play_update', _itemCheckGuide)
    _mgr_evt.unsubscribe('battle.boss_showed', _itemCheckBossGuide)
    _mgr_evt.unsubscribe('battle.boss_died', _itemCheckBossGuide)
  end
  for n, ui in pairs(_item) do
    _item[n] = nil
  end
end

local _doFinalRush
_doFinalRush = function()
  local r = _data.final_rush
  if r > 0 then
    _data.final_rush = r - 1
    --冲刺5秒
    _data.team:useItemRush(5, _item.ui_rush_spr, _item.ui_rush_bar, _doFinalRush)
  else
    if _data.revive_temporary then
      _data.team:removeAllHeros()
    end
    _data.final_rush = nil
    _data.revive_temporary = nil
  end
end

---------------------
function teamDied()
  _itemHideBossGuide()
end

function teamRevive(final_rush, revive_temporary)
  _data.final_rush = final_rush
  _data.revive_temporary = revive_temporary
  if final_rush then
    _doFinalRush()
  end
end

function pause()
  _data.paused = true
  _data.touch_id = nil
end

function resume()
  _data.paused = false
end

function start(ui_battle, team, ui_func, ignore_guide)
  local lsn = cc.EventListenerTouchOneByOne:create()
  lsn:registerScriptHandler(_touchDown, cc.Handler.EVENT_TOUCH_BEGAN )
  lsn:registerScriptHandler(_touchMoved, cc.Handler.EVENT_TOUCH_MOVED )
  lsn:registerScriptHandler(_touchUp, cc.Handler.EVENT_TOUCH_ENDED )
  lsn:registerScriptHandler(_touchUp, cc.Handler.EVENT_TOUCH_CANCELLED)
  ui_battle:getEventDispatcher():addEventListenerWithSceneGraphPriority(lsn, ui_battle)
  
  _data.ui_battle = ui_battle
  _data.ui_func = ui_func
  _data.ignore_guide = ignore_guide

  _itemSetup(ui_battle, ignore_guide)
     
  _data.team = team
  _data.listener = lsn
  _data.paused = false
  _data.touche_id = nil
  
  --为实现新手引导，暂直接暴露处理函数。。。
  return _touchDown, _touchMoved, _touchUp, _touchUp
end

function stop()
  if not _data.ui_battle then return end
  
  _data.ui_battle:getEventDispatcher():removeEventListener(_data.listener)
  _itemFree()
  for n,v in pairs(_data) do
    _data[n] = nil
  end
end

