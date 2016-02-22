
local GameModel = 
{
    game_model           = nil;--游戏模式(通关模式 无尽模式)
    game_setup           = nil;--游戏状态(开始 结束 奖励模式)
    ----------------------------------------背景层----------------------------------------
    id                   = nil;
    gold                 = nil;
    far                  = nil;
    far_speed            = 0.6;
    far_heigth           = 0;

    middle               = nil;
    middle_speed         = 2;
    middle_heigth        = 0;

    near                 = nil;
    near_speed           = 4;
    near_heigth          = 0;

    floor                = nil;
    floor_speed          = 6;
    floor_heigth         = 0;

    animation            = nil;
    animation_name       = nil;
    animation_speed      = 0;

    role_type            = nil;--角色类型以这个来初始化角色
    section              = "1;1";--章节;关卡

    map_path_table       = {};--地图
    goldMap              = nil;--奖励地图
    
    back_ground_pic      = nil;--远景静止图

    middle_path          = {};--中景路径列表
    middle_obj_tab       = {};--中景对象列表


    ----------------------------------------主逻辑层----------------------------------------
    --刚返回普通模式需要清理奖励模式对象 此变量用于标识是否清理
    is_just_reward       = true;
    
    is_release           = nil;--重来时候防止多次进入定时器
    tag                  = nil;--role_tag
    
    global_speed         = 0;
    layer_speed          = 0;--当前层速度
    Handler              = nil;--控制器
    CollideHandler       = nil;--碰撞检测器

    --本次关卡是否需要循环
    is_repeat_map        = false;


    --当前创建到第几个层第几个怪物
    --当前地图索引
    cur_map_id           = 0;
    --当前层里面怪物索引
    cur_mot_id           = 0;

    --从excel表中读取的MapData
    map_data_str         = nil;--"res/MapData/test.xml;res/MapData/test.xml .."

    --从地图编辑器导出的xml数据数据列表(一个xml对应一个地图数据) (里面的每一个地图数据的所有对象都是按顺序保存)
    map_data_list        = {};--所有xml文件对应的所有对象 **这个列表的怪物按一定顺序**
    --拆分完成的XX;XX;XX的table对应上面map_data_list
    split_data_list      = {};

    --(scene->主层->怪物图层表(table{layer})->对象各自列表)
    --ready_layer_list     = {};--将要被主层addChild的层(下面是主层addChild后要放入的列表) *内部使用*

    --当前层列表索引
    map_layer_index      = nil;--供外部map_layer_list使用

    mot_floor_list       = {};--地面(可以阻碍玩家前进)
    mot_road_list        = {};--平铺列表(可以阻碍玩家前进)一搬是隐藏 用于冲刺结束时候显示 或者 捡到道具显示
    mot_obj_list         = {};--障碍物(让玩家掉血 但不能被砍死)
    mot_gift_list        = {};--礼包盒(可以阻碍玩家前进 但是可以让玩家顶爆获奖)
    mot_flygift_list     = {};--飞行礼包盒(碰到就弹起)
    mot_hurt_list        = {};--扣血怪物列表(让玩家掉血 可以被砍死)
    mot_gold_list        = {};--金币类列表
    mot_flygold_list     = {};--飞翔金币列表
    mot_buffer_list      = {};--buffer类列表 (加血 冲刺 飞行 护盾 磁铁 巨人 浮梯 弹簧)
    mot_block_list       = {};--阻碍物(可以阻碍玩家前进)
    mot_air_floor_list   = {};--空中地面(只有从上至下的碰撞 让角色站上去) 包括:上浮空中地面 下沉空中地面

    create_range         = nil;--创建范围x
    --动态物品
    dynamic_hp_list      = {};--动态血瓶

    ----------------------------------------UI层----------------------------------------
    UI = {--免得重名
        --左上角
        --头像
        photoHead_path = {
            "zhandou_touxiang_ali.png";
            "zhandou_touxiang_ez.png";
            "zhandou_touxiang_gailun.png";
            "zhandou_touxiang_jiansheng.png";
            "zhandou_touxiang_timo.png";
            "zhandou_touxiang_zhaoxin.png";
        };
        photoHead_Z = 3;
        --血量
        photoBlood_path = "zhandou_xuetiao_02.png";
        photoBloodBack_path = "zhandou_xuetiao_01.png";
        photoBlood_Z = 2;
        --英雄buff
        heroBuff = {
            "zhandou_buff_01.png";
            "zhandou_buff_02.png";
            "zhandou_buff_03.png";
            "zhandou_buff_04.png";
        };
        --宝箱
        box = {
            "zhandou_baoxiang_001.png";
            "zhandou_baoxiang_002.png";
            "zhandou_baoxiang_004.png";
            "zhandou_baoxiang_003.png";
        };
        --表现
        biaoxian_path = "zhandou_biaoxian_01.png";
        --进度百分比
        persent_path = "changepersent.png";
        --战斗进度条
        zhandou_jindutiao = "zhandou_jindutiao_02.png";
        zhandou_jindutiao_ground = "zhandou_jindutiao_01.png";
        zhandou_jindutiao_start = "zhandou_start.png";
        --距离
        juli_bg_path = "zhandou_juli_dikuang.png";
        juli_word_path = "zhandou_juli.png";
        juli_mi_path = "zhandou_juli_mi.png";
        --战斗加血
        jiaxie_path = "zhandou_jiaxue_02.png";
        jiaxiekuang_path = "zhandou_jiaxue_01.png";
        --血条小人物
        jiaxie_renwu = "zhandou_jiaxue_03.png";
        jiaxie_Z = 4;
        --击杀怪物
        --kill_bg_path = "zhandou_guaiwujishashuliang_dikuang.png";
        --kill_word_path = "zhandou_jishaguaiwu.png";
        --斜杠
        --xiegang_path = "zhandou_xiexian.png";
        --boss状态栏
        --boss_head_path = "zhandou_bosstouxiang_01.png";
        --boss_blood_bg_path = "zhandou_bossxuetiao_01.png";
        --boss_blood_path = "zhandou_bossxuetiao_02.png";
        --boss_name_path = "zhandou_bossmingcheng_01.png";
        --boss_state = {
        --    "zhandou_bossjineng_01.png";
        --    "zhandou_bossjineng_02.png";
        --    "zhandou_bossjineng_03.png";
        --};

    };

    biaoxian_score = 0;--表现分数
    juli_score     = 0;--距离米数
    ----------------------------------------控制层----------------------------------------
    BUTTON = {
        --跳
        jump = {
            "zhandou_tiaoyueanniu.png";
            "zhandou_tiaoyueanniu.png";
            "zhandou_tiaoyueanniu.png";
            "zhandou_tiaoyuezi.png";--跳文字
        };
        --攻击
        gongji = {
            "zhandou_gongjianniu.png";
            "zhandou_gongjianniu.png";
            "zhandou_gongjianniu.png";
            "zhandou_gongjizi.png";--攻击文字
        };
        gongji_cd_time = 2;
        --技能
        jineng  ={
            "zhandou_jinenganniu.png";
            "zhandou_jinenganniu.png";
            "zhandou_jinenganniu.png";
            "zhandou_jineng.png";--技能文字
        };
        jineng_cd_time = 2;
        --冲刺
        chongci = {
            "zhandou_chongcianniu.png";
            "zhandou_chongcianniu.png";
            "zhandou_chongcianniu.png";
            "zhandou_chongcizi.png";--冲刺文字
        };
        chongci_cd = 2;
        cd_path = "zhandou_jineng_CD_01.png";
        zanting = {
            "zhandou_zanting.png";
            "zhandou_zanting.png";
            "zhandou_zanting.png";
        };
    };
    ----------------------------------------暂停界面----------------------------------------
    game_pause = nil;--暂停界面对象

    ----------------------------------------boss模式----------------------------------------
    boss_list   = nil;--boss列表

    Boss_Handler = nil;--boss控制器

    boss_die     = false;
    ----------------------------------------新手引导----------------------------------------
    js           = nil;--js
    is_js        = false;--是否出现过剑圣
    js_atk       = false;--js攻击
    js_skill     = false;--js技能
    is_exit      = false;--是否退出引导教程

    js_frame     = nil;
    js_label     = nil;
    light        = nil;
    is_run_light = nil;--是否运行监测光圈
    js_skill_ani = nil;--剑圣大招动画
    leader_finish = nil;--完成引导

}
local meta = GameModel



----引用和全局，初始化----------------------------------------------------------------------------------
local ValueTool = require "src/tool/value"
local GameRewardM = require "src/GameScene/GameRewardM"
local MonsterModel = require "src/monster/MonsterM"
--调用频繁就用local
local visibleSize_width = g_visibleSize.width
local visibleSize_height = g_visibleSize.height
--初始化UI层数据
function meta:initGameUI()
    meta.biaoxian_score = 0;--表现分数
    meta.juli_score     = 0;--距离米数
end
--xml解码
function meta:XMLdec(xml)
    for key,val in pairs(xml) do
        xml[key] = rever_dec(val)
    end
end

--读取利用tmx文件生成的战斗数据(包括战斗层 背景层)
function meta:ConverData()
    meta.is_release = false
    meta.map_data_list = {}
    meta.split_data_list = {}

    local data_list = meta:GetMapData()--获取关卡mapdata "res/MapData/test.xml;res/MapData/test.xml .."
    
    if data_list ~= "" then
        local xml_list = Split(data_list,";")--有多少个xml文件(获取xml路径)
        -------------------每一个tmx地图文件-------------------
        for i=1,#xml_list do
            --用工具类对象获取相应战斗数据
            --tmx_table = 
            --{
            --    obj_layer = {"XX;XX;XX","XX;XX;XX","XX;XX;XX" ... };--主战斗层 一个怪物对应一个"XX;XX;XX"
            --    back_layer = {暂时留空};--背景层
            --    width = nil;
            --    height = nil;
            --}
            local filepath = xml_list[i]
            --["key"] = value
            local data_map = cc.FileUtils:getInstance():getValueMapFromFile(filepath)
            --meta:XMLdec(data_map)

            -------------------每一xml地图中的所有怪物-------------------
            local layer_mot = {}--某一层里所有怪物
            local layer_bg  = {}--某一层里所有背景元素
            local j=1
            while true do
                --背景层
                local bg_x = string.format("bg_%d",j)
                if data_map[bg_x] then
                    --(加入所有背景元素入层)
                    table.insert(layer_bg,data_map[bg_x])
                end
                
                --战斗层
                local zd_x = string.format("zd_%d",j)--key
                if data_map[zd_x] then--value 每一只怪物的信息 XX;XX;XX
                    --把所有怪物放入层
                    table.insert(layer_mot,data_map[zd_x])--{XX;XX;XX , XX;XX;XX,...}一个地图层中所有怪物
                else
                    break
                end
                if j > 99999 then
                    return false--错误返回 不可能出现10万怪物
                end
                j = j + 1
            end
            
           
            --把层放入层列表
            if #layer_mot ~= 0 then
                local layer_width = data_map["width"]
                local layer_height = data_map["height"]
                local layer_data = --层数据结构
                {
                    --{ width = ,height = ,value = {"XX;XX;XX","XX;XX;XX",...} }
                    width  = layer_width;
                    height = layer_height;
                    value  = layer_mot;--怪物列表{"XX;XX;XX","XX;XX;XX",...}
                }
                table.insert(meta.map_data_list,layer_data)

                --meta.map_data_list = 
                --{
                --    --层1
                --    {
                --     width = 960;
                --     height = 640;
                --     value = {"XX;XX;XX","XX;XX;XX"...}
                --     },

                --    --层2
                --    {
                --     width = 960;
                --     height = 640;
                --     value = {"XX;XX;XX","XX;XX;XX"...}
                --     },

                --     ...
                --  }
            end
        end
        --赋值对应的拆分列表
        for i=1,#meta.map_data_list do
            local layer_split = {}
            for j=1,#meta.map_data_list[i].value do
                local str = meta.map_data_list[i].value[j]
                local mot_obj = ValueTool:init(str)--XX;XX;XX
                table.insert(layer_split,mot_obj)
            end
            table.insert(meta.split_data_list,layer_split)
        end
        
    end
    --初始化
    meta:releaseAllList()

    --初始化奖励数据
    GameRewardM:ConverData()
end
--清空所有对象表
function meta:releaseAllList()
    meta.cur_map_id = 1--层索引
    meta.cur_mot_id = 1--层怪物索引
    meta.map_layer_index = 1--层列表索引
    meta.create_range = visibleSize_width--创建范围
    meta.mot_floor_list       = {};
    meta.mot_road_list        = {};
    meta.mot_obj_list         = {};
    meta.mot_gift_list        = {};
    meta.mot_flygift_list     = {};
    meta.mot_hurt_list        = {};
    meta.mot_flygold_list     = {};
    meta.mot_gold_list        = {};
    meta.mot_buffer_list      = {};
    meta.mot_block_list            = {};
    meta.mot_air_floor_list        = {};
    meta.dynamic_hp_list           = {};
end

--数据赋值
function meta:initMonster(monster,mot_obj)
    
    if not mot_obj then
        return
    end

    monster.id             = mot_obj:GetId()--mot_list[1]--id,
    monster.name           = mot_obj:GetName()--mot_list[2]--mot_name,
    monster.res            = mot_obj:GetRes()--mot_list[3]--mot_res,
    monster.createType     = mot_obj:GetCreateType()--mot_list[4]--mot_createType,
    monster.monster_tag    = mot_obj:GetType()--mot_list[5]--mot_type,

    monster.attack         = mot_obj:GetAttack()--mot_list[6]--mot_attack,
    monster.defense        = mot_obj:GetDefense()--mot_list[7]--mot_defense,
                    
    monster.gold           = mot_obj:GetGold()--mot_list[8]--mot_gold,
    monster.spurt          = mot_obj:GetSpurt()--mot_list[9]--mot_spurt,
    monster.resumHp        = mot_obj:GetResumHp()--mot_list[10]--mot_resumHp,--回血
    monster.resumMp        = mot_obj:GetResumMp()--mot_list[11]--mot_resumMp,--回蓝
    monster.time           = mot_obj:GetTime()--mot_list[12]--mot_time    --持续时间

    monster.scope_x        = mot_obj:GetScopeX()--mot_list[13]--mot_scope_x
    monster.scope_y        = mot_obj:GetScopeY()--mot_list[14]--mot_scope_y
    monster.scope_w        = mot_obj:GetScopeW()--mot_list[15]--mot_scope_w
    monster.scope_h        = mot_obj:GetScopeH()--mot_list[16]--mot_scope_h

    monster.speed_x        = mot_obj:GetSpeedX()--mot_list[17]--mot_speed_x
    monster.speed_y        = mot_obj:GetSpeedY()--mot_list[18]--mot_speed_y

    monster.pos_x          = mot_obj:GetPosX()--mot_list[#mot_obj-1]--mot_pos_x
    monster.pos_y          = mot_obj:GetPosY()--mot_list[#mot_obj]--mot_pos_y

    monster.mot_tag        = mot_obj:GetMotTag()----mot_tag

    monster.scale          = mot_obj:GetMotScale()--mot_scale

    monster.show           = mot_obj:GetMotShow()--mot_show

end
--对怪物进行缩放
function meta:MonsterScale(monster)
    monster.ani:setScale(monster.scale)
end
--对怪物初始行为处理
function meta:MonsterAction(monster)
    if monster:GetMonsterTag() == MONSTER_TYPE.fly_gold or --飞行金币
       monster:GetId() == 160020 or --飞行护盾
       monster:GetId() == 160019 then--飞行冲刺
        local vec = cc.p(0,monster.move_metre)
        local move = cc.MoveBy:create(monster.move_time,vec)
        local reverse =  move:reverse()
        monster.ani:runAction(cc.RepeatForever:create(cc.Sequence:create(move,reverse)))
        --monster.ani:setScale(monster.scale)
    elseif monster:GetMonsterTag() == MONSTER_TYPE.road then
        if meta.Handler:getRole():GetRoleEscalator() then
            monster.ani:setVisible(true)--浮梯显示
        else
            monster.ani:setVisible(false)--浮梯隐藏
        end
    elseif monster:GetMonsterTag() == MONSTER_TYPE.up_floor then
        monster.ani:setPositionY(-monster.ani:getContentSize().height)
    end
    monster.pre_moveY = monster.ani:getPositionY()--为所有对象记录本次初始化位置
end
--选择渲染批次资源
function meta:choiceResTag(monster)
    if monster.mot_tag ~= "null" then
        return monster.mot_tag
    end
    return 0
end
--创建ani
function meta:CreateAni(monster)
    --local scope = monster:GetScope()

    local function AnimationEvent(arm, eventType, movmentID)--动画,状态 ,时刻id(动画动作名字)
        --cclog("self.movmentID = " ..movmentID)
		if eventType == ccs.MovementEventType.complete then --动画不循环情况下 完成时调用
            if movmentID == ANIMATION_ENUM.Injured then
                --扣血怪物列表
                if #meta.mot_hurt_list ~= 0 then
                    local i=1
                    while (i<=#meta.mot_hurt_list) do
                        if meta.mot_hurt_list[i].ani == arm then
                            arm:removeFromParent(true)
                            table.remove(meta.mot_hurt_list,i)
                            arm = nil
                            break
                        end
                        i = i + 1
                    end
                end
            end
        end
    end
    

    if monster.createType == MONSTER_CREATE_TYPE.exportjson then
        monster.ani = ccs.Armature:create(monster.res)--创建动画对象
        monster.ani:getAnimation():play(ANIMATION_ENUM.wait)
        monster.ani:setAnchorPoint(0,0)
        monster:SetScopePosX(monster:GetScopeX()*monster.ani:getContentSize().width)
        monster:SetScopePosY(monster:GetScopeY()*monster.ani:getContentSize().height)
        monster.ani:setPosition(monster.pos_x,monster.pos_y)
        monster.ani:getAnimation():setMovementEventCallFunc(AnimationEvent)--注册动画事件
    elseif monster.createType == MONSTER_CREATE_TYPE.png then
        monster.ani = cc.Sprite:createWithSpriteFrameName(monster.res)--此处ani表示精灵
        monster.ani:setAnchorPoint(0,0)
        monster:SetScopePosX(monster:GetScopeX()*monster.ani:getContentSize().width)
        monster:SetScopePosY(monster:GetScopeY()*monster.ani:getContentSize().height)
        
        monster.ani:setPosition(monster.pos_x,monster.pos_y)
    end
end
--创建动态血瓶
function meta:createDynamicHp()
    --血瓶数据结构
    local monster = MonsterModel:init()--初始化怪物信息
    local hp_struct = g_conf.g_monster_conf[27]
    monster.ani = cc.Sprite:createWithSpriteFrameName(hp_struct.mot_res)--此处ani表示精灵
    monster.ani:setAnchorPoint(0,0)
    
    monster:SetScopePosX(hp_struct.mot_scope_x*monster.ani:getContentSize().width)
    monster:SetScopePosY(hp_struct.mot_scope_y*monster.ani:getContentSize().height)
    monster:SetScopeWidth(hp_struct.mot_scope_w)
    monster:SetScopeHeight(hp_struct.mot_scope_h)

    --数据赋值
    monster.monster_tag = hp_struct.mot_type
    monster.resumHp     = hp_struct.mot_resumHp
    monster.speed_x     = hp_struct.mot_speed_x

    --动作处理
    local vec = cc.p(0,monster.move_metre)
    local move = cc.MoveBy:create(monster.move_time,vec)
    local reverse =  move:reverse()
    monster.ani:runAction(cc.RepeatForever:create(cc.Sequence:create(move,reverse)))

    monster.ani:setPosition(visibleSize_width,visibleSize_height/2)

    meta.Handler:getParent():addChild(monster.ani)
    if monster.glNode then
        meta.Handler:getParent():addChild(monster.glNode)--画笔
    end
    
    table.insert(meta.dynamic_hp_list,monster)
end

--*************************池更新*************************
--开始检查池列表
function meta:StartCheckPool(list,mot_obj,map_layer)
    local i=1
    while (i<=#list) do
        --检查每一个对象的父节点  因为有可能不一样
        if list[i].ani:getParent() == map_layer then--找到父节点再操作
            if list[i]:GetDie() then--死亡的对象才能拿来初始化
                if list[i]:GetId() == mot_obj:GetId() then
                    --重新初始化位置
                    list[i].pos_x = mot_obj:GetPosX()--mot_list[#mot_obj-1]--mot_pos_x
                    list[i].pos_y = mot_obj:GetPosY()--mot_list[#mot_obj]--mot_pos_y
                    list[i].ani:setPosition(list[i]:GetPosX(),list[i]:GetPosY())
                    list[i]:SetDie(false)
                    return true
                end
            end
        end
        i = i + 1
    end

    return false
end
--检查池中是否有可用对象
function meta:checkPoolObject(map_layer,mot_obj)
    if not mot_obj then
        return false
    end

    if mot_obj:GetType() == MONSTER_TYPE.floor then--地面(可以阻碍玩家前进)
        return meta:StartCheckPool(meta.mot_floor_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.road then--平铺(可以阻碍玩家前进)一搬是隐藏 用于冲刺结束时候显示 或者 捡到道具显示
        return meta:StartCheckPool(meta.mot_road_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.obj then--障碍物(可以阻碍玩家前进)
        return meta:StartCheckPool(meta.mot_obj_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.gift then--礼包盒(可以阻碍玩家前进 但是可以让玩家顶爆获奖)
        return meta:StartCheckPool(meta.mot_gift_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.fly_gift then--飞行礼包盒(碰到弹起)
        return meta:StartCheckPool(meta.mot_flygift_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.hurt then--扣血怪物
        return meta:StartCheckPool(meta.mot_hurt_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.gold then--金币类
        return meta:StartCheckPool(meta.mot_gold_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.fly_gold then--飞翔金币类
        return meta:StartCheckPool(meta.mot_flygold_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.item_spurt then--冲刺道具
        return meta:StartCheckPool(meta.mot_buffer_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.item_fly then--飞行道具
        return meta:StartCheckPool(meta.mot_buffer_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.item_protect then--护盾道具
        return meta:StartCheckPool(meta.mot_buffer_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.item_addHp then--加血道具
        return meta:StartCheckPool(meta.mot_buffer_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.item_magnet then--磁铁道具
        return meta:StartCheckPool(meta.mot_buffer_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.item_stretch then--弹簧道具
        return meta:StartCheckPool(meta.mot_buffer_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.item_escalator then--浮梯道具
        return meta:StartCheckPool(meta.mot_buffer_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.item_giant then--巨人道具
        return meta:StartCheckPool(meta.mot_buffer_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.block then--阻碍物
        return meta:StartCheckPool(meta.mot_block_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.air_floor then--空中地面
        return meta:StartCheckPool(meta.mot_air_floor_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.up_floor then--上浮地面
        return meta:StartCheckPool(meta.mot_air_floor_list,mot_obj,map_layer)
    elseif mot_obj:GetType() == MONSTER_TYPE.down_floor then--下沉地面
        return meta:StartCheckPool(meta.mot_air_floor_list,mot_obj,map_layer)
    end
end
--********************************************************************
--放入列表
function meta:intoList(monster)
    local is_log = false
    
    if monster.monster_tag == MONSTER_TYPE.floor then--地面(可以阻碍玩家前进)
        table.insert(meta.mot_floor_list,monster)
        if is_log then
            cclog("地面 ==== " ..#meta.mot_floor_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.road then--平铺(可以阻碍玩家前进)一搬是隐藏 用于冲刺结束时候显示 或者 捡到道具显示
        table.insert(meta.mot_road_list,monster)
        if is_log then
            cclog("平铺 ==== " ..#meta.mot_road_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.obj then--障碍物(可以阻碍玩家前进)
        table.insert(meta.mot_obj_list,monster)
        if is_log then
            cclog("障碍物 ==== " ..#meta.mot_obj_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.gift then--礼包盒(可以阻碍玩家前进 但是可以让玩家顶爆获奖)
        table.insert(meta.mot_gift_list,monster)
        if is_log then
            cclog("礼包盒 ==== " ..#meta.mot_gift_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.fly_gift then--飞行礼包盒(碰到弹起)
        table.insert(meta.mot_flygift_list,monster)
        if is_log then
            cclog("飞行礼包盒 ==== " ..#meta.mot_flygift_list)
        end
        
    elseif monster.monster_tag == MONSTER_TYPE.hurt then--扣血怪物
        table.insert(meta.mot_hurt_list,monster)
        if is_log then
            cclog("扣血怪物 ==== " ..#meta.mot_hurt_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.gold then--金币类
        table.insert(meta.mot_gold_list,monster)
        if is_log then
            cclog("金币类 ==== " ..#meta.mot_gold_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.fly_gold then--飞翔金币类
        table.insert(meta.mot_flygold_list,monster)
        if is_log then
            cclog("飞翔金币类 ==== " ..#meta.mot_flygold_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.item_spurt then--冲刺道具
        table.insert(meta.mot_buffer_list,monster)
        if is_log then
            cclog("冲刺道具 ==== " ..#meta.mot_buffer_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.item_fly then--飞行道具
        table.insert(meta.mot_buffer_list,monster)
        if is_log then
            cclog("飞行道具 ==== " ..#meta.mot_buffer_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.item_protect then--护盾道具
        table.insert(meta.mot_buffer_list,monster)
        if is_log then
            cclog("护盾道具 ==== " ..#meta.mot_buffer_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.item_addHp then--加血道具
        table.insert(meta.mot_buffer_list,monster)
        if is_log then
            cclog("加血道具 ==== " ..#meta.mot_buffer_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.item_magnet then--磁铁道具
        table.insert(meta.mot_buffer_list,monster)
        if is_log then
            cclog("磁铁道具 ==== " ..#meta.mot_buffer_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.item_stretch then--弹簧道具
        table.insert(meta.mot_buffer_list,monster)
        if is_log then
            cclog("弹簧道具 ==== " ..#meta.mot_buffer_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.item_escalator then--浮梯道具
        table.insert(meta.mot_buffer_list,monster)
        if is_log then
             cclog("浮梯道具 ==== " ..#meta.mot_buffer_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.item_giant then--巨人道具
        table.insert(meta.mot_buffer_list,monster)
        if is_log then
            cclog("巨人道具 ==== " ..#meta.mot_buffer_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.block then--阻碍物
        table.insert(meta.mot_block_list,monster)
        if is_log then
            cclog("阻碍物 ==== " ..#meta.mot_block_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.air_floor then--空中地面
        table.insert(meta.mot_air_floor_list,monster)
        if is_log then
            cclog("空中地面 ==== " ..#meta.mot_air_floor_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.up_floor then--上浮空中地面
        table.insert(meta.mot_air_floor_list,monster)
        if is_log then
            cclog("上浮空中地面 ==== " ..#meta.mot_air_floor_list)
        end
    elseif monster.monster_tag == MONSTER_TYPE.down_floor then--下沉空中地面
        table.insert(meta.mot_air_floor_list,monster)
        if is_log then
            cclog("下沉空中地面 ==== " ..#meta.mot_air_floor_list)
        end
    end
end
--检查释放方法 供checkReleasefunc用
function meta:checkReleasefunc(list)
    local i = 1
    while (i<=#list) do
        if list[i] then
            local obj_world = ConvertToWorldSpace(list[i].ani)
            local obj_width = list[i].ani:getContentSize().width
            if obj_world.x < - obj_width then
                if list[i].monster_tag == MONSTER_TYPE.floor then--地面(可以阻碍玩家前进)
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.road then--平铺(可以阻碍玩家前进)一搬是隐藏 用于冲刺结束时候显示 或者 捡到道具显示
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.obj then--障碍物(可以阻碍玩家前进)
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.gift then--礼包盒(可以阻碍玩家前进 但是可以让玩家顶爆获奖)
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.hurt then--扣血怪物
                   list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.gold then--金币类
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.item_spurt then--冲刺道具
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.item_fly then--飞行道具
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.item_protect then--护盾道具
                   list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.item_addHp then--加血道具
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.item_magnet then--磁铁道具
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                elseif list[i].monster_tag == MONSTER_TYPE.item_stretch then--弹簧道具
                   list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.item_escalator then--浮梯道具
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.item_giant then--巨人道具
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.block then--阻碍物
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.air_floor then--空中地面
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.up_floor then--上浮空中地面
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                elseif list[i].monster_tag == MONSTER_TYPE.down_floor then--下沉空中地面
                    list[i].ani:removeFromParent(true)
                    table.remove(list,i)
                    break
                    
                end

            end
        end
        i = i + 1
    end
end
--检查释放怪物(供外部使用)
function meta:checkReleaseObj()
    meta:checkReleasefunc(meta.mot_floor_list)--地面(可以阻碍玩家前进)
    meta:checkReleasefunc(meta.mot_road_list) --平铺列表(可以阻碍玩家前进)一搬是隐藏 用于冲刺结束时候显示 或者 捡到道具显示
    meta:checkReleasefunc(meta.mot_obj_list)  --障碍物(可以阻碍玩家前进)
    meta:checkReleasefunc(meta.mot_gift_list) --礼包盒(可以阻碍玩家前进 但是可以让玩家顶爆获奖)
    meta:checkReleasefunc(meta.mot_flygift_list) --飞行礼包盒(碰到弹起)
    meta:checkReleasefunc(meta.mot_hurt_list) --扣血怪物列表
    meta:checkReleasefunc(meta.mot_gold_list) --金币类列表
    meta:checkReleasefunc(meta.mot_flygold_list) --飞翔金币类列表
    meta:checkReleasefunc(meta.mot_buffer_list)--buffer类列表 (加血 冲刺 飞行 护盾 磁铁)
    meta:checkReleasefunc(meta.mot_block_list)--阻碍物(可以阻碍玩家前进)
    meta:checkReleasefunc(meta.mot_air_floor_list)--空中地面(只有从上至下的碰撞 让角色站上去) 包括:上浮空中地面 下沉空中地面
end
--清空方法(供clearAllObj使用)
function meta:clearList(list)
    local remove_i = 1
    while (remove_i<=#list) do
        list[remove_i].ani:removeFromParent(true)
        remove_i = remove_i + 1
    end
end
--清空所有普通场景对象列表
function meta:clearAllObj()
    
    meta:clearList(meta.mot_floor_list)--地面
    meta.mot_floor_list  = {}
    
    meta:clearList(meta.mot_road_list)--平铺列表
    meta.mot_road_list  = {}
    
    meta:clearList(meta.mot_obj_list)--障碍物
    meta.mot_obj_list    = {}

    meta:clearList(meta.mot_gift_list)--礼包盒
    meta.mot_gift_list   = {}

    meta:clearList(meta.mot_flygift_list)--飞行礼包盒
    meta.mot_flygift_list   = {}
    
    meta:clearList(meta.mot_hurt_list)--扣血怪物列表
    meta.mot_hurt_list   = {}

    meta:clearList(meta.mot_gold_list)--金币类列表
    meta.mot_gold_list   = {}

    meta:clearList(meta.mot_flygold_list)--飞翔金币类列表
    meta.mot_flygold_list   = {}
    
    meta:clearList(meta.mot_buffer_list)--buffer类列表
    meta.mot_buffer_list = {}

    meta:clearList(meta.mot_block_list)--阻碍物
    meta.mot_block_list  = {}

    meta:clearList(meta.mot_air_floor_list)--空中地面
    meta.mot_air_floor_list = {}
    
end
--获取当前地图关卡怪物id
function meta:GetCurMotId()
    return meta.cur_mot_id
end
--设置当前地图关卡怪物id
function meta:SetCurMotId(id)
    meta.cur_mot_id = id
end
--获取当前地图关卡
function meta:GetCurMapId()
    return meta.cur_map_id
end
--设置当前地图关卡
function meta:SetCurMapId(map_id)
    meta.cur_map_id = map_id
end
--获取关卡mapdata
function meta:GetMapData()
    return meta.map_data_str
end
--设置获取关卡mapdata
function meta:SetMapData(path)
    meta.map_data_str = path
end
--获取本次关卡是否需要循环
function meta:GetIsRepeat()
    return meta.is_repeat_map
end
--设置本次关卡是否需要循环
function meta:SetIsRepeat(is_repeat)
    meta.is_repeat_map = is_repeat
end
--获取当前层列表索引
function meta:GetLayerIndex()
    return meta.map_layer_index
end
--设置当前层列表索引
function meta:SetLayerIndex(index)
    meta.map_layer_index = index
end
--获取全局速度
function meta:GetGlobalSpeed()
    return meta.global_speed
end
--设置全局速度
function meta:SetGlobalSpeed(speed)
    meta.global_speed = speed*60/g_frame
end
--获取游戏状态
function meta:GetGameSetup()
    return meta.game_setup
end
--设置游戏状态
function meta:SetGameSetup(setup)
    meta.game_setup = setup
end
--获取当前层速度
function meta:GetLayerSpeed()
    return meta.layer_speed
end
--设置当前层速度
function meta:SetLayerSpeed(cur_speed)
    meta.layer_speed = cur_speed*60/g_frame
end
--获取创建范围
function meta:GetCreateRange()
    return meta.create_range
end
--设置创建范围
function meta:SetCreateRange(create_range)
    meta.create_range = create_range
end
--获取boss死亡状态
function meta:getBossDie()
    return self.boss_die
end
--设置boss死亡状态
function meta:setBossDie(is_die)
    self.boss_die = is_die
end
local MapContent = {
    [1] = {
        [1] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [2] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [3] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [4] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [5] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [6] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [7] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [8] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [9] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [10] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [11] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [12] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [13] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [14] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [15] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [16] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [17] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [18] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
    };
    [2] = {
        [1] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [2] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [3] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [4] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [5] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [6] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [7] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [8] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [9] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [10] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [11] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [12] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [13] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [14] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [15] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [16] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [17] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [18] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
    };
    [3] = {
        [1] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [2] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [3] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [4] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [5] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [6] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [7] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [8] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [9] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [10] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [11] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [12] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [13] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [14] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [15] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [16] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [17] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [18] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
    };
     [4] = {
        [1] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [2] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [3] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [4] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [5] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [6] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [7] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [8] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [9] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [10] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [11] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [12] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [13] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [14] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [15] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [16] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [17] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [18] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
    };
    [5] = {
        [1] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [2] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [3] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [4] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [5] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [6] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [7] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [8] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [9] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [10] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [11] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [12] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [13] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [14] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [15] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [16] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [17] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
        [18] = {far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0};
    };

};
--无尽模式
local MapWj = 
{
    --far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0
}
--新手引导
local MapLd = 
{
}

--读取配置文件章节
function meta:LoadBackground()
    --无尽模式
    for i=2,#g_conf.g_wj_conf do
        local temp_conf = g_conf.g_wj_conf[i]
        local wj_data = {

            id             = temp_conf.id;
            gold           = temp_conf.gold;
            far            = temp_conf.far;
            far_speed      = temp_conf.far_speed;
            far_heigth     = temp_conf.far_height;
            
            middle         = temp_conf.middle;
            middle_speed   = temp_conf.middle_speed;
            middle_heigth  = temp_conf.middle_height;

            near           = temp_conf.near;
            near_speed     = temp_conf.near_speed;
            near_height    = temp_conf.near_height;

            floor          = temp_conf.floor;
            floor_speed    = temp_conf.floor_speed;
            floor_heigth   = temp_conf.floor_heigth;

            MapData        = temp_conf.MapData;
            is_repeat      = temp_conf.is_repeat;
            layer_speed    = temp_conf.layer_speed;
            goldMap        = temp_conf.goldMap
        }
        table.insert(MapWj,wj_data)
    end
        
        --[[关卡模式
        for i = 2,#g_conf.g_game_conf do
            local temp_conf = g_conf.g_game_conf[i]
            MapContent[temp_conf.section][temp_conf.point] = 
            {
                id             = temp_conf.id;
                gold           = temp_conf.gold;
                far            = temp_conf.far;
                far_speed      = temp_conf.far_speed;
                far_heigth     = temp_conf.far_height;
            
                middle         = temp_conf.middle;
                middle_speed   = temp_conf.middle_speed;
                middle_heigth  = temp_conf.middle_height;

                near           = temp_conf.near;
                near_speed     = temp_conf.near_speed;
                near_height    = temp_conf.near_height;

                floor          = temp_conf.floor;
                floor_speed    = temp_conf.floor_speed;
                floor_heigth   = temp_conf.floor_heigth;

                MapData        = temp_conf.MapData;
                is_repeat      = temp_conf.is_repeat;
                layer_speed    = temp_conf.layer_speed;
                goldMap        = temp_conf.goldMap
            }
            --cclog("far === " ..tostring(MapContent[g_game_conf[i].section][g_game_conf[i].point].far))
        end
        --]]

    

    --奖励模式
    for i=2,#g_conf.g_jl_conf do
        local temp_conf = g_conf.g_jl_conf[i]
        local jl_data = 
        {
            id             = temp_conf.id;
            gold           = temp_conf.gold;
            far            = temp_conf.far;
            far_speed      = temp_conf.far_speed;
            far_heigth     = temp_conf.far_height;
            
            middle         = temp_conf.middle;
            middle_speed   = temp_conf.middle_speed;
            middle_heigth  = temp_conf.middle_height;

            near           = temp_conf.near;
            near_speed     = temp_conf.near_speed;
            near_height    = temp_conf.near_height;

            floor          = temp_conf.floor;
            floor_speed    = temp_conf.floor_speed;
            floor_heigth   = temp_conf.floor_heigth;

            MapData        = temp_conf.MapData;
            is_repeat      = temp_conf.is_repeat;
            layer_speed    = temp_conf.layer_speed;
            goldMap        = temp_conf.goldMap;
        }
        
        table.insert(GameRewardM.Mapjl,jl_data)
    end

    --新手引导
    if g_userinfo.leader <= LEADER_ENUM.leader0 then
       --新手引导地图
        for i=2,#g_conf.g_leader_conf do
            local temp_conf = g_conf.g_leader_conf[i]
            local ld_data = {

                id             = temp_conf.id;
                gold           = temp_conf.gold;
                far            = temp_conf.far;
                far_speed      = temp_conf.far_speed;
                far_heigth     = temp_conf.far_height;
            
                middle         = temp_conf.middle;
                middle_speed   = temp_conf.middle_speed;
                middle_heigth  = temp_conf.middle_height;

                near           = temp_conf.near;
                near_speed     = temp_conf.near_speed;
                near_height    = temp_conf.near_height;

                floor          = temp_conf.floor;
                floor_speed    = temp_conf.floor_speed;
                floor_heigth   = temp_conf.floor_heigth;

                MapData        = temp_conf.MapData;
                is_repeat      = temp_conf.is_repeat;
                layer_speed    = temp_conf.layer_speed;
                goldMap        = temp_conf.goldMap
            }
            table.insert(MapLd,ld_data)
        end
    end
     
end


local function getZhangJie(str)
    local pos = string.find(str,";")
    if pos ~= nil then
        local zhang = tonumber(string.sub(str, 1, pos-1))
        local jie   = tonumber(string.sub(str, pos+1, string.len(str)))
        return zhang,jie
    end
end

function meta:setBackground(section)
    
    meta.far                  = nil;--远景静止图
    meta.middle               = {};--中景路径列表
    meta.middle_obj_tab       = {};--中景对象列表
    if g_userinfo.leader <= LEADER_ENUM.leader0 then
        --随机无尽地图
        local Rand = require "src/tool/rand"
        local map_id = Rand:randnum(1,#MapLd)
        local map_obj = MapLd[map_id]

        meta.id             = map_obj.id
        meta.gold           = map_obj.gold
        meta.far            = map_obj.far--设置场景背景远图
        meta.far_speed      = map_obj.far_speed
        meta.far_heigth     = map_obj.far_heigth

        --meta.middle         = map_obj.middle
        meta.middle_speed   = map_obj.middle_speed
        meta.middle_heigth  = map_obj.middle_heigth

        meta.near           = map_obj.near
        meta.near_speed     = map_obj.near_speed
        meta.near_heigth    = map_obj.near_heigth
        meta.floor          = map_obj.floor
        meta.floor_speed    = map_obj.floor_speed*6
        meta.floor_heigth   = map_obj.floor_heigth

        meta.goldMap        = map_obj.goldMap
        
        ----------------------------------------------------
        
        --地图是否循环
        meta.is_repeat      = map_obj.is_repeat
        if meta.is_repeat == 1 then
            meta:SetIsRepeat(true)
        else
            meta:SetIsRepeat(false)
        end

        --设置初始化战斗地图数据
        meta:SetMapData(map_obj.MapData)--"res/MapData/test.xml;res/MapData/test.xml .."
        --设置层速度
        meta:SetLayerSpeed(map_obj.layer_speed)
        local temp_path = map_obj.middle
        if temp_path ~= "null" then
            local tab_middle_path = Split(temp_path,";")
            for i=1,#tab_middle_path do
                table.insert(meta.middle,tab_middle_path[i])--中景路径列表
            end
        end

        --根据id获取奖励模式地图
        for i=1,#GameRewardM.Mapjl do
            local conf = GameRewardM.Mapjl[i]
            if meta.goldMap == conf.id then
                --根据id设置奖励模式地图数据
                GameRewardM:setBackground(conf)
                break
            end
        end

    elseif GameModel.game_model == GAME_MODEL.game_repeat then--无尽模式
        --随机无尽地图
        local Rand = require "src/tool/rand"
        local map_id = Rand:randnum(1,#MapWj)
        local map_obj = MapWj[map_id]

        meta.id             = map_obj.id
        meta.gold           = map_obj.gold
        meta.far            = map_obj.far--设置场景背景远图
        meta.far_speed      = map_obj.far_speed
        meta.far_heigth     = map_obj.far_heigth

        --meta.middle         = map_obj.middle
        meta.middle_speed   = map_obj.middle_speed
        meta.middle_heigth  = map_obj.middle_heigth

        meta.near           = map_obj.near
        meta.near_speed     = map_obj.near_speed
        meta.near_heigth    = map_obj.near_heigth
        meta.floor          = map_obj.floor
        meta.floor_speed    = map_obj.floor_speed*6
        meta.floor_heigth   = map_obj.floor_heigth

        meta.goldMap        = map_obj.goldMap
        ----------------------------------------------------
        
        --地图是否循环
        meta.is_repeat      = map_obj.is_repeat
        if meta.is_repeat == 1 then
            meta:SetIsRepeat(true)
        else
            meta:SetIsRepeat(false)
        end

        --设置初始化战斗地图数据
        meta:SetMapData(map_obj.MapData)--"res/MapData/test.xml;res/MapData/test.xml .."
        --设置层速度
        meta:SetLayerSpeed(map_obj.layer_speed)
        local temp_path = map_obj.middle
        if temp_path ~= "null" then
            local tab_middle_path = Split(temp_path,";")
            for i=1,#tab_middle_path do
                table.insert(meta.middle,tab_middle_path[i])--中景路径列表
            end
        end

        --根据id获取奖励模式地图
        for i=1,#GameRewardM.Mapjl do
            local conf = GameRewardM.Mapjl[i]
            if meta.goldMap == conf.id then
                --根据id设置奖励模式地图数据
                GameRewardM:setBackground(conf)
                break
            end
        end

    else
        --      z = 章  ;j = 节
        local z,j = getZhangJie(section)
        cclog("zhang = %d,   jie = %d",z,j)
        if MapContent[z][j].far ~= "" then
            meta.far               = MapContent[z][j].far
            meta.far_speed         = MapContent[z][j].far_speed
            meta.far_heigth        = MapContent[z][j].far_heigth

            --meta.middle = MapContent[z][j].middle
            meta.middle_speed      = MapContent[z][j].middle_speed
            meta.middle_heigth     = MapContent[z][j].middle_heigth

            meta.near              = MapContent[z][j].near
            meta.near_speed        = MapContent[z][j].near_speed
            meta.near_heigth       = MapContent[z][j].near_heigth
            meta.floor             = MapContent[z][j].floor
            meta.floor_speed       = MapContent[z][j].floor_speed*6
            meta.floor_heigth      = MapContent[z][j].floor_heigth

            ----------------------------------------------------
            --地图是否循环
            meta.is_repeat      = map_obj.is_repeat
            if meta.is_repeat == 1 then
                meta:SetIsRepeat(true)
            else
                meta:SetIsRepeat(false)
            end


            --设置场景背景远图
            --meta.back_ground_pic = MapContent[z][j].far
            --设置初始化战斗地图数据
            meta:SetMapData(MapContent[z][j].MapData)--"res/MapData/test.xml;res/MapData/test.xml .."

            --设置层速度
            meta:SetLayerSpeed(MapContent[z][j].layer_speed)

            local temp_path = MapContent[1][1].middle
            if temp_path ~= "null" then
                local tab_middle_path = Split(temp_path,";")
                for i=1,#tab_middle_path do
                    table.insert(meta.middle,tab_middle_path[i])--中景路径列表
                end
            end
       
        else
            --cclog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
            --防止崩溃
            meta.far             = MapContent[1][1].far --设置场景背景远图
            meta.far_speed       = MapContent[1][1].far_speed
            meta.far_heigth      = MapContent[1][1].far_heigth


            --meta.middle          = MapContent[1][1].middle
            meta.middle_speed    = MapContent[1][1].middle_speed
            meta.middle_heigth   = MapContent[1][1].middle_heigth

            meta.near            = MapContent[1][1].near
            meta.near_speed      = MapContent[1][1].near_speed
            meta.near_heigth     = MapContent[1][1].near_heigth
            meta.floor           = MapContent[1][1].floor
            meta.floor_speed     = MapContent[1][1].floor_speed*3
            meta.floor_heigth    = MapContent[1][1].floor_heigth

            ----------------------------------------------------

            --地图是否循环
            meta.is_repeat      = map_obj.is_repeat
            meta:SetIsRepeat(true)--默认循环
            

            --设置关卡mapdata 
            meta:SetMapData(MapContent[z][j].MapData)--"res/MapData/test.xml;res/MapData/test.xml .."

            --设置层速度
            meta:SetLayerSpeed(MapContent[z][j].layer_speed)

            local temp_path = MapContent[1][1].middle
            if temp_path ~= "null" then
                local tab_middle_path = Split(temp_path,";")
                for i=1,#tab_middle_path do
                    table.insert(meta.middle,tab_middle_path[i])--中景路径列表
                end
            end
        end
    end
    
end
------------------------------------------新手引导------------------------------------------
--新手引导数据初始化
function meta:initLeader()
    --新手引导
    if g_userinfo.leader <= LEADER_ENUM.leader0 then
        meta.js           = nil;--js
        meta.is_js        = false;--是否出现过剑圣
        meta.js_atk       = false;--js攻击
        meta.js_skill     = false;--js技能
        meta.is_exit      = false;--是否退出引导教程
        meta.js_frame     = nil;
        meta.js_label     = nil;
        meta.light        = nil;
        meta.is_run_light = false;
        meta.js_skill_ani = nil;--剑圣大招动画
        meta.leader_finish = false;--完成引导
    end
end
--新手引导剑圣出场
function meta:jsShowEx(layer)
    --剑圣从天掉下来
    meta.js = ccs.Armature:create("JS")
    meta.js:getAnimation():play(ANIMATION_ENUM.run)
    meta.js:setAnchorPoint(0,0)
    meta.js:setPosition(meta.Handler:getCurPosition().x,visibleSize_height)
    layer:addChild(meta.js,10)
    local move_by = cc.MoveBy:create(0.5,cc.p(100,meta.Boss_Handler:getPositionY() - visibleSize_height))
    local function jsAtk()
        meta.js_atk = true
    end
    local seq = cc.Sequence:create(move_by,cc.CallFunc:create(jsAtk))
    meta.js:runAction(seq)

    --动画事件回调
	local function JSAnimationEvent(arm, eventType, movmentID)--动画,状态 ,时刻id(动画动作名字)
		if eventType == ccs.MovementEventType.complete then --动画不循环情况下 完成时调用
            if movmentID == ANIMATION_ENUM.AOE then
                meta.js:getAnimation():play(ANIMATION_ENUM.run)
            end
        end
    end
    meta.js:getAnimation():setMovementEventCallFunc(JSAnimationEvent)
end
--新手引导剑圣出场
function meta:jsShow(layer)
    --剑圣从天掉下来
    meta.js = ccs.Armature:create("JS")
    meta.js:getAnimation():play(ANIMATION_ENUM.run)
    meta.js:setAnchorPoint(0,0)
    meta.js:setPosition(meta.Handler:getCurPosition().x,visibleSize_height)
    local move_by = cc.MoveBy:create(0.5,cc.p(100,meta.Boss_Handler:getPositionY() - visibleSize_height))

    meta.js_frame = cc.Scale9Sprite:createWithSpriteFrameName("xinshouyindao_dikuang.png")--框
    meta.js_frame:setAnchorPoint(0,0)
    meta.js_frame:setPosition(visibleSize_width - meta.js_frame:getContentSize().width,visibleSize_height - meta.js_frame:getContentSize().height)
    meta.js_frame:setVisible(false)
    meta.js_label = cc.LabelTTF:create("","微软雅黑",24)
    meta.js_label:setAnchorPoint(0,0)
    meta.js_label:setVisible(false)

    layer:addChild(meta.js)
    layer:addChild(meta.js_frame)
    layer:addChild(meta.js_label)

    local function showSpeak()--出场白
         meta.js_frame:setVisible(true)
         meta.js_label:setVisible(true)
         meta.js_label:setString("  你的剑就是我的剑，年轻的勇士，我来帮您！")
         meta.js_label:setPosition(meta.js_frame:getPositionX(),meta.js_frame:getPositionY()+50)
    end
    local function endSpeak()--出场白结束
        if meta.js_frame then
            meta.js_frame:setVisible(false)
            meta.js_label:setVisible(false)
        end
    end
    
    --跳下来 出场对白
    local jump_speak = cc.Sequence:create(cc.Spawn:create(move_by,cc.CallFunc:create(showSpeak)),cc.DelayTime:create(3),cc.CallFunc:create(endSpeak))
    --meta.js:runAction(jump_speak)
    
    ---[[
    --打2秒
    local function jsAtk()
        meta.js_atk = true
    end

    local js_atk = cc.CallFunc:create(jsAtk)--cc.Spawn:create(cc.DelayTime:create(2),cc.CallFunc:create(jsAtk))

   
    --动画事件回调
	local function JSAnimationEvent(arm, eventType, movmentID)--动画,状态 ,时刻id(动画动作名字)
		if eventType == ccs.MovementEventType.complete then --动画不循环情况下 完成时调用
            if movmentID == ANIMATION_ENUM.AOE then
                meta.js:getAnimation():play(ANIMATION_ENUM.run)
               
            --elseif movmentID == ANIMATION_ENUM.atk then
            --    meta.js:getAnimation():play(ANIMATION_ENUM.run)
            end
        end
    end
    meta.js:getAnimation():setMovementEventCallFunc(JSAnimationEvent)
    

    --总流程 
    local js_seq = cc.Sequence:create(jump_speak,js_atk)
    meta.js:runAction(js_seq)
    --]]
end
--新手引导update
function meta:leaderUpdateEx(layer)
    if meta.js_atk then
        meta.js_atk = false
        --boss掉血动作
        local function BossInjured()
            local injured = meta.Handler:getRole():GetDataAttack()
            --随机无尽地图
            local Rand = require "src/tool/rand"
            local offsect = Rand:randnum(1,50)--浮动伤害
            injured = injured*2 + offsect
            meta.Boss_Handler:setInjureString(injured)
        end
        --js跑动
        local function jsRun()
            meta.js:getAnimation():play(ANIMATION_ENUM.run)
        end
        --js攻击
        local function jsGj()
            meta.js:getAnimation():play(ANIMATION_ENUM.atk)
        end

        local js_gj = cc.Spawn:create(cc.DelayTime:create(0.2),cc.CallFunc:create(jsGj),cc.CallFunc:create(BossInjured))

        --奥义
        local function ay()
            cclog("！！！！奥义！！！！")
            --meta.js_skill = true
            --meta.js:getAnimation():play(ANIMATION_ENUM.AOE)
            ---[[
            meta.js_skill_ani = ccs.Armature:create("JSbig")
            meta.js_skill_ani:getAnimation():play(ANIMATION_ENUM.run)
            --动画事件回调
	        local function JSANIAnimationEvent(arm, eventType, movmentID)--动画,状态 ,时刻id(动画动作名字)
		        if eventType == ccs.MovementEventType.complete then --动画不循环情况下 完成时调用
                    if movmentID == ANIMATION_ENUM.run then
                        meta.js_skill_ani:removeFromParent()
                        meta.js_skill = true
                        meta.js:getAnimation():play(ANIMATION_ENUM.AOE)
                    end
                end
            end
            meta.js_skill_ani:getAnimation():setMovementEventCallFunc(JSANIAnimationEvent)
            --meta.js_skill_ani:setAnchorPoint(0,0)
            meta.js_skill_ani:setPosition(visibleSize_width/2,visibleSize_height/2)
            cc.Director:getInstance():getRunningScene():addChild(meta.js_skill_ani,99)
            --]]
        end

        local seq = cc.Sequence:create(
           js_gj,cc.CallFunc:create(jsRun),cc.DelayTime:create(1),--跑步 延时
            js_gj,cc.CallFunc:create(jsRun),cc.DelayTime:create(1),----跑步 延时
            js_gj,cc.CallFunc:create(jsRun),cc.DelayTime:create(2),----跑步 延时
            cc.CallFunc:create(ay)
            )
        meta.Boss_Handler:runAction(seq)
    end

    if meta.js_skill then
        meta.js_skill = false
        local count = 1
        local boss_hp = meta.Boss_Handler:GetCurHp()/3
        --boss掉血动作
        local function BossInjured()
            if count < 3 then
                injured = boss_hp
                count = count + 1
            else
                injured = meta.Boss_Handler:GetCurHp()
            end
            meta.Boss_Handler:setInjureString(math.floor(injured))
        end
         
         
        local seq = cc.Sequence:create(
        cc.CallFunc:create(BossInjured),cc.DelayTime:create(1),
        cc.CallFunc:create(BossInjured),cc.DelayTime:create(1),
        cc.CallFunc:create(BossInjured),
        cc.DelayTime:create(2)
        )
        meta.js:runAction(seq)
    end

end
--新手引导update
function meta:leaderUpdate(layer)
    if meta.js_atk then
        meta.js_atk = false
        --boss掉血动作
        local function BossInjured()
            local injured = meta.Handler:getRole():GetDataAttack()
            --随机无尽地图
            local Rand = require "src/tool/rand"
            local offsect = Rand:randnum(1,50)--浮动伤害
            injured = injured*2 + offsect
            meta.Boss_Handler:setInjureString(injured)
        end
        --js跑动
        local function jsRun()
            meta.js:getAnimation():play(ANIMATION_ENUM.run)
        end
        --js攻击
        local function jsGj()
            meta.js:getAnimation():play(ANIMATION_ENUM.atk)
        end

        local js_gj = cc.Spawn:create(cc.DelayTime:create(0.2),cc.CallFunc:create(jsGj),cc.CallFunc:create(BossInjured))

         --奥义
        local function skill_speak()
            meta.js_frame:setVisible(true)
            meta.js_label:setVisible(true)
            meta.js_label:setString("          奥义·无敌斩!!!!!!")
            meta.js_label:setPosition(meta.js_frame:getPositionX(),meta.js_frame:getPositionY()+50)
        end
        local function endSkillSpeak()
            if meta.js_frame then
                meta.js_frame:setVisible(false)
                meta.js_label:setVisible(false)
                meta.js:getAnimation():play(ANIMATION_ENUM.AOE)
                 meta.js_skill = true
            end
        end
        local js_ay = cc.Sequence:create(cc.CallFunc:create(skill_speak),cc.DelayTime:create(1),cc.CallFunc:create(endSkillSpeak))

        local seq = cc.Sequence:create(
           js_gj,cc.CallFunc:create(jsRun),cc.DelayTime:create(1),--跑步 延时
            js_gj,cc.CallFunc:create(jsRun),cc.DelayTime:create(1),----跑步 延时
            js_gj,cc.CallFunc:create(jsRun),cc.DelayTime:create(2),----跑步 延时
            js_ay--奥义
        )
        meta.Boss_Handler:runAction(seq)
    end
    if meta.js_skill then
        meta.js_skill = false
        local count = 1
        local boss_hp = meta.Boss_Handler:GetCurHp()/3
        --boss掉血动作
        local function BossInjured()
            if count < 3 then
                injured = boss_hp
                count = count + 1
            else
                injured = meta.Boss_Handler:GetCurHp()
            end
            meta.Boss_Handler:setInjureString(math.floor(injured))
        end
         
         
        local function lightVisible()
             --光圈出现
             meta.is_run_light = true
        end

        local seq = cc.Sequence:create(
        cc.CallFunc:create(BossInjured),cc.DelayTime:create(1),
        cc.CallFunc:create(BossInjured),cc.DelayTime:create(1),
        cc.CallFunc:create(BossInjured),
        cc.DelayTime:create(2),
        cc.CallFunc:create(lightVisible)
        )
        meta.js:runAction(seq)
    end
    
    

end
--光圈出现
function meta:showLightEx()
    if meta.is_run_light then
        if meta.light then
            local pos_x = meta.light:getPositionX()
            pos_x = pos_x - meta:GetLayerSpeed()
            meta.light:setPositionX(pos_x)
            if pos_x <= meta.js:getPositionX() then
                meta.light:removeFromParent()
                meta.js:removeFromParent()
                meta.is_exit = true--退出教程引导
                meta.light = nil
                meta.is_run_light = false--结束光圈更新标识
            end
        else
            meta.light = ccs.Armature:create("terminal")--光圈
            meta.light:getAnimation():play(ANIMATION_ENUM.wait)
            meta.light:setAnchorPoint(0,0)
            local light_y = meta.js:getPositionY()-meta.js:getContentSize().height/3
            meta.light:setPosition(visibleSize_width,light_y)
            cc.Director:getInstance():getRunningScene():addChild(meta.light,99)
        end
    end
end
--光圈出现
function meta:showLight()
     if meta.is_run_light then
        if meta.light then
            local pos_x = meta.light:getPositionX()
            pos_x = pos_x - meta:GetLayerSpeed()
            meta.light:setPositionX(pos_x)
            if pos_x <= meta.js:getPositionX() then
                meta.light:removeFromParent()
                meta.js_frame:removeFromParent()
                meta.js_label:removeFromParent()
                meta.js:removeFromParent()
                meta.is_exit = true--退出教程引导
                meta.light = nil
                meta.is_run_light = false--结束光圈更新标识
            end
        else
            meta.light = ccs.Armature:create("terminal")--光圈
            meta.light:getAnimation():play(ANIMATION_ENUM.wait)
            meta.light:setAnchorPoint(0,0)
            local light_y = meta.js:getPositionY()-meta.js:getContentSize().height/3
            meta.light:setPosition(visibleSize_width,light_y)
            cc.Director:getInstance():getRunningScene():addChild(meta.light,99)
        end
     end
    
    --[[
    meta.light = ccs.Armature:create("terminal")--光圈
    meta.light:getAnimation():play(ANIMATION_ENUM.wait)
    meta.light:setAnchorPoint(0,0)
    local light_y = meta.js:getPositionY()-meta.js:getContentSize().height/3
    meta.light:setPosition(visibleSize_width,light_y)
    cc.Director:getInstance():getRunningScene():addChild(meta.light,99)
        
    local function endLight()
        meta.light:removeFromParent()
        meta.js_frame:removeFromParent()
        meta.js_label:removeFromParent()
        meta.js:removeFromParent()
        meta.is_exit = true
        --js_frame:setVisible(true)
        --js_label:setVisible(true)
        --js_label:setString("勇士，合作愉快，期待和您再次合作，再见。")
        --js_label:setPosition(0,js_frame:getPositionY())
    end

    local the_end = cc.CallFunc:create(endLight)
    local light_time = (visibleSize_width - meta.js:getPositionX())/meta:GetLayerSpeed()*60
    local arrive = cc.Sequence:create(cc.MoveBy:create(light_time,cc.p(meta.js:getPositionX()-visibleSize_width,0)),the_end)
    meta.light:runAction(arrive)
    --]]
end
--从新手场景转化到下一教程
function meta:NextLeader()
    cclog("从新手场景转化到下一教程")
    GameModel.leader_finish = true --完成教程

    --背景层释放
    local GameBackGroundView = require "src/GameScene/gamevbackground"
    GameBackGroundView:ReleaseAll()
    --释放主层数据
    local GameView = require "src/GameScene/GameV"
    GameView:release()--重来需要传true
    --释放UI层
    local GameSceneUi = require "src/GameScene/GameSceneUi"
    --GameSceneUi:release()
    --释放控制层
    local GameSceneButton = require "src/GameScene/GameSceneButton"
    GameSceneButton:release()

    local startScene = require "src/start/startScene"--登陆
    

    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/Loading/loadingRes.plist", 
                                                        "res/ui/Loading/loadingRes.pvr.ccz")--新loading资源

	if cc.Director:getInstance():getRunningScene() then
		cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,startScene:init2()))
	else
        cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,startScene:init2()))
	end

end

return GameModel

