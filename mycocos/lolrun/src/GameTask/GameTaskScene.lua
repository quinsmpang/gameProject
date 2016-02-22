local GameTaskScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameTaskScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameTaskView = require "src/GameTask/GameTaskV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameTaskView:init())
    return meta.mainScene
end 

return GameTaskScene