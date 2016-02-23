local name = "Main"
module("Controller." ..name .."LayerC", package.seeall)

local _MainLayerView = require("View." ..name .."LayerV")
local _LayerManager = require("Manager.LayerManager")
local _SceneManager = require("Manager.SceneManager")

local _event = require("Event.event")

local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

 Controller = require('util.class').class(name .."LayerC",function()
    return cc.Layer:create() 
 end)
   
local _object

local function createUI(self) 
    self.mainLayerV = _MainLayerView.create()  
    _SceneManager.gameLayer:addChild(self.mainLayerV)  
end  

local function addBtnEventListener(self) 
    --按钮事件处理  
    local function eventBtnListener(event)  
       local eventNum = event._usedata  
       local switch = {  
           [_MainLayerView._Tag.btn1] = function()  
                cclog("one")
                _LayerManager.gotoLayerByType(_event.EVENT_CLICK_MENU_HELP)  
           end
       }  
       switch[eventNum]()  
    end  
    --注册事件处理  
    local _custom = cc.EventListenerCustom:create(_event.EVENT_CLICK_MENU_MAIN,eventBtnListener)
    --
    eventDispatcher:addEventListenerWithSceneGraphPriority(_custom,self.mainLayerV)
    --local _eventBtnListener = self.mainLayerV:getEventDispatcher()
    --addEventListenerWithFixedPriority 自行设定优先级
    --addEventListenerWithSceneGraphPriority 默认为0的优先级 单点触摸按层级优先响应
end


Controller.ctor = function(self)
    --约定:
    --不能在此创建精灵
    --定义成员变量    
    cclog("MainLayerC")

    self.mainLayerV = nil
end 

function create()
    _object = Controller.new()
    createUI(_object) 
    addBtnEventListener(_object)
    _SceneManager.gameLayer:addChild(_object)
    if _object.mainLayerV then
        cclog("_object.mainLayerV ====== " ..type(_object.mainLayerV))
    end
    return _object
end