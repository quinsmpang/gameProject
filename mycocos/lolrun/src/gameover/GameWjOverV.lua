local GameWjOverView = 
{
    mainLayer = nil; --本图层

    
    bg_path     = "jiesuan_beijing01.png";--背景图

    --左边
    wjmsjl_path =  "baoxiang_baoti_01.png";--无尽模式宝箱奖励文字图
    ddzdfs_path = "baoxiang_baoti_03.png";--到达指定分数获得宝箱奖励
    mrtz_path   = "baoxiang_baoti_04.png";--每日挑战奖励
    jdxtz_path  = "baoxiang_baoti_05.png";--阶段性挑战

    box1_path   = "baoxiang_qingtongbaoxiang.png";--青铜
    box2_path   = "baoxiang_baiyinbaoxiang.png";--白银
    box3_path   = "baoxiang_huangjinbaoxiang.png";--黄金
    box4_path   = "baoxiang_baijinbaoxiang.png";--白金

    box5_path   = "baoxiang_boss_youling.png";--boss1
    box6_path   = "baoxiang_boss_julang.png";--boss2
    box7_path   = "baoxiang_boss_shitouren.png";--boss3
    box8_path   = "baoxiang_boss_xiaolong.png";--boss4

    --右边
    hdjl_path   = "baoxiang_baoti_02.png";--获得奖励
    bxdf_path   = "baoxiang_defen.png";--宝箱得分
    mostScore_num = nil;--表现分
    bxjl_path   = "baoxiang_jiangli.png";--宝箱奖励
    mt_pic      = nil;--米字对象
    mt_path     = "metremi.png";--米字
    mostMetre_num = nil;--米数

    gold_path   = "baoxiang_jiangli_jinbi.png";--金币图
    gold_pic    = nil;--金币图
    gold_label  = nil;--金币文字

    zuanshi_path = "baoxiang_jiangli_jingyan.png";--钻石图
    bxan_path    = "baoxiang_anniu_02.png";--继续按钮
    bxbq_path    = "baoxiang_anniu_01.png";--我要变强按钮

    gouxuan      = "zhandou_baoxiang_yilingqu.png";--勾选

    jinsekuang   = "jinsekuang";--可点选框
    score        = nil;--表现分
    metre        = nil;--米数

    mi           = "baoxiangmi.png";--米数

	
}--@ 游戏逻辑主图层
local  meta = GameWjOverView

local PriorityLayer = require "src/common/priorityLayer"
setmetatable(meta,PriorityLayer)--设置类型是RoleBase
meta.__index = meta--表设定为自身

--引用和全局，初始化----------------------------------------------------------------------------------
local GameView = require "src/GameScene/GameV"
local GameBackGroundView = require "src/GameScene/gamevbackground"
local GameSceneUi = require "src/GameScene/GameSceneUi"
local GameSceneButton = require "src/GameScene/GameSceneButton"
local Rand = require "src/tool/rand"
local visibleSize = cc.Director:getInstance():getVisibleSize()
local origin = cc.Director:getInstance():getVisibleOrigin()
function meta:init( metre,score,box_state,bbox_state,gold )

    local self = {}
    self = PriorityLayer:initEx()
    setmetatable(self,meta)

    SimpleAudioEngine:getInstance():stopMusic()
    SimpleAudioEngine:getInstance():stopAllEffects()
    playEffect("res/music/effect/fight/result.ogg")
    
    --测试用
    --cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/gameIn/jiesuan/wj/wjjiesuan.plist","res/ui/gameIn/jiesuan/wj/wjjiesuan.pvr.ccz")
    --cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/gameIn/UiAndButton/zhandouUI.plist","res/ui/gameIn/UiAndButton/zhandouUI.pvr.ccz")
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/ui/gameIn/jiesuan/wj/jinsekuang.csb")


     --[[测试数据
    metre = 4253
    score = 1234567890
    box_state = 
    {
        {"990001","0"},
        {"990002","0"},
        {"990003","0"},
        {"990004","0"},
        {"1","1"},
        {"2","1"},
        {"3","1"},
        {"4","1"}
    }
    --]]
    
    --创建结算界面
    self:createSettlement(metre,score,box_state,bbox_state,gold)


    return self.mainLayer
end


--界面布局----------------------------------------------------------------------------------
--创建结算界面
function meta:createSettlement(metre,score,box_state,bbox_state,gold)
    local bg_pic = cc.Sprite:createWithSpriteFrameName(self.bg_path)
    bg_pic:setPosition(0,0)
    bg_pic:setAnchorPoint(0,0)
    self.mainLayer:addChild(bg_pic)
    --self:registerMove(bg_pic)

    --左边
    local left = self:createLeft(box_state,bbox_state)
    self.mainLayer:addChild(left)
    --右边
    local right = self:createRight()
    self.mainLayer:addChild(right)

    
    self:setScoreNum(score)--设置表现分
    self:setGoldLabel(score,gold)--设置金币
    
    self:setMetreNum(metre)--设置米数

    statistics(2200)--统计结算游戏

    
end

--左边
function meta:createLeft(box_state,bbox_state)
    local node = cc.Node:create()
    
    local ylq = "1"--已领取
    local klq = "0"--可领取
    

    --无尽模式宝箱奖励
    local wjmsjl_pic = cc.Sprite:createWithSpriteFrameName(self.wjmsjl_path)
    wjmsjl_pic:setPosition(139,510)
    wjmsjl_pic:setAnchorPoint(0,0)
    node:addChild(wjmsjl_pic)
    --self:registerMove(wjmsjl_pic)

    --到达指定分数奖励
    local ddzdfs_pic = cc.Sprite:createWithSpriteFrameName(self.ddzdfs_path)
    ddzdfs_pic:setPosition(116,451)
    ddzdfs_pic:setAnchorPoint(0,0)
    node:addChild(ddzdfs_pic)
    --self:registerMove(ddzdfs_pic)

    --每日挑战
    --local mrtz_pic = cc.Sprite:createWithSpriteFrameName(self.mrtz_path)
    --mrtz_pic:setPosition(146,403)
    --mrtz_pic:setAnchorPoint(0,0)
    --node:addChild(mrtz_pic)
    --self:registerMove(mrtz_pic)

    
    --触摸事件
    local listener1 = cc.EventListenerTouchOneByOne:create()
    --listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(meta.onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = node:getEventDispatcher()


    --宝箱
    local box1_pic = cc.Sprite:createWithSpriteFrameName(self.box1_path)
    box1_pic:setPosition(115,280)
    box1_pic:setAnchorPoint(0,0)
    node:addChild(box1_pic)

    if #box_state >= 1 then
        if box_state[1][1] ~= "0" and box_state[1][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box1_pic:addChild(gouxuan)
        elseif box_state[1][1] ~= "0" and box_state[1][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(105,290)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = box_state[1][1]
            node:addChild(frame,1)
            
            --self:registerMove(frame)
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener1,frame)
        end
    end    
    --self:registerMove(box1_pic)
    --米数
    local box1_mi = cc.Sprite:createWithSpriteFrameName(self.mi)
    box1_mi:setPosition(160,370)
    box1_mi:setAnchorPoint(0,0)
    node:addChild(box1_mi)
    --self:registerMove(box1_mi)
    local mi_1000  = ccui.TextAtlas:create()
    mi_1000:setPosition(129,379)
    mi_1000:setProperty("1000","res/ui/gameIn/font/font_18.png",16,24,"0")
    node:addChild(mi_1000)
    --self:registerMove(mi_1000)
    

    local box2_pic = cc.Sprite:createWithSpriteFrameName(self.box2_path)
    box2_pic:setPosition(216,282)
    box2_pic:setAnchorPoint(0,0)
    node:addChild(box2_pic)
    if #box_state >= 2 then
        if box_state[2][1] ~= "0" and box_state[2][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box2_pic:addChild(gouxuan)
        elseif box_state[2][1] ~= "0" and box_state[2][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(207,290)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = box_state[2][1]
            node:addChild(frame,1)
            --self:registerMove(frame)
            local listener2 = listener1:clone()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener2, frame)
        end
    end
    --self:registerMove(box2_pic)
    --米数
    local box2_mi = cc.Sprite:createWithSpriteFrameName(self.mi)
    box2_mi:setPosition(262,372)
    box2_mi:setAnchorPoint(0,0)
    node:addChild(box2_mi)
    --self:registerMove(box2_mi)
    local mi_2000  = ccui.TextAtlas:create()
    mi_2000:setPosition(230,379)
    mi_2000:setProperty("3000","res/ui/gameIn/font/font_18.png",16,24,"0")
    node:addChild(mi_2000)
    --self:registerMove(mi_2000)


    local box3_pic = cc.Sprite:createWithSpriteFrameName(self.box3_path)
    box3_pic:setPosition(317,283)
    box3_pic:setAnchorPoint(0,0)
    node:addChild(box3_pic)
    if #box_state >= 3 then
        if box_state[3][1] ~= "0" and box_state[3][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box3_pic:addChild(gouxuan)
        elseif box_state[3][1] ~= "0" and box_state[3][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(312,290)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = box_state[3][1]
            node:addChild(frame,1)
            --self:registerMove(frame)
            local listener3 = listener1:clone()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener3, frame)
        end
    end
    --self:registerMove(box3_pic)
    --米数
    local box3_mi = cc.Sprite:createWithSpriteFrameName(self.mi)
    box3_mi:setPosition(360,372)
    box3_mi:setAnchorPoint(0,0)
    node:addChild(box3_mi)
    --self:registerMove(box3_mi)
    local mi_3000  = ccui.TextAtlas:create()
    mi_3000:setPosition(330,383)
    mi_3000:setProperty("6000","res/ui/gameIn/font/font_18.png",16,24,"0")
    node:addChild(mi_3000)
    --self:registerMove(mi_3000)

    local box4_pic = cc.Sprite:createWithSpriteFrameName(self.box4_path)
    box4_pic:setPosition(419,283)
    box4_pic:setAnchorPoint(0,0)
    node:addChild(box4_pic)
    if #box_state >= 4 then
        if box_state[4][1] ~= "0" and box_state[4][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box4_pic:addChild(gouxuan)
         elseif box_state[4][1] ~= "0" and box_state[4][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(410,290)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = box_state[4][1]
            node:addChild(frame,1)
            --self:registerMove(frame)
            local listener4 = listener1:clone()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener4, frame)
        end
    end
    --self:registerMove(box4_pic)
    --米数
    local box4_mi = cc.Sprite:createWithSpriteFrameName(self.mi)
    box4_mi:setPosition(463,372)
    box4_mi:setAnchorPoint(0,0)
    node:addChild(box4_mi)
    --self:registerMove(box4_mi)
    local mi_4000  = ccui.TextAtlas:create()
    mi_4000:setPosition(432,383)
    mi_4000:setProperty("9000","res/ui/gameIn/font/font_18.png",16,24,"0")
    node:addChild(mi_4000)
    --self:registerMove(mi_4000)
    
    ----------------------------------------------------------------
    --boss击杀宝箱
    ----------------------------------------------------------------

    --触摸事件(boss宝箱)
    local bosslistener1 = cc.EventListenerTouchOneByOne:create()
    --bosslistener1:setSwallowTouches(true)
    bosslistener1:registerScriptHandler(meta.bossTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local bosseventDispatcher = node:getEventDispatcher()
    
    --boss1
    local box1_pic_ex = cc.Sprite:createWithSpriteFrameName(self.box5_path)
    box1_pic_ex:setPosition(115,127)
    box1_pic_ex:setAnchorPoint(0,0)
    node:addChild(box1_pic_ex)
    --self:registerMove(box1_pic_ex)
    if #bbox_state >= 1 then
        if bbox_state[1][1] ~= "0" and bbox_state[1][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box1_pic_ex:addChild(gouxuan)
        elseif bbox_state[1][1] ~= "0" and bbox_state[1][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(107,137)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = bbox_state[1][1]
            node:addChild(frame,1)
            --self:registerMove(frame)
            bosseventDispatcher:addEventListenerWithSceneGraphPriority(bosslistener1, frame)
        end
    end


    --boss2
    local box2_pic_ex = cc.Sprite:createWithSpriteFrameName(self.box6_path)
    box2_pic_ex:setPosition(216,127)
    box2_pic_ex:setAnchorPoint(0,0)
    node:addChild(box2_pic_ex)
    --self:registerMove(box2_pic_ex)
    if #bbox_state >= 2 then
        if bbox_state[2][1] ~= "0" and bbox_state[2][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box2_pic_ex:addChild(gouxuan)
        elseif bbox_state[2][1] ~= "0" and bbox_state[2][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(208,137)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = bbox_state[2][1]
            node:addChild(frame,1)
            --self:registerMove(frame)
            local bosslistener2 = bosslistener1:clone()
            bosseventDispatcher:addEventListenerWithSceneGraphPriority(bosslistener2, frame)
        end
    end


    --boss3
    local box3_pic_ex = cc.Sprite:createWithSpriteFrameName(self.box7_path)
    box3_pic_ex:setPosition(320,127)
    box3_pic_ex:setAnchorPoint(0,0)
    node:addChild(box3_pic_ex)
    --self:registerMove(box3_pic_ex)
    if #bbox_state >= 3 then
        if bbox_state[3][1] ~= "0" and bbox_state[3][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box3_pic_ex:addChild(gouxuan)
        elseif bbox_state[3][1] ~= "0" and bbox_state[3][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(311,137)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = bbox_state[3][1]
            node:addChild(frame,1)
            --self:registerMove(frame)
            local bosslistener3 = bosslistener1:clone()
            bosseventDispatcher:addEventListenerWithSceneGraphPriority(bosslistener3, frame)
        end
    end


    --boss4
    local box4_pic_ex = cc.Sprite:createWithSpriteFrameName(self.box8_path)
    box4_pic_ex:setPosition(424,127)
    box4_pic_ex:setAnchorPoint(0,0)
    node:addChild(box4_pic_ex)
    --self:registerMove(box4_pic_ex)
    if #bbox_state >= 4 then
        if bbox_state[4][1] ~= "0" and bbox_state[4][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box4_pic_ex:addChild(gouxuan)
        elseif bbox_state[4][1] ~= "0" and bbox_state[4][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(418,137)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = bbox_state[4][1]
            
            node:addChild(frame,1)
            --self:registerMove(frame)
            local bosslistener4 = bosslistener1:clone()
            bosseventDispatcher:addEventListenerWithSceneGraphPriority(bosslistener4, frame)
        end
    end



    --[[
    --宝箱2
    local box1_pic_ex = cc.Sprite:createWithSpriteFrameName(self.box5_path)
    box1_pic_ex:setPosition(115,110)
    box1_pic_ex:setAnchorPoint(0,0)
    node:addChild(box1_pic_ex)
    if #box_state >= 5 then
        if box_state[5][1] ~= "0" and box_state[5][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box1_pic_ex:addChild(gouxuan)
        elseif box_state[5][1] ~= "0" and box_state[5][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(109,119)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = box_state[5][1]
            node:addChild(frame,1)
            --self:registerMove(frame)
            local listener5 = listener1:clone()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener5, frame)
        end
    end
    --self:registerMove(box1_pic_ex)
    --米数
    local box5_mi = cc.Sprite:createWithSpriteFrameName(self.mi)
    box5_mi:setPosition(158,200)
    box5_mi:setAnchorPoint(0,0)
    node:addChild(box5_mi)
    --self:registerMove(box5_mi)
    local mi_5000  = ccui.TextAtlas:create()
    mi_5000:setPosition(129,209)
    mi_5000:setProperty("5000","res/ui/gameIn/font/font_18.png",16,24,"0")
    node:addChild(mi_5000)
    --self:registerMove(mi_5000)

    local box2_pic_ex = cc.Sprite:createWithSpriteFrameName(self.box6_path)
    box2_pic_ex:setPosition(216,110)
    box2_pic_ex:setAnchorPoint(0,0)
    node:addChild(box2_pic_ex)
    if #box_state >= 6 then
        if box_state[6][1] ~= "0" and box_state[6][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box2_pic_ex:addChild(gouxuan)
        elseif box_state[6][1] ~= "0" and box_state[6][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(208,119)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = box_state[6][1]
            node:addChild(frame,1)
            --self:registerMove(frame)
            local listener6 = listener1:clone()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener6, frame)
        end
    end
    --self:registerMove(box2_pic_ex)
    --米数
    local box6_mi = cc.Sprite:createWithSpriteFrameName(self.mi)
    box6_mi:setPosition(261,200)
    box6_mi:setAnchorPoint(0,0)
    node:addChild(box6_mi)
    --self:registerMove(box6_mi)
    local mi_6000  = ccui.TextAtlas:create()
    mi_6000:setPosition(228,209)
    mi_6000:setProperty("6000","res/ui/gameIn/font/font_18.png",16,24,"0")
    node:addChild(mi_6000)
    --self:registerMove(mi_6000)


    local box3_pic_ex = cc.Sprite:createWithSpriteFrameName(self.box7_path)
    box3_pic_ex:setPosition(317,110)
    box3_pic_ex:setAnchorPoint(0,0)
    node:addChild(box3_pic_ex)
    if #box_state >= 7 then
        if box_state[7][1] ~= "0" and box_state[7][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box3_pic_ex:addChild(gouxuan)
        elseif box_state[7][1] ~= "0" and box_state[7][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(311,119)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = box_state[7][1]
            node:addChild(frame,1)
            --self:registerMove(frame)
            local listener7 = listener1:clone()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener7, frame)
        end
    end
    --self:registerMove(box3_pic_ex)
    --米数
    local box7_mi = cc.Sprite:createWithSpriteFrameName(self.mi)
    box7_mi:setPosition(359,200)
    box7_mi:setAnchorPoint(0,0)
    node:addChild(box7_mi)
    --self:registerMove(box7_mi)
    local mi_7000  = ccui.TextAtlas:create()
    mi_7000:setPosition(328,209)
    mi_7000:setProperty("7000","res/ui/gameIn/font/font_18.png",16,24,"0")
    node:addChild(mi_7000)
    --self:registerMove(mi_7000)

    local box4_pic_ex = cc.Sprite:createWithSpriteFrameName(self.box8_path)
    box4_pic_ex:setPosition(419,110)
    box4_pic_ex:setAnchorPoint(0,0)
    node:addChild(box4_pic_ex)
    if #box_state >= 8 then
        if box_state[8][1] ~= "0" and box_state[8][2] == ylq then--存在并且已领取
            local gouxuan = cc.Sprite:createWithSpriteFrameName(self.gouxuan)
            gouxuan:setPositionX(50)
            box4_pic_ex:addChild(gouxuan)
        elseif box_state[8][1] ~= "0" and box_state[8][2] == klq then--存在并且可领取
            local frame = ccs.Armature:create(self.jinsekuang)
            frame:setPosition(410,119)
            frame:setAnchorPoint(0,0)
            frame:getAnimation():play(ANIMATION_ENUM.run)
            frame.number = box_state[8][1]
            
            node:addChild(frame,1)
            --self:registerMove(frame)
            local listener8 = listener1:clone()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener8, frame)
        end
    end
    --self:registerMove(box4_pic_ex)
    --米数
    local box8_mi = cc.Sprite:createWithSpriteFrameName(self.mi)
    box8_mi:setPosition(462,200)
    box8_mi:setAnchorPoint(0,0)
    node:addChild(box8_mi)
    --self:registerMove(box8_mi)
    local mi_8000  = ccui.TextAtlas:create()
    mi_8000:setPosition(430,209)
    mi_8000:setProperty("8000","res/ui/gameIn/font/font_18.png",16,24,"0")
    node:addChild(mi_8000)
    --self:registerMove(mi_8000)
    --]]


    return node

end

--右边
function meta:createRight()
    local node = cc.Node:create()

    --获得奖励
    local hdjl_pic = cc.Sprite:createWithSpriteFrameName(self.hdjl_path)
    hdjl_pic:setPosition(602,469)
    hdjl_pic:setAnchorPoint(0,0)
    node:addChild(hdjl_pic)
    --self:registerMove(hdjl_pic)

    --米数底图
    local bxdf_pic = cc.Sprite:createWithSpriteFrameName(self.bxdf_path)
    bxdf_pic:setPosition(525,324)
    bxdf_pic:setAnchorPoint(0,0)
    node:addChild(bxdf_pic)
    --self:registerMove(bxdf_pic)

    --表现分
    self.mostScore_num  = ccui.TextAtlas:create()
    self.mostScore_num:setPosition(702,377)
    self.mostScore_num:setProperty("3,200","res/ui/gameIn/jiesuan/wj/wj60.png",48,59,",")
    node:addChild(self.mostScore_num)
    --self:registerMove(mostScore_num)

    --米字
    self.mt_pic = cc.Sprite:createWithSpriteFrameName(self.mt_path)
    self.mt_pic:setAnchorPoint(0,0)
    self.mt_pic:setPosition(745,267)
    self.mt_pic:setAnchorPoint(0,0)
    node:addChild(self.mt_pic)
    --self:registerMove(mt_pic)

    --米数
    self.mostMetre_num  = ccui.TextAtlas:create()
    self.mostMetre_num:setAnchorPoint(0,0)
    self.mostMetre_num:setProperty("123456","res/ui/gameIn/jiesuan/wj/minumber.png",22,32,"0")
    node:addChild(self.mostMetre_num)
    self.mostMetre_num:setPosition(self.mt_pic:getPositionX() - self.mostMetre_num:getLayoutSize().width,270)

    --self:registerMove(self.mostMetre_num)

    --奖励底图
    local bxjl_pic = cc.Sprite:createWithSpriteFrameName(self.bxjl_path)
    bxjl_pic:setPosition(562,198)
    bxjl_pic:setAnchorPoint(0,0)
    node:addChild(bxjl_pic)
    --self:registerMove(bxjl_pic)

    --金币
    self.gold_pic = cc.Sprite:createWithSpriteFrameName(self.gold_path)
    self.gold_pic:setPosition(617,203)
    self.gold_pic:setAnchorPoint(0,0)
    node:addChild(self.gold_pic)
    --self:registerMove(gold_pic)

    --金币文字
    self.gold_label  = ccui.TextAtlas:create()
    self.gold_label:setAnchorPoint(0,0)
    self.gold_label:setPosition(self.gold_pic:getPositionX()+self.gold_pic:getContentSize().width,210)
    self.gold_label:setProperty("120","res/ui/gameIn/jiesuan/wj/wj24.png",16,22,"0")
    node:addChild(self.gold_label)
    --self:registerMove(self.gold_label)

    --继续按钮
    local button = ccui.Button:create()
    button:setTouchEnabled(true)
    button:loadTextures(self.bxan_path,self.bxan_path,self.bxan_path,ccui.TextureResType.plistType)
    button:addTouchEventListener(MakeScriptHandler(self,self.receive))
    button:setPosition(744,103)
    button:setAnchorPoint(0,0)
    node:addChild(button)
    --self:registerMove(button)

    --我要变强按钮
    local bq_button = ccui.Button:create()
    bq_button:setTouchEnabled(true)
    bq_button:loadTextures(self.bxbq_path,self.bxbq_path,self.bxbq_path,ccui.TextureResType.plistType)
    bq_button:addTouchEventListener(MakeScriptHandler(self,self.receiveEx))
    bq_button:setPosition(519,103)
    bq_button:setAnchorPoint(0,0)
    node:addChild(bq_button)
    --self:registerMove(bq_button)

    return node
end
--设置表现分
function meta:setScoreNum(score)
    --local t = {1,2,3,4,5}
    --for i=#t,1,-1 do
    --    cclog("t" ..tostring(i) ..tostring(t[i]))
    --end
    local tab = {}
    local dou = 1
    while true do--记录每位数字
        if dou == 4 then
            table.insert(tab,",")
            dou = 2
        else
            dou = dou+1
        end
        local temp = math.floor(score/10)
        if temp ~= 0 then
            local yu = score%10
            table.insert(tab,yu)
            score = temp
        else
            temp = score%10
            table.insert(tab,temp)
            break
        end
    end
    --重新组织数字
    local str = ""
    for i=#tab,1,-1 do
        str = str ..tab[i]
    end
    self.mostScore_num:setString(str)
end
--设置金币数
function meta:setGoldLabel(score,gold_num)
    self.score = score
    self.gold_label:setString(gold_num)
    self.gold_label:setPositionX(self.gold_pic:getPositionX()+self.gold_pic:getContentSize().width)
end
--设置米数
function meta:setMetreNum(metre)
    self.mostMetre_num:setString(metre)
    self.mostMetre_num:setPositionX(self.mt_pic:getPositionX() - self.mostMetre_num:getLayoutSize().width)
end

--------------继续------------
--点选领取回调
function meta:receive(sender,eventType)
    if eventType == ccui.TouchEventType.began then
        --发送领取信息
        --local act         = "act=score"
        local uid         = "&uid=" .. g_userinfo.uid
        local uname       = "&uname=" .. g_userinfo.uname
        local usid        = "&sid=" .. g_userinfo.sid
        local score       = "&score=" ..tostring(self.score)
        local order_key   = "&order_key=" ..tostring(Func_genOrderCode())
        local url         = g_wjurl ..uid ..uname ..usid ..score ..order_key
        --"http://www.v5fz.com/api/accounts.php?" ..act 
        cclog("url =========== " ..url)
        Func_HttpRequest(url,"",MakeScriptHandler(self,self.receiveCallBack))
    end
end
--领取后回调
function meta:receiveCallBack(msg)
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        if msg == "success" then
           --已经领取过了
           cclog("已经领取过了")
        elseif msg then
            ---[[
            g_userinfo.gold = msg--从服务器返回加成后的金币数
            cclog("==================== msg ==================== " ..msg)
            --androidAlert("")
            SimpleAudioEngine:getInstance():stopAllEffects()
            playEffect("res/music/effect/btn_click.ogg")
            --self:release()--释放
            cc.Director:getInstance():popScene()
        
            --背景层释放
            GameBackGroundView:ReleaseAll()
            --释放主层数据
            GameView:release()
            --释放UI层
            GameSceneUi:release()
            --释放控制层
            GameSceneButton:release()
            --]]

            local repeat_id = 0
            local function receive()
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(repeat_id)
                --loading
                local loadV = require "src/GameLoad/GameLoadV"
                --cc.Director:getInstance():getRunningScene():addChild(loadV:initUiRes(nil,true))
                loadV:initUiRes(nil,true)
            end
            repeat_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(receive,1/g_frame,false)
            

        else
            androidAlert("领取失败请检查网络")
            cclog("领取失败请检查网络")
        end
    else
        --[[
        g_userinfo.gold = msg--从服务器返回加成后的金币数
        cclog("==================== msg ==================== " ..msg)
        --cclog("receiveCallBack = " ..ok)
        SimpleAudioEngine:getInstance():stopAllEffects()
        playEffect("res/music/effect/btn_click.ogg")
        self:release()--释放
        --背景层释放
        GameBackGroundView:ReleaseAll()
        --释放主层数据
        GameView:release()
        --释放UI层
        GameSceneUi:release()
        --释放控制层
        GameSceneButton:release()

         --loading
        local loadV = require "src/GameLoad/GameLoadV"
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(loadV:initUiRes())
        --]]

        ---[[pop场景结算
        cc.Director:getInstance():popScene()
        g_userinfo.gold = msg--从服务器返回加成后的金币数
        --cclog("==================== msg ==================== " ..msg)
        --cclog("receiveCallBack = " ..ok)
        SimpleAudioEngine:getInstance():stopAllEffects()
        playEffect("res/music/effect/btn_click.ogg")
        --self:release()--释放

        --背景层释放
        GameBackGroundView:ReleaseAll()
        --释放主层数据
        GameView:release()
        --释放UI层
        GameSceneUi:release()
        --释放控制层
        GameSceneButton:release()

        local schid = 0
        local function callback()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schid)
            
            --loading
            local loadV = require "src/GameLoad/GameLoadV"
            local scene = cc.Director:getInstance():getRunningScene()
            --scene:addChild(loadV:initUiRes(nil,true))
            loadV:initUiRes(nil,true)
        end
        schid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 1, false)
        --]]

    end
end
--------------我要变强------------
function meta:receiveEx(sender,eventType)
    if eventType == ccui.TouchEventType.began then
        --发送领取信息
        --local act         = "act=score"
        local uid         = "&uid=" .. g_userinfo.uid
        local uname       = "&uname=" .. g_userinfo.uname
        local usid        = "&sid=" .. g_userinfo.sid
        local score       = "&score=" ..tostring(self.score)
        local order_key   = "&order_key=" ..tostring(Func_genOrderCode())
        local url         = g_wjurl ..uid ..uname ..usid ..score ..order_key
        --"http://www.v5fz.com/api/accounts.php?" ..act 
        cclog("url =========== " ..url)
        Func_HttpRequest(url,"",MakeScriptHandler(self,self.receiveCallBackEx))
    end
end
--领取后回调
function meta:receiveCallBackEx(msg)
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        if msg == "success" then
           --已经领取过了
           cclog("已经领取过了")
        elseif msg then
            ---[[
            g_userinfo.gold = msg--从服务器返回加成后的金币数
            cclog("==================== msg ==================== " ..msg)
            --androidAlert("")
            SimpleAudioEngine:getInstance():stopAllEffects()
            playEffect("res/music/effect/btn_click.ogg")
            --self:release()--释放
            cc.Director:getInstance():popScene()
        
            --背景层释放
            GameBackGroundView:ReleaseAll()
            --释放主层数据
            GameView:release()
            --释放UI层
            GameSceneUi:release()
            --释放控制层
            GameSceneButton:release()
            --]]

            local repeat_id = 0
            local function receive()
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(repeat_id)
                --loading
                local loadV = require "src/GameLoad/GameLoadV"
                --cc.Director:getInstance():getRunningScene():addChild(loadV:initUiRes(GAME_UI.Game_Guide,true))
                loadV:initUiRes(GAME_UI.Game_Guide,true)
            end
            repeat_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(receive,1/g_frame,false)
            

        else
            androidAlert("领取失败请检查网络")
            cclog("领取失败请检查网络")
        end
    else
        --[[
        g_userinfo.gold = msg--从服务器返回加成后的金币数
        cclog("==================== msg ==================== " ..msg)
        --cclog("receiveCallBack = " ..ok)
        SimpleAudioEngine:getInstance():stopAllEffects()
        playEffect("res/music/effect/btn_click.ogg")
        self:release()--释放
        --背景层释放
        GameBackGroundView:ReleaseAll()
        --释放主层数据
        GameView:release()
        --释放UI层
        GameSceneUi:release()
        --释放控制层
        GameSceneButton:release()

         --loading
        local loadV = require "src/GameLoad/GameLoadV"
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(loadV:initUiRes())
        --]]

        ---[[pop场景结算
        cc.Director:getInstance():popScene()
        g_userinfo.gold = msg--从服务器返回加成后的金币数
        --cclog("==================== msg ==================== " ..msg)
        --cclog("receiveCallBack = " ..ok)
        SimpleAudioEngine:getInstance():stopAllEffects()
        playEffect("res/music/effect/btn_click.ogg")
        --self:release()--释放

        --背景层释放
        GameBackGroundView:ReleaseAll()
        --释放主层数据
        GameView:release()
        --释放UI层
        GameSceneUi:release()
        --释放控制层
        GameSceneButton:release()

        local schid = 0
        local function callback()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schid)
            
            --loading
            local loadV = require "src/GameLoad/GameLoadV"
            --local scene = cc.Director:getInstance():getRunningScene()
            --scene:addChild(loadV:initUiRes(GAME_UI.Game_Guide,true))
            loadV:initUiRes(GAME_UI.Game_Guide,true)
        end
        schid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 1, false)
        --]]

    end
end



 -----------------------------------------------------
 --释放
 -----------------------------------------------------
 function meta:release()
    
    --self.mainLayer:removeAllChildren(true)--remove所有此界面子节点
    self.mainLayer:removeFromParent(true)

 end
 --触摸事件(米数宝箱)
function meta.onTouchBegan(touch, event)
    --cclog("onTouchBegan")
    local target = event:getCurrentTarget()
        
    local locationInNode = target:convertToNodeSpaceAR(touch:getLocation())
    local s = target:getContentSize()
    local rect = cc.rect(0, 0, s.width, s.height)
        
    if cc.rectContainsPoint(rect, locationInNode) then
        cclog("onTouchBegan")
        local gouxuan = cc.Sprite:createWithSpriteFrameName(meta.gouxuan)
        local pos_x,pos_y = target:getPosition()
        gouxuan:setPosition(pos_x+50,pos_y)
        target:getParent():addChild(gouxuan)
        
        --发送领取信息
        --local act         = "act=get_gift"
        local uid         = "&uid=" .. g_userinfo.uid
        local uname       = "&uname=" .. g_userinfo.uname
        local usid        = "&sid=" .. g_userinfo.sid
        local score       = "&itid=" ..  tostring(target.number)
        --cclog("score ==== " ..tostring(target.number))
        local url = g_wjbxurl ..uid ..uname ..usid ..score
        --"http://www.v5fz.com/api/accounts.php?" ..act ..uid ..uname ..usid ..score

        local function func(val)
            
        end

        Func_HttpRequest(url,"",func)

        target:removeFromParent(true)
    end
end
--触摸事件(boss宝箱)
function meta.bossTouchBegan(touch, event)
    --cclog("bossTouchBegan")
    local target = event:getCurrentTarget()
        
    local locationInNode = target:convertToNodeSpaceAR(touch:getLocation())
    local s = target:getContentSize()
    local rect = cc.rect(0, 0, s.width, s.height)
        
    if cc.rectContainsPoint(rect, locationInNode) then
        cclog("bossTouchBegan")
        local gouxuan = cc.Sprite:createWithSpriteFrameName(meta.gouxuan)
        local pos_x,pos_y = target:getPosition()
        gouxuan:setPosition(pos_x+50,pos_y)
        target:getParent():addChild(gouxuan)
        
        --发送领取信息
        --local act         = "act=get_gift"
        local uid         = "&uid=" .. g_userinfo.uid
        local uname       = "&uname=" .. g_userinfo.uname
        local usid        = "&sid=" .. g_userinfo.sid
        local score       = "&itid=" ..  tostring(target.number)
        --cclog("score ==== " ..tostring(target.number))
        local url = g_wjbxurl ..uid ..uname ..usid ..score
        --"http://www.v5fz.com/api/accounts.php?" ..act ..uid ..uname ..usid ..score

        local function func(val)
            
        end

        Func_HttpRequest(url,"",func)

        target:removeFromParent(true)
    end
end
 ------------------------------------------------------
 --对层注册一个move函数，每次都打印位置
function meta:registerMove(layer)
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)

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


return GameWjOverView