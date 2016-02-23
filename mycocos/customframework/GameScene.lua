module("GameScene", package.seeall)

local _SceneManager = require("Manager.SceneManager")
local _LayerManager = require("Manager.LayerManager")
local _event = require("Event.event")
local scene = nil  

function startGame()  
    --初始化  
    scene = cc.Scene:create()  
    if cc.Director:getInstance():getRunningScene() then  
        cc.Director:getInstance():replaceScene(scene)  
    else  
        cc.Director:getInstance():runWithScene(scene)  
    end  
    _SceneManager.initLayer(scene)  
    enterGame()  
end  
   
function enterGame()  
    _LayerManager.gotoLayerByType(_event.EVENT_CLICK_MENU_MAIN)  
end  