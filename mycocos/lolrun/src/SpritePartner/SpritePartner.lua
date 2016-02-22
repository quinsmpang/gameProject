SpritePartner = class("SpritePartner")
SpritePartner.__index = SpritePartner



-------------------------------- 目录 --------------------------------

--------------------------------创建装备
--------------------------------名字
--------------------------------星级
--------------------------------描述
--------------------------------获得技能cd
--------------------------------是否加金币
--------------------------------是否加经验
--------------------------------是否加血
--------------------------------是否加防御
--------------------------------是否加攻击力
--------------------------------是否复活半价
--------------------------------是否冲刺片刻

SpritePartner.id = nil
SpritePartner.name = nil
SpritePartner.level = nil
SpritePartner.remark = nil
SpritePartner.skcd = nil

--创建装备
function SpritePartner:create(_id)
  local spritepartner = SpritePartner.new() 
  spritepartner:init(_id)
  return spritepartner
end 


function SpritePartner:init(_id)
    self.id = _id
end
--------------------------------名字--------------------------------
function SpritePartner:getName()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            self.name = g_sprite_conf[i].sp_name
            break
        end
    end
    return self.name
end
--------------------------------星级--------------------------------
function SpritePartner:getLevel()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            self.level = g_sprite_conf[i].sp_level
            break
        end
    end
    return self.level
end

--------------------------------描述--------------------------------
function SpritePartner:getRemark()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            self.remark = g_sprite_conf[i].sp_remark
            break
        end
    end
    return self.remark
end

--------------------------------获得技能cd--------------------------------
function SpritePartner:getSkcd()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            self.skcd = g_sprite_conf[i].sp_skcd
            break
        end
    end
    return self.skcd
end

--------------------------------是否加金币--------------------------------
function SpritePartner:isAddGold()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            if g_sprite_conf[i].sp_gold == "null" then 
                return false
            else
                return true
            end
        end
    end
end

--------------------------------是否加经验--------------------------------
function SpritePartner:isAddExp()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            if g_sprite_conf[i].sp_exp == "null" then 
                return false
            else
                return true
            end
        end
    end
end

--------------------------------是否加血--------------------------------
function SpritePartner:isAddLife()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            if g_sprite_conf[i].sp_life == "null" then 
                return false
            else
                return true
            end
        end
    end
end
--------------------------------是否加防御--------------------------------
function SpritePartner:isAddDefense()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            if g_sprite_conf[i].sp_defense == "null" then 
                return false
            else
                return true
            end
        end
    end
end

--------------------------------是否加攻击力--------------------------------
function SpritePartner:isAddAttack()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            if g_sprite_conf[i].sp_attack == "null" then 
                return false
            else
                return true
            end
        end
    end
end
--------------------------------是否复活半价--------------------------------
function SpritePartner:isAddrebirth()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            if g_sprite_conf[i].sp_rebirth == "null" then 
                return false
            else
                return true
            end
        end
    end
end

--------------------------------是否冲刺片刻--------------------------------
function SpritePartner:isPunching()
    for i = 2,#g_sprite_conf do 
        if g_sprite_conf[i].sp_id == self.id then
            if g_sprite_conf[i].sp_punching == "null" then 
                return false
            else
                return true
            end
        end
    end
end

