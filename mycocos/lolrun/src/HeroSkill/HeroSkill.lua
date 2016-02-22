--金恒保佑
HeroSkill = class("HeroSkill")
HeroSkill.__index = HeroSkill



HeroSkill.id = nil

---------------------------------目录---------------------------------

---------------------------------初始化
---------------------------------获得技能id
---------------------------------获取技能名称
---------------------------------获取技能描述
---------------------------------获取技能目标
---------------------------------是否有无敌状态
---------------------------------是否有飞行状态
---------------------------------获取技能图标
---------------------------------获取技能伤害
---------------------------------获取有效时间
---------------------------------获取攻击力加成
---------------------------------是否产生护盾
---------------------------------获取技能增加的生命值
---------------------------------获取技能增加的攻击力
---------------------------------获取技能增加的防御力
---------------------------------获取技能冷却时间
---------------------------------获取成长有效时间
---------------------------------获取成长伤害攻击力加成
---------------------------------获取成长护盾
---------------------------------获取成长生命值
---------------------------------获取成长攻击力
---------------------------------获取成长防御力
---------------------------------获取成长冷却时间


--创建装备
function HeroSkill:create(_id)
  local skill = HeroSkill.new() 
  skill:init(_id)
  return skill
end 

---------------------------------初始化---------------------------------
function HeroSkill:init(_id)
    self.id = _id
end
---------------------------------获得装备id---------------------------------
function HeroSkill:getHeroSkillId()
    return self.id
end




---------------------------------获取技能名称
function HeroSkill:getSkName()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_name ~= "null" then
                return g_heroskill_conf[i].sk_name 
            else 
                return "策划很懒，没有写技能名字"
            end
        end
    end
end

---------------------------------获取技能描述
function HeroSkill:getSkRemark()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_remark ~= "null" then
                return g_heroskill_conf[i].sk_remark 
            else 
                return "策划很懒，没有写描述"
            end
        end
    end
end
---------------------------------获取技能目标
function HeroSkill:getSkTarget()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_target ~= "null" then
                return g_heroskill_conf[i].sk_target 
            else 
                return "策划很懒，没有写技能描述"
            end
        end
    end
end
---------------------------------是否有无敌状态
function HeroSkill:isInvincible()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_Invincible == 0 then 
                return false             
            elseif g_heroskill_conf[i].sk_Invincible ~= "null" then
                return true
            else
                cclog( "策划很懒，无敌状态没有写东西")
                return false
            end
        end
    end
end
---------------------------------是否有飞行状态
function HeroSkill:isFly()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_fly == 0 then 
                return false             
            elseif g_heroskill_conf[i].sk_fly ~= "null" then
                return true
            else
                cclog( "策划很懒，飞行状态没有写东西")
                return false
            end
        end
    end
end
---------------------------------获取技能图标
function HeroSkill:getPic()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_pic ~= "null" then
                return g_heroskill_conf[i].sk_pic
            else
                cclog( "策划很懒，技能图标没有写东西")
                return ""
            end
        end
    end
end
---------------------------------获取技能伤害
function HeroSkill:getSkDamage()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_damage ~= "null" then
                return g_heroskill_conf[i].sk_damage
            else
                cclog( "策划很懒，技能伤害没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取有效时间
function HeroSkill:getEffectTime()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_time ~= "null" then
                return g_heroskill_conf[i].sk_time
            else
                cclog( "策划很懒，技能有效时间没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取攻击力加成
function HeroSkill:getAttackAddition()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_atkdmg ~= "null" then
                return g_heroskill_conf[i].sk_atkdmg
            else
                cclog( "策划很懒，技能加成没有写东西")
                return 0
            end
        end
    end
end
---------------------------------是否产生护盾
function HeroSkill:isHaveShield()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_shield == 0 then 
                return false 
            elseif g_heroskill_conf[i].sk_shield ~= "null" then
                return true
            else
                cclog( "策划很懒，是否产生护盾没有写东西")
                return false
            end
        end
    end
end
---------------------------------获取技能增加的生命值
function HeroSkill:getLife()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_life ~= "null" then
                return g_heroskill_conf[i].sk_life
            else
                cclog( "策划很懒，生命值没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取技能增加的攻击力
function HeroSkill:getAttack()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_attack ~= "null" then
                return g_heroskill_conf[i].sk_attack
            else
                cclog( "策划很懒，攻击力没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取技能增加的防御力
function HeroSkill:getDefense()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_defense ~= "null" then
                return g_heroskill_conf[i].sk_defense
            else
                cclog( "策划很懒，防御力没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取技能冷却时间
function HeroSkill:getCD()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_cd ~= "null" then
                return g_heroskill_conf[i].sk_cd
            else
                cclog( "策划很懒，冷却时间没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取成长有效时间
function HeroSkill:getGrowEffectTime()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_uptime ~= "null" then
                return g_heroskill_conf[i].sk_uptime
            else
                cclog( "策划很懒，冷却时间没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取成长伤害攻击力加成
function HeroSkill:getGrowAttackAddition()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_updamage ~= "null" then
                return g_heroskill_conf[i].sk_updamage
            else
                cclog( "策划很懒，成长伤害攻击力加成没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取成长护盾
function HeroSkill:getGrowShield()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_upshield ~= "null" then
                return g_heroskill_conf[i].sk_upshield
            else
                cclog( "策划很懒，成长护盾没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取成长生命值
function HeroSkill:getGrowLife()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_uplife ~= "null" then
                return g_heroskill_conf[i].sk_uplife
            else
                cclog( "策划很懒，成长护盾没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取成长攻击力
function HeroSkill:getGrowAttack()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_upattack ~= "null" then
                return g_heroskill_conf[i].sk_upattack
            else
                cclog( "策划很懒，成长攻击力没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取成长防御力
function HeroSkill:getGrowDefense()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_updefense ~= "null" then
                return g_heroskill_conf[i].sk_updefense
            else
                cclog( "策划很懒，成长防御力没有写东西")
                return 0
            end
        end
    end
end
---------------------------------获取成长冷却时间
function HeroSkill:getGrowCD()
    for i = 2,#g_heroskill_conf do 
        if g_heroskill_conf[i].sk_id == self.id then 
            if g_heroskill_conf[i].sk_upcd ~= "null" then
                return g_heroskill_conf[i].sk_upcd
            else
                cclog( "策划很懒，成长冷却时间没有写东西")
                return 0
            end
        end
    end
end
