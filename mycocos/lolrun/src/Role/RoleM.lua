local RoleModel = 
{
    role_tag = nil;

    atk_type = nil;--区分近战和远程英雄

    scope = {};

    stretch_sum = nil;
    bullet_list = {};--角色子弹
    bullet_draw = nil;--画笔
    
    spurt_step     = 0;--冲刺延时结束  用于进入场景冲刺叠加

    sprite_dun     = nil;--护盾
    sprite_spurt   = nil;--冲刺
    sprite_jump2   = nil;--二跳动画

    hero_id        = nil;--英雄id
    hero_level     = nil;--英雄等级
    big_time       = nil;--巨人时间
    magnet_time    = nil;--磁铁持续时间
    spurt_time     = nil;--冲刺
    escalator_time = nil;--浮梯时间
    gliding_time   = nil;--滑翔时间
    gliding_stop   = nil;--标识滑翔是否中断 如果在空中自己松手或者滑翔结束后 不可再滑翔 直到落地位置重置
    spurt_clear    = nil;

    attack_cd      = nil;--攻击CD
    skill_cd       = nil;--技能CD
    spurt_cd       = nil;--冲刺CD

    --Action
    Gliding_Action = nil;--滑翔动作 便于stop
    on_floor       = nil;--判断是否在地面
    spurt_action   = nil;--冲刺动作(不包含转化场景时候的冲刺)

    shoot_range    = nil;--攻击距离

    --change_big    = nil;--在变大的过程所获取的缩放值是原值 所以在这里要记录变大后的数据
    role_is_floor = nil;--角色是否一直都碰到地面 用于判断是否平走掉落 平走掉落会减少跳跃上限次数

    --角色状态
    role_type = 
    {
        run        =  true,--平跑 正常
        jump1      =  false,--1段跳跃
        jump2      =  false,--2段跳跃
        jump3      =  false,--3段跳跃
        jump4      =  false,--4段跳跃
        blink      =  false,--闪烁(无敌一小段时间 受伤触发)
        big        =  false,--变大(无敌 能够撞烂任何东西)
        dun        =  false, --护盾
        spurt      =  false, --冲刺
        magnet     =  false,  --磁铁
        escalator  =  false,   --浮梯
        gliding    =  false,   --滑翔

        attack     =  false,    --攻击
        airattack  =  false,   --空中攻击
        skill      =  false    --技能状态
    };

    --获取战斗数据
    fight_role = nil;

    --八个宝箱领取状况
    box =
    {
      [BOX.bronze_status]   = nil;
      [BOX.silver_status]   = nil;
      [BOX.gold_status]     = nil;
      [BOX.platinum_status] = nil;
      [BOX.boss_1]          = nil;
      [BOX.boss_2]          = nil;
      [BOX.boss_3]          = nil;
      [BOX.boss_4]          = nil;
    }

}

local meta = RoleModel
local RoleBase = require "src/Base/RoleBase"
setmetatable(meta,RoleBase)--设置类型是RoleBase
meta.__index = meta--表设定为自身
----引用和全局，初始化----------------------------------------------------------------------------------
local GameSceneUi = require "src/GameScene/GameSceneUi"
local GameSceneButton = require "src/GameScene/GameSceneButton"
local GameM = require "src/GameScene/GameM"
local Rand = require "src/tool/rand"
local visibleSize_width = g_visibleSize.width
local visibleSize_height = g_visibleSize.height

function meta:init()

    local self = {}--初始化自身
    self = RoleBase:init()--将对象自身设定为父类，这个语句相当于其他语言的super
    setmetatable(self,meta)--将对象自身元表设定为RoleModel类

    --初始化数据
    self:initRoleData()

    --初始化模拟数据
    --self:initRoleDataModel()



    return self

end
--与外部数据对接
function meta:SetFightRole(fight_role)
    meta.fight_role = fight_role

    --meta.fight_role:getGiant()--英雄巨人时间
    --meta.fight_role:getSprint()--英雄冲刺时间
    --meta.fight_role:getLadder()--英雄浮梯时间
    --meta.fight_role:getMagnet()--英雄磁铁时间
    --meta.fight_role:getattack()--英雄最终攻击力
    --meta.fight_role:getFinallife()--英雄最终HP

end
--初始化数据
function meta:initRoleData()
    
    if meta.role_tag then
        self.role_tag = meta.role_tag
    elseif g_userinfo.leader <= LEADER_ENUM.leader0 then--新手引导
        self.role_tag = ROLE_HERO_ENUM.tm
    else
        --self.role_tag = ROLE_HERO_ENUM.tm
        self.role_tag = ROLE_HERO_ENUM.tm
    end
    
    ------------------------------提莫------------------------------
    if self.role_tag == ROLE_HERO_ENUM.tm then
        
        --名字
        self.name = "提莫"
        self.res  = "Teemo"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0,width=50,height=100},
            atk = {x=0.3,y=0,width=100,height=100}
        }

        self.atk_type    =  ROLE_ATK_TYPE.farwar

        self.shoot_range = 300
        self.attack_cd   = 0
        self.skill_cd    = 0
        self.spurt_cd    = 0
    ------------------------------阿狸------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ah then
        
        --名字
        self.name = "阿狸"
        self.res  = "Ahri"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.6,y=0,width=50,height=100},
            atk = {x=0.6,y=0,width=100,height=100}
        }

        self.atk_type    =  ROLE_ATK_TYPE.farwar
        self.shoot_range = 500
        self.attack_cd   = 0
        self.skill_cd    = 30
        self.spurt_cd    = 0
    ------------------------------赵信------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.zx then
        
        --名字
        self.name = "赵信"
        self.res  = "zhaoxin"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0,width=50,height=100},
            atk = {x=0.3,y=0,width=200,height=100}
        }

        self.atk_type    =  ROLE_ATK_TYPE.melee
        self.shoot_range = 1000
        self.attack_cd   = 0.2
        self.skill_cd    = 0
        self.spurt_cd    = 0
    ------------------------------Ezreal------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ez then
        
        --名字
        self.name = "Ezreal"
        self.res  = "Ezreal"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0,width=50,height=100},
            atk = {x=0.3,y=0,width=100,height=100}
        }

        self.atk_type    =  ROLE_ATK_TYPE.farwar
        self.shoot_range = 500
        self.attack_cd   = 0.2
        self.skill_cd    = 25
        self.spurt_cd    = 0
     ------------------------------盖伦------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.dm then
        
        --名字
        self.name = "Garen"
        self.res  = "Garen"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0.15,width=50,height=100},
            atk = {x=0.3,y=0.15,width=200,height=100}
        }

        self.shoot_range = 1000
        self.attack_cd   =  0.2
        self.skill_cd    = 20
        self.spurt_cd    = 0
        self.atk_type    =  ROLE_ATK_TYPE.melee
    ------------------------------剑圣------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.js then
        
        --名字
        self.name = "JS"
        self.res  = "JS"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.4,y=0,width=50,height=100},
            atk = {x=0.4,y=0,width=200,height=100}
        }

        self.shoot_range = 1000
        self.attack_cd   =  0.2
        self.skill_cd    = 40
        self.spurt_cd    = 0
        self.atk_type =  ROLE_ATK_TYPE.melee
    ------------------------------默认提莫------------------------------
    else
        --名字
        self.name = "提莫"
        self.res  = "Teemo"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0,width=50,height=100},
            atk = {x=0.3,y=0,width=100,height=100}
        }

        
        self.shoot_range = 300
        self.attack_cd   = 0.2
        self.skill_cd    = 0
        self.spurt_cd    = 0
        self.atk_type =  ROLE_ATK_TYPE.farwar
        
    end

    --临时调位置 正式发布要注释
    --self.attack_cd   =  0.2
    --self.shoot_range = 500
    --self.bullet_draw = cc.DrawNode:create()
    
    self.hero_id        = meta.fight_role:getId()--英雄id
    self.hero_level     = meta.fight_role:getLevel()--英雄id
    self.big_time       = meta.fight_role:getGiant()--英雄巨人时间
    self.magnet_time    = meta.fight_role:getMagnet()--英雄磁铁时间
    self.spurt_time     = meta.fight_role:getSprint()--英雄冲刺时间
    self.escalator_time = meta.fight_role:getLadder()--英雄浮梯时间


    self.gliding_stop   = false --滑翔重置
    self.Gliding_Action = nil--滑翔动作 便于stop
    self.bullet_list    = {} --子弹列表
    self.spurt_clear    = false;--冲刺后清空对象
    --self.change_big = 1

    self.spurt_step     = 0;--冲刺延时结束  用于进入场景冲刺叠加
    self.spurt_action   = nil

    --属性
    --cclog(" meta.fight_role:getId() == " ..meta.fight_role:getId())
    self.hp             = meta.fight_role:getFinallife()--英雄最终HP
    self.cur_hp         = self.hp
    self.attack         = meta.fight_role:getFinalattack()--英雄最终攻击力
    self.crit           = tonumber(meta.fight_role:getCrit())--英雄暴击率
    self.spurt_cd       = tonumber(meta.fight_role:getSprint())

    self.gliding_time   = 2--滑翔时间
    self.stretch_sum    = 0--连续接触弹簧次数
    self.role_is_floor  = false--角色是否在地上

    --meta.fight_role:getattack()--英雄最终攻击力

    --初始化角色状态
    self.role_type = 
    {
        run        =  true,--平跑 正常
        jump1      =  false,--1段跳跃
        jump2      =  false,--2段跳跃
        jump3      =  false,--3段跳跃
        jump4      =  false,--4段跳跃
        blink      =  false,--闪烁(无敌一小段时间 受伤触发)
        big        =  false,--变大(无敌 能够撞烂任何东西)
        dun        =  false, --护盾
        spurt      =  false, --冲刺
        magnet     =  false,  --磁铁
        escalator  =  false,   --浮梯
        gliding    =  false,   --滑翔

        attack     =  false,    --攻击
        airattack  =  false,   --空中攻击
        skill      =  false    --技能状态
    }


    self.box = 
    {
      [BOX.bronze_status]   = meta.fight_role:getBoxStatus(BOX.bronze_status);
      [BOX.silver_status]   = meta.fight_role:getBoxStatus(BOX.silver_status);
      [BOX.gold_status]     = meta.fight_role:getBoxStatus(BOX.gold_status);
      [BOX.platinum_status]   = meta.fight_role:getBoxStatus(BOX.platinum_status);
      [BOX.boss_1]          = meta.fight_role:getBoxStatus(BOX.boss_1);
      [BOX.boss_2]          = meta.fight_role:getBoxStatus(BOX.boss_2);
      [BOX.boss_3]          = meta.fight_role:getBoxStatus(BOX.boss_3);
      [BOX.boss_4]          = meta.fight_role:getBoxStatus(BOX.boss_4);
    }
    --根据宝箱判断bossId(从第五个开始)
    if self.box[BOX.boss_1] == 2 then
        g_boss = 1
    elseif self.box[BOX.boss_2] == 2 then 
        g_boss = 2
    elseif self.box[BOX.boss_3] == 2 then 
        g_boss = 3
    elseif self.box[BOX.boss_4] == 2 then 
        g_boss = 4
    else
        g_boss = 0
    end
end

--初始化模拟数据
function meta:initRoleDataModel()
    --self.role_tag = ROLE_HERO_ENUM.ez
    if meta.role_tag then
        self.role_tag = meta.role_tag
    else
        --self.role_tag = ROLE_HERO_ENUM.tm
        self.role_tag = ROLE_HERO_ENUM.tm
    end
    
    ------------------------------提莫------------------------------
    if self.role_tag == ROLE_HERO_ENUM.tm then
        
        --名字
        self.name = "提莫"
        self.res  = "Teemo"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0,width=50,height=100},
            atk = {x=0.3,y=0,width=100,height=100}
        }

        self.hp          = 100
        self.cur_hp      = self.hp
        self.atk_type    =  ROLE_ATK_TYPE.farwar

        self.shoot_range = 300
        self.attack_cd   = 0.5
        self.skill_cd    = 0
        self.spurt_cd    = 0
    ------------------------------阿狸------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ah then
        
        --名字
        self.name = "阿狸"
        self.res  = "Ahri"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.6,y=0,width=50,height=100},
            atk = {x=0.6,y=0,width=100,height=100}
        }

        self.hp          = 200
        self.cur_hp      = self.hp
        self.atk_type    =  ROLE_ATK_TYPE.farwar
        self.shoot_range = 500
        self.attack_cd   = 0.5
        self.skill_cd    = 30
        self.spurt_cd    = 0
    ------------------------------赵信------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.zx then
        
        --名字
        self.name = "赵信"
        self.res  = "zhaoxin"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0,width=50,height=100},
            atk = {x=0.3,y=0,width=200,height=100}
        }

        self.hp          = 1000
        self.cur_hp      = self.hp
        self.atk_type    =  ROLE_ATK_TYPE.melee
        self.shoot_range = 1000
        self.attack_cd   = 1
        self.skill_cd    = 0
        self.spurt_cd    = 0
    ------------------------------Ezreal------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ez then
        
        --名字
        self.name = "Ezreal"
        self.res  = "Ezreal"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0,width=50,height=100},
            atk = {x=0.3,y=0,width=100,height=100}
        }

        self.hp          = 500
        self.cur_hp      = self.hp
        self.atk_type    =  ROLE_ATK_TYPE.farwar
        self.shoot_range = 500
        self.attack_cd   = 0.5
        self.skill_cd    = 25
        self.spurt_cd    = 0
     ------------------------------盖伦------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.dm then
        
        --名字
        self.name = "Garen"
        self.res  = "Garen"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.7,y=0.3,width=50,height=100},
            atk = {x=0.7,y=0.3,width=200,height=100}
        }

        self.hp          = 2000
        self.cur_hp      = self.hp
        self.shoot_range = 1000
        self.attack_cd   =  1
        self.skill_cd    = 20
        self.spurt_cd    = 0
        self.atk_type    =  ROLE_ATK_TYPE.melee
    ------------------------------剑圣------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.js then
        
        --名字
        self.name = "JS"
        self.res  = "JS"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0,width=50,height=100},
            atk = {x=0.3,y=0,width=200,height=100}
        }

        self.hp          = 2000
        self.cur_hp      = self.hp
        self.shoot_range = 1000
        self.attack_cd   =  1
        self.skill_cd    = 40
        self.spurt_cd    = 0
        self.atk_type =  ROLE_ATK_TYPE.melee
    ------------------------------默认提莫------------------------------
    else
        --名字
        self.name = "提莫"
        self.res  = "Teemo"

        --类型碰撞范围
        self.scope = 
        {
            --正常跑步(包括被阻塞)
            run = {x=0.3,y=0,width=50,height=100},
            atk = {x=0.3,y=0,width=200,height=100}
        }

        self.hp          = 100
        self.cur_hp      = self.hp
        self.shoot_range = 300
        self.attack_cd   = 0
        self.skill_cd    = 0
        self.spurt_cd    = 0
        self.atk_type =  ROLE_ATK_TYPE.farwar
    end

    --临时调位置 正式发布要注释
    self.attack_cd   =  0
    self.stretch_sum = 0--连续接触弹簧次数
    --self.shoot_range = 500
    --self.bullet_draw = cc.DrawNode:create()
    
    self.hero_id        = 100001
    self.hero_level     = 5
    self.big_time       = 5--巨人时间
    self.magnet_time    = 5--磁铁持续时间
    self.spurt_time     = 5--冲刺时间
    self.escalator_time = 5--浮梯时间
    self.gliding_time   = 2--滑翔时间

    self.gliding_stop   = false --滑翔重置
    self.Gliding_Action = nil--滑翔动作 便于stop
    self.bullet_list    = {} --子弹列表
    self.spurt_clear    = false;--冲刺后清空对象
    --self.change_big = 1
    self.spurt_step     = 0;--冲刺延时结束  用于进入场景冲刺叠加
    self.spurt_action   = nil

    self.role_is_floor  = false--角色是否在地上
    --初始化角色状态
    self.role_type = 
    {
        run        =  true,--平跑 正常
        jump1      =  false,--1段跳跃
        jump2      =  false,--2段跳跃
        jump3      =  false,--3段跳跃
        jump4      =  false,--4段跳跃
        blink      =  false,--闪烁(无敌一小段时间 受伤触发)
        big        =  false,--变大(无敌 能够撞烂任何东西)
        dun        =  false, --护盾
        spurt      =  false, --冲刺
        magnet     =  false,  --磁铁
        escalator  =  false,   --浮梯
        gliding    =  false,   --滑翔

        attack     =  false,    --攻击
        airattack  =  false,   --空中攻击
        skill      =  false    --技能状态
    }

    self.box = 
    {
      [BOX.bronze_status]   = 0;
      [BOX.silver_status]   = 0;
      [BOX.gold_status]     = 0;
      [BOX.platinum_status] = 0;
      [BOX.boss_1]          = 0;
      [BOX.boss_2]          = 0;
      [BOX.boss_3]          = 0;
      [BOX.boss_4]          = 0;
    }

    g_boss = 1
end
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--击中声音筛选
function meta:HitSound()
    ------------------------------提莫------------------------------
    if self.role_tag == ROLE_HERO_ENUM.tm then
       playEffect("res/music/effect/role/teemo/Teemo_atchit.ogg")
    ------------------------------阿狸------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ah then
       playEffect("res/music/effect/role/ahri/Ahri_atchit.ogg")
    ------------------------------Ezreal------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ez then
       playEffect("res/music/effect/role/ez/Ezreal_atchit.ogg")
    ------------------------------赵信------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.zx then
       playEffect("res/music/effect/role/zhaoxin/zhaoxi_atchit.ogg")
     ------------------------------盖伦------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.dm then
       playEffect("res/music/effect/role/garen/Garen_atchit.ogg")
    ------------------------------剑圣------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.js then
       playEffect("res/music/effect/role/js/JS_atchit.ogg")
    end
end
--二跳动画
function meta:SpriteJump2Ani()
    
    self.sprite_jump2:setVisible(true)
    self.sprite_jump2:getAnimation():play(ANIMATION_ENUM.run)
    

    if self:GetRoleBig() then
        self.sprite_jump2:setScale(2)
        self.sprite_jump2:setPosition(self.ani:getParent():getPositionX() - 80,self.ani:getParent():getPositionY() - 100)
    else
        self.sprite_jump2:setScale(1)
        self.sprite_jump2:setPosition(self.ani:getParent():getPositionX() - 40,self.ani:getParent():getPositionY()+40)
    end
    
    --------------------------------提莫------------------------------
    --if self.role_tag == ROLE_HERO_ENUM.tm then
    --    self.sprite_jump2:setPosition(self.ani:getParent():getPositionX() - 40,self.ani:getParent():getPositionY()+40)
    --------------------------------阿狸------------------------------
    --elseif self.role_tag == ROLE_HERO_ENUM.ah then
    --    self.sprite_jump2:setPosition(self.ani:getParent():getPositionX() - 40,self.ani:getParent():getPositionY()+40)
    --------------------------------Ezreal------------------------------
    --elseif self.role_tag == ROLE_HERO_ENUM.ez then
    --    self.sprite_jump2:setPosition(self.ani:getParent():getPositionX() - 40,self.ani:getParent():getPositionY()+40)
    --------------------------------赵信------------------------------
    --elseif self.role_tag == ROLE_HERO_ENUM.zx then
    --    self.sprite_jump2:setPosition(self.ani:getParent():getPositionX() - 40,self.ani:getParent():getPositionY()+40)
    -- ------------------------------盖伦------------------------------
    --elseif self.role_tag == ROLE_HERO_ENUM.dm then
    --    self.sprite_jump2:setPosition(self.ani:getParent():getPositionX() - 40,self.ani:getParent():getPositionY()+40)
    --------------------------------剑圣------------------------------
    --elseif self.role_tag == ROLE_HERO_ENUM.js then
    --    self.sprite_jump2:setPosition(self.ani:getParent():getPositionX() - 40,self.ani:getParent():getPositionY()+40)
    --end
     
end
--冲刺
function meta:Spurt(val_time)
    if not self:GetRoleSpurt() then
        --cclog("~~~~~~~~~~~~~~Spurt~~~~~~~~~~~~~~~~~~~~~~")
        --self.spurt_step = self.spurt_step + 1--记录切换场景  防止刚好冲刺结束掉落
        --设置角色冲刺状态
        self:SetRoleSpurt(true)
        self:SetRoleMagnet(true)--磁性效果
        GameM:SetGlobalSpeed(15)
        playEffect("res/music/effect/fight/i_rush.ogg")
        --冲刺开始
        local function spurtStart()
            self.sprite_spurt:setVisible(true)
            self:GetAni():getAnimation():play(ANIMATION_ENUM.spurt)
        end
        --冲刺结束
        local function spurtEnd()
            --cclog("~~~~~~~~~~~~~~Spurt  spurtEnd~~~~~~~~~~~~~~~~~~~~~~")
            self.spurt_action = nil
            --self.spurt_step = self.spurt_step - 1
            --if self.spurt_step == 0 then--转化进入场景 交由过度场景冲刺结束
                --cclog("~~~~~~~~~~~~~~Spurt spurtEndspurtEnd~~~~~~~~~~~~~~~~~~~~~~")
                self.ani:getParent():setVyZero()--设置竖直速度为0
                self.sprite_spurt:setVisible(false)
                self:SetRoleSpurt(false)--冲刺结束
                self:SetRoleMagnet(false)--磁性效果
                GameM:SetGlobalSpeed(0)
                --触发显示浮梯
                local function EscalatorStart()--浮梯开始
                    self:SetRoleEscalator(true)
                    --浮梯显示
                    for i=1,#GameM.mot_road_list do
                        GameM.mot_road_list[i].ani:setVisible(true)
                    end
                end
                local function EscalatorEnd()--浮梯结束
                    self:SetRoleEscalator(false)
                end
                local seq = cc.Sequence:create(cc.CallFunc:create(EscalatorStart),cc.DelayTime:create(self.escalator_time),cc.CallFunc:create(EscalatorEnd))
                GameM.Handler:runAction(seq)
                --清空场景怪物 盒子 金币 buffer列表
                self.spurt_clear = true
            --end
        end
        
                                    
        --上下浮动
        local vec = cc.p(0,100)
        local move = cc.MoveBy:create(0.5,vec)
        local reverse =  move:reverse()
        local seq_moving = cc.Sequence:create(move,reverse)
        
        local s_time = val_time or self.spurt_time
        local spa  = cc.Spawn:create(cc.CallFunc:create(spurtStart),cc.MoveTo:create(1,cc.p(self.ani:getParent():getStdX(),visibleSize_height*3/5)))
        local spa2 = cc.Repeat:create(seq_moving,s_time)--cc.Spawn:create(cc.DelayTime:create(self.magnet_time),cc.Repeat:create(seq_moving,5))
        self.spurt_action = cc.Sequence:create(spa,spa2,cc.CallFunc:create(spurtEnd))
        GameM.Handler:runAction(self.spurt_action)
    end
end


--无敌变大
function meta:Invincible(how_time)
    if not self:GetRoleBig() then
        local showbig = cc.ScaleBy:create(0.5,2)--开始变大
        --self.change_big = 2
        --GameModel.Handler:setScale(1.6)
        local revebig = showbig:reverse()--逆过程
        local function showBig()--变大无敌
            self:SetRoleBig(true)
        end
        local function resumBig()--恢复原来大小
            self:SetRoleBig(false)
        end

        local seq = cc.Sequence:create(
                                    cc.CallFunc:create(showBig),--记录大小 设置变大状态
                                    showbig,--开始变大
                                    cc.DelayTime:create(how_time),--维持时间
                                    revebig,--开始缩小
                                    cc.CallFunc:create(resumBig)--还原大小和 状态
                                    )
        self.ani:getParent():runAction(seq)
    end
end
--补血
function meta:AddHp(add_hp)
    if self.cur_hp >= self.hp then
        --超过上限不加
    else
        self.cur_hp = self.cur_hp+add_hp
        GameSceneUi:setHeroCurBlood(self.cur_hp)
    end
end
--开始闪烁
function meta:Blink_Start(injury)
    
    self:SetBlink(true)

    --[[提莫技能
    if self:GetRoleTag() == ROLE_HERO_ENUM.tm then
          local function OpacityStart()
              self.ani:setOpacity(135)
          end
          local function OpacityEnd()
              self.ani:setOpacity(255)
              self:blink_end()
          end
          local blink = cc.Blink:create(1,10)
          local seq = cc.Sequence:create( blink,cc.CallFunc:create(OpacityStart),cc.DelayTime:create(2),cc.CallFunc:create(OpacityEnd)  )
          self.ani:runAction(seq)
    else
         self.ani:runAction(cc.Sequence:create(cc.Blink:create(1,10),cc.CallFunc:create(MakeScriptHandler(self,self.blink_end)) ))                               
    end
    --]]
    
    self.ani:runAction(cc.Sequence:create(cc.Blink:create(1,10),cc.CallFunc:create(MakeScriptHandler(self,self.blink_end)) ))

    --角色伤血
    if self.cur_hp > 0 then
        self.cur_hp = self.cur_hp - injury
    else
        self.cur_hp = 0
    end

    
    GameSceneUi:setHeroCurBlood(self.cur_hp)

    
end
--闪烁结束回调
--self是观察者(本身)，sender是发送者(发起事件的对象)
function meta:blink_end(sender,...)--事件对象,参数..  此处是sender:调用runAction的那个对象
    
    self:SetBlink(false)--闪烁结束
end
--掉血
function meta:DropHp()
    --[[角色伤血
    if self:GetRoleTag() == ROLE_HERO_ENUM.dm then 
        --盖伦技能
        self.cur_hp = self.cur_hp - 0.3
    else
        self.cur_hp = self.cur_hp - 0.6
    end
    --]]
    self.cur_hp = self.cur_hp - 1
    if self.cur_hp < 0 then
        self.cur_hp = 0
    end
    
    GameSceneUi:setHeroCurBlood(self.cur_hp)
end
--滑翔设置
function meta:GlidingSetting()
    --self:SetRoleGliding(true)
    if not self.gliding_stop then
        local function glidingActionEnd()--滑翔结束
            self:SetRoleGliding(false)
            self.ani:getParent():setVyZero()
        end
        self:SetRoleGliding(true)--设置角色滑翔状态
        self.gliding_stop = true--滑翔中
        self.ani:getParent():setVyZero()
        self.ani:getParent():jumpGliding()
        self.Gliding_Action = cc.Sequence:create(cc.DelayTime:create(self.gliding_time),cc.CallFunc:create(glidingActionEnd))
        self.ani:getParent():runAction(self.Gliding_Action)
    end
end
--滑翔重置
function meta:GlidingReset()
     if self.gliding_stop then
        self.gliding_stop = false--重置滑翔
        self.ani:getParent():stopAction(self.Gliding_Action)--停止动作
     end
end
--子弹回调
function meta:BulletAnimation(bullet)
    --动画事件回调
	local function BulletAnimationEvent(arm, eventType, movmentID)--动画,状态 ,时刻id(动画动作名字)
        --cclog("self.movmentID = " ..movmentID)
		if eventType == ccs.MovementEventType.start then --动画开始时调用

        elseif eventType == ccs.MovementEventType.complete then --动画不循环情况下 完成时调用
            if movmentID == ANIMATION_ENUM.hit then
                local i = 1
                while (i <= #self.bullet_list) do--找不到代表释放了
                    if self.bullet_list[i] == bullet then
                        bullet:removeFromParent(true)
                        table.remove(self.bullet_list,i)
                        break
                    end
                    i = i + 1
                end
            end
        elseif eventType == ccs.MovementEventType.loopComplete then --动画循环情况下不断被调用
            
        end
    end
    bullet:getAnimation():setMovementEventCallFunc(BulletAnimationEvent)--注册动画事件
end
--Teemo毒箭
function meta:TeemoBullet()
    local role_bullet = ccs.Armature:create("Teemo_attack")
    role_bullet:setScale(self.ani:getParent():getScale())
    role_bullet:getAnimation():play(ANIMATION_ENUM.fly)
    local bullet_x = self.ani:getParent():getPositionX()
    local bullet_y = self.ani:getParent():getPositionY()+self.ani:getContentSize().height/3 - 10
    if self:GetRoleBig() then
        bullet_x = self.ani:getParent():getPositionX()
        bullet_y = self.ani:getParent():getPositionY()+self.ani:getContentSize().height/3 +30
    end
    
    role_bullet:setPosition(bullet_x,bullet_y)
    local function disappear()--去到指定距离消失
        --role_bullet:getAnimation():play(ANIMATION_ENUM.fly)
        --self:SetRun()
        local i = 1
        while (i <= #self.bullet_list) do--找不到代表释放了
            if self.bullet_list[i] == role_bullet then
                role_bullet:removeFromParent(true)
                table.remove(self.bullet_list,i)
                --cclog("disappear()")
                break
            end
            i = i + 1
        end
    end
    local taget = ConvertToWorldSpace(self.ani:getParent())
    local move = cc.MoveTo:create(0.3,cc.p(taget.x+self.shoot_range,taget.y+self.ani:getContentSize().height/3))
    local action = cc.Sequence:create(move,cc.CallFunc:create(disappear))
    role_bullet:runAction(action)
    self:BulletAnimation(role_bullet)

    self.ani:getParent():getParent():addChild(role_bullet,OBJECT_RENDER_TAG.bullet)
    table.insert(self.bullet_list,role_bullet)

    playEffect("res/music/effect/role/teemo/Teemo_atchit.ogg")
end
--Ahri子弹
function meta:AhriBullet()
    local role_bullet = ccs.Armature:create("Ahri_attack")
    role_bullet:setScale(self.ani:getParent():getScale())
    role_bullet:getAnimation():play(ANIMATION_ENUM.fly)
    local bullet_x = self.ani:getParent():getPositionX()+self.ani:getContentSize().width
    local bullet_y = self.ani:getParent():getPositionY()+self.ani:getContentSize().height/3 - 10
    if self:GetRoleBig() then
        bullet_x = self.ani:getParent():getPositionX()
        bullet_y = self.ani:getParent():getPositionY()+self.ani:getContentSize().height/3 +30
    end
    role_bullet:setPosition(bullet_x,bullet_y)
    local function disappear()--去到指定距离消失
        --role_bullet:getAnimation():play(ANIMATION_ENUM.fly)
        --self:SetRun()
        local i = 1
        while (i <= #self.bullet_list) do--找不到代表释放了
            if self.bullet_list[i] == role_bullet then
                role_bullet:removeFromParent(true)
                table.remove(self.bullet_list,i)
                break
            end
            i = i + 1
        end
    end
    local taget = ConvertToWorldSpace(self.ani:getParent())
    local move = cc.MoveTo:create(0.3,cc.p(taget.x+self.shoot_range,taget.y+self.ani:getContentSize().height/3))
    local action = cc.Sequence:create(move,cc.CallFunc:create(disappear))
    role_bullet:runAction(action)
    self:BulletAnimation(role_bullet)
    self.ani:getParent():getParent():addChild(role_bullet,OBJECT_RENDER_TAG.bullet)
    table.insert(self.bullet_list,role_bullet)
end
--Ez子弹
function meta:EzBullet()
    local role_bullet = ccs.Armature:create("Ezreal_attack")
    role_bullet:setScale(self.ani:getParent():getScale())
    role_bullet:getAnimation():play(ANIMATION_ENUM.fly)
    local bullet_x = self.ani:getParent():getPositionX()+self.ani:getContentSize().width
    local bullet_y = self.ani:getParent():getPositionY()+self.ani:getContentSize().height/3 - 10
    if self:GetRoleBig() then
        bullet_x = self.ani:getParent():getPositionX()
        bullet_y = self.ani:getParent():getPositionY()+self.ani:getContentSize().height/3 +30
    end
    role_bullet:setPosition(bullet_x,bullet_y)
    local function disappear()--去到指定距离消失
        --role_bullet:getAnimation():play(ANIMATION_ENUM.fly)
        --self:SetRun()
        local i = 1
        while (i <= #self.bullet_list) do--找不到代表释放了
            if self.bullet_list[i] == role_bullet then
                role_bullet:removeFromParent(true)
                table.remove(self.bullet_list,i)
                break
            end
            i = i + 1
        end
    end
    local taget = ConvertToWorldSpace(self.ani:getParent())
    local move = cc.MoveTo:create(0.3,cc.p(taget.x+self.shoot_range,taget.y+self.ani:getContentSize().height/3))
    local action = cc.Sequence:create(move,cc.CallFunc:create(disappear))
    role_bullet:runAction(action)
    self:BulletAnimation(role_bullet)

    self.ani:getParent():getParent():addChild(role_bullet,OBJECT_RENDER_TAG.bullet)
    table.insert(self.bullet_list,role_bullet)
end
--近战击中效果
function meta:MeleeHit(cur_mot_scope)
    if self:GetAtkType() == ROLE_ATK_TYPE.melee then
        local role_hit = nil
        if self.role_tag == ROLE_HERO_ENUM.zx then
            role_hit = ccs.Armature:create("zhaoxin_attack")
        elseif self.role_tag == ROLE_HERO_ENUM.dm then
            role_hit = ccs.Armature:create("Garen_attack")
        elseif self.role_tag == ROLE_HERO_ENUM.js then
            role_hit = ccs.Armature:create("JS_attack")
        end

        if role_hit then
            role_hit:getAnimation():play(ANIMATION_ENUM.hit)
            self.ani:getParent():getParent():addChild(role_hit,99)
            table.insert(self.bullet_list,role_hit)
            self:HitSound()--击中音效
            local bullet_x = cur_mot_scope.x
            local bullet_y = cur_mot_scope.y
            role_hit:setPosition(cur_mot_scope.x,cur_mot_scope.y+cur_mot_scope.height/2)
            self:BulletAnimation(role_hit)
        end
        
    end

end
   
--攻击
function meta:Attack()
    
    ------------------------------提莫------------------------------
    if self.role_tag == ROLE_HERO_ENUM.tm then
        self:TeemoBullet()
    ------------------------------阿狸------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ah then
        self:AhriBullet()
    ------------------------------Ezreal------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ez then
        self:EzBullet()

    ------------------------------赵信------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.zx then
        self:SetAttack()
     ------------------------------盖伦------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.dm then
        self:SetAttack()
    ------------------------------剑圣------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.js then
        self:SetAttack()
    end
   
end

------------------------------------角色控制------------------------------------
--技能按下
function meta:ControlSkill()
     if not self:GetRoleSpurt() then
        ------------------------------提莫------------------------------
        if self.role_tag == ROLE_HERO_ENUM.tm then
            self:Spurt()
         ------------------------------阿狸------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.ah then
            self:Spurt()
        ------------------------------Ezreal------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.ez then
            self:Spurt()
         ------------------------------赵信------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.zx then
            self:Spurt()
        ------------------------------盖伦------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.dm then
            --self:Invincible(4)
            self:Spurt()
         ------------------------------剑圣------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.js then
            self:Spurt()
        end

     end
end
--冲刺按下
function meta:ControlSpurt()
     if not self:GetRoleSpurt() then
        ------------------------------提莫------------------------------
        if self.role_tag == ROLE_HERO_ENUM.tm then
            self:Spurt()
         ------------------------------阿狸------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.ah then
            self:Spurt()
        ------------------------------Ezreal------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.ez then
            self:Spurt()
         ------------------------------赵信------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.zx then
            self:Spurt()
        ------------------------------盖伦------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.dm then
            --self:Invincible(4)
            self:Spurt()
         ------------------------------剑圣------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.js then
            self:Spurt()
        end
     end
end
--转化场景过度冲刺
function meta:ExcessiveSpurt(val_time)
    --cclog("~~~~~~~~~~~~~~ExcessiveSpurt~~~~~~~~~~~~~~~~~~~~~~")

    --if self.spurt_step ~= 0 then
    --    self.spurt_step = 0
    --end
    --self.spurt_step = self.spurt_step + 1--记录切换场景  防止刚好冲刺结束掉落
    ---[[
    --设置角色冲刺状态
    self:SetRoleSpurt(true)
    self:SetRoleMagnet(true)--磁性效果
    GameM:SetGlobalSpeed(15)
    playEffect("res/music/effect/fight/i_rush.ogg")
    --冲刺开始
    local function spurtStart()
        self.sprite_spurt:setVisible(true)
        self:GetAni():getAnimation():play(ANIMATION_ENUM.spurt)
        if self.spurt_action ~= nil then
            GameM.Handler:stopAction(self.spurt_action)
            self.spurt_action = nil
        end
    end
    --冲刺结束
    local function spurtEnd()
        --cclog("~~~~~~~~~~~~~~ExcessiveSpurt   spurtEnd~~~~~~~~~~~~~~~~~~~~~~")
        --self.spurt_step = self.spurt_step - 1
        --if self.spurt_step == 0 then
            self.ani:getParent():setVyZero()--设置竖直速度为0
            self.sprite_spurt:setVisible(false)
            self:SetRoleSpurt(false)--冲刺结束
            self:SetRoleMagnet(false)--磁性效果
            GameM:SetGlobalSpeed(0)
            --触发显示浮梯
            local function EscalatorStart()--浮梯开始
                self:SetRoleEscalator(true)
                --cclog("（（（（浮梯显示）））））")
                --浮梯显示
                for i=1,#GameM.mot_road_list do
                    GameM.mot_road_list[i].ani:setVisible(true)
                end
            end

            local function EscalatorEnd()--浮梯结束
                self:SetRoleEscalator(false)
                --cclog("（（（（浮梯结束）））））")
            end


            local seq = cc.Sequence:create(cc.CallFunc:create(EscalatorStart),cc.DelayTime:create(self.escalator_time),cc.CallFunc:create(EscalatorEnd))

            GameM.Handler:runAction(seq)
            --清空场景怪物 盒子 金币 buffer列表
            self.spurt_clear = true
        --end
    end
                                    
    --上下浮动
    local vec = cc.p(0,100)
    local move = cc.MoveBy:create(0.5,vec)
    local reverse =  move:reverse()
    local seq_moving = cc.Sequence:create(move,reverse)
        
    local s_time = val_time or self.spurt_time
    local spa  = cc.Spawn:create(cc.CallFunc:create(spurtStart),cc.MoveTo:create(1,cc.p(self.ani:getParent():getStdX(),visibleSize_height*3/5)))
    local spa2 = cc.Repeat:create(seq_moving,s_time)--cc.Spawn:create(cc.DelayTime:create(self.magnet_time),cc.Repeat:create(seq_moving,5))
    local seq = cc.Sequence:create(spa,spa2,cc.CallFunc:create(spurtEnd))
    GameM.Handler:runAction(seq)
    --]]
end
--转化场景到奖励模式
function meta:ChangeSceneStart()
    local function setReward()
        GameM:SetGameSetup(GAME_STEP.game_boss)--(GAME_STEP.game_reward)
        GameSceneUi:replaceNormalUI(false)--更换普通UI
        GameSceneButton:replaceNormalButton(false)--更换普通控制
        if GameM.Boss_Handler then
            GameM.Boss_Handler:setVisible(true)
            GameSceneUi.boss_ui_node:setPosition(GameM.Boss_Handler:getPositionX(),GameM.Boss_Handler:getPositionY()+GameM.Boss_Handler:getContentSize().height)
        end
        GameSceneUi.boss_ui_node:setVisible(true)
        GameSceneUi.boss_time_label:setVisible(true)
    end
    local function setGamedata()
        GameM:SetGameSetup(GAME_STEP.game_start)
        GameSceneUi:replaceNormalUI(true)--更换普通UI
        GameSceneButton:replaceNormalButton(true)--更换普通控制
        if GameM.Boss_Handler then
            GameM.Boss_Handler:setVisible(false)
        end
        if GameSceneUi.boss_ui_node then
            GameSceneUi.boss_ui_node:setVisible(false)
        end
        GameSceneUi.boss_time_label:setVisible(false)
    end
    
    --返回普通场景
    if GameM:GetGameSetup() == GAME_STEP.game_boss then--GameM:GetGameSetup() == GAME_STEP.game_reward then
        local fade = self:funcFade(setGamedata,3)
        self:GetAni():getParent():getParent():addChild(fade,OBJECT_RENDER_TAG.fade_layer)
    --进入奖励场景
    elseif GameM:GetGameSetup() == GAME_STEP.game_start then
        local fade = self:funcFade(setReward,1)
        self:GetAni():getParent():getParent():addChild(fade,OBJECT_RENDER_TAG.fade_layer)
    end

    --设置boss死亡时候置换 
    if GameM:getBossDie() then
        GameM:setBossDie(false)
    end  

end
--淡入淡出层
function meta:funcFade(func,val_time)
    local fade_node = cc.LayerColor:create(cc.c4b(255, 255, 255, 255), visibleSize_width, visibleSize_height) --全屏
    fade_node:setVisible(false)
    local function start()--设置显示
        fade_node:setVisible(true)
    end
    local function setSpurt()--设置冲刺
        self:ExcessiveSpurt(val_time)
    end
    local function End()--释放
        fade_node:removeFromParent(true)
    end
    --淡入淡出组合 用于做白色层淡入效果
    local fade_out = cc.FadeOut:create(0.5)
    local fade_in = fade_out:reverse()
    --一边淡人白色层一边冲刺
    local spurt_spa = cc.Spawn:create(fade_out,cc.CallFunc:create(setSpurt))
    --结合淡入淡出逆向才能做出淡入效果
    local seq_fade_in = cc.Sequence:create(spurt_spa,cc.CallFunc:create(start),fade_in)
    local spa = cc.Spawn:create(cc.CallFunc:create(func),cc.DelayTime:create(0.5))
    local seq = cc.Sequence:create(seq_fade_in,spa,fade_out)
    fade_node:runAction(seq)

    return fade_node
end
--攻击按下
function meta:ControlAttack()
    --cclog("ControlAttack1")
    if not self:GetRoleSpurt() then
        --cclog("ControlAttack2")
        ------------------------------提莫------------------------------
        if self.role_tag == ROLE_HERO_ENUM.tm then
            if self:GetRun() then
                self.ani:getAnimation():play(ANIMATION_ENUM.atk)
                --self:SetAttack() 在发射子弹那一刻设置
                --cclog("地面攻击")
                playEffect("res/music/effect/role/teemo/Teemo_attack.ogg")
            elseif self:GetJump1() or self:GetJump2() then
                self.ani:getAnimation():play(ANIMATION_ENUM.jump_atk)
                self:SetAirAttack(true)
                --cclog("空中攻击")
                playEffect("res/music/effect/role/teemo/Teemo_attack.ogg")
            end
            
        ------------------------------阿狸------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.ah then
            if self:GetRun() then
                self.ani:getAnimation():play(ANIMATION_ENUM.atk)
                --self:SetAttack()
                --cclog("地面攻击")
                playEffect("res/music/effect/role/ahri/Ahri_attack.ogg")
            elseif self:GetJump1() or self:GetJump2() or self:GetJump3() or self:GetJump4() then
                self.ani:getAnimation():play(ANIMATION_ENUM.jump_atk)
                self:SetAirAttack(true)
                --cclog("空中攻击")
                playEffect("res/music/effect/role/ahri/Ahri_attack.ogg")
            end
        
        ------------------------------Ezreal------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.ez then
            if self:GetRun() then
                self.ani:getAnimation():play(ANIMATION_ENUM.atk)
                --self:SetAttack()
                --cclog("地面攻击")
                playEffect("res/music/effect/role/ez/Ezreal_attack.ogg")
            elseif self:GetJump1() or self:GetJump2() or self:GetJump3() or self:GetJump4() then
                self.ani:getAnimation():play(ANIMATION_ENUM.jump_atk)
                self:SetAirAttack(true)
                --cclog("空中攻击")
                playEffect("res/music/effect/role/ez/Ezreal_attack.ogg")
            end
         ------------------------------赵信------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.zx then
            --cclog("self:GetRun() =========== " ..tostring(self:GetRun()))
            if self:GetRun() then
                self.ani:getAnimation():play(ANIMATION_ENUM.atk)
                self:Attack()
                if GameM.Boss_Handler then
                    GameM.Boss_Handler:setBossInjured(true)--打boss专用
                end
                --cclog("地面攻击")
                playEffect("res/music/effect/role/zhaoxin/zhaoxi_attack.ogg")
            elseif self:GetJump1() or self:GetJump2() or self:GetJump3() or self:GetJump4() then
                self.ani:getAnimation():play(ANIMATION_ENUM.jump_atk)
                self:SetAirAttack(true)
                if GameM.Boss_Handler then
                    GameM.Boss_Handler:setBossInjured(true)--打boss专用
                end
                --cclog("空中攻击")
                playEffect("res/music/effect/role/zhaoxin/zhaoxi_attack.ogg")
            end

         ------------------------------盖伦------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.dm then
            if self:GetRun() then
                self.ani:getAnimation():play(ANIMATION_ENUM.atk)
                self:Attack()
                if GameM.Boss_Handler then
                    GameM.Boss_Handler:setBossInjured(true)--打boss专用
                end
                --cclog("地面攻击")
                playEffect("res/music/effect/role/garen/Garen_attack.ogg")
            elseif self:GetJump1() or self:GetJump2() or self:GetJump3() or self:GetJump4() then
                self.ani:getAnimation():play(ANIMATION_ENUM.jump_atk)
                self:SetAirAttack(true)
                if GameM.Boss_Handler then
                    GameM.Boss_Handler:setBossInjured(true)--打boss专用
                end
                --cclog("空中攻击")
                playEffect("res/music/effect/role/garen/Garen_attack.ogg")
            end
         ------------------------------剑圣------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.js then
            if self:GetRun() then
                self.ani:getAnimation():play(ANIMATION_ENUM.atk)
                self:Attack()
                if GameM.Boss_Handler then
                    GameM.Boss_Handler:setBossInjured(true)--打boss专用
                end
                --cclog("地面攻击")
                playEffect("res/music/effect/role/js/JS_attack.ogg")
            elseif self:GetJump1() or self:GetJump2() or self:GetJump3() or self:GetJump4() then
                self.ani:getAnimation():play(ANIMATION_ENUM.jump_atk)
                self:SetAirAttack(true)
                if GameM.Boss_Handler then
                    GameM.Boss_Handler:setBossInjured(true)--打boss专用
                end
                
                --cclog("空中攻击")
                playEffect("res/music/effect/role/js/JS_attack.ogg")
            end
        end
    end
    
end

--跳跃按下
function meta:ControlBegan()
    --cclog("ControlBegan")
    --self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.jump then
    if not self:GetRoleSpurt() then
        self:SetIsFloor(false)--腾空
        ------------------------------提莫------------------------------
        if self.role_tag == ROLE_HERO_ENUM.tm then
            if self:GetJump1() then
                self:SetJump2()
                self.ani:getParent():jump2()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump2() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.jump2 then
                --处于二段跳中 无任何操作
                self:GlidingSetting()--滑翔
                
            elseif self:GetRun() or self:GetAttack() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.run then 
                self:SetJump1()
                self.ani:getParent():jump1()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                playEffect("res/music/effect/role/jump.ogg")
            end
        
        ------------------------------阿狸------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.ah then
        
            if self:GetJump1() then
                self:SetJump2()
                self.ani:getParent():jump2()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump2() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.jump2 then
                self:SetJump3()
                self.ani:getParent():jump3()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump3() then
                self:SetJump4()
                self.ani:getParent():jump4()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump4() then
                
                self:GlidingSetting()--滑翔
                
            elseif self:GetRun() or self:GetAttack() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.run then 
                self:SetJump1()
                self.ani:getParent():jump1()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                playEffect("res/music/effect/role/jump.ogg")
            end
        

        ------------------------------赵信------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.zx then
        
            if self:GetJump1() then
                self:SetJump2()
                self.ani:getParent():jump2()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump2() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.jump2 then
                self:SetJump3()
                self.ani:getParent():jump3()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
                
                --处于二段跳中 无任何操作
                --self:GlidingSetting()--滑翔
                
            elseif self:GetRun() or self:GetAttack() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.run then 
                self:SetJump1()
                self.ani:getParent():jump1()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                playEffect("res/music/effect/role/jump.ogg")
            end
        

        ------------------------------Ezreal------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.ez then
       
            if self:GetJump1() then
                self:SetJump2()
                self.ani:getParent():jump2()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump2() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.jump2 then
                self:SetJump3()
                self.ani:getParent():jump3()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump3() then
                self:SetJump4()
                self.ani:getParent():jump4()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump4() then
                
                self:GlidingSetting()--滑翔
                
            elseif self:GetRun() or self:GetAttack() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.run then 
                self:SetJump1()
                self.ani:getParent():jump1()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                playEffect("res/music/effect/role/jump.ogg")
            end
        

         ------------------------------盖伦------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.dm then
       
            if self:GetJump1() then
                self:SetJump2()
                self.ani:getParent():jump2()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump2() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.jump2 then
                self:SetJump3()
                self.ani:getParent():jump3()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
                --处于二段跳中 无任何操作
                --self:GlidingSetting()--滑翔
                
            elseif self:GetRun() or self:GetAttack() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.run then 
                self:SetJump1()
                self.ani:getParent():jump1()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                playEffect("res/music/effect/role/jump.ogg")
            end
        
        ------------------------------剑圣------------------------------
        elseif self.role_tag == ROLE_HERO_ENUM.js then
            if self:GetJump1() then
                self:SetJump2()
                self.ani:getParent():jump2()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump2() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.jump2 then
                self:SetJump3()
                self.ani:getParent():jump3()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump3() then
                self:SetJump4()
                self.ani:getParent():jump4()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump2)
                self:SpriteJump2Ani()
                playEffect("res/music/effect/role/jump2.ogg")
            elseif self:GetJump4() then
                
                self:GlidingSetting()--滑翔
                
            elseif self:GetRun() or self:GetAttack() then--self:GetAni():getAnimation():getCurrentMovementID() == ANIMATION_ENUM.run then 
                self:SetJump1()
                self.ani:getParent():jump1()
                self:GetAni():getAnimation():play(ANIMATION_ENUM.jump)
                playEffect("res/music/effect/role/jump.ogg")
            end
        end
    end
    


end
--跳跃弹起
function meta:ControlEnd()
    --cclog("ControlEnd")

    ------------------------------提莫------------------------------
    if self.role_tag == ROLE_HERO_ENUM.tm then
        if self:GetRoleGliding() then
            self:SetRoleGliding(false)
            self.ani:getParent():setVyZero()
        end
     ------------------------------赵信------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.zx then
        if self:GetRoleGliding() then
            self:SetRoleGliding(false)
            self.ani:getParent():setVyZero()
        end
    ------------------------------盖伦------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.dm then
        if self:GetRoleGliding() then
            self:SetRoleGliding(false)
            self.ani:getParent():setVyZero()
        end
    ------------------------------Ezreal------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ez then
        if self:GetRoleGliding() then
            self:SetRoleGliding(false)
            self.ani:getParent():setVyZero()
        end
    ------------------------------阿狸------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.ah then
        if self:GetRoleGliding() then
            self:SetRoleGliding(false)
            self.ani:getParent():setVyZero()
        end
    ------------------------------剑圣------------------------------
    elseif self.role_tag == ROLE_HERO_ENUM.js then
        if self:GetRoleGliding() then
            self:SetRoleGliding(false)
            self.ani:getParent():setVyZero()
        end
    end
end


--判断上一次是否在路面
function meta:checkPreFloor()
    if self:GetRun() and not self.role_is_floor and not self:GetRoleSpurt() then--平路掉落时候会减少跳跃减少上限
        self:SetJump1()
        self:GetAni():getAnimation():play(ANIMATION_ENUM.jump) 
    end
end
 
--设置动态血瓶出现
function meta:setDynamicHp()
    GameSceneUi:setHeroJiaXie(9999)
end


-------------------------------------------获取与设置属性-------------------------------------------


--获取英雄攻击类型
function meta:GetAtkType()
    return self.atk_type
end

--获取跑步
function meta:GetRun()
    return self.role_type.run
end
--设置跑步(内部处理互斥)
function meta:SetRun()
    self.role_type.run   = true
    self.role_type.jump1 = false
    self.role_type.jump2 = false
    self.role_type.jump3 = false
    self.role_type.jump4 = false
    self.role_type.attack = false
    self.role_type.airattack = false
end
--获取1段跳跃
function meta:GetJump1()
    return self.role_type.jump1
end
--设置1段跳跃(内部处理互斥)
function meta:SetJump1()
    self.role_type.run   = false
    self.role_type.jump1 = true
    self.role_type.jump2 = false
    self.role_type.jump3 = false
    self.role_type.jump4 = false
    self.role_type.attack = false
    self.role_type.airattack = false
end
--获取2段跳跃
function meta:GetJump2()
    return self.role_type.jump2
end
--设置2段跳跃(内部处理互斥)
function meta:SetJump2()
    self.role_type.run   = false
    self.role_type.jump1 = false
    self.role_type.jump2 = true
    self.role_type.jump3 = false
    self.role_type.jump4 = false
    self.role_type.airattack = false
end
--获取3段跳跃
function meta:GetJump3()
    return self.role_type.jump3
end
--设置3段跳跃(内部处理互斥)
function meta:SetJump3()
    self.role_type.run   = false
    self.role_type.jump1 = false
    self.role_type.jump2 = false
    self.role_type.jump3 = true
    self.role_type.jump4 = false
    self.role_type.airattack = false
    --self.role_type.airattack = false
end
--获取4段跳跃
function meta:GetJump4()
    return self.role_type.jump4
end
--设置4段跳跃(内部处理互斥)
function meta:SetJump4()
    self.role_type.run   = false
    self.role_type.jump1 = false
    self.role_type.jump2 = false
    self.role_type.jump3 = false
    self.role_type.jump4 = true
    self.role_type.airattack = false
end
--获取闪烁
function meta:GetBlink()
    return self.role_type.blink
end
--设置闪烁
function meta:SetBlink(is_blink)
   self.role_type.blink = is_blink--闪烁
end
--获取角色状态
function meta:GetRoleType()
    return self.role_type
end
--获取碰撞区
function meta:GetRoleScope()
    return self.scope
end
--获取角色标识
function meta:GetRoleTag()
    return self.role_tag
end
--设置角色标识
function meta:SetRoleTag(role_tag)
    self.role_tag = role_tag
end
--获取角色无敌变大
function meta:GetRoleBig()
    return self.role_type.big
end
--设置角色无敌变大
function meta:SetRoleBig(is_big)
    self.role_type.big = is_big
end
--获取角色上一次是否在路面上
function meta:GetIsFloor()
    return self.role_is_floor
end
--设置角色是否一直都碰到地面
function meta:SetIsFloor(role_is_floor)
    self.role_is_floor = role_is_floor
end
--获取角色获取护盾状态
function meta:GetRoleDun()
    return self.role_type.dun
end
--设置角色获取护盾状态
function meta:SetRoleDun(is_dun)
    self.role_type.dun = is_dun
end
--获取角色获取冲刺状态
function meta:GetRoleSpurt()
    return self.role_type.spurt
end
--设置角色获取冲刺状态
function meta:SetRoleSpurt(is_spurt)
    self.role_type.spurt = is_spurt
end
--获取角色获取磁铁状态
function meta:GetRoleMagnet()
    return self.role_type.magnet
end
--设置角色获取磁铁状态
function meta:SetRoleMagnet(is_magnet)
    self.role_type.magnet = is_magnet
end
--获取角色获取浮梯状态
function meta:GetRoleEscalator()
    return self.role_type.escalator
end
--设置角色获取浮梯状态
function meta:SetRoleEscalator(is_escalator)
    self.role_type.escalator = is_escalator
end
--获取角色滑翔状态
function meta:GetRoleGliding()
    return self.role_type.gliding
end
--设置角色滑翔状态
function meta:SetRoleGliding(is_gliding)
    self.role_type.gliding = is_gliding
end
--获取角色滑翔重置
function meta:GetResetGliding()
    return self.gliding_stop
end
--设置角色滑翔重置
function meta:SetResetGliding(is_gliding_stop)
    self.gliding_stop = is_gliding_stop
end
--获取角色攻击
function meta:GetAttack()
    return self.role_type.attack
end
--设置角色攻击
function meta:SetAttack()
    self.role_type.attack = true
    self.role_type.run    = false
end
--获取角色空中攻击
function meta:GetAirAttack()
    return self.role_type.airattack
end
--设置角色空中攻击
function meta:SetAirAttack(is_airattack)
    self.role_type.airattack = is_airattack
end
--获取角色技能攻击
function meta:GetSkill()
    return self.role_type.is_skill
end
--设置角色技能攻击
function meta:SetSkill(is_skill)
    self.role_type.skill = is_skill
end
--获取角色攻击CD
function meta:GetAttackCD()
    return self.attack_cd
end
--设置角色攻击CD
function meta:SetAttackCD(cd)
    self.attack_cd = cd
end
--获取角色技能CD
function meta:GetSkillCD()
    return self.skill_cd
end
--设置角色技能CD
function meta:SetSkillCD(cd)
    self.skill_cd = cd
end
--获取角色冲刺CD
function meta:GetSpurtCD()
    return self.spurt_cd
end
--设置角色冲刺CD
function meta:SetSpurtCD(cd)
    self.spurt_cd = cd
end
--检查角色是否有暴击
function meta:checkCurt()
    local cirt_percent = Rand:randnum()
    if cirt_percent <= self:GetCrit() then
        return true
    end
    return false
end


return RoleModel

