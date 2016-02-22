local GameRoleScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameRoleScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameRoleView = require "src/GameRole/GameRoleV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameRoleView:init())
    return meta.mainScene
end 

return GameRoleScene