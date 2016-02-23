local name = "Main"
module("View." ..name .."LayerV", package.seeall)

local _Model = require("Model." ..name .."LayerM")
local _event = require("Event.event")


View = require('util.class').class(name .."LayerV",function()
    return cc.Layer:create() 
end)

local _object

--控件标识
_Tag = 
{
    btn1 = 1

}

local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

local function initUI(self)
    local winSize = cc.Director:getInstance():getWinSize()  
    self.bg = cc.Sprite:create(_Model.main_bg)  
    self.bg:setPosition(winSize.width / 2,winSize.height / 2)  
    self:addChild(self.bg)
       
    local function menuCallback(tag,menuItem)  
        local event = cc.EventCustom:new(_event.EVENT_CLICK_MENU_MAIN)  
        event._usedata = tag  
        eventDispatcher:dispatchEvent(event)  
    end  
       
    self.btnItem1 = cc.MenuItemImage:create(_Model.main_btn1,_Model.main_btn1,_Model.main_btn1)  
    self.btnItem1:setPosition(winSize.width / 2,winSize.height / 3)  
    self.btnItem1:setTag(_Tag.btn1)  
    self.btnItem1:registerScriptTapHandler(menuCallback)  
     
    --创建菜单  
    self.menu = cc.Menu:create(self.btnItem1)  
    self.menu:setPosition(0,0)  
    self:addChild(self.menu)

end

View.ctor = function(self)
    --约定:
    --不能在此创建精灵
    --定义成员变量  
   cclog("MainLayerV")

   self.bg       = nil
   self.btnItem1 = nil
   self.menu     = nil
end


function create()
    _object = View.new()
    initUI(_object)
    return _object
end