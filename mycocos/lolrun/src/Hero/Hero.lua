



--[[
 print("英雄id："..timo:getId())
    print("英雄当前等级："..timo:getLevel())
    print("英雄当前经验："..timo:getExp())
    print("英雄名字："..timo:getName())
    print("英雄类型："..timo:getType())
    print("英雄星级："..timo:getStarlevel())
    print("英雄品阶”"..timo:getQualitynum())
    print("英雄当前品阶的最高等级："..timo:getMaxlevel())
    print("英雄初始HP:"..timo:getBaselife())
    print("英雄成长HP:"..timo:getUplife())
    print("英雄初始攻击力:"..timo:getBaseattack())
    print("英雄成长攻击力:"..timo:getUpattack())
    print("英雄暴击率："..timo:getCrit())
    print("英雄技能："..timo:getSkills())
    print("英雄巨人时间："..timo:getGiant())
    print("英雄冲刺时间："..timo:getSprint())
    print("英雄浮梯时间："..timo:getLadder())
    print("英雄磁铁时间："..timo:getMagnet())
    print("英雄最终攻击力:"..timo:getFinalattack())    
    print("英雄最终HP："..timo:getFinallife())  


    ---获取宝箱状态宝箱
    --获取宝箱状态
    getBoxStatus(BOX.bronze_status)
    getBoxStatus(BOX.silver_status)
    getBoxStatus(BOX.gold_status)
    getBoxStatus(BOX.platinum_status)
    getBoxStatus(BOX.boss_1)
    getBoxStatus(BOX.boss_2)
    getBoxStatus(BOX.boss_3)
    getBoxStatus(BOX.boss_4)
--]]




Hero = class("Hero")
Hero.__index = Hero

Hero.data_str         = ""
Hero.id           = nil     --英雄id
Hero.name         = nil     --名字
Hero.level        = nil     --等级
Hero.minLevel     = nil     --最低等级
Hero.exp          = nil     --英雄的经验

Hero.ep_id       ={}        --装备1-6 的id

Hero.ep_isExit     = {}       --装备1-6 是否存在，存在则true


Hero.base_attack       = nil     --基础攻击力
Hero.base_life         = nil     --基础生命值
Hero.base_defense      = nil     --基础抗性

Hero.equip_attack      = nil     --现有装备总攻击力
Hero.equip_life        = nil     --现有装备总生命值
Hero.equip_defense     = nil     --现有装备总抗性

Hero.final_attack      = nil     --最终加成攻击力
Hero.final_life        = nil     --最终加成生命值
Hero.final_defense     = nil     --最终加成抗性


Hero.tbBox             = {}       --记录宝箱状态


----------------------------创建英雄
function Hero:create(id,level,exp)
  local hero = Hero.new() 
  hero:init(id,level,exp)
  return hero
end 

----------------------------初始化
function Hero:init(id,level,exp)
    self.id    = id
    self.level = level
    self.exp   = exp
    --根据 英雄id，等级 初始化装备id
end

-------------------------获取id 
function Hero:getId()
    return self.id
end 

-------------------------获取当前等级 
function Hero:getLevel()
    return self.level    
end 

--------------------------获取当前经验
function Hero:getExp()
    return self.exp
end 

--------------------------获取名称
function Hero:getName()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_name ~= "null" then
                return  g_conf.g_hero_conf[i].hr_name
            else 
                return "null"
            end
        end
    end
end 

----------------------------获取攻击类型
function Hero:getType()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_type
            else
                return "null"
            end
        end
    end
end 

-------------------------获取星级
function Hero:getStarlevel()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_starlevel
            else
                return "null"
            end
        end
    end
end 

-------------------------获取品阶
function Hero:getQualitynum()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_qualitynum
            else
                return "null"
            end
        end
    end
end

-------------------------获取品阶名称
function Hero:getQuality()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_quality
            else
                return "null"
            end
        end
    end
end  

-------------------------获取该品阶等级上限
function Hero:getMaxlevel()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_maxlevel
            else
                return "null"
            end
        end
    end
end  

-------------------------获取初始HP
function Hero:getBaselife()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_life
            else
                return "null"
            end
        end
    end
end  

------------------------获取成长HP
function Hero:getUplife()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_uplife
            else
                return "null"
            end
        end
    end
end 

------------------------获取最终HP
function Hero:getFinallife()
    return  math.ceil(tonumber(self:getBaselife()) + tonumber(self:getUplife()) * tonumber(self:getLevel()))
end 

------------------------获取初始攻击力
function Hero:getBaseattack()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_attack
            else
                return "null"
            end
        end
    end
end

------------------------获取成长攻击力
function Hero:getUpattack()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_upattack
            else
                return "null"
            end
        end
    end
end

------------------------获取最终攻击力
function Hero:getFinalattack()
    return  math.ceil(tonumber(self:getBaseattack()) + tonumber(self:getUpattack()) * tonumber(self:getLevel()))
end 

---------------------获取暴击率
function Hero:getCrit()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_crit
            else
                return "null"
            end
        end
    end   
end 


--------------------获取技能
function Hero:getSkills()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_skills
            else
                return "null"
            end
        end
    end
end 

--------------------获取巨人时间
function Hero:getGiant()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return (g_conf.g_hero_conf[i].hr_giant + g_conf.g_hero_conf[2].hr_giant)
            else
                return "null"
            end
        end
    end
end

--------------------获取冲刺时间
function Hero:getSprint()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return (g_conf.g_hero_conf[i].hr_sprint + g_conf.g_hero_conf[2].hr_sprint)
            else
                return "null"
            end
        end
    end
end

--------------------获取浮梯时间
function Hero:getLadder()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return (g_conf.g_hero_conf[i].hr_ladder + g_conf.g_hero_conf[2].hr_ladder)
            else
                return "null"
            end
        end
    end
end

--------------------获取磁铁时间
function Hero:getMagnet()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return ( g_conf.g_hero_conf[i].hr_magnet + g_conf.g_hero_conf[2].hr_magnet )
            else
                return "null"
            end
        end
    end
end

--------------------获取进阶需要物品
function Hero:getAdvancedgoods()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_advanced_goods
            else
                return "null"
            end
        end
    end
end

--------------------获取进阶需要物品数量
function Hero:getAdvancednum()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_advanced_num
            else
                return "null"
            end
        end
    end
end

--------------------英雄升级
function Hero:upgrade()
    self.level = tostring(tonumber(self.level) + 1)
    return self.level
end 

--------------------获取标志
function Hero:getSymbol()
     for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_symbol
            else
                return "null"
            end
        end
    end
end 

--------------------获取跳跃模式
function Hero:getJump()
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(self.id) then 
            if g_conf.g_hero_conf[i].hr_type ~= "null" then 
                return g_conf.g_hero_conf[i].hr_jump
            else
                return "null"
            end
        end
    end
end 

-----------------------设置宝箱状态
function Hero:setBoxStatus(box_conf)
    --重置宝箱
    Hero:firstSetBoxStatus()
    -- 距离宝箱
    local pass_chest = box_conf.pass_chest
    local pass_gstatus = box_conf.pass_gstatus
    local arrayPass_chest = Split(pass_chest,";")
    local arrayPass_gstatus = Split(pass_gstatus,";")
    -- BOSS宝箱
    local pass_bchest  = box_conf.pass_bchest
    local pass_bstatus = box_conf.pass_bstatus
    local arrayPass_bchest  = Split(pass_bchest,";")
    local arrayPass_bstatus = Split(pass_bstatus,";")

    for key,var in pairs(BOX) do 
        for i =1 , #arrayPass_chest do 
            if var == arrayPass_chest[i] then 
                self.tbBox[var] = arrayPass_gstatus[i]
            end 
        end 

        for i =4+1 , #arrayPass_bchest + 4 do 
            cclog("aa"..(#arrayPass_bchest + 4)..arrayPass_bchest[i-4])
            cclog(arrayPass_bchest[i-4])
            if var == arrayPass_bchest[i-4] then 
                self.tbBox[var] = arrayPass_bstatus[i-4]
            end 
        end 
    end 
    for key,var in pairs(self.tbBox) do 
        cclog("HERO里的",key,var)
    end 
end 

--------------------宝箱状态
function Hero:getBoxStatus(boxName)
    --cclog(self.tbBox[boxName])
    if self.tbBox[boxName]  then 
        return self.tbBox[boxName]
    else 
        return 2
    end 
end

---------------------重置
function Hero:firstSetBoxStatus()
    for key,var in pairs(BOX) do 
         self.tbBox[var] = 2
    end 
end 


-------------------最大HP
function Hero:getMaxHp()
    return  math.ceil(tonumber(self:getBaselife()) + tonumber(self:getUplife()) * 75)
end 

-------------------最大攻击力
function Hero:getMaxAttack()
    return  math.ceil(tonumber(self:getBaseattack()) + tonumber(self:getUpattack()) * 75)
end 

--获取头像路径
function Hero:getNameImageById(id)
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(id) then 
            if g_conf.g_hero_conf[i].hr_rank_heroimage ~= "null" then
                return  g_conf.g_hero_conf[i].hr_rank_heroimage
            else 
                return "null"
            end
        end
    end
end 

--获取名字图片路径
function Hero:getNamePathById(id)
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(id) then 
            if g_conf.g_hero_conf[i].hr_rank_heroname ~= "null" then
                return  g_conf.g_hero_conf[i].hr_rank_heroname
            else 
                return "null"
            end
        end
    end
end 

--获取名字
function Hero:getNameById(id)
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(id) then 
            if g_conf.g_hero_conf[i].hr_name ~= "null" then
                return  g_conf.g_hero_conf[i].hr_name
            else 
                return "null"
            end
        end
    end
end

--获取动画
function Hero:getDonghuaById(id)
    for i = 2,#g_conf.g_hero_conf do 
        if g_conf.g_hero_conf[i].hr_id == tonumber(id) then 
            if g_conf.g_hero_conf[i].hr_donghua ~= "null" then
                return  g_conf.g_hero_conf[i].hr_donghua
            else 
                return "null"
            end
        end
    end
end