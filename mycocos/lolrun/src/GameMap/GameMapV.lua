local GameMapView=
{
    mainLayer      = nil,  --本图层
    panel_map  = nil,  --章节界面
    gameGuideDir   = nil,  --准备界面GameGuideV的导演层
    starSch        = nil,  --准备界面流星定时器
    isOpened       = true ,  --本图层是否开启
    readyMeta      = nil,
}--@ 游戏逻辑主图层
local meta = GameMapView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameMapModel = require "src/GameMap/GameMapM"

function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createMap()
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createMap()
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_map.ExportJson")
    --uiLayout:setPosition(g_origin.x,g_origin.y)

    meta.panel_map = uiLayout:getChildByName("Panel_map")
    local button_back = meta.panel_map:getChildByName("Button_back")
    --local button_map_1 = meta.panel_map:getChildByName("Button_map_1")
    local listView = meta.panel_map:getChildByName("ListView_55")
    local image_95  = listView:getChildByName("Image_92")
    local button_160 = image_95:getChildByName("Button_160")
    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then 
           print(touch:getName())
           --meta.mainLayer:removeFromParent()
           meta:remove()
       end 
    end 
    
    ----章节界面
    --local function toMapEvent(touch,eventType)
    --    if eventType == ccui.TouchEventType.ended then 
    --       print(touch:getName())
    --       local panel_ready = meta.mainLayer:getParent()
    --       local panel_readyParent = panel_ready:getParent()
    --       panel_ready:removeFromParent()
    --       local mapLayer = require "src/MapGuide/GuideV" 
    --       --进去地图前，关闭准备界面上的定时器
    --       --meta.gameGuideDir:unscheduleScriptEntry(meta.starSch)
    --       panel_readyParent:addChild(mapLayer:init())
    --   end 
    --end 

    local function gotoPlay(touch,eventType)
        if eventType == ccui.TouchEventType.ended then 
            print("a")
            local loading = require "src/GameLoad/GameLoadS"--loading
            if cc.Director:getInstance():getRunningScene() then
		        cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,loading:initFigthingRes()))
	        else
                cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,loading:initFigthingRes()))
	        end
        end 
    end 

    --添加监听
    button_back:addTouchEventListener(backEvent)
    --button_map_1:addTouchEventListener(toMapEvent)
    button_160:addTouchEventListener(gotoPlay)
    meta.mainLayer:addChild(uiLayout)
end 

--获取GameGuideV的导演 和 流星定时器
function meta:getSch(dir,sch)
    meta.gameGuideDir = dir
    meta.starSch      = sch
end 

--删除 主图层 函数
function meta:remove()
    meta.readyMeta:setMapFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

return GameMapView
