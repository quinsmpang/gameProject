--新手引导剧情
local leader2 = 
{
    speak_1     = 368;
    is_speak_1  = false;--是否已经出发过
    speak_1_txt = "完成新手关卡，可获得丰厚奖励哦！";

    speak_2     = 500;
    is_speak_2  = false;--是否已经出发过
    speak_2_txt = "奔跑中会持续掉血,可以通过拾取血瓶恢复.";

    speak_3     = 600;
    is_speak_3  = false;--是否已经出发过


    jump_1     = 30;--避开钉子
    is_jump_1  = false;--是否已经出发过
    jump_1_txt = "遇到障碍，点屏幕右下方按钮进行跳跃！";

    jump_2     = 60;--避开子弹
    is_jump_2  = false;--是否已经出发过
    jump_2_txt = "棒棒的，前方有飞弹，小心！";

    jump_3     = 62;--前面有坑 1跳
    is_jump_3  = false;--是否已经出发过
    jump_3_txt = "前面有个大坑，要二连跳哦！";

    jump_4     = 77;--前面有坑 2跳
    is_jump_4  = false;--是否已经出发过
    jump_4_txt = "再跳！       ";

    --jump_5     = 445;
    --is_jump_5  = false;--是否已经出发过
    --jump_5_txt = "奔跑中会持续掉血，\n可以通过拾取血瓶恢复.";


    atk_1      = 88;
    is_atk_1   = false;--是否已经出发过
    atk_1_txt = "遇到怪物,点屏幕左下方按钮攻击！";

    spurt_1    = 100;
    is_spurt_1 = false;--是否已经出发过
    spurt_1_txt = "每个英雄有专属大招,点右上方按钮可以释放！";

    boss_1     = 375;
    is_boss_1  = false;--是否已经出发过
    boss_1_txt = "进入BOSS模式,击杀可获得丰富奖励！";

    is_leader_exit = false;--退出战斗引导
    ExitLeader_txt = "勇士,合作愉快,期待和您再次合作，再见.";

    is_btn  = false;--是否按下有效
    
    is_boss  = false;--boss模式
    is_speak = false;--旁白
    is_jump  = false;--要求按下跳跃
    is_atk   = false;--要求按下攻击
    is_spurt = false;--要求按下冲刺

    leader_ahri_path    = "xinshouyindao_ali.png";
    leader_jiantou_path = "xinshouyindao_jiantou.png";
    leader_frame_path    = "xinshouyindao_dikuang.png";

    leader_ahri     = nil;
    leader_jiantou  = nil;
    leader_frame    = nil;
    leader_label    = nil;
    ahri_label      = nil;

    --引导场景步骤
    leader_step = 
    {
        "res/ui/leader/publish/map_1.csb",
        "res/ui/leader/publish/map_2.csb",
        "res/ui/leader/publish/map_3.csb",
        "res/ui/leader/publish/map_4.csb",
        "res/ui/leader/publish/map_5.csb",
        "res/ui/leader/publish/map_6.csb",
        "res/ui/leader/publish/map_7.csb",
        "res/ui/leader/publish/boss_1.csb",
        "res/ui/leader/publish/boss_2.csb"
    };
    leader_objList = {};--引导对象列表
    leader_index   = 1;--地图引导id
    --leader_node  = nil;--引导节点

    leader_type    = true;--true新引导 false原引导

}



local meta = leader2
meta.__index = meta--表设定为自身
----引用和全局，初始化----------------------------------------------------------------------------------
local GameSceneButton = require "src/GameScene/GameSceneButton"
local GameModel = require "src/GameScene/GameM"

local visibleSize_width = g_visibleSize.width
local visibleSize_height = g_visibleSize.height

--初始化阿狸教程框
function meta:initLeader()
    
    --单独测试开启
    --cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/leader/fightleader.plist", "res/ui/leader/fightleader.pvr.ccz")

    --local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_login.ExportJson")
    
    local leader_node = nil
    if meta.leader_type then
        ---[[新引导
        leader_node   = cc.Node:create()
        leader_node:setAnchorPoint(0,0)
        for i=1,#meta.leader_step do
            local node = cc.Node:create()
            node:setAnchorPoint(0,0)
            local obj = ccs.SceneReader:getInstance():createNodeWithSceneFile(meta.leader_step[i])
            if i <= 5 then
                --屏蔽框1
                local com_data = obj:getChildByTag(20001)
                local sprite = com_data:getComponent(LEADER_COMPONENT.CCSprite):getNode()
                sprite:setAnchorPoint(0,0)
                local new_rect = ScaleToRect(com_data:getScaleX(),com_data:getScaleX(),cc.rect(com_data:getPositionX(),com_data:getPositionY(),sprite:getContentSize().width,sprite:getContentSize().height))
                node:addChild(createClippingBoard(new_rect,cc.c4b(0,0,0,155)),1)
                node:addChild(obj,2)--放在黑白透明层上面
            else
                --屏蔽框2
                local com_data = obj:getChildByTag(10001)
                local armature = com_data:getComponent(LEADER_COMPONENT.CCArmature):getNode()
                armature:setAnchorPoint(0,0)
                local frame = armature:getBone("Layer2"):getDisplayRenderNode():getBoundingBox()
                local frame_pos = armature:getBone("Layer2"):getDisplayRenderNode():convertToWorldSpace(cc.p(0,0))
                node:addChild(createClippingBoard(cc.rect(frame_pos.x,frame_pos.y,frame.width,frame.height),cc.c4b(0,0,0,155)),1)
                node:addChild(obj,2)--放在黑白透明层上面
            end
            leader_node:addChild(node)
            table.insert(meta.leader_objList,node)
            node:setVisible(false)
            
            --node:getChildByTag(1)
        end
    
    --    lay:addChild(createClippingBoard(cc.rect(50,30,100,100),cc.c4b(0,0,0,100)))

        --]]
    else
        ---[[原引导
        meta.leader_ahri    = cc.Sprite:createWithSpriteFrameName(meta.leader_ahri_path)
        meta.leader_jiantou = cc.Sprite:createWithSpriteFrameName(meta.leader_jiantou_path)
        meta.leader_frame   = cc.Scale9Sprite:createWithSpriteFrameName(meta.leader_frame_path)
    
        meta.leader_ahri:setAnchorPoint(0,0)
        meta.leader_jiantou:setAnchorPoint(0,0)
        meta.leader_frame:setAnchorPoint(0,0)

        meta.leader_ahri:setPosition(visibleSize_width - meta.leader_ahri:getContentSize().width,0)
        meta.leader_frame:setPosition(visibleSize_width - meta.leader_frame:getContentSize().width,0)
        meta.leader_jiantou:setPosition(meta.leader_ahri:getPositionX() - meta.leader_jiantou:getContentSize().width,meta.leader_frame:getContentSize().height/3)

        meta.leader_label = cc.LabelTTF:create("","微软雅黑",24)
        meta.leader_label:setAnchorPoint(0,0)
        meta.leader_label:setPosition(meta.leader_frame:getPositionX()+100,meta.leader_frame:getContentSize().height/2)

        leader_node   = cc.Node:create()
        leader_node:setAnchorPoint(0,0)
    
        leader_node:addChild(meta.leader_frame)
        leader_node:addChild(meta.leader_ahri)
        leader_node:addChild(meta.leader_jiantou)
        leader_node:addChild(meta.leader_label)
        --]]

    end
   
    
    return leader_node
end

--创建引导层
function meta:createLeaderFrame()
    local node = cc.Node:create()
    node:setAnchorPoint(0,0)
    local obj = ccs.SceneReader:getInstance():createNodeWithSceneFile(meta.leader_step[meta.leader_index])
    if meta.leader_index <= 5 then
        --屏蔽框1
        local com_data = obj:getChildByTag(20001)
        local sprite = com_data:getComponent(LEADER_COMPONENT.CCSprite):getNode()
        sprite:setAnchorPoint(0,0)
        local new_rect = ScaleToRect(com_data:getScaleX(),com_data:getScaleX(),cc.rect(com_data:getPositionX(),com_data:getPositionY(),sprite:getContentSize().width,sprite:getContentSize().height))
        node:addChild(createClippingBoard(new_rect,cc.c4b(0,0,0,155)),1)
        node:addChild(obj,2)--放在黑白透明层上面
    else
        --屏蔽框2
        local com_data = obj:getChildByTag(10001)
        local armature = com_data:getComponent(LEADER_COMPONENT.CCArmature):getNode()
        --armature:setAnchorPoint(0,0)
        
        --帧事件回调
	    local function FrameEvent( bone, evt, originFrameIndex, currentFrameIndex )
            if evt then
                armature:getAnimation():gotoAndPlay(tonumber(evt))
            end
        end
        armature:getAnimation():setFrameEventCallFunc(FrameEvent)--注册帧事件
        node:addChild(createClippingBoard(cc.rect(0,0,visibleSize_width,visibleSize_height),cc.c4b(0,0,0,155),false))
        node:addChild(obj,2)--放在黑白透明层上面
    end

    return node
end


--设置教程文字
function meta:setLeaderString(str,dir)--false:右 true:左
    dir = dir or false
    if not dir then
        --右边
        meta.leader_label:setString(str)
        meta.leader_ahri:setPosition(visibleSize_width - meta.leader_ahri:getContentSize().width,0)
        meta.leader_ahri:setRotationSkewY(0)
        meta.leader_frame:setPosition(visibleSize_width - meta.leader_ahri:getContentSize().width - meta.leader_frame:getContentSize().width,0)
        meta.leader_label:setPositionX(meta.leader_frame:getPositionX())
        meta.leader_jiantou:setPosition(meta.leader_ahri:getPositionX() - meta.leader_jiantou:getContentSize().width,meta.leader_frame:getContentSize().height/3)
    else
        --左边
        meta.leader_label:setString(str)
        meta.leader_ahri:setPosition(meta.leader_ahri:getContentSize().width,0)
        meta.leader_ahri:setRotationSkewY(180)
        meta.leader_frame:setPosition(meta.leader_frame:getContentSize().width,0)
        meta.leader_label:setPositionX(meta.leader_frame:getContentSize().width - meta.leader_label:getContentSize().width)
        meta.leader_jiantou:setPosition(meta.leader_frame:getContentSize().width,meta.leader_frame:getContentSize().height/3)
    end
    
end
--退出战斗教程
function meta:ExitLeader()
    if meta.leader_type then

    else
        ---[[原引导
        --cclog("退出战斗教程")
        meta:setLeaderString(meta.ExitLeader_txt)
        GameSceneButton.black_layer:setVisible(true)
        meta.leader_frame:setPositionX(meta.leader_ahri:getContentSize().width)
        meta.leader_label:setPositionX(meta.leader_ahri:getContentSize().width+52)
        meta.leader_jiantou:setPositionX(meta.leader_frame:getPositionX()+486)
        --]]
    end
    
end
----------------------------------------
--检查新手引导
function meta:checkLeader(metre)
    if meta.leader_type then
        ---[[新引导
        --检查是否需要按冲刺
        if meta:checkLeaderSpurt(metre) then
            meta.is_spurt = true
            g_isPause = true--暂停
            GameSceneButton.black_layer:addChild(meta:createLeaderFrame())
            GameSceneButton:setSpurtVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --检查是否需要按攻击
        elseif meta:checkLeaderAtk(metre) then
            meta.is_atk = true
            g_isPause = true--暂停
            GameSceneButton.black_layer:addChild(meta:createLeaderFrame())
            GameSceneButton:setAtkVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --检查是否需要按跳跃
        elseif meta:checkLeaderJump(metre) then
            meta.is_jump = true
            g_isPause = true--暂停
            GameSceneButton.black_layer:addChild(meta:createLeaderFrame())
            GameSceneButton:setJumpVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --检查旁白
        elseif meta:checkSpeaking(metre) then
            meta.is_speak = true
            meta.is_atk   = false--攻击
            meta.is_spurt = false--冲刺
            meta.is_jump  = false--跳跃
            g_isPause = true--暂停
            GameSceneButton.black_layer:addChild(meta:createLeaderFrame())
            GameSceneButton.black_layer:setVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --检查boss
        elseif meta:checkBossLeader(metre) then
            meta.is_boss = true--boss
            g_isPause = true--暂停
            --GameSceneButton.black_layer:addChild(meta:createLeaderFrame())
            GameSceneButton.black_layer:addChild(meta:createLeaderFrame())
            GameSceneButton.black_layer:setVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --退出战斗引导
        elseif GameModel.is_exit then
            GameModel.is_exit = false
            g_isPause = true--暂停
            GameModel:NextLeader()--直接退出
            return
        end
        --]]
    else
         ----------------------------------------------------------------------------------------
        --[[boss部分
        if meta:checkBossLeader(metre) then
            meta.is_btn = true
            meta.is_boss = true
            g_isPause = true--暂停
            GameSceneButton:setLeaderVisible(false)
            GameSceneButton.black_layer:setVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --退出战斗引导
        elseif GameModel.is_exit then
            GameModel.is_exit = false
            meta.is_btn = true
            g_isPause = true--暂停
            --开始退出释放界面
            --退出战斗教程
            meta:ExitLeader()
            meta.is_leader_exit = true
            GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.wait)
        end
        --]]


        ---[[原引导
        --检查是否需要按冲刺
        if meta:checkLeaderSpurt(metre) then
            meta.is_btn = true
            meta.is_spurt = true
            g_isPause = true--暂停
            GameSceneButton:setSpurtVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --检查是否需要按攻击
        elseif meta:checkLeaderAtk(metre) then
            meta.is_btn = true
            meta.is_atk = true
            g_isPause = true--暂停
            GameSceneButton:setAtkVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --检查是否需要按跳跃
        elseif meta:checkLeaderJump(metre) then
            meta.is_btn = true
            meta.is_jump = true
            g_isPause = true--暂停
            GameSceneButton:setJumpVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
         --检查旁白
        elseif meta:checkSpeaking(metre) then
            meta.is_btn = true
            meta.is_speak = true
            g_isPause = true--暂停
            GameSceneButton:setLeaderVisible(false)
            GameSceneButton.black_layer:setVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --检查boss
        elseif meta:checkBossLeader(metre) then
            meta.is_btn = true
            meta.is_boss  = true--boss
            g_isPause = true--暂停
            GameSceneButton:setLeaderVisible(false)
            GameSceneButton.black_layer:setVisible(true)
            GameModel.Handler:getRole():GetAni():pause()
        --退出战斗引导
        elseif GameModel.is_exit then
            GameModel.is_exit = false
            meta.is_btn = true
            g_isPause = true--暂停
            --开始退出释放界面
            --退出战斗教程
            meta:ExitLeader()
            meta.is_leader_exit = true
            GameModel.Handler:getRole():GetAni():getAnimation():play(ANIMATION_ENUM.wait)
        end
        --]]

    end
   
   
end
--旁白
function meta:checkSpeaking(metre)
    if meta.leader_type then
        ---[[新引导
        if not meta.is_speak_3 and metre >= meta.speak_3 then
            meta.is_speak_3 = true
            meta.leader_index = meta.leader_index + 1
            GameModel.js:pause()--剑圣
            GameModel.is_run_light = true--开启光圈
            return true
        elseif not meta.is_speak_2 and metre >= meta.speak_2 then
            meta.is_speak_2 = true
            meta.leader_index = meta.leader_index + 1
            GameModel.Boss_Handler:GetAni():pause()
            GameModel.is_js = true
            return true
        elseif not meta.is_speak_1 and metre >= meta.speak_1 then
            meta.is_speak_1 = true
            meta.leader_index = meta.leader_index + 1
            return true
        end
        --]]
    else
        ---[[原引导
        --if not meta.is_speak_2 and metre >= meta.speak_2 then
        --    meta.is_speak_2 = true
        --    meta:setLeaderString(meta.speak_2_txt)
        --    meta.leader_frame:setPositionX(meta.leader_ahri:getContentSize().width)
        --    meta.leader_label:setPositionX(meta.leader_ahri:getContentSize().width+20)
        --    meta.leader_jiantou:setPositionX(meta.leader_frame:getPositionX()+486)
        --    GameModel.Handler:getRole():setDynamicHp()--生成血瓶   
        --    return true
        --else
        if not meta.is_speak_1 and metre >= meta.speak_1 then--完成新手关卡，可获得丰厚奖励哦！
            meta.is_speak_1 = true
            meta:setLeaderString(meta.speak_1_txt)
            meta.leader_label:setPosition(meta.leader_label:getPositionX() + 70,meta.leader_label:getPositionY() -20)
            meta.leader_jiantou:setPositionX(meta.leader_label:getPositionX() + 70 + 338)
            return true
        end
        --]]

    end
    
    return false
end
--检查是否进入boss模式
function meta:checkBossLeader(metre)
    
    

    if meta.leader_type then
        ---[[新引导
        if not meta.is_boss_1 and metre >= meta.boss_1 then
            meta.is_boss_1 = true
             meta.leader_index = meta.leader_index + 1
            return true
        end
        --]]
    else
        ---[[原引导
        if not meta.is_boss_1 and metre >= meta.boss_1 then
            meta.is_boss_1 = true
            meta:setLeaderString(meta.boss_1_txt)
            meta.leader_frame:setPositionX(meta.leader_ahri:getContentSize().width)
            meta.leader_label:setPositionX(meta.leader_ahri:getContentSize().width+72)
            meta.leader_jiantou:setPositionX(meta.leader_frame:getPositionX()+486)
            return true
        end
        --]]
    end

    
    return false
end
--检查是否需要按跳跃
function meta:checkLeaderJump(metre)
    
    if meta.leader_type then
        ---[[
        if not meta.is_jump_3 and metre >= meta.jump_3 then--再按一次！
            meta.is_jump_3 = true
            meta.leader_index = meta.leader_index + 1
            return true
        elseif not meta.is_jump_2 and metre >= meta.jump_2 then--前面有个大坑，要二连跳哦！
            meta.is_jump_2 = true
            meta.leader_index = meta.leader_index + 1
            return true
        elseif not meta.is_jump_1 and metre >= meta.jump_1 then--遇到障碍，点屏幕右下方按钮进行跳跃！
            meta.is_jump_1 = true
            meta.leader_index = 1
            return true
        end
        --]]
    else
        ---[[原引导
        --if not meta.is_jump_5 and metre >= meta.jump_5 then
        --    meta.is_jump_5 = true
        --    meta:setLeaderString(meta.jump_5_txt,true)
        --    GameModel.Handler:getRole():setDynamicHp()--生成血瓶 
        --    return true
        --else

        --if not meta.is_jump_4 and metre >= meta.jump_4 then
        --    meta.is_jump_4 = true
        --    meta:setLeaderString(meta.jump_4_txt,true)
        --    meta.leader_frame:setPositionX(meta.leader_ahri:getContentSize().width)
        --    meta.leader_label:setPositionX(meta.leader_frame:getPositionX()+220)
        --    meta.leader_jiantou:setPositionX(meta.leader_frame:getPositionX()+486)
        --    return true
        --else
        if not meta.is_jump_3 and metre >= meta.jump_3 then
            meta.is_jump_3 = true
            meta:setLeaderString(meta.jump_3_txt,true)
            meta.leader_frame:setPositionX(meta.leader_ahri:getContentSize().width)
            meta.leader_label:setPositionX(meta.leader_ahri:getContentSize().width+122)
            meta.leader_jiantou:setPositionX(meta.leader_frame:getPositionX() + 486)
            return true
        elseif not meta.is_jump_2 and metre >= meta.jump_2 then--棒棒的，前方有飞弹，小心！
            meta.is_jump_2 = true
            meta:setLeaderString(meta.jump_2_txt,true)
            meta.leader_frame:setPositionX(meta.leader_ahri:getContentSize().width)
            meta.leader_label:setPositionX(meta.leader_ahri:getContentSize().width+132)
            meta.leader_jiantou:setPositionX(meta.leader_label:getContentSize().width + 290 + 110)
            return true
        elseif not meta.is_jump_1 and metre >= meta.jump_1 then--遇到障碍，点屏幕右下方按钮进行跳跃！
            --cclog("要求按下跳跃")
            meta.is_jump_1 = true
            meta:setLeaderString(meta.jump_1_txt,true)
            meta.leader_frame:setPositionX(meta.leader_ahri:getContentSize().width)
            meta.leader_label:setPositionX(meta.leader_ahri:getContentSize().width+65)
            meta.leader_jiantou:setPositionX(meta.leader_label:getContentSize().width + 290)
            return true
        end
        --]]
    end

    

    

    return false
end
--检查是否需要按攻击
function meta:checkLeaderAtk(metre)
    
    if meta.leader_type then
         ---[[
        if not meta.is_atk_1 and metre >= meta.atk_1 then
            meta.is_atk_1 = true
            meta.leader_index = meta.leader_index + 1
            return true
        end
        --]]
    else
        ---[[原引导
        if not meta.is_atk_1 and metre >= meta.atk_1 then
            meta.is_atk_1 = true
            meta:setLeaderString(meta.atk_1_txt)
            meta.leader_frame:setPositionX(meta.leader_ahri:getContentSize().width)
            meta.leader_label:setPositionX(meta.leader_ahri:getContentSize().width+72)
            meta.leader_jiantou:setPositionX(meta.leader_frame:getPositionX()+486)
            GameSceneButton.jump:setVisible(false)
            GameSceneButton.jump_label:setVisible(false)
            return true
        end
        --]]
    end

   


    
    return false
end
--检查是否需要按冲刺
function meta:checkLeaderSpurt(metre)
    
    if meta.leader_type then
        ---[[新引导
        if not meta.is_spurt_1 and metre >= meta.spurt_1 then
            meta.is_spurt_1 = true
            meta.leader_index = meta.leader_index + 1
            return true
        end
        --]]
    else
        ---[[原引导
        if not meta.is_spurt_1 and metre >= meta.spurt_1 then
            meta.is_spurt_1 = true
            meta:setLeaderString(meta.spurt_1_txt)
            meta.leader_frame:setPositionX(meta.leader_ahri:getContentSize().width)
            meta.leader_label:setPositionX(meta.leader_ahri:getContentSize().width+10)
            meta.leader_jiantou:setPositionX(meta.leader_frame:getPositionX()+496)
            GameSceneButton.jump:setVisible(false)
            GameSceneButton.jump_label:setVisible(false)
            GameSceneButton.gongji:setVisible(false)
            GameSceneButton.gongji_label:setVisible(false)
            return true
        end
        --]]
    end

    
    
    return false
end
-----------------------------------------
--是否可以按下
function meta:getIsBtn()
    return meta.is_btn
end
--是否可以按下
function meta:setIsBtn(is_btn)
    meta.is_btn = is_btn
end
--是否要求按下跳跃
function meta:getIsJump()
    return meta.is_jump
end
--是否要求按下跳跃
function meta:setIsJump(is_btn)
    meta.is_jump = is_btn
end
--是否要求按下攻击
function meta:getIsAtk()
    return meta.is_atk
end
--是否要求按下攻击
function meta:setIsAtk(is_btn)
    meta.is_atk = is_btn
end
--是否要求按下冲刺
function meta:getIsSpurt()
    return meta.is_spurt
end
--是否要求按下冲刺
function meta:setIsSpurt(is_btn)
    meta.is_spurt = is_btn
end
--获取旁白
function meta:getIsSpeak()
    return meta.is_speak
end
--设置旁白
function meta:setIsSpeak(is_btn)
    meta.is_speak = is_btn
end
--获取boss
function meta:getIsBoss()
    return meta.is_boss
end
--设置boss
function meta:setIsBoss(is_btn)
    meta.is_boss = is_btn
end
--获取退出引导
function meta:getIsLeaderExit()
    return meta.is_leader_exit
end
--设置退出引导
function meta:setIsLeaderExit(is_btn)
    meta.is_leader_exit = is_btn
end

-------------------------------------------------------------

--Leader6 = class(Leader6,function() return cc.Layer:create() end )
--Leader6.__index = Leader6
--Leader6.newLayer = nil
--Leader6.mainLayer = nil

--function Leader6:createLayer()
--    local lay = Leader6:new()
--    self.mailLayer= ccs.SceneReader:getInstance():createNodeWithSceneFile("res/ui/leader/publish/gift_1.json")
--    lay:addChild(createClippingBoard(cc.rect(50,30,100,100),cc.c4b(0,0,0,100)))
--    lay:addChild(self.mailLayer)
--    return lay
--end




return leader2

