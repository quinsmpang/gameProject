local GameMapScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameMapScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameMapView = require "src/GameMap/GameMapV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameMapView:init())
    return meta.mainScene
end 

return GameMapScene