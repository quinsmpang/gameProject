--中文




local GameSceneButton  = {
    mainLayer         = nil;
    jump              = nil; --跳跃按钮
    jump_label        = nil;--跳跃文字
    jineng_cd         = nil; --技能cd挡板
    jineng            = nil;
    jineng_label      = nil;--技能文字
    gongji_label      = nil;--攻击文字
    gongji_cd         = nil; --攻击cd挡板
    gongji            = nil;
    chongci_cd        = nil;
    chongci           = nil;
    chongci_label     = nil;--冲刺文字
    black_layer       = nil;--黑色半透明层
}

local meta = GameSceneButton

local GameM = require "src/GameScene/GameM"
local UI    = GameM.UI
local BUTTON = GameM.BUTTON


local key_w= 143
local key_a= 121
local key_s= 139
local key_j = 130
--应该需要传参数
function meta:init()
    
    
     --cc.SpriteFrameCache:getInstance():addSpriteFrames("res/gameIn/UiAndButton/zhandou_ui_button.plist","res/gameIn/UiAndButton/zhandou_ui_button.png")
    self.mainLayer = cc.Node:create()
    --self.mainLayer = cc.LayerColor:create(cc.c4b(255,255,255,255))
    self:initMainLayer()
    

    self:set_gongjiCD_time(GameM.Handler:getRole():GetAttackCD())
    self:set_jinengCD_time(GameM.Handler:getRole():GetSkillCD())
    self:set_chongciCD_time(60)--(GameM.Handler:getRole():GetSpurtCD())

    return self.mainLayer
end

--设置技能CD时间
function meta:set_jinengCD_time(time)
    BUTTON.jineng_cd_time = time
end
--设置攻击CD时间
function meta:set_gongjiCD_time(time)
    BUTTON.gongji_cd_time = time
end
--设置冲刺时间
function meta:set_chongciCD_time(time)
    BUTTON.chongci_cd = time
end
function meta:release()
    self.mainLayer:removeFromParent()
end

--暂停界面
function meta:createPause()
    --[[正在用
    playEffect("res/music/effect/btn_click.ogg")
    cc.Director:getInstance():pause()--暂停游戏
    local GamePauseView = require "src/gamePause/GamePauseV"
    GameM.game_pause = GamePauseView:init()
    self.mainLayer:getParent():addChild(GameM.game_pause.mainLayer,999)--暂停界面
    --]]
    ---[[测试新暂停
    local function pauseScene(scene)
        if scene then
            local GamePauseView = require "src/gamePause/GamePauseV"
            GameM.game_pause = GamePauseView:init()
            scene:addChild(GameM.game_pause.mainLayer,999)--暂停界面
        end
    end
    --记录原场景
    PauseScene(pauseScene)
    --]]
end

--------------------------------------------------------------高层
function meta:initMainLayer()
    --跳跃按键 攻击  技能  冲刺 暂停
    local menu_tag = 9
    local menu = self:createMenu()
    self.mainLayer:addChild(menu,menu_tag)

    local cd_tag = 10
    --攻击CD
    self.gongji_cd = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(BUTTON.cd_path))
    --self.gongji_cd:setPercentage(100)
    self.gongji_cd:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.gongji_cd:setReverseDirection(true)
    self.gongji_cd:setPosition(cc.p(71,74))
    self.mainLayer:addChild(self.gongji_cd,cd_tag)
    --self.gongji_cd:setVisible(false)
    --self:registerMove(self.gongji_cd)

    --技能CD
    self.jineng_cd = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(BUTTON.cd_path))
    --self.jineng_cd:setPercentage(100)
    --self:set_jinengCD_time(10)
    self.jineng_cd:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.jineng_cd:setReverseDirection(true)
    self.jineng_cd:setPosition(cc.p(73,378))
    self.mainLayer:addChild(self.jineng_cd,cd_tag)
    --self.jineng_cd:setVisible(false)
    --self:registerMove(self.jineng_cd,1)

    --冲刺CD
    self.chongci_cd = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(BUTTON.cd_path))
    --self.chongci_cd:setPercentage(100)
    --self:set_jinengCD_time(10)
    self.chongci_cd:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    --self.chongci_cd:setReverseDirection(true)
    self.chongci_cd:setPosition(cc.p(885,378))
    self.mainLayer:addChild(self.chongci_cd,cd_tag)
    --self.chongci_cd:setVisible(false)
    --self:registerMove(self.chongci_cd,1)

    --新手引导
    if g_userinfo.leader <= LEADER_ENUM.leader0 then
        local black_tag  = 11--除了比攻击 技能 跳跃 冲刺按钮层级低以外 比任何层级高
        self.black_layer = self:blackLayer()
        self.mainLayer:addChild(self.black_layer,black_tag)
    end
   
end
--------------------------------------------------------------模块层
function meta:blackLayer()
    
    --btn
    self.jump:setVisible(false)
    self.jump_label:setVisible(false)
    self.gongji:setVisible(false)
    self.gongji_label:setVisible(false)
    self.jineng:setVisible(false)
    self.jineng_label:setVisible(false)
    self.chongci:setVisible(false)
    self.chongci_label:setVisible(false)

    --cd
    self.chongci_cd:setVisible(false)
    self.jineng_cd:setVisible(false)
    self.gongji_cd:setVisible(false)

    local leader2 = require "src/leader/leader2/leader2"
    local blcaklayer = nil
    if leader2.leader_type then
        ---[[新引导
        blcaklayer = cc.Node:create()
        --blcaklayer:setVisible(false)
        --blcaklayer:addChild(leader2:initLeader())--即时创建
        --]]
    else
        ---[[原引导
        blcaklayer = cc.LayerColor:create(cc.c4b(0,0,0,100))
        blcaklayer:setVisible(false)
        blcaklayer:addChild(leader2:initLeader())
        --]]
    end
    
    return blcaklayer
end
function meta:createMenu()
    local menu = cc.Node:create()
    
    local btn_tag = 1
    --跳跃
    self.jump = cc.Sprite:createWithSpriteFrameName(BUTTON.jump[1])--self:CreateButton(BUTTON.jump[1],BUTTON.jump[2],BUTTON.jump[3],meta.jumpCallback)
    self.jump:setPosition(cc.p(875,76))
    menu:addChild(self.jump,btn_tag)
    --self:registerMove(self.jump)
    self:registerKeyboard(self.jump)

    self.jump_label = cc.Sprite:createWithSpriteFrameName(BUTTON.jump[4])
    self.jump_label:setPosition(cc.p(878,41))
    menu:addChild(self.jump_label,btn_tag)
    --self:registerMove(self.jump_label)

    ---[[
    --攻击
    self.gongji = cc.Sprite:createWithSpriteFrameName(BUTTON.gongji[1])--self:CreateButton(BUTTON.gongji[1],BUTTON.gongji[2],BUTTON.gongji[3],meta.attackCallback)
    menu:addChild(self.gongji,btn_tag)
    self.gongji:setPosition(cc.p(72,75))
    --self:registerMove(self.gongji)
    --self.gongji:setVisible(false)
    
    self.gongji_label = cc.Sprite:createWithSpriteFrameName(BUTTON.gongji[4])
    self.gongji_label:setPosition(cc.p(74,41))
    menu:addChild(self.gongji_label,btn_tag)
    --self:registerMove(self.gongji_label)
   
   
    --技能
    self.jineng = cc.Sprite:createWithSpriteFrameName(BUTTON.jineng[1])--self:CreateButton(BUTTON.jineng[1],BUTTON.jineng[2],BUTTON.jineng[3],meta.jinengCallback)
    menu:addChild(self.jineng,btn_tag)
    self.jineng:setPosition(cc.p(72,375))--(cc.p(211,73))
    --self:registerMove(self.jineng)
    self.jineng:setVisible(false)

    
    self.jineng_label = cc.Sprite:createWithSpriteFrameName(BUTTON.jineng[4])
    self.jineng_label:setPosition(cc.p(70,343))
    menu:addChild(self.jineng_label,btn_tag)
    self.jineng_label:setVisible(false)
    --self:registerMove(self.jineng_label)

    --冲刺
    self.chongci = cc.Sprite:createWithSpriteFrameName(BUTTON.chongci[1])--self:CreateButton(BUTTON.chongci[1],BUTTON.chongci[2],BUTTON.chongci[3],meta.chongciCallback)
    menu:addChild(self.chongci,btn_tag)
    self.chongci:setPosition(cc.p(882,375))
    --self.chongci:setContentSize(70,70)
    --self:registerMove(self.chongci)
    --self.chongci:setVisible(false)

    
    self.chongci_label = cc.Sprite:createWithSpriteFrameName(BUTTON.chongci[4])
    self.chongci_label:setPosition(cc.p(883,343))
    menu:addChild(self.chongci_label,btn_tag)
    --self:registerMove(self.chongci_label)

    function zantingCallback(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            --cclog("zanting")
            --暂停界面
            meta:createPause()--暂停界面
        end
    end

    local pause_tag = 1
    --暂停按钮
    local zanting = self:CreateButton(BUTTON.zanting[1],BUTTON.zanting[2],BUTTON.zanting[3],zantingCallback)
    menu:addChild(zanting,pause_tag)
    zanting:setPosition(cc.p(911,606))
    self:createControlLayer(menu)
    --self:registerMove(zanting)
    if g_userinfo.leader <= LEADER_ENUM.leader0 then
        zanting:setVisible(false)
    end
    --zanting:setVisible(false)
    --]]


    return menu 
end
--新手引导点击
function meta:LeaderTouches(touch,leader2)
    if leader2.leader_type then
        --开始暂停
        if GameM:GetGameSetup() == GAME_STEP.game_ready then
            GameM:SetGameSetup(GAME_STEP.game_start)
            GameM.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
            return true
        end

        --cclog("----------------------------touchesBegin----------------------------")
        local target = touch:getLocation()
        if GameM:GetGameSetup() == GAME_STEP.game_start then
            --跳跃
            if leader2:getIsJump() and target.x > g_visibleSize.width / 2 and target.y < g_visibleSize.height*2 / 5 then
                statistics(20000 + leader2.leader_index)
                g_isPause = false
                self.black_layer:removeAllChildren(true)
                self.black_layer:setVisible(false)
                GameM.Handler:getRole():GetAni():resume()
                GameM.Handler:getRole():ControlBegan()
                return true
            --攻击
            elseif leader2:getIsAtk() and target.x < g_visibleSize.width / 2 and target.y < g_visibleSize.height*2 / 5 then
                statistics(20000 + leader2.leader_index)
                g_isPause = false
                self.black_layer:removeAllChildren(true)
                self.black_layer:setVisible(false)
                GameM.Handler:getRole():GetAni():resume()
                local precent = meta.gongji_cd:getPercentage()
                if precent == 0 then 
                    meta.gongji_cd:setPercentage(100)
                    local CD = cc.ProgressTo:create(BUTTON.gongji_cd_time, 0)
                    meta.gongji_cd:runAction(CD)
                    GameM.Handler:getRole():ControlAttack()
                end
            --冲刺
            elseif leader2:getIsSpurt() and target.x > g_visibleSize.width / 2 and target.y <= g_visibleSize.height*3 / 4 then
                statistics(20000 + leader2.leader_index)
                g_isPause = false
                self.black_layer:removeAllChildren(true)
                self.black_layer:setVisible(false)
                GameM.Handler:getRole():GetAni():resume()
                local precent = meta.chongci_cd:getPercentage()
                if precent == 0 then 
                    meta.chongci_cd:setPercentage(100)
                    local CD = cc.ProgressTo:create(BUTTON.chongci_cd, 0)
                    meta.chongci_cd:runAction(CD)
                    GameM.Handler:getRole():ControlSpurt()
                end
            --旁白    
            elseif leader2:getIsSpeak() then
                statistics(20000 + leader2.leader_index)
                leader2:setIsSpeak(false)
                g_isPause = false
                self.black_layer:removeAllChildren(true)
                self.black_layer:setVisible(false)
                GameM.Handler:getRole():GetAni():resume()
            --进入boss
            elseif leader2:getIsBoss() then
                statistics(20000 + leader2.leader_index)
                leader2:setIsBoss(false)
                g_isPause = false
                self.black_layer:removeAllChildren(true)
                self.black_layer:setVisible(false)
                GameM.Handler:getRole():GetAni():resume()
                --转换场景
                GameM.Handler:getRole():ChangeSceneStart()
            end
        elseif GameM:GetGameSetup() == GAME_STEP.game_boss then
            --旁白    
            if leader2:getIsSpeak() then
                statistics(20000 + leader2.leader_index)
                leader2:setIsSpeak(false)
                g_isPause = false
                self.black_layer:removeAllChildren(true)
                self.black_layer:setVisible(false)
                GameM.Handler:getRole():GetAni():resume()
                
                if leader2.is_speak_3 then
                    GameM:showLightEx()
                    GameM.js:resume()--剑圣
                elseif leader2.is_speak_2 then
                    GameM.Boss_Handler:GetAni():resume()
                end
                if GameM.is_js then--是否出现过js
                    GameM.is_js = false
                    GameM:jsShowEx(cc.Director:getInstance():getRunningScene())
                end
            
            elseif GameM.Handler:getRole():GetIsFloor() and target.x < g_visibleSize.width and target.y < g_visibleSize.height*5 / 6 then
                local precent = meta.gongji_cd:getPercentage()
                if precent == 0 then 
                    meta.gongji_cd:setPercentage(100)
                    local CD = cc.ProgressTo:create(BUTTON.gongji_cd_time, 0)
                    meta.gongji_cd:runAction(CD)
                    GameM.Handler:getRole():ControlAttack()--攻击
                    --[[近战点击攻击马上触发boss受伤
                    if GameM.Handler:getRole():GetAtkType() == ROLE_ATK_TYPE.melee then
                        local injure = GameM.Handler:getRole():GetDataAttack()--获取角色攻击力数值
                        if GameM.Handler:getRole():checkCurt() then
                            injure = injure*2
                        end
                        local boss_die = GameM.Boss_Handler:setInjureString(injure)
                        GameM:setBossDie(boss_die)--设置boss是否死亡
                    end
                    --]]
                end
            end
        end
        
        --]]
    else
        ---[[原引导
            --开始暂停
            if GameM:GetGameSetup() == GAME_STEP.game_ready then
                GameM:SetGameSetup(GAME_STEP.game_start)
                GameM.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                --刚开始的旁白
                if leader2:getIsBtn() then--允许按下
                    leader2:setIsBtn(false)--重置
                    self.black_layer:setVisible(false)
                    GameM.Handler:getRole():GetAni():resume()
                    if leader2:getIsSpeak() then--旁白
                        leader2:setIsSpeak(false)
                        g_isPause = false
                        return true
                    end
                end
                return false
            end
            --打boss
            if GameM:GetGameSetup() == GAME_STEP.game_boss then
                if g_boss ~= 0 then
                    local target = touch:getLocation()
                    if GameM.Handler:getRole():GetIsFloor() and target.x < g_visibleSize.width and target.y < g_visibleSize.height*5 / 6 then
                        local precent = meta.gongji_cd:getPercentage()
                        if precent == 0 then 
                            meta.gongji_cd:setPercentage(100)
                            local CD = cc.ProgressTo:create(BUTTON.gongji_cd_time, 0)
                            meta.gongji_cd:runAction(CD)
                            GameM.Handler:getRole():ControlAttack()--攻击
                        end
                    end
                end
                
            end

            if leader2:getIsBtn() then--允许按下
                leader2:setIsBtn(false)--重置
                self.black_layer:setVisible(false)
                GameM.Handler:getRole():GetAni():resume()
                if leader2:getIsSpeak() then--旁白
                    leader2:setIsSpeak(false)
                    g_isPause = false
                    return true
                elseif leader2:getIsJump() then--是否要求按下跳跃
                    leader2:setIsJump(false)
                    g_isPause = false
                    GameM.Handler:getRole():ControlBegan()
                    return true
                elseif leader2:getIsAtk() then--是否要求按下攻击
                    leader2:setIsAtk(false)
                    g_isPause = false
                    local precent = meta.gongji_cd:getPercentage()
                    if precent == 0 then 
                        meta.gongji_cd:setPercentage(100)
                        local CD = cc.ProgressTo:create(BUTTON.gongji_cd_time, 0)
                        meta.gongji_cd:runAction(CD)
                        GameM.Handler:getRole():ControlAttack()
                    end
                    self.jump:setVisible(true)
                    self.jump_label:setVisible(true)
                elseif leader2:getIsSpurt() then--是否要求按下冲刺
                    leader2:setIsSpurt(false)
                    g_isPause = false
                    local precent = meta.chongci_cd:getPercentage()
                    if precent == 0 then 
                        meta.chongci_cd:setPercentage(100)
                        local CD = cc.ProgressTo:create(BUTTON.chongci_cd, 0)
                        meta.chongci_cd:runAction(CD)
                        GameM.Handler:getRole():ControlSpurt()
                    end
                    self.jump:setVisible(true)
                    self.jump_label:setVisible(true)
                    self.gongji:setVisible(true)
                    self.gongji_label:setVisible(true)
                elseif leader2:getIsBoss() then--是否进入boss
                    leader2:setIsBoss(false)
                    g_isPause = false
                    --转换场景
                    GameM.Handler:getRole():ChangeSceneStart()
                elseif leader2:getIsLeaderExit() then--是否退出引导
                    leader2:setIsLeaderExit(false)
                    GameM:NextLeader()
                end

            end
            return false
        --]]

    end
    
    


end
--触屏点击
function meta:createControlLayer(layer)
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    local leader2 = require "src/leader/leader2/leader2"
    local function touchesBegin(touch,event)
        cclog("新手引导点击")
        ---------------------------新手引导----------------------
        if g_userinfo.leader <= LEADER_ENUM.leader0 then
            return meta:LeaderTouches(touch,leader2)
        end
        -----------------------------------------------------------
        --开始暂停
        if GameM:GetGameSetup() == GAME_STEP.game_ready then
            GameM:SetGameSetup(GAME_STEP.game_start)
            GameM.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
            return false
        end
        --角色触发死亡时候操控无效
        if GameM:GetGameSetup() == GAME_STEP.game_end or GameM:GetGameSetup() == GAME_STEP.game_role_die or GameM:GetGameSetup() == GAME_STEP.game_role_move_die then
            return false
        end
        --cclog("----------------------------touchesBegin----------------------------")
        local target = touch:getLocation()
        if GameM:GetGameSetup() == GAME_STEP.game_start then
            --跳跃
            if target.x > g_visibleSize.width / 2 and target.y < g_visibleSize.height*2 / 5 then
                GameM.Handler:getRole():ControlBegan()
                return true
            --攻击
            elseif target.x < g_visibleSize.width / 2 and target.y < g_visibleSize.height*2 / 5 then
                local precent = meta.gongji_cd:getPercentage()
                if precent == 0 then 
                    meta.gongji_cd:setPercentage(100)
                    local CD = cc.ProgressTo:create(BUTTON.gongji_cd_time, 0)
                    meta.gongji_cd:runAction(CD)
                    GameM.Handler:getRole():ControlAttack()
                end
            --冲刺
            elseif target.x > g_visibleSize.width / 2 and target.y <= g_visibleSize.height*3 / 4 then
                local precent = meta.chongci_cd:getPercentage()
                if precent == 0 then 
                    meta.chongci_cd:setPercentage(100)
                    local CD = cc.ProgressTo:create(BUTTON.chongci_cd, 0)
                    meta.chongci_cd:runAction(CD)
                    GameM.Handler:getRole():ControlSpurt()
                end
            --技能
            --elseif target.x < g_visibleSize.width / 2 and target.y <= g_visibleSize.height*3 / 4 then
            --    local precent = meta.jineng_cd:getPercentage()
            --    if precent == 0 then 
            --        meta.jineng_cd:setPercentage(100)
            --        local CD = cc.ProgressTo:create(BUTTON.jineng_cd_time, 0)
            --        meta.jineng_cd:runAction(CD)
            --        --GameM.Handler:getRole():ControlSkill()
            --        cclog("技能")
            --    end
            end
        elseif GameM:GetGameSetup() == GAME_STEP.game_boss then
            if GameM.Handler:getRole():GetIsFloor() and target.x < g_visibleSize.width and target.y < g_visibleSize.height*5 / 6 then
                local precent = meta.gongji_cd:getPercentage()
                if precent == 0 then 
                    meta.gongji_cd:setPercentage(100)
                    local CD = cc.ProgressTo:create(BUTTON.gongji_cd_time, 0)
                    meta.gongji_cd:runAction(CD)
                    GameM.Handler:getRole():ControlAttack()--攻击
                    --[[近战点击攻击马上触发boss受伤
                    if GameM.Handler:getRole():GetAtkType() == ROLE_ATK_TYPE.melee then
                        local injure = GameM.Handler:getRole():GetDataAttack()--获取角色攻击力数值
                        if GameM.Handler:getRole():checkCurt() then
                            injure = injure*2
                        end
                        local boss_die = GameM.Boss_Handler:setInjureString(injure)
                        GameM:setBossDie(boss_die)--设置boss是否死亡
                    end
                    --]]
                end
            end
        end
        

        return false
    end
    
    local function touchesEnd(touch,event)
        --跳跃回调
        GameM.Handler:getRole():ControlEnd()
        
        --cclog("touchesEnd")
    end

    listenner:registerScriptHandler(touchesBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(touchesEnd,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layer)
end
----更换普通控制
function meta:replaceNormalButton(is_visible)
   self.jump:setVisible(is_visible)--跳跃
   self.jump_label:setVisible(is_visible)--跳跃文字
   self.gongji:setVisible(is_visible)--攻击
   self.gongji_label:setVisible(is_visible)--攻击文字
   self.chongci:setVisible(is_visible)--冲刺
   self.chongci_label:setVisible(is_visible)--冲刺文字
   --self.jineng:setVisible(is_visible)--技能
   --self.jineng_label:setVisible(is_visible)--技能文字

   self.gongji_cd:setVisible(is_visible)--攻击cd
   --self.jineng_cd:setVisible(is_visible)--技能cd
   self.chongci_cd:setVisible(is_visible)--冲刺cd

end


--------------------------------------------------------------功能层、小模块层
function meta:CreateButton(A,B,C,callback)

    --local nor       = cc.Sprite:createWithSpriteFrameName(A)
    --local select1    = cc.Sprite:createWithSpriteFrameName(B)
    --local disable   = cc.Sprite:createWithSpriteFrameName(C)
    --local item = cc.MenuItemSprite:create( nor,
    --                                    select1,
    --                                    disable)
    --item:registerScriptTapHandler(callback)
    --return item

    ---[[
    local button = ccui.Button:create()
    button:setTouchEnabled(true)
    button:loadTextures(A,B,C,ccui.TextureResType.plistType)   
    button:addTouchEventListener(callback)
    --]]


    return button

end
--------------------------------------------------------------注册回调
--[[
--跳跃
function meta.jumpCallback(sender,eventType)
    --cclog("jump")
    --开始暂停
    if GameM:GetGameSetup() == GAME_STEP.game_ready then
        GameM:SetGameSetup(GAME_STEP.game_start)
        GameM.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
        return false
    end
    if eventType == ccui.TouchEventType.began then
        GameM.Handler:getRole():ControlBegan()
    elseif eventType == ccui.TouchEventType.ended then
        GameM.Handler:getRole():ControlEnd()
    end
end
--攻击
function meta.attackCallback(sender,eventType)
    --cclog("attack")
    if eventType == ccui.TouchEventType.began then
        --开始暂停
        if GameM:GetGameSetup() == GAME_STEP.game_ready then
            GameM:SetGameSetup(GAME_STEP.game_start)
            GameM.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
            return true
        end
        --cclog("gongji callback")
        local precent = meta.gongji_cd:getPercentage()
        if precent == 0 then 
            meta.gongji_cd:setPercentage(100)
            local CD = cc.ProgressTo:create(BUTTON.gongji_cd_time, 0)
            meta.gongji_cd:runAction(CD)
            GameM.Handler:getRole():ControlAttack()
        end
        
    end
end
--技能
 function meta.jinengCallback(sender,eventType)
    
    if eventType == ccui.TouchEventType.began then
        --开始暂停
        if GameM:GetGameSetup() == GAME_STEP.game_ready then
            GameM:SetGameSetup(GAME_STEP.game_start)
            GameM.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
            return true
        end
        --cclog("jineng callback")
        local precent = meta.jineng_cd:getPercentage()
        if precent == 0 then 
            meta.jineng_cd:setPercentage(100)
            local CD = cc.ProgressTo:create(BUTTON.jineng_cd_time, 0)
            meta.jineng_cd:runAction(CD)
            --GameM.Handler:getRole():ControlSkill()
            cclog("技能")
        end
    end
end
--冲刺
function meta.chongciCallback(sender,eventType)
    if eventType == ccui.TouchEventType.began then
        --开始暂停
        if GameM:GetGameSetup() == GAME_STEP.game_ready then
            GameM:SetGameSetup(GAME_STEP.game_start)
            GameM.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
            return true
        end
        --cclog("chong ci")
        local precent = meta.chongci_cd:getPercentage()
        if precent == 0 then 
            meta.chongci_cd:setPercentage(100)
            local CD = cc.ProgressTo:create(BUTTON.chongci_cd, 0)
            meta.chongci_cd:runAction(CD)
            GameM.Handler:getRole():ControlSpurt()
        end
    end
end
--]]
---------------------------------------------------------------设置数字相关


--------------------------------------------------------------辅助
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
--注册键盘事件
function meta:registerKeyboard(layer)
    if cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_ANDROID and cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_IPHONE then
        -- 监听键盘按键事件
	    local listenerKeyboard = cc.EventListenerKeyboard:create()
	    listenerKeyboard:registerScriptHandler(self.onEvenKeyboardPressed,cc.Handler.EVENT_KEYBOARD_PRESSED  )
        listenerKeyboard:registerScriptHandler(self.onEvenKeyboardReleased,cc.Handler.EVENT_KEYBOARD_RELEASED )
        local eventDispatcher = layer:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenerKeyboard,layer)
    end
end

function meta.onEvenKeyboardPressed(keyCode,event)
    --cclog("keyCode ============ " ..tostring(keyCode))

    --角色触发死亡时候操控无效
    if GameM:GetGameSetup() == GAME_STEP.game_end or GameM:GetGameSetup() == GAME_STEP.game_role_die or GameM:GetGameSetup() == GAME_STEP.game_role_move_die then
        return
    end

    if keyCode == key_w then 
        GameM.Handler:getRole():ControlBegan()
    elseif keyCode == key_a then
        --cclog("gongji callback")
        local precent = meta.gongji_cd:getPercentage()
        if precent == 0 then 
            meta.gongji_cd:setPercentage(100)
            local CD = cc.ProgressTo:create(BUTTON.gongji_cd_time, 0)
            meta.gongji_cd:runAction(CD)
            GameM.Handler:getRole():ControlAttack()
        end
    elseif keyCode == key_s then
        --GameM.Handler:setVx(-1000)
        local precent = meta.chongci_cd:getPercentage()
        if precent == 0 then 
            meta.chongci_cd:setPercentage(100)
            local CD = cc.ProgressTo:create(BUTTON.chongci_cd, 0)
            meta.chongci_cd:runAction(CD)
            GameM.Handler:getRole():ControlSpurt()
        end
    elseif keyCode == key_j then
        --cclog("keyCode ============ " ..tostring(keyCode))
        --转换场景
        GameM.Handler:getRole():ChangeSceneStart()
        
    end
end

function meta.onEvenKeyboardReleased(keyCode,event)
    if keyCode == key_w then 
        GameM.Handler:getRole():ControlEnd()
    end
end
------------------新手引导专用区------------------
--显示/隐藏 跳跃按钮
function meta:setJumpVisible(is_visible)
    self.black_layer:setVisible(is_visible)
    self.jump:setVisible(is_visible)
    self.jump_label:setVisible(is_visible)
end
--显示/隐藏 攻击按钮
function meta:setAtkVisible(is_visible)
    self.black_layer:setVisible(is_visible)
    self.gongji:setVisible(is_visible)
    self.gongji_label:setVisible(is_visible)
    self.gongji_cd:setVisible(is_visible)
end
--显示/隐藏 冲刺按钮
function meta:setSpurtVisible(is_visible)
    self.black_layer:setVisible(is_visible)
    self.chongci:setVisible(is_visible)
    self.chongci_label:setVisible(is_visible)
    self.chongci_cd:setVisible(is_visible)
end
--显示/隐藏 所有按钮
function meta:setLeaderVisible(is_visible)
    
    --黑色半透明层
    self.black_layer:setVisible(is_visible)
    --btn
    self.jump:setVisible(is_visible)
    self.jump_label:setVisible(is_visible)
    self.gongji:setVisible(is_visible)
    self.gongji_label:setVisible(is_visible)
    self.jineng:setVisible(is_visible)
    self.jineng_label:setVisible(is_visible)
    self.chongci:setVisible(is_visible)
    self.chongci_label:setVisible(is_visible)

    --cd
    self.chongci_cd:setVisible(is_visible)
    self.jineng_cd:setVisible(is_visible)
    self.gongji_cd:setVisible(is_visible)

end
------------------------------------------------------

return GameSceneButton