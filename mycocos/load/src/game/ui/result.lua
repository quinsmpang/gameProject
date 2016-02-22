module('game.ui.result', package.seeall)



local _base_panel = require('game.ui.basepanel').BasePanel
local _misc = require('util.misc')
local _charge = require('game.charge')
local _charge_data = require('data.charge')
local _text = require('data.text')
local _player = require('game.player')
local _uipanel = require('game.ui.panel')
local _rank_data = require('game.ui.rank.rank_data')
--[[
self的数据
_my_score
_my_distance
_history_score
_history_distance
_reward
_task
_font_again
_money_text

--是否需要领取奖励
_need_get_reward
]]

--再玩一次
local function _cb_again(self,tab)
    self:destroy()
    if tab.cb_again then
        tab.cb_again()
    end
end

--领取奖励->再玩一次
local function _restorePlayAgain(self)
  --self._money_text:setVisible(false)
  self._font_again:setSpriteFrame("ui/result/font_again.png")
  
  self._need_get_reward = false
end

--领取奖励
local function _cb_get(self)
  --去付费(领取金币礼包)
  --用阻塞方式实现支付，故不需维护支付中状态
  if _charge.chargeForBag(_charge_data.gold_bag) then
    _restorePlayAgain(self)
  end
end

Result = require('util.class').class(_base_panel)

--
Result.inst_meta.setResultData = function(self, tab)
    self._my_score:setString(tab.my_score)
    self._my_distance:setString(tab.my_distance)
    self._history_score:setString(tab.history_score)
    self._history_distance:setString(tab.history_distance)
    self._reward:setString(tab.reward)
    self._task:setString(tab.task)
end

Result.ctor = function(self, tab)--{modal,ani,cb_home,cb_again}
    local panel = cc.CSLoader:createNode('ui/settlement.csb')
    self.__super_ctor__(self, panel, tab.modal, tab.ani)
    
    
    local action = cc.CSLoader:createTimeline('ui/settlement.csb')
    panel:runAction(action)
    action:gotoFrameAndPlay(0,true)

--    local _page_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'page_btn')
--    _page_btn:addTouchEventListener(
--      _misc.createClickCB(function()
--        self:destroy()
--        if tab.cb_home then
--            tab.cb_home()
--        end
--      end
--    ))

    --数据
    self._my_score         = ccui.Helper:seekWidgetByNameOnNode(panel, 'fnt_my_score')
    self._my_distance      = ccui.Helper:seekWidgetByNameOnNode(panel, 'fnt_my_distance')
    self._history_score    = ccui.Helper:seekWidgetByNameOnNode(panel, 'fnt_history_score')
    self._history_distance = ccui.Helper:seekWidgetByNameOnNode(panel, 'fnt_history_distance')
    self._reward           = ccui.Helper:seekWidgetByNameOnNode(panel, 'fnt_reward')
    self._task             = ccui.Helper:seekWidgetByNameOnNode(panel, 'fnt_task')
    self._font_again = panel:getChildByName('font_again')
    --self._money_text = self._font_again:getChildByName("money_text")
    
    --是否需领取奖励
    self._need_get_reward = false--无需领取
--    self._money_text:setString(
--      string.format(_text.ui_charge_format, _charge_data.gold_bag.rmb)
--    )
    
    local _again_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'again_btn')
    _again_btn:addTouchEventListener(
      _misc.createClickCB(function()
        if self._need_get_reward then
          _cb_get(self)
        else
          _cb_again(self, tab)
        end
      end
    ))

    --关闭将按钮恢复为 再来一次
    local function close()
        self:destroy()
        if tab.cb_close then
            tab.cb_close()
        end
      --[[旧逻辑
      if self._need_get_reward then
        _restorePlayAgain(self)
      else
         self:destroy()
        if tab.cb_close then
            tab.cb_close()
        end

         if _player.get().rank.info.name then
            self:destroy()
            if tab.cb_close then
              tab.cb_close()
            end
         else
            local panel = require('game.ui.rank.rank_panel')
            local dlg = panel.RankPanel(
                {
                  modal=true,
                  ani=true,
                  type_panel=panel.TAKENAME,
                  cb_enter = function()
                        self:destroy()
                        if tab.cb_close then
                          tab.cb_close()
                        end
                  end
                })
         end
        end
         --]]
    end
    self.onKeyBack = close
    
    local public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
    public_btn_close:addTouchEventListener(
      _misc.createClickCB(close)
    )

    --鼓励界面
--    cclog("_player.get().rank.refresh ============== " .._player.get().rank.refresh)
    if _player.get().rank.refresh >= _rank_data.REFRESH then
        local dlg = _uipanel.Panel(
        {
          modal=true,
          ani=true,
          type_panel=_uipanel.ENCOURAGE
        })
    end
   
end


--[[使用例子
  local _cb_again = function()
      cclog("============== _cb_again ==============")
  end 
  local _cb_home = function()
      cclog("============== _cb_home ==============")
  end
  local _cb_close = function()
      cclog("============== _cb_close ==============")
  end
  local _panel = require('game.ui.result')
  local object = _panel.Result({cb_home = _cb_home,cb_again = _cb_again,cb_close = _cb_close})
  --设置数据
  object:setResultData({my_score = "1111",my_distance = "2222",history_score = "3333",history_distance = "4444",reward = "5555",task = "7"})
 --]]

