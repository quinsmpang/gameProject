local startScene = 
{
   mainScene = nil;
}--@ 开始场景
local meta = startScene

--引用和全局，初始化----------------------------------------------------------------------------------
local startView = require "src/start/startV"

function meta:init( ... )
    meta.mainScene =  cc.Scene:create()
	
	meta.mainScene:addChild(startView:init())

    return meta.mainScene
end

function meta:init2()
    meta.mainScene =  cc.Scene:create()
	
	meta.mainScene:addChild(startView:init2())

    return meta.mainScene
end 


return startScene

