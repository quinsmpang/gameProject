local GameGuideScene = 
{
    mainScene = nil,
}--@ 开始场景
local meta = GameGuideScene

--引用和全局，初始化----------------------------------------------------------------------------------
local GameGuideView = require "src/GameGuide/GameGuideV"
local GameGuideModel = require "src/GameGuide/GameGuideM"

function meta:init(leadOpen)
    meta.mainScene = cc.Scene:create()
    meta.mainScene:addChild(GameGuideView:init(leadOpen))

    --local gold = cc.Sprite:createWithSpriteFrameName("goumaijinbi_jinbi_03.png")
    --meta.mainScene:addChild(gold,99999999)
    --gold:setPosition(cc.p(100,100))

    --local diamond = cc.Sprite:createWithSpriteFrameName("goumaizuanshi_zuanshi_03.png")
    --if diamond then 
    --    meta.mainScene:addChild(diamond,99999999)
    --    diamond:setPosition(cc.p(100,200))
    --end

    --local rou = cc.Sprite:createWithSpriteFrameName("youxiang_tili.png")
    --if rou then 
    --    meta.mainScene:addChild(rou,99999999)
    --    rou:setPosition(cc.p(100,300))
    --end

    return meta.mainScene
end 

return GameGuideScene