
require "Cocos2d"
require "Cocos2dConstants"

--require "src/init"
---------------------------------------------------------------------------------
local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    --local path = cc.FileUtils:getInstance():getWritablePath()
    --cc.FileUtils:getInstance():addSearchPath(path)
    --cc.FileUtils:getInstance():addSearchResolutionsOrder(path);
	cc.FileUtils:getInstance():addSearchResolutionsOrder("src");
	cc.FileUtils:getInstance():addSearchResolutionsOrder("res");
    --cc.FileUtils:getInstance():addSearchResolutionsOrder("res/role2");
    
    --cc.FileUtils:getInstance():writeToFile(tab,path)

	local schedulerID = 0
    --support debug
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or 
       (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or
       (cc.PLATFORM_OS_MAC == targetPlatform) then
        cclog("result is ")
		--require('debugger')()
        
    end
    
 --   local layer = cc.Layer:create()
 --   local scene = cc.Director:getInstance():getRunningScene()
 --   if scene then
	--	scene:addChild(layer)
	--end

	--cc.Director:getInstance():setDisplayStats(false)--关闭帧频率
    --local function onrelease(code, event)
    --    --cc.Director:getInstance():setDisplayStats(false)--关闭帧频率
    --    if code == cc.KeyCode.KEY_BACK then
    --        --cc.Director:getInstance():endToLua()
    --        --cc.Director:getInstance():setDisplayStats(false)--关闭帧频率
    --    elseif code == cc.KeyCode.KEY_HOME then
    --        androidAlert("KEY_HOME")
    --        --cc.Director:getInstance():endToLua()
    --        cc.Director:getInstance():setDisplayStats(false)--关闭帧频率
    --    end
    --end

     --local key_listener = cc.EventListenerKeyboard:create()
     if cc.Director:getInstance():getRunningScene() then
        androidAlert(g_userinfo.mac)
     end
     
     --cc.Director:getInstance():setDisplayStats(false)--关闭帧频率
    ----返回键回调
    --local function key_return()
    --    cc.Director:getInstance():setDisplayStats(false)--关闭帧频率
    --    --结束游戏
    --    --cc.Director:getInstance():endToLua()
    --end

    ----监听
    --key_listener:registerScriptHandler(key_return,cc.Handler.EVENT_KEYBOARD_RELEASED)
    ----key_listener:registerScriptHandler(key_return,cc.Handler.KEYPAD)
    --local eventDispatch = layer:getEventDispatcher()
    --eventDispatch:addEventListenerWithSceneGraphPriority(key_listener,layer)
	
end




xpcall(main, __G__TRACKBACK__)
