--用于获取表数据对应字段
local ValueTool = 
{
    id             = nil,--id,
    name           = nil,--mot_name,
    res            = nil,--mot_res,
    createType     = nil,--mot_createType,
    monster_tag    = nil,--mot_type,

    attack         = nil,--mot_attack,
    defense        = nil,--mot_defense,
            
    gold           = nil,--mot_gold,
    spurt          = nil,--mot_spurt,
    resumHp        = nil,--mot_resumHp,--回血
    resumMp        = nil,--mot_resumMp,--回蓝
    time           = nil,--mot_time    --持续时间

    scope_x        = nil,--mot_scope_x
    scope_y        = nil,--mot_scope_y
    scope_w        = nil,--mot_scope_w
    scope_h        = nil,--mot_scope_h

    speed_x        = nil,--mot_speed_x
    speed_y        = nil,--mot_speed_y
            
    speed_x        = nil,--mot_speed_x
    speed_y        = nil,--mot_speed_y

    pos_x          = nil,--mot_pos_x
    pos_y          = nil,--mot_pos_y
    render_tag     = nil,--mot_tag怪物渲染层级
    scale          = nil,--mot_scale怪物缩放
    show           = nil--mot_show怪物表现分
}
local meta = ValueTool
ValueTool.__index = ValueTool
--初始化
function meta:init( strPath )

    local self = {}
    setmetatable(self,ValueTool)

    local mot_list = Split(strPath,";")

    self.id             = mot_list[1]--id,
    self.name           = mot_list[2]--mot_name,
    self.res            = mot_list[3]--mot_res,
    self.createType     = mot_list[4]--mot_createType,
    self.monster_tag    = mot_list[5]--mot_type,

    self.attack         = mot_list[6]--mot_attack,
    self.defense        = mot_list[7]--mot_defense,
            
    self.gold           = mot_list[8]--mot_gold,
    self.spurt          = mot_list[9]--mot_spurt,
    self.resumHp        = mot_list[10]--mot_resumHp,--回血
    self.resumMp        = mot_list[11]--mot_resumMp,--回蓝
    self.time           = mot_list[12]--mot_time    --持续时间

    self.scope_x        = mot_list[13]--mot_scope_x
    self.scope_y        = mot_list[14]--mot_scope_y
    self.scope_w        = mot_list[15]--mot_scope_w
    self.scope_h        = mot_list[16]--mot_scope_h

    self.speed_x        = mot_list[17]--mot_speed_x
    self.speed_y        = mot_list[18]--mot_speed_y
    
    self.render_tag     = mot_list[19]--mot_pos_x

    self.scale          = mot_list[20]--mot_scale

    self.show           = mot_list[21]--mot_show

    --x y总是最后
    self.pos_x          = mot_list[#mot_list-1]--mot_pos_x
    self.pos_y          = mot_list[#mot_list]--mot_pos_y
    

    return self
end

function meta:GetId()
    return tonumber(self.id)
end
function meta:GetName()
    return self.name
end
function meta:GetRes()
    return self.res
end
function meta:GetCreateType()
    return tonumber(self.createType)
end
function meta:GetType()
    return tonumber(self.monster_tag)
end
function meta:GetAttack()
    return tonumber(self.attack)
end
function meta:GetDefense()
    return tonumber(self.defense)
end
function meta:GetGold()
    return tonumber(self.gold)
end
function meta:GetSpurt()
    return tonumber(self.spurt)
end
function meta:GetResumHp()
    return tonumber(self.resumHp)
end
function meta:GetResumMp()
    return tonumber(self.resumMp)
end
function meta:GetTime()
    return tonumber(self.scope_w)
end
function meta:GetScopeX()
    return tonumber(self.scope_x)
end
function meta:GetScopeY()
    return tonumber(self.scope_y)
end
function meta:GetScopeW()
    return tonumber(self.scope_w)
end
function meta:GetScopeH()
    return tonumber(self.scope_h)
end
function meta:GetSpeedX()
    return tonumber(self.speed_x)
end
function meta:GetSpeedY()
    return tonumber(self.speed_y)
end
function meta:GetPosX()
    return tonumber(self.pos_x)
end
function meta:GetPosY()
    return tonumber(self.pos_y)
end
function meta:GetMotTag()
    return tonumber(self.render_tag)
end
function meta:GetMotScale()
    return tonumber(self.scale)
end
function meta:GetMotShow()
    return tonumber(self.show)
end

return ValueTool