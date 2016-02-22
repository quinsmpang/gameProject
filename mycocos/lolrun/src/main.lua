
require "Cocos2d"
require "Cocos2dConstants"

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
end
--------------------------全局变量-------------------------

-----------------------------------加载音乐音效---------------------------------

--[[音效
-----------音效id---------
g_btn_sound = SimpleAudioEngine:getInstance():playEffect("res/music/effect/btn_click.ogg")--继续游戏 退出游戏 返回上一级菜单 返回菜单
--SimpleAudioEngine:getInstance():stopEffect(g_btn_sound)

g_eat_gold = SimpleAudioEngine:getInstance():playEffect("res/music/effect/sound003gold.ogg")--吃金币
--SimpleAudioEngine:getInstance():stopEffect(g_eat_gold)
g_role_jump = SimpleAudioEngine:getInstance():playEffect("res/music/effect/sound001jump.ogg")--英雄跳跃
--SimpleAudioEngine:getInstance():stopEffect(g_role_jump)
g_choice_sound = SimpleAudioEngine:getInstance():playEffect("res/music/effect/sound005map_change_chapter.mp3")--英雄选择 切换地图
--SimpleAudioEngine:getInstance():stopEffect(g_choice_sound)
g_role_injured = nil;--英雄受伤
g_customs = nil;--关卡开始前三秒
g_win = SimpleAudioEngine:getInstance():playEffect("res/music/effect/sound006battle_win.mp3")--通关成功
--SimpleAudioEngine:getInstance():stopEffect(g_win)
g_faile = SimpleAudioEngine:getInstance():playEffect("res/music/effect/sound007battle_lose.mp3")--通关失败
--SimpleAudioEngine:getInstance():stopEffect(g_faile)
g_pause_soud = SimpleAudioEngine:getInstance():playEffect("res/music/effect/sound004countdown.mp3")--暂停恢复倒计时
--SimpleAudioEngine:getInstance():stopEffect(g_pause_soud)
SimpleAudioEngine:getInstance():stopAllEffects()--停止所有音效
--SimpleAudioEngine:getInstance():pauseAllEffect()--暂停所有音效
---------------------------------------------------------------------------------
--]]

---------------------------------------------------------------------------------
 


require "src/init"
--require "Opengl"--用于画图
--androidAlert(Func_GetChannel())
---------------------------------------------------------------------------------
local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    --[[路径
    --local path = cc.FileUtils:getInstance():getWritablePath()
    --cc.FileUtils:getInstance():addSearchPath(path)
    --cc.FileUtils:getInstance():addSearchResolutionsOrder(path);
	--cc.FileUtils:getInstance():addSearchResolutionsOrder("src");
	--cc.FileUtils:getInstance():addSearchResolutionsOrder("res");
 --   cc.FileUtils:getInstance():addSearchResolutionsOrder("res/ui");
 --   cc.FileUtils:getInstance():addSearchResolutionsOrder("res/tilemap");
 --   cc.FileUtils:getInstance():addSearchResolutionsOrder("res/Loading");
 --   cc.FileUtils:getInstance():addSearchResolutionsOrder("res/ani/monster/png");
 --   cc.FileUtils:getInstance():addSearchResolutionsOrder("res/ui/gameIn/background");
    --cc.FileUtils:getInstance():addSearchResolutionsOrder("res/role2");
    
    --cc.FileUtils:getInstance():writeToFile(tab,path)
    --]]
	
    
    local schedulerID = 0
    --support debug
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or 
       (cc.PLATFORM_OS_ANDROID == targetPlatform) or (cc.PLATFORM_OS_WINDOWS == targetPlatform) or
       (cc.PLATFORM_OS_MAC == targetPlatform) then
        cclog("result is ")
		--require('debugger')()
        
    end
	---------------------------------------------把可写路径置前-----------------------------
    local writePath = cc.FileUtils:getInstance():getWritablePath()  
    local searchPath  =  cc.FileUtils:getInstance():getSearchPaths()
    table.insert(searchPath, 1, writePath)
    table.insert(searchPath, 1, "res/ui/leader/")
    --table.insert(searchPath, 1, "res/ui/leader/publish/gift_word_10_PList.Dir")
    cc.FileUtils:getInstance():setSearchPaths(searchPath);
    ----------------------------------------------工具初始化-----------------------------------------------------
    --ReadLuaFile()--读取配置文件
    --g_res = coroutine.create(LoadResourse)--异步加载
    --g_res = coroutine.create(LoadResourseEx)--cocos加载
    --设置战斗场景配置

    -------------------------------------------------------------------------------------------------------------

    --cclog("CCDirector:sharedDirector():getVisibleSize().width = " ..CCDirector:sharedDirector():getVisibleSize().width)--2.X格式
    --cclog("g_visibleSize = " ..tostring(cc.Director:getInstance():getVisibleSize().width))--3.X格式 此lua提示只提示2.X 后续关注官网跟新

	cc.Director:getInstance():setDisplayStats(false)--关闭帧频率
	--cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(960,640,0)

    --cc.UserDefault:getInstance():setStringForKey("string", "abc") 
    --cc.UserDefault:getInstance():flush()
    --local str = cc.UserDefault:getInstance():getStringForKey("string")
    --local path = cc.FileUtils:getInstance():getWritablePath()
    --cclog("user_path ==============" ..path)




    --cc.Director:getInstance():setAnimationInterval(1/30)
    ---[[
     --run
	
    
    --local startScene = require "src/Loading/LoadingScene"--loading
    --local startScene = require "src/GameGuide/GameGuideScene"--选择英雄
    --local startScene = require "src/MapGuide/MapGuideScene"--选择地图
    --local startScene = require "src/GameScene/GameScene"--战斗场景
    --local startScene = require "src/gameover/GameOverScene"--结算界面
    --local startScene = require "src/GameLoad/GameLoadS"--
    --SimpleAudioEngine:getInstance():playMusic("res/music/sound/music001xzjm.mp3",true)

    --cc.UserDefault:getInstance():setStringForKey("current-version-codezd","1.1")
    --cc.UserDefault:getInstance():setStringForKey("current-version","1.0")
    --cc.UserDefault:getInstance():flush()

    cc.Texture2D:PVRImagesHavePremultipliedAlpha(true)

    local startScene = require "src/start/startScene"--登陆
    
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/Loading/loadingRes.plist", 
                                                        "res/ui/Loading/loadingRes.pvr.ccz")--新loading资源

	if cc.Director:getInstance():getRunningScene() then
		cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,startScene:init()))
	else
        cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,startScene:init()))
	end

 --   local startScene = require "src/GameLoad/GameLoadS"--
 --    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/Loading/loadingRes.plist", 
 --                                                       "res/Loading/loadingRes.png")--新loading资源

	--if cc.Director:getInstance():getRunningScene() then
	--	cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,startScene:initFigthingRes()))
	--else
 --       cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,startScene:initFigthingRes()))
	--end
    

    --]]
end




xpcall(main, __G__TRACKBACK__)
