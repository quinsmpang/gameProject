local GameView = 
{
    mainLayer = nil; --本图层

    map_layer_list    = {};--所有层 对象列表
    reward_layer_list = {};--奖励模式所有层 对象列表


    
    -------用于检测帧速率均值情况-------
    frame_rate  = 0;--帧速率 每秒加总一次 30秒计算均值
    frame_num   = 0;--计时器 每秒记录一次 30秒被frame_rate除
    frame_clock = 0;--用于计算时间
    frame_calc  = 0;--用于安卓上计算
    role_die    = 0;--角色夹死或者掉坑死后剩余退出时间
    ----------------------------

    ----------压力测试专用------
    batch_a       = nil;--纹理1给SpriteBatchNode用
    batch_b       = nil;--纹理2给SpriteBatchNode用
    render_type   = 0;--更新压力测试类型 1：SpriteBatchNode    2：AutoBatching
    ----------------------------

    ----------地图编辑测试专用------
    isRepeat             = true;--地图编辑是否循环
    
    game_time_label      = nil;--游戏时间文字
    game_time            = nil;--游戏时间
    game_frame           = nil;--游戏帧速率

    game_speed_label     = nil;--游戏全局速度文字
    font_label           = nil;--显示当前循环状态

    ----------------------------
    is_draw       = true;--画出碰撞区域
    drawbone      = nil;--画笔

}--@ 游戏逻辑主图层
local  meta = GameView
----引用和全局，初始化----------------------------------------------------------------------------------
--require "Opengl"--用于画图
local GameModel = require "src/GameScene/GameM"
local RoleModel = require "src/Role/RoleM"
local BossModel = require "src/Boss/BossM"
local MonsterModel = require "src/monster/MonsterM"
local ValueTool = require "src/tool/value"
local Rand = require "src/tool/rand"
local GameSceneUi = require "src/GameScene/GameSceneUi"
local GameRewardM = require "src/GameScene/GameRewardM"
local leader2 = require "src/leader/leader2/leader2"
local visibleSize_width = g_visibleSize.width
local visibleSize_height = g_visibleSize.height
function meta:init( ... )
    
    meta.mainLayer = cc.Layer:create()

    --初始化游戏数据
    meta:initGame()

    --启动更新
    meta:LaunchUpdate()


    --压力测试
    --meta:pressureTest()

    --显示碰撞区域
    --meta:ShowCollide()
    --meta:changeFrame()
    return meta.mainLayer
end
--显示碰撞区域
function meta:ShowCollide()
    
    local function DrawCollide()
        meta.is_draw = not meta.is_draw
    end

    local draw_btn = cc.MenuItemFont:create("draw")
    draw_btn:registerScriptTapHandler(DrawCollide)
    draw_btn:setPositionY(100)

    --菜单
    local menu = cc.Menu:create(draw_btn)
    menu:setPosition(visibleSize_width - 200,visibleSize_height/3)
    meta.mainLayer:addChild(menu,100)

end
--切换帧速率
function meta:changeFrame()
    
    local function frame30()--30
        g_frame = 30
        GameModel.Handler:AdjustFrame(g_frame)
        GameModel:SetLayerSpeed(7)
        GameModel:SetGlobalSpeed(0)
    end
    local function frame60()--60
        g_frame = 60
        GameModel.Handler:AdjustFrame(g_frame)
        GameModel:SetLayerSpeed(7)
        GameModel:SetGlobalSpeed(0)
    end

    --local function die()--
    --    GameModel.Handler:getRole():SetCurHp(0)
    --end

    --frame30
    local frame30_btn = cc.MenuItemFont:create("30帧")
    frame30_btn:registerScriptTapHandler(frame30)
    frame30_btn:setPositionY(300)
    --frame60
    local frame60_btn = cc.MenuItemFont:create("60帧")
    frame60_btn:registerScriptTapHandler(frame60)
    frame60_btn:setPositionY(400)
    
    ----die
    --local die_btn = cc.MenuItemFont:create("死亡")
    --die_btn:registerScriptTapHandler(die)
    --die_btn:setPositionY(100)

    --菜单
    local menu = cc.Menu:create(frame60_btn,frame30_btn,die_btn)
    menu:setPosition(visibleSize_width - 200,visibleSize_height/4)
    meta.mainLayer:addChild(menu,100)
end
--画层范围
function meta:DrawLayers()
    if meta.drawbone then
        meta.drawbone:clear()
        for i=1,#meta.map_layer_list do
            local points = 
            {
                cc.p(meta.map_layer_list[i]:getPositionX(),meta.map_layer_list[i]:getPositionY()),--左下
                cc.p(meta.map_layer_list[i]:getPositionX()+meta.map_layer_list[i]:getContentSize().width,meta.map_layer_list[i]:getPositionY()),--右下
                cc.p(meta.map_layer_list[i]:getPositionX()+meta.map_layer_list[i]:getContentSize().width,meta.map_layer_list[i]:getPositionY()+meta.map_layer_list[i]:getContentSize().height),--右上
                cc.p(meta.map_layer_list[i]:getPositionX(),meta.map_layer_list[i]:getPositionY()+meta.map_layer_list[i]:getContentSize().height)--左上
            }
            meta.drawbone:drawPolygon(points, #points, cc.c4f(0,0,0,0),1,cc.c4f(0,0,1,1))
        end
    end
end
--画对象矩形
function meta:DrawObj(drawbone,left_down,right_down,right_up,left_up,str_name)
    --cclog("str_name ===== " ..str_name)
    drawbone:clear()
    local points = 
    {
        left_down,--左下
        right_down,--右下
        right_up,--右上
        left_up--左上
    }
    drawbone:drawPolygon(points, #points, cc.c4f(0,0,0,0),1,cc.c4f(0,0,1,1))
end
--初始化游戏数据
function meta:initGame()
    
    --meta.game_time = 0--游戏时间
    meta.frame_rate  = 0;--帧速率 每秒加总一次 30秒计算均值
    meta.frame_num   = 0;--计时器 每秒记录一次 30秒被frame_rate除
    meta.frame_clock = 0;--用于计算时间
    meta.frame_calc  = 0;--用于安卓上计算
    meta.role_die    = 0;--角色夹死或者掉坑死后剩余退出时间
    --游戏有准备状态
    --GameModel:SetGameSetup(GAME_STEP.game_start)--标识游戏开始
    
    --添加画图工具
    --meta.drawbone = cc.DrawNode:create()
    --meta.mainLayer:addChild(meta.drawbone,1000)
    GameModel:SetLayerSpeed(7)
    GameModel:SetGlobalSpeed(0)

    --初始化角色数据
    meta:initRole()

    --初始化boss数据
    meta:initBoss()

    --初始化障碍物
    meta:initObject()

    

    --写字
    --meta.game_time_label = cc.LabelTTF:create("帧速: 0 ","宋体",30)
    --meta.game_time_label:setColor(cc.c3b(255,0,0))
    --meta.game_time_label:setPosition(visibleSize_width/3,visibleSize_height*4/5-20)
    --meta.mainLayer:addChild(meta.game_time_label,9999)

end
--初始化角色数据
function meta:initRole()
    
    --GameModel.role = RoleModel.init()--初始化角色信息
    
    local temp_role = RoleModel.init()--初始化角色信息
    temp_role.ani = ccs.Armature:create(temp_role.res)--(GameModel.role.res)--创建动画对象--cc.Scale9Sprite:createWithSpriteFrameName("07CJYS05.png")
    require "src/Role/C_lolRunHero"
    GameModel.Handler = C_lolRunHero:create(temp_role)
    meta.mainLayer:addChild(GameModel.Handler,999)
    local role_range = GameModel.Handler:getRole():GetRoleScope()
    GameModel.Handler:getRole():GetAni():setAnchorPoint(role_range.run.x,role_range.run.y)--碰撞范围碰撞的时候设置
    GameModel.Handler:setPosition(cc.p(visibleSize_width/4+20,visibleSize_height))

    GameModel.Handler:setStdX(visibleSize_width/3)--设置相对位置 使角色自觉对位
    GameModel.Handler:addPhysicsBody()
    GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.wait)
    
    --护盾 zidun
    --GameModel.Handler:getRole().sprite_dun = cc.Scale9Sprite:createWithSpriteFrameName("dun.png")
    --GameModel.Handler:getRole().sprite_dun:setAnchorPoint(0.3,0)
    --GameModel.Handler:getRole().sprite_dun:setVisible(false)
    --GameModel.Handler:addChild(GameModel.Handler:getRole().sprite_dun)
    GameModel.Handler:getRole().sprite_dun = ccs.Armature:create("dun")
    GameModel.Handler:getRole().sprite_dun:getAnimation():play(ANIMATION_ENUM.run)
    GameModel.Handler:getRole().sprite_dun:setAnchorPoint(0.3,0)
    GameModel.Handler:getRole().sprite_dun:setScale(1.3)

    GameModel.Handler:getRole().sprite_dun:setVisible(false)
    GameModel.Handler:addChild(GameModel.Handler:getRole().sprite_dun)--让角色覆盖冲刺
    --冲刺
    GameModel.Handler:getRole().sprite_spurt = ccs.Armature:create("chonci")
    GameModel.Handler:getRole().sprite_spurt:getAnimation():play(ANIMATION_ENUM.run)
    GameModel.Handler:getRole().sprite_spurt:setAnchorPoint(0.8,0.3)
    GameModel.Handler:getRole().sprite_spurt:setVisible(false)
    GameModel.Handler:addChild(GameModel.Handler:getRole().sprite_spurt)--让角色覆盖冲刺
    GameModel.Handler:AdjustFrame(g_frame)
    
    --二跳动画
    GameModel.Handler:getRole().sprite_jump2 = ccs.Armature:create("jump2")
    GameModel.Handler:getRole().sprite_jump2:setAnchorPoint(0,0)
    GameModel.Handler:getRole().sprite_jump2:setVisible(false)
    meta.mainLayer:addChild(GameModel.Handler:getRole().sprite_jump2,OBJECT_RENDER_TAG.spurt)
    --动画事件回调
	local function JumpAnimationEvent(arm, eventType, movmentID)--动画,状态 ,时刻id(动画动作名字)
		if eventType == ccs.MovementEventType.complete then --动画不循环情况下 完成时调用
            if movmentID == ANIMATION_ENUM.run then
                GameModel.Handler:getRole().sprite_jump2:setVisible(false)
            end
        end
    end
    GameModel.Handler:getRole().sprite_jump2:getAnimation():setMovementEventCallFunc(JumpAnimationEvent)


    --GameModel.Handler:getRole().role_bullet 远程英雄专属 子弹列表
    if GameModel.Handler:getRole().glNode then
        meta.mainLayer:addChild(GameModel.Handler:getRole().glNode,1000)
    end
    if GameModel.Handler:getRole().bullet_draw then
        meta.mainLayer:addChild(GameModel.Handler:getRole().bullet_draw,1000)
    end

    --GameModel.Handler:setContentSize()
    GameModel.Handler:setScale(0.8)
    
    --GameModel.Handler:setScaleX(0.8)
    --GameModel.Handler:setScaleY(0.8)
    
    require "src/Role/C_Rect"
    GameModel.CollideHandler = C_Rect.new()


    --帧事件回调
	local function FrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
		--cclog("FrameEvent")
		if evt == "fun_act" then
            GameModel.Handler:getRole():Attack()
            GameModel.Handler:getRole():SetAttack()
            --cclog("fun_act")
        elseif evt == "fun_airact" then
            --cclog("fun_airact")
            GameModel.Handler:getRole():Attack()
        end
    end


    --动画事件回调
	local function AnimationEvent(arm, eventType, movmentID)--动画,状态 ,时刻id(动画动作名字)
        --cclog("self.movmentID = " ..movmentID)
		if eventType == ccs.MovementEventType.start then --动画开始时调用

        elseif eventType == ccs.MovementEventType.complete then --动画不循环情况下 完成时调用
            if movmentID == ANIMATION_ENUM.atk then
                if GameModel.Handler:getRole():GetAttack() then
                    GameModel.Handler:getRole():SetRun()
                    GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                    cclog("地面攻击回调")
                end
            elseif movmentID == ANIMATION_ENUM.jump_atk then
                GameModel.Handler:getRole():SetAirAttack(false)
                if GameModel.Handler:getRole():GetIsFloor() then--如果在地上
                    GameModel.Handler:getRole():SetRun()
                    GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                    cclog("在地上")
                end
            elseif movmentID == ANIMATION_ENUM.death then
                g_isPause = false
                --游戏结束
                GameModel:SetGameSetup(GAME_STEP.game_end)
                --给个黑色背景 因为会看见原来场景的背景
                 cc.Director:getInstance():getRunningScene():addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 255)),10)
                 --检测结算
                 meta:checkReasult()
            end
        elseif eventType == ccs.MovementEventType.loopComplete then --动画循环情况下不断被调用
            
        end
    end

    GameModel.Handler:getRole():GetAni():getAnimation():setFrameEventCallFunc(FrameEvent)--注册帧事件
    GameModel.Handler:getRole():GetAni():getAnimation():setMovementEventCallFunc(AnimationEvent)--注册动画事件

    
end
--初始化boss数据
function meta:initBoss()
    if g_boss ~= 0 then
        GameModel:setBossDie(false)
        GameModel.Boss_Handler = BossModel:create()
        GameModel.Boss_Handler:setAnchorPoint(0.5,0)
        GameModel.Boss_Handler:setRotationSkewY(180)
        GameModel.Boss_Handler:setVisible(false)
        meta.mainLayer:addChild(GameModel.Boss_Handler,99)

        if GameModel.Boss_Handler.bullet_draw then
            meta.mainLayer:addChild(GameModel.Boss_Handler.bullet_draw,1000)
        end
    end
    
    
end
--释放boss数据
function meta:releaseBoss()
    GameModel.Boss_Handler:removeFromParent()
    if GameModel.Boss_Handler.bullet_draw then
        GameModel.Boss_Handler.bullet_draw:removeFromParent()
    end
    GameModel.Boss_Handler = nil
end
--初始化障碍物
function meta:initObject()
    --拆分转化地图数据
    --GameModel:ConverData()
    --meta.isRepeat = true
    --GameModel:SetIsRepeat(meta.isRepeat)
    --创建对象到列表中
    meta:createObjectToList()
    

    --创建编辑器菜单
    --meta:EditMenuUI()
end
--********************************奖励模式********************************
--根据数据转化所有配置怪物信息
function meta:createRewardObjectToList()--定时器中时刻检测 60/1
    meta.reward_layer_list = {}
    local cur_map_id = 1--GameRewardM:GetCurMapId()--获取当前地图关卡
    GameRewardM:SetCurMapId(cur_map_id)
    local cur_mot_id = 1--GameRewardM:GetCurMotId()--获取当前地图关卡怪物id
    GameRewardM:SetCurMotId(cur_mot_id)
    local map_layer_index = 1--GameRewardM:GetLayerIndex()--获取当前层列表索引
    GameRewardM:SetLayerIndex(map_layer_index)
    if #meta.reward_layer_list == 0 then
        local map_layer = cc.Layer:create()
        map_layer:setAnchorPoint(0,0)--锚点
        map_layer:setPosition(0,0)
        map_layer:setContentSize(GameRewardM.map_data_list[cur_map_id].width,GameRewardM.map_data_list[cur_map_id].height)
        map_layer.pre_pos_x = map_layer:getPositionX()--第一次记录上一次位置
        table.insert(meta.reward_layer_list,map_layer)
        meta.mainLayer:addChild(map_layer,OBJECT_RENDER_TAG.reward_layer)
    end
    while(cur_map_id <= #GameRewardM.map_data_list) do--层数据
        while(cur_mot_id <= #GameRewardM.map_data_list[cur_map_id].value ) do--层怪物数据
            --获取数据结构(优化成拆分完成table直接赋值)
            local mot_obj = GameRewardM.split_data_list[cur_map_id][cur_mot_id]
            
            --此层坐标+怪物相对坐标
            if meta.reward_layer_list[map_layer_index]:getPositionX()+mot_obj:GetPosX() <= GameRewardM.create_range then

                local monster = MonsterModel:init()--初始化怪物信息

                --数据赋值
                GameRewardM:initMonster(monster,mot_obj)

                --创建ani
                GameRewardM:CreateAni(monster)

                --对怪物进行缩放
                GameRewardM:MonsterScale(monster)

                --对怪物初始行为处理
                GameRewardM:MonsterAction(monster)

                --放入列表
                GameRewardM:intoList(monster)

                --渲染批次tag
                local tag = GameRewardM:choiceResTag(monster)

                meta.reward_layer_list[map_layer_index]:addChild(monster.ani,tag)--把怪物放入此层
                if monster.glNode then
                    meta.reward_layer_list[map_layer_index]:addChild(monster.glNode,1000)
                end
            else
                
                return--因为是按顺序 因此后面的怪物一定不在范围
            end

            cur_mot_id = cur_mot_id + 1
            GameRewardM:SetCurMotId(cur_mot_id)
        end
        cur_map_id = cur_map_id + 1
        GameRewardM:SetCurMapId(cur_map_id)
    end
end
--动态更新创建怪物列表
function meta:updateRewardObjectInList()
    while (true) do
        --游戏是否开始
        if GameModel:GetGameSetup() == GAME_STEP.game_end then
            return
        end
        
        local cur_map_id = GameRewardM:GetCurMapId()--获取当前地图关卡
        local cur_mot_id = GameRewardM:GetCurMotId()--获取当前地图关卡怪物id
        local map_layer_index = GameRewardM:GetLayerIndex()--获取当前层列表索引
        while(cur_map_id <= #GameRewardM.map_data_list) do--层数据
            while(cur_mot_id <= #GameRewardM.map_data_list[cur_map_id].value ) do--层怪物数据
                --获取数据结构(优化成拆分完成table直接赋值)
                local mot_obj = GameRewardM.split_data_list[cur_map_id][cur_mot_id]
            
                 --此层坐标+怪物相对坐标
                if meta.reward_layer_list[map_layer_index]:getPositionX()+mot_obj:GetPosX() <= GameRewardM.create_range then
                 
                    local monster = MonsterModel:init()--初始化怪物信息

                    --数据赋值
                    GameRewardM:initMonster(monster,mot_obj)

                    --创建ani
                    GameRewardM:CreateAni(monster)

                    --对怪物进行缩放
                    GameRewardM:MonsterScale(monster)

                    --对怪物初始行为处理
                    GameRewardM:MonsterAction(monster)

                    --放入列表
                    GameRewardM:intoList(monster)
                       
                    --渲染批次tag
                    local tag = GameRewardM:choiceResTag(monster)

                    --把怪物放入此层
                    meta.reward_layer_list[map_layer_index]:addChild(monster.ani,tag)
                    --画笔
                    if monster.glNode then
                        meta.reward_layer_list[map_layer_index]:addChild(monster.glNode,1000)
                    end

                else
                    return--因为是按顺序 因此后面的怪物一定不在范围
                end

                cur_mot_id = cur_mot_id + 1
                GameRewardM:SetCurMotId(cur_mot_id)
            end

            --创建下一个层(默认创建的地图一定比屏幕宽 并且有怪物不在范围内)
            local map_layer = cc.Layer:create()
            map_layer:setAnchorPoint(0,0)--锚点
            local next_pos_x = meta.reward_layer_list[map_layer_index]:getPositionX()+meta.reward_layer_list[map_layer_index]:getContentSize().width
            map_layer:setPosition(next_pos_x,0)--新层紧跟着当前层
            map_layer.pre_pos_x = map_layer:getPositionX()--第一次记录上一次位置

            map_layer_index = map_layer_index + 1
            GameRewardM:SetLayerIndex(map_layer_index)

            cur_map_id = cur_map_id + 1
            GameRewardM:SetCurMapId(cur_map_id)

            cur_mot_id = 1
            GameRewardM:SetCurMotId(cur_mot_id)

            --下一次是否越界 越界返回第一个
            if cur_map_id <= #GameRewardM.map_data_list then
                map_layer:setContentSize(cc.size(GameRewardM.map_data_list[cur_map_id].width,GameRewardM.map_data_list[cur_map_id].height))
            else
                map_layer:setContentSize(cc.size(GameRewardM.map_data_list[1].width,GameRewardM.map_data_list[1].height))
            end
               
            table.insert(meta.reward_layer_list,map_layer)
            meta.mainLayer:addChild(map_layer,OBJECT_RENDER_TAG.reward_layer)
        end

        --地图是否循环
        if not GameRewardM:GetIsRepeat() then
            GameModel:SetGameSetup(GAME_STEP.game_end)--标识游戏结束
            return
        end

        cur_map_id = 1
        GameRewardM:SetCurMapId(cur_map_id)
        cur_mot_id = 1
        GameRewardM:SetCurMotId(cur_mot_id)
    end
end
--检查释放对象及层
function meta:checkRewardRelease()
    GameRewardM:checkReleaseObj()--检查释放对象
    --检查释放层
    local i=1
    while (i<=#meta.reward_layer_list) do
        --if meta.reward_layer_list[i]:isVisible() then--仅对显示层做检查释放 池更新
            if GameRewardM:GetIsRepeat() then--循环地图
                --判断层下是否还有子节点
                --if meta.reward_layer_list[i]:getPositionX() < -meta.reward_layer_list[i]:getContentSize().width then
                    --cclog("meta.reward_layer_list[" ..i .."]:getChildrenCount() == " ..meta.reward_layer_list[i]:getChildrenCount())
                --end
                --超过层边界而且子节点数为0就释放
                if meta.reward_layer_list[i]:getPositionX() < -meta.reward_layer_list[i]:getContentSize().width and meta.reward_layer_list[i]:getChildrenCount() == 0 then
                    local index = GameRewardM:GetLayerIndex()
                    index = index-1
                    GameRewardM:SetLayerIndex(index)--对应的层索引要对应reward_layer_list
                    meta.reward_layer_list[i]:removeFromParent(true)
                    table.remove(meta.reward_layer_list,i)
                    break
                end
                i = i + 1
            else--不循环地图
                --最后一幅图的最右边与屏幕右边对齐
                if meta.reward_layer_list[#meta.reward_layer_list]:getContentSize().width - meta.reward_layer_list[#meta.reward_layer_list]:getPositionX() <= visibleSize_width then
                    g_isPause = true
                end
                i = i + 1
            end
        --end 池更新
        
    end
end
--检查清除普通模式的对象
function meta:checkRewardScene()
    if not GameModel.is_just_reward then--是否刚返回普通模式
        GameModel.is_just_reward = true
        --清空所有奖励模式对象列表(注意清空的对象 别弄错)
        GameRewardM:clearAllObj()
        --清空奖励层列表
        for i=1,#meta.reward_layer_list do
            meta.reward_layer_list[i]:removeFromParent(true)
        end
        meta.reward_layer_list = {}
    end
end
--更新层
function meta:UpdateRewardLayer()
    --移动层

    --死亡后无需检测
   if GameModel:GetGameSetup() == GAME_STEP.game_role_die then
        return
   end

    --暂停
    if GameModel:GetGameSetup() == GAME_STEP.game_ready or g_isPause then
        return
    end

    --奖励模式才有效
    if GameModel:GetGameSetup() ~= GAME_STEP.game_boss then--GameModel:GetGameSetup() ~= GAME_STEP.game_reward then
        --检查清除奖励场景的对象
        meta:checkRewardScene()
        return
    else
        GameModel.is_just_reward = false--奖励模式时候重置
    end
    

    --游戏是否结束
    if GameModel:GetGameSetup() == GAME_STEP.game_end then
        
        --测试用
        --if GameModel:GetIsRepeat() then
        --    --GameModel:SetGameSetup(GAME_STEP.game_start)
        --    g_isPause = false
        --else
        --    g_isPause = true

        --end
        
        g_isPause = true

        return
    end

    
    if #meta.reward_layer_list ~= 0 then
        local i=1
        while (i<=#meta.reward_layer_list) do
            if meta.reward_layer_list[i] then
                local pos_x = meta.reward_layer_list[i]:getPositionX()
                meta.reward_layer_list[i].pre_pos_x = pos_x
                pos_x = pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed()
                meta.reward_layer_list[i]:setPositionX(pos_x)
            end
            i = i + 1
        end
    else
        --创建奖励模式对象到列表中
        meta:createRewardObjectToList()
    end 
    meta:checkRewardRelease()--检查释放对象及层
    meta:updateRewardObjectInList()--创建对象到列表中
    --meta:DrawLayers()--画层范围
end
--**************************普通模式**************************************
--根据数据转化所有配置怪物信息(供外部使用)
function meta:createObjectToList()--定时器中时刻检测 60/1
    meta.map_layer_list = {}
    local cur_map_id = GameModel:GetCurMapId()--获取当前地图关卡
    local cur_mot_id = GameModel:GetCurMotId()--获取当前地图关卡怪物id
    local map_layer_index = GameModel:GetLayerIndex()--获取当前层列表索引
    if #meta.map_layer_list == 0 then
        local map_layer = cc.Layer:create()
        map_layer:setAnchorPoint(0,0)--锚点
        map_layer:setPosition(0,0)
        map_layer:setContentSize(GameModel.map_data_list[cur_map_id].width,GameModel.map_data_list[cur_map_id].height)
        map_layer.pre_pos_x = map_layer:getPositionX()--第一次记录上一次位置
        table.insert(meta.map_layer_list,map_layer)
        meta.mainLayer:addChild(map_layer,OBJECT_RENDER_TAG.normal_layer)
    end
    while(cur_map_id <= #GameModel.map_data_list) do--层数据
        while(cur_mot_id <= #GameModel.map_data_list[cur_map_id].value ) do--层怪物数据
            --获取数据结构(优化成拆分完成table直接赋值)
            --local str = GameModel.map_data_list[cur_map_id].value[cur_mot_id]
            --local mot_obj = ValueTool:init(str)--XX;XX;XX
            local mot_obj = GameModel.split_data_list[cur_map_id][cur_mot_id]
            
            --此层坐标+怪物相对坐标
            if meta.map_layer_list[map_layer_index]:getPositionX()+mot_obj:GetPosX() <= GameModel.create_range then
                if GameModel:GetGameSetup() == GAME_STEP.game_boss then--GameModel:GetGameSetup() == GAME_STEP.game_reward then

                    --奖励模式下无需创建对象

                else
                    local monster = MonsterModel:init()--初始化怪物信息

                    --数据赋值
                    GameModel:initMonster(monster,mot_obj)

                    --创建ani
                    GameModel:CreateAni(monster)

                    --对怪物进行缩放
                    GameModel:MonsterScale(monster)

                    --对怪物初始行为处理
                    GameModel:MonsterAction(monster)

                    --放入列表
                    GameModel:intoList(monster)

                    --渲染批次tag
                    local tag = GameModel:choiceResTag(monster)

                    meta.map_layer_list[map_layer_index]:addChild(monster.ani,tag)--把怪物放入此层
                    if monster.glNode then
                        meta.map_layer_list[map_layer_index]:addChild(monster.glNode,1000)
                    end

                end
                
            else
                
                return--因为是按顺序 因此后面的怪物一定不在范围
            end

            cur_mot_id = cur_mot_id + 1
            GameModel:SetCurMotId(cur_mot_id)
        end
        cur_map_id = cur_map_id + 1
        GameModel:SetCurMapId(cur_map_id)
    end
end
--动态更新创建怪物列表
function meta:updateObjectInList()
    while (true) do
        --游戏是否开始
        if GameModel:GetGameSetup() == GAME_STEP.game_end then
            return
        end
        
        local cur_map_id = GameModel:GetCurMapId()--获取当前地图关卡
        local cur_mot_id = GameModel:GetCurMotId()--获取当前地图关卡怪物id
        local map_layer_index = GameModel:GetLayerIndex()--获取当前层列表索引
        while(cur_map_id <= #GameModel.map_data_list) do--层数据
            while(cur_mot_id <= #GameModel.map_data_list[cur_map_id].value ) do--层怪物数据
                --获取数据结构(优化成拆分完成table直接赋值)
                --local str = GameModel.map_data_list[cur_map_id].value[cur_mot_id]
                --local mot_obj = ValueTool:init(str)--XX;XX;XX
                local mot_obj = GameModel.split_data_list[cur_map_id][cur_mot_id]
            
                 --此层坐标+怪物相对坐标
                if meta.map_layer_list[map_layer_index]:getPositionX()+mot_obj:GetPosX() <= GameModel.create_range then
                    
                    --奖励模式
                    if GameModel:GetGameSetup() == GAME_STEP.game_boss then--GameModel:GetGameSetup() == GAME_STEP.game_reward then
                         --奖励模式下无需创建对象
                         --cclog("奖励模式下无需创建对象")
                    else
                        local monster = MonsterModel:init()--初始化怪物信息

                        --数据赋值
                        GameModel:initMonster(monster,mot_obj)

                        --创建ani
                        GameModel:CreateAni(monster)

                        --对怪物进行缩放
                        GameModel:MonsterScale(monster)

                        --对怪物初始行为处理
                        GameModel:MonsterAction(monster)

                        --放入列表
                        GameModel:intoList(monster)
                       
                        --渲染批次tag
                        local tag = GameModel:choiceResTag(monster)

                        --把怪物放入此层
                        meta.map_layer_list[map_layer_index]:addChild(monster.ani,tag)
                        --画笔
                        if monster.glNode then
                            meta.map_layer_list[map_layer_index]:addChild(monster.glNode,1000)
                        end

                        --************************池更新***************************
                        ----检查池中是否有可用对象
                        --if GameModel:checkPoolObject(meta.map_layer_list[map_layer_index],mot_obj) then
                        
                        --else
                        --    local monster = MonsterModel:init()--初始化怪物信息

                        --    --数据赋值
                        --    GameModel:initMonster(monster,mot_obj)

                        --    --创建ani
                        --    GameModel:CreateAni(monster)

                        --    --对怪物进行缩放
                        --    GameModel:MonsterScale(monster)

                        --    --放入列表
                        --    GameModel:intoList(monster)
                       
                        --    --渲染批次tag
                        --    local tag = GameModel:choiceResTag(monster)

                        --    --把怪物放入此层
                        --    meta.map_layer_list[map_layer_index]:addChild(monster.ani,tag)
                        --    --画笔
                        --    if monster.glNode then
                        --        meta.map_layer_list[map_layer_index]:addChild(monster.glNode,1000)
                        --    end
                        --end
                        --*********************************************************************************
                    
                    end

                else
                    return--因为是按顺序 因此后面的怪物一定不在范围
                end

                cur_mot_id = cur_mot_id + 1
                GameModel:SetCurMotId(cur_mot_id)
            end

            --创建下一个层(默认创建的地图一定比屏幕宽 并且有怪物不在范围内)
            local map_layer = cc.Layer:create()
            map_layer:setAnchorPoint(0,0)--锚点
            local next_pos_x = meta.map_layer_list[map_layer_index]:getPositionX()+meta.map_layer_list[map_layer_index]:getContentSize().width
            map_layer:setPosition(next_pos_x,0)--新层紧跟着当前层
            map_layer.pre_pos_x = map_layer:getPositionX()--第一次记录上一次位置

            map_layer_index = map_layer_index + 1
            GameModel:SetLayerIndex(map_layer_index)

            cur_map_id = cur_map_id + 1
            GameModel:SetCurMapId(cur_map_id)

            cur_mot_id = 1
            GameModel:SetCurMotId(cur_mot_id)

            --下一次是否越界 越界返回第一个
            if cur_map_id <= #GameModel.map_data_list then
                map_layer:setContentSize(cc.size(GameModel.map_data_list[cur_map_id].width,GameModel.map_data_list[cur_map_id].height))
            else
                map_layer:setContentSize(cc.size(GameModel.map_data_list[1].width,GameModel.map_data_list[1].height))
            end
               
            table.insert(meta.map_layer_list,map_layer)
            meta.mainLayer:addChild(map_layer,OBJECT_RENDER_TAG.normal_layer)

            --***************************池更新***************************
            --检查层是否有出屏幕(隐藏代表出屏 显示代表显示滚动中)
            --local is_layer_out = false
            --for i=1,#meta.map_layer_list do
            --    if not meta.map_layer_list[i]:isVisible() then
            --        meta.map_layer_list[i]:setVisible(true)
            --        is_layer_out = true--标记找到隐藏的层 下面没必要再创建
            --        --初始化层信息
            --        local next_pos_x = meta.map_layer_list[map_layer_index]:getPositionX()+meta.map_layer_list[map_layer_index]:getContentSize().width
            --        meta.map_layer_list[i]:setPosition(next_pos_x,0)--新层紧跟着当前层

            --        map_layer_index = map_layer_index + 1
            --        GameModel:SetLayerIndex(map_layer_index)

            --        cur_map_id = cur_map_id + 1
            --        GameModel:SetCurMapId(cur_map_id)

            --        cur_mot_id = 1
            --        GameModel:SetCurMotId(cur_mot_id)

            --        --下一次是否越界 越界返回第一个
            --        if cur_map_id <= #GameModel.map_data_list then
            --            meta.map_layer_list[i]:setContentSize(cc.size(GameModel.map_data_list[cur_map_id].width,GameModel.map_data_list[cur_map_id].height))
            --        else
            --            meta.map_layer_list[i]:setContentSize(cc.size(GameModel.map_data_list[1].width,GameModel.map_data_list[1].height))
            --        end

            --        --在判断层释放的时候并没有释放掉此层  所以没必要再addChild
            --        --table.insert(meta.map_layer_list,map_layer)
            --        --meta.mainLayer:addChild(map_layer)

            --        break
            --    end
            --end
            
            
            --如果所有层都还在显示则新创建一个
            --if not is_layer_out then
            --    --创建下一个层(默认创建的地图一定比屏幕宽 并且有怪物不在范围内)
            --    local map_layer = cc.Layer:create()
            --    map_layer:setAnchorPoint(0,0)--锚点
            --    local next_pos_x = meta.map_layer_list[map_layer_index]:getPositionX()+meta.map_layer_list[map_layer_index]:getContentSize().width
            --    map_layer:setPosition(next_pos_x,0)--新层紧跟着当前层

            --    map_layer_index = map_layer_index + 1
            --    GameModel:SetLayerIndex(map_layer_index)

            --    cur_map_id = cur_map_id + 1
            --    GameModel:SetCurMapId(cur_map_id)

            --    cur_mot_id = 1
            --    GameModel:SetCurMotId(cur_mot_id)

            --    --下一次是否越界 越界返回第一个
            --    if cur_map_id <= #GameModel.map_data_list then
            --        map_layer:setContentSize(cc.size(GameModel.map_data_list[cur_map_id].width,GameModel.map_data_list[cur_map_id].height))
            --    else
            --        map_layer:setContentSize(cc.size(GameModel.map_data_list[1].width,GameModel.map_data_list[1].height))
            --    end
               
            --    table.insert(meta.map_layer_list,map_layer)
            --    meta.mainLayer:addChild(map_layer)
            --end
            --*********************************************************************************

        end

        --地图是否循环
        if not GameModel:GetIsRepeat() then
            GameModel:SetGameSetup(GAME_STEP.game_end)--标识游戏结束
            return
        end

        cur_map_id = 1
        GameModel:SetCurMapId(cur_map_id)
        cur_mot_id = 1
        GameModel:SetCurMotId(cur_mot_id)
    end
end
--检查释放对象及层
function meta:checkRelease()
    if GameModel:GetGameSetup() ~= GAME_STEP.game_boss then--GameModel:GetGameSetup() ~= GAME_STEP.game_reward then
        GameModel:checkReleaseObj()--检查释放对象
        --检查释放层
        local i=1
        while (i<=#meta.map_layer_list) do
            --if meta.map_layer_list[i]:isVisible() then--仅对显示层做检查释放 池更新
                if GameModel:GetIsRepeat() then--循环地图
                    --判断层下是否还有子节点
                    --if meta.map_layer_list[i]:getPositionX() < -meta.map_layer_list[i]:getContentSize().width then
                        --cclog("meta.map_layer_list[" ..i .."]:getChildrenCount() == " ..meta.map_layer_list[i]:getChildrenCount())
                    --end
                    --超过层边界而且子节点数为0就释放
                    if meta.map_layer_list[i]:getPositionX() < -meta.map_layer_list[i]:getContentSize().width and meta.map_layer_list[i]:getChildrenCount() == 0 then
                    --预留1/4屏幕的大小防止size超过层边界
                    --if meta.map_layer_list[i]:getPositionX() < -meta.map_layer_list[i]:getContentSize().width - visibleSize_width/4 then
                        --meta.map_layer_list[i]:setVisible(false)--隐藏此层代表已经出屏幕 池更新
                        local index = GameModel:GetLayerIndex()
                        index = index-1
                        GameModel:SetLayerIndex(index)--对应的层索引要对应map_layer_list
                        meta.map_layer_list[i]:removeFromParent(true)
                        table.remove(meta.map_layer_list,i)
                        --**********池更新**********
                        --table.insert(meta.map_layer_list,meta.map_layer_list[i])--先把这个出屏幕的层再插入一个 接在后面
                        --table.remove(meta.map_layer_list,i)--再从最前面移除  
                        --cclog("meta.map_layer_list ==== " ..#meta.map_layer_list)
                        --******************************
                        --cclog("************************************************************************************************************************")
                        break
                    
                    end
                    i = i + 1
                else--不循环地图
                    --最后一幅图的最右边与屏幕右边对齐
                    if meta.map_layer_list[#meta.map_layer_list]:getContentSize().width - meta.map_layer_list[#meta.map_layer_list]:getPositionX() <= visibleSize_width then
                        g_isPause = true
                    end
                    i = i + 1
                end
            --end 池更新
        
        end
    end
end
--计算游戏时间
function meta:CalcTime()
    
    --死亡后无需检测
   if GameModel:GetGameSetup() == GAME_STEP.game_role_die then
        return
   end

    if GameModel:GetGameSetup() == GAME_STEP.game_ready or g_isPause then
        return false
    end

    local is_second = false

    if meta.frame_calc >= g_frame then
        if GameModel:GetGameSetup() == GAME_STEP.game_role_move_die then
            if meta.role_die >= 2 then--死亡2秒后结算
                 g_isPause = false
                --游戏结束
                GameModel:SetGameSetup(GAME_STEP.game_end)
                --给个黑色背景 因为会看见原来场景的背景
                 cc.Director:getInstance():getRunningScene():addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 255)),10)
                 --检测结算
                 meta:checkReasult()
                return
            else
                meta.role_die = meta.role_die + 1
            end
        end
        --1秒进来一次
        meta.frame_calc = 1
        meta.frame_clock = meta.frame_clock + 1
        is_second = true
        --人物持续掉血
        GameModel.Handler:getRole():DropHp()
         --7(1+10%*n/2000)
        if GameModel.juli_score > 100 and GameModel.juli_score < 3000 then
            local speed = 7*(1+GameModel.juli_score/10000)
            GameModel:SetLayerSpeed(speed)
            GameModel.Handler:SetTimes(speed)--设置角色物理时间
            --cclog("SetLayerSpeed == " ..speed)
        end
        GameSceneUi:setHeroJiaXie(1)--按时间生成血瓶
        
    else
        meta.frame_calc = meta.frame_calc + 1

        --计算退出boss模式时间
        GameSceneUi:setChangeScenePercentNumber()
    end

    --[[
     --人物持续掉血(在安卓机中os.clock无反应)
    if os.clock() - meta.frame_clock > 1 then--1秒进来一次
        meta.frame_clock = os.clock()
        is_second = true
        GameModel.Handler:getRole():DropHp()

        --7(1+10%*n/2000)
        if GameModel.juli_score > 2000 then
            local speed = 7*(1+GameModel.juli_score/20000)
            GameModel:SetLayerSpeed(speed)
            GameModel.Handler:SetTimes(speed)--设置角色物理时间
            cclog("SetLayerSpeed == " ..speed)
        end

        --cclog("frame_clock ===========  " ..meta.frame_clock)
    end
    --]]

    --[[帧速率高于60要计算 根据当前游戏帧速率调节
    if meta.frame_num < 10 and 1/cc.Director:getInstance():getAnimationInterval() > 40 then
        if is_second then
            --meta.game_time = meta.game_time + 1
            meta:checkFrame()--1秒进入一次
        end
    end
    --]]
     
    
end
--检查帧速率情况(只计算一次 在游戏开始前30秒默认60帧  如果卡会降到30帧)
function meta:checkFrame()
    if meta.frame_num < 10 then--计时器 每秒记录一次 30秒被frame_rate除
        --默认是每秒60帧
        --meta.game_time_label:setString(tostring(cc.Director:getInstance():getFrameRate()))
        meta.frame_rate =  meta.frame_rate + cc.Director:getInstance():getFrameRate()--加当前这一秒帧速率
        meta.frame_num  = meta.frame_num + 1
    elseif meta.frame_num == 10 then--开始计算
        --cc.Director:getInstance():setAnimationInterval(1/30)
        --GameModel:SetLayerSpeed(GameModel.GetLayerSpeed()*2)
        --GameModel.Handler:AdjustFrame(30)
        -----
        meta.frame_rate = meta.frame_rate/meta.frame_num
        --设置帧速率
        if meta.frame_rate >= 50 then--每秒60帧
            cc.Director:getInstance():setAnimationInterval(1/60)--默认层速度不用改
        else --每秒30帧
            cc.Director:getInstance():setAnimationInterval(1/30)
            g_frame = 30
            GameModel:SetLayerSpeed(GameModel:GetLayerSpeed())
            --GameRewardM:SetLayerSpeed(GameRewardM:GetLayerSpeed())
            GameModel:SetGlobalSpeed(GameModel:GetGlobalSpeed())
        end
        GameModel.Handler:AdjustFrame(meta.frame_rate)--根据帧速率调节数值(传入的是一个均值)
        meta.frame_num  = meta.frame_num + 1
        --meta.game_time_label:setString(tostring(meta.frame_rate))
    end
end
--启动更新
function meta:LaunchUpdate()
    local max_time = 0
    local frame = 1
    
    --更新数据
    local function UpdateData(dt)

        local num = 60/g_frame
        if not (frame % num == 0) then
            frame = frame + 1
        else
            frame = 1
        
            --local start_time = os.clock()

            
            if GameModel:GetGameSetup() == GAME_STEP.game_end then
                return
            end
            
            --重来释放(编辑器测试用)
            if GameModel.is_release then
                return
            end

            --游戏计时 玩家掉血
            meta:CalcTime()

            --检测是否死亡
            meta:checkDie()

            --新手引导
           if g_userinfo.leader <= LEADER_ENUM.leader0 then
                if GameModel.leader_finish then
                    return
                end
           end

            --检测结算
            if meta:checkReasult() then
                --meta.mainLayer:unscheduleUpdate()--停止定时器
                return
            end

            --更新层
            meta:UpdateLayer()

            --更新boss模式层(原来的奖励模式层)
            meta:UpdateRewardLayer()
            
            --更新bossAI
            meta:UpdateBossAi()
            
            --更新对象(内部含有更新奖励模式对象)
            meta:UpdateObject()
        
            
            
        
            ---------测试用----------
            --更新游戏时间
            --meta:GameTime()

            --更新游戏速度
            --meta:GameSpeed()

            --更新压力测试
            --meta:UpdatePressureTest()
            ------------------------------

            --local end_time = os.clock()
        
            --local result_time =  end_time - start_time
            --if result_time > max_time then
            --    max_time = result_time
            --    --print(max_time)
            --    --cclog("max_time ============ " ..max_time)
            --    meta.game_time_label:setString(tostring(max_time))
            --end

        end

    end
    --cc.Director:getInstance():getScheduler():scheduleScriptFunc(UpdateData,0,false)
    meta.mainLayer:scheduleUpdateWithPriorityLua(UpdateData,0)--回调 刷新优先级
end
--检测结算
function meta:checkReasult()
    --游戏刚开始暂停
    if GameModel:GetGameSetup() == GAME_STEP.game_ready or g_isPause then
        return false
    end

    --游戏结束
    if GameModel:GetGameSetup() == GAME_STEP.game_end then
        
        ---[[新结算
        local mi = math.ceil(GameModel.juli_score)
        local function pauseScene(scene)
            if scene then
                local GameService = require "src/GameScene/GameS"
                local require_http = GameService:init(mi,GameModel.biaoxian_score,GameModel.Handler:getRole().hero_id,GameModel.Handler:getRole().hero_level)--米数 表现分
                scene:addChild(require_http)
            end
        end
        PauseScene(pauseScene)
        --]]
        --[[旧结算
        local mi = math.ceil(GameModel.juli_score)
        local GameService = require "src/GameScene/GameS"
        local require_http = GameService:init(mi,GameModel.biaoxian_score)--米数 表现分
        --]]
       

        --按钮控制那里释放
        --self:release()
        --GameModel.Handler:unscheduleUpdate()--停止角色定时器
        return true
        
    end
    return false
end
--检测是否死亡
function meta:checkDie()

    --准备开始
    if GameModel:GetGameSetup() == GAME_STEP.game_ready or g_isPause then
        --新手引导
        if g_userinfo.leader <= LEADER_ENUM.leader0 then
            leader2:checkLeader(0)
        end
        
        return false
    end

    local cur_role_pos = GameModel.Handler:getCurPosition()
    if cur_role_pos.x < -GameModel.Handler:getRole():GetAni():getContentSize().width or cur_role_pos.y <  - GameModel.Handler:getRole():GetAni():getContentSize().height then
        cclog("角色被夹死")
        GameModel:SetLayerSpeed(3)
        GameModel.middle_speed  = 0.1
        --角色被夹死
        GameModel:SetGameSetup(GAME_STEP.game_role_move_die)
        
    elseif GameModel.Handler:getRole():GetCurHp() <= 0 then
        --角色hp为0死亡
         GameModel:SetGameSetup(GAME_STEP.game_role_die)
         g_isPause = true
         GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.death)
    end

    --更新距离
    local speed = 0
    if GameModel.Handler:getRole():GetRoleSpurt() then
        speed = 0.5*(1+GameModel.juli_score/1000)
    else
        speed = 0.15*(1+GameModel.juli_score/10000)
    end
    GameModel.juli_score = GameModel.juli_score + speed
    --GameSceneUi:setHeroJiaXie(speed)--按距离生成血瓶

    --新手引导
    if g_userinfo.leader <= LEADER_ENUM.leader0 then
        leader2:checkLeader(GameModel.juli_score)
        if not GameModel.leader_finish then--未完成才执行
            local mi = math.ceil(GameModel.juli_score)
            GameSceneUi:setJuliNumber(mi)--距离米数
            GameSceneUi:updateDynamicBox(mi)--查看宝箱显示
        end
    else
        local mi = math.ceil(GameModel.juli_score)
        GameSceneUi:setJuliNumber(mi)--距离米数
        GameSceneUi:updateDynamicBox(mi)--查看宝箱显示
    end
    
    

    if not GameSceneUi.game_is_score then--按距离计算
        GameSceneUi:setChangeScenePercentNumber(speed)
        GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
    end
    
    
end
--更新层
function meta:UpdateLayer()
    --移动层


    --死亡后无需检测
   if GameModel:GetGameSetup() == GAME_STEP.game_role_die then
        return
   end

    --暂停
    if GameModel:GetGameSetup() == GAME_STEP.game_ready or g_isPause then
        return
    end

    --游戏是否结束
    if GameModel:GetGameSetup() == GAME_STEP.game_end then
        
        --测试用
        --if GameModel:GetIsRepeat() then
        --    --GameModel:SetGameSetup(GAME_STEP.game_start)
        --    g_isPause = false
        --else
        --    g_isPause = true
        --end

        g_isPause = true

        return
    end

    
    if #meta.map_layer_list ~= 0 then
        local i=1
        while (i<=#meta.map_layer_list) do
            if meta.map_layer_list[i] then
                local pos_x = meta.map_layer_list[i]:getPositionX()
                meta.map_layer_list[i].pre_pos_x = pos_x
                pos_x = pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed()
                meta.map_layer_list[i]:setPositionX(pos_x)
            end
            i = i + 1
        end
    end 
    meta:checkRelease()--检查释放对象及层
    meta:updateObjectInList()--创建对象到列表中
    --meta:DrawLayers()--画层范围
end
--更新对象
function meta:UpdateObject()
   
   --死亡后无需检测
   if GameModel:GetGameSetup() == GAME_STEP.game_role_die or GameModel:GetGameSetup() == GAME_STEP.game_role_move_die then
        return
   end

   if GameModel:GetGameSetup() == GAME_STEP.game_start then
        if g_isPause then
            return
        end
    end
    

    local no_collide = false--除了浮梯和地面意外都屏蔽交互
    --碰撞检测
    local scale = GameModel.Handler:getScale()
    local cur_role_pos      = GameModel.Handler:getCurPosition()
    
    --角色碰撞宽高
    local role_width  =  math.ceil(GameModel.Handler:getRole():GetRoleScope().run.width*scale)
    local role_height = math.ceil(GameModel.Handler:getRole():GetRoleScope().run.height*scale)

   --当前角色碰撞区
    local cur_role_scope    = cc.rect(cur_role_pos.x,cur_role_pos.y,role_width,role_height)
    
    --角色下一个位置的碰撞区
    local next_role_pos      = GameModel.Handler:getNextPosition()
    local next_role_scope    = cc.rect( next_role_pos.x,next_role_pos.y,role_width,role_height)

    local magnet_speed = 30*60/g_frame + GameModel:GetGlobalSpeed() --磁铁吸收速度

    --奖励地面(如果奖励模式有怪物则需要把这段代码放在攻击碰撞区域下面 并且传参)
    if GameModel:GetGameSetup() == GAME_STEP.game_reward or GameModel:GetGameSetup() == GAME_STEP.game_boss then
        meta:UpdateGameRewardObject(cur_role_scope,next_role_scope,magnet_speed)
        return--如果有奖励模式 就不需运行往下代码
    else
        GameRewardM.is_just_reward = false--退出奖励模式 重置
    end
    

    --角色攻击碰撞区
    local role_atk_width  = 0--攻击宽(近战)
    local role_atk_height = 0--攻击高(近战)
    local role_atk = false--是否为攻击状态(包括空中攻击)
    local cur_role_atk_scope = {}--用于近战碰撞区域
    if GameModel.Handler:getRole():GetAttack() or GameModel.Handler:getRole():GetAirAttack() then
        role_atk = true
        role_atk_width  = math.ceil(GameModel.Handler:getRole():GetRoleScope().atk.width*scale)
        role_atk_height = math.ceil(GameModel.Handler:getRole():GetRoleScope().atk.height*scale)
        cur_role_atk_scope = cc.rect(cur_role_pos.x,cur_role_pos.y,role_atk_width,role_atk_height)
        if GameModel.Handler:getRole().glNode then
            meta:DrawObj(
            GameModel.Handler:getRole().glNode,
            cc.p(cur_role_atk_scope.x,cur_role_atk_scope.y),--左下
            cc.p(cur_role_atk_scope.x+cur_role_atk_scope.width,cur_role_atk_scope.y),--右下
            cc.p(cur_role_atk_scope.x+cur_role_atk_scope.width,cur_role_atk_scope.y+cur_role_atk_scope.height),--右上
            cc.p(cur_role_atk_scope.x,cur_role_atk_scope.y+cur_role_atk_scope.height),--左上
            "角色攻击碰撞区"
            )
        end

    else
        
        if GameModel.Handler:getRole().glNode then
            meta:DrawObj(
            GameModel.Handler:getRole().glNode,
            cc.p(cur_role_scope.x,cur_role_scope.y),--左下
            cc.p(cur_role_scope.x+cur_role_scope.width,cur_role_scope.y),--右下
            cc.p(cur_role_scope.x+cur_role_scope.width,cur_role_scope.y+cur_role_scope.height),--右上
            cc.p(cur_role_scope.x,cur_role_scope.y+cur_role_scope.height),--左上
            "角色碰撞区"
            )
        end
    end
    
    --上下左右矩形相交差值
    --local collide_range_down = 0--{down = 0,right = 0}--只有角色向下和向右才会修正位置  向上是不会贴边修正 向左的情况实际不存在
    --local collide_range_right = 0

    --local is_collide = false--是否有挤压的碰撞
    
    GameModel.Handler:getRole():SetIsFloor(false)--赋值给上一次是否在路面
    --local is_floor = false
    local visible_size_half = visibleSize_width/2
    local offset_y = 30--y轴偏移值
    -------------------------------------------地面-------------------------------------------
    if #GameModel.mot_floor_list ~= 0 then
        --cclog("地面 ================= " ..#GameModel.mot_floor_list)
        local i=1
        while (i<=#GameModel.mot_floor_list) do
            local obj = GameModel.mot_floor_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"地面")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_floor_list,i)
                elseif obj_world.x >= visible_size_half then
                   --[[直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                   --]]
                   break
                else
                    
                    local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                    local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                    --local pos_x = parent_x + obj.ani:getPositionX()
                    --local next_pos_x = pos_x - obj:GetSpeedX()

                    local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()
                    local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                    --当前怪物碰撞区
                    local mot_width  = obj:GetScopeWidth()
                    local mot_height = obj:GetScopeHeight()
                    --当前怪物碰撞区
                    local cur_mot_pos_x   = cur_pos_x
                    local cur_mot_pos_y   = obj.ani:getPositionY()
                    local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                    --怪物下一个位置的碰撞区
                    local next_mot_pos      = cc.p( next_pos_x, obj.ani:getPositionY())
                    local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)


                    if obj.glNode then
                        local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                        meta:DrawObj(
                            obj.glNode,
                            cc.p(draw_x,cur_mot_scope.y),--左下
                            cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                            cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                            cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                            "地面"
                            )
                    end
            
                    --不是冲刺才进行碰撞检测
                    if not GameModel.Handler:getRole():GetRoleSpurt() then
                        local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)

                        --没有碰撞
                        if result.x == 0 and result.y == 0 then
                                --角色什么也不用做
                        --角色向下碰撞
                        elseif result.y < 0 then
                                local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                next_role_scope.y = obj.ani:getPositionY()+obj:GetScopeHeight()--collide_rect.y+collide_rect.height--修正角色位置
                                ----往下撞要判断差值最大的 最后才set位置
                                --if collide_range_down < collide_rect.height then
                                --   collide_range_down = collide_rect.height
                                --end
                         
                                if (not GameModel.Handler:getRole():GetRun() and not GameModel.Handler:getRole():GetAirAttack() and not GameModel.Handler:getRole():GetAttack()) or  GameModel.Handler:getRole():GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.spurt then
                                    GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                                    --cclog("111111111")
                                end
                
                                if not GameModel.Handler:getRole():GetAttack() then
                                    GameModel.Handler:getRole():SetRun()
                                    GameModel.Handler:getRole():SetIsFloor(false)--赋值给上一次是否在路面
                                    --cclog("行号 ====== " ..1312)
                                end
                                
                                GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置
                                if not GameModel.Handler:getRole():GetIsFloor() then
                                    GameModel.Handler:getRole():SetIsFloor(true)--赋值给上一次是否在路面
                                end
                 
                 
                                GameModel.Handler:setVyZero()--落地后设置速度为0
                 
                                --is_collide = true
                                --GameModel.Handler:setPositionY(next_role_pos.y+collide_rect.height)
                                --break
                        --角色向右碰撞
                        elseif result.x > 0 then
                            local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                            if cur_mot_scope.y+cur_mot_scope.height - collide_rect.y > offset_y then--collide_rect.height > offset_y then
                                next_role_scope.x = collide_rect.x-role_width
                            else
                                next_role_scope.y = obj.ani:getPositionY()+obj:GetScopeHeight()--collide_rect.y+collide_rect.height--修正角色位置
                            end
                            

                            
                            --GameModel.Handler:setPositionY(next_role_pos.x-collide_rect.width)
                            --往右撞要判断差值最大的 最后才set位置
                                --if collide_range.right < collide_rect.width then
                                --   collide_range.right = collide_rect.width
                                --end
                        
                
                            --is_collide = true
                        --角色向上碰撞
                        --elseif result.y > 0 then
                        --    local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                        --    --往下撞要判断差值最大的 最后才set位置
                        --     if collide_range.up < collide_rect.height then
                        --        collide_range.up = collide_rect.height
                        --     end
                        --     is_collide = true
                        --    --GameModel.Handler:setPositionY(next_role_pos.y-collide_rect.height)
                        --    break
            
                        --角色向左碰撞
                        --elseif result.x < 0 then
                        --    local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                        --    --GameModel.Handler:setPositionY(next_role_pos.x+collide_rect.width)
                        --    --往右撞要判断差值最大的 最后才set位置
                        --     if collide_range.left < collide_rect.width then
                        --        collide_range.left = collide_rect.width
                        --     end
                        --    is_collide = true
                        --    break
                        end--注意这个对应上述if else
          
                    end

                    next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                    obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                    i = i + 1
                    
                    
                end 
            --end 池更新

        end
    end
    -------------------------------------------空中地面-------------------------------------------
    if #GameModel.mot_air_floor_list ~= 0 then
        --cclog("空中地面 ================= " ..#GameModel.mot_air_floor_list)
        local i=1
        while (i<=#GameModel.mot_air_floor_list) do
            local obj = GameModel.mot_air_floor_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"空中地面")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_air_floor_list,i)
                elseif obj_world.x > visible_size_half then
                    --[[直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                    --]]
                   break
                else
                    --********************空中地面********************
                    if obj:GetMonsterTag() == MONSTER_TYPE.air_floor then
                        local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                        local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                        --local pos_x = parent_x + obj.ani:getPositionX()
                        --local next_pos_x = pos_x - obj:GetSpeedX()

                        local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()
                        local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                        --当前碰撞区
                        local mot_width  = obj:GetScopeWidth()
                        local mot_height = obj:GetScopeHeight()
                        --当前碰撞区
                        local cur_mot_pos_x   = cur_pos_x
                        local cur_mot_pos_y   = obj.ani:getPositionY()
                        local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                        --怪物下一个位置的碰撞区
                        local next_mot_pos      = cc.p( next_pos_x, obj.ani:getPositionY())
                        local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)


                        if obj.glNode then
                            local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                            meta:DrawObj(
                                obj.glNode,
                                cc.p(draw_x,cur_mot_scope.y),--左下
                                cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                "空中地面"
                                )
                        end
            
                        --不是冲刺才进行碰撞检测
                        if not GameModel.Handler:getRole():GetRoleSpurt() then
                            local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)

                            --没有碰撞
                            if result.x == 0 and result.y == 0 then
                                    --角色什么也不用做
                            --角色向下碰撞
                            elseif result.y < 0 then
                                    local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                    next_role_scope.y = obj.ani:getPositionY()+obj:GetScopeHeight()--collide_rect.y+collide_rect.height--修正角色位置
                                    ----往下撞要判断差值最大的 最后才set位置
                                    --if collide_range_down < collide_rect.height then
                                    --   collide_range_down = collide_rect.height
                                    --end
                         
                                    if (not GameModel.Handler:getRole():GetRun() and not GameModel.Handler:getRole():GetAirAttack() and not GameModel.Handler:getRole():GetAttack()) or  GameModel.Handler:getRole():GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.spurt then
                                        GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                                        --cclog("111111111")
                                    end
                
                                    if not GameModel.Handler:getRole():GetAttack() then
                                        GameModel.Handler:getRole():SetRun()
                                        GameModel.Handler:getRole():SetIsFloor(false)--赋值给上一次是否在路面
                                        --cclog("行号 ====== " ..1460)
                                    end
                                
                                    GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置
                                    if not GameModel.Handler:getRole():GetIsFloor() then
                                        GameModel.Handler:getRole():SetIsFloor(true)--赋值给上一次是否在路面
                                    end
                                    GameModel.Handler:setVyZero()--落地后设置速度为0
                            end
          
                        end
                    --********************上浮地面********************
                    elseif obj:GetMonsterTag() == MONSTER_TYPE.up_floor then
                        if obj_world.x <= visibleSize_width/2 then
                            --是否完成上浮
                            if obj.up_floor_success then
                                local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                                local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                                --local pos_x = parent_x + obj.ani:getPositionX()
                                --local next_pos_x = pos_x - obj:GetSpeedX()

                                local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()
                                local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                                --当前碰撞区
                                local mot_width  = obj:GetScopeWidth()
                                local mot_height = obj:GetScopeHeight()
                                --当前碰撞区
                                local cur_mot_pos_x   = cur_pos_x
                                local cur_mot_pos_y   = obj.pre_moveY
                                local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                                --下一个位置的碰撞区
                                local next_mot_pos      = cc.p( next_pos_x, obj.ani:getPositionY())
                                local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)
                                obj.pre_moveY = obj.ani:getPositionY()

                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(draw_x,cur_mot_scope.y),--左下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "上浮地面"
                                        )
                                end
            
                                --不是冲刺才进行碰撞检测
                                if not GameModel.Handler:getRole():GetRoleSpurt() then
                                    local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)

                                    --没有碰撞
                                    if result.x == 0 and result.y == 0 then
                                            --角色什么也不用做
                                    --角色向下碰撞
                                    elseif result.y < 0 then
                                            local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                            next_role_scope.y = obj.ani:getPositionY()+obj:GetScopeHeight()--collide_rect.y+collide_rect.height--修正角色位置
                                            ----往下撞要判断差值最大的 最后才set位置
                                            --if collide_range_down < collide_rect.height then
                                            --   collide_range_down = collide_rect.height
                                            --end
                         
                                            if (not GameModel.Handler:getRole():GetRun() and not GameModel.Handler:getRole():GetAirAttack() and not GameModel.Handler:getRole():GetAttack()) or  GameModel.Handler:getRole():GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.spurt then
                                                GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                                                --cclog("111111111")
                                            end
                
                                            if not GameModel.Handler:getRole():GetAttack() then
                                                GameModel.Handler:getRole():SetRun()
                                                GameModel.Handler:getRole():SetIsFloor(false)--赋值给上一次是否在路面
                                                --cclog("行号 ====== " ..1532)
                                            end
                                
                                            GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置
                                            if not GameModel.Handler:getRole():GetIsFloor() then
                                                GameModel.Handler:getRole():SetIsFloor(true)--赋值给上一次是否在路面
                                            end
                                            GameModel.Handler:setVyZero()--落地后设置速度为0
                                    end
          
                                end
                            
                            else
                            ------未上浮 ------------
                                if not obj.floor_action then
                                    obj.floor_action = true
                                    --结束上浮
                                    local function MoveUpEnd()
                                        obj.up_floor_success = true--上浮完成
                                    end
                                    local target_y = obj.pos_y + obj.ani:getContentSize().height
                                    local up_move = cc.MoveBy:create(0.3,cc.p(0,target_y))
                                    local seq = cc.Sequence:create(up_move,cc.CallFunc:create(MoveUpEnd))
                                    obj.ani:runAction(seq)
                                end
                                
                            end
                        end
                        
                    --********************下沉地面********************
                    elseif obj:GetMonsterTag() == MONSTER_TYPE.down_floor then
                        if obj_world.x <= visibleSize_width/2 then
                            --是否完成下沉
                            if obj.down_floor_success then
                            else
                            ------未下沉------------
                                if not obj.floor_action then
                                    obj.floor_action = true
                                    --结束上浮
                                    local function MoveUpEnd()
                                        obj.down_floor_success = true--下沉完成
                                    end
                                    local target_y = - obj.pos_y -obj.ani:getContentSize().height
                                    local up_move = cc.MoveBy:create(0.5,cc.p(0,target_y))
                                    local seq = cc.Sequence:create(up_move,cc.CallFunc:create(MoveUpEnd))
                                    obj.ani:runAction(seq)
                                end
                                
                            end
                        else
                            --[[未下沉支持踩踏
                            local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            --local pos_x = parent_x + obj.ani:getPositionX()
                            --local next_pos_x = pos_x - obj:GetSpeedX()

                            local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()
                            local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                            --当前碰撞区
                            local mot_width  = obj:GetScopeWidth()
                            local mot_height = obj:GetScopeHeight()
                            --当前碰撞区
                            local cur_mot_pos_x   = cur_pos_x
                            local cur_mot_pos_y   = obj.pre_moveY
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                            --下一个位置的碰撞区
                            local next_mot_pos      = cc.p( next_pos_x, obj.ani:getPositionY())
                            local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)
                            obj.pre_moveY = obj.ani:getPositionY()

                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                    "下沉地面"
                                    )
                            end
            
                            --不是冲刺才进行碰撞检测
                            if not GameModel.Handler:getRole():GetRoleSpurt() then
                                local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)

                                --没有碰撞
                                if result.x == 0 and result.y == 0 then
                                        --角色什么也不用做
                                --角色向下碰撞
                                elseif result.y < 0 then
                                    local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                    next_role_scope.y = obj.ani:getPositionY()+obj:GetScopeHeight()--collide_rect.y+collide_rect.height--修正角色位置
                                    ----往下撞要判断差值最大的 最后才set位置
                                    --if collide_range_down < collide_rect.height then
                                    --   collide_range_down = collide_rect.height
                                    --end
                         
                                    if (not GameModel.Handler:getRole():GetRun() and not GameModel.Handler:getRole():GetAirAttack() and not GameModel.Handler:getRole():GetAttack()) or  GameModel.Handler:getRole():GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.spurt then
                                        GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                                        --cclog("111111111")
                                    end
                
                                    if not GameModel.Handler:getRole():GetAttack() then
                                        GameModel.Handler:getRole():SetRun()
                                        GameModel.Handler:getRole():SetIsFloor(false)--赋值给上一次是否在路面
                                        --cclog("行号 ====== " ..1639)
                                    end
                                
                                    GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置
                                    if not GameModel.Handler:getRole():GetIsFloor() then
                                        GameModel.Handler:getRole():SetIsFloor(true)--赋值给上一次是否在路面
                                    end
                                    GameModel.Handler:setVyZero()--落地后设置速度为0
                                end
                            end
                            --]]
                        end
                    end

                    

                    next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                    obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                    i = i + 1
                    
                end 
            --end 池更新
        end
    end
    -------------------------------------------平铺列表-------------------------------------------
    if #GameModel.mot_road_list ~= 0 then
        --cclog("平铺列表 ================= " ..#GameModel.mot_road_list)
        local i=1
        while (i<=#GameModel.mot_road_list) do
            local obj = GameModel.mot_road_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"平铺列表")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_road_list,i)
                elseif obj_world.x >= visible_size_half then
                    --[[直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                    --]]
                    break
                else
                    if obj.ani:isVisible() then--浮板经常隐藏  所以隐藏不能是判断出屏 而是用GetDie来判断出屏
                        local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                        local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                        --local pos_x = parent_x + obj.ani:getPositionX()
                        --local next_pos_x = pos_x - obj:GetSpeedX()
                        local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()
                        local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                        --当前怪物碰撞区
                        local mot_width  = obj:GetScope().width
                        local mot_height = obj:GetScope().height
                        --当前怪物碰撞区
                        local cur_mot_pos_x   = cur_pos_x
                        local cur_mot_pos_y   = obj.ani:getPositionY()
                        local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                        --怪物下一个位置的碰撞区
                        local next_mot_pos      = cc.p( next_pos_x, obj.ani:getPositionY())
                        local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)

                        if obj.glNode then
                            local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                            meta:DrawObj(
                                obj.glNode,
                                cc.p(draw_x,cur_mot_scope.y),--左下
                                cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                "平铺列表"
                                )
                        end

                        --不是冲刺才进行碰撞检测
                        if not GameModel.Handler:getRole():GetRoleSpurt() then
                            local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
            
                            --没有碰撞
                            if result.x == 0 and result.y == 0 then
                                    --角色什么也不用做
                            --角色向下碰撞
                            elseif result.y < 0 then
                                    local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                    next_role_scope.y = obj.ani:getPositionY()+obj:GetScopeHeight()--collide_rect.y+collide_rect.height
                                    --往下撞要判断差值最大的 最后才set位置
                                    --if collide_range.down < collide_rect.height then
                                    --   collide_range.down = collide_rect.height
                                    --end
                                    if (not GameModel.Handler:getRole():GetRun() and not GameModel.Handler:getRole():GetAirAttack() and not GameModel.Handler:getRole():GetAttack()) or  GameModel.Handler:getRole():GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.spurt then
                                        GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                                    end

                                    if not GameModel.Handler:getRole():GetAttack()then
                                        GameModel.Handler:getRole():SetRun()
                                        GameModel.Handler:getRole():SetIsFloor(false)
                                        --cclog("行号 ====== " ..1739)
                                    end
                                    
                                    GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置

                                    if not GameModel.Handler:getRole():GetIsFloor() then
                                         GameModel.Handler:getRole():SetIsFloor(true)
                                    end

                                    GameModel.Handler:setVyZero()--落地后设置速度为0
                 
                                    --is_collide = true
                                    --GameModel.Handler:setPositionY(next_role_pos.y+collide_rect.height)
                                    --break
                            --角色向右碰撞
                            elseif result.x > 0 then
                                local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                --GameModel.Handler:setPositionY(next_role_pos.x-collide_rect.width)
                            
                                --给出一定偏移  如果小于某个值默认踩上去
                                if cur_mot_scope.y+cur_mot_scope.height - collide_rect.y > offset_y then--collide_rect.height < offset_y then
                                    --collide_range.down = collide_rect.height
                                    next_role_scope.y = obj.ani:getPositionY()+obj:GetScopeHeight()--collide_rect.y+collide_rect.height
                                
                                --往右撞要判断差值最大的 最后才set位置
                                else
                                    --collide_range.right = collide_rect.width
                                    next_role_scope.x = collide_rect.x-role_width
                                end

                
                                --is_collide = true
                            end

                        end
                        

                        next_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                        obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                    else
                        --路面隐藏时候自行往左移动
                        local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                
                    end

                    i = i + 1
                    
                    --直接移动
                    --local pos_x = obj.ani:getPositionX()
                    --pos_x = pos_x - obj:GetSpeedX()
                    --obj.ani:setPositionX(pos_x)
                    --i=i+1
                     
                end
                
            --end 池更新
        end

    end

    --开始暂停
    if GameModel:GetGameSetup() == GAME_STEP.game_ready or g_isPause then
        GameModel.Handler:setPosition(cc.p(cur_role_pos.x,next_role_scope.y))
        return
    end
    -------------------------------------------阻碍物-------------------------------------------
    if #GameModel.mot_block_list ~= 0 then
        --cclog("阻碍物 ================= " ..#GameModel.mot_block_list)
        local i=1
        while (i<=#GameModel.mot_block_list) do
            local obj = GameModel.mot_block_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"阻碍物")
                local obj_width = obj.ani:getContentSize().width*2
                if obj_world.x < - obj_width then
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_block_list,i)
                elseif (obj_world.x >= visible_size_half) then
                    --[[直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                    --]]
                    break
                elseif (obj_world.x+obj_width) < cur_role_scope.x then
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else
                    --***********************无敌变大状态***********************
                    if GameModel.Handler:getRole():GetRoleBig() then
                        local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                        local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                        --local pos_x = parent_x + obj.ani:getPositionX()
                        --local next_pos_x = pos_x - obj:GetSpeedX()
                        local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()--obj.ani:getPositionX()--obj.ani:convertToWorldSpaceAR(cc.p(0,0))
                        local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                        --当前怪物碰撞区
                        local mot_width  = obj:GetScope().width
                        local mot_height = obj:GetScope().height
                        --当前怪物碰撞区
                        local cur_mot_pos_x   = cur_pos_x--obj.ani:getPositionX()-GameModel.create_range--cur_pos.x--obj.ani:getPositionX()
                        local cur_mot_pos_y   = obj.pre_moveY--cur_pos.y--obj.ani:getPositionY()
                        local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                        --怪物下一个位置的碰撞区
                        local next_mot_pos      = cc.p( next_pos_x,obj.ani:getPositionY())--obj.ani:getPositionY()
                        local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)

                        local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
                        obj.pre_moveY = obj.ani:getPositionY()


                        if obj.glNode then
                            local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                            meta:DrawObj(
                                obj.glNode,
                                cc.p(draw_x,cur_mot_scope.y),--左下
                                cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                "阻碍物无敌变大状态"
                                )
                        end
            
                        --没有碰撞
                        if result.x == 0 and result.y == 0 then

                        else
                            obj.ani:removeFromParent(true)
                            table.remove(GameModel.mot_block_list,i)
                            is_remove = true

                            GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                            GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)

                            if GameSceneUi.game_is_score then--按表现分算就开启
                                GameSceneUi:setChangeScenePercentNumber(obj.show)
                                GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                            end
                            
                        end
          
                        if not is_remove then
                            next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                            obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                        end
                    else
                        local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                        local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                        --local pos_x = parent_x + obj.ani:getPositionX()
                        --local next_pos_x = pos_x - obj:GetSpeedX()

                        local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()
                        local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                        --当前怪物碰撞区
                        local mot_width  = obj:GetScopeWidth()
                        local mot_height = obj:GetScopeHeight()
                        --当前怪物碰撞区
                        local cur_mot_pos_x   = cur_pos_x
                        local cur_mot_pos_y   = obj.ani:getPositionY()
                        local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                        --怪物下一个位置的碰撞区
                        local next_mot_pos      = cc.p( next_pos_x, obj.ani:getPositionY())
                        local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)


                        if obj.glNode then
                            local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                            meta:DrawObj(
                                obj.glNode,
                                cc.p(draw_x,cur_mot_scope.y),--左下
                                cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                "阻碍物"
                                )
                        end
            
                        --不是冲刺才进行碰撞检测
                        if not GameModel.Handler:getRole():GetRoleSpurt() then
                            local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)

                            --没有碰撞
                            if result.x == 0 and result.y == 0 then
                                    --角色什么也不用做
                            elseif result.y > 0 then
                                --向上碰到
                                local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                next_role_scope.y = collide_rect.y-role_height
                                GameModel.Handler:setVyZero()--落地后设置速度为0


                                -- cclog("上顶盒子")
                            --角色向右碰撞
                            elseif result.x > 0 then
                                local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                next_role_scope.x = collide_rect.x-role_width
                            end
          
                        end


                        if not is_remove then
                            next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                            obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                        end
                    end
                    
                    if not is_remove then
                        i = i + 1
                    end
                    
                end 
            --end 池更新

        end
    end
    -------------------------------------------障碍物-------------------------------------------
    if #GameModel.mot_obj_list ~= 0 then
        --cclog("障碍物 ================= " ..#GameModel.mot_obj_list)
        local i=1
        while (i<=#GameModel.mot_obj_list) do
            local obj = GameModel.mot_obj_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"障碍物")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_obj_list,i)
                elseif (obj_world.x >= visible_size_half) then
                    break
                elseif (obj_world.x+obj_width) < cur_role_scope.x then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else
                    if no_collide then
                        --直接移动
                        local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                        i = i + 1
                    else
                        --***********************冲刺状态***********************
                        if GameModel.Handler:getRole():GetRoleSpurt() then
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                            cur_pos_x = cur_pos_x - obj:GetSpeedX()
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                            local cur_mot_pos_y   = obj:GetScopePosY()+obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                                    cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                    "障碍物冲刺状态"
                                    )
                            end
                            

                            --碰撞检测
                            if cur_pos_x <= cur_role_pos.x or cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                --obj.ani:setVisible(false)
                                obj.ani:removeFromParent(true)
                                table.remove(GameModel.mot_obj_list,i)
                                is_remove = true

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)

                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                            end

                            if not is_remove then
                                cur_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()
                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        --***********************无敌变大状态***********************
                        elseif GameModel.Handler:getRole():GetRoleBig() then
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                            cur_pos_x = cur_pos_x - obj:GetSpeedX()
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                            local cur_mot_pos_y   = obj:GetScopePosY()+obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           

                            --碰撞检测
                            if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                                --obj.ani:setVisible(false)
                                obj.ani:removeFromParent(true)
                                table.remove(GameModel.mot_obj_list,i)
                                is_remove = true
                            end

                            if not is_remove then
                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "障碍物无敌变大状态"
                                        )
                                end


                                cur_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()
                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end

                        --***********************角色与怪物正常交互***********************
                        elseif not GameModel.Handler:getRole():GetBlink() then
                        
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                            cur_pos_x = cur_pos_x - obj:GetSpeedX()
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScopeWidth()
                            local mot_height = obj:GetScopeHeight()
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                            local cur_mot_pos_y   = obj:GetScopePosY()+obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                            
                            --碰撞检测
                            if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                --判断是否有护盾
                                if GameModel.Handler:getRole():GetRoleDun() then
                                    GameModel.Handler:getRole():SetRoleDun(false)
                                    GameModel.Handler:getRole().sprite_dun:setVisible(false)
                                    GameModel.Handler:getRole():Blink_Start(0)
                                    playEffect("res/music/effect/fight/shield_dis.ogg")
                                    --cclog("有护盾")
                                else
                                    GameModel.Handler:getRole():Blink_Start(obj.attack) 
                                    --cclog("受伤")
                                end
                                
                            end

                            if not is_remove then
                                 if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                         "障碍物角色与怪物正常交互"
                                        )
                                end

                                cur_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()
                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        else
                        --***********************角色闪烁状态***********************
                            if obj.glNode then
                                local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                                local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                                cur_pos_x = cur_pos_x - obj:GetSpeedX()
                                --当前怪物碰撞区
                                local mot_width  = obj:GetScope().width
                                local mot_height = obj:GetScope().height
                                --当前怪物碰撞区
                                local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                                local cur_mot_pos_y   = obj:GetScopePosY()+obj.ani:getPositionY()
                                local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                                
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                                    cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                     "障碍物角色闪烁状态"
                                    )
                            end



                            --其他情况都是穿越
                            local cur_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()
                            obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                        end

                        
            
                        --是否移除
                        if not is_remove then
                            i = i + 1
                        end

                    end
                    

                end
            --end 池更新
             
        end
    end
    -------------------------------------------礼包盒-------------------------------------------
    if #GameModel.mot_gift_list ~= 0 then
        --cclog("礼包盒 ================= " ..#GameModel.mot_gift_list)
        local i=1
        while (i<=#GameModel.mot_gift_list) do
            local obj = GameModel.mot_gift_list[i]
            --local local_obj = obj
            --if not obj:GetDie() then 池更新
                -- --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"礼包盒")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_gift_list,i)
                elseif (obj_world.x >= visible_size_half) then
                    break
                elseif (obj_world.x+obj_width) < cur_role_scope.x then
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else
                    if no_collide then
                         local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                        i = i + 1  
                    else
                        --***********************冲刺状态***********************
                        if GameModel.Handler:getRole():GetRoleSpurt() then
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                            cur_pos_x = cur_pos_x - obj:GetSpeedX()
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = cur_pos_x
                            local cur_mot_pos_y   = obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                     "礼包盒冲刺状态"
                                    )
                            end
                        
                       
                            --碰撞检测
                            if cur_pos_x <= cur_role_pos.x or cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                --obj.ani:setVisible(false)
                                obj.ani:removeFromParent(true)
                                table.remove(GameModel.mot_gift_list,i)
                                is_remove = true

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                            end

                            if not is_remove then
                                next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                                obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end

                        --***********************无敌变大状态***********************
                        elseif GameModel.Handler:getRole():GetRoleBig() then
                            local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            --local pos_x = parent_x + obj.ani:getPositionX()
                            --local next_pos_x = pos_x - obj:GetSpeedX()
                            local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()--obj.ani:getPositionX()--obj.ani:convertToWorldSpaceAR(cc.p(0,0))
                            local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = cur_pos_x--obj.ani:getPositionX()-GameModel.create_range--cur_pos.x--obj.ani:getPositionX()
                            local cur_mot_pos_y   = obj.pre_moveY--cur_pos.y--obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                            --怪物下一个位置的碰撞区
                            local next_mot_pos      = cc.p( next_pos_x,obj.ani:getPositionY())--obj.ani:getPositionY()
                            local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)

                            local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
                            obj.pre_moveY = obj.ani:getPositionY()


                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                     "礼包盒无敌变大状态"
                                    )
                            end
            
                            --没有碰撞
                            if result.x == 0 and result.y == 0 then

                            else
                                if result.y < 0 then
                                    --向下碰到弹簧进行跳跃
                                    GameModel.Handler:getRole():SetJump1()
                                    GameModel.Handler:jump1()
                                    GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                                    GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置

                                    GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                    GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                    if GameSceneUi.game_is_score then--按表现分算就开启
                                        GameSceneUi:setChangeScenePercentNumber(obj.show)
                                        GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                    end
                                    --obj.ani:setVisible(false)
                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_gift_list,i)
                                    is_remove = true
                                    playEffect("res/music/effect/fight/get_box.ogg")

                                elseif result.y > 0 then
                                    --向上碰到
                                    GameModel.Handler:setVyZero()--落地后设置速度为0

                                    GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                    GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                    if GameSceneUi.game_is_score then--按表现分算就开启
                                        GameSceneUi:setChangeScenePercentNumber(obj.show)
                                        GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                    end

                                    --obj.ani:setVisible(false)
                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_gift_list,i)
                                    is_remove = true
                                    playEffect("res/music/effect/fight/get_box.ogg")
                                --其他碰撞
                                else
                                    GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                    GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                    if GameSceneUi.game_is_score then--按表现分算就开启
                                        GameSceneUi:setChangeScenePercentNumber(obj.show)
                                        GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                    end

                                    --obj.ani:setVisible(false)
                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_gift_list,i)
                                    is_remove = true
                                    playEffect("res/music/effect/fight/get_box.ogg")
                                end
                            end
          
                            if not is_remove then
                                next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                                obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        

                        --********************正常交互礼包盒子********************
                        else
                            local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            --local pos_x = parent_x + obj.ani:getPositionX()
                            --local next_pos_x = pos_x - obj:GetSpeedX()
                            local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()--obj.ani:getPositionX()--obj.ani:convertToWorldSpaceAR(cc.p(0,0))
                            local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                            --当前碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前碰撞区
                            local cur_mot_pos_x   = cur_pos_x--obj.ani:getPositionX()-GameModel.create_range--cur_pos.x--obj.ani:getPositionX()
                            local cur_mot_pos_y   = obj.pre_moveY--cur_pos.y--obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                            --怪物下一个位置的碰撞区
                            local next_mot_pos      = cc.p( next_pos_x,obj.ani:getPositionY() )
                            local next_mot_scope    = cc.rect( next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)

                            local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
                            obj.pre_moveY = obj.ani:getPositionY()

                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                    "礼包盒正常交互礼包盒子"
                                    )
                            end
            
                            --没有碰撞
                            if result.x == 0 and result.y == 0 then
                                    --角色什么也不用做
                        
                            --角色向下碰撞
                            else
                                if result.y < 0 then
                                    --向下碰到弹簧进行跳跃
                                    GameModel.Handler:getRole():SetJump1()
                                    GameModel.Handler:jump1()
                                    GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                                    GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置

                                    GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                    GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                    if GameSceneUi.game_is_score then--按表现分算就开启
                                        GameSceneUi:setChangeScenePercentNumber(obj.show)
                                        GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                    end

                                    --obj.ani:setVisible(false)
                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_gift_list,i)
                                    is_remove = true
                                    playEffect("res/music/effect/fight/get_box.ogg")
                                    --cclog("下踩盒子")
                                elseif result.y > 0 then
                                    --向上碰到
                                    GameModel.Handler:setVyZero()--落地后设置速度为0

                                    GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                    GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                    if GameSceneUi.game_is_score then--按表现分算就开启
                                        GameSceneUi:setChangeScenePercentNumber(obj.show)
                                        GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                    end

                                    --obj.ani:setVisible(false)
                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_gift_list,i)
                                    is_remove = true
                                    playEffect("res/music/effect/sound/get_box.ogg")
                                        
                                    -- cclog("上顶盒子")
                                --角色向右碰撞
                                elseif result.x > 0 then
                                    local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                    next_role_scope.x = collide_rect.x-role_width

                                
                                    --GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                    --GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)

                                    --obj.ani:removeFromParent(true)
                                    --table.remove(GameModel.mot_gift_list,i)
                                    --is_remove = true
                                end
                            end
          
                            if not is_remove then
                                next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                                obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        
                        end

                        if not is_remove then
                            i = i + 1
                        end
                    end
                    
                    
                end

                
            --end 池更新

        end
    end
    -------------------------------------------飞行礼包盒-------------------------------------------
    if #GameModel.mot_flygift_list ~= 0 then
        --cclog("飞行礼包盒 ================= " ..#GameModel.mot_flygift_list)
        local i=1
        while (i<=#GameModel.mot_flygift_list) do
            local obj = GameModel.mot_flygift_list[i]
            --local local_obj = obj
            --if not obj:GetDie() then 池更新
                -- --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"飞行礼包盒")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_flygift_list,i)
                elseif (obj_world.x >= visible_size_half) then
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                elseif (obj_world.x+obj_width) < cur_role_scope.x then
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else
                    if no_collide then
                         local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                        i = i + 1  
                    else
                        --***********************冲刺状态***********************
                        if GameModel.Handler:getRole():GetRoleSpurt() then
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                            cur_pos_x = cur_pos_x - obj:GetSpeedX()
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = cur_pos_x
                            local cur_mot_pos_y   = obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                     "礼包盒冲刺状态"
                                    )
                            end
                        
                       
                            --碰撞检测
                            if cur_pos_x <= cur_role_pos.x or cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                --obj.ani:setVisible(false)
                                obj.ani:removeFromParent(true)
                                table.remove(GameModel.mot_flygift_list,i)
                                is_remove = true

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                            end

                            if not is_remove then
                                next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                                obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end

                        --***********************无敌变大状态***********************
                        elseif GameModel.Handler:getRole():GetRoleBig() then
                            local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            --local pos_x = parent_x + obj.ani:getPositionX()
                            --local next_pos_x = pos_x - obj:GetSpeedX()
                            local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()--obj.ani:getPositionX()--obj.ani:convertToWorldSpaceAR(cc.p(0,0))
                            local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = cur_pos_x--obj.ani:getPositionX()-GameModel.create_range--cur_pos.x--obj.ani:getPositionX()
                            local cur_mot_pos_y   = obj.pre_moveY--cur_pos.y--obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                            --怪物下一个位置的碰撞区
                            local next_mot_pos      = cc.p( next_pos_x,obj.ani:getPositionY())--obj.ani:getPositionY()
                            local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)

                            local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
                            obj.pre_moveY = obj.ani:getPositionY()


                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                     "礼包盒无敌变大状态"
                                    )
                            end
            
                            --没有碰撞
                            if result.x == 0 and result.y == 0 then

                            else
                                --碰到弹簧进行跳跃
                                GameModel.Handler:getRole():SetJump1()
                                GameModel.Handler:jump1()
                                GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                                GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                                --obj.ani:setVisible(false)
                                obj.ani:removeFromParent(true)
                                table.remove(GameModel.mot_flygift_list,i)
                                is_remove = true
                                playEffect("res/music/effect/fight/get_box.ogg")
                            end
          
                            if not is_remove then
                                next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                                obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        

                        --********************正常交互礼包盒子********************
                        else
                            local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            --local pos_x = parent_x + obj.ani:getPositionX()
                            --local next_pos_x = pos_x - obj:GetSpeedX()
                            local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()--obj.ani:getPositionX()--obj.ani:convertToWorldSpaceAR(cc.p(0,0))
                            local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                            --当前碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前碰撞区
                            local cur_mot_pos_x   = cur_pos_x--obj.ani:getPositionX()-GameModel.create_range--cur_pos.x--obj.ani:getPositionX()
                            local cur_mot_pos_y   = obj.pre_moveY--cur_pos.y--obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                            --怪物下一个位置的碰撞区
                            local next_mot_pos      = cc.p( next_pos_x,obj.ani:getPositionY() )
                            local next_mot_scope    = cc.rect( next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)

                            local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
                            obj.pre_moveY = obj.ani:getPositionY()

                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                    "礼包盒正常交互礼包盒子"
                                    )
                            end
            
                            --没有碰撞
                            if result.x == 0 and result.y == 0 then
                                    --角色什么也不用做
                        
                            --角色向下碰撞
                            else
                                --碰到弹簧进行跳跃
                                GameModel.Handler:getRole():SetJump1()
                                GameModel.Handler:jump1()
                                GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                                GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                                --obj.ani:setVisible(false)
                                obj.ani:removeFromParent(true)
                                table.remove(GameModel.mot_flygift_list,i)
                                is_remove = true
                                playEffect("res/music/effect/fight/get_box.ogg")
                            end
          
                            if not is_remove then
                                next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                                obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        
                        end

                        if not is_remove then
                            i = i + 1
                        end
                    end
                    
                    
                end

                
            --end 池更新

        end
    end



    ---[[-------------------------------------------扣血怪物列表-------------------------------------------
    if #GameModel.mot_hurt_list ~= 0 then
        --cclog("扣血怪物列表 ================= " ..#GameModel.mot_hurt_list)
        local i=1
        while (i<=#GameModel.mot_hurt_list) do
            local obj = GameModel.mot_hurt_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"扣血怪物列表")
                local obj_width = obj.ani:getContentSize().width
                --cclog("hrut_obj_world = " ..obj_world.x)
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_hurt_list,i)
                elseif (obj_world.x+obj_width) < cur_role_scope.x then
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else
                    if obj:GetDie() or no_collide then
                        --直接移动
                        local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                        i = i + 1
                    else
                        --***********************冲刺状态***********************
                        if GameModel.Handler:getRole():GetRoleSpurt() then
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                            cur_pos_x = cur_pos_x - obj:GetSpeedX()
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                            local cur_mot_pos_y   = obj:GetScopePosY()+obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                                    cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                    "扣血怪物冲刺状态"
                                    )
                            end
                            

                            --碰撞检测
                            if cur_pos_x <= cur_role_pos.x or cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                --obj.ani:setVisible(false)

                                if obj.createType == MONSTER_CREATE_TYPE.exportjson then
                                    --arm:getAnimation():play(ANIMATION_ENUM.Injured)
                                    obj.ani:getAnimation():play(ANIMATION_ENUM.Injured)
                                    obj:SetDie(true)--标记死亡
                                else
                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_hurt_list,i)
                                    is_remove = true
                                end

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)

                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                            end

                            if not is_remove then
                                cur_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()
                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        --***********************无敌变大状态***********************
                        elseif GameModel.Handler:getRole():GetRoleBig() then
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                            cur_pos_x = cur_pos_x - obj:GetSpeedX()
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                            local cur_mot_pos_y   = obj:GetScopePosY()+obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                            local role_collide = cur_role_scope
                            --远战英雄才需要检测子弹
                            if GameModel.Handler:getRole():GetAtkType() == ROLE_ATK_TYPE.farwar then
                                --与角色怪物子弹碰撞检测
                                local bullet_i = 1
                                while ( bullet_i <= #GameModel.Handler:getRole().bullet_list) do
                                    local role_bullet = GameModel.Handler:getRole().bullet_list[bullet_i]
                                    local bullet_rect = cc.rect(role_bullet:getPositionX()+GameModel.Handler:getRole():GetAni():getContentSize().width,role_bullet:getPositionY()-role_bullet:getContentSize().height,role_bullet:getContentSize().width/2,role_bullet:getContentSize().height*2)
                                    
                                     if GameModel.Handler:getRole().bullet_draw then
                                        meta:DrawObj(
                                            GameModel.Handler:getRole().bullet_draw,
                                            cc.p(bullet_rect.x,bullet_rect.y),--左下
                                            cc.p(bullet_rect.x+bullet_rect.width,bullet_rect.y),--右下
                                            cc.p(bullet_rect.x+bullet_rect.width,bullet_rect.y+bullet_rect.height),--右上
                                            cc.p(bullet_rect.x,bullet_rect.y+bullet_rect.height),--左上
                                            "扣血怪物子弹碰撞检测"
                                            )
                                    end
                                
                                    --子弹与怪物碰撞
                                    if cc.rectIntersectsRect(bullet_rect,cur_mot_scope) then
                                        --子弹释放
                                        role_bullet:stopAllActions()
                                        role_bullet:getAnimation():play(ANIMATION_ENUM.hit)
                                        GameModel.Handler:getRole():HitSound()--击中音效

                                        if obj.createType == MONSTER_CREATE_TYPE.exportjson then
                                            --arm:getAnimation():play(ANIMATION_ENUM.Injured)
                                            obj.ani:getAnimation():play(ANIMATION_ENUM.Injured)
                                            obj:SetDie(true)--标记死亡
                                        else
                                            --怪物释放
                                            obj.ani:removeFromParent(true)
                                            table.remove(GameModel.mot_hurt_list,i)
                                            is_remove = true
                                        end

                                        
                                        break
                                    end

                                    bullet_i = bullet_i + 1
                                end
                            --else
                            --    --近战
                            --    --刷新碰撞区域
                            --    if role_atk then
                            --        cur_role_scope = cur_role_atk_scope
                            --    end
                            end
                            
                            --刷新碰撞区域
                            if role_atk then
                                role_collide = cur_role_atk_scope
                            end


                            --碰撞检测
                            if cc.rectIntersectsRect(role_collide,cur_mot_scope) then
                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)
                                
                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end

                                if role_atk then
                                    --近战英雄击中效果
                                    GameModel.Handler:getRole():MeleeHit(cur_mot_scope)
                                end
                                

                                if obj.createType == MONSTER_CREATE_TYPE.exportjson then
                                    --arm:getAnimation():play(ANIMATION_ENUM.Injured)
                                    obj.ani:getAnimation():play(ANIMATION_ENUM.Injured)
                                    obj:SetDie(true)--标记死亡
                                else
                                    --obj.ani:setVisible(false)
                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_hurt_list,i)
                                    is_remove = true
                                end
                            end

                            if not is_remove then
                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "扣血怪物无敌变大状态"
                                        )
                                end


                                cur_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()
                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end

                        --***********************角色与怪物正常交互***********************
                        elseif not GameModel.Handler:getRole():GetBlink() then
                        
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                            cur_pos_x = cur_pos_x - obj:GetSpeedX()
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                            local cur_mot_pos_y   = obj:GetScopePosY()+obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                            local role_collide = cur_role_scope
                            --远战英雄才需要检测子弹
                            if GameModel.Handler:getRole():GetAtkType() == ROLE_ATK_TYPE.farwar then
                                --与角色怪物子弹碰撞检测
                                local bullet_i = 1
                                while ( bullet_i <= #GameModel.Handler:getRole().bullet_list) do
                                    local role_bullet = GameModel.Handler:getRole().bullet_list[bullet_i]
                                    local bullet_rect = cc.rect(role_bullet:getPositionX(),role_bullet:getPositionY()-role_bullet:getContentSize().height/2,role_bullet:getContentSize().width,role_bullet:getContentSize().height)
                                
                                     if GameModel.Handler:getRole().bullet_draw then
                                        meta:DrawObj(
                                            GameModel.Handler:getRole().bullet_draw,
                                            cc.p(bullet_rect.x,bullet_rect.y),--左下
                                            cc.p(bullet_rect.x+bullet_rect.width,bullet_rect.y),--右下
                                            cc.p(bullet_rect.x+bullet_rect.width,bullet_rect.y+bullet_rect.height),--右上
                                            cc.p(bullet_rect.x,bullet_rect.y+bullet_rect.height),--左上
                                            "扣血怪物检测子弹"
                                            )
                                    end
                                
                                    --子弹与怪物碰撞
                                    if cc.rectIntersectsRect(bullet_rect,cur_mot_scope) then
                                        --子弹释放
                                        role_bullet:stopAllActions()
                                        role_bullet:getAnimation():play(ANIMATION_ENUM.hit)
                                        GameModel.Handler:getRole():HitSound()--击中音效
                                        
                                        if obj.createType == MONSTER_CREATE_TYPE.exportjson then
                                            --arm:getAnimation():play(ANIMATION_ENUM.Injured)
                                            obj.ani:getAnimation():play(ANIMATION_ENUM.Injured)
                                            obj:SetDie(true)--标记死亡
                                        else
                                            --怪物释放
                                            obj.ani:removeFromParent(true)
                                            table.remove(GameModel.mot_hurt_list,i)
                                            is_remove = true
                                        end
                                        
                                        break
                                    end

                                    bullet_i = bullet_i + 1
                                end
                            --else
                            --    --近战
                            --    --刷新碰撞区域
                            --    if role_atk then
                            --        cur_role_scope = cur_role_atk_scope
                            --    end
                            end
                            
                            --刷新碰撞区域
                            if role_atk then
                                role_collide = cur_role_atk_scope
                            end

                            --碰撞检测
                            if cc.rectIntersectsRect(role_collide,cur_mot_scope) then
                                 --是否在攻击状态
                                if role_atk then
                                    
                                    --击中效果
                                    GameModel.Handler:getRole():MeleeHit(cur_mot_scope)
                                    
                                    if obj.createType == MONSTER_CREATE_TYPE.exportjson then
                                        --arm:getAnimation():play(ANIMATION_ENUM.Injured)
                                        obj.ani:getAnimation():play(ANIMATION_ENUM.Injured)
                                        obj:SetDie(true)--标记死亡
                                    else
                                        if not is_remove then
                                            --怪物释放
                                            obj.ani:removeFromParent(true)
                                            table.remove(GameModel.mot_hurt_list,i)
                                            is_remove = true
                                        end
                                    end

                                    --if GameModel.Handler:getRole():GetAtkType() == ROLE_ATK_TYPE.melee then--近战
                                    --    --怪物释放
                                    --    obj.ani:removeFromParent(true)
                                    --    table.remove(GameModel.mot_hurt_list,i)
                                    --    is_remove = true
                                    --else
                                    --    --远程的英雄本身会有交互
                                    --    --判断是否有护盾
                                    --    if GameModel.Handler:getRole():GetRoleDun() then
                                    --        GameModel.Handler:getRole():SetRoleDun(false)
                                    --        GameModel.Handler:getRole().sprite_dun:setVisible(false)
                                    --    else
                                    --        GameModel.Handler:getRole():Blink_Start(obj.attack) 
                                           
                                    --    end
                                    --end
                                    GameModel.Handler:getRole():HitSound()--击中音效
                                else
                                    --判断是否有护盾
                                    if GameModel.Handler:getRole():GetRoleDun() then
                                        GameModel.Handler:getRole():SetRoleDun(false)
                                        GameModel.Handler:getRole().sprite_dun:setVisible(false)
                                        GameModel.Handler:getRole():Blink_Start(0) 
                                        playEffect("res/music/effect/fight/shield_dis.ogg")
                                        --cclog("有护盾")
                                    else
                                        GameModel.Handler:getRole():Blink_Start(obj.attack) 
                                        --cclog("受伤")
                                    end
                                end
                            end

                            if not is_remove then
                                 if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "扣血怪物角色与怪物正常交互"
                                        )
                                end



                                cur_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()
                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        else
                        --***********************角色闪烁状态***********************
                            
                            local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                            local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                            cur_pos_x = cur_pos_x - obj:GetSpeedX()
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                            local cur_mot_pos_y   = obj:GetScopePosY()+obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)

                            local role_collide = cur_role_scope
                            --远战英雄才需要检测子弹
                            if GameModel.Handler:getRole():GetAtkType() == ROLE_ATK_TYPE.farwar then
                                --与角色怪物子弹碰撞检测
                                local bullet_i = 1
                                while ( bullet_i <= #GameModel.Handler:getRole().bullet_list) do
                                    local role_bullet = GameModel.Handler:getRole().bullet_list[bullet_i]
                                    local bullet_rect = cc.rect(role_bullet:getPositionX(),role_bullet:getPositionY()-role_bullet:getContentSize().height/2,role_bullet:getContentSize().width,role_bullet:getContentSize().height)
                                
                                    if GameModel.Handler:getRole().bullet_draw then
                                        meta:DrawObj(
                                            GameModel.Handler:getRole().bullet_draw,
                                            cc.p(bullet_rect.x,bullet_rect.y),--左下
                                            cc.p(bullet_rect.x+bullet_rect.width,bullet_rect.y),--右下
                                            cc.p(bullet_rect.x+bullet_rect.width,bullet_rect.y+bullet_rect.height),--右上
                                            cc.p(bullet_rect.x,bullet_rect.y+bullet_rect.height),--左上
                                            "扣血怪物子弹闪烁"
                                            )
                                    end
                                
                                    --子弹与怪物碰撞
                                    if cc.rectIntersectsRect(bullet_rect,cur_mot_scope) then
                                        --子弹释放
                                        role_bullet:stopAllActions()
                                        role_bullet:getAnimation():play(ANIMATION_ENUM.hit)
                                        
                                        if obj.createType == MONSTER_CREATE_TYPE.exportjson then
                                            --arm:getAnimation():play(ANIMATION_ENUM.Injured)
                                            obj.ani:getAnimation():play(ANIMATION_ENUM.Injured)
                                            obj:SetDie(true)--标记死亡
                                        else
                                            --怪物释放
                                            obj.ani:removeFromParent(true)
                                            table.remove(GameModel.mot_hurt_list,i)
                                            is_remove = true
                                        end
                                        
                                        break
                                    end

                                    bullet_i = bullet_i + 1
                                end
                            --else
                            --    --近战
                            --    --刷新碰撞区域
                            --    if role_atk then
                            --        cur_role_scope = cur_role_atk_scope
                            --    end
                            end
                            
                            --刷新碰撞区域
                            if role_atk then
                                role_collide = cur_role_atk_scope
                            end

                            --碰撞检测
                            if cc.rectIntersectsRect(role_collide,cur_mot_scope) then
                                --是否在攻击状态
                                if role_atk then
                                    
                                    --击中效果
                                    GameModel.Handler:getRole():MeleeHit(cur_mot_scope)

                                    if obj.createType == MONSTER_CREATE_TYPE.exportjson then
                                        --arm:getAnimation():play(ANIMATION_ENUM.Injured)
                                        obj.ani:getAnimation():play(ANIMATION_ENUM.Injured)
                                        obj:SetDie(true)--标记死亡
                                    else
                                        if not is_remove then
                                             --怪物释放
                                            obj.ani:removeFromParent(true)
                                            table.remove(GameModel.mot_hurt_list,i)
                                            is_remove = true
                                        end
                                    end
                                    
                                   
                                    --if GameModel.Handler:getRole():GetAtkType() == ROLE_ATK_TYPE.melee then--近战
                                    --    --怪物释放
                                    --    obj.ani:removeFromParent(true)
                                    --    table.remove(GameModel.mot_hurt_list,i)
                                    --    is_remove = true
                                    --    --此处因为角色闪烁 所以远程不受伤
                                    --end
                                end
                            end

                            if not is_remove then
                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "扣血怪物角色闪烁"
                                        )
                                end



                                --其他情况都是穿越
                                cur_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()
                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end

                        end
            
                        --是否移除
                        if not is_remove then
                            i = i + 1
                        end

                    end
                    

                end
            --end 池更新
        end
        
    end
    --]]
    -------------------------------------------金币类列表-------------------------------------------
    if #GameModel.mot_gold_list ~= 0 then
        --cclog("金币类列表 ================= " ..#GameModel.mot_gold_list)
        --if #GameModel.mot_flygold_list > 10 then
           --cclog("#GameModel.mot_gold_list =========== " ..#GameModel.mot_gold_list)
        --end
        --gold_index = 1
        local i=1
        --cclog("GameModel.Handler:getRole():GetAni():getPositionX() == " ..cur_role_scope.x)
        while (i<=#GameModel.mot_gold_list) do
            local obj = GameModel.mot_gold_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"金币类列表")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_gold_list,i)
                elseif not GameModel.Handler:getRole():GetRoleMagnet() and obj_world.x >= visible_size_half then
                   break
                elseif not GameModel.Handler:getRole():GetRoleMagnet() and (obj_world.x+obj_width) < cur_role_scope.x then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else
                    
                    --if #GameModel.mot_gold_list > 50 then
                    --    if not max_num then
                    --        max_num = 0
                    --    elseif max_num < gold_index then
                    --        max_num = gold_index
                    --        gold_index = gold_index + 1
                    --        cclog("max_num =========== " ..max_num)
                    --    end
                    --end

                    if no_collide then
                         --直接移动
                        local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                        i = i + 1  
                    else
                        local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                        local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                        cur_pos_x = cur_pos_x - obj:GetSpeedX()
                        if obj.ani:isVisible() then
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = cur_pos_x
                            local cur_mot_pos_y   = obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)

                        --    --碰撞方向
                        --    --local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
            
                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                    "金币类"
                                    )
                            end
                        
                            local is_magnet = false--磁铁效果:是否开始吸收
                            --碰撞检测
                            if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                --obj.ani:setVisible(false)
                                playEffect("res/music/effect/fight/gold.ogg")
                                obj.ani:removeFromParent(true)
                                table.remove(GameModel.mot_gold_list,i)
                                is_remove = true

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)

                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                            else
                                --磁铁状态无需移动
                                if not GameModel.Handler:getRole():GetRoleMagnet() then
                                    cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                    obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                else
                                    --半屏吸收
                                    if cur_pos_x <= visibleSize_width*4/5 then
                                        is_magnet = true
                                    else
                                        cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                        obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    end
                                end

                            end

                            --buffer靠近角色
                            if not is_remove and is_magnet then
                                local move_x = cur_mot_scope.x
                                local move_y = cur_mot_scope.y
                                --向角色靠近
                                --x
                                if move_x < cur_role_pos.x then
                                    move_x = move_x + magnet_speed
                                elseif move_x > cur_role_pos.x then
                                    move_x = move_x - magnet_speed
                                end
                                --y
                                if move_y < cur_role_pos.y then
                                    move_y = move_y + magnet_speed
                                elseif move_y > cur_role_pos.y then
                                    move_y = move_y - magnet_speed
                                end
                                move_x = move_x - parent_pos_x
                                obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end


                        end
                        --是否移除
                        if not is_remove then
                            i = i + 1
                        end
                        

                        
                    end
                   
                end
            --end 池更新
            
        end
    end

    -------------------------------------------飞行金币类列表-------------------------------------------
    if #GameModel.mot_flygold_list ~= 0 then
        --cclog("飞行金币类列表 ================= " ..#GameModel.mot_flygold_list)
        local i=1
        while (i<=#GameModel.mot_flygold_list) do
            local obj = GameModel.mot_flygold_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"飞行金币类列表")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_flygold_list,i)
                elseif not GameModel.Handler:getRole():GetRoleMagnet() and obj_world.x >= visible_size_half then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                elseif not GameModel.Handler:getRole():GetRoleMagnet() and (obj_world.x+obj_width) < cur_role_scope.x then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else
                    if no_collide then
                         --直接移动
                        local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                        i = i + 1  
                    else
                        local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                        local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                        cur_pos_x = cur_pos_x - obj:GetSpeedX()
                        if obj.ani:isVisible() then
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = cur_pos_x
                            local cur_mot_pos_y   = obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)

                        --    --碰撞方向
                        --    --local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
            
                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                    "金币类"
                                    )
                            end
                        
                            local is_magnet = false--磁铁效果:是否开始吸收
                            --碰撞检测
                            if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                --obj.ani:setVisible(false)
                                playEffect("res/music/effect/fight/gold.ogg")
                                obj.ani:removeFromParent(true)
                                table.remove(GameModel.mot_flygold_list,i)
                                is_remove = true

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)

                                
                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                            else
                                --磁铁状态无需移动
                                if not GameModel.Handler:getRole():GetRoleMagnet() then
                                    cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                    obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                else
                                    --半屏吸收
                                    if cur_pos_x <= visibleSize_width*4/5 then
                                        is_magnet = true
                                    else
                                        cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                        obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    end
                                end

                            end

                            --buffer靠近角色
                            if not is_remove and is_magnet then
                                local move_x = cur_mot_scope.x
                                local move_y = cur_mot_scope.y
                                --向角色靠近
                                --x
                                if move_x < cur_role_pos.x then
                                    move_x = move_x + magnet_speed
                                elseif move_x > cur_role_pos.x then
                                    move_x = move_x - magnet_speed
                                end
                                --y
                                if move_y < cur_role_pos.y then
                                    move_y = move_y + magnet_speed
                                elseif move_y > cur_role_pos.y then
                                    move_y = move_y - magnet_speed
                                end
                                move_x = move_x - parent_pos_x
                                obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end


                        end
                        --是否移除
                        if not is_remove then
                            i = i + 1
                        end
                        

                        
                    end
                   
                end
            --end 池更新
            
        end
    end

    -------------------------------------------动态类列表(血瓶)-------------------------------------------
    if #GameModel.dynamic_hp_list ~= 0 then
        --cclog("动态类列表 ================= " ..#GameModel.dynamic_hp_list)
        local i=1
        while (i<=#GameModel.dynamic_hp_list) do
            local obj = GameModel.dynamic_hp_list[i]
            local is_remove = false
            local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"动态类列表(血瓶)")
            local obj_width = obj.ani:getContentSize().width
            if obj_world.x < - obj_width then
                obj.ani:removeFromParent(true)
                table.remove(GameModel.dynamic_hp_list,i)
            elseif not GameModel.Handler:getRole():GetRoleMagnet() and obj_world.x >= visible_size_half then
                --直接移动
                local pos_x = obj.ani:getPositionX()
                pos_x = pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed() - obj:GetSpeedX()
                obj.ani:setPositionX(pos_x)
                i = i +1
            elseif not GameModel.Handler:getRole():GetRoleMagnet() and (obj_world.x+obj_width) < cur_role_scope.x then
               --直接移动
                local pos_x = obj.ani:getPositionX()
                pos_x = pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed() - obj:GetSpeedX()
                obj.ani:setPositionX(pos_x)
                i = i +1
            else
                if no_collide then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed() - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i +1
                else
                    local cur_pos_x = obj.ani:getPositionX()
                    cur_pos_x = cur_pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed() - obj:GetSpeedX()
                    --当前怪物碰撞区
                    local mot_width  = obj:GetScopeWidth()
                    local mot_height = obj:GetScopeHeight()
                    --当前怪物碰撞区
                    local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                    local cur_mot_pos_y   = obj:GetScopePosY()+obj.ani:getPositionY()
                    local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                    if obj.glNode then
                        local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                        meta:DrawObj(
                            obj.glNode,
                            cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                            cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                            cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                            cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                            "动态类"
                            )
                    end
                            
                    local is_magnet = false
                    --碰撞检测
                    if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                        playEffect("res/music/effect/fight/get_item.ogg")
                        local resumHp = obj.resumHp
                        GameModel.Handler:getRole():AddHp(resumHp) 

                        obj.ani:removeFromParent(true)
                        table.remove(GameModel.dynamic_hp_list,i)
                        is_remove = true
                    else
                        --磁铁状态无需移动
                        if not GameModel.Handler:getRole():GetRoleMagnet() then
                            obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                        else
                            --半屏吸收
                            if cur_pos_x <= visibleSize_width*4/5 then
                                is_magnet = true
                            else
                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        end
                    end 
                            
                    --buffer靠近角色
                    if not is_remove and is_magnet then
                        local move_x = cur_pos_x
                        local move_y = cur_mot_pos_y
                        --向角色靠近
                        --x
                        if move_x < cur_role_pos.x then
                            move_x = move_x + magnet_speed
                        elseif move_x > cur_role_pos.x then
                            move_x = move_x - magnet_speed
                        end
                        --y
                        if move_y < cur_role_pos.y then
                            move_y = move_y + magnet_speed
                        elseif move_y > cur_role_pos.y then
                            move_y = move_y - magnet_speed
                        end
                        obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                    end

                    --是否移除
                    if not is_remove then
                        i = i + 1
                    end
                end
            end
        end
    end

    -------------------------------------------buffer类列表-------------------------------------------
    if #GameModel.mot_buffer_list ~= 0 then
        --cclog("buffer类列表 ================= " ..#GameModel.mot_buffer_list)
        local i=1
        while (i<=#GameModel.mot_buffer_list) do
            local obj = GameModel.mot_buffer_list[i]
           --if not obj:GetDie() then 池更新
               --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"buffer类列表")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameModel.mot_buffer_list,i)
               elseif not GameModel.Handler:getRole():GetRoleMagnet() and obj_world.x >= visible_size_half then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
               elseif not GameModel.Handler:getRole():GetRoleMagnet() and (obj_world.x+obj_width) < cur_role_scope.x then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else
                    if no_collide then
                        --直接移动
                        local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                        i = i +1
                    else
                         if obj.ani:isVisible() then
                            --********************弹簧********************
                            if obj:GetMonsterTag() == MONSTER_TYPE.item_stretch then
                                local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                                local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                                --local pos_x = parent_x + obj.ani:getPositionX()
                                --local next_pos_x = pos_x - obj:GetSpeedX()
                                local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()--obj.ani:getPositionX()--obj.ani:convertToWorldSpaceAR(cc.p(0,0))
                                local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                                --当前怪物碰撞区
                                local mot_width  = obj:GetScope().width
                                local mot_height = obj:GetScope().height
                                --当前怪物碰撞区
                                local cur_mot_pos_x   = cur_pos_x--obj.ani:getPositionX()-GameModel.create_range--cur_pos.x--obj.ani:getPositionX()
                                local cur_mot_pos_y   = obj.ani:getPositionY()--cur_pos.y--obj.ani:getPositionY()
                                local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                                --怪物下一个位置的碰撞区
                                local next_mot_pos      = cc.p( next_pos_x,obj.ani:getPositionY())
                                local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)

                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(draw_x,cur_mot_scope.y),--左下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "弹簧"
                                        )
                                end

                                --不是冲刺才进行碰撞检测
                                if not GameModel.Handler:getRole():GetRoleSpurt() then
                                    local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
                                
                                    --没有碰撞
                                    if result.x == 0 and result.y == 0 then
                                            --角色什么也不用做
                                    --角色向下碰撞
                                    elseif result.y < 0 then
                                            playEffect("res/music/effect/fight/r_spring.ogg")
                                            --向下碰到弹簧进行跳跃
                                            GameModel.Handler:getRole():SetJump1()
                                            GameModel.Handler:jumpTan()--用弹簧的跳跃
                                            GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                                            GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置

                                            
                                            local function AddSpeed()--设置场景速度变快
                                                GameModel.Handler:getRole().stretch_sum = GameModel.Handler:getRole().stretch_sum + 1
                                                GameModel:SetGlobalSpeed(15)
                                            end
                                            local function ResumSpeed()--恢复场景速度
                                                GameModel.Handler:getRole().stretch_sum = GameModel.Handler:getRole().stretch_sum - 1
                                                if not GameModel.Handler:getRole():GetRoleSpurt() and GameModel.Handler:getRole().stretch_sum == 0 then
                                                     GameModel:SetGlobalSpeed(0)
                                                end
                                            end
                 
                                            GameModel.Handler:runAction(cc.Sequence:create(cc.CallFunc:create(AddSpeed),cc.DelayTime:create(0.5),cc.CallFunc:create(ResumSpeed)))
                 
                                    --角色向右碰撞
                                    elseif result.x > 0 then
                                        local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                        next_role_scope.x = collide_rect.x-role_width
                                        --GameModel.Handler:setPositionY(next_role_pos.x-collide_rect.width)
                                        --往右撞要判断差值最大的 最后才set位置
                                        --if collide_range.right < collide_rect.width then
                                        --    collide_range.right = collide_rect.width
                                        --end
                
                                        --is_collide = true
                                    end
                                end
                            

                                next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                                obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
            
                            --********************无敌变大********************
                            elseif obj:GetMonsterTag() == MONSTER_TYPE.item_giant then
                                local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                                local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                                cur_pos_x = cur_pos_x - obj:GetSpeedX()
                                if obj.ani:isVisible() then
                                    --当前怪物碰撞区
                                    local mot_width  = obj:GetScope().width
                                    local mot_height = obj:GetScope().height
                                    --当前怪物碰撞区
                                    local cur_mot_pos_x   = cur_pos_x
                                    local cur_mot_pos_y   = obj.ani:getPositionY()
                                    local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                                    --碰撞方向
                                    --local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
            
                                    if obj.glNode then
                                        local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                        meta:DrawObj(
                                            obj.glNode,
                                            cc.p(draw_x,cur_mot_scope.y),--左下
                                            cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                            cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                            cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                            "无敌变大"
                                            )
                                    end
                                

                                    local is_magnet = false
                                    --碰撞检测
                                    if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                        --obj.ani:setVisible(false)
                                        obj.ani:removeFromParent(true)
                                        table.remove(GameModel.mot_buffer_list,i)
                                        is_remove = true
                                        playEffect("res/music/effect/fight/get_item.ogg")
                                        --无敌变大
                                        GameModel.Handler:getRole():Invincible(GameModel.Handler:getRole().big_time)
                                    else
                                        --磁铁状态无需移动
                                        if not GameModel.Handler:getRole():GetRoleMagnet() then
                                            cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                            obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                        else
                                            --半屏吸收
                                            if cur_pos_x <= visibleSize_width*4/5 then
                                                is_magnet = true
                                            else
                                                cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                            end
                                        end
                                    end

                                    --buffer靠近角色
                                    if not is_remove and is_magnet then
                                        local move_x = cur_mot_scope.x
                                        local move_y = cur_mot_scope.y
                                        --向角色靠近
                                        --x
                                        if move_x < cur_role_pos.x then
                                            move_x = move_x + magnet_speed
                                        elseif move_x > cur_role_pos.x then
                                            move_x = move_x - magnet_speed
                                        end
                                        --y
                                        if move_y < cur_role_pos.y then
                                            move_y = move_y + magnet_speed
                                        elseif move_y > cur_role_pos.y then
                                            move_y = move_y - magnet_speed
                                        end
                                        move_x = move_x - parent_pos_x
                                        obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    end

                                end
                            --********************护盾********************
                            elseif obj:GetMonsterTag() == MONSTER_TYPE.item_protect then
                                local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                                local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                                cur_pos_x = cur_pos_x - obj:GetSpeedX()
                                --当前怪物碰撞区
                                local mot_width  = obj:GetScope().width
                                local mot_height = obj:GetScope().height
                                --当前怪物碰撞区
                                local cur_mot_pos_x   = cur_pos_x
                                local cur_mot_pos_y   = obj.ani:getPositionY()
                                local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(draw_x,cur_mot_scope.y),--左下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "护盾"
                                        )
                                end
                            
                                local is_magnet = false
                                --碰撞检测
                                if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                    --得到护盾
                                    GameModel.Handler:getRole():SetRoleDun(true)
                                    GameModel.Handler:getRole().sprite_dun:setVisible(true)
                                    playEffect("res/music/effect/fight/get_item.ogg")
                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_buffer_list,i)
                                    is_remove = true
                                else
                                    --磁铁状态无需移动
                                    if not GameModel.Handler:getRole():GetRoleMagnet() then
                                        cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                        obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    else
                                        --半屏吸收
                                        if cur_pos_x <= visibleSize_width*4/5 then
                                            is_magnet = true
                                        else
                                            cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                            obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                        end
                                    end
                                end
                                 --buffer靠近角色
                                if not is_remove and is_magnet then
                                    local move_x = cur_mot_scope.x
                                    local move_y = cur_mot_scope.y
                                    --向角色靠近
                                    --x
                                    if move_x < cur_role_pos.x then
                                        move_x = move_x + magnet_speed
                                    elseif move_x > cur_role_pos.x then
                                        move_x = move_x - magnet_speed
                                    end
                                    --y
                                    if move_y < cur_role_pos.y then
                                        move_y = move_y + magnet_speed
                                    elseif move_y > cur_role_pos.y then
                                        move_y = move_y - magnet_speed
                                    end
                                    move_x = move_x - parent_pos_x
                                    obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                end
                             --********************冲刺********************
                            elseif obj:GetMonsterTag() == MONSTER_TYPE.item_spurt or obj:GetMonsterTag() == MONSTER_TYPE.item_fly then
                                local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                                local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                                cur_pos_x = cur_pos_x - obj:GetSpeedX()
                                --当前怪物碰撞区
                                local mot_width  = obj:GetScope().width
                                local mot_height = obj:GetScope().height
                                --当前怪物碰撞区
                                local cur_mot_pos_x   = cur_pos_x
                                local cur_mot_pos_y   = obj.ani:getPositionY()
                                local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(draw_x,cur_mot_scope.y),--左下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "冲刺"
                                        )
                                end
                            
                                local is_magnet = false
                                --碰撞检测
                                if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                    --冲刺
                                    GameModel.Handler:getRole():Spurt()
                                    --[[
                                    if not GameModel.Handler:getRole():GetRoleSpurt() then
                                        --设置角色冲刺状态
                                        GameModel.Handler:getRole():SetRoleSpurt(true)
                                        GameModel.Handler:getRole():SetRoleMagnet(true)--磁性效果
                                        GameModel:SetGlobalSpeed(15)
                                        --冲刺开始
                                        local function spurtStart()
                                            GameModel.Handler:getRole().sprite_spurt:setVisible(true)
                                            GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.spurt)
                                        end
                                        --冲刺结束
                                        local function spurtEnd()
                                            GameModel.Handler:setVyZero()--设置竖直速度为0
                                            GameModel.Handler:getRole().sprite_spurt:setVisible(false)
                                            GameModel.Handler:getRole():SetRoleSpurt(false)--冲刺结束
                                            GameModel.Handler:getRole():SetRoleMagnet(false)--磁性效果
                                            GameModel:SetGlobalSpeed(0)
                                            --触发显示浮梯
                                            local function EscalatorStart()--浮梯开始
                                                GameModel.Handler:getRole():SetRoleEscalator(true)
                                                --浮梯显示
                                                for i=1,#GameModel.mot_road_list do
                                                    GameModel.mot_road_list[i].ani:setVisible(true)
                                                end
                                            end
                                            local function EscalatorEnd()--浮梯结束
                                                GameModel.Handler:getRole():SetRoleEscalator(false)
                                            end
                                            local seq = cc.Sequence:create(cc.CallFunc:create(EscalatorStart),cc.DelayTime:create(GameModel.Handler:getRole().escalator_time),cc.CallFunc:create(EscalatorEnd))
                                            GameModel.Handler:runAction(seq)
                                            --清空场景怪物 盒子 金币 buffer列表
                                            GameModel.Handler:getRole().spurt_clear = true
                                        end
                                    
                                        --上下浮动
                                        local vec = cc.p(0,100)
                                        local move = cc.MoveBy:create(0.5,vec)
                                        local reverse =  move:reverse()
                                        local seq_moving = cc.Sequence:create(move,reverse)
                                    
                                        local spa  = cc.Spawn:create(cc.CallFunc:create(spurtStart),cc.MoveTo:create(1,cc.p(GameModel.Handler:getStdX(),visibleSize_height*3/5)))
                                        local spa2 = cc.Repeat:create(seq_moving,GameModel.Handler:getRole().spurt_time)--cc.Spawn:create(cc.DelayTime:create(GameModel.Handler:getRole().magnet_time),cc.Repeat:create(seq_moving,5))
                                        local seq = cc.Sequence:create(spa,spa2,cc.CallFunc:create(spurtEnd))
                                        GameModel.Handler:runAction(seq)
                                    end
                                    --]]
                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_buffer_list,i)
                                    is_remove = true
                                else
                                    --磁铁状态无需移动
                                    if not GameModel.Handler:getRole():GetRoleMagnet() then
                                        cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                        obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    else
                                        --半屏吸收
                                        if cur_pos_x <= visibleSize_width*4/5 then
                                            is_magnet = true
                                        else
                                            cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                            obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                        end
                                    end
                                end   
                                 --buffer靠近角色
                                if not is_remove and is_magnet then
                                    local move_x = cur_mot_scope.x 
                                    local move_y = cur_mot_scope.y 
                                    --向角色靠近
                                    --x
                                    if move_x < cur_role_pos.x then
                                        move_x = move_x + magnet_speed
                                    elseif move_x > cur_role_pos.x then
                                        move_x = move_x - magnet_speed
                                    end
                                    --y
                                    if move_y < cur_role_pos.y then
                                        move_y = move_y + magnet_speed
                                    elseif move_y > cur_role_pos.y then
                                        move_y = move_y - magnet_speed
                                    end
                                    move_x = move_x - parent_pos_x
                                    obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                end 
                            --********************磁铁********************
                            elseif obj:GetMonsterTag() == MONSTER_TYPE.item_magnet then
                                local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                                local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                                cur_pos_x = cur_pos_x - obj:GetSpeedX()
                                --当前怪物碰撞区
                                local mot_width  = obj:GetScope().width
                                local mot_height = obj:GetScope().height
                                --当前怪物碰撞区
                                local cur_mot_pos_x   = cur_pos_x
                                local cur_mot_pos_y   = obj.ani:getPositionY()
                                local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(draw_x,cur_mot_scope.y),--左下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "磁铁"
                                        )
                                end

                                local is_magnet = false
                                --碰撞检测
                                if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                    playEffect("res/music/effect/fight/get_item.ogg")
                                    if not GameModel.Handler:getRole():GetRoleMagnet() then
                                        --设置角色磁铁状态
                                        GameModel.Handler:getRole():SetRoleMagnet(true)

                                        local function magnetEnd()
                                            GameModel.Handler:getRole():SetRoleMagnet(false)
                                        end

                                        local seq = cc.Sequence:create(cc.DelayTime:create(GameModel.Handler:getRole().magnet_time),cc.CallFunc:create(magnetEnd))
                                        GameModel.Handler:runAction(seq)
                                    end
                                

                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_buffer_list,i)
                                    is_remove = true
                                else
                                    --磁铁状态无需移动
                                    if not GameModel.Handler:getRole():GetRoleMagnet() then
                                        cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                        obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    else
                                        --半屏吸收
                                        if cur_pos_x <= visibleSize_width*4/5 then
                                            is_magnet = true
                                        else
                                            cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                            obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                        end
                                    end
                                end  
                                --buffer靠近角色
                                if not is_remove and is_magnet then
                                    local move_x = cur_mot_scope.x
                                    local move_y = cur_mot_scope.y
                                    --向角色靠近
                                    --x
                                    if move_x < cur_role_pos.x then
                                        move_x = move_x + magnet_speed
                                    elseif move_x > cur_role_pos.x then
                                        move_x = move_x - magnet_speed
                                    end
                                    --y
                                    if move_y < cur_role_pos.y then
                                        move_y = move_y + magnet_speed
                                    elseif move_y > cur_role_pos.y then
                                        move_y = move_y - magnet_speed
                                    end
                                    move_x = move_x - parent_pos_x
                                    obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                end
                            --********************血瓶********************
                            elseif obj:GetMonsterTag() == MONSTER_TYPE.item_addHp then
                                local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                                local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                                cur_pos_x = cur_pos_x - obj:GetSpeedX()
                                --当前怪物碰撞区
                                local mot_width  = obj:GetScope().width
                                local mot_height = obj:GetScope().height
                                --当前怪物碰撞区
                                local cur_mot_pos_x   = cur_pos_x
                                local cur_mot_pos_y   = obj.ani:getPositionY()
                                local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(draw_x,cur_mot_scope.y),--左下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "血瓶"
                                        )
                                end
                            
                                local is_magnet = false
                                --碰撞检测
                                if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                    playEffect("res/music/effect/fight/get_item.ogg")
                                    local resumHp = obj.resumHp
                                    GameModel.Handler:getRole():AddHp(resumHp) 

                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_buffer_list,i)
                                    is_remove = true
                                else
                                   --磁铁状态无需移动
                                    if not GameModel.Handler:getRole():GetRoleMagnet() then
                                        cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                        obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    else
                                       --半屏吸收
                                        if cur_pos_x <= visibleSize_width*4/5 then
                                            is_magnet = true
                                        else
                                            cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                            obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                        end
                                    end
                                end 
                            
                                --buffer靠近角色
                                if not is_remove and is_magnet then
                                    local move_x = cur_mot_scope.x
                                    local move_y = cur_mot_scope.y
                                    --向角色靠近
                                    --x
                                    if move_x < cur_role_pos.x then
                                        move_x = move_x + magnet_speed
                                    elseif move_x > cur_role_pos.x then
                                        move_x = move_x - magnet_speed
                                    end
                                    --y
                                    if move_y < cur_role_pos.y then
                                        move_y = move_y + magnet_speed
                                    elseif move_y > cur_role_pos.y then
                                        move_y = move_y - magnet_speed
                                    end
                                    move_x = move_x - parent_pos_x
                                    obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                end
                            --********************浮梯道具********************
                            elseif obj:GetMonsterTag() == MONSTER_TYPE.item_escalator then
                                local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                                local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                                cur_pos_x = cur_pos_x - obj:GetSpeedX()
                                --当前怪物碰撞区
                                local mot_width  = obj:GetScope().width
                                local mot_height = obj:GetScope().height
                                --当前怪物碰撞区
                                local cur_mot_pos_x   = cur_pos_x
                                local cur_mot_pos_y   = obj.ani:getPositionY()
                                local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                                if obj.glNode then
                                    local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                    meta:DrawObj(
                                        obj.glNode,
                                        cc.p(draw_x,cur_mot_scope.y),--左下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                        cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                        cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                        "浮梯道具"
                                        )
                                end
                            
                                local is_magnet = false
                                --碰撞检测
                                if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                    playEffect("res/music/effect/fight/get_item.ogg")
                                    if not GameModel.Handler:getRole():GetRoleEscalator() then
                                        local function EscalatorStart()--浮梯开始
                                            GameModel.Handler:getRole():SetRoleEscalator(true)
                                            --浮梯显示
                                            for i=1,#GameModel.mot_road_list do
                                                GameModel.mot_road_list[i].ani:setVisible(true)
                                            end
                                        end
                                        local function EscalatorEnd()--浮梯结束
                                            GameModel.Handler:getRole():SetRoleEscalator(false)
                                        end
                                        local seq = cc.Sequence:create(cc.CallFunc:create(EscalatorStart),cc.DelayTime:create(GameModel.Handler:getRole().escalator_time),cc.CallFunc:create(EscalatorEnd))
                                        GameModel.Handler:runAction(seq)
                                    end
                                    

                                    obj.ani:removeFromParent(true)
                                    table.remove(GameModel.mot_buffer_list,i)
                                    is_remove = true
                                else
                                   --磁铁状态无需移动
                                    if not GameModel.Handler:getRole():GetRoleMagnet() then
                                        cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                        obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    else
                                       --半屏吸收
                                        if cur_pos_x <= visibleSize_width*4/5 then
                                            is_magnet = true
                                        else
                                            cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                            obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                        end
                                    end
                                end 
                            
                                --buffer靠近角色
                                if not is_remove and is_magnet then
                                    local move_x = cur_mot_scope.x
                                    local move_y = cur_mot_scope.y
                                    --向角色靠近
                                    --x
                                    if move_x < cur_role_pos.x then
                                        move_x = move_x + magnet_speed
                                    elseif move_x > cur_role_pos.x then
                                        move_x = move_x - magnet_speed
                                    end
                                    --y
                                    if move_y < cur_role_pos.y then
                                        move_y = move_y + magnet_speed
                                    elseif move_y > cur_role_pos.y then
                                        move_y = move_y - magnet_speed
                                    end
                                    move_x = move_x - parent_pos_x
                                    obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                end  
                            else    
                                --其他buffer
                                local pos_x = obj.ani:getPositionX()
                                pos_x = pos_x - obj:GetSpeedX()
                                obj.ani:setPositionX(pos_x)
                           end

                        end
                    
                        --是否移除
                        if not is_remove then
                            i = i + 1
                        end
                    end

                end
           --end 池更新
                    
        end
            
    end
    


    --判断上一次是否在路面
    GameModel.Handler:getRole():checkPreFloor()
   
   --冲刺时候人物是穿越并且无重力状态
    if not GameModel.Handler:getRole():GetRoleSpurt() then
        GameModel.Handler:setPosition(cc.p(next_role_scope.x,next_role_scope.y))
    end
    
    --清空场景怪物 盒子 金币 buffer列表
    if GameModel.Handler:getRole().spurt_clear then
        GameModel.Handler:getRole().spurt_clear = false--重置
        local remove_i = 1
        while (remove_i<=#GameModel.mot_gift_list) do
            GameModel.mot_gift_list[remove_i].ani:removeFromParent(true)
            remove_i = remove_i + 1
        end
        local remove_i = 1
        while (remove_i<=#GameModel.mot_flygift_list) do
            GameModel.mot_flygift_list[remove_i].ani:removeFromParent(true)
            remove_i = remove_i + 1
        end
        remove_i = 1
        while (remove_i<=#GameModel.mot_obj_list) do
            GameModel.mot_obj_list[remove_i].ani:removeFromParent(true)
            remove_i = remove_i + 1
        end

        remove_i = 1
        while (remove_i<=#GameModel.mot_block_list) do
            GameModel.mot_block_list[remove_i].ani:removeFromParent(true)
            remove_i = remove_i + 1
        end

        remove_i = 1
        while (remove_i<=#GameModel.mot_hurt_list) do
            GameModel.mot_hurt_list[remove_i].ani:removeFromParent(true)
            remove_i = remove_i + 1
        end
        remove_i = 1
        while (remove_i<=#GameModel.mot_gold_list) do
            GameModel.mot_gold_list[remove_i].ani:removeFromParent(true)
            remove_i = remove_i + 1
        end
        remove_i = 1
        while (remove_i<=#GameModel.mot_flygold_list) do
            GameModel.mot_flygold_list[remove_i].ani:removeFromParent(true)
            remove_i = remove_i + 1
        end
        remove_i = 1
        while (remove_i<=#GameModel.mot_buffer_list) do
            GameModel.mot_buffer_list[remove_i].ani:setVisible(false)
            remove_i = remove_i + 1
        end
        GameModel.mot_gift_list    = {}
        GameModel.mot_flygift_list = {}
        GameModel.mot_obj_list     = {}
        GameModel.mot_block_list   = {}
        GameModel.mot_hurt_list    = {}
        GameModel.mot_gold_list    = {}
        GameModel.mot_flygold_list = {}
        GameModel.mot_buffer_list  = {}
    end
    


    --cclog("GameModel.Handler:getDiff().y == " ..GameModel.Handler:getDiff().y)
    --检测完以后设置最后玩家位置(只针对能够阻碍角色前进的对象)
    --if is_collide then
    --    --GameModel.Handler:setPosition(cc.p(next_role_scope.x-collide_range.right,next_role_scope.y+collide_range.down))
        
    --else
    --    GameModel.Handler:setPosition(cc.p(next_role_scope.x,next_role_scope.y))
    --end
end
--检查清除原来场景的对象
function meta:checkNormalScene()
    if not GameRewardM.is_just_reward then--是否刚进入奖励模式
        GameRewardM.is_just_reward = true
        --清空所有普通场景对象列表(注意清空的对象 别弄错)
        GameModel:clearAllObj()
    end
end
--更新奖励模式对象
function meta:UpdateGameRewardObject(cur_role_scope,next_role_scope,magnet_speed)
    --检查清除原来场景的对象
    meta:checkNormalScene()
    local visible_size_half = visibleSize_width/2
-------------------------------------------奖励地面-------------------------------------------
    if #GameRewardM.mot_floor_list ~= 0 then
        local i=1
        while (i<=#GameRewardM.mot_floor_list) do
            local obj = GameRewardM.mot_floor_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"奖励地面")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    obj.ani:removeFromParent(true)
                    table.remove(GameRewardM.mot_floor_list,i)
                elseif obj_world.x >= visible_size_half then
                    break
                else
                    local parent_pre_x = obj.ani:getParent().pre_pos_x--获取父节点在上一次的位置
                    local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                    --local pos_x = parent_x + obj.ani:getPositionX()
                    --local next_pos_x = pos_x - obj:GetSpeedX()

                    local cur_pos_x =  parent_pre_x+obj.ani:getPositionX()
                    local next_pos_x = parent_pos_x+obj.ani:getPositionX() - obj:GetSpeedX()

                    --当前怪物碰撞区
                    local mot_width  = obj:GetScopeWidth()
                    local mot_height = obj:GetScopeHeight()
                    --当前怪物碰撞区
                    local cur_mot_pos_x   = cur_pos_x
                    local cur_mot_pos_y   = obj.ani:getPositionY()
                    local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
                    --怪物下一个位置的碰撞区
                    local next_mot_pos      = cc.p( next_pos_x, obj.ani:getPositionY())
                    local next_mot_scope    = cc.rect(next_mot_pos.x,next_mot_pos.y,mot_width,mot_height)


                    if obj.glNode then
                        local draw_x = obj.ani:getPositionX()--+GameRewardM.create_range
                        meta:DrawObj(
                            obj.glNode,
                            cc.p(draw_x,cur_mot_scope.y),--左下
                            cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                            cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                            cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                            "奖励地面"
                            )
                    end
            
                    --不是冲刺才进行碰撞检测
                    if not GameModel.Handler:getRole():GetRoleSpurt() then
                        local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)

                        --没有碰撞
                        if result.x == 0 and result.y == 0 then
                                --角色什么也不用做
                        --角色向下碰撞
                        elseif result.y < 0 then
                                local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                                next_role_scope.y = obj.ani:getPositionY()+obj:GetScopeHeight()--collide_rect.y+collide_rect.height--修正角色位置
                                ----往下撞要判断差值最大的 最后才set位置
                                --if collide_range_down < collide_rect.height then
                                --   collide_range_down = collide_rect.height
                                --end
                         
                                if (not GameModel.Handler:getRole():GetRun() and not GameModel.Handler:getRole():GetAirAttack() and not GameModel.Handler:getRole():GetAttack()) or  GameModel.Handler:getRole():GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.spurt then
                                    GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.run)
                                    --cclog("111111111")
                                end
                
                                if not GameModel.Handler:getRole():GetAttack() then
                                    GameModel.Handler:getRole():SetRun()
                                    GameModel.Handler:getRole():SetIsFloor(false)--赋值给上一次是否在路面
                                    --cclog("行号 ====== " ..4291)
                                end
                                
                                GameModel.Handler:getRole():GlidingReset()--滑翔设置 内设重置
                                if not GameModel.Handler:getRole():GetIsFloor() then
                                    GameModel.Handler:getRole():SetIsFloor(true)--赋值给上一次是否在路面
                                end
                 
                 
                                GameModel.Handler:setVyZero()--落地后设置速度为0
                 
                                --is_collide = true
                                --GameModel.Handler:setPositionY(next_role_pos.y+collide_rect.height)
                                --break
                        --角色向右碰撞
                        elseif result.x > 0 then
                            local collide_rect = GameModel.CollideHandler:CollisionRect(next_role_scope,next_mot_scope)
                            next_role_scope.x = collide_rect.x-next_role_scope.width

                            
                        end
          
                    end

                    next_pos_x = obj.ani:getPositionX() - obj:GetSpeedX()--obj.ani:getParent():convertToNodeSpaceAR(cc.p(next_pos_x,cur_mot_pos_y))
                    obj.ani:setPositionX(next_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                    i = i + 1
                    
                    
                end 
            --end 池更新

        end
    end
    -------------------------------------------金币类列表-------------------------------------------
    if #GameRewardM.mot_gold_list ~= 0 then
        --if #GameRewardM.mot_gold_list > 10 then
        --   cclog("#GameRewardM.mot_gold_list =========== " ..#GameRewardM.mot_gold_list)
        --end
        --gold_index = 1
        local i=1
        while (i<=#GameRewardM.mot_gold_list) do
            local obj = GameRewardM.mot_gold_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"奖励金币类列表")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameRewardM.mot_gold_list,i)
                elseif not GameModel.Handler:getRole():GetRoleMagnet() and obj_world.x >= visible_size_half then
                   break
                elseif not GameModel.Handler:getRole():GetRoleMagnet() and (obj_world.x+obj_width) < cur_role_scope.x then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else
                    
                    if no_collide then
                         --直接移动
                        local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                        i = i + 1  
                    else
                        local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                        local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                        cur_pos_x = cur_pos_x - obj:GetSpeedX()
                        if obj.ani:isVisible() then
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = cur_pos_x
                            local cur_mot_pos_y   = obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)

                        --    --碰撞方向
                        --    --local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
            
                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                    "奖励金币类"
                                    )
                            end
                        
                            local is_magnet = false--磁铁效果:是否开始吸收
                            --碰撞检测
                            if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                --obj.ani:setVisible(false)
                                playEffect("res/music/effect/fight/gold.ogg")
                                obj.ani:removeFromParent(true)
                                table.remove(GameRewardM.mot_gold_list,i)
                                is_remove = true

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)

                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                            else
                                --磁铁状态无需移动
                                if not GameModel.Handler:getRole():GetRoleMagnet() then
                                    cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                    obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                else
                                    --半屏吸收
                                    if cur_pos_x <= visibleSize_width*4/5 then
                                        is_magnet = true
                                    else
                                        cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                        obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    end
                                end

                            end

                            --buffer靠近角色
                            if not is_remove and is_magnet then
                                local move_x = cur_mot_scope.x
                                local move_y = cur_mot_scope.y
                                --向角色靠近
                                --x
                                if move_x < cur_role_scope.x then
                                    move_x = move_x + magnet_speed
                                elseif move_x > cur_role_scope.x then
                                    move_x = move_x - magnet_speed
                                end
                                --y
                                if move_y < cur_role_scope.y then
                                    move_y = move_y + magnet_speed
                                elseif move_y > cur_role_scope.y then
                                    move_y = move_y - magnet_speed
                                end
                                move_x = move_x - parent_pos_x
                                obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end


                        end
                        --是否移除
                        if not is_remove then
                            i = i + 1
                        end
                        

                        
                    end
                   
                end
            --end 池更新
            
        end
    end
    -------------------------------------------飞行金币类列表-------------------------------------------
    if #GameRewardM.mot_flygold_list ~= 0 then
        --if #GameRewardM.mot_flygold_list > 10 then
        --   cclog("#GameRewardM.mot_flygold_list =========== " ..#GameRewardM.mot_flygold_list)
        --end
        --gold_index = 1
        local i=1
        while (i<=#GameRewardM.mot_flygold_list) do
            local obj = GameRewardM.mot_flygold_list[i]
            --if not obj:GetDie() then 池更新
                --检查释放对象
                local is_remove = false
                local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"飞行金币类列表")
                local obj_width = obj.ani:getContentSize().width
                if obj_world.x < - obj_width then
                    --obj:SetDie(true) 池更新
                    obj.ani:removeFromParent(true)
                    table.remove(GameRewardM.mot_flygold_list,i)
                elseif not GameModel.Handler:getRole():GetRoleMagnet() and obj_world.x >= visible_size_half then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                elseif not GameModel.Handler:getRole():GetRoleMagnet() and (obj_world.x+obj_width) < cur_role_scope.x then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i + 1
                else

                    if no_collide then
                         --直接移动
                        local pos_x = obj.ani:getPositionX()
                        pos_x = pos_x - obj:GetSpeedX()
                        obj.ani:setPositionX(pos_x)
                        i = i + 1  
                    else
                        local parent_pos_x,parent_pos_y = obj.ani:getParent():getPosition()--当前父节点位置
                        local cur_pos_x = parent_pos_x + obj.ani:getPositionX()
                        cur_pos_x = cur_pos_x - obj:GetSpeedX()
                        if obj.ani:isVisible() then
                            --当前怪物碰撞区
                            local mot_width  = obj:GetScope().width
                            local mot_height = obj:GetScope().height
                            --当前怪物碰撞区
                            local cur_mot_pos_x   = cur_pos_x
                            local cur_mot_pos_y   = obj.ani:getPositionY()
                            local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)

                        --    --碰撞方向
                        --    --local result = GameModel.CollideHandler:Collision(cur_role_scope,next_role_scope,cur_mot_scope,next_mot_scope)
            
                            if obj.glNode then
                                local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                                meta:DrawObj(
                                    obj.glNode,
                                    cc.p(draw_x,cur_mot_scope.y),--左下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                                    cc.p(draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                                    cc.p(draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                                    "奖励金币类"
                                    )
                            end
                        
                            local is_magnet = false--磁铁效果:是否开始吸收
                            --碰撞检测
                            if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                                --obj.ani:setVisible(false)
                                playEffect("res/music/effect/fight/gold.ogg")
                                obj.ani:removeFromParent(true)
                                table.remove(GameRewardM.mot_flygold_list,i)
                                is_remove = true

                                GameModel.biaoxian_score = GameModel.biaoxian_score + obj.show
                                GameSceneUi:setBiaoxianNumber(GameModel.biaoxian_score)

                                if GameSceneUi.game_is_score then--按表现分算就开启
                                    GameSceneUi:setChangeScenePercentNumber(obj.show)
                                    GameSceneUi:setHeroRewardProgress()--设置英雄当前进入奖励模式进度条
                                end
                            else
                                --磁铁状态无需移动
                                if not GameModel.Handler:getRole():GetRoleMagnet() then
                                    cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                    obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                else
                                    --半屏吸收
                                    if cur_pos_x <= visibleSize_width*4/5 then
                                        is_magnet = true
                                    else
                                        cur_pos_x = obj.ani:getPositionX()- obj:GetSpeedX()
                                        obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                                    end
                                end

                            end

                            --buffer靠近角色
                            if not is_remove and is_magnet then
                                local move_x = cur_mot_scope.x
                                local move_y = cur_mot_scope.y
                                --向角色靠近
                                --x
                                if move_x < cur_role_scope.x then
                                    move_x = move_x + magnet_speed
                                elseif move_x > cur_role_scope.x then
                                    move_x = move_x - magnet_speed
                                end
                                --y
                                if move_y < cur_role_scope.y then
                                    move_y = move_y + magnet_speed
                                elseif move_y > cur_role_scope.y then
                                    move_y = move_y - magnet_speed
                                end
                                move_x = move_x - parent_pos_x
                                obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end


                        end
                        --是否移除
                        if not is_remove then
                            i = i + 1
                        end
                        

                        
                    end
                   
                end
            --end 池更新
            
        end
    end

    -------------------------------------------动态类列表(血瓶)-------------------------------------------
    if #GameModel.dynamic_hp_list ~= 0 then
        local i=1
        while (i<=#GameModel.dynamic_hp_list) do
            local obj = GameModel.dynamic_hp_list[i]
            local is_remove = false
            local obj_world = obj.ani:convertToWorldSpace(cc.p(0,0))--ConvertToWorldSpace(obj.ani,"奖励动态类列表(血瓶)")
            local obj_width = obj.ani:getContentSize().width
            if obj_world.x < - obj_width then
                obj.ani:removeFromParent(true)
                table.remove(GameModel.dynamic_hp_list,i)
            elseif not GameModel.Handler:getRole():GetRoleMagnet() and obj_world.x >= visible_size_half then
                --直接移动
                local pos_x = obj.ani:getPositionX()
                pos_x = pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed() - obj:GetSpeedX()
                obj.ani:setPositionX(pos_x)
                i = i +1
            elseif not GameModel.Handler:getRole():GetRoleMagnet() and (obj_world.x+obj_width) < cur_role_scope.x then
               --直接移动
                local pos_x = obj.ani:getPositionX()
                pos_x = pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed() - obj:GetSpeedX()
                obj.ani:setPositionX(pos_x)
                i = i +1
            else
                if no_collide then
                    --直接移动
                    local pos_x = obj.ani:getPositionX()
                    pos_x = pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed() - obj:GetSpeedX()
                    obj.ani:setPositionX(pos_x)
                    i = i +1
                else
                    local cur_pos_x = obj.ani:getPositionX()
                    cur_pos_x = cur_pos_x - GameModel:GetLayerSpeed() - GameModel:GetGlobalSpeed() - obj:GetSpeedX()
                    --当前怪物碰撞区
                    local mot_width  = obj:GetScopeWidth()
                    local mot_height = obj:GetScopeHeight()
                    --当前怪物碰撞区
                    local cur_mot_pos_x   = obj:GetScopePosX()+cur_pos_x
                    local cur_mot_pos_y   = obj.ani:getPositionY()
                    local cur_mot_scope   = cc.rect(cur_mot_pos_x,cur_mot_pos_y,mot_width,mot_height)
           
                    if obj.glNode then
                        local draw_x = obj.ani:getPositionX()--+GameModel.create_range
                        meta:DrawObj(
                            obj.glNode,
                            cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y),--左下
                            cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y),--右下
                            cc.p(obj:GetScopePosX()+draw_x+cur_mot_scope.width,cur_mot_scope.y+cur_mot_scope.height),--右上
                            cc.p(obj:GetScopePosX()+draw_x,cur_mot_scope.y+cur_mot_scope.height),--左上
                            "奖励动态类"
                            )
                    end
                            
                    local is_magnet = false
                    --碰撞检测
                    if cc.rectIntersectsRect(cur_role_scope,cur_mot_scope) then
                        playEffect("res/music/effect/fight/get_item.ogg")
                        local resumHp = obj.resumHp
                        GameModel.Handler:getRole():AddHp(resumHp) 

                        obj.ani:removeFromParent(true)
                        table.remove(GameModel.dynamic_hp_list,i)
                        is_remove = true
                    else
                        --磁铁状态无需移动
                        if not GameModel.Handler:getRole():GetRoleMagnet() then
                            obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                        else
                            --半屏吸收
                            if cur_pos_x <= visibleSize_width*4/5 then
                                is_magnet = true
                            else
                                obj.ani:setPositionX(cur_pos_x)--地面时肯定会往左移动的 角色无法阻挡地面前进
                            end
                        end
                    end 
                            
                    --buffer靠近角色
                    if not is_remove and is_magnet then
                        local move_x = cur_pos_x
                        local move_y = cur_mot_pos_y
                        --向角色靠近
                        --x
                        if move_x < cur_role_scope.x then
                            move_x = move_x + magnet_speed
                        elseif move_x > cur_role_scope.x then
                            move_x = move_x - magnet_speed
                        end
                        --y
                        if move_y < cur_role_scope.y then
                            move_y = move_y + magnet_speed
                        elseif move_y > cur_role_scope.y then
                            move_y = move_y - magnet_speed
                        end
                        obj.ani:setPosition(move_x,move_y)--地面时肯定会往左移动的 角色无法阻挡地面前进
                    end

                    --是否移除
                    if not is_remove then
                        i = i + 1
                    end
                end
            end
        end
    end


    --判断上一次是否在路面
   --GameModel.Handler:getRole():checkPreFloor()
   
   --冲刺时候人物是穿越并且无重力状态
    if not GameModel.Handler:getRole():GetRoleSpurt() then
        GameModel.Handler:setPosition(cc.p(next_role_scope.x,next_role_scope.y))
    end
     
end
--释放接口
function meta:release(is_repeat)
    GameModel.Handler:unscheduleUpdate()--停止角色定时器
    GameModel:releaseAllList()--清空所有列表
    meta.mainLayer:unscheduleUpdate()--停止定时器
    meta.mainLayer:removeAllChildren(true)
    meta.map_layer_list = {}
    meta.reward_layer_list = {}
    --重来的情况才进
    if is_repeat then
        --拆分转化地图数据
        GameModel:ConverData()
    end
end
--bossAI
function meta:UpdateBossAi()
    
    --死亡后无需检测
   if GameModel:GetGameSetup() == GAME_STEP.game_role_die or not GameModel.Boss_Handler or not GameModel.Handler then
        return
   end

    --暂停
    if GameModel:GetGameSetup() == GAME_STEP.game_ready or g_isPause then
        return
    end

    if GameModel:GetGameSetup() == GAME_STEP.game_boss and not GameModel:getBossDie() then
       
       -------------------------远战-----------------------
       if GameModel.Handler:getRole():GetAtkType() == ROLE_ATK_TYPE.farwar then
            --与角色怪物子弹碰撞检测
            local bullet_i = 1
            --cclog("#GameModel.Handler:getRole().bullet_list == " .. #GameModel.Handler:getRole().bullet_list)
            while ( bullet_i <= #GameModel.Handler:getRole().bullet_list) do
                local role_bullet = GameModel.Handler:getRole().bullet_list[bullet_i]
                --cclog("role_bullet:getAnimation():getCurrentMovementID() = " ..role_bullet:getAnimation():getCurrentMovementID())
                if role_bullet:getAnimation():getCurrentMovementID() == ANIMATION_ENUM.hit then
                    --击中
                else--if role_bullet:getAnimation():getCurrentMovementID() == ANIMATION_ENUM.fly then
                    local bullet_rect = cc.rect(role_bullet:getPositionX(),role_bullet:getPositionY()-role_bullet:getContentSize().height/2,role_bullet:getContentSize().width,role_bullet:getContentSize().height)
                    --cclog("bullet_rect.x ============== " ..bullet_rect.x)
                    --cclog("bullet_rect.y ============== " ..bullet_rect.y)  
                    --cclog("bullet_rect.w ============== " ..bullet_rect.width)  
                    --cclog("bullet_rect.h ============== " ..bullet_rect.height)                  
                    if GameModel.Handler:getRole().bullet_draw then
                        meta:DrawObj(
                            GameModel.Handler:getRole().bullet_draw,
                            cc.p(bullet_rect.x,bullet_rect.y),--左下
                            cc.p(bullet_rect.x+bullet_rect.width,bullet_rect.y),--右下
                            cc.p(bullet_rect.x+bullet_rect.width,bullet_rect.y+bullet_rect.height),--右上
                            cc.p(bullet_rect.x,bullet_rect.y+bullet_rect.height),--左上
                            "bossAI角色子弹碰撞区"
                            )
                    end
                
                    --boss碰撞区
                    local boss_scope = GameModel.Boss_Handler:GetBossRect()
                    if GameModel.Boss_Handler.bullet_draw then
                        meta:DrawObj(
                                GameModel.Boss_Handler.bullet_draw,
                                cc.p(boss_scope.x,boss_scope.y),--左下
                                cc.p(boss_scope.x+boss_scope.width,boss_scope.y),--右下
                                cc.p(boss_scope.x+boss_scope.width,boss_scope.y+boss_scope.height),--右上
                                cc.p(boss_scope.x,boss_scope.y+boss_scope.height),--左上
                                "bossAI碰撞区"
                                )
                        cclog("行号 =============== 4761" )
                    end

                                
                    --子弹与boss碰撞
                    if cc.rectIntersectsRect(bullet_rect,boss_scope) then
                        --cclog("子弹与boss碰撞")
                        --子弹释放
                        role_bullet:stopAllActions()
                        role_bullet:getAnimation():play(ANIMATION_ENUM.hit)
                        local injure = GameModel.Handler:getRole():GetDataAttack()--获取角色攻击力数值
                        if GameModel.Handler:getRole():checkCurt() then--暴击
                            injure = injure*2
                        else
                            local offsect = Rand:randnum(1,50)--浮动伤害
                            injure = injure + offsect
                        end
                        local boss_die = GameModel.Boss_Handler:setInjureString(injure) 
                        
                        --GameModel:setBossDie(boss_die)--设置boss是否死亡     
                        --break
                    end
                    --cclog("*******************")
                end

                bullet_i = bullet_i + 1
            end


       ---[[近战点击出现伤血 可以由控制层完成
       -----------------------近战-----------------------
       elseif GameModel.Handler:getRole():GetAtkType() == ROLE_ATK_TYPE.melee then
           if GameModel.Boss_Handler:getBossInjured() then
                cclog("getBossInjured")
                GameModel.Boss_Handler:setBossInjured(false)
                local cur_role_pos  = GameModel.Handler:getCurPosition()
                local scale         = GameModel.Handler:getScale()

                --角色碰撞宽高
                local role_width    =  math.ceil(GameModel.Handler:getRole():GetRoleScope().atk.width*scale)
                local role_height   = math.ceil(GameModel.Handler:getRole():GetRoleScope().atk.height*scale)

               --当前角色碰撞区
               local cur_role_scope = cc.rect(cur_role_pos.x,cur_role_pos.y,role_width,role_height)
                
               --boss碰撞区
               local boss_scope     = GameModel.Boss_Handler:GetBossRect()

               --碰撞
               if cc.rectIntersectsRect(cur_role_scope,boss_scope) then
                    --击中效果
                    boss_scope.x = boss_scope.x + boss_scope.width/2
                    GameModel.Handler:getRole():MeleeHit(boss_scope)

                    local injure = GameModel.Handler:getRole():GetDataAttack()--获取角色攻击力数值
                    if GameModel.Handler:getRole():checkCurt() then
                        injure = injure*2
                    else
                        local offsect = Rand:randnum(1,50)--浮动伤害
                        injure = injure + offsect
                    end
                    local boss_die = GameModel.Boss_Handler:setInjureString(injure)
                    --GameModel:setBossDie(boss_die)--设置boss是否死亡
               end

               if GameModel.Handler:getRole().glNode then
                    meta:DrawObj(
                    GameModel.Handler:getRole().glNode,
                    cc.p(cur_role_scope.x,cur_role_scope.y),--左下
                    cc.p(cur_role_scope.x+cur_role_scope.width,cur_role_scope.y),--右下
                    cc.p(cur_role_scope.x+cur_role_scope.width,cur_role_scope.y+cur_role_scope.height),--右上
                    cc.p(cur_role_scope.x,cur_role_scope.y+cur_role_scope.height),--左上
                    "bossAI角色攻击碰撞区"
                    )
                end
                
           end
        --]]
       
       
       end

       

    end
end

          
--******************************************************************************************************************************
--********************************************************压力测试**************************************************************
--******************************************************************************************************************************
function meta:pressureTest()
    

    --update用
    meta.batch_a = cc.SpriteBatchNode:create("160022.png")
    meta.mainLayer:addChild(meta.batch_a)

    meta.batch_b = cc.SpriteBatchNode:create("160023.png")
    meta.mainLayer:addChild(meta.batch_b)




    local node_sum = 1000
    local node_sum_label = cc.LabelTTF:create("1000","宋体",30)
    node_sum_label:setPosition(100,visibleSize_height*2/3)
    meta.mainLayer:addChild(node_sum_label)

    local function AddNode()--AddNode
        node_sum = node_sum + 100
        node_sum_label:setString(node_sum)
    end
    local function ReduceNode()--ReduceNode
        node_sum = node_sum - 100
        if node_sum <= 0 then
            node_sum = 0
        end
        node_sum_label:setString(node_sum)
    end


    local function SpriteBatchNode()--SpriteBatchNode
        meta:TestSpriteBatchNode(node_sum)
    end
    local function AutoBatching()--Auto-batching
        meta:AutoBatching(node_sum)
    end
    local function ReleaseAll()--ReleaseAll
        meta:ReleaseAll()
    end


    local function RenderTypeSpriteBatchNode()
       meta.render_type = 1
    end

    local function RenderTypeAutoBatching()
       meta.render_type = 2
    end

    ----RenderType-SpriteBatchNode
    local RenderTypeSpriteBatchNode_btn = cc.MenuItemFont:create("UpdateBatch")
    RenderTypeSpriteBatchNode_btn:registerScriptTapHandler(RenderTypeSpriteBatchNode)
    RenderTypeSpriteBatchNode_btn:setPosition(100-(visibleSize_width - 200),visibleSize_height/2)

    ----RenderType-Auto-batching
    local RenderTypeAutoBatching_btn = cc.MenuItemFont:create("UpdateAuto")
    RenderTypeAutoBatching_btn:registerScriptTapHandler(RenderTypeAutoBatching)
    RenderTypeAutoBatching_btn:setPosition(100-(visibleSize_width - 200),visibleSize_height/3)


    ----AddNode
    local AddNode_btn = cc.MenuItemFont:create("AddNode")
    AddNode_btn:registerScriptTapHandler(AddNode)
    AddNode_btn:setPositionY(0)

    ----ReduceNode
    local ReduceNode_btn = cc.MenuItemFont:create("ReduceNode")
    ReduceNode_btn:registerScriptTapHandler(ReduceNode)
    ReduceNode_btn:setPositionY(100)

    --ReleaseAll
    local ReleaseAll_btn = cc.MenuItemFont:create("ReleaseAll")
    ReleaseAll_btn:registerScriptTapHandler(ReleaseAll)
    ReleaseAll_btn:setPositionY(200)
    --SpriteBatchNode
    local SpriteBatchNode_btn = cc.MenuItemFont:create("SpriteBatchNode")
    SpriteBatchNode_btn:registerScriptTapHandler(SpriteBatchNode)
    SpriteBatchNode_btn:setPositionY(300)
    --Auto-batching
    local AutoBatching_btn = cc.MenuItemFont:create("AutoBatching")
    AutoBatching_btn:registerScriptTapHandler(AutoBatching)
    AutoBatching_btn:setPositionY(400)
    --菜单
    local menu = cc.Menu:create(SpriteBatchNode_btn,AutoBatching_btn,ReleaseAll_btn,AddNode_btn,ReduceNode_btn,RenderTypeSpriteBatchNode_btn,RenderTypeAutoBatching_btn)
    menu:setPosition(visibleSize_width - 200,visibleSize_height/4)
    meta.mainLayer:addChild(menu,100)
    
end
--update压力测试
function meta:UpdatePressureTest()
    --*********************SpriteBatchNode*********************
    if meta.render_type == 1 then

        local bk = cc.Sprite:createWithSpriteFrameName("bingkuai.png")
        local x = visibleSize_width
        local y = Rand:randnum(0,visibleSize_height)
        bk:setPosition(x,y)
        meta.batch_a:addChild(bk)

        local function reset1()--完成动作后释放
            bk:removeFromParent(true)
        end
        local func = cc.CallFunc:create(reset1)
        local move = cc.MoveTo:create(3,cc.p(-bk:getContentSize().width,y))
        local seq  = cc.Sequence:create(move,func)
        bk:runAction(seq)

        --------------------

        local st = cc.Sprite:createWithSpriteFrameName("shitou.png")
        x = visibleSize_width
        y = Rand:randnum(0,visibleSize_height)
        st:setPosition(x,y)
        meta.batch_b:addChild(st)
        

        local function reset2()--完成动作后释放
            st:removeFromParent(true)
        end
        local func2 = cc.CallFunc:create(reset2)
        local move2 = cc.MoveTo:create(3,cc.p(-st:getContentSize().width,y))
        local seq2  = cc.Sequence:create(move2,func2)
        st:runAction(seq2)
    
    --*********************Auto-batching*********************
    elseif meta.render_type == 2 then

        local bk = cc.Sprite:createWithSpriteFrameName("bingkuai.png")
        local x = visibleSize_width
        local y = Rand:randnum(0,visibleSize_height)
        bk:setPosition(x,y)
        meta.mainLayer:addChild(bk,1)
        --bk:runAction(cc.MoveTo:create(5,cc.p(-100,y)))
        
        local function reset1()--完成动作后释放
            bk:removeFromParent(true)
        end
        local func = cc.CallFunc:create(reset1)
        local move = cc.MoveTo:create(3,cc.p(-bk:getContentSize().width,y))
        local seq  = cc.Sequence:create(move,func)
        bk:runAction(seq)

        --------------------

        local st = cc.Sprite:createWithSpriteFrameName("shitou.png")
        x = visibleSize_width
        y = Rand:randnum(0,visibleSize_height)
        st:setPosition(x,y)
        meta.mainLayer:addChild(st,2)
        --st:runAction(cc.MoveTo:create(5,cc.p(-100,y)))

        local function reset2()--完成动作后释放
            st:removeFromParent(true)
        end
        local func2 = cc.CallFunc:create(reset2)
        local move2 = cc.MoveTo:create(3,cc.p(-st:getContentSize().width,y))
        local seq2  = cc.Sequence:create(move2,func2)
        st:runAction(seq2)
    end
    
end
---------------------------SpriteBatchNode---------------------------
function meta:TestSpriteBatchNode(node_sum)
    --local rand = require "src/tool/rand.lua"
    
    local batch1 = cc.SpriteBatchNode:create("bingkuai.png")
    meta.mainLayer:addChild(batch1)

    local batch2 = cc.SpriteBatchNode:create("shitou.png")
    meta.mainLayer:addChild(batch2)

    for i=1,node_sum do
        local bk = cc.Sprite:createWithSpriteFrameName("bingkuai.png")
        local x = visibleSize_width + visibleSize_width/10*i--rand:randnum(0,visibleSize_height)--visibleSize_width + visibleSize_width/10*i
        local y = Rand:randnum(0,visibleSize_height)
        bk:setPosition(x,y)
        batch1:addChild(bk)

        local function reset1()--完成动作后重置
            bk:setPosition(x,y)
        end
        local func = cc.CallFunc:create(reset1)
        local move = cc.MoveTo:create(5*i/2,cc.p(-100,y))
        local seq  = cc.Sequence:create(move,func)
        bk:runAction(cc.RepeatForever:create(seq))

        ---------------

        local st = cc.Sprite:createWithSpriteFrameName("shitou.png")
        x = visibleSize_width + visibleSize_width/10*i--rand:randnum(0,visibleSize_height)--visibleSize_width + visibleSize_width/10*i
        y = Rand:randnum(0,visibleSize_height)
        st:setPosition(x,y)
        batch2:addChild(st)
        

        local function reset2()--完成动作后重置
            st:setPosition(x,y)
        end
        local func2 = cc.CallFunc:create(reset2)
        local move2 = cc.MoveTo:create(5*i/2,cc.p(-100,y))
        local seq2  = cc.Sequence:create(move2,func2)
        st:runAction(cc.RepeatForever:create(seq2))


    end

    --for i=1,1000 do
    --    local st = cc.Sprite:createWithSpriteFrameName("shitou.png")
    --    local x = Rand:randnum(0,visibleSize_height)--visibleSize_width + visibleSize_width/10*i
    --    local y = Rand:randnum(0,visibleSize_height)
    --    st:setPosition(x,y)
    --    batch2:addChild(st)
    --end
end
---------------------------Auto-batching---------------------------
function meta:AutoBatching(node_sum)
    --Auto-culling的支持，Sprite在绘制时会进行检查，超出屏幕的不会发给渲染
    --出了屏幕不再渲染
    --local rand = require "src/tool/rand.lua"
    --rand:init()

    for i=1,node_sum do
        
        local bk = cc.Sprite:createWithSpriteFrameName("bingkuai.png")
        local x = visibleSize_width + visibleSize_width/10*i
        local y = Rand:randnum(0,visibleSize_height)
        bk:setPosition(x,y)
        meta.mainLayer:addChild(bk,1)
        --bk:runAction(cc.MoveTo:create(5,cc.p(-100,y)))
        
        local function reset1()--完成动作后重置
            bk:setPosition(x,y)
        end
        local func = cc.CallFunc:create(reset1)
        local move = cc.MoveTo:create(5*i/2,cc.p(-100,y))
        local seq  = cc.Sequence:create(move,func)
        bk:runAction(cc.RepeatForever:create(seq))

        --------------------

        local st = cc.Sprite:createWithSpriteFrameName("shitou.png")
        x = visibleSize_width + visibleSize_width/10*i
        y = Rand:randnum(0,visibleSize_height)
        st:setPosition(x,y)
        meta.mainLayer:addChild(st,2)
        --st:runAction(cc.MoveTo:create(5,cc.p(-100,y)))

        local function reset2()--完成动作后重置
            st:setPosition(x,y)
        end
        local func2 = cc.CallFunc:create(reset2)
        local move2 = cc.MoveTo:create(5*i/2,cc.p(-100,y))
        local seq2  = cc.Sequence:create(move2,func2)
        st:runAction(cc.RepeatForever:create(seq2))

    end
    --for i=1,2000 do
    --    local st = cc.Sprite:createWithSpriteFrameName("shitou.png")
    --    local x = Rand:randnum(0,visibleSize_height)
    --    local y = Rand:randnum(0,visibleSize_height)
    --    st:setPosition(x,y)
    --    meta.mainLayer:addChild(st)
    --    --st:runAction(cc.MoveTo:create(5,cc.p(-100,y)))
    --end    
end
--ReleaseAll
function meta:ReleaseAll()
    meta.mainLayer:removeAllChildren(true)
    meta:pressureTest()
    meta.render_type = 0
end
--******************************************************************************************************************************
--******************************************************************************************************************************
--******************************************************************************************************************************


--////////////////////////////////测试专用////////////////////////////////
--画线矩形
function meta:DrawRect(glNode,rect_x,rect_y,rect_w,rect_h)--左下角为原点 往右x增 往上y增
    
    local function primitivesDraw(transform, transformUpdated)
            cc.DrawPrimitives.drawLine(cc.p(rect_x,rect_y+rect_h),cc.p(rect_x+rect_w,rect_y+rect_h))--上
            cc.DrawPrimitives.drawLine(cc.p(rect_x,rect_y),cc.p(rect_x+rect_w,rect_y))--下
            cc.DrawPrimitives.drawLine(cc.p(rect_x,rect_y),cc.p(rect_x,rect_y+rect_h))--左
            cc.DrawPrimitives.drawLine(cc.p(rect_x+rect_w,rect_y),cc.p(rect_x+rect_w,rect_y+rect_h))--右
            gl.lineWidth( 1.0 )
            cc.DrawPrimitives.drawColor4B(255,0,0,255)
    end
    glNode:registerScriptDrawHandler(primitivesDraw)
    
end


--地图编辑演示用到
function meta:EditMenuUI()
    
    local test_tag = 9999--测试专用tag

    --文字显示
    meta.font_label = cc.LabelTTF:create("循环中","宋体",30)
    meta.font_label:setPosition(visibleSize_width/3,visibleSize_height*5/6)
    meta.mainLayer:addChild(meta.font_label,test_tag)

    
    --游戏时间文字显示
    meta.game_time = 0
    meta.game_time_label = cc.LabelTTF:create("时间: 0 ","宋体",30)
    meta.game_time_label:setColor(cc.c3b(255,0,0))
    meta.game_time_label:setPosition(visibleSize_width/3,visibleSize_height*4/5-20)
    meta.mainLayer:addChild(meta.game_time_label,test_tag)

    --游戏速度文字显示
    GameModel:SetGlobalSpeed(0)
    meta.game_speed_label = cc.LabelTTF:create("速度: 0 ","宋体",30)
    meta.game_speed_label:setColor(cc.c3b(255,0,0))
    meta.game_speed_label:setPosition(visibleSize_width/3,visibleSize_height*3/4-50)
    meta.mainLayer:addChild(meta.game_speed_label,test_tag)
    
    meta.isRepeat = true
    GameModel:SetIsRepeat(meta.isRepeat)
    local function IsRepeat()--是否循环
        meta.isRepeat = not meta.isRepeat
        GameModel:SetIsRepeat(meta.isRepeat)
        
        if meta.isRepeat then
           meta.font_label:setString("循环中")
        else
            meta.font_label:setString("不循环")
        end
        
    end


    local function AddSpeed()--加速
        GameModel.global_speed = GameModel.global_speed + 1
        cclog("GameModel.global_speed = " ..GameModel.global_speed)
    end
    local function ReduceSpeed()--减速
        GameModel.global_speed = GameModel.global_speed - 1
        cclog("GameModel.global_speed = " ..GameModel.global_speed)
    end
    local function EditRelease()--重来
        GameModel.is_release = true
        meta.mainLayer:removeAllChildren()
        meta.mainLayer:getParent():removeAllChildren()
        --初始化数据
        meta.map_layer_list = {}
        GameModel:setBackground(GameModel.section)
        local changeScene = require "src/GameScene/GameScene"
        if cc.Director:getInstance():getRunningScene() then         
            cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,changeScene:init()))--replaceScene此函数自动释放场景
	    else
		    cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,changeScene:init()))
	    end

        meta.map_layer_list = {}
        --初始化索引
        GameModel.map_data_list = {}
        GameModel:SetCurMapId(1)--层索引
        GameModel:SetCurMotId(1)--层怪物索引
        GameModel:SetLayerIndex(1)--层列表索引
        GameModel:SetCreateRange(visibleSize_width)--创建范围
        meta:init()
    end

    --重来
    local EditRelease_btn = cc.MenuItemFont:create("EditRelease")
    EditRelease_btn:registerScriptTapHandler(EditRelease)
    EditRelease_btn:setPositionY(100)

    ----循环
    --local Is_Repeat_btn = cc.MenuItemFont:create("IsRepeat")
    --Is_Repeat_btn:registerScriptTapHandler(IsRepeat)
    --Is_Repeat_btn:setPositionY(100)

    --减速
    local ReduceSpeed_btn = cc.MenuItemFont:create("ReduceSpeed")
    ReduceSpeed_btn:registerScriptTapHandler(ReduceSpeed)
    ReduceSpeed_btn:setPositionY(200)

    --增加
    local AddSpeed_btn = cc.MenuItemFont:create("AddSpeed")
    AddSpeed_btn:registerScriptTapHandler(AddSpeed)
    AddSpeed_btn:setPositionY(300)

    --菜单
    local menu = cc.Menu:create(AddSpeed_btn,ReduceSpeed_btn,EditRelease_btn)
     menu:setPosition(visibleSize_width - 200,visibleSize_height/3)
    meta.mainLayer:addChild(menu,test_tag)

end
--计算游戏时长
function meta:GameTime()
    
    if meta.game_time_label then
        
        --取最后一个层坐标+层宽度把总长度求出来（循环的情况时间会变）
        local last_layer = #meta.map_layer_list
        if last_layer ~= 0 then
            local layer_sum = meta.map_layer_list[last_layer]:getPositionX() + meta.map_layer_list[last_layer]:getContentSize().width
            
            --计算时长
            meta.game_time = layer_sum/60--每秒60帧
            local str = string.format("时间 : %d",meta.game_time)
            meta.game_time_label:setString(str)
        end
        
    end
end
--当前全局游戏速度
function meta:GameSpeed()
    if meta.game_speed_label then
        local str = string.format("游戏速度 : %d",GameModel.global_speed)
        meta.game_speed_label:setString(str)
        
    end
end



return GameView