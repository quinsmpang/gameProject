local GameDiamondScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameDiamondScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameDiamondView = require "src/GameDiamond/GameDiamondV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameDiamondView:init())
    return meta.mainScene
end 

return GameDiamondScene