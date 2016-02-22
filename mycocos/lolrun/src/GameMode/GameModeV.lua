local GameModeView=
{
    mainLayer   = nil,  --本图层
    panel_mode  = nil, 
    isOpened       = true ,  --本图层是否开启
    readyMeta      = nil,
    panel_mine  = nil ,      --矿洞图层
}--@ 游戏逻辑主图层
local meta = GameModeView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameModeModel = require "src/GameMode/GameModeM"

function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createMode()
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createMode()
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/game_mode/game_mode.ExportJson")
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_mode.ExportJson")
    --uiLayout:setPosition(g_origin.x,g_origin.y)

    meta.panel_mode = uiLayout:getChildByName("Panel_mode")     --战役选择界面
    meta.panel_mine = uiLayout:getChildByName("Panel_mine")     --矿洞难度选择界面

    local button_back = meta.panel_mode:getChildByName("Button_back")
    local button_mode_1 = meta.panel_mode:getChildByName("Button_mode_1") --模式选择按钮1--矿洞

    local button_mine = meta.panel_mine:getChildByName("Button_mine")
    local button_mineBack = meta.panel_mine:getChildByName("Button_mineBack")
    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
           print(touch:getName())
           meta.remove()
       end 
    end 
    
    --战役界面  跳  难度选择界面
    local function modeToHardEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then 
           print(touch:getName())
           meta.panel_mine:setVisible(true)
           meta.panel_mode:setVisible(false)
       end 
    end

    --难度返回到模式界面（战役界面）
    local function hardToModeEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then 
           print(touch:getName())
           meta.panel_mine:setVisible(false)
           meta.panel_mode:setVisible(true)
       end 
    end

    --添加监听
    button_back:addTouchEventListener(backEvent)
    button_mode_1:addTouchEventListener(modeToHardEvent)
    button_mineBack:addTouchEventListener(hardToModeEvent)
    meta.mainLayer:addChild(uiLayout)
end 

--删除 主图层 函数
function meta:remove()
    meta.readyMeta:setModeFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

return GameModeView
