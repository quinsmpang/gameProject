local RoleBase = 
{
   id               = 0;
   ani              = nil;--动画对象/png对象
   name             = nil;--名字
   res              = nil;--动画名称(用于创建动画对象)/XX.png
   createType       = nil;--创建类型 1:动画创建 2:png创建
   Type             = nil;--角色/怪物 状态:1;--平跑 正常 2;--跳跃上升...
   
   --初始位置
   pos_x            = nil;--x
   pos_y            = nil;--y

   --碰撞范围
   scope_x          = 0;--锚点x
   scope_y          = 0;--锚点y
   scope_w          = 50;--宽(往右)
   scope_h          = 50;--高(网上)
   --bone = nil;--骨骼名字(帧动画目前默认1个骨骼) 用于获取每帧动画位置

   --碰撞偏移量
   scope_pos_x      = 0;
   scope_pos_y      = 0;

   --属性
   cur_hp           = nil;--当前血量
   hp               = nil;--血量
   attack           = nil;--攻击
   defense          = nil;--防御
   crit             = nil;--暴击率
   speed_x          = nil;--x速度(向前移动的速度)/怪物:相对速度
   speed_y          = nil;--y方向速度

   glNode           = nil;--画碰撞区域用


}
local meta = RoleBase

meta.__index = meta--没有这句话 此类不能被继承
--require "Opengl"--用于画图

--引用和全局，初始化----------------------------------------------------------------------------------
function meta:init( ... )
    
   
    local self = {}--初始化self，如果没有这句，那么类所建立的对象改变，其他对象都会改变
    setmetatable(self,meta)  --将self的元表设定为RoleBase

    --self.glNode = cc.DrawNode:create()--gl.DrawNode()--画笔

    return self --返回自身

end
function meta:GetId()
    return self.id
end
function meta:GetAni()
    return self.ani
end
function meta:GetRes()
    return self.res
end
function meta:GetCreateType()
    return tonumber(self.createType)
end
function meta:GetPosX()
    return tonumber(self.pos_x)
end
function meta:GetPosY()
    return tonumber(self.pos_y)
end
function meta:GetScope()
    local rect = {x = tonumber(self.scope_x),y = tonumber(self.scope_y),width = tonumber(self.scope_w),height = tonumber(self.scope_h)}
    return rect
end
function meta:GetDataAttack()
    return tonumber(self.attack)
end
function meta:GetDataDefense()
    return tonumber(self.defense)
end
function meta:GetSpeedX()
    return tonumber(self.speed_x)
end
function meta:GetSpeedY()
    return tonumber(self.speed_y)
end
function meta:GetHp()
    return tonumber(self.hp)
end
function meta:SetHp(hp)
    self.hp = hp
    return tonumber(self.hp)
end
function meta:GetCurHp()
    return tonumber(self.cur_hp)
end
function meta:SetCurHp(cur_hp)
    self.cur_hp = cur_hp
    return tonumber(self.cur_hp)
end
function meta:GetScopeX()
    return self.scope_x
end
function meta:GetScopeY()
    return self.scope_y
end
function meta:GetScopeWidth()
    return self.scope_w
end
function meta:GetScopeHeight()
    return self.scope_h
end
function meta:SetScopeWidth(scope_w)
    self.scope_w = scope_w
end
function meta:SetScopeHeight(scope_h)
    self.scope_h = scope_h
end
function meta:SetScopePosX(scope_pos_x)
    self.scope_pos_x = scope_pos_x
end
function meta:SetScopePosY(scope_pos_y)
    self.scope_pos_y = scope_pos_y
end
function meta:GetScopePosX()
    return self.scope_pos_x
end
function meta:GetScopePosY()
    return self.scope_pos_y
end
function meta:GetCrit()
    return self.crit
end

return RoleBase

