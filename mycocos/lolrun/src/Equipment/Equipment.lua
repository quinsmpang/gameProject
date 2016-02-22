
---------------------------------目录---------------------------------

---------------------------------初始化
---------------------------------获得装备id
---------------------------------获得装备类型
---------------------------------获得装备有效时间
---------------------------------获得装备品质
---------------------------------获得装备技能id ？？
---------------------------------获得装备生命值
---------------------------------获得装备攻击力
---------------------------------获得装备防御力
---------------------------------获得装备合成所需金币
---------------------------------获得装备合成所需物品s
---------------------------------获得装备 每个背包格子最多数量
---------------------------------获得装备 获取该装备的地图难度，章，节






Equipment = class("Equipment")
Equipment.__index = Equipment



Equipment.id = nil










---------------------------------初始化
--创建装备
function Equipment:create(_id)
  local equipment = Equipment.new() 
  equipment:init(_id)
  return equipment
end 
function Equipment:init(_id)
    self.id = _id
end
---------------------------------获得装备id
function Equipment:getEquipmentId()
    return self.id
end

---------------------------------获得装备类型
function Equipment:getType()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_type ~= "null" then 
                return g_equip_conf[j].ep_type
            else 
                cclog("********** can not find the value **********")
                return nil
            end
        end
    end
    cclog("********** can not find the equipment **********")
end
---------------------------------获得装备有效时间
function Equipment:getEffectTime()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_time ~= "null" then 
                return g_equip_conf[j].ep_time
            else 
                cclog("********** can not find the value **********")
                return nil
            end
        end
    end
    cclog("********** can not find the equipment **********")
end
---------------------------------获得装备品质
function Equipment:getQuality()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_quality ~= "null" then 
                return g_equip_conf[j].ep_quality
            else 
                cclog("********** can not find the value **********")
                return nil
            end
        end
    end
    cclog("********** can not find the equipment **********")
end
---------------------------------获得装备技能id ？？
function Equipment:getSkillId()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_skills ~= "null" then 
                return g_equip_conf[j].ep_skills
            else 
                cclog("********** can not find the value **********")
                return nil
            end
        end
    end
    cclog("********** can not find the equipment **********")
end
---------------------------------获得装备生命值

function Equipment:getLife()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_life ~= "null" then 
                return g_equip_conf[j].ep_life
            else 
                cclog("********** can not find the value **********")
                return nil
            end
        end
    end
    cclog("********** can not find the equipment **********")
end
---------------------------------获得装备攻击力

function Equipment:getAttack()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_attack ~= "null" then 
                return g_equip_conf[j].ep_attack
            else 
                cclog("********** can not find the value **********")
                return nil
            end
        end
    end
    cclog("********** can not find the equipment **********")
end

---------------------------------获得装备防御力
function Equipment:getDefense()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_defense ~= "null" then 
                return g_equip_conf[j].ep_defense
            else 
                cclog("********** can not find the value **********")
                return nil
            end
        end
    end
    cclog("********** can not find the equipment **********")
end
---------------------------------获得装备合成所需金币
function Equipment:getGoldRequireToUpdate()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_upgold ~= "null" then 
                return g_equip_conf[j].ep_upgold
            else 
                cclog("********** can not find the value **********")
                return nil
            end
        end
    end
    cclog("********** can not find the equipment **********")
end
---------------------------------获得装备合成所需物品s
function Equipment:getItemRequireToUpdate()
    local item_table = {}
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            for i = 1,5 do 
                local item_str = string.format("ep_upitem%d",i)
                if g_equip_conf[j][item_str] ~= "null" then
                    table.insert(item_table, 1, g_equip_conf[j][item_str])
                else 
                    return item_table
                end
            end
        end
    end
    cclog("********** can not find the equipment **********")
end

---------------------------------获得装备 每个背包格子最多数量
function Equipment:getCapacityOfItemInUnit()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_max ~= "null" then
                return g_equip_conf[j].ep_max
            else
                return 1            -----注意，如果没有的话，暂定为1
            end
        end
    end
    cclog("********** can not find the equipment **********")
end
---------------------------------获得装备 获取该装备的地图难度，章，节

function Equipment:getMapOfEquitmentExist()
    for j = 2,#g_equip_conf do 
        if g_equip_conf[j].ep_itemid == self.id then
            if g_equip_conf[j].ep_map ~= "null" then
                return g_equip_conf[j].ep_map
            else
                cclog("********** can not find the value **********")
                return nil            -----注意，如果没有的话，暂定为1
            end
        end
    end
    cclog("********** can not find the equipment **********")
end


















