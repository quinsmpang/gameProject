

local leader1 = {
    mainLayer = nil;    --主层
    progressTimer = nil; --进度条对象
    cur_leader_idx = 1;

    bg1 = nil;  --背景对象

    bg1_path = "denglu_beijing_01.png";
    bg2_path = "denglu_ali.png";
    progressTimer_path = "bossjiazai_jindutiao_02.png";
    progressTimer_bg_path = "bossjiazai_jindutiao_01.png";
}
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------常亮
local winSize = {width = 960,height = 640}

local leader1_m = require "src/leader/leader1/leader1_m"

---------------------------------------------------------------------------------函数
function leader1:create()
    leader1.mainLayer = cc.LayerColor:create(cc.c4b(0,0,0,255))

    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/leader/leader1/leader1.plist",
                                                       "res/ui/leader/leader1/leader1.pvr.ccz")
    for i = 1, #leader1_m.Hero_ExportJson do 
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(leader1_m.Hero_ExportJson[i])
    end
    leader1:init() 

    return leader1.mainLayer
end
--第一个场景
function leader1:init()
    leader1:registerTouch()
    --local bg1 = cc.Sprite:createWithSpriteFrameName(leader1.bg1_path)
    leader1.bg1 = cc.LayerColor:create(cc.c4b(0,0,0,255))
    leader1.bg1:setAnchorPoint(cc.p(0,0))
    leader1.mainLayer:addChild(leader1.bg1,leader1_m.Zorder.bg1)

    --local action = cc.FadeIn:create(1)
    --leader1.bg1:setOpacity(0)
    --leader1.bg1:runAction(action)

    local label = cc.LabelTTF:create("", "微软雅黑", 24,cc.size(250*2,24*5),cc.TEXT_ALIGNMENT_LEFT)
    label:setString("    ".."欢迎来到酷跑联盟，丛林深处的大龙已经控制了召唤师峡谷，奔跑吧兄弟，消灭大龙，宝藏在向你招手！")
    leader1.bg1:addChild(label,1,leader1_m.tag.bg1_label_tag)
    label:setPosition(cc.p(480,320))
end
--下一个场景
function leader1:next()
    --local action_out = cc.FadeOut:create(1)
    --leader1.bg1:runAction(action_out)
    --leader1.bg1:setVisible(false)
    --ccs 层
    --local layer = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/leader/leader1/leader1.ExportJson")
    local layer = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/leader/leader1/leader1.ExportJson")
    leader1.mainLayer:addChild(layer,leader1_m.Zorder.bg2)
    --layer:setOpacity(0)
    --local action_in = cc.FadeIn:create(2)
    --layer:runAction(action_in)


    local hero_armature = nil
    local tmp_layer = nil
    local heroActionName = "run"
    local bossActionName = "run"
    --加入英雄动画，对应位置对应英雄
    for i = 1,#leader1_m.heroName do 
        tmp_layer = layer:getChildByName("star_"..tostring(i)):getChildByName("hero")
        hero_armature = ccs.Armature:create(leader1_m.heroName[i])
        --timo:setScale(0.5)
        hero_armature:getAnimation():play(heroActionName)
        tmp_layer:addChild(hero_armature)
    end
    --加载boss对应资源对应动画

    local boss = {} --保存boss动画对象
    for i = 1,5 do 
        tmp_layer = layer:getChildByName("star_"..tostring(i+5)):getChildByName("hero")
        boss[i] = ccs.Armature:create(leader1_m.bossName[i])

        boss[i]:setScale(leader1_m.boss_scale[i])
        boss[i]:setScaleX(leader1_m.boss_scale[i] * -1)
        boss[i]:setPosition(leader1_m.boss_pos[i])
        boss[i]:getAnimation():play(bossActionName)
        tmp_layer:addChild(boss[i])
    end
    boss[1]:getAnimation():setSpeedScale(0.7)
    boss[5]:getAnimation():setSpeedScale(0.7)
    --local bone = boss[2]:getBone("dg_body1_3")--大鬼的尾巴
    --bone:removeFromParent(false)
    --leader1:registerMove(boss[1])

    local progress_bg = cc.Sprite:createWithSpriteFrameName(leader1.progressTimer_bg_path)
    leader1.mainLayer:addChild(progress_bg)
    progress_bg:setPosition(138,362)

    leader1.progressTimer = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(leader1.progressTimer_path))
    leader1.progressTimer:setPosition(138,362)
    leader1.progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)--条形类型
    leader1.progressTimer:setMidpoint(cc.p(0, 0))--起点
    leader1.progressTimer:setBarChangeRate(cc.p(1,0))--终点
    --leader1.progressTimer:setPercentage(100)
    leader1.mainLayer:addChild(leader1.progressTimer,leader1_m.Zorder.progressTimer)
    --leader1:registerMove(leader1.progressTimer)

    local game_load = require "src/GameLoad/GameLoadV"
    game_load:initLeaderRes(leader1.progressTimer,leader1.mainLayer)
end



function leader1:registerTouch()
    local function show_hero()
        leader1:next()
    end
    local isOnce = true
    local function onTouchEnded(touch, event)
        if isOnce then 
            isOnce = not isOnce
            local action_out = cc.FadeOut:create(1)
            local bg1_label  = leader1.bg1:getChildByTag(leader1_m.tag.bg1_label_tag)
            bg1_label:runAction(cc.Sequence:create(action_out,cc.CallFunc:create(show_hero)))
        end
    end

    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:setSwallowTouches(true)
    touchListener:registerScriptHandler(function() return true end, cc.Handler.EVENT_TOUCH_BEGAN) 
    --touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED) 
    touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = leader1.mainLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(touchListener, leader1.mainLayer)
end

function leader1:registerMove(layer,isSwallow)
    local  listenner = cc.EventListenerTouchOneByOne:create()
    isSwallow = isSwallow or true
    listenner:setSwallowTouches(isSwallow)

    local function touchesBegin(touch,event)
        
        return true
    end
    local function touchesMove(touch,event)
        local x,y = layer:getPosition()
        local delta = touch:getDelta()
        cclog("x = %d     y = %d",x,y)
        layer:setPosition(cc.p(x+delta.x,y+delta.y))
    end
    local function touchesEnd(touch,event)
        
    end

    listenner:registerScriptHandler(touchesBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(touchesMove,cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(touchesEnd,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layer)

end

return leader1