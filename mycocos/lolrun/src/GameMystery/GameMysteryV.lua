local GameMysteryView=
{
    mainLayer   = nil,     --本图层
    panel_mystery  = nil,  --商城图层
    isOpened       = true ,--本图层是否开启
    readyMeta      = nil,
}--@ 游戏逻辑主图层
local meta = GameMysteryView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameMysteryModel = require "src/GameMystery/GameMysteryM"
local GameDiamondView    =   require "src/GameDiamond/GameDiamondV"      
function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createMystery()
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createMystery()
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_mystery.ExportJson")
    --uiLayout:setPosition(g_origin.x,g_origin.y)

    meta.panel_mystery = uiLayout:getChildByName("Panel_mystery")
    local button_back          = meta.panel_mystery:getChildByName("Button_back")
    local button_diamond       = meta.panel_mystery:getChildByName("Button_diamond")
    local button_recommend     = meta.panel_mystery:getChildByName("Button_recommend")
    local button_hero          = meta.panel_mystery:getChildByName("Button_hero")
    local button_pet           = meta.panel_mystery:getChildByName("Button_pet")
    local button_guy           = meta.panel_mystery:getChildByName("Button_guy")
    local button_item          = meta.panel_mystery:getChildByName("Button_item")



    --刚进商城显示的“商城”面板
    button_hero:setTouchEnabled(false)
    button_hero:setBright(false)

     --重置商城左边按钮的状态
    local function mysteryReset()    
        --button_diamond:setTouchEnabled(true)  
        button_recommend:setTouchEnabled(true)
        button_hero:setTouchEnabled(true)     
        button_pet:setTouchEnabled(true)      
        button_guy:setTouchEnabled(true)      
        button_item:setTouchEnabled(true)  
         
        --button_diamond:setBright(true)  
        button_recommend:setBright(true)
        button_hero:setBright(true)     
        button_pet:setBright(true)      
        button_guy:setBright(true)      
        button_item:setBright(true)
    end 

    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then 
           print(touch:getName())
           meta:remove()
       end 
    end 
    
    --左侧 按钮触发事件
    local function toMysteryPanelEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then 
            mysteryReset()
            touch:setTouchEnabled(false)
            touch:setBright(false)
            --touch:setLocalZOrder(20)
            local touchName = touch:getName()
            if touchName == "Button_diamond" then
                --显示商城“购买钻石”面板
                print("DiamondPanel")
            elseif touchName == "Button_recommend" then
                --显示商城“推荐”面板
                print("RecommendPanel") 
            elseif touchName == "Button_hero"  then
                --显示商城“英雄”面板
                print("HeroPanel") 
            elseif touchName == "Button_pet" then
                --显示商城“宠物”面板
                print("PetPanel")
            elseif touchName == "Button_guy" then
                --显示商城“小伙伴”面板
                print("GuyPanel")
            elseif touchName == "Button_item" then
                --显示商城“道具”面板
                print("ItemPanel")
            end 
        elseif eventType == ccui.TouchEventType.began then 
            --touch:setLocalZOrder(20)
        elseif eventType == ccui.TouchEventType.canceled then 
            --touch:setLocalZOrder(2)
        end 
    end 

    local function mysteryToDiamondEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then 
            local layerParent = meta.mainLayer:getParent()
            meta.mainLayer:removeFromParent()
            GameDiamondView:getGameGuideMeta(meta.readyMeta)
            meta.readyMeta:setDiamondState(true)
            layerParent:addChild(GameDiamondView:init())
        end 
    end 

    --添加监听
    button_back:addTouchEventListener(backEvent)
    button_diamond:addTouchEventListener(mysteryToDiamondEvent)  
    button_recommend:addTouchEventListener(toMysteryPanelEvent)
    button_hero:addTouchEventListener(toMysteryPanelEvent)     
    button_pet:addTouchEventListener(toMysteryPanelEvent)      
    button_guy:addTouchEventListener(toMysteryPanelEvent)      
    button_item:addTouchEventListener(toMysteryPanelEvent)
    meta.mainLayer:addChild(uiLayout)
end 

--删除 主图层 函数
function meta:remove()
    meta.readyMeta:setMysteryFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

return GameMysteryView
