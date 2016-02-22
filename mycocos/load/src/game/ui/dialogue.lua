module('game.ui.dialogue', package.seeall)


local _base_panel = require('game.ui.basepanel').BasePanel
local _misc = require('util.misc')
local _heros_data = require('data.hero').heros
local _text = require('data.text')
local _charge_unlock = require('data.charge').unlock
local _charge = require('game.charge')

Dialogue = require('util.class').class(_base_panel)



--创建对话
Dialogue.ctor = function(self, tab)--{hero_id,cb_yes,cb_no,type_panel,modal,ani}
    local panel = cc.CSLoader:createNode('ui/dialogue.csb')
    self.__super_ctor__(self, panel, tab.modal, tab.ani)
    
    local action = cc.CSLoader:createTimeline('ui/dialogue.csb')
    panel:runAction(action)
    action:gotoFrameAndPlay(0,true)

    local hero_id = tab.hero_id
    
    local _spr_role = panel:getChildByName("role_spr")
    local str = "ui/heros/" ..tostring(hero_id) ..".png"
    _spr_role:setSpriteFrame(str)

    local _fong_text = ccui.Helper:seekWidgetByNameOnNode(panel, 'role_name')
    _fong_text:setString(_heros_data[hero_id].name)
    
    local _fong_speak = ccui.Helper:seekWidgetByNameOnNode(panel, 'speak_frame')
    _fong_speak:setString(_text.rescue[hero_id])
    
--    local _money_text = ccui.Helper:seekWidgetByNameOnNode(panel, 'money_text')
--    _money_text:setString(
--      string.format(_text.ui_charge_format, _charge_unlock[hero_id].rmb)
--    )
    
    local function close()
      self:destroy()
      tab.cb_no()
    end
    
    self.onKeyBack = close
    
    local btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
    btn:addTouchEventListener(
      _misc.createClickCB(close)
    )
    
    btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'refuse_btn')
    btn:addTouchEventListener(
      _misc.createClickCB(close)
    )

    local function pay()
        if not _charge.chargeForUnlock(hero_id) then
          return
        end
        self:destroy()--测试时候注释此处
        tab.cb_yes()--返回外部处理
        --panel:removeFromParent()
        --[[测试
        local role_name,random_speak = FindHero(hero_id)

        local _fong_text = ccui.Helper:seekWidgetByNameOnNode(panel, 'role_name')
        _fong_text:setString(role_name)

        local _fong_speak = ccui.Helper:seekWidgetByNameOnNode(panel, 'speak_frame')
        _fong_speak:setString(random_speak)

        _spr_role:setSpriteFrame("ui/heros/11001.png")
        --]]
    end

    btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_yellow')
    btn:addTouchEventListener(
      _misc.createClickCB(function()
        --此处直接接入付费
        pay()
        --[[
        local _buy_tip = require('game.ui.panel')
        local dlg = _buy_tip.Panel(
            {
                modal=true,
                ani=true,
                type_panel=_buy_tip.BUYTIPS,
                type_parent=_buy_tip.UNLOCK,
                cb_enter=pay,
                data=hero_id
            })
            --]]
      end
    ))
end



--[[使用例子
  callback可传可不传 针对邀请按钮返回外部处理
  local function callback()
    cclog("_onTestBtn  callback~~~~~~~~~~~~~~")
  end
  hero_id是英雄id 句子内部自动随机
  local tab = {hero_id = hero_id,callback = callback}
  local _panel = require('game.ui.dialogue').Dialogue(tab)
--]]


