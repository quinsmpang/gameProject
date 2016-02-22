local priorityLayer = 
{
    mainLayer = nil; --本图层
}--@ 具有最高优先级图层
local  meta = priorityLayer
meta.__index = meta--没有这句话 此类不能被继承
--引用和全局，初始化----------------------------------------------------------------------------------
--local tiledmapLayer = require "src/xxxxx/xxxxxLayer"

local visibleSize = cc.Director:getInstance():getVisibleSize()
local origin = cc.Director:getInstance():getVisibleOrigin()


function meta:initEx( ... )
    local self = {}--初始化self，如果没有这句，那么类所建立的对象改变，其他对象都会改变
    setmetatable(self,meta)  --将self的元表设定为RoleBase

    self.mainLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 155), visibleSize.width, visibleSize.height) --全屏
   

   -- 监听触摸事件
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)--阻止消息往下传递
    listener:registerScriptHandler(meta.onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(meta.onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(meta.onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self.mainLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.mainLayer)

   return self
end

function meta:init( params)
    meta.mainLayer = cc.LayerColor:create(cc.c4b(0, 0, 17, 17), visibleSize.width, visibleSize.height) --全屏
    
    --窗口---------------------
    if params.bCreateDlg == true then --是否显示出对话框    
    --背景
    local spriteBG = cc.Scale9Sprite:create("res/ui/GUI/button.png")
    spriteBG:setContentSize(params.width,params.height)
    spriteBG:setPosition(visibleSize.width/2,visibleSize.height/2)
    meta.mainLayer:addChild(spriteBG,-1)

    local posBgX, posBgY=  spriteBG:getPosition() --以背景中心点作参考点
    local sizeBg = spriteBG:getContentSize()

    --标题文字
    local titleLabel =  cc.LabelTTF:create(params.titleText,"Arail",36)
	titleLabel:setColor(ccc3(255,255,255))
	titleLabel:setPosition(posBgX,posBgY + sizeBg.height/2)
    titleLabel:setAnchorPoint(0.5,1)
	meta.mainLayer:addChild(titleLabel)--node,render,tag

    --关闭按钮
    if params.isCloseButton == true then 
		local closeButton = cc.MenuItemSprite:create(cc.Scale9Sprite:create("res/ui/GUI/button1.png"),
		    cc.Scale9Sprite:create("res/ui/GUI/button2.png"),cc.Scale9Sprite:create("res/ui/GUI/button2.png"))
		closeButton:setTag(101)
		local mainMenu=cc.Menu:create()
		mainMenu:addChild(closeButton,100)
		local csize=closeButton:getContentSize()
		local anpoint=mainMenu:getAnchorPoint()
	   
	    if params.func ~= nil then
	    	closeButton:registerScriptTapHandler(params.func)
	    end
	    mainMenu:setTag(2)
		mainMenu:setPosition(posBgX + sizeBg.width/2,posBgY + sizeBg.height/2)
		meta.mainLayer:addChild(mainMenu,100)
	end

    end



    -- 监听触摸事件
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)--阻止消息往下传递
    if params.event ==nil then
        listener:registerScriptHandler(meta.onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(meta.onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(meta.onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    elseif params.event ~=nil then
        listener:registerScriptHandler(params.event.onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(params.event.onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(params.event.onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    end
    local eventDispatcher = meta.mainLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, meta.mainLayer)

    return meta.mainLayer
end




--界面布局----------------------------------------------------------------------------------

--@Func背景
--local function meta:renderBackground( param ) 

--end


--界面逻辑回调与相关控制----------------------------------------------------------------------------------

function meta.onTouchBegan(touch, event)
    --local ccPoint = touch:getLocation()
    --print("layer touch began point :"..tostring(ccPoint.x).."---"..tostring(ccPoint.y))
    -- local ccRectTouchPt = cc.rect(ccPoint.x,ccPoint.y,1,1)
    -- local ccRect = cc.rect(0, 0,visibleSize.width,visibleSize.height)
    -- if(cc.rectIntersectsRect(ccRect,ccRectTouchPt)) then
    --     return false
    -- end
    --  return false
    return true
end
   
function meta.onTouchMoved(touch, event)    

end

function meta.onTouchEnded(touch, event)    

end

--@Func菜单回调
function meta.doMenuXXX( ... ) 
    
end



return priorityLayer