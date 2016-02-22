local BossModel = class("BossModel",function()
    return cc.Node:create()
end)
local meta = BossModel

--新手引导boss
meta.leaderVal =
{
    head_path    = "bosstouxiang_youling.png",
    ani_path     = "dg",
    boss_hp      = 100000,
    pos_x        = g_visibleSize.width*2/3,
    pos_y        = 180,
    scope_x      = 0,
    scope_y      = 0,
    scope_width  = 300,
    scope_height = 200
}

--所有boss属性
meta.bossVal = 
{
    --boss1
    {
        head_path    = "bosstouxiang_sanlang.png", 
        ani_path     = "dalang",
        boss_hp      = 3000,
        pos_x        = g_visibleSize.width*2/3,
        pos_y        = 182,
        scope_x      = 0,
        scope_y      = 0,
        scope_width  = 450,
        scope_height = 200
     },
    

    --boss2
    {
        head_path    = "bosstouxiang_youling.png",
        ani_path     = "dg",
        boss_hp      = 9000,
        pos_x        = g_visibleSize.width*2/3 - 100,
        pos_y        = 180,
        scope_x      = 0,
        scope_y      = 0,
        scope_width  = 300,
        scope_height = 200
     },
    

    --boss3
    {
        head_path    = "bosstouxiang_shitouren.png",
        ani_path     = "nanbaba",
        boss_hp      = 15000,
        pos_x        = g_visibleSize.width*2/3 - 50,
        pos_y        = 100,
        scope_x      = 0,
        scope_y      = 0,
        scope_width  = 300,
        scope_height = 300
     },

    --boss4
    {
        head_path    = "bosstouxiang_hongbuff.png",
        ani_path     = "hbf",
        boss_hp      = 30000,
        pos_x        = g_visibleSize.width*4/7,
        pos_y        = 182,
        scope_x      = 0,
        scope_y      = 0,
        scope_width  = 254,
        scope_height = 184
    }
}

meta.data = 
{
    boss_head    = nil;
    cur_hp       = nil;
    all_hp       = nil;
    pos_x        = nil;
    pos_y        = nil;
    scope_x      = nil;
    scope_y      = nil;
    scope_width  = nil;
    scope_height = nil;
    bullet_draw  = nil;

    boss_injure  = nil;--防近战英雄刷血 每次攻击一次有效
}
--引用和全局，初始化----------------------------------------------------------------------------------
local GameSceneUi = require "src/GameScene/GameSceneUi"

local visibleSize_width = g_visibleSize.width
local visibleSize_height = g_visibleSize.height
function meta:create()
    
    local self = meta.new()

    --根据id筛选boss
    local boss_path = nil
    local data = nil
    if g_userinfo.leader <= LEADER_ENUM.leader1 then
        boss_path = self.leaderVal.ani_path
        data = self.leaderVal
    else
        --g_boss = 3
        boss_path = self.bossVal[g_boss].ani_path
        data      = self.bossVal[g_boss]
    end


    self.ani = ccs.Armature:create(boss_path)
    self:addChild(self.ani)
    self.ani:getAnimation():play(ANIMATION_ENUM.run)

    

    --动画事件回调
	local function BossAnimationEvent(arm, eventType, movmentID)--动画,状态 ,时刻id(动画动作名字)
		if eventType == ccs.MovementEventType.complete then --动画不循环情况下 完成时调用
           
        end
    end
    self.ani:getAnimation():setMovementEventCallFunc(BossAnimationEvent)

    --属性赋值
    self.data.boss_head    = data.head_path
    self.data.cur_hp       = data.boss_hp
    self.data.all_hp       = data.boss_hp
    self.data.pos_x        = data.pos_x
    self.data.pos_y        = data.pos_y
    self.data.scope_x      = data.scope_x
    self.data.scope_y      = data.scope_y
    self.data.scope_width  = data.scope_width
    self.data.scope_height = data.scope_height

    self.boss_injure       = false --每次攻击仅一次有效 true的时候允许受伤 受伤后置换为false
    
    self:setContentSize(self.ani:getContentSize().width,self.ani:getContentSize().height)
    self.ani:setAnchorPoint(self.data.scope_x,self.data.scope_y)
    self:setAnchorPoint(self.data.scope_x,self.data.scope_y)
    self:setPosition(self.data.pos_x,self.data.pos_y)

    
    --self.bullet_draw = cc.DrawNode:create()
    
    return self
end
--------------------------------------------------------------
--获取数据
--------------------------------------------------------------
function meta:GetAni()
    return self.ani
end
--设置总血量
function meta:SetAllHp(hp)
    self.data.all_hp = hp
end
--获取总血量
function meta:GetAllHp()
    return self.data.all_hp
end
--设置当前血量
function meta:SetCurHp(hp)
    self.data.cur_hp = hp
end
--获取当前血量
function meta:GetCurHp()
    return self.data.cur_hp
end
--获取boss头像
function meta:GetBossHead()
    return self.data.boss_head
end
--获取boss碰撞区域
function meta:GetBossRect()
    if g_userinfo.leader <= LEADER_ENUM.leader1 then
        return cc.rect(self:getPositionX(),self:getPositionY(),self.data.scope_width,self.data.scope_height)
    else
        return cc.rect(self:getPositionX() - self:getContentSize().width/2,self:getPositionY(),self.data.scope_width,self.data.scope_height)
    end
    
end
--设置每次攻击一次有效
function meta:setBossInjured(is_injured)
    self.boss_injure = is_injured
end
--获取每次攻击一次有效
function meta:getBossInjured()
    return self.boss_injure
end
--------------------------------------------------------------
--方法函数
--------------------------------------------------------------
--彪出伤害数字
function meta:setInjureString(injure)
    
    
    local label = ccui.TextAtlas:create()
    label:setProperty(tostring(injure),"res/ui/gameIn/font/font_60.png",45,58,"+")
    label:setRotationSkewY(180)

    if g_userinfo.leader <= LEADER_ENUM.leader1 then
        label:setVisible(false)
    end
    
    label:setAnchorPoint(0,0)
    label:setPosition(200,100)
    self:addChild(label)

    --释放数字
    local function releaseString()
        --label:stopAllActions()
        label:removeFromParent()
    end
    --动作组合
    local fade_out = cc.FadeOut:create(2)--淡出
    local move_by = cc.MoveBy:create(2,cc.p(100,100))--上升
    local spawn = cc.Spawn:create(fade_out,move_by)
    local sequence = cc.Sequence:create(spawn,cc.CallFunc:create(releaseString))
    label:runAction(sequence)

    --同步bossUI
    local boss_die = false
    self.data.cur_hp = self.data.cur_hp - injure
    --cclog("self.data.cur_hp ====== " ..self.data.cur_hp)
    --cclog("#self.bossVal ====== " ..#self.bossVal)
    if self.data.cur_hp <=0 then
        self.data.cur_hp = 0
        g_boss = g_boss + 1

        if g_boss > #self.bossVal or g_userinfo.leader <= LEADER_ENUM.leader1 then
            g_boss = 0
        end
        boss_die = true
    end
     --cclog("g_boss ====== " ..g_boss)
    if not boss_die then
        GameSceneUi:setBossCurBlood(self.data.cur_hp)
        GameSceneUi:createBossInjured()--创建boss受伤框
    elseif g_boss ~= 0 then
        --创建新boss
        local GameView = require "src/GameScene/GameV"
        GameView:releaseBoss()--释放boss
        GameView:initBoss()------
        --重置boss死亡状态
        local GameModel = require "src/GameScene/GameM"
        GameModel:setBossDie(false)

        GameSceneUi:updateBossUI()--更新bossUI--------
        GameSceneUi.change_scene_reward_number = 0--刷新秒数


        --置换角色状态(因为角色在打完boss后瞬间触发转化场景 来不及播放完攻击动作就被打断 所以进入不了动画回调置换状态 在这里置换)
        if GameModel.Handler:getRole():GetAttack() then
            GameModel.Handler:getRole():SetRun()
            GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
            --cclog("地面攻击回调")
        end

        --转换场景
        GameModel.Handler:getRole():ChangeSceneStart()

    elseif g_boss == 0 then
        
        if g_userinfo.leader <= LEADER_ENUM.leader1 then--新手引导
            --g_isPause = true
            local GameView = require "src/GameScene/GameV"
            GameView:releaseBoss()--释放boss
            --重置boss死亡状态
            local GameModel = require "src/GameScene/GameM"
            GameModel:setBossDie(true)
            GameSceneUi:releaseBossUI()
            GameSceneUi.change_scene_reward_number = 0--刷新秒数
            GameSceneUi.boss_time_label:setVisible(false)--隐藏时间
            GameSceneUi:createBossView(true)--隐藏猛戳

            --[[光圈出现
            local light = ccs.Armature:create("terminal")--光圈
            light:getAnimation():play(ANIMATION_ENUM.wait)
            light:setAnchorPoint(0,0)
            local light_y = GameModel.js:getPositionY()-GameModel.js:getContentSize().height/3
            light:setPosition(visibleSize_width,light_y)
            cc.Director:getInstance():getRunningScene():addChild(light,99)
        
            local function endLight()
                light:removeFromParent()
                GameModel.js_frame:removeFromParent()
                GameModel.js_label:removeFromParent()
                GameModel.js:removeFromParent()
                GameModel.is_exit = true
                --js_frame:setVisible(true)
                --js_label:setVisible(true)
                --js_label:setString("勇士，合作愉快，期待和您再次合作，再见。")
                --js_label:setPosition(0,js_frame:getPositionY())
            end

            local the_end = cc.CallFunc:create(endLight)
            local light_time = (visibleSize_width - GameModel.js:getPositionX())/GameModel:GetLayerSpeed()*60
            local arrive = cc.Sequence:create(cc.MoveBy:create(light_time,cc.p(GameModel.js:getPositionX()-visibleSize_width,0)),the_end)
            light:runAction(arrive)
            --]]
            --GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.wait)
            ------------------------------------------------------------------------------------------------------
        else
            --创建新boss
            local GameView = require "src/GameScene/GameV"
            GameView:releaseBoss()--释放boss
             --重置boss死亡状态
            local GameModel = require "src/GameScene/GameM"
            GameModel:setBossDie(false)

            GameSceneUi:releaseBossUI()
            GameSceneUi.change_scene_reward_number = 0--刷新秒数

            --置换角色状态(因为角色在打完boss后瞬间触发转化场景 来不及播放完攻击动作就被打断 所以进入不了动画回调置换状态 在这里置换)
            if GameModel.Handler:getRole():GetAttack() then
                GameModel.Handler:getRole():SetRun()
                GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                --cclog("地面攻击回调")
            end

            --转换场景
            local GameModel = require "src/GameScene/GameM"
            GameModel.Handler:getRole():ChangeSceneStart()

        end
    elseif boss_die then
        
    
    end
    
    

    return boss_die

    --[[
    local function createLabelAction(index,tick)
        local label = cc.LabelTTF:create("-" ..injure,"宋体",48)
        label:setVisible(false)
        label:setColor(cc.c3b(255,0,0))
        self.ani:addChild(label)

        local temp_pos = {}
        temp_pos.x = 0
        temp_pos.y = self.ani:getPositionY()+self.ani:getContentSize().height/2+20
        label:setPosition(temp_pos.x,temp_pos.y)
        
        --显示数字
        local function showLabel()
            label:setVisible(true)
            local GameUIView = require "src/GameScene/GameUIV"
            local GameView = require "src/GameScene/GameV"
            if self.monster_cur_hp <= 0 then
                --boss死亡
                self.monster_cur_hp = 0
            else
                self.monster_cur_hp = self.monster_cur_hp - GameView.role.atk
                GameUIView.boss_hp_percent = self.monster_cur_hp/self.monster_hp*100
            end
            GameUIView.boss_label_cur_hp:setString(self.monster_cur_hp)
            GameUIView.boss_hp_progressTimer:setPercentage(GameUIView.boss_hp_percent)
        end
        --释放数字
        local function releaseString()
            --label:stopAllActions()
            table.insert(self.injure_figure_table,label)
        end
        --动作组合
        local spawn = cc.Spawn:create(fade_out,move_to)
        local delay = cc.DelayTime:create(tick*(index-1)) or cc.DelayTime:create(0.5)
        local sequence = cc.Sequence:create(delay,cc.CallFunc:create(showLabel),spawn,cc.CallFunc:create(releaseString))
        label:runAction(sequence)
    end
    
  
    
    local n = num or 1
    local detime = delay_time or 0
    for i=1,n do
        createLabelAction(i,detime)
    end
    --]]
    
    

    --local action = nil
    --if num ~= nil then
    --    local delay_time = cc.DelayTime:create(delay_time)
    --    action = cc.Sequence:create(delay_time,sequence)
    --    for i = 1,num do
    --        label:runAction(action)
    --    end

    --else
    --    action = sequence
    --    label:runAction(action)
    --end

    --local action = cc.Repeat:create(sequence,3)
    --文字升起和淡出同时进行  之后释放自己
    --label:runAction(action)
    
end

return BossModel

