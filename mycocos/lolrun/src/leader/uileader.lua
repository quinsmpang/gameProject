UILeader = class(UILeader,function() return cc.Layer:create() end )
UILeader.__index = UILeader

local listGuild = {
    "gift_1",
    "gift_2",
    "gift_3",
    "gift_4",
    "gift_5",
    "gift_6",
    "gift6_1",
    "gift_7",
    "gift_8",
    "gift_9",
    "gift_10",
    "gift_10_1",
    "gift_10_2",
    "gift_11",
    "gift11_1",
    "gift_12",
    "gift_13",
    "gift_14",
    "gift_15"
};

--引导2

function UILeader:create(leaderWord)
    local uileader = UILeader:new()
    uileader:init(leaderWord)
    return uileader
end 

function UILeader:ctor()
    UILeader.mainLayer = nil
    UILeader.isNew = 0
    UILeader.allMaskLayer  = nil 
    UILeader.someMaskLayer = nil
    UILeader.maskListener  = nil
    UILeader.curStep  = 0
end 

local function boxZeroRect(boxNode)
    local boxPosX   = boxNode:getPositionX() 
    local boxPosY   = boxNode:getPositionY() 
    local boxScaleX = math.abs(boxNode:getScaleX())
    local boxScaleY = math.abs(boxNode:getScaleY())
    local newRect   = cc.rect(math.ceil(boxPosX - ( 4 * boxScaleX ) / 2),math.ceil(boxPosY - ( 4 * boxScaleY )/ 2),4 * boxScaleX,4 * boxScaleY)
    return newRect
end 

function UILeader:init(leaderWord)
    
    self:initMaskLayer()
    self.curStep = leaderWord
    if self.curStep > #listGuild then
        --Over
        self:removeFromParent()
        return 
    else 
        local name = listGuild[self.curStep]
        self.rootNode = ccs.SceneReader:getInstance():createNodeWithSceneFile("res/ui/leader/publish/" .. name .. ".csb")
    end
    local box  = nil
    if self.rootNode ~= nil then
        self:addChild(self.rootNode,9992,5)           --中间场景获取的node
        box  = self.rootNode:getChildByTag(20001)

        if self.someMaskLayer ~= nil then 
            cclog("关闭局部屏蔽")
            self.someMaskLayer:removeFromParent()
            self.someMaskLayer = nil 
        end 

        if self.allMaskLayer ~= nil then 
            cclog("关闭全屏屏蔽")
            self.allMaskLayer:setVisible(false)
        end 
    else 
            --OVER
            cclog("rootNode == nil ")
    end

    if box == nil then
            local child_ali   = self.rootNode:getChildByTag(10001)
            local render_ali  = child_ali:getComponent("CCArmature")
            local widget_ali  = render_ali:getNode()
            local bone        = widget_ali:getChildren()
            print("创建全屏屏蔽")
            self.allMaskLayer:setVisible(true)
            --帧事件回调
	        local function FrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
		        if evt == "goto(9)" then
                    widget_ali:getAnimation():gotoAndPlay(9)
                end
                if evt == "goto(10)" then
                    widget_ali:getAnimation():gotoAndPlay(10)
                end
            end
            widget_ali:getAnimation():setFrameEventCallFunc(FrameEvent)--注册帧事件
    else
   
            local boxPosX   = box:getPositionX() 
            local boxPosY   = box:getPositionY() 
            local boxScaleX = math.abs(box:getScaleX())
            local boxScaleY = math.abs(box:getScaleY())
            local boxNewRect = boxZeroRect(box)
            print(boxNewRect.x)
            print(boxNewRect.y)
            --local duan = createClippingBoard(cc.rect(0,0,0,0),cc.c4b(100,0,0,100))
            print("创建局部屏蔽")
            self.someMaskLayer = createClippingBoard(boxNewRect,cc.c4b(0,0,0,0))
            local function maskBegin(touch, event)
                local target = event:getCurrentTarget()
                local locationInNode = touch:getLocation()
                local s = boxNewRect
                local dstWidth = s.width / 4
                local dstHeight = s.height / 4
                local rect = cc.rect(s.x + dstWidth, s.y + dstHeight, s.width - dstWidth, s.height - dstHeight)
                if cc.rectContainsPoint(rect, locationInNode) then
                    statistics(21000 + self.curStep)
                    self.rootNode:removeFromParent()
                    self:init(self.curStep + 1)
                    return false
                end
                return true
            end
            local Listener = cc.EventListenerTouchOneByOne:create()
            Listener:registerScriptHandler(maskBegin,cc.Handler.EVENT_TOUCH_BEGAN)
            Listener:setSwallowTouches(true)
            local eventDispatcher = self.someMaskLayer:getEventDispatcher()
            eventDispatcher:addEventListenerWithSceneGraphPriority(Listener,self.someMaskLayer)
            self:addChild(self.someMaskLayer,9990)
    end 
end 




function UILeader:initMaskLayer()
    if self.allMaskLayer == nil then 
        self.allMaskLayer = cc.LayerColor:create(cc.c4b(0,0,0,0))
        local function maskBegin(touch, event)
             statistics(21000 + self.curStep)
             print("全屏")
             self:webStep()
             if self.allMaskLayer:isVisible() then 
                self.rootNode:removeFromParent()
                self:init(self.curStep + 1)
                return true 
             else
                if self.curStep == 17 then 
                    self:removeFromParent()
                end 
                return false
             end
        end 
        self.maskListener = cc.EventListenerTouchOneByOne:create()
        self.maskListener:registerScriptHandler(maskBegin,cc.Handler.EVENT_TOUCH_BEGAN)
        self.maskListener:setSwallowTouches(true)
        local eventDispatcher = self.allMaskLayer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(self.maskListener,self.allMaskLayer)
        self:addChild(self.allMaskLayer,9991,3) 
    end 
end 

function UILeader:webStep()
    cclog("进入记录步骤")

    if  self.curStep == 1 or self.curStep == 6 or self.curStep == 12 or self.curStep == 17 or self.curStep == 19 then 
        g_userinfo.leader = self.curStep
        if self.curStep == #listGuild then
            cclog("已完成新手引导")
            g_userinfo.leader = -1
        end

        local function kong()
        end 
        local steprequrl = g_url.get_step .. "?uid=" .. g_userinfo.uid .. "&uname=".. g_userinfo.uname .."&step=".. g_userinfo.leader  .."&sid=" .. g_userinfo.sid
        cclog(steprequrl)
        Func_HttpRequest(steprequrl,"",kong,false)
    end

    
end 





