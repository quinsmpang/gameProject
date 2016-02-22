local GameMysteryScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameMysteryScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameGuideView = require "src/GameMystery/GameMysteryV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameMysteryView:init())
    return meta.mainScene
end 

return GameMysteryScene