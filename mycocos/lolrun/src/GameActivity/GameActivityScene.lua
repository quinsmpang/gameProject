local GameActivityScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameActivityScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameActivityView = require "src/GameActivity/GameActivityV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameActivityView:init())
    return meta.mainScene
end 

return GameActivityScene