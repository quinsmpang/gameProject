local GameKindView=
{
    mainLayer      = nil,  --本图层
    panel_kind     = nil,  --模式界面
    gameGuideDir   = nil,  --准备界面GameGuideV的导演层
    starSch        = nil,  --准备界面流星定时器
    isOpened       = true ,  --本图层是否开启
    readyMeta      = nil,
    panel_kindYes  = nil ,
}--@ 游戏逻辑主图层
local meta = GameKindView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameKindModel = require "src/GameKind/GameKindM"
local RoleModel = require "src/Role/RoleM"
local GameModel = require "src/GameScene/GameM"
local GameGuideModel = require "src/GameGuide/GameGuideM"
require "src/Hero/Hero"
function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createKind()
    --统计成功进入模式界面
    statistics(2200)
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createKind()
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/game_kind/game_kind.ExportJson")
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_kind.ExportJson")
    --uiLayout:setPosition(g_origin.x,g_origin.y)
    meta.panel_kind     = uiLayout:getChildByName("Panel_kind")
    meta.panel_kindYes  = uiLayout:getChildByName("Panel_kindYes")
    local button_yes    = meta.panel_kindYes:getChildByName("Button_yes")
    local button_no     = meta.panel_kindYes:getChildByName("Button_no")
    local button_back   = meta.panel_kind:getChildByName("Button_back")
    meta.button_endless = meta.panel_kind:getChildByName("Button_endless")
    --meta.heroArmature  = nil 
    
    print(GameGuideModel.curMyHero:getName())
    print(GameGuideModel.curMyHero:getName())
    local armatureName = Hero:getDonghuaById(GameGuideModel.curMyHero:getId())
    meta.heroArmature = ccs.Armature:create(armatureName)
    meta.heroArmature:getAnimation():play("wait")
    meta.heroArmature:setPosition(cc.p(272,280))
    meta.heroArmature:setScale(1.0)
    meta.panel_kind :addChild(meta.heroArmature,70,1)

    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
           playEffect("res/music/effect/fight/get_item.ogg")
        end 
        if eventType == ccui.TouchEventType.ended  then 
           print(touch:getName())
           --meta.mainLayer:removeFromParent()
           meta:remove()
       end 
    end 
	
    local function gotoPlay(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            --数据赋值与选择模式
            RoleModel:SetFightRole(GameGuideModel.curMyHero)
            --RoleModel:SetFightRole(meta.readyMeta.curMyHero)
            if touch:getName() == "Button_endless" then 
                --统计选择无尽模式
                statistics(2300)
                print(g_userinfo.uid)
                if g_debug_btn then
                    GameModel.game_model = GAME_MODEL.game_repeat--无尽模式
                    local loading = require "src/GameLoad/GameLoadS"--loading
                    if cc.Director:getInstance():getRunningScene() then
		                cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,loading:initFigthingRes()))
	                else
                        cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,loading:initFigthingRes()))
	                end
                else
                    local function myEndless(msg)
                        if msg == "0" then 
                            print("体力不足")
                            meta.panel_kindYes:setVisible(true)
                        else
                            local cjson = require("cjson")
                            local endless_conf = cjson.decode(msg)
                            GameGuideModel.curMyHero:setBoxStatus(endless_conf)
                            ---[[无尽模式
                            GameModel.game_model = GAME_MODEL.game_repeat
			                print(GameGuideModel.curMyHero:getName())
                            print("英雄ID:"..GameGuideModel.curMyHero:getId())
                            print("英雄等级:"..GameGuideModel.curMyHero:getLevel())
                            print("英雄血量:"..GameGuideModel.curMyHero:getFinallife())
                            print("巨人时间:"..GameGuideModel.curMyHero:getGiant())
                            print("冲刺时间:"..GameGuideModel.curMyHero:getSprint())
                            print("浮梯时间:"..GameGuideModel.curMyHero:getLadder())
                            print("磁铁时间:"..GameGuideModel.curMyHero:getMagnet())
                            print("青铜宝箱状态:"..GameGuideModel.curMyHero:getBoxStatus(BOX.bronze_status))
                            print("白银宝箱状态:"..GameGuideModel.curMyHero:getBoxStatus(BOX.silver_status))
                            print("黄金宝箱状态:"..GameGuideModel.curMyHero:getBoxStatus(BOX.gold_status))
                            print("白金宝箱状态:"..GameGuideModel.curMyHero:getBoxStatus(BOX.platinum_status))
                            print("BOSS1宝箱状态:"..GameGuideModel.curMyHero:getBoxStatus(BOX.boss_1))
                            print("BOSS2宝箱状态:"..GameGuideModel.curMyHero:getBoxStatus(BOX.boss_2))
                            print("BOSS3箱状态:"..GameGuideModel.curMyHero:getBoxStatus(BOX.boss_3))
                            print("BOSS4箱状态:"..GameGuideModel.curMyHero:getBoxStatus(BOX.boss_4))
                            print(GameGuideModel.curMyHero:getBoxStatus(BOX.bronze_status))
                            print("GameGuideModel.curMyHero:getFinallife()=== " ..GameGuideModel.curMyHero:getFinallife())
                            --无尽模式减20
                            meta.readyMeta:closeCountDownTime()
                            g_userinfo.physical = endless_conf.member_physical
                            local loading = require "src/GameLoad/GameLoadS"--loading
                            if cc.Director:getInstance():getRunningScene() then
		                        cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,loading:initFigthingRes()))
	                        else
                                cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,loading:initFigthingRes()))
	                        end
                            --]]
                        end 
                    end 
                    local requrl = g_url.get_section.."&uid=".. g_userinfo.uid .."&uname=".. g_userinfo.uname .. "&sid=" .. g_userinfo.sid
                    Func_HttpRequest(requrl,"",myEndless)
                    --统计选择什么英雄进行武进游戏
                    statistics(tonumber(GameGuideModel.curMyHero:getId()))
                end
            end 
        end 
    end 

    local function confirmEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then 
            if touch:getName() == "Button_yes" then 
                --进入购买体力界面
                print("yes")
                meta.panel_kindYes:setVisible(false)
                meta.readyMeta.enterStrength()
                --meta:remove()
            else 
                print("no")
                meta.panel_kindYes:setVisible(false)
            end  
        end 
    end

    --添加监听
    button_yes:addTouchEventListener(confirmEvent)
    button_no:addTouchEventListener(confirmEvent)
    button_back:addTouchEventListener(backEvent)
    meta.button_endless:addTouchEventListener(gotoPlay)
    meta.mainLayer:addChild(uiLayout)
end 

--获取GameGuideV的导演 和 流星定时器
function meta:getSch(dir,sch)
    meta.gameGuideDir = dir
    meta.starSch      = sch
end 

--删除 主图层 函数
function meta:remove()
    meta.readyMeta:setKindFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 



return GameKindView
