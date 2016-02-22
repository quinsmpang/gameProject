local UpdateV = 
{
    assetsManager = nil;
    curVer = nil ;   --记录当前版本号
    nextVer = nil;  --记录下一个版本号
    mainScene = nil;    --主场景
    progressTimer = nil; --进度条
    label = nil;        --下载进度的数字
    label2 = nil; --说明
    label3 =nil;
    label4=nil;
    label5 = nil;

    updateSchedule = nil;

    curScene = nil;  --准备要运行的场景保存在这里，方便addchild
}--@ 游戏逻辑主图层
local  meta = UpdateV
local this = nil;
local scheduler = cc.Director:getInstance():getScheduler()
local debug = not true
local winSize = cc.Director:getInstance():getVisibleSize()
--------------------------------------------------------------public
--------------------------------------------------------------public
--------------------------------------------------------------public
--------------------------------------------------------------public
--------------------------------------------------------------public
local updateM = require "src/GameUpdate/GameUpdateM"
local cjson = require "cjson"
-----------------------------------
--初始化"战斗界面"资源接口
-----------------------------------
function meta:gotoUpdate(scene)
    --保存准备要运行的场景保存在meta
    --self.curScene = scene
    -------------------------------------------------------半透膜
    meta.mainScene = cc.LayerColor:create(cc.c4b(0,0,0,220))
    meta:registerMuTai(meta.mainScene)
    scene:addChild(meta.mainScene)
    -------------------------------------------------------背景框
    local bg = cc.Scale9Sprite:createWithSpriteFrameName("tanchukuang_2.png")
    bg:setCapInsets(cc.rect(11,53,77,35))
    bg:setContentSize(cc.size(600,400))
    bg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    meta.mainScene:addChild(bg)
    ------------------------------------------------------更新中
    local label_update = cc.Label:create()
    label_update:setSystemFontSize(30)
    label_update:setString("更新中")
    self.mainScene:addChild(label_update,10)
    label_update:setPosition(462,496)
    --self:registerMove(label_update)
    ------------------------------------------------------
    --初始化assetsmanager
    meta:createAssetsManager()
    --注册更新函数，1秒钟后运行
    --updateSchedule = scheduler:scheduleScriptFunc(meta.update(), 1, false)
    --运行更新场景
    meta:runUpdateScene()
    
end

function meta:createAssetsManager()
---[[
    --this
    this = self
    --


    --当前版本号
    self.curVer = self:getCurVersion()   --自定义访问版本

    --保存路径
    local pathToSave = cc.FileUtils:getInstance():getWritablePath()
    cclog("%s",pathToSave)
    local PackageUrl =  meta:getNewestPackageUrl()
                        
    local versionFileUrl = meta:getNewestVersionUrl()
    self.assetsManager = cc.AssetsManager:new(PackageUrl,
                                                versionFileUrl,
                                                pathToSave)
    self.assetsManager:setDelegate(meta.onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    self.assetsManager:setDelegate(meta.onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    self.assetsManager:setDelegate(meta.onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    self.assetsManager:setConnectionTimeout(10)
    self.assetsManager:retain()              --貌似没有这句话会蹦
    return self.assetsManager
    --]]

end



function meta:runUpdateScene()

    --场景
    --self.mainScene = cc.Director:getInstance():getRunningScene()

    local progressBg = cc.Sprite:createWithSpriteFrameName("duqu_jindutiao_01.png")
    self.mainScene:addChild(progressBg,2)
    progressBg:setPosition(g_visibleSize.width/2,g_visibleSize.height/2-165)
    --进度条
    self.progressTimer = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("duqu_jindutiao_02.png"))
    self.progressTimer:setPosition(g_visibleSize.width/2,g_visibleSize.height/2-165)
    self.progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)--条形类型
    self.progressTimer:setMidpoint(cc.p(0, 0))--起点
    self.progressTimer:setBarChangeRate(cc.p(1,0))--终点
    self.progressTimer:setReverseDirection(false)--顺逆时
    self.mainScene:addChild(self.progressTimer,2)
    self.progressTimer:setPercentage(1)

    --数字
    self.label = cc.Label:create()
    self.label:setSystemFontSize(20)
    self.label:setString("precent")
    self.mainScene:addChild(self.label,10)
    self.label:setPosition(winSize.width/2,winSize.height/2-150)


        --说明1
        self.label2 = cc.Label:create()
        self.label2:setSystemFontSize(30)
        self.label2:setString("说明")
        self.mainScene:addChild(self.label2,10)
        self.label2:setPosition(480,320)
        -----------------------------------------------
    if debug then 
        --说明2
        self.label3 = cc.Label:create()
        self.label3:setSystemFontSize(40)
        self.label3:setString("说明")
        self.mainScene:addChild(self.label3,10)
        self.label3:setPosition(100,200)

        --说明3
        self.label4 = cc.Label:create()
        self.label4:setSystemFontSize(40)
        self.label4:setString("说明")
        self.mainScene:addChild(self.label4,10)
        self.label4:setPosition(100,300)

        --说明4
        self.label5 = cc.Label:create()
        self.label5:setSystemFontSize(40)
        self.label5:setString("说明")
        self.mainScene:addChild(self.label5,10)
        self.label5:setPosition(100,400)
    end

    self.mainScene:runAction(cc.Sequence:create( cc.DelayTime:create(1), cc.CallFunc:create(meta.update)))

    --self:update()
	--if cc.Director:getInstance():getRunningScene() then
	--	cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,self.mainScene))
	--else
 --       cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,self.mainScene))
	--end
end

-------------------------------------------------------------------------------------------private
-------------------------------------------------------------------------------------------private
-------------------------------------------------------------------------------------------private
-------------------------------------------------------------------------------------------private




function meta.onError(errorCode)
    local function action1()
        if this.label2 then 
            this.label2:setString("已经是最新版本")
        end
    end
    local function action2()
        if this.label2 then 
            this.label2:setString("准备重启")
        end
    end

    local function action3()
        --meta:releaseAll()
        local startScene = meta:reloadModule( "src/start/startScene")--登陆
	    if cc.Director:getInstance():getRunningScene() then
		    cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,startScene:init()))
	    else
            cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,startScene:init()))
	    end

    end
    local schedulerChangScene = nil;
    local function changScene(dt)
        local scene = cc.Director:getInstance():getRunningScene()
        local to1 = cc.CallFunc:create(action1)
        local to2 = cc.DelayTime:create(3)
        local to3 = cc.CallFunc:create(action2)
        local to4 = to2:clone()
        local to5 = cc.CallFunc:create(action3)
        local startScene = require "src/start/startScene"--登陆
        scene:runAction(cc.Sequence:create(to1,to2,to3,to4,to5))
        scheduler:unscheduleScriptEntry(schedulerChangScene)
    end

    --if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
    --    cclog("no new version")

    --elseif errorCode == cc.ASSETSMANAGER_NETWORK then
    --    cclog("network error")
    --    this.label:setString("error : network error")
    --elseif errorCode == cc.ASSETSMANAGER_CREATE_FILE then
    --    cclog("create file")
    --    this.label:setString("error : create file")
    --elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
    --    cclog("uncompress")
    --    --this.label:setString("error : uncompress")
    --end
    this.label:setString("请稍等 ...")
    schedulerChangScene = scheduler:scheduleScriptFunc(changScene, 1, false)
end

function meta.onProgress(percent)
    meta.progressTimer:setPercentage(percent)
    meta.label:setString("已经下载 "..tostring(percent).."%")
end

function meta.onSuccess()

    local nextVersion = meta:getNextVersion()
    meta.label2:setString("已经下载完成版本 "..nextVersion.." ... ...")
    meta:setCurVersion(nextVersion)
    meta:releaseAssetsManager()
    --初始化assetsmanager
    meta:createAssetsManager()
    
    local newestVersion = meta:getNewestVersionUrl()

    meta.mainScene:runAction(cc.Sequence:create( cc.DelayTime:create(1), cc.CallFunc:create(meta.update)))

end

function meta.update(dt)
    if meta.assetsManager:checkUpdate() then

            cclog("new version")
            local ver = meta:getCurVersion()
            ver = tonumber(ver)
            meta.label2:setString("正在更新版本 "..tostring(ver+0.1))
        if debug then 
            local verUrl = meta.assetsManager:getVersionFileUrl()
            verUrl = string.sub(verUrl,-4,-1)
            meta.label3:setString(verUrl)

            local packUrl = meta.assetsManager:getPackageUrl()
            packUrl = string.sub(packUrl,-10,-1)
            meta.label4:setString(packUrl)
        end
        meta.assetsManager:update()
    else 
        --meta:releaseAssetsManager()
        if debug then 
            meta.label2:setString("没什么好更新的")
        end
    end


end

function meta:releaseAssetsManager()
    if meta.assetsManager then 
        meta.assetsManager:release()
        meta.assetsManager = nil;
    end
end

function meta:createProgress()
    local progressTimer = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("duqu_jindutiao_02.png"))
    progressTimer:setPosition(443,48)
    progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)--条形类型
    progressTimer:setMidpoint(cc.p(0, 0))--起点
    progressTimer:setBarChangeRate(cc.p(1,0))--终点
    --progressTimer:setReverseDirection(false)--顺逆时
    progressTimer:setPercentage(1)


    --meta:registerMove(progressTimer)

    return progressTimer
end

function meta:reloadModule( moduleName )
    --cclog(package.loaded[moduleName])
    package.loaded[moduleName] = nil

    return require(moduleName)
end

----------------------------------------------------------------------------链接 版本相关
function meta:getCurVersion()
    local ver = cc.UserDefault:getInstance():getStringForKey("current-version") --我们私自用current-version来记录当前版本
    if ver == "" then 
        local rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/versionconf.json")
        rconf = rever_dec(rconf)
        g_conf["g_version"] = cjson.decode(rconf)

        ver = tostring(g_conf["g_version"][2].version)
        cc.UserDefault:getInstance():setStringForKey("current-version",ver)
        cc.UserDefault:getInstance():flush()
    end
    return ver
end
function meta:setCurVersion(ver)
    cc.UserDefault:getInstance():setStringForKey("current-version",tostring(ver))
    cc.UserDefault:getInstance():flush()
end

function meta:getNextVersion()
    local curVersion = meta:getCurVersion()
    local newestVersion = tostring(tonumber(curVersion) + 0.1)
    return newestVersion
end

function meta:getNewestVersionUrl()

    local newestVersion = meta:getNextVersion()
    return g_inturl .. "&ver="..newestVersion
end

function meta:getNewestPackageUrl()
    local nextVer = meta:getNextVersion()
    return g_onlineUrl.."uploadfiles/" .. nextVer .. ".zip"
end

function meta:registerMove(tar)
    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local posX,posY = target:getPosition()
        local delta = touch:getDelta()
        target:setPosition(cc.p(posX + delta.x, posY + delta.y))
        cclog("%d    %d",posX + delta.x,posY + delta.y)
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    --listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    local scene = cc.Director:getInstance():getRunningScene()
    local eventDispatcher = scene:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, tar)

end

function meta:registerMuTai(tar)
    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchMoved(touch, event)

    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    --local scene = cc.Director:getInstance():getRunningScene()
    local eventDispatcher = tar:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, tar)

end


return UpdateV