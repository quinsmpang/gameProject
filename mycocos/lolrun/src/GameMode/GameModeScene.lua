local GameModeScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameModeScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameModeView = require "src/GameMode/GameModeV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameModeView:init())
    return meta.mainScene
end 

return GameModeScene