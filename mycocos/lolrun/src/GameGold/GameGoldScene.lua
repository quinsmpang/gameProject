local GameGoldScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameGoldScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameGoldView = require "src/GameGold/GameGoldV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameGoldView:init())
    return meta.mainScene
end 

return GameGoldScene