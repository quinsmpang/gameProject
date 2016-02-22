--中文


local GameSceneUi  = {
    mainLayer = nil;
    blood = nil; --血条

    change_scene_bg       = nil;--转化场景进度条背景图
    change_scene_progress = nil;--转化场景进度条
    change_scene_start    = nil;--转化场景进度条星星
    change_scene_percent  = nil;--转化场景百分比
    change_scene_percent_number    = nil;--转化场景百分比
    change_scene_number            = nil;--用于计算场景进度条实际数值
    change_scene_all_pecent        = 1000;--按距离计算就是距离 按表现分计算就是表现分
    change_scene_reward_number     = 9;--秒 用于计算奖励模式进度条实际数值
    change_scene_reward_frame      = 100;--帧
    change_scene_reward_all_pecent = 10;----boss模式中代表多少秒退出(奖励模式总共百分比) 每次打10秒
    leader_time                    = 19;--新手引导打boss时间

    game_is_score                  = false;--按表现分计算需要开启这个变量 并且修改change_scene_number值 false是按距离计算

    jiaxue_bg     = nil;--加血底图
    jiaxue        = nil;--加血进度条
    jiaxue_renwu  = nil;--加血人物
    jiaxue_number = nil;--用于记录当前percent
    jiaxue_all    = 30;--按时间计算就是时间  按距离计算就是距离

    biaoxian        = nil;--表现文字
    biaoxian_number = nil;--表现分数
    juli_number = nil; --距离


    heroBloodBg       = nil;--英雄血条底图
    heroBloodProgress = nil; --英雄血条进度条 

    heroAllBlood = nil; --英雄总血量
    heroCurBlood = nil; --英雄当前血量
    
    
    box1        = nil;--青铜
    box2        = nil;--白银
    box3        = nil;--黄金
    box4        = nil;--白金

    
    box1_metre = 1000;
    box2_metre = 3000;
    box3_metre = 6000;
    box4_metre = 9000;
 

    box_juli    = nil;--与box距离
    dynamic_box = nil;--动态宝箱
    box_visible = nil;--根据米数创建对应动态宝箱

    --传参
    heroName = nil;


    

    --右上角
    boss_head_node      = nil;--boss节点(关联 boss头像 boss百分号 boss百分号数字)
    boss_head           = nil;--boss头像

    boss_percent        = nil;--boss百分号
    boss_percent_path   = "bosspercent.png";

    boss_percent_num    = nil;--boss百分号数字

    --boss头顶
    boss_ui_node        = nil;--bossUI节点(关联 boss当前血量 boss总血量 boss血量斜杠 boss血条进度条 boss血条 ..)
    bossCurBlood_number = nil; -- boss当前血量
    bossBlood_number    = nil; --boss总血量
    boss_xiegang        = nil;--boss血量斜杠
    boss_xiegang_path   = "zhandou_xiexian.png"; --boss血量斜杠
    bossBloodProgress   = nil; -- boss血条进度条
    bossBloodProgress_path = "boss_xuetiao_02.png";--boss血条
    bossBloodBg         = "boss_xuetiao_01.png";--boss血条背景图

    boss_view               = nil;--猛戳屏幕
    boss_view_path          = "boss_mengchuopingmu.png";
    boss_injure_frame_path  = "boss_shaoushangtixing.png";

    --时间倒计时
    boss_time_label     = nil;--boss时间对象
}

local meta = GameSceneUi

local GameM = require "src/GameScene/GameM"
local leader2 = require "src/leader/leader2/leader2"
local UI    = GameM.UI
local BUTTON = GameM.BUTTON

---------------public
---------------public
---------------public
---------------public
--应该需要传参数
function meta:init(heroName)
    
    --{"res/gameIn/UiAndButton/zhandou_ui_button.plist","res/gameIn/UiAndButtonzhandou_ui_button.png"};--战斗场景ui and button
     --cc.SpriteFrameCache:getInstance():addSpriteFrames("res/gameIn/UiAndButton/zhandou_ui_button.plist","res/gameIn/UiAndButton/zhandou_ui_button.png")

     self.heroName = heroName or "Teemo"

    self.mainLayer = cc.Node:create()
    self:initMainLayer()

    self:initUI()

    return self.mainLayer
end
---------------public
---------------public
---------------public
---------------public


--设置表现数字
--设置距离
--设置击杀怪物最大值
--设置当前击杀的怪物
--设置击杀boss的时间
--设置boss的总血量
--设置boss的当前血量
--设置英雄总血量
--设置英雄当前血量
--释放本层

--初始化UI信息
function meta:initUI()
    local GameModel = require "src/GameScene/GameM"
    self:setBiaoxianNumber(0)
    self:setJuliNumber(0)
    if GameM.Boss_Handler then
        self:setBossAllBlood(GameM.Boss_Handler:GetAllHp())
        self:setBossCurBlood(GameM.Boss_Handler:GetAllHp())--必须先初始化AllBlood，再初始化CurBlood
        self:setHeroCurBlood(GameM.Handler:getRole():GetCurHp())
    end
    
end
    
--设置与下一个宝箱剩余距离
function meta:setBoxJuLi(str)
    self.box_juli:setString(tostring(str))    
end
--设置表现数字
function meta:setBiaoxianNumber(str)
    --self:setHeroJiaXie()
    self.biaoxian_number:setString(tostring(str))
    local pos_x = self.biaoxian:getPositionX()+self.biaoxian:getContentSize().width
    self.biaoxian_number:setPositionX(pos_x)
end
--设置距离
function meta:setJuliNumber(str)
    self.juli_number:setString(tostring(str))    
end
--设置boss的总血量
function meta:setBossAllBlood(str)
    self.bossBlood_number:setString(tostring(str))
end
--设置boss的当前血量
function meta:setBossCurBlood(str)
    --boss当前血量数字
    self.bossCurBlood_number:setString(str)
    self.bossCurBlood_number:setPosition(self.boss_xiegang:getPositionX() - self.bossCurBlood_number:getLayoutSize().width,-12)
    --计算百分比
    local curBlood = tonumber(str)
    local allBlood = tonumber(self.bossBlood_number:getString())
    local pecent = curBlood*100/allBlood
    self.bossBloodProgress:setPercentage(pecent)
    self.boss_percent_num:setString(math.floor(pecent))
    --同步boss头像百分比
    local percent_x = self.boss_head:getPositionX() + self.boss_head:getContentSize().width/2 - self.boss_percent_num:getLayoutSize().width/2
    self.boss_percent_num:setPosition(percent_x,465)

end

--设置英雄当前血量
function meta:setHeroCurBlood(str)
    --str = math.floor(str)
    --self.heroCurBlood:setString(tostring(str))
    local curBlood = tonumber(str)
    local allBlood = GameM.Handler:getRole():GetHp()--tonumber(self.heroAllBlood:getString())
    self.heroBloodProgress:setPercentage(curBlood*100/allBlood)
end
--设置英雄当前加血进度条
function meta:setHeroJiaXie(add_metre)

    if GameM:GetGameSetup() ~= GAME_STEP.game_boss then
        ---[[如果按时间计算jiaxue_all就是时间 按距离则是距离 以此类推
        self.jiaxue_number = self.jiaxue_number + add_metre
        if self.jiaxue_number >= self.jiaxue_all then
            self.jiaxue_number = 0
            --为场景生成动态血瓶
            GameM:createDynamicHp()
        --else
        --    self.jiaxue_number = self.jiaxue_number + add_metre
        end
        local width_percent = self.jiaxue_number/self.jiaxue_all*100
        local percent = math.floor(width_percent)
        self.jiaxue:setPercentage(percent)
        local percent_x = self.jiaxue:getBoundingBox().x+self.jiaxue:getContentSize().width*self.jiaxue:getPercentage()/100
        self.jiaxue_renwu:setPosition(cc.p(percent_x,3))
        --]]
    end
    
end
--获取英雄当前加血进度条
function meta:getHeroJiaXie()
    return self.jiaxue:getPercentage()
end
--设置英雄当前进入奖励模式进度条
function meta:setHeroRewardProgress()
    if g_boss ~= 0 then
        ---[[boss奖励模式
        if GameM:GetGameSetup() ~= GAME_STEP.game_boss then
            local percent = tostring(math.floor(self.change_scene_number/self.change_scene_all_pecent*100))
            self.change_scene_progress:setPercentage(percent)
            --cclog("percent==================================" ..percent)
            self.change_scene_percent_number:setString(percent)
            local layout_size = self.change_scene_percent_number:getLayoutSize()
            local pos_x = self.change_scene_percent:getPositionX()
            self.change_scene_percent_number:setPosition(cc.p(pos_x-layout_size.width,0))
        else
            self.change_scene_progress:setPercentage(0)
            self.change_scene_percent_number:setString("0")
        end
        --]]
    end
    



    --[[金币奖励模式
    if GameM:GetGameSetup() ~= GAME_STEP.game_reward then
        local percent = tostring(math.floor(self.change_scene_number/self.change_scene_all_pecent*100))
        self.change_scene_progress:setPercentage(percent)
        self.change_scene_percent_number:setString(percent)
        local layout_size = self.change_scene_percent_number:getLayoutSize()
        local pos_x = self.change_scene_percent:getPositionX()
        self.change_scene_percent_number:setPosition(cc.p(pos_x-layout_size.width,0))
    else
        
        self.change_scene_progress:setPercentage(0)
        self.change_scene_percent_number:setString("0")
    end
    --]]
end
--获取英雄当前加血数值
function meta:getHeroJiaXie()
    return self.jiaxue:getPercentage()
end

--获取英雄当前进入奖励模式进度条
function meta:getHeroRewardProgress()
    return self.change_scene_percent_number:getPercentage()
end
--设置进入奖励模式的数值
function meta:setChangeScenePercentNumber(change_scene_number)
    if g_userinfo.leader <= LEADER_ENUM.leader0 then
        
    else
        if g_boss == 0 then
            return
        end
    end
    

    --boss奖励
    if GameM:GetGameSetup() ~= GAME_STEP.game_boss and change_scene_number ~= nil then
        if self.change_scene_number >= self.change_scene_all_pecent then
            self.change_scene_number = 0
            self.change_scene_progress:setPercentage(self.change_scene_number)
            self.change_scene_percent_number:setString("0")

            self.change_scene_reward_number = 0
            --转换场景
            GameM.Handler:getRole():ChangeSceneStart()
            --cclog("行号 ====== " ..260)
        else
            self.change_scene_number = self.change_scene_number + change_scene_number
        end
    
    --boss模式
    elseif GameM:GetGameSetup() == GAME_STEP.game_boss then
        --cclog("self.change_scene_reward_number ======= " ..self.change_scene_reward_number)
        if self.change_scene_reward_number >= self.change_scene_reward_all_pecent then
            self.change_scene_reward_number = 0
            self.boss_time_label:setVisible(false)
             --置换角色状态(因为角色在打完boss后瞬间触发转化场景 来不及播放完攻击动作就被打断 所以进入不了动画回调置换状态 在这里置换)
            if GameM.Handler:getRole():GetAttack() then
                GameM.Handler:getRole():SetRun()
                GameM.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                --cclog("地面攻击回调")
            end

            --转换场景
            GameM.Handler:getRole():ChangeSceneStart()
            --cclog("行号 ====== " ..272)
        else
            
            --倒计时
            self.change_scene_reward_frame  = self.change_scene_reward_frame - g_frame/60
            if self.change_scene_reward_frame <= 0 then
                self.change_scene_reward_number = self.change_scene_reward_number + 1
                self.change_scene_reward_frame = 100
            end
            local calc = self.change_scene_reward_all_pecent-self.change_scene_reward_number
            --local minute = math.floor(calc/60)
            --local second = calc-minute*60
            local ms     = math.floor(self.change_scene_reward_frame)
            --cclog("minute ======= " ..minute)
            --cclog("second ======= " ..second)
            local str_time = string.format("%02d:%02d",calc,ms)
            self.boss_time_label:setString(str_time)

            --新手引导
            if g_userinfo.leader <= LEADER_ENUM.leader0 then
                if leader2.leader_type then
                    GameM:showLightEx()--光圈出现后才运行
                    GameM:leaderUpdateEx(self.mainLayer)
                else
                    GameM:showLight()--光圈出现后才运行
                    --原引导
                    if not GameM.is_js and self.change_scene_reward_number >= 5 then--7秒后执行动画
                        GameM.is_js = true
                        GameM:jsShow(self.mainLayer)
                    end
                    GameM:leaderUpdate(self.mainLayer)
                end
                
            end
            
        end
        --cclog("self.change_scene_reward_number ======== " ..self.change_scene_reward_number)

    -----------------------------------------------------------
    --[[金币奖励模式
    elseif GameM:GetGameSetup() == GAME_STEP.game_reward then
         if self.change_scene_reward_number >= self.change_scene_reward_all_pecent then
            self.change_scene_reward_number = 0
            --转换场景
            GameM.Handler:getRole():ChangeSceneStart()
        else
            self.change_scene_reward_number = self.change_scene_reward_number + change_scene_number
        end
        --self.change_scene_progress:setPercentage(0)
        --self.change_scene_percent_number:setString("0")
    --]]
    end
end

--更换boss模式所需UI
function meta:replaceNormalUI(is_visible)
    --普通UI
    self.change_scene_bg:setVisible(is_visible)--进度条底图
    self.change_scene_progress:setVisible(is_visible)--进度条
    self.change_scene_start:setVisible(is_visible)--进度条星星
    self.change_scene_percent:setVisible(is_visible)--进度条百分号
    self.change_scene_percent_number:setVisible(is_visible)--进度条数字
    --bossUI
    self:createBossView(is_visible)--猛搓屏幕
     
end
--猛搓屏幕
function meta:createBossView(is_visible)
    if is_visible then
        if self.boss_view then
            self.boss_view:setVisible(false)
        end

    else
        --隐藏普通UI显示BossUI
        if self.boss_view then
            self.boss_view:setVisible(true)
        end
    end
    
    
end
--获取进入奖励模式的数值
function meta:getChangeScenePercentNumber()
    return self.change_scene_number
end
--释放本层
function meta:release()
    self.mainLayer:removeFromParent()
end

---------------private
---------------private
---------------private
--------------------------------------------------------------高层
function meta:initMainLayer()
    --左上角头像
    local photo = self:createPhoto()    --英雄
    self.mainLayer:addChild(photo)

    --左上角 buff下面的表现
    local biaoxian = self:createBiaoxian()
    self.mainLayer:addChild(biaoxian)
    --距离
    local juli = self:createJuli()
    self.mainLayer:addChild(juli)
    --宝箱位置
    --local box = self:createBox()
    --self.mainLayer:addChild(box)
    --加血进度
    local jiaxue = self:createJiaXue()
    self.mainLayer:addChild(jiaxue)
    --动态宝箱
    self.dynamic_box = nil
    self.box_visible = nil
    --self:updateDynamicBox()
    --与box距离
    self.box_juli = nil
    --self.box_juli = self:createBoxJuli()
    --self.mainLayer:addChild(self.box_juli)
    --转化场景进度条
    local change_scene = self:createChangeProgress()
    self.mainLayer:addChild(change_scene)

    --boss
    self.boss_head_node = self:createBossState()
    self.mainLayer:addChild(self.boss_head_node)
    --bossState:setVisible(false)

    --bossUI
    self.boss_ui_node = self:createBossUI()
    self.mainLayer:addChild(self.boss_ui_node)
    --self.boss_ui_node:setAnchorPoint(1,0)
    self.boss_ui_node:setVisible(false)

    --Boss时间倒计时
    self.boss_time_label  = ccui.TextAtlas:create()
    self.boss_time_label:setPosition(472,454)
    self.boss_time_label:setProperty("00:00","res/ui/gameIn/font/font_60.png",45,58,"+")
    self.mainLayer:addChild(self.boss_time_label)
    self.boss_time_label:setVisible(false)
    --self.boss_time_label:setString("00:00")
    --self:registerMove(self.boss_time_label)

    --是否在新手引导里
    --新手引导
    if g_userinfo.leader <= LEADER_ENUM.leader0 then
        self.change_scene_reward_all_pecent = self.leader_time--新手引导打boss时间
    end
    


    --猛搓屏幕
    self.boss_view = cc.Sprite:createWithSpriteFrameName(self.boss_view_path)
    self.boss_view:setPosition(g_visibleSize.width/2,g_visibleSize.height/2)
    local fade_out = cc.FadeOut:create(0.5)
    local fade_in  = fade_out:reverse()
    local seq = cc.Sequence:create(fade_out,fade_in)
    self.boss_view:runAction(cc.RepeatForever:create(seq))
    self.mainLayer:addChild(self.boss_view,10)
    self.boss_view:setVisible(false)


end

--------------------------------------------------------------模块层
function meta:createPhoto()
    local photo = cc.Node:create()
    photo:setPosition(cc.p(118,550))
    --self:registerMove(photo)

    --头像
    local head_path 
    if self.heroName == "Ahri" then 
        head_path = UI.photoHead_path[1]
    elseif self.heroName == "Ezreal" then
        head_path = UI.photoHead_path[2]
    elseif self.heroName == "Garen" then
        head_path = UI.photoHead_path[3]
    elseif self.heroName == "JS" then
        head_path = UI.photoHead_path[4]
    elseif self.heroName == "Teemo" then
        head_path = UI.photoHead_path[5]
    elseif self.heroName == "zhaoxin" then
        head_path = UI.photoHead_path[6]
    end
    local head = cc.Sprite:createWithSpriteFrameName(head_path)
    head:setPosition(cc.p(-67,14))
    head:setScale(1)
    photo:addChild(head,UI.photoHead_Z)
    --self:registerMove(head)

    --血条底图
    self.heroBloodBg = cc.Sprite:createWithSpriteFrameName(UI.photoBloodBack_path)
    photo:addChild(self.heroBloodBg,UI.photoBlood_Z)
    self.heroBloodBg:setPosition(cc.p(136,12))
    --self:registerMove(self.heroBloodBg)

    --血条
    self.heroBloodProgress = self:createBlood()
    photo:addChild(self.heroBloodProgress,UI.photoBlood_Z)
    self.heroBloodProgress:setPosition(cc.p(136,12))
    --to1 = cc.ProgressTo:create(5, 100)
    --self.blood:runAction(to1)
    self.heroBloodProgress:setPercentage(100)
    --self:registerMove(self.heroBloodProgress)

    --英雄总血量
    --self.heroAllBlood  = ccui.TextAtlas:create()
    --self.heroAllBlood:setVisible(false)
    --self.heroAllBlood:setPosition(cc.p(55,16))
    --self.heroAllBlood:setProperty("","res/gameIn/font/font_20.png",16,24,"0")
    --photo:addChild(self.heroAllBlood,3)
    --self.heroAllBlood:setString("150")
    --self:registerMove(self.heroAllBlood)

    --英雄当前血量
    --self.heroCurBlood = self.heroAllBlood:clone()
    --self.heroCurBlood:setVisible(false)
    --self.heroCurBlood:setPosition(cc.p(-8,17))
    --photo:addChild(self.heroCurBlood,3)

    --斜杠
    --local xiegang = cc.Sprite:createWithSpriteFrameName(UI.xiegang_path)
    --xiegang:setVisible(false)
    --xiegang:setPosition(cc.p(22,17))
    --photo:addChild(xiegang,3)
    --self:registerMove(xiegang)
    return photo
end


function meta:createBiaoxian()
    self.biaoxian = cc.Sprite:createWithSpriteFrameName(UI.biaoxian_path)
    self.biaoxian:setPosition(cc.p(39,610))
    --self:registerMove(biaoxian)


    self.biaoxian_number  = ccui.TextAtlas:create()
    self.biaoxian_number:setPosition(cc.p(self.biaoxian:getPositionX()+self.biaoxian:getContentSize().width,14))
    self.biaoxian_number:setProperty("","res/ui/gameIn/font/font_20.png",16,24,"0")
    self.biaoxian:addChild(self.biaoxian_number)
    self.biaoxian_number:setString("10000")
    --self:registerMove(self.biaoxian_number)

    return self.biaoxian
end
function meta:createJinDu()
    local change_scene_percent_number  = ccui.TextAtlas:create()
    change_scene_percent_number:setProperty("","res/ui/gameIn/font/font_20.png",16,24,"0")
    change_scene_percent_number:setString("0")
    --self:registerMove(change_scene_percent_number)
    
    return change_scene_percent_number
end

--------------------------------------------------------------功能层、小模块层
function meta:createBlood()
    local blood = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(UI.photoBlood_path))
    blood:setMidpoint(cc.p(0, 1))
    blood:setBarChangeRate(cc.p(1,0))
    blood:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    return blood
end
function meta:createAddHpProgress()
    local add_hp = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(UI.jiaxie_path))
    add_hp:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    add_hp:setMidpoint(cc.p(0,0))
    add_hp:setBarChangeRate(cc.p(1,0))
    add_hp:setPercentage(0)
    --add_hp:setReverseProgress()
    --add_hp:setReverseDirection(false)--顺逆时
    return add_hp
end
function meta:createProgress()
    local change_progress = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(UI.zhandou_jindutiao))
    change_progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    change_progress:setMidpoint(cc.p(0,0))
    change_progress:setBarChangeRate(cc.p(1,0))
    change_progress:setPercentage(0)
    --add_hp:setReverseProgress()
    --add_hp:setReverseDirection(false)--顺逆时
    return change_progress
end

function meta:createChangeProgress()
     local node = cc.Node:create()
     --self:registerMove(node)
     node:setPosition(cc.p(469,74))


     self.change_scene_bg = cc.Sprite:createWithSpriteFrameName(UI.zhandou_jindutiao_ground)
     self.change_scene_bg:setPosition(cc.p(0,0))
     node:addChild(self.change_scene_bg,UI.jiaxie_Z)
     --self:registerMove(self.change_scene_bg)

     self.change_scene_progress = self:createProgress()
     self.change_scene_progress:setPosition(cc.p(15,0))
     node:addChild(self.change_scene_progress,UI.jiaxie_Z)
     self.change_scene_number = 0
     self.change_scene_reward_number = 0
     --self:registerMove(self.change_scene_progress)

     self.change_scene_start = cc.Sprite:createWithSpriteFrameName(UI.zhandou_jindutiao_start)
     self.change_scene_start:setPosition(cc.p(-197,0))
     node:addChild(self.change_scene_start,UI.jiaxie_Z)
     --self:registerMove(self.change_scene_start)

     self.change_scene_percent = cc.Sprite:createWithSpriteFrameName(UI.persent_path)
     self.change_scene_percent:setPosition(cc.p(55,-1))
     node:addChild(self.change_scene_percent,UI.jiaxie_Z)
     --self:registerMove(self.change_scene_percent)

     self.change_scene_percent_number = self:createJinDu()
     local layout_size = self.change_scene_percent_number:getLayoutSize()
     local pos_x = self.change_scene_percent:getPositionX()
     self.change_scene_percent_number:setPosition(cc.p(pos_x-layout_size.width,0))
     node:addChild(self.change_scene_percent_number,UI.jiaxie_Z)
     --self:registerMove(self.change_scene_percent_number)

     --新手引导
     if g_userinfo.leader <= LEADER_ENUM.leader0 then
        self.change_scene_bg:setVisible(false)
        self.change_scene_progress:setVisible(false)
        self.change_scene_start:setVisible(false)
        self.change_scene_percent:setVisible(false)
        self.change_scene_percent_number:setVisible(false)
     end

     
     return node

end
function meta:createJiaXue()
    local node = cc.Node:create()
    node:setPosition(cc.p(167,525))
     --self:registerMove(node)

    self.jiaxue_bg = cc.Sprite:createWithSpriteFrameName(UI.jiaxiekuang_path)
    node:addChild(self.jiaxue_bg,UI.jiaxie_Z)
    self.jiaxue_bg:setPosition(cc.p(8,2))
    --self:registerMove(self.jiaxue_bg)

    self.jiaxue = self:createAddHpProgress()
    node:addChild(self.jiaxue,UI.jiaxie_Z)
    --self.jiaxue:setScaleX(0.8)
    self.jiaxue:setPosition(cc.p(0,0))
    --self:registerMove(self.jiaxue)

    self.jiaxue_renwu = cc.Sprite:createWithSpriteFrameName(UI.jiaxie_renwu)
    node:addChild(self.jiaxue_renwu,UI.jiaxie_Z)
    --self.jiaxue:setScaleX(0.8)
    local percent = self.jiaxue:getBoundingBox().x+self.jiaxue:getContentSize().width*self.jiaxue:getPercentage()/100
    self.jiaxue_renwu:setPosition(cc.p(percent,3))
    self.jiaxue_number = 0
    --self:registerMove(self.jiaxue_renwu)
    
    return node
end

--更新动态宝箱 提示剩余多少距离可以获取XX宝箱
function meta:updateDynamicBox(metre)
    --调整位置
    --self.dynamic_box = cc.Sprite:createWithSpriteFrameName(UI.box[1])
    --self.dynamic_box:setPosition(692,594)
    --self:registerMove(self.dynamic_box)
    --self.mainLayer:addChild(self.dynamic_box)
    
     --新手引导
     if g_userinfo.leader <= LEADER_ENUM.leader0 then
        return
     end

    ---[[
    local temp = 0
    local temp_metre = 0
    if GameM.Handler:getRole().box[BOX.platinum_status] == "0" or GameM.Handler:getRole().box[BOX.platinum_status] == "1" or metre >= self.box4_metre then

        temp = 4
    elseif GameM.Handler:getRole().box[BOX.gold_status] == "0" or GameM.Handler:getRole().box[BOX.gold_status] == "1" or metre >= self.box3_metre then

        temp = 3
        temp_metre = self.box4_metre - metre
    elseif GameM.Handler:getRole().box[BOX.silver_status] == "0" or GameM.Handler:getRole().box[BOX.silver_status] == "1" or metre >= self.box2_metre then

        temp = 2
        temp_metre = self.box3_metre - metre
    elseif GameM.Handler:getRole().box[BOX.bronze_status] == "0" or GameM.Handler:getRole().box[BOX.bronze_status] == "1" or metre >= self.box1_metre then

        temp = 1
        temp_metre = self.box2_metre - metre
    else

        temp = 0
        temp_metre = self.box1_metre - metre
    end

    

    if temp == 4 then --已经领取所有宝箱不必显示
        if self.dynamic_box then
            self.box_visible = temp
            self.dynamic_box:removeFromParent(true)
            self.dynamic_box = nil
            if self.box_juli then
                self.box_juli:removeFromParent(true)
                self.box_juli = nil
            end
        end
    elseif self.box_visible ~= temp then --与上一次不一样证明进阶了一个宝箱
        self.box_visible = temp
        if self.dynamic_box then
            self.dynamic_box:removeFromParent(true)
        end
        if not self.box_juli then
            self.box_juli = self:createBoxJuli()
            self.mainLayer:addChild(self.box_juli)
        end
        if self.box_visible == 0 then
            self.dynamic_box = cc.Sprite:createWithSpriteFrameName(UI.box[1])
        elseif self.box_visible == 1 then
            self.dynamic_box = cc.Sprite:createWithSpriteFrameName(UI.box[2])
        elseif self.box_visible == 2 then
            self.dynamic_box = cc.Sprite:createWithSpriteFrameName(UI.box[3])
        elseif self.box_visible == 3 then
            self.dynamic_box = cc.Sprite:createWithSpriteFrameName(UI.box[4])
        end
        --设置动态宝箱距离
        self.dynamic_box:setPosition(692,594)
        self.mainLayer:addChild(self.dynamic_box)
        --设置与box距离数字居中
        self.box_juli:setString(tostring(metre))
        local pos_x = self.dynamic_box:getPositionX()+self.dynamic_box:getContentSize().width/2
        local layout_width = self.box_juli:getLayoutSize().width
        self.box_juli:setPosition(cc.p(pos_x-layout_width/2,self.box_juli:getPositionY()))
    else
        if self.box_juli and self.dynamic_box then
            --设置与box距离数字居中
            self.box_juli:setString(tostring(temp_metre))
            local pos_x = self.dynamic_box:getPositionX()+self.dynamic_box:getContentSize().width/2
            local layout_width = self.box_juli:getLayoutSize().width
            self.box_juli:setPosition(cc.p(pos_x-layout_width/2,self.box_juli:getPositionY()))
        end
        
    end

    --]]
end
function meta:createBox()
    local node = cc.Node:create()
    --self:registerMove(node)
    node:setPosition(cc.p(560,607))

    --从左到右
    --宝箱1
    self.box1 = cc.Sprite:createWithSpriteFrameName(UI.box[1])
    self.box1:setPosition(cc.p(70,-3))
    node:addChild(self.box1)
    --self:registerMove(self.box1)
    --宝箱2
    self.box2 = cc.Sprite:createWithSpriteFrameName(UI.box[2])
    self.box2:setPosition(cc.p(138,-3))
    node:addChild(self.box2)
    --self:registerMove(self.box2)
    --宝箱3
    self.box3 = cc.Sprite:createWithSpriteFrameName(UI.box[3])
    self.box3:setPosition(cc.p(207,-3))
    node:addChild(self.box3)
    --self:registerMove(self.box3)
    --宝箱4
    self.box4 = cc.Sprite:createWithSpriteFrameName(UI.box[4])
    self.box4:setPosition(cc.p(273,-3))
    node:addChild(self.box4)
    --self:registerMove(box4)

    return node
end

function meta:createJuli()
    local node = cc.Node:create()
    --self:registerMove(node)
    node:setPosition(cc.p(365,607))
    --背景
    local bg = cc.Sprite:createWithSpriteFrameName(UI.juli_bg_path)
    node:addChild(bg)
    --距离两个字
    local word = cc.Sprite:createWithSpriteFrameName(UI.juli_word_path)
    word:setPosition(cc.p(-84,-2))
    node:addChild(word)
    --self:registerMove(word)
    --"米"字
    local mi = cc.Sprite:createWithSpriteFrameName(UI.juli_mi_path)
    mi:setPosition(cc.p(91,-2))
    node:addChild(mi)
    --self:registerMove(mi)

    --距离数字
    self.juli_number  = ccui.TextAtlas:create()
    self.juli_number:setPosition(cc.p(11,-2))
    self.juli_number:setProperty("","res/ui/gameIn/font/font_24.png",16,24,"0")
    node:addChild(self.juli_number)
    self.juli_number:setString("10000")
    --self:registerMove(self.juli_number)

    return node
end 

function meta:createBoxJuli()
    local box_juli = ccui.TextAtlas:create()
    box_juli:setProperty("","res/ui/gameIn/font/font_24.png",16,24,"0")
    box_juli:setString("1000")
    --box_juli:setVisible(false)
    box_juli:setPosition(cc.p(693,539))
    --self:registerMove(box_juli)

    return box_juli
end

function meta:createBossState()
    local node = cc.Node:create()
    node:setPosition(cc.p(0,0))
    --self:registerMove(node)

    if GameM.Boss_Handler then
        --boss头像
        self.boss_head = cc.Sprite:createWithSpriteFrameName(GameM.Boss_Handler:GetBossHead())
        self.boss_head:setAnchorPoint(0,0)
        self.boss_head:setPosition(877,494)
        node:addChild(self.boss_head)
        --self:registerMove(self.boss_head)
    
        --boss百分号数字
        self.boss_percent_num  = ccui.TextAtlas:create()
        self.boss_percent_num:setProperty("","res/ui/gameIn/font/font_20.png",16,24,"0")
        self.boss_percent_num:setAnchorPoint(0,0)
        node:addChild(self.boss_percent_num)
        self.boss_percent_num:setString("100")
        local percent_x = self.boss_head:getPositionX() + self.boss_head:getContentSize().width/2 - self.boss_percent_num:getLayoutSize().width/2
        self.boss_percent_num:setPosition(percent_x,465)
        --self:registerMove(self.boss_percent_num)

        --boss百分号
        self.boss_percent = cc.Sprite:createWithSpriteFrameName(self.boss_percent_path)
        self.boss_percent:setAnchorPoint(0,0)
        self.boss_percent:setPosition(percent_x+self.boss_percent_num:getLayoutSize().width,465)
        node:addChild(self.boss_percent)
        --self:registerMove(self.boss_percent)

    end

    return node
end
--boss血条数据
function meta:createBossUI()
    local node = cc.Node:create()
    node:setAnchorPoint(0,0)
    --node:setPosition(cc.p(g_visibleSize.width/2,g_visibleSize.height/2))

    if self.boss_percent_num then--boss不存在
        --boss血条背景
        local blood_bg = cc.Sprite:createWithSpriteFrameName(self.bossBloodBg)
        blood_bg:setPositionX(blood_bg:getContentSize().width/3)
        node:addChild(blood_bg)
        --self:registerMove(blood_bg)

        --boss血条
        self.bossBloodProgress = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName(self.bossBloodProgress_path))
        --self.bossBloodProgress:setAnchorPoint(0,0)
        self.bossBloodProgress:setPositionX(blood_bg:getPositionX())
        self.bossBloodProgress:setMidpoint(cc.p(0, 1))
        self.bossBloodProgress:setBarChangeRate(cc.p(1,0))
        self.bossBloodProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.bossBloodProgress:setPercentage(100)
        node:addChild(self.bossBloodProgress)
        --self:registerMove(self.bossBloodProgress)

        --boss斜杠
        self.boss_xiegang = cc.Sprite:createWithSpriteFrameName(self.boss_xiegang_path)
        self.boss_xiegang:setAnchorPoint(0,0)
        self.boss_xiegang:setPosition(-15+blood_bg:getPositionX(),-13)
        node:addChild(self.boss_xiegang)

        --boss总血量
        self.bossBlood_number = self.boss_percent_num:clone()
        self.bossBlood_number:setAnchorPoint(0,0)
        self.bossBlood_number:setPosition(self.boss_xiegang:getContentSize().width-15+blood_bg:getPositionX(),-12)
        node:addChild(self.bossBlood_number)
        self.bossBlood_number:setString("100")

        --boss当前血量
        self.bossCurBlood_number = self.boss_percent_num:clone()
        self.bossCurBlood_number:setAnchorPoint(0,0)
        node:addChild(self.bossCurBlood_number)
        self.bossCurBlood_number:setString("10000")
        self.bossCurBlood_number:setPosition(self.boss_xiegang:getPositionX() - self.bossCurBlood_number:getLayoutSize().width+blood_bg:getPositionX(),-12)
        --self:registerMove(self.bossCurBlood_number)
    
    end

    
    

    return node
end
--初始化新boss数据
function meta:updateBossUI()
    self.boss_head_node:removeFromParent()
    self.boss_ui_node:removeFromParent()

    self.boss_head_node = nil
    self.boss_ui_node   = nil

    self.boss_head_node = self:createBossState()--右上角
    self.mainLayer:addChild(self.boss_head_node)
    self.boss_ui_node   = self:createBossUI()--boss头顶
    self.boss_ui_node:setVisible(false)--不然在左下角显示
    self.mainLayer:addChild(self.boss_ui_node)

    self:setBossAllBlood(GameM.Boss_Handler:GetAllHp())
    self:setBossCurBlood(GameM.Boss_Handler:GetAllHp())--必须先初始化AllBlood，再初始化CurBlood
end
--boss打完 释放
function meta:releaseBossUI()
    self.boss_head_node:removeFromParent()
    self.boss_ui_node:removeFromParent()

    self.boss_head_node = nil
    self.boss_ui_node   = nil
end
--受伤框淡出
function meta:createBossInjured()
    --boss受伤框
    local boss_injure_frame = cc.Sprite:createWithSpriteFrameName(self.boss_injure_frame_path)
    boss_injure_frame:setAnchorPoint(0,0)
    boss_injure_frame:setPosition(0,0)
    self.mainLayer:addChild(boss_injure_frame)
    
    local function releaseFrame()
        boss_injure_frame:removeFromParent()
    end
    local fade_out = cc.FadeOut:create(0.5)
    local seq = cc.Sequence:create(fade_out,cc.CallFunc:create(releaseFrame))
    boss_injure_frame:runAction(seq)
end


--------------------------------------------------------------注册回调

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



return GameSceneUi