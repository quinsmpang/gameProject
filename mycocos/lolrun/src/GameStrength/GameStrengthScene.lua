local GameStrengthScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameStrengthScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameStrengthView = require "src/GameStrength/GameStrengthV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameStrengthView:init())
    return meta.mainScene
end 

return GameStrengthScene