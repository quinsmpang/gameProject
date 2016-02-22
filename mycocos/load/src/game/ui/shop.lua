module('game.ui.shop', package.seeall)

local _misc = require('util.misc')
local _popupTip = require('game.mgr_scr').popupTip
local _text = require('data.text')
local _panel = require('game.ui.panel')

local _panel_list = {
    {name_panel="gift_pk", type_panel=_panel.CHALLENGE},--{name_panel="gift_login", type_panel=_panel.LOGIN},
    {name_panel="gift_guide", type_panel=_panel.GUIDE},
    {name_panel="gift_item", type_panel=_panel.REWARD},
    {name_panel="gift_thank", type_panel=_panel.THANK},
    {name_panel="gift_gold", type_panel=_panel.GOLD}
}

local function _createGift(type_panel)
  return function()
    local dlg = _panel.Panel{
      modal=true,
      ani=true,
      type_panel=type_panel,
      cb_enter=function()
        _popupTip(_text.shop)
      end,
      endback=nil
    }

  end  
end

function create(cb_return)
  local shop = cc.CSLoader:createNode('ui/shop.csb')

  local action = cc.CSLoader:createTimeline('ui/shop.csb')
  shop:runAction(action)
  action:gotoFrameAndPlay(0,true)

  for j,gift in pairs(_panel_list) do
     local _p = ccui.Helper:seekWidgetByNameOnNode(shop,gift.name_panel)
      _p:addTouchEventListener(
        _misc.createClickCB(
          _createGift(gift.type_panel)
        )
      )
  end

  local btn = ccui.Helper:seekWidgetByNameOnNode(shop, 'btn_return')
  btn:addTouchEventListener(
    _misc.createClickCB(cb_return)
  )

  return {
    node=shop,
    block_bottom=true,
    pop_effect=true,
    reposition_center=true,
    onKeyBack=cb_return,
  }
end
