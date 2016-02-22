local GameKindScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameKindScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameKindView = require "src/GameKind/GameKindV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameKindView:init())
    return meta.mainScene
end 

return GameKindScene