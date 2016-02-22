local GameRewardM = 
{
    id                   = nil;--id
    gold                 = nil;--关卡奖励金币
----------------------------------------背景层----------------------------------------
    far                  = nil;--静态背景图
    far_obj              = nil;--远景图对象
    far_speed            = 0.6;--
    far_heigth           = 0;--

    middle               = {};--中景路径列表
    middle_obj_tab       = {};--中景对象列表
    middle_speed         = 2;
    middle_heigth        = 0;

    near                 = nil;
    near_speed           = 4;
    near_heigth          = 0;

    floor                = nil;--g_game_conf[2].floor;
    floor_speed          = 6;--g_game_conf[2].floor_speed;
    floor_heigth         = 0;--g_game_conf[2].floor_height;

    animation            = nil;--g_game_conf[2].animation;
    animation_name       = nil;--g_game_conf[2].animation_name;
    animation_speed      = 0;--g_game_conf[2].animation_speed;

    map_path_table       = {};--地图

    back_ground_pic      = nil;--远景静止图

    --奖励模式
    Mapjl = 
    {
         --far = "";far_speed = 0;far_heigth = 0;middle = "";middle_speed = 0;middle_heigth = 0;near = "";near_speed = 0;near_heigth = 0;floor = "";floor_speed = 0;floor_heigth = 0;MapData = "";layer_speed = 0;goldMap = ""
    };

----------------------------------------主逻辑层----------------------------------------
    
    --刚进入奖励模式需要清理原来场景对象 此变量用于标识是否清理
    is_just_reward       = false;

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
    mot_flygift_list     = {};--飞行礼包盒(碰到弹起)
    mot_hurt_list        = {};--扣血怪物列表(让玩家掉血 可以被砍死)
    mot_gold_list        = {};--金币类列表
    mot_flygold_list     = {};--飞翔金币列表
    mot_buffer_list      = {};--buffer类列表 (加血 冲刺 飞行 护盾 磁铁 巨人 浮梯 弹簧)
    mot_block_list       = {};--阻碍物(可以阻碍玩家前进)
    mot_air_floor_list   = {};--空中地面(只有从上至下的碰撞 让角色站上去) 包括:上浮空中地面 下沉空中地面

    create_range         = nil;--创建范围x

}
local meta = GameRewardM

--调用频繁就用local
local visibleSize_width = g_visibleSize.width
local visibleSize_height = g_visibleSize.height
--引用和全局，初始化-----------------------------------------------------------
local ValueTool = require "src/tool/value"

--设置奖励模式地图数据
function meta:setBackground(map_obj)

    meta.middle_obj_tab       = {};--中景对象列表

    meta.id             = map_obj.id
    meta.gold           = map_obj.gold
    meta.far            = map_obj.far--远景静止图
    meta.far_speed      = map_obj.far_speed
    meta.far_heigth     = map_obj.far_heigth

    --meta.middle         = map_obj.middle--
    meta.middle_speed   = map_obj.middle_speed
    meta.middle_heigth  = map_obj.middle_heigth

    meta.near           = map_obj.near
    meta.near_speed     = map_obj.near_speed
    meta.near_heigth    = map_obj.near_heigth
    meta.floor          = map_obj.floor
    meta.floor_speed    = map_obj.floor_speed*6
    meta.floor_heigth   = map_obj.floor_heigth

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

end
--读取利用tmx文件生成的战斗数据(包括战斗层 背景层)
function meta:ConverData()

    meta.map_data_list = {}
    meta.split_data_list = {}

    local data_list = meta:GetMapData()--获取关卡mapdata "res/MapData/test.xml;res/MapData/test.xml .."
    
    if data_list ~= "" then
        local xml_list = Split(data_list,";")--有多少个xml文件(获取xml路径)
        -------------------每一个tmx地图文件-------------------
        for i=1,#xml_list do
            
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
    meta.mot_gold_list        = {};
    meta.mot_flygold_list     = {};
    meta.mot_buffer_list      = {};
    meta.mot_block_list            = {};
    meta.mot_air_floor_list        = {};
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
        if GameModel.Handler:getRole():GetRoleEscalator() then
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
    local scope = monster:GetScope()
    if monster.createType == MONSTER_CREATE_TYPE.exportjson then
        monster.ani = ccs.Armature:create(monster.res)--创建动画对象
        monster.ani:getAnimation():play(ANIMATION_ENUM.wait)
        monster.ani:setAnchorPoint(scope.x,scope.y)
        monster.ani:setPosition(monster.pos_x,monster.pos_y)
    elseif monster.createType == MONSTER_CREATE_TYPE.png then
        monster.ani = cc.Sprite:createWithSpriteFrameName(monster.res)--此处ani表示精灵
        monster.ani:setAnchorPoint(scope.x,scope.y)
        monster.ani:setPosition(monster.pos_x,monster.pos_y)
    end
end
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
                --cclog(list[i].name .."==  " ..#list - 1)
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


-----------------------设置与获取数据-----------------------
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
--获取创建范围
function meta:GetCreateRange()
    return meta.create_range
end
--设置创建范围
function meta:SetCreateRange(create_range)
    meta.create_range = create_range
end
--获取当前层速度
function meta:GetLayerSpeed()
    return meta.layer_speed
end
--设置当前层速度
function meta:SetLayerSpeed(cur_speed)
    meta.layer_speed = cur_speed*60/g_frame
end
--获取当前层列表索引
function meta:GetLayerIndex()
    return meta.map_layer_index
end
--设置当前层列表索引
function meta:SetLayerIndex(index)
    meta.map_layer_index = index
end

return GameRewardM

