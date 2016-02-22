module('game.ui.miracle', package.seeall)

local _base_panel = require('game.ui.basepanel').BasePanel
local _misc = require('util.misc')
local _player = require('game.player')
local _miracle_sdata = require('data.miracle').data

--[[
其它地方也用到数据，故将一部分其移到 data.miracle。
剩下的合并到这里了。。。
]]

Panel = require('util.class').class(_base_panel)


local sf      = string.format


--[[config
    id         --- 编号
    desc       --- 描述文字的格式
    pic        --- icon图片
    scale      --- 图片缩放值
]]
local _ui_data = {
  {
    id = 1,
    desc = [[
  贪婪-等级%d
获得金币加成%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/miracle/icon_money.png",
    scale = 1
  },
  {
    id = 2,
    desc = [[
  分数-等级%d
获得游戏加成%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/miracle/icon_score.png",
    scale = 1
  },
  {
    id = 3,
    desc = [[
   炸弹-等级%d
炸弹道具的威力加成%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/battle/icon_bomb.png",
    scale = 1
  },
  {
    id = 4,
    desc = [[
   无敌-等级%d
无敌道具的时间加成%.1f秒
  (每级增加%.1f秒)]],
    cost = '花费:',
    pic = "ui/battle/icon_invincible.png",
    scale = 1
  },
  {
    id = 5,
    desc = [[
   冲刺-等级%d
冲刺道具的时间加成%.1f秒
  (每级增加%.1f秒)]],
    cost = '花费:',
    pic = "ui/battle/icon_rush.png",
    scale = 1
  },
  {
    id = 6,
    desc = [[
   剑士-等级%d
提升剑士的攻击力%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/heros/18001.png",
    scale = 0.6
  },
  {
    id = 7,
    desc = [[
   弓手-等级%d
提升弓手的攻击力%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/heros/14001.png",
    scale = 0.6
  },
  {
    id = 8,
    desc = [[
   法师-等级%d
提升法师的攻击力%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/heros/17001.png",
    scale = 0.6,
    px = -10
  },
  {
    id = 9,
    desc = [[
   绿巨人-等级%d
提升绿巨人的攻击力%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/heros/19001.png",
    scale = 0.6
  },
  {
    id = 10,
    desc = [[
   斧手-等级%d
提升斧手的攻击力%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/heros/15001.png",
    scale = 0.7,
    px = -5
  },
  {
    id = 11,
    desc = [[
   守护者-等级%d
提升守护者的攻击力%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/heros/10003.png",
    scale = 0.6,
    px = 5
  },
  {
    id = 12,
    desc = [[
   蚁人-等级%d
提升蚁人的攻击力%d%%
  (每级增加%d%%)]],
    cost = '花费:',
    pic = "ui/heros/10005.png",
    scale = 0.6,
    px = 0
  },
} --_ui_data

local function _buff(pdata, sdata)
  return pdata.level * sdata.buff_level
end

local function _levelUpCost(pdata, sdata)
  local cost
  local lv = pdata.level
  if lv < sdata.max_level then
    cost = sdata.levelup_gold_base * (lv+1)
  else
    cost = 0
  end
  return cost
end

local function _doLevelUp(self, list_item, index)
  local ud = _player.get()
  local pdata = ud.miracle[index]
  local sdata = _miracle_sdata[index]
  
  if pdata.level >= sdata.max_level then
    return false
  end
  
  local cost = _levelUpCost(pdata, sdata)
  if ud.golds < cost then
    local panel = require('game.ui.panel')
    panel.Panel{
      modal=true,
      ani=true,
      type_panel=panel.GOLD
    }
    return false
  end

  ud.golds = ud.golds - cost
  pdata.level = pdata.level + 1
  _player.setDirty()
  _player.save()
  return true
end

----------------
local function _resetOneItem(self, list_item, index)
  local sdata = _miracle_sdata[index]
  local ui_data = _ui_data[index]
  local pdata = _player.get().miracle[index]
  
  local pic = list_item:getChildByName('icon_pic')
  pic:loadTexture(ui_data.pic, ccui.TextureResType.plistType)
  pic:setScale(ui_data.scale)
  if ui_data.px then--偏移
    pic:setPositionX(pic:getPositionX()+ui_data.px)
  end
  
  local desc = list_item:getChildByName('font_value')
  desc:setString( 
    string.format(ui_data.desc,
      pdata.level,
      _buff(pdata, sdata),
      sdata.buff_level
  ) )
  
  list_item:getChildByName('font_cost'):setString(ui_data.cost)
  local cost = list_item:getChildByName('cost_gold')
  cost:setString( 
    string.format('%d', _levelUpCost(pdata,sdata))
  )
  
  local btn = list_item:getChildByName('btn_uplevel')
  --local btn_font = list_item:getChildByName('font_btn')
  if pdata.level < sdata.max_level then
    btn:setBright(true)
    btn:setEnabled(true)
--    btn_font:loadTexture('ui/miracle/font_uplevel.png', ccui.TextureResType.plistType)
    btn:setTitleText("升级")
  else
    btn:setBright(false)
    btn:setEnabled(false)
--    btn_font:loadTexture('ui/miracle/font_max.png', ccui.TextureResType.plistType)
    btn:setTitleText("满级")
  end
  --仅是方便。。。
--  list_item:addTouchEventListener(function(object, event)
--        if event == ccui.TouchEventType.began then
--            local s = self._list:getInnerContainer():getPositionY()
--            cclog("began == " ..s)
--        elseif event == ccui.TouchEventType.ended then
--            local s = self._list:getInnerContainer():getPositionY()
--            cclog("ended == " ..s)
--        elseif event == ccui.TouchEventType.moved then
--            local s = self._list:getInnerContainer():getPositionY()
--            cclog("moved == " ..s)
--        end
--    end)

  return btn
end

local function _resetMyGold(self)
  self._my_gold:setString(
    string.format('%dG', _player.get().golds) )
  self._font_yy:setPositionX(self._my_gold:getPositionX()-self._my_gold:getLayoutSize().width - self._font_yy:getContentSize().width/2 )
end

local function _load(self, _cb_endback)
  local panel = cc.CSLoader:createNode('ui/miracle.csb')

  local list = ccui.Helper:seekWidgetByNameOnNode(panel, 'list_view')
  self._list = list
  
  local cell = ccui.Helper:seekWidgetByNameOnNode(panel, 'cell_data')
  list:setItemModel(cell)
  cell:removeFromParent()

--  local function callback(obj,eventType)
--        --cclog("eventType == " ..tostring(eventType))

--        --拖动中
--        if eventType == ccui.ScrollviewEventType.scrolling then
--            cclog("ccui.ScrollviewEventType.scrolling == " ..tostring(ccui.ScrollviewEventType.scrolling))
--        --手指往下拉到底后反弹置顶
--        elseif eventType == ccui.ScrollviewEventType.bounceTop then
--            cclog("ccui.ScrollviewEventType.bounceTop == " ..tostring(ccui.ScrollviewEventType.bounceTop))

--        --手指往上拉到底后反弹置底
--        elseif eventType == ccui.ScrollviewEventType.bounceBottom then
--            cclog("ccui.ScrollviewEventType.bounceBottom == " ..tostring(ccui.ScrollviewEventType.bounceBottom))

--        --手指往下拉到底后调用(若到底了还往下拉则不断被调用)
--        elseif eventType == ccui.ScrollviewEventType.scrollToTop then
--            cclog("ccui.ScrollviewEventType.scrollToTop == " ..tostring(ccui.ScrollviewEventType.scrollToTop))

--        --手指往上拉到顶后调用(若到顶了还上拉则不断被调用)
--        elseif eventType == ccui.ScrollviewEventType.scrollToBottom then
--            cclog("ccui.ScrollviewEventType.scrollToBottom == " ..tostring(ccui.ScrollviewEventType.scrollToBottom))
--        end
--    end
--  list:addEventListener(callback)
--    list:scrollToPercentVertical(0.5,0,false)
    
  local btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
  btn:addTouchEventListener(
    _misc.createClickCB(
      function()
        self:destroy()
        _cb_endback()
      end
  ))

  self._my_gold = ccui.Helper:seekWidgetByNameOnNode(panel, 'my_gold')
  self._font_yy = ccui.Helper:seekWidgetByNameOnNode(panel, 'font_yy')
  return panel
end

--[[
tab={
  modal=true|false 是否模态
  ani=true|false  是否弹出效果
  cb_endback=function()end 退出回调
}
]]
Panel.ctor = function(self, tab)
  local panel = _load(self, tab.cb_endback)
  --self._list
  --self._my_gold
  self._panel = panel
  self.__super_ctor__(self, panel, tab.modal, tab.ani)
end

Panel.inst_meta.onEnter = function(self)
  local list = self._list
  for i,ui in ipairs(_ui_data) do
    --list以0作为开始索引
    list:insertDefaultItem(i-1)
    local item = list:getItem(i-1)
    local btn = _resetOneItem(self, item, i)
    btn:addTouchEventListener(
      _misc.createClickCB(function()
        if _doLevelUp(self, item, i) then
          _resetOneItem(self, item, i)
          _resetMyGold(self)
        end
      end 
    ) )
  end
  _resetMyGold(self)
  
  --取第一项引导
  local item = list:getItem(0)
  if item then
    require('game.guide_logic').checkMiracleGuide(
      2,
      self._panel,
      item:getChildByName('btn_uplevel'), 
      function() end)
  end
end

---
function check(info)
  local dirty = false

  if type(info) ~= 'table' then
      info, dirty = {}, true
  end

  for i,sdata in ipairs(_miracle_sdata) do
    local t = info[i]
    if type(t) ~= 'table' then
      t = {}
      info[i], dirty = t, true
    end
    local lv = t.level
    if type(lv)~='number' or lv<0 or lv>sdata.max_level then
        t.level, dirty = 0, true
    end
  end
  return info, dirty
end
