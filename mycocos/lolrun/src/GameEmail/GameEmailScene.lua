local GameEmailScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameEmailScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameGuideView = require "src/GameEmail/GameEmailV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameEmailView:init())
    return meta.mainScene
end 

return GameEmailScene