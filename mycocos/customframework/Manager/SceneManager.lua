module("Manager.SceneManager", package.seeall)

--场景管理器

--背景层  
bgLayer = nil  
--游戏层  
gameLayer = nil  
--弹窗层  
panelLayer = nil

function initLayer(scene)  
    bgLayer = cc.Layer:create()  
    scene:addChild(bgLayer)  
       
    gameLayer = cc.Layer:create()  
    scene:addChild(gameLayer)  
       
    panelLayer = cc.Layer:create()  
    scene:addChild(panelLayer)  
end    