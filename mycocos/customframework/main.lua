
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

-- CC_USE_DEPRECATED_API = true
require "cocos.init"

-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end


local function init()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)


    local file_util = cc.FileUtils:getInstance()
    file_util:addSearchPath('res')
    file_util:addSearchPath('src')

    -- initialize director
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("HelloLua", cc.rect(0,0,960,640))
        director:setOpenGLView(glview)
    end

    glview:setDesignResolutionSize(960, 640, cc.ResolutionPolicy.NO_BORDER)

    --turn on display FPS
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)

    local schedulerID = 0
    --support debug
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or
       (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or
       (cc.PLATFORM_OS_MAC == targetPlatform) then
        cclog("result is ")
        --require('debugger')()

    end
end

local function testFunc()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()

    
    -- run
    local scene = cc.Scene:create()
    local layer = cc.Layer:create()
    cclog("=========================开始测试=========================")
    
    
    --create :
    --init   :  
    --getGridSideLenMax:
    --setGridSideLenMax:
    --getGridSideLenMin:
    --setGridSideLenMin:
    --doCrack               :setGridSideLenMax setGridSideLenMin要在此方法前设置
    --getState              :获取当前动作状态
    --reSet                 :重置完整图片
    --createCfallOffAction  :创建碎片action 总共给予多少时间掉落  这个时间过后停止动作
    --generateDelayTimes    :第一个到最后一个掉落之间时间差


    local eState_well     = 0--敲碎
    local eState_crack    = 1--裂纹掉落
    local eState_fallOff  = 2--重置

    local cs = CbreakSprite:create()
    cs:init("frozen_small.png")
    cs:setAnchorPoint(cc.p(0.5,0.5));
    cs:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))

   --每个网格的大小 随机从最大到最小
    cs:setGridSideLenMax(50)
    cs:setGridSideLenMin(50)
    cs:doCrack(cc.p(visibleSize.width/2, visibleSize.height/2))

    cs:generateDelayTimes(3)
    local action = cs:createCfallOffAction(3)

    local fade_out = cc.FadeOut:create(3)
    local move     = cc.MoveBy:create(3,cc.p(100,0))
    local spa      = cc.Spawn:create(move,action)
    local function func()
        cs:reSet()
    end
    local seq = cc.Sequence:create(spa,cc.CallFunc:create(func))
    cs:runAction(seq)

    cclog("cs:getState ==== " ..cs:getState())

    layer:addChild(cs)

--普通创建精灵
--    local sp = cc.Sprite:create("logo.png")
--    sp:setAnchorPoint(cc.p(0.5,0.5));
--    sp:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
--    sp:runAction(seq)
--    layer:addChild(sp)

    --local cs = cc.Sprite:new()
    --cs:setPostition(visibleSize.width/2,visibleSize.height/2)
    --layer:addChild(cs)

--    local spr = cc.Sprite:create("frozen_small.png")
--    layer:addChild(spr)


    cclog("=========================测试结束=========================")
    scene:addChild(layer)
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end

end


local function main()
    init()
    --testFunc()



    local GameScene = require("GameScene")
    GameScene.startGame()

    --[[
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()
    local scene = cc.Scene:create()
    local layer = cc.Layer:create()


    local sp = cc.Sprite:create("frozen_small.png")
    sp:setAnchorPoint(cc.p(0.5,0.5))
    sp:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
    layer:addChild(sp)

    scene:addChild(layer)
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
    --]]

    --[[
    local test = require("testobj").new()
    --local test = obj:create()
     local sp = cc.Sprite:create("frozen_small.png")
     test:addChild(sp)
    local scene = cc.Scene:create()
     scene:addChild(test)
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
    --]]

end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
