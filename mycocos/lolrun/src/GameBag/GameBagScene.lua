local GameBagScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameBagScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameBagView = require "src/GameBag/GameBagV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameBagView:init())
    return meta.mainScene
end 

return GameBagScene