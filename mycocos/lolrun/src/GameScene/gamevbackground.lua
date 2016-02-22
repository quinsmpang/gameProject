local GameBackGroundView = 
{
    mainLayer = nil; --本图层
    far_table = {};
    middle_table = {};
    near_table = {};
    floor_table = {};
    animation = nil;
    schedulerID = 0;
    --is_BackgroundPause = false;     --如果想暂停背景，只需要把这个值设成true  -->>移动到GameM

}--@ 游戏逻辑背景层
local  meta = GameBackGroundView

--引用和全局，初始化----------------------------------------------------------------------------------

local GameModel = require "src/GameScene/GameM"
local GameView = require "src/GameScene/GameV"
local Rand = require "src/tool/rand.lua"
local GameRewardM = require "src/GameScene/GameRewardM"

function meta:init( ... )
    meta.mainLayer =  cc.Layer:create()

    --GameModel.near = "01CJYYS02A.png"
    --GameModel.far = "null"
    --GameModel.floor = "01CJJJ.png"
	--meta:createRunScene(GameModel.far,GameModel.middle,GameModel.near,GameModel.floor,GameModel.animation)
   
   --远中景多图创建(主场景远景,中景,奖励远景,奖励中景)
   meta:createRunSceneEx(GameModel.far,GameModel.middle,GameRewardM.far,GameRewardM.middle)
   


    --创建静态背景
    --meta:createBackGround()


    -------------------------------------------------------------
    --测试场景加速 减速 静止
    --meta:TestSpeed()
    -------------------------------------------------------------


    -------------------------------------------------------------
    --测试键  测试全场暂停 begin
    -------------------------------------------------------------
    --[[
    local function menuCallBack(tag, pSender)
        GameModel.is_BackgroundPause = not GameModel.is_BackgroundPause
    end

    local nor    = cc.Scale9Sprite:createWithSpriteFrameName("fanghui_button_01.png")
    local select = cc.Scale9Sprite:createWithSpriteFrameName("fanghui_button_02.png")
    local dis    = cc.Scale9Sprite:createWithSpriteFrameName("dadian_button_02.png")
    local button = cc.MenuItemSprite:create(nor,select,dis)
    --菜单
    local menu = cc.Menu:create(button)
    menu:setPosition(cc.p(600,200))
    meta.mainLayer:addChild(menu,100000,1000000)
    button:registerScriptTapHandler(menuCallBack)
    --]]
    -------------------------------------------------------------
    --测试键  测试全场暂停  end
    -------------------------------------------------------------

    -- -- 监听触摸事件
    -- local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:registerScriptHandler(meta.onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    -- listener:registerScriptHandler(meta.onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    -- listener:registerScriptHandler(meta.onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    -- local eventDispatcher = meta.mainLayer:getEventDispatcher()
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, meta.mainLayer)

    return meta.mainLayer
end



--界面布局----------------------------------------------------------------------------------
--更新背景元素
--local function updateBackGround()
    
    
--end
----创建背景
--function meta:createBackGround()
--    --创建远景
--    if GameModel.back_ground_pic then
--        local far_bg = cc.Sprite:createWithSpriteFrameName(GameModel.back_ground_pic)--此处ani表示精灵
--        far_bg:setAnchorPoint(0,0)
--        far_bg:setPosition(0,0)
--        meta.mainLayer:addChild(far_bg)
--    end
    

--    meta.mainLayer:scheduleUpdateWithPriorityLua(updateBackGround,0)
--end


--旧的场景逻辑
--[[
--场景滚动
local function SceneMoving()

    --暂停
    if g_isPause or g_isInjured then
        return
    end

    --暂停背景
    if GameModel.is_BackgroundPause then
        return
    end

    --远景
    for i=1,#meta.far_table do
            local temp_x = meta.far_table[i]:getPositionX() - GameModel.far_speed - GameModel.global_speed
            if temp_x+meta.far_table[i]:getContentSize().width <= 1 then
                --meta.far_table[i]:setPosition((#meta.far_table-1)*meta.far_table[i]:getContentSize().width-1,GameModel.far_heigth)
                meta.far_table[i]:setPositionX(temp_x + (#meta.far_table)*(meta.far_table[i]:getContentSize().width-1))
            else
                meta.far_table[i]:setPositionX(temp_x)
            end
        end

    --中景    
    for i=1,#meta.middle_table do
        local temp_x = meta.middle_table[i]:getPositionX() - GameModel.middle_speed - GameModel.global_speed
            if temp_x+meta.middle_table[i]:getContentSize().width <= 1 then
                --meta.middle_table[i]:setPosition((#meta.middle_table-1)*meta.middle_table[i]:getContentSize().width-1,GameModel.middle_heigth)
                meta.middle_table[i]:setPositionX(temp_x + (#meta.middle_table)*(meta.middle_table[i]:getContentSize().width-1))
            else
                meta.middle_table[i]:setPositionX(temp_x)
            end
        end

    --近景    
    for i=1,#meta.near_table do
        local temp_x = meta.near_table[i]:getPositionX() - GameModel.near_speed - GameModel.global_speed
            if temp_x+meta.near_table[i]:getContentSize().width <= 1 then
                --meta.near_table[i]:setPosition((#meta.near_table-1)*meta.near_table[i]:getContentSize().width-1,GameModel.near_heigth)
                meta.near_table[i]:setPositionX(temp_x + (#meta.near_table)*(meta.near_table[i]:getContentSize().width))
            else
                meta.near_table[i]:setPositionX(temp_x)
            end
        end

    --地面    
    for i=1,#meta.floor_table do
        local temp_x = meta.floor_table[i]:getPositionX() - GameModel.floor_speed - GameModel.global_speed
            if temp_x+meta.floor_table[i]:getContentSize().width <= 1 then
                --meta.floor_table[i]:setPosition((#meta.floor_table-1)*meta.floor_table[i]:getContentSize().width-1,GameModel.floor_heigth)
                meta.floor_table[i]:setPosition(temp_x + (#meta.floor_table)*(meta.floor_table[i]:getContentSize().width),GameModel.floor_heigth)
            else
                meta.floor_table[i]:setPosition(temp_x,GameModel.floor_heigth)
            end
        end

    --动画
    if GameModel.animation ~= nil then
        local temp_x = meta.animation:getPositionX() - GameModel.animation_speed - GameModel.global_speed
        if temp_x+meta.animation:getContentSize().width <= 0 then
            --meta.animation:setPositionX(g_visibleSize.width+meta.animation:getContentSize().width)
            meta.animation:setPositionX(temp_x + g_visibleSize.width+meta.animation:getContentSize().width)
        else
            meta.animation:setPositionX(temp_x)  
        end
    end
       
end
--]]

--奖励模式创建
function meta:createRewardMap(far_scene_pic,middle_scene_tab)
    
    --远景静态图
    GameRewardM.far_obj = cc.Sprite:createWithSpriteFrameName(far_scene_pic)
    GameRewardM.far_obj:setAnchorPoint(0,0)
    GameRewardM.far_obj:setPosition(0,0)
    GameRewardM.far_obj:setVisible(false)
    meta.mainLayer:addChild(GameRewardM.far_obj,10)
  
    --中景
    if #middle_scene_tab > 0 then
        local map_pic_index = Rand:randnum(1,#middle_scene_tab)

        local middle_scene = cc.Sprite:createWithSpriteFrameName(middle_scene_tab[map_pic_index])
        middle_scene:getTexture():setAliasTexParameters()
        middle_scene:setAnchorPoint(0,0)
        middle_scene:setPosition(0,0)
        middle_scene:setVisible(false)
        table.insert(GameRewardM.middle_obj_tab,middle_scene)
        meta.mainLayer:addChild(middle_scene,10)

        for i=1,#GameRewardM.middle_obj_tab do
            local cur_x = 0
            if i > 1 then
                cur_x = GameRewardM.middle_obj_tab[i-1]:getPositionX()+GameRewardM.middle_obj_tab[i-1]:getContentSize().width
                GameRewardM.middle_obj_tab[i]:setPositionX(cur_x)
            end

            cur_x = GameRewardM.middle_obj_tab[i]:getPositionX()+GameRewardM.middle_obj_tab[i]:getContentSize().width - 1
            if cur_x <= g_visibleSize.width then
                map_pic_index = Rand:randnum(1,#middle_scene_tab)--从路径列表随机拿一张
                middle_scene = cc.Sprite:createWithSpriteFrameName(middle_scene_tab[map_pic_index])
                middle_scene:getTexture():setAliasTexParameters()
                middle_scene:setAnchorPoint(0,0)
                middle_scene:setPositionX(cur_x)
                middle_scene:setVisible(false)
                table.insert(GameRewardM.middle_obj_tab,middle_scene)
                meta.mainLayer:addChild(middle_scene,10)
            end 
            
        end
        
    end

end

--更新奖励地图
function meta:UpdateRewardMap(far_scene_pic,middle_scene_tab)
    
    --游戏准备
    if GameModel:GetGameSetup() == GAME_STEP.game_ready or g_isPause then
        return
    end

    --游戏结束
    if GameModel:GetGameSetup() == GAME_STEP.game_end then
        return
    end

    --暂停
    if g_isPause then
        return
    end

    --是否在奖励模式中
    if GameModel:GetGameSetup() ~= GAME_STEP.game_boss then--GameModel:GetGameSetup() ~= GAME_STEP.game_reward then
        --如果显示就隐藏
        if GameRewardM.far_obj:isVisible() then
            GameRewardM.far_obj:setVisible(false)
            for i=1,#GameRewardM.middle_obj_tab do
                GameRewardM.middle_obj_tab[i]:setVisible(false)
            end
        end
        return
    else
        --如果隐藏就显示
        if not GameRewardM.far_obj:isVisible() then
            GameRewardM.far_obj:setVisible(true)
            for i=1,#GameRewardM.middle_obj_tab do
                GameRewardM.middle_obj_tab[i]:setVisible(true)
            end
        end
    end
    
 

    --暂停背景
    if GameModel.is_BackgroundPause then
        return
    end

    --中景
    local i=1
    while (i<=#GameRewardM.middle_obj_tab) do
        --检查当前地图是否出了屏幕是否需要被释放
        local cur_x = GameRewardM.middle_obj_tab[i]:getPositionX() + GameRewardM.middle_obj_tab[i]:getContentSize().width - 1
        if cur_x <= 0 then
            GameRewardM.middle_obj_tab[i]:removeFromParent(true)
            table.remove(GameRewardM.middle_obj_tab, i)
        else
            --屏幕内的情况
            if i > 1 then
                cur_x = GameRewardM.middle_obj_tab[i-1]:getPositionX()+GameRewardM.middle_obj_tab[i-1]:getContentSize().width
                GameRewardM.middle_obj_tab[i]:setPositionX(cur_x)
            else
                cur_x = GameRewardM.middle_obj_tab[i]:getPositionX() - GameModel.middle_speed - GameModel.global_speed
                GameRewardM.middle_obj_tab[i]:setPositionX(cur_x)
            end
        
            --检查最后一幅图是否覆盖屏幕右边
            if i == #GameRewardM.middle_obj_tab  then
                cur_x = GameRewardM.middle_obj_tab[i]:getPositionX()+GameRewardM.middle_obj_tab[i]:getContentSize().width - 1
                if cur_x <= g_visibleSize.width  then--是否需要接上下一张图
                    local map_pic_index = Rand:randnum(1,#middle_scene_tab)--从路径列表随机拿一张
                    local middle_scene = cc.Sprite:createWithSpriteFrameName(middle_scene_tab[map_pic_index])
                    middle_scene:getTexture():setAliasTexParameters()
                    middle_scene:setAnchorPoint(0,0)
                    middle_scene:setPositionX(cur_x)--紧接着上一张
                    table.insert(GameRewardM.middle_obj_tab,middle_scene)
                    meta.mainLayer:addChild(middle_scene,10)
                end
            end

            i = i + 1
            
        end

    end



end

--更新地图	
function meta:UpdateMap(far_scene_pic,middle_scene_tab)

    --游戏准备
    if GameModel:GetGameSetup() == GAME_STEP.game_ready or g_isPause then
        return
    end

    --游戏结束
    if GameModel:GetGameSetup() == GAME_STEP.game_end then
        return
    end

    --暂停
    if g_isPause then
        return
    end

    --暂停背景
    if GameModel.is_BackgroundPause then
        return
    end
    
    --中景
    local i=1
    while (i<=#GameModel.middle_obj_tab) do
        --检查当前地图是否出了屏幕是否需要被释放
        local cur_x = GameModel.middle_obj_tab[i]:getPositionX() + GameModel.middle_obj_tab[i]:getContentSize().width - 1
        if cur_x <= 0 then
            GameModel.middle_obj_tab[i]:removeFromParent(true)
            table.remove(GameModel.middle_obj_tab, i)
        else
            --屏幕内的情况
            if i > 1 then
                cur_x = GameModel.middle_obj_tab[i-1]:getPositionX()+GameModel.middle_obj_tab[i-1]:getContentSize().width
                GameModel.middle_obj_tab[i]:setPositionX(cur_x)
            else
                cur_x = GameModel.middle_obj_tab[i]:getPositionX() - GameModel.middle_speed - GameModel.global_speed
                GameModel.middle_obj_tab[i]:setPositionX(cur_x)
            end
        
            --检查最后一幅图是否覆盖屏幕右边
            if i == #GameModel.middle_obj_tab  then
                cur_x = GameModel.middle_obj_tab[i]:getPositionX()+GameModel.middle_obj_tab[i]:getContentSize().width - 1
                if cur_x <= g_visibleSize.width  then--是否需要接上下一张图
                    local map_pic_index = Rand:randnum(1,#middle_scene_tab)--从路径列表随机拿一张
                    local middle_scene = cc.Sprite:createWithSpriteFrameName(middle_scene_tab[map_pic_index])
                    middle_scene:getTexture():setAliasTexParameters()
                    middle_scene:setAnchorPoint(0,0)
                    middle_scene:setPositionX(cur_x)--紧接着上一张
                    table.insert(GameModel.middle_obj_tab,middle_scene)
                    meta.mainLayer:addChild(middle_scene)
                end
            end

            i = i + 1
            
        end

    end

end


--远中景多图创建
function meta:createRunSceneEx(far_scene_pic,middle_scene_tab,reward_far_scene_pic,reward_middle_scene_tab)
    
    --远景静态图
    local far_scene = cc.Sprite:createWithSpriteFrameName(far_scene_pic)
    far_scene:setAnchorPoint(0,0)
    far_scene:setPosition(0,0)
    meta.mainLayer:addChild(far_scene)
  
    --中景
    if #middle_scene_tab > 0 then
        local map_pic_index = Rand:randnum(1,#middle_scene_tab)

        local middle_scene = cc.Sprite:createWithSpriteFrameName(middle_scene_tab[map_pic_index])
        middle_scene:getTexture():setAliasTexParameters()
        middle_scene:setAnchorPoint(0,0)
        middle_scene:setPosition(0,0)
        table.insert(GameModel.middle_obj_tab,middle_scene)
        meta.mainLayer:addChild(middle_scene)

        for i=1,#GameModel.middle_obj_tab do
            local cur_x = 0
            if i > 1 then
                cur_x = GameModel.middle_obj_tab[i-1]:getPositionX()+GameModel.middle_obj_tab[i-1]:getContentSize().width
                GameModel.middle_obj_tab[i]:setPositionX(cur_x)
            end

            cur_x = GameModel.middle_obj_tab[i]:getPositionX()+GameModel.middle_obj_tab[i]:getContentSize().width - 1
            if cur_x <= g_visibleSize.width then
                map_pic_index = Rand:randnum(1,#middle_scene_tab)--从路径列表随机拿一张
                middle_scene = cc.Sprite:createWithSpriteFrameName(middle_scene_tab[map_pic_index])
                middle_scene:getTexture():setAliasTexParameters()
                middle_scene:setAnchorPoint(0,0)
                middle_scene:setPositionX(cur_x)
                table.insert(GameModel.middle_obj_tab,middle_scene)
                meta.mainLayer:addChild(middle_scene)
            end 
            
        end
        
    end
    
    --奖励模式创建
    meta:createRewardMap(reward_far_scene_pic,reward_middle_scene_tab)

    local function LaunchUpdateMap()
        meta:UpdateMap(far_scene_pic,middle_scene_tab)
        meta:UpdateRewardMap(reward_far_scene_pic,reward_middle_scene_tab)
    end
    meta.mainLayer:scheduleUpdateWithPriorityLua(LaunchUpdateMap,0)
    
end
--ReleaseAll
function meta:ReleaseAll()
    meta.mainLayer:unscheduleUpdate()
    meta.mainLayer:removeAllChildren(true)
    meta.middle_table = {}
    GameModel.middle_obj_tab   = {}
    GameRewardM.middle_obj_tab = {}
    --[[以下测试用
    --GameModel.back_ground_pic = nil
    --GameModel.middle_speed = 0
    --]]
end
--背景
function meta:createRunScene(far_scene_path,middle_scene_path,near_scene_path,floor_scene_path,animation_scene_path)
    --cclog("g_visibleSize.width = " ..g_visibleSize.width)

	--远景
    if far_scene_path ~= "null" then
        local far_scene1 = cc.Sprite:createWithSpriteFrameName(far_scene_path)
        far_scene1:getTexture():setAliasTexParameters()
        local far_num = g_visibleSize.width % far_scene1:getContentSize().width

        if far_num ~= 0 then
            far_num = g_visibleSize.width/far_scene1:getContentSize().width + 2
        else
            far_num = g_visibleSize.width/far_scene1:getContentSize().width + 1
        end

        local i = 1
        repeat
            if i == 1 then
                far_scene1:setAnchorPoint(cc.p(0, 0))
                far_scene1:setPosition(0,GameModel.far_heigth)
                --far_scene1:setScaleY(g_SizePercentY)
                table.insert(meta.far_table,far_scene1)
                meta.mainLayer:addChild(far_scene1)
            else
                local far_scene = cc.Sprite:createWithSpriteFrameName(far_scene_path)
                far_scene:getTexture():setAliasTexParameters()
                far_scene:setAnchorPoint(cc.p(0, 0))
                far_scene:setPosition((i-1)*far_scene:getContentSize().width-1,GameModel.far_heigth)
                --far_scene1:setScaleY(g_SizePercentY)
                table.insert(meta.far_table,far_scene)
                meta.mainLayer:addChild(far_scene)
            end
            i = i+1
        until (i > far_num)
    end
	
       
    --中景
    if #middle_scene_path ~= "null" then
        local middle_scene1 = cc.Sprite:createWithSpriteFrameName(middle_scene_path)
        middle_scene1:getTexture():setAliasTexParameters()
        local middle_num = g_visibleSize.width % middle_scene1:getContentSize().width
    
        if middle_num ~= 0 then
            middle_num = g_visibleSize.width/middle_scene1:getContentSize().width + 2
        else
            middle_num = g_visibleSize.width/middle_scene1:getContentSize().width + 1
        end

        i = 1
        repeat
            if i == 1 then
                middle_scene1:setAnchorPoint(cc.p(0, 0))
                middle_scene1:setPosition(0,GameModel.middle_heigth)
                --middle_scene1:setScaleY(g_SizePercentY)
                table.insert(meta.middle_table,middle_scene1)
                meta.mainLayer:addChild(middle_scene1)
            else
                local middle_scene = cc.Sprite:createWithSpriteFrameName(middle_scene_path)
                middle_scene:getTexture():setAliasTexParameters()
                middle_scene:setAnchorPoint(cc.p(0, 0))
                middle_scene:setPosition((i-1)*middle_scene:getContentSize().width-1,GameModel.middle_heigth)
                --middle_scene1:setScaleY(g_SizePercentY)
                table.insert(meta.middle_table,middle_scene)
                meta.mainLayer:addChild(middle_scene)
            end
            i = i+1
        until (i > middle_num)
    end

    --地面
    if floor_scene_path ~= "null" then
        local floor_scene1 = cc.Sprite:createWithSpriteFrameName(floor_scene_path)
        floor_scene1:getTexture():setAliasTexParameters()
        local floor_num = g_visibleSize.width % floor_scene1:getContentSize().width
    
        if floor_num ~= 0 then
            floor_num = g_visibleSize.width/floor_scene1:getContentSize().width + 2
        else
            floor_num = g_visibleSize.width/floor_scene1:getContentSize().width + 1
        end

        i = 1
        repeat
            if i == 1 then
                floor_scene1:setAnchorPoint(cc.p(0, 0))
                floor_scene1:setPosition(0,GameModel.floor_heigth)
                --floor_scene1:setScaleY(g_SizePercentY)
                table.insert(meta.floor_table,floor_scene1)
                meta.mainLayer:addChild(floor_scene1)
            else
                local floor_scene1 = cc.Sprite:createWithSpriteFrameName(floor_scene_path)
                floor_scene1:getTexture():setAliasTexParameters()
                floor_scene1:setAnchorPoint(cc.p(0, 0))
                floor_scene1:setPosition((i-1)*floor_scene1:getContentSize().width,GameModel.floor_heigth)
                --floor_scene1:setScaleY(g_SizePercentY)
                table.insert(meta.floor_table,floor_scene1)
                meta.mainLayer:addChild(floor_scene1)
            end
            i = i+1
        until (i > floor_num)
    end
    

     --场景动画
    if animation_scene_path ~= nil then
            --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animation_scene_path)
        meta.animation = ccs.Armature:create(animation_scene_path)
        meta.animation:setAnchorPoint(cc.p(0, 0))
        meta.animation:setPosition(g_visibleSize.width+meta.animation:getContentSize().width,g_visibleSize.height*2/3)
        meta.animation:getAnimation():play(ANIMATION_ENUM.run)
        meta.mainLayer:addChild(meta.animation)
    end
   


    --近景(雾)
    if near_scene_path ~= "null" then
        local near_scene1 = cc.Sprite:createWithSpriteFrameName(near_scene_path)
        near_scene1:getTexture():setAliasTexParameters()
        local near_num = g_visibleSize.width % near_scene1:getContentSize().width
    
        if near_num ~= 0 then
            near_num = g_visibleSize.width/near_scene1:getContentSize().width + 2
        else
            near_num = g_visibleSize.width/near_scene1:getContentSize().width + 1
        end

        i = 1
        repeat
            if i == 1 then
                near_scene1:setAnchorPoint(cc.p(0, 0))
                near_scene1:setPosition(0,GameModel.near_heigth)
                table.insert(meta.near_table,near_scene1)
                meta.mainLayer:addChild(near_scene1)
            else
                local near_scene = cc.Sprite:createWithSpriteFrameName(near_scene_path)
                near_scene:getTexture():setAliasTexParameters()
                near_scene:setAnchorPoint(cc.p(0, 0))
                near_scene:setPosition((i-1)*near_scene:getContentSize().width,GameModel.near_heigth)
                table.insert(meta.near_table,near_scene)
                meta.mainLayer:addChild(near_scene)
            end
            i = i+1
        until (i > near_num)
    end
    



	meta.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(SceneMoving, 0, false)

end

--释放
function meta:release()

    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(meta.schedulerID)--停止定时器
     --清除
     --远景
    while #meta.far_table ~= 0 do
        meta.far_table[1]:removeFromParent(true)
        table.remove(meta.far_table,1)
    end
    --中景
    while #meta.middle_table ~= 0 do
        meta.middle_table[1]:removeFromParent(true)
        table.remove(meta.middle_table,1)
    end
    --近景
    while #meta.near_table ~= 0 do
        meta.near_table[1]:removeFromParent(true)
        table.remove(meta.near_table,1)
    end
    --地面
    while #meta.floor_table ~= 0 do
        meta.floor_table[1]:removeFromParent(true)
        table.remove(meta.floor_table,1)
    end
    --动画
    if meta.animation ~= nil then
        meta.animation:removeFromParent(true)
    end
    

    meta.mainLayer:removeFromParent(true)
end

--界面逻辑回调与相关控制----------------------------------------------------------------------------------

-- local function meta.onTouchBegan(touch, event)
--     return true
-- end
   
-- local function meta.onTouchMoved(touch, event)    

-- end

-- local function meta.onTouchEnded(touch, event)    

-- end


--//////////////////////////////////////////////测试代码////////////////////////////////////////////
function meta:TestSpeed()
    
    local function AddSpeed()--加速
        GameModel.global_speed = GameModel.global_speed + 1
        cclog("GameModel.global_speed = " ..GameModel.global_speed)
    end
    local function ReduceSpeed()--减速
        GameModel.global_speed = GameModel.global_speed - 1
        cclog("GameModel.global_speed = " ..GameModel.global_speed)
    end
    local function stop()--暂停
        g_isPause = true
    end
    local function start()--开始
        g_isPause = false
        

    end
    ----加速
    local AddSpeed_btn = cc.MenuItemFont:create("AddSpeed")
    AddSpeed_btn:registerScriptTapHandler(AddSpeed)
    AddSpeed_btn:setPositionY(0)
    --减速
    local ReduceSpeed_btn = cc.MenuItemFont:create("ReduceSpeed")
    ReduceSpeed_btn:registerScriptTapHandler(ReduceSpeed)
    ReduceSpeed_btn:setPositionY(100)
    --暂停
    local stop_btn = cc.MenuItemFont:create("stop")
    stop_btn:registerScriptTapHandler(stop)
    stop_btn:setPositionY(200)
    --开始
    local start_btn = cc.MenuItemFont:create("start")
    start_btn:registerScriptTapHandler(start)
    start_btn:setPositionY(300)
    --菜单
    local menu = cc.Menu:create(AddSpeed_btn,ReduceSpeed_btn,stop_btn,start_btn)
    menu:setPosition(g_visibleSize.width - 200,g_visibleSize.height/3)
    meta.mainLayer:addChild(menu,100)
end

return GameBackGroundView