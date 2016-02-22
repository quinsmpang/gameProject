local MonsterModel = 
{
    
    createType   = nil;--创建类型初始化 1:动画 2:png
    monster_tag  = nil;--怪物类型 MONSTER_TYPE
    monster_type = {};--怪物行为
    scale        = nil;--怪物整体缩放值
    show         = nil;--怪物表现分

    --属性
    gold         = nil;
    spurt        = nil;
    resumHp      = nil;
    resumMp      = nil;
    time         = nil;

    --动态怪物每秒移动距离
    move_time    = nil;--多少秒内移动多少距离
    move_metre   = nil;--移动多少距离
    pre_moveY    = nil;--记录上一次坐标(用于上下移动的物体)


    --浮动地面专用
    floor_action       = false;--上浮或者下沉动作
    up_floor_success   = false;--是否完成上浮
    down_floor_success = false;--是否完成下沉

}
local meta = MonsterModel
local RoleBase = require "src/Base/RoleBase"
setmetatable(meta,RoleBase)--设置类型是RoleBase
meta.__index = meta--表设定为自身

function meta:init( ... )

    local self = {}--初始化自身
    self = RoleBase:init()--将对象自身设定为父类，这个语句相当于其他语言的super
    setmetatable(self, meta)--将对象自身元表设定为MonsterModel类


    --初始化怪物状态
    self.monster_type = 
    {
        run        =  true,--平跑 正常
        boom       =  false,--爆炸 动画爆炸中用到 爆炸完转成die
        die        =  false--死亡 png直接隐藏 然后变成die (出了屏幕的标示  不会马上移除 减少创建开销)
    }
    self.move_time = 0.5
    self.move_metre = 100

    return self
end

-------------------------------------------获取与设置属性-------------------------------------------
--获取跑步
function meta:GetRun()
    return self.monster_type.run
end
--设置跑步(内部处理互斥)
function meta:SetRun()
    self.monster_type.run   = true
    self.monster_type.boom  = false
    self.monster_type.die   = false
end
--获取爆炸 
function meta:GetBoom()
    return self.monster_type.boom
end
--设置爆炸 
function meta:SetBoom()
    self.monster_type.run   = false
    self.monster_type.boom  = true
    self.monster_type.die   = false
end
--获取死亡
function meta:GetDie()
    return self.monster_type.die
end
--设置死亡
function meta:SetDie(is_die)
    if is_die then
        self.monster_type.run   = false
        self.monster_type.boom  = false
        self.monster_type.die   = is_die
        --self.ani:setVisible(false)
    else
        self.monster_type.run   = true
        self.monster_type.boom  = false
        self.monster_type.die   = is_die
        --self.ani:setVisible(true)
    end
    
end
--设置怪物类型
function meta:GetMonsterTag()
    return self.monster_tag
end


return MonsterModel

