module("Manager.LayerManager", package.seeall)

--Layer管理器
local _MainLayerC = require("Controller.MainLayerC")
local _HelperLayerC = require("Controller.HelperLayerC")
local _event = require("Event.event")


local curLayer = nil  
local count = 0
function gotoLayerByType(layerType)  
    if curLayer ~= nil then  
        cclog("destroy")
        destroy(curLayer)
        curLayer = nil
    end  
    
    if layerType == _event.EVENT_CLICK_MENU_MAIN then  
        cclog("====================LAYER_TYPE_MAIN====================" ..count)
        curLayer = _MainLayerC.create()
    elseif layerType == _event.EVENT_CLICK_MENU_HELP then  
        cclog("====================LAYER_TYPE_HELP====================" ..count)
        curLayer = _HelperLayerC.create()
    end 
    count = count + 1 
end
function destroy(curLayer)
    --注意释放顺序:视图层 控制层
    curLayer.mainLayerV:removeFromParent()--
    curLayer:removeFromParent()
end