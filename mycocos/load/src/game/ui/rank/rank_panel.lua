module('game.ui.rank.rank_panel', package.seeall)

TAKENAME      = 1    --取名界面
RANKMAIN      = 2    --排行榜主界面
RANKSELECT    = 3    --排行榜查看界面
RANKRULES     = 4    --排行榜规则说明
RANKGIFT      = 5    --排行榜奖励界面

local _base_panel = require('game.ui.basepanel').BasePanel
local _misc = require('util.misc')
local _tool   = require('util.tool')
local _mgr_scr = require('game.mgr_scr')
local _heros_data = require('data.hero').heros
local _rank_logic = require('game.ui.rank.rank_logic')
local _popupTip = require('game.mgr_scr').popupTip
local visibleSize = require('config').design
local _player = require('game.player')
local _rank_data = require('game.ui.rank.rank_data')

RankPanel = require('util.class').class(_base_panel)

local cell_id = 1--用于默认打开到第几条数据
local scrollview_offsetY = -27

local _guide_pos = {}--用于排行榜教学坐标

--取名界面
local function _TakeName(self, _cb_enter,_cb_endback)
    local panel = cc.CSLoader:createNode('ui/name.csb')

    local edit = ""


   local _public_btn_yellow = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_yellow')
   _public_btn_yellow:addTouchEventListener(
    _misc.createClickCB(
        function()
            if _rank_logic.setName(edit) then
                callback(self,_cb_enter)
            end
        end
    ))

    local name_bg = panel:getChildByName("editbox_bg")
    local config = require('config').design
    local function editboxEventHandler(eventType,_editbox)
        local text = _editbox:getText()
        if eventType == "began" then
            cclog( " began")
        elseif eventType == "changed" then
            local i=1
            local max = 20
            while (true) do
                local sub = string.sub(text,i,i)
                if sub == "" then
                    _editbox:setText(edit)
                    break
                end
                if i > max - 2 then
                    _popupTip("不超过18个字节\n中文3字节\n数字英文1个字节")
                    _editbox:setText(edit)
                    break
                end
                local ascii = string.byte(sub)
                cclog(sub .."=" ..ascii)
                if ascii>=33 and ascii<=126 then
                    if ascii >= 48 and ascii<=57 or--数字
                       ascii >= 65 and ascii<=90 or--大写英文
                       ascii >= 97 and ascii<=122 --小写英文
                    then
                        edit = string.format("%s%s",edit,sub)
                        i = i + 1
                    else
                        --非法字符
                        _popupTip("请输入中英文数字")
                        _editbox:setText("")
                        break
                    end
                else
                    --除此以外默认都是中文
                    sub = string.sub(text,i,i+2)
                    edit = string.format("%s%s",edit,sub)
                    i = i + 3
                end

                if i>max then
                    _editbox:setText(edit)
                    break
                end
            end
        elseif eventType == "ended" then
            cclog( "ended")
        elseif eventType == "return" then
            cclog( "return")
--            cclog("getMaxLength == " .._editbox:getMaxLength())
        end
    end
    local editbox = ccui.EditBox:create(cc.size(258,51), ccui.Scale9Sprite:create(), ccui.Scale9Sprite:create(), ccui.Scale9Sprite:create())
    editbox:setMaxLength(6)
    editbox:setFontSize(24)
    editbox:setPosition(name_bg:getPositionX(),name_bg:getPositionY())
   editbox:registerScriptEditBoxHandler(editboxEventHandler)
--   editbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editbox:setPlaceHolder("请输入姓名")
    panel:addChild(editbox)

    local function randname()
        local _robot = require('game.ui.rank.robot')
        if #_player.get().rank[_rank_data.NOVICE] == 0 then--未初始化机器人
            local id = _tool.randnum(1,#_robot.robot)
            edit = _robot.robot[id].name
            editbox:setText(edit)
        else
            while (true) do
                local id = _tool.randnum(1,#_robot.robot)
                for i=1,#_rank_data.ruler do
                    for j=1,#_player.get().rank[i] do
                        if _player.get().rank[i][j].name ~= _robot.robot[id] then
                            edit = _robot.robot[id].name
                            editbox:setText(edit)
                            return
                        end
                    end
                end
            end
        end
    end
    local _public_btn_green = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_green')
   _public_btn_green:addTouchEventListener(
    _misc.createClickCB(
        function()
            randname()
        end
    ))

    return panel
end
local function _createCell(node,scrollview,model,_name,v,i)
    local cell
    local path_bg
    local model_number       = ccui.Helper:seekWidgetByNameOnNode(model, 'cell_rank')
    local model_name         = ccui.Helper:seekWidgetByNameOnNode(model, 'role_name')
    local model_font_score   = ccui.Helper:seekWidgetByNameOnNode(model, 'font_score')
    local model_cell_score   = ccui.Helper:seekWidgetByNameOnNode(model, 'cell_score')
    if v.name == _name then
        path_bg = "ui/rank/bar_2.png"
        cell_id =  _player.get().rank.info.number
        --cclog("_createCell ================= " ..i)
    else
        path_bg = "ui/rank/bar_3.png"
    end
    cell = cc.Sprite:createWithSpriteFrameName(path_bg)
    cell:setAnchorPoint(cc.p(0.5,1))
    cell:setPosition(cc.p(scrollview:getInnerContainerSize().width/2,scrollview:getInnerContainerSize().height-(i-1)-cell:getContentSize().height*(i-1)))
    node:addChild(cell)

    local number_laber = cc.Label:createWithBMFont("ui/rank_num.fnt",tostring(v.number))
    local name_label = cc.Label:createWithSystemFont(v.name, '', 24)
    name_label:setColor({r=0,g=166,b=240})
    local font_score = cc.Sprite:createWithSpriteFrameName("ui/rank/score.png")
    local cell_score = cc.Label:createWithBMFont("ui/battle_tip.fnt",tostring(v.score))

    number_laber:setPosition(cc.p(model_number:getPosition()))
    name_label:setPosition(cc.p(model_name:getPosition()))
    font_score:setPosition(cc.p(model_font_score:getPosition()))
    cell_score:setPosition(cc.p(model_cell_score:getPosition()))

    cell:addChild(number_laber)
    cell:addChild(name_label)
    cell:addChild(font_score)
    cell:addChild(cell_score)
    return cell
end
local function _createScrollview(panel)
    local scrollviewlist  = {}
    local show            = 5--可显示数据数量
    local _rank_type      = _player.get().rank.info.rank_type or _rank_data.NOVICE
    local _name           = _player.get().rank.info.name
    local num             = #_rank_logic.rank[_rank_type]
    local scrollview      = ccui.Helper:seekWidgetByNameOnNode(panel,"ScrollView_1")
    local model           = panel:getChildByName('cell_data')--模板(用于位置定位)
    model:setVisible(false)
    scrollview:setInnerContainerSize(cc.size(model:getContentSize().width,(num+1)*model:getContentSize().height+scrollview_offsetY))
    
    local node = cc.Layer:create()
    for i,v in ipairs(_rank_logic.rank[_rank_type]) do
        local cell = _createCell(node,scrollview,model,_name,v,i)
        table.insert(scrollviewlist, i,cell)
    end
    --scrollview:setBounceEnabled(true)
    --scrollview:setInertiaScrollEnabled(true)
    --percent = percent > 0 and percent or 1


    if cell_id == 1 then 
        --scrollview:jumpToTop()
    elseif cell_id > (num - show) then
        scrollview:scrollToPercentVertical(100,0,false)
    else
        local percent = (cell_id-1)/(num-show)*100
        scrollview:scrollToPercentVertical(percent,0,false)--0~100,time,滚动动画
    end

    
--   scrollview:addTouchEventListener(function(object, event)
--            if event == ccui.TouchEventType.ended then
----                cclog("****************************************************************")
----                cclog("X ============= " ..scrollview:getInnerContainer():getPositionX())
----                cclog("Y ============= " ..scrollview:getInnerContainer():getPositionY())
--                --setGuide(cell_id,scrollview,num,show,model)
--            end
--    end)


    local function callback(obj,eventType)
        --cclog("eventType == " ..tostring(eventType))
        
        --拖动中
        if eventType == ccui.ScrollviewEventType.scrolling then
--            cclog("****************************************************************")
--            cclog("X ============= " ..scrollview:getInnerContainer():getPositionX())
--            cclog("Y ============= " ..scrollview:getInnerContainer():getPositionY())
        --手指往下拉到底后反弹置顶
        elseif eventType == ccui.ScrollviewEventType.bounceTop then
            cclog("ccui.ScrollviewEventType.bounceTop == " ..tostring(ccui.ScrollviewEventType.bounceTop))
        
        --手指往上拉到底后反弹置底
        elseif eventType == ccui.ScrollviewEventType.bounceBottom then
            cclog("ccui.ScrollviewEventType.bounceBottom == " ..tostring(ccui.ScrollviewEventType.bounceBottom))
       
        --手指往下拉到底后调用(若到底了还往下拉则不断被调用)
        elseif eventType == ccui.ScrollviewEventType.scrollToTop then
            cclog("ccui.ScrollviewEventType.scrollToTop == " ..tostring(ccui.ScrollviewEventType.scrollToTop))
       
        --手指往上拉到顶后调用(若到顶了还上拉则不断被调用)
        elseif eventType == ccui.ScrollviewEventType.scrollToBottom then
            cclog("ccui.ScrollviewEventType.scrollToBottom == " ..tostring(ccui.ScrollviewEventType.scrollToBottom))
        end
    end
    scrollview:addEventListener(callback)
    scrollview:setSwallowTouches(true)--这里要设置 不然如果点击稍微快一点就会被父面启动瞬间截获滚动消息
    scrollview:addChild(node)
    
    return function()
      setGuide(panel, cell_id, scrollview, num, show, model)
    end
end

local function _viewRule()
    --callback(self,_cb_enter)
    local rank_panel = require('game.ui.rank.rank_panel')
    local dlg = rank_panel.RankPanel(
    {
        modal=true,
        ani=true,
        type_panel=rank_panel.RANKSELECT
    })
end
        
--排行榜主界面
local function _RankMain(self,_cb_enter,_cb_endback)
    local panel = cc.CSLoader:createNode('ui/rank_main.csb')

    local _public_btn_green = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
   _public_btn_green:addTouchEventListener(
    _misc.createClickCB(
        function()
            callback(self,_cb_endback)
        end
    ))

   local _check_rules = ccui.Helper:seekWidgetByNameOnNode(panel, 'check_rules')
   _check_rules:addTouchEventListener(
      _misc.createClickCB(_viewRule) )

    --外部刷新排行榜数据 进来直接显示
    local post_func = _createScrollview(panel)
    local _rank_type      = _player.get().rank.info.rank_type or _rank_data.NOVICE
    panel:getChildByName("icon_group"):setSpriteFrame(_rank_data.icon[_rank_type].path)
    ccui.Helper:seekWidgetByNameOnNode(panel, 'group_font_1'):setString(_rank_data.icon[_rank_type].name)
    local _tips = panel:getChildByName("tips")
    if _player.get().rank.info.number then
        _tips:setString(string.format("当前排名%d,可领取金币x%d",_player.get().rank.info.number,_player.get().rank.info.gold))
    else
        _tips:setVisible(false) 
    end

    --是否显示排行榜
--    if _rank_logic.checkUpdate() then
--        _popupTip("显示排行榜")
--        _createScrollview(panel)
--        local _rank_type      = _player.get().rank.info.rank_type or _rank_data.NOVICE
--        panel:getChildByName("icon_group"):setSpriteFrame(_rank_data.icon[_rank_type].path)
--        ccui.Helper:seekWidgetByNameOnNode(panel, 'group_font_1'):setString(_rank_data.icon[_rank_type].name)
--        local _tips = panel:getChildByName("tips")
--        if _player.get().rank.info.number then
--            _tips:setString(string.format("当前排名%d,可领取金币x%d",_player.get().rank.info.number,_player.get().rank.info.gold))
--        else
--            _tips:setVisible(false) 
--        end
--    else
--         _popupTip("不显示排行榜")
--    end



    return panel, post_func
end
--查询各组规则
local function _SelectGroup(panel,group)
    local _select_group = ccui.Helper:seekWidgetByNameOnNode(panel, 'select_group')
    _select_group:setString(_rank_data.icon[group].name)
    for i=1,8 do
        local _cell_data  = panel:getChildByName(string.format("cell_data_%d",i))
        local _cell_rank  = ccui.Helper:seekWidgetByNameOnNode(_cell_data, string.format("cell_rank_%d",i))
        local _cell_score = ccui.Helper:seekWidgetByNameOnNode(_cell_data, string.format("cell_score_%d",i))
        local _cell_group = ccui.Helper:seekWidgetByNameOnNode(_cell_data, string.format("cell_group_%d",i))
        --local _icon_money = _cell_data:getChildByName(string.format("icon_money_%d",i))
        local _icon_group = _cell_data:getChildByName(string.format("icon_group_%d",i))

        local max = _rank_data.ruler[group][i].rank_max
        local min = _rank_data.ruler[group][i].rank_min
        local font_number
        if max - min > 0 then
            font_number = string.format("%d~%d",min,max)
        else
            font_number = max
        end
        
        if _rank_data.ruler[group][i].group == _rank_data.GROUP_UP then
            _cell_group:setVisible(true)
            _icon_group:setVisible(true)
            _icon_group:setSpriteFrame("ui/rank/arrow_up.png")
            _cell_group:setString("升组")
        elseif _rank_data.ruler[group][i].group == _rank_data.GROUP_DOWN then
            _cell_group:setVisible(true)
            _icon_group:setVisible(true)
            _icon_group:setSpriteFrame("ui/rank/arrow_down.png")
            _cell_group:setString("降组")
        else
            _cell_group:setVisible(false)
            _icon_group:setVisible(false)
        end

        _cell_rank:setString(font_number)
        _cell_score:setString(tostring(_rank_data.ruler[group][i].gold))
    end

    

end
--排行榜查看界面
local function _RankSelect(self, _cb_enter,_cb_endback)
    local panel = cc.CSLoader:createNode('ui/rank_select.csb')

    local _public_btn_green = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
   _public_btn_green:addTouchEventListener(
    _misc.createClickCB(
        function()
            callback(self,_cb_endback)
        end
    ))

    local _btn_rules = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_rules')
   _btn_rules:addTouchEventListener(
    _misc.createClickCB(
        function()
            --callback(self,_cb_endback)
            local rank_panel = require('game.ui.rank.rank_panel')
            local dlg = rank_panel.RankPanel(
            {
                modal=true,
                ani=true,
                type_panel=rank_panel.RANKRULES
            })
        end
    ))

    local btn_group = "btn_%d"
    for i=1,6 do
        local _btn = ccui.Helper:seekWidgetByNameOnNode(panel, string.format(btn_group,i))
        _btn:addTouchEventListener(
        _misc.createClickCB(
            function()
                _SelectGroup(panel,i)
            end
        ))
    end

    local _rank_type = _player.get().rank.info.rank_type or _rank_data.NOVICE
    local _cur_group = ccui.Helper:seekWidgetByNameOnNode(panel, 'cur_group')
    _cur_group:setString(_rank_data.icon[_rank_type].name)
    _SelectGroup(panel,_rank_type)

    return panel
end
--排行榜查看界面
local function _RankRules(self, _cb_enter,_cb_endback)
    local panel = cc.CSLoader:createNode('ui/rank_rules.csb')

    local _public_btn_green = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
   _public_btn_green:addTouchEventListener(
    _misc.createClickCB(
        function()
            callback(self,_cb_endback)
        end
    ))

    return panel
end
--排行榜奖励界面
local function _RankGift(self, _cb_enter,_cb_endback)
    local panel = cc.CSLoader:createNode('ui/rank_gift.csb')

    local unlock_id
    local _public_btn_green = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
   _public_btn_green:addTouchEventListener(
    _misc.createClickCB(
        function()
            callback(self,_cb_endback)
        end
    ))

    local _public_btn_yellow = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_yellow')
   _public_btn_yellow:addTouchEventListener(
    _misc.createClickCB(
        function()
            _rank_logic.getGift(unlock_id)
            callback(self,_cb_enter)
        end
    ))
    
    
    
    local _rank_type = _player.get().rank.gift.rank_type or _rank_data.NOVICE

    local _cur_group = ccui.Helper:seekWidgetByNameOnNode(panel, 'cur_group')
    local _cur_number = ccui.Helper:seekWidgetByNameOnNode(panel, 'cur_number')
    local _gold_num = ccui.Helper:seekWidgetByNameOnNode(panel, 'gold_num')
    local _hero_name = ccui.Helper:seekWidgetByNameOnNode(panel, 'hero_name')
    local _icon_gold = panel:getChildByName("icon_gold")--ccui.Helper:seekWidgetByNameOnNode(panel, 'icon_gold')
    local hero_id = 13001
    local is_unlock
    if _rank_type >= _rank_data.GOLD and not _player.get().heros_unlock[hero_id] then--针对斧手做奖励处理(暂时先写死)
        unlock_id = hero_id
        is_unlock = false
        
        _icon_gold:setSpriteFrame("ui/heros/13001.png")
        
        _hero_name:setString("解锁" .._heros_data[hero_id].name)
    else
        is_unlock = true
        _icon_gold:setSpriteFrame("ui/sign/gold.png")
        _cur_group:setString(_rank_data.icon[_rank_type].name)

        local _number = _player.get().rank.gift.number or 50
        _cur_number:setString(string.format("第%d名",_number))

        local _gold = _player.get().rank.gift.gold or 999999
        _gold_num:setString(string.format("%d",_gold))
    end
    _cur_group:setVisible(is_unlock)
    _cur_number:setVisible(is_unlock)
    _gold_num:setVisible(is_unlock)
    _hero_name:setVisible(not is_unlock)

    return panel
end
local function _onEnter(self,_cb_enter,_cb_endback,_type_panel)
   if _type_panel == TAKENAME then
      return _TakeName(self, _cb_enter,_cb_endback)
   elseif _type_panel == RANKMAIN then
      --if _rank_logic.checkUpdate() then--刷新一下排行榜（结算的时候占用时间去刷新）
          if _player.get().rank.gift.isget == _rank_data.GIFT_GET then
            return _RankGift(self, _cb_enter,_cb_endback)
          else
            return _RankMain(self, _cb_enter,_cb_endback)
          end
      --end
   elseif _type_panel == RANKSELECT then
      return _RankSelect(self, _cb_enter,_cb_endback)
   elseif _type_panel == RANKRULES then
      return _RankRules(self, _cb_enter,_cb_endback)
   elseif _type_panel == RANKGIFT then
      return _RankGift(self, _cb_enter,_cb_endback)
   end
end
--[[
tab={
  modal=true|false 是否模态
  ani=true|false  是否弹出效果
}
]]
RankPanel.ctor = function(self,tab)
    local _type_panel   = tab.type_panel
    local _cb_enter     = tab.cb_enter
    local _cb_endback   = tab.endback
    
    local panel, post_func = _onEnter(self,_cb_enter,_cb_endback,_type_panel)
    
   self.__super_ctor__(self, panel, tab.modal, tab.ani)
   if post_func then
     post_func()
   end
end
function callback(self,cb_back)
    self:destroy()
    if type(cb_back) == "function" then
        cb_back()
    end
end
function setGuide(panel,cell_id,scrollview,num,show,model)
--    cclog("****************************************************************")

    local _pos = cc.p(scrollview:getPosition())
    if cell_id <= num-show+1 then
        _pos.y = _pos.y + scrollview:getContentSize().height
    elseif cell_id == num then
        _pos.y = _pos.y + (num - cell_id + 1)*model:getContentSize().height- model:getContentSize().height
    else
        _pos.y = _pos.y + (num - cell_id + 1)*model:getContentSize().height
    end
--    cclog("pos.x = " .._pos.x)
--    cclog("pos.y = " .._pos.y)

    --TODO: 框放大了120%，暂这样
    local gui_rect = cc.rect(_pos.x,_pos.y,
      model:getContentSize().width*1.2,
      model:getContentSize().height*1.2)
    
    local guide = require('game.guide_logic')
    local function _checkRank2()
      local r = ccui.Helper:seekWidgetByNameOnNode(panel, 'check_rules')
      guide.checkRank2Guide(2, r, _viewRule)
    end
    if not guide.checkRank1Guide(2, gui_rect, _checkRank2) then
      _checkRank2()
    end
end

