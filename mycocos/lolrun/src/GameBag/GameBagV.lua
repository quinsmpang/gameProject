local GameBagView=
{
    mainLayer = nil,  --本图层
    panel_bag = nil,
    isOpened       = true ,  --本图层是否开启
    readyMeta      = nil, 
    panel_synthetic = nil, --合成界面
}--@ 游戏逻辑主图层
local meta = GameBagView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameBagModel = require "src/GameBag/GameBagM"

function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createBag()
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createBag()
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/game_bag/game_bag.ExportJson")
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_bag.ExportJson")
    --uiLayout:setPosition(g_origin.x,g_origin.y)
    meta.panel_bag             = uiLayout:getChildByName("Panel_bag")
    local panel_cover          = meta.panel_bag:getChildByName("Panel_cover")
    local button_back          = meta.panel_bag:getChildByName("Button_back")
    local button_bagAll        = meta.panel_bag:getChildByName("Button_bagAll")
    local button_bagEquip      = meta.panel_bag:getChildByName("Button_bagEquip")
    local button_bagItem       = meta.panel_bag:getChildByName("Button_bagItem")
    local button_bagFragment   = meta.panel_bag:getChildByName("Button_bagFragment")
    local button_bagHandbook   = meta.panel_bag:getChildByName("Button_bagHandbook") 
    
    --刚进背包显示的“全部”面板
    button_bagAll:setTouchEnabled(false)
    button_bagAll:setBright(false)

    --重置背包左边按钮的状态
    local function bagReset()
        button_bagAll:setTouchEnabled(true)
        button_bagEquip:setTouchEnabled(true)
        button_bagItem:setTouchEnabled(true)
        button_bagFragment:setTouchEnabled(true)
        button_bagHandbook:setTouchEnabled(true)
        button_bagAll:setBright(true)
        button_bagEquip:setBright(true)
        button_bagItem:setBright(true)
        button_bagFragment:setBright(true)
        button_bagHandbook:setBright(true)
    end 

    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then 
          print("a")
           meta.remove() 
            --touch:setLocalZOrder(2)
        end
    end 

    --左列 按钮触发事件
    local function toBagPanelEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then 
            bagReset()
            touch:setTouchEnabled(false)
            touch:setBright(false)
            --touch:setLocalZOrder(20)
            local touchName = touch:getName()
            if touchName == "Button_bagAll" then
                --显示背包“全部”面板
                print("AllPanel")
            elseif touchName == "Button_bagEquip" then
                --显示背包“装备”面板
                print("EquipPanel") 
            elseif touchName == "Button_bagItem"  then
                --显示背包“道具”面板
                print("ItemPanel") 
            elseif touchName == "Button_bagFragment" then
                --显示背包“英雄碎片”面板
                print("FragmentPanel")
            elseif touchName == "Button_bagHandbook" then
                --显示背包“图鉴”面板
                print("HandbookPanel")
            end 
        elseif eventType == ccui.TouchEventType.began then 
            touch:setLocalZOrder(20)
        elseif eventType == ccui.TouchEventType.canceled then 
            touch:setLocalZOrder(2)
        end 
    end 

    --添加监听
    button_back:addTouchEventListener(backEvent)
    button_bagAll:addTouchEventListener(toBagPanelEvent)
    button_bagEquip:addTouchEventListener(toBagPanelEvent)
    button_bagItem:addTouchEventListener(toBagPanelEvent)
    button_bagFragment:addTouchEventListener(toBagPanelEvent)
    button_bagHandbook:addTouchEventListener(toBagPanelEvent)
    meta.mainLayer:addChild(uiLayout)
end 

--删除 主图层 函数
function meta:remove()
    meta.readyMeta:setBagFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

return GameBagView
