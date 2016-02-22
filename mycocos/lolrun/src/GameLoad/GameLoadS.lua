

local LoadingScene = 
{
   mainScene = nil;
}--@ 开始场景
local meta = LoadingScene


--引用和全局，初始化----------------------------------------------------------------------------------
local gameLoadV = require "src/GameLoad/GameLoadV"

function meta:initFigthingRes()
     meta.mainScene =  cc.Scene:create()
    
     meta.mainScene:addChild(gameLoadV:initFigthingRes())

     return meta.mainScene
end

function meta:initUiRes()
     meta.mainScene =  cc.Scene:create()
    
     meta.mainScene:addChild(gameLoadV:initUiRes())

     return meta.mainScene
end



return LoadingScene

