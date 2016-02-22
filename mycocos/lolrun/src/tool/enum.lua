--///////////////////////////////枚举/////////////////////////////
--角色选取
ROLE_HERO_ENUM =
{
    tm    = 1;--提莫
    zx    = 2;--赵兴
    dm    = 3;--德玛
    ez    = 4;--EZ
    ah    = 5;--阿狸
    js    = 6;--剑圣

    --boss
    xkzy  = 7;--虚空之眼
    str   = 8;--石头人
}
--主界面英雄需要展示的动作
ROLE_SHWO_ACTION = {
    "attack";
    "death";
    "Injured";
    "jump2";
    "skills";
}
--怪物类型
MONSTER_TYPE = 
{
    floor           =  1;--地面(可以阻碍玩家前进) mot_floor_list
    road            =  2;--平铺(可以阻碍玩家前进)一搬是隐藏 用于冲刺结束时候显示 或者 捡到道具显示 mot_road_list
    obj             =  3;--障碍物(让玩家掉血 但不能被砍死) mot_obj_list
    gift            =  4;--礼包盒(可以阻碍玩家前进 但是可以让玩家顶爆获奖) mot_gift_list
    hurt            =  5;--扣血怪物(让玩家掉血 可以被砍死) mot_hurt_list
    gold            =  6;--金币类 mot_gold_list
    item_spurt      =  7;--飞行冲刺道具 mot_buffer_list
    item_fly        =  8;--极速飞行卡(静态) mot_buffer_list
    item_protect    =  9;--护盾道具 mot_buffer_list
    item_addHp      =  10;--加血道具 mot_buffer_list
    item_magnet     =  11;--磁铁道具 mot_buffer_list
    item_stretch    =  12;--弹簧道具(会使玩家弹起 场景对象迅速往左移动一段距离)mot_buffer_list
    item_escalator  =  13;--浮梯道具(碰到后让平铺列表显示)mot_buffer_list
    item_giant      =  14;--巨人道具(让角色无敌 并且撞烂所有对象)mot_buffer_list
    block           =  15;--阻碍物(可以阻碍玩家前进)
    air_floor       =  16;--空中地面(只有从上至下的碰撞 让角色站上去)
    up_floor        =  17;--上浮空中地面(会上浮至指定位置)
    down_floor      =  18;--下沉空中地面(会从指定位置下沉)
    fly_gold        =  19;--飞翔金币列表 mot_flygold_list
    fly_gift        =  20;--飞行礼包盒mot_flygift_list
}
--怪物创建类型初始化
MONSTER_CREATE_TYPE = 
{
    exportjson =  1;--动画初始化
    png        =  2;--精灵初始化
}
ROLE_ATK_TYPE = 
{
    melee = 1;--近战
    farwar = 2;--远战
}
--资源分类(像texturepacker同一个资源png图的为一个类型  一个骨骼动画一个类型) 
--(因为每个不同类型的对象不是连续创建 设置这个值是为了同一个资源 在同一批次也就是tag 可以批量渲染 注意:值越大的在靠近屏幕)
OBJECT_RENDER_TAG = --（config配置 这个枚举测试用）
{
    fade_layer        = 1000;
    reward_layer      = 2;
    normal_layer      = 1;
    --怪物png图
    floor             = 100;--地面
    air_floor         = 99;--奖励地面

    --动画tag
    bullet            = 100;
    spurt             = 200;--冲刺

}

--游戏步骤
GAME_STEP = 
{
    game_ready    = 0;--准备
    game_start    = 1;--开始
    game_in       = 2;--游戏中
    game_end      = 3;--结束
    game_reward   = 4;--奖励模式
    game_boss     = 5;--boss模式
    game_novice   = 6;--新手引导模式
    game_role_die = 7;--角色hp为0死亡
    game_role_move_die = 8;--角色被夹死或者是掉坑死
}

--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--动画动作枚举
ANIMATION_ENUM = 
{
    run        = "run";--跑步
    jump       = "jump1";--跳跃
    jump2      = "jump2";--跳跃
    spurt      = "chongci";--冲刺
    skill      = "skills";--技能--"skill";"skills";
    jump_atk   = "attack_air";--跳跃攻击--"atk";--"attack_air";
    jump_skill = "skills_air";--跳跃放技能--"skill";--"skills_air";

    --glide   = "glide";--下滑
    --normal     = "normal";--普通
    --boom       = "boom";--爆炸
    --suffer     = "suffer";--受击

    atk        = "attack";--攻击--"atk";"attack"
    Injured    = "Injured";--受伤
    death      = "death";--死亡

    --角色子弹
    fly        = "fly";--飞行
    hit        = "hit";--击中
    skifly     = "skifly";--蘑菇飞行
    skihit     = "skihit";--蘑菇击中

    wait       = "wait";--待机

    AOE        = "AOE";--JS大招
   
}
--游戏模式
GAME_MODEL =
{
    game_copy = 1;--副本模式
    game_extra = 2;--金币/经验模式
    game_repeat = 3;--无尽模式
}
--新手引导步骤
LEADER_ENUM = 
{
    leader0  = 0;--战斗引导地图
    leader1  = 1;--创号之后
    leader2  = 2;
    leader3  = 3;
    leader4  = 4;
    leader5  = 5;
    leader6  = 6;
}
--新手引导组件名称
LEADER_COMPONENT =
{
    CCSprite   = "CCSprite";
    CCArmature = "CCArmature";
}
--字体类型
LABEL_TYPE_ENUM = 
{
    ttf      = 1;--标题字体(setString时候效率等于创建 建议用于不改变字体内容情况下使用)
    bmfont   = 2;--fnt字体库创建字体
}
--按钮类型
BUTTON_TYPE_ENUM = 
{
    normal = 1;--单按钮
    high   = 2;--双按钮 普通和按下状态

}
--本地数据key
CONFIG_USER_DEFAULT = 
{
    UserMac      = "umac";
    UserId       = "uid";
    UserName     = "uname";
    UserPsw      = "upsw";
    UserSid      = "sid";
    Power        = "Power";--体力
    Gold         = "Gold"; --金币
    Diamonds     = "Diamonds";--钻石
    LastTime     = "LastTime";--最后登陆时间
    LoginNum     = "LoginNum";--连续登陆次数
    RoleData     = "RoleData";--角色数据
    Section      = "Section";--章节
    MidLevelSection = "MidLevelSection";--用于记录中等难度关的章节
    HigLevelSection = "HigLevelSection";--用于记录高难度关的章节
    Chest = {
        --第一章
        {
            "chest_1_1";    --_1_1代表第一章第一个宝箱   如果为true，则表示已经领取
            "chest_1_2";
            "chest_1_3";
        };
    };

    HighestScore = {
        [1] = {--第一章
            [1] = {--初级难度
            "scroe_nor_1_1";"scroe_nor_1_2";"scroe_nor_1_3";"scroe_nor_1_4";"scroe_nor_1_5";"scroe_nor_1_6";
            "scroe_nor_1_7";"scroe_nor_1_8";"scroe_nor_1_9";"scroe_nor_1_10";"scroe_nor_1_11";"scroe_nor_1_12";
            "scroe_nor_1_13";"scroe_nor_1_14";"scroe_nor_1_15";"scroe_nor_1_16";"scroe_nor_1_17";"scroe_nor_1_18";
            };
            [2] = {--中级难度
            "scroe_mid_1_1";"scroe_mid_1_2";"scroe_mid_1_3";"scroe_mid_1_4";"scroe_mid_1_5";"scroe_mid_1_6";
            "scroe_mid_1_7";"scroe_mid_1_8";"scroe_mid_1_9";"scroe_mid_1_10";"scroe_mid_1_11";"scroe_mid_1_12";
            "scroe_mid_1_13";"scroe_mid_1_14";"scroe_mid_1_15";"scroe_mid_1_16";"scroe_mid_1_17";"scroe_mid_1_18";
            };
            [3] = {--高级难度
            "scroe_hig_1_1";"scroe_hig_1_2";"scroe_hig_1_3";"scroe_hig_1_4";"scroe_hig_1_5";"scroe_hig_1_6";
            "scroe_hig_1_7";"scroe_hig_1_8";"scroe_hig_1_9";"scroe_hig_1_10";"scroe_hig_1_11";"scroe_hig_1_12";
            "scroe_hig_1_13";"scroe_hig_1_14";"scroe_hig_1_15";"scroe_hig_1_16";"scroe_hig_1_17";"scroe_hig_1_18";
            };
        };
    };

    HeroData = "HeroData"; --角色数据结构


}
--无尽模式奖励数据
BOX = {
    bronze_status    = "990001",
    silver_status    = "990002",
    gold_status      = "990003",
    platinum_status  = "990004",
    boss_1           = "1",
    boss_2           = "2",
    boss_3           = "3",
    boss_4           = "4"
}
--界面id
GAME_UI = 
{
    Game_Guide = 1;--主界面
}

---[[引导地图   计算界面
--难度水平的枚举
LEVEL_TYPE = 
{
    Nor = 1;
    Mid = 2;
    Hig = 3;

}
--记录最大的章节
MAX = {
    zhang = 1;
    jie = 18;
};


--记录boss的位置
line_boss_idx = {
    1;
    4;
    7;
    11;
    15;
    18;
};

--统计
--]]