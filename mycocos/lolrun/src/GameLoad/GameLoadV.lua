local LoadingView = 
{
    mainLayer = nil; --本图层
    ani = nil;  --动画
    progressTimer = nil;    --进度条
    progress_time = 1;
    idx_changeScene = nil;  --用个号码来表示转换的场景：1=GameGuide ；2=战斗场景\
    GameGuideScene = 1;
    GameScene = 2;
    --------------------
    fightSchedule  = nil;
    fightSchedule_count = nil;
    fight_all_count = nil;
    fight_ExportJson = nil;
    fight_plistAndPng = nil;

}--@ 游戏逻辑主图层
local  meta = LoadingView

--------------------------------------------------------------public
--------------------------------------------------------------public
--------------------------------------------------------------public
--------------------------------------------------------------public
--------------------------------------------------------------public
local LoadingM = require "src/GameLoad/GameLoadM"
local scheduler = cc.Director:getInstance():getScheduler()

-----------------------------------
--初始化"战斗界面"资源接口
-----------------------------------
function meta:initFigthingRes()
    self.mainLayer =  cc.Node:create()
    self:createLoading()--loading界面
    self:loadFightingRes()
    --self:loadFightingRes_schedule()
    return self.mainLayer
end
-----------------------------------
--释放"战斗界面"资源接口
-----------------------------------
function meta:removeFightRes()

end
-----------------------------------
--初始化"UI"界面资源接口
-----------------------------------
function meta:initUiRes(openWindowIdx,fight_return)
    --this = self
    if fight_return then
         self.idx_changeScene = self.GameGuideScene    --表示转入GameGuide
         meta:changScene(openWindowIdx)
    else
        self.mainLayer =  cc.Node:create()
        self:createLoading()--loading界面
        self:loadUiRes(openWindowIdx)
        return self.mainLayer
    end
   
end
-----------------------------------
--释放"UI"界面资源接口
-----------------------------------
function meta:removeUiRes()
    
end 
-----------------------------------
--初始化"新手引导"所需要的资源
-----------------------------------
function meta:initLeaderRes(progressTimer,rootLayer)
    self:loadLeaderRes(progressTimer,rootLayer)
end


-------------------------------------------------------------------------------------------private
-------------------------------------------------------------------------------------------private
-------------------------------------------------------------------------------------------private
-------------------------------------------------------------------------------------------private


--loading界面
function meta:createLoading()
    --[[
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/Loading/loadingBackGround.plist", "res/Loading/loadingBackGround.png")--loading背景
    self.background = cc.Sprite:createWithSpriteFrameName("loading_ditu_01.png")
    self.background:setPosition(cc.p(g_visibleSize.width/2,g_visibleSize.height/2))
    self.mainLayer:addChild(self.background)

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/Loading/Loading.ExportJson")--加载loading动画资源
    self.ani = ccs.Armature:create("Loading")--创建动画对象
    self.ani:setPosition(cc.p(g_visibleSize.width/2,g_visibleSize.height/2))
    self.ani:getAnimation():play("loading")
    self.mainLayer:addChild(self.ani,1)
    --]]

    --框
    local kuang = cc.Sprite:createWithSpriteFrameName("duqu_kuang.png")
    self.mainLayer:addChild(kuang,1)
    kuang:setPosition(cc.p(g_visibleSize.width/2,g_visibleSize.height/2))

    for i = 1,1 do 
        local myrand = require "src/tool/rand"
        myrand:init()
        local rand_number = myrand:randnum(1,#LoadingM.tips)
        --框里面的图片
        local tip_png = cc.Sprite:createWithSpriteFrameName(LoadingM.tips[rand_number][1])
        self.mainLayer:addChild(tip_png)
        tip_png:setPosition(cc.p(480,320))

        --框下面的tips
        local tip_label = cc.Sprite:createWithSpriteFrameName(LoadingM.tips[rand_number][2])
        self.mainLayer:addChild(tip_label)
        tip_label:setPosition(cc.p(480,200))

        --进度条下面的一句话  -不知道算不算tips
        local tip_label_2 = cc.Sprite:createWithSpriteFrameName(LoadingM.tips[rand_number][3])
        self.mainLayer:addChild(tip_label_2)
        tip_label_2:setPosition(cc.p(480,120))
    end

    --local label = cc.Label:create()
    --label:setSystemFontSize(40)
    --label:setString("加载中...")
    --self.mainLayer:addChild(label,1)
    --label:setPosition(cc.p(g_visibleSize.width/2+300,g_visibleSize.height/2))

    local progressBg = cc.Sprite:createWithSpriteFrameName("duqu_jindutiao_01.png")
    self.mainLayer:addChild(progressBg,1)
    progressBg:setPosition(cc.p(g_visibleSize.width/2 - 15,g_visibleSize.height/2-165))

    self.progressTimer = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("duqu_jindutiao_02.png"))
    self.progressTimer:setPosition(g_visibleSize.width/2 - 15,g_visibleSize.height/2-165)
    self.progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)--条形类型
    self.progressTimer:setMidpoint(cc.p(0, 0))--起点
    self.progressTimer:setBarChangeRate(cc.p(1,0))--终点
    --self.progressTimer:setReverseDirection(false)--顺逆时
    self.mainLayer:addChild(self.progressTimer,1)

end

function meta.loading(precent)
    local pre = precent * 100
    local function changScene()
        --if meta.idx_changeScene == meta.GameGuideScene then 
        --    meta:changScene()
        --    return 
        --end
        if pre == 100 then 
            meta:changScene()
        end
    end 
    local action = cc.ProgressTo:create(1.5, pre)
    meta.progressTimer:runAction(cc.Sequence:create(action,
                                                    cc.CallFunc:create(changScene)))

end

function meta:loadFightingRes_schedule()
    meta.idx_changeScene = self.GameScene    --表示转入战斗场景
    meta.fightSchedule_count = 1
    meta.fight_ExportJson = LoadingM.fighting.ExportJson
    meta.fight_plistAndPng = LoadingM.fighting.plistAndPng
    meta.fight_all_count = #meta.fight_ExportJson + #meta.fight_plistAndPng
    meta:releaseUiRes()


    local function openSchedule()
        local scheduler = cc.Director:getInstance():getScheduler()
        meta.fightSchedule = scheduler:scheduleScriptFunc(meta.fightScheduleFunc, 1/10, false)
    end

    meta.mainLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(openSchedule)))

end

function meta.fightScheduleFunc()
    local pre = meta.fightSchedule_count * 100 / meta.fight_all_count
    local action = cc.ProgressTo:create(meta.progress_time, pre)
    local i = meta.fightSchedule_count
    if meta.fightSchedule_count <= #meta.fight_ExportJson then 
        --加载动画
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(meta.fight_ExportJson[i])
    else
        --加载plist 和 png
        i = i - #meta.fight_ExportJson
        cc.SpriteFrameCache:getInstance():addSpriteFrames(meta.fight_plistAndPng[i][1],meta.fight_plistAndPng[i][2])
    end

    local function changScene()
        meta:changScene()
    end

    if meta.fightSchedule_count >= meta.fight_all_count then 
        --换场景
        meta.progressTimer:runAction(cc.Sequence:create(action,cc.CallFunc:create(changScene)))
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(meta.fightSchedule)
    else 
        meta.progressTimer:runAction(action)
    end
    meta.fightSchedule_count = meta.fightSchedule_count + 1

end

--加载战斗界面资源过程
function meta:loadFightingRes()
--[[
    local ExportJson = LoadingM.fighting.ExportJson
    local plistAndPng = LoadingM.fighting.plistAndPng
    self.idx_changeScene = self.GameScene    --表示转入战斗场景
    for i = 1,#plistAndPng do 
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistAndPng[i][1],plistAndPng[i][2])
    end
    for i = 1,#ExportJson do 
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(ExportJson[i],meta.loading)
    end
    --]]
--[[
    local ExportJson = LoadingM.fighting.ExportJson
    local plistAndPng = LoadingM.fighting.plistAndPng
    self.idx_changeScene = self.GameScene    --表示转入战斗场景
    for i = 1,#plistAndPng do 
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistAndPng[i][1],plistAndPng[i][2])
    end
    for i = 1,#ExportJson do 
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(ExportJson[i])
    end
    local function changScene()
        meta:changScene()
    end 
    local action = cc.ProgressTo:create(1.5, 100)
    meta.progressTimer:runAction(cc.Sequence:create(action,
                                                    cc.CallFunc:create(changScene)))

 --]]
 ---[[
    local function changScene()
        self:changScene()
    end

    local loaded = 0
    local size = #LoadingM.fighting.ExportJson

    local function loading(precent)
        loaded = loaded + 1
        local pre = 100 * (loaded / size )
        local action = cc.ProgressTo:create(1.5, pre)
        if loaded == size then
            self.progressTimer:runAction(cc.Sequence:create(action,
                                                        cc.CallFunc:create(changScene)))
        else
            self.progressTimer:runAction(action)
        end
    end


    local ExportJson = LoadingM.fighting.ExportJson
    local plistAndPng = LoadingM.fighting.plistAndPng
    self:releaseUiRes()
    self.idx_changeScene = self.GameScene    --表示转入战斗场景

    local function addExportJson()
        for i = 1,#ExportJson do 
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(ExportJson[i],loading)
        end
    end

    self.mainLayer:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(addExportJson)))
    for i = 1,#plistAndPng do 
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistAndPng[i][1],plistAndPng[i][2])
    end

 --]]

end


--释放战斗界面资源过程
function meta:releaseFightingRes()
    local ExportJson = LoadingM.fighting.ExportJson
    local plistAndPng = LoadingM.fighting.plistAndPng
    for i = 1,#plistAndPng do 
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plistAndPng[i][1])
    end
    --for i = 1,#ExportJson do 
        --ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(ExportJson[i])
    --end

end

--加载ui界面资源过程
function meta:loadUiRes(openWindowIdx)
--[[
    local ExportJson = LoadingM.ui.ExportJson
    local plistAndPng = LoadingM.ui.plistAndPng
    self.idx_changeScene = self.GameGuideScene    --表示转入GameGuide
    for i = 1,#plistAndPng do 
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistAndPng[i][1],plistAndPng[i][2])
    end
    for i = 1,#ExportJson do 
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(ExportJson[i],meta.loading)
    end
--]]
 ---[[
    local function changScene()
        self:changScene(openWindowIdx)
    end
  

    local loaded = 0
    local size = #LoadingM.ui.ExportJson

    local function loading(precent)
        loaded = loaded + 1
        local pre = 100 * (loaded / size )
        local action = cc.ProgressTo:create(1.5, pre)
        if loaded == size then
            self.progressTimer:runAction(cc.Sequence:create(action,
                                                        cc.CallFunc:create(changScene)))
        else
            self.progressTimer:runAction(action)
        end
    end




    self:releaseFightingRes()
    local ExportJson = LoadingM.ui.ExportJson
    local plistAndPng = LoadingM.ui.plistAndPng
    self.idx_changeScene = self.GameGuideScene    --表示转入GameGuide

    local function addExportJson()
        for i = 1,#ExportJson do 
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(ExportJson[i],loading)
        end
    end

    self.mainLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(addExportJson)))

    for i = 1,#plistAndPng do 
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistAndPng[i][1],plistAndPng[i][2])
    end
    --for i = 1,#ExportJson do 
    --    ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(ExportJson[i],loading)
    --end
 --]]

end
--释放ui界面资源过程
function meta:releaseUiRes()
    --local ExportJson = LoadingM.ui.ExportJson
    --local plistAndPng = LoadingM.ui.plistAndPng
    --for i = 1,#plistAndPng do 
    --    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plistAndPng[i][1])
    --end

    --cc.TextureCache:removeAllTextures()
    --for i = 1,#ExportJson do 
        --ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(ExportJson[i])
    --end

end


function meta:loadLeaderRes(progressTimer,rootLayer) --参数是一个进度条


    local loaded = 0
    local size = #LoadingM.leader.ExportJson

    local function changScene2()
        self:changScene()
    end

    local function changScene()
        --注册触屏
        local colorLayer = cc.LayerColor:create(cc.c4b(0,0,0,166))
        --local colorLayer = cc.Layer:create()
        rootLayer:addChild(colorLayer,3)
        meta:registerTouch(colorLayer,changScene2)        --点击改变场景
        
        --添加字体
        local label = cc.Sprite:createWithSpriteFrameName("bossjiazai_dianjirenyiweizhi.png")
        colorLayer:addChild(label)
        label:setPosition(cc.p(480,320))
    end

    local function loading(precent)
        loaded = loaded + 1
        local pre = 100 * (loaded / size )
        local action = cc.ProgressTo:create(3, pre)
        if loaded == size then
            progressTimer:runAction(cc.Sequence:create(action,
                                                        cc.CallFunc:create(changScene)))
        else
            progressTimer:runAction(action)
        end
    end

    self.idx_changeScene = self.GameScene    --表示转入战斗场景
    local ExportJson = LoadingM.leader.ExportJson
    local plistAndPng = LoadingM.leader.plistAndPng



    for i = 1,#ExportJson do 
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(ExportJson[i],loading)
    end

    for i = 1,#plistAndPng do 
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistAndPng[i][1],plistAndPng[i][2])
    end

    --加载配置文件  音乐
    local load_file = require "src/GameUpdate/GameUpdateS"
    load_file:updata_config_and_music()
end


--当加载到达100%的时候，转换场景
function meta:changScene(openWindowIdx)
    local i = 0             --阿红专用标记
    local changeScene 
    if self.idx_changeScene == self.GameGuideScene then
        changeScene= meta:getGameGuideScene()
        i = 1            --阿红专用标记
    elseif self.idx_changeScene==self.GameScene then
        changeScene=  meta:getGameScene()
    else
        cclog("err : self.idx_changeScene ~=1 or 2")
        return 
    end
    if cc.Director:getInstance():getRunningScene() then
        if i == 1 then 
        ---[[阿红专用，
            local function mySelect(msg)
                if msg == "0" then 
                    --选服失败
                elseif msg ~= "" and msg ~= nil then 
                    print("GAMELOAD成功选服:",msg)
                    local cjson = require "cjson"
			        local temp_conf = cjson.decode(msg) 
                    --赋值排行榜
                    local GameGuideModel = require "src/GameGuide/GameGuideM"
                    GameGuideModel.initRanks(temp_conf.ranks)
                    g_userinfo.physical = temp_conf.member_physical
                    g_userinfo.diamond = temp_conf.member_diamond
                    g_userinfo.gold = temp_conf.member_gold
                    local GameEmailModel = require "src/GameEmail/GameEmailM"
                    GameEmailModel.saveMailData(temp_conf.email)
                    local GameTaskModel     =   require "src/GameTask/GameTaskM"
                    GameTaskModel.initTaskData(temp_conf.chest)
                    local GameGuideView     =   require "src/GameGuide/GameGuideV"
                    cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,changeScene:init(openWindowIdx)))
                end 
            end 
            local requrl = g_url.get_server.."?uid="..g_userinfo.uid.."&uname="..g_userinfo.uname.."&sid="..g_userinfo.sid
            Func_HttpRequest(requrl,"",mySelect,false)
        else
            cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,changeScene:init(openWindowIdx)))
        end 
        --]]
	else
        cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,changeScene:init(openWindowIdx)))
	end
    
end
--游戏引导界面
function meta:getGameGuideScene()
    --SimpleAudioEngine:getInstance():playMusic("res/music/sound/bgmusic.ogg",true)
    playMusic("res/music/sound/bgmusic.ogg",true)
    return require "src/GameGuide/GameGuideScene"--require "src/GameScene/GameScene"
end

--战斗场景
function meta:getGameScene()
    --cclog("***************************getGameScene============================= ")
    local GameModel = require "src/GameScene/GameM"
    --新手引导需要用
    if g_userinfo.leader <= LEADER_ENUM.leader0 then
        GameModel.game_model = GAME_MODEL.game_repeat--无尽模式
    end
    playEffect("res/music/effect/btn_click.ogg")
    
    GameModel.section = tostring(g_cur_zhang)..";"..tostring(g_cur_jie)
    GameModel:setBackground(GameModel.section)
    playMusic("res/music/effect/fight/fight_music.ogg",true)
    --拆分转化地图数据
    GameModel:ConverData()
    statistics(2000)--统计进入游戏
    return  require "src/GameScene/GameScene"
end

function meta:registerTouch(layer,callback)
    local function onTouchEnded(touch, event)
        callback()
    end

    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:setSwallowTouches(true)
    touchListener:registerScriptHandler(function() return true end, cc.Handler.EVENT_TOUCH_BEGAN) 
    --touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED) 
    touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(touchListener, layer)
end


return LoadingView