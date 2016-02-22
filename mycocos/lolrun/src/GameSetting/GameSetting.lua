local GameSettingScene = 
{
    mainScene = 0
}--@ 开始场景
local meta = GameSettingScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameSettingView = require "src/GameSetting/GameSettingV"

function meta:init(...)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameSettingView:init())
    return meta.mainScene
end 

return GameSettingScene