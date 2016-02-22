Consumer = class("Consumer")
Consumer.__index = Consumer



Consumer.id = nil

---------------------------------目录---------------------------------

---------------------------------初始化
---------------------------------获得消耗品id
---------------------------------获得消耗品攻击力
---------------------------------获得消耗品防御力
---------------------------------获得消耗品生命值
---------------------------------获得消耗品价值金币多少钱
---------------------------------获得消耗品价值钻石多少钱
---------------------------------获得消耗品 在背包里的一个格子存个最大数量
---------------------------------获得消耗品的出现的 章节（带难度）


--创建消耗品
function Consumer:create(_id)
  local consumer = Consumer.new() 
  consumer:init(_id)
  return consumer
end 

---------------------------------初始化---------------------------------
function Consumer:init(_id)
    self.id = _id
end
---------------------------------获得消耗品id---------------------------------
function Consumer:getConsumerId()
    return self.id
end

---------------------------------获得消耗品攻击力---------------------------------

function Consumer:getAttack()
    for i = 2,#g_consumer_conf do 
        if g_consumer_conf[i].cs_itemid == self.id then
            if g_consumer_conf[i].cs_attack ~= "null" then 
                return g_consumer_conf[i].cs_attack
            else
                return 0
            end
        end
    end
    cclog("********** can not find the Consumer **********")
end

---------------------------------获得消耗品防御力---------------------------------
function Consumer:getDefense()
    for i = 2,#g_consumer_conf do 
        if g_consumer_conf[i].cs_itemid == self.id then
            if g_consumer_conf[i].cs_defense ~= "null" then 
                return g_consumer_conf[i].cs_defense
            else
                return 0
            end
        end
    end
    cclog("********** can not find the Consumer **********")
end

---------------------------------获得消耗品生命值---------------------------------

function Consumer:getLife()
    for i = 2,#g_consumer_conf do 
        if g_consumer_conf[i].cs_itemid == self.id then
            if g_consumer_conf[i].cs_life ~= "null" then 
                return g_consumer_conf[i].cs_life
            else
                return 0
            end
        end
    end
    cclog("********** can not find the Consumer **********")
end

---------------------------------获得消耗品价值金币多少钱---------------------------------
function Consumer:getValueOfGold()
    for i = 2,#g_consumer_conf do 
        if g_consumer_conf[i].cs_itemid == self.id then
            if g_consumer_conf[i].cs_gold ~= "null" then 
                return g_consumer_conf[i].cs_gold
            else
                return 0
            end
        end
    end
    cclog("********** can not find the Consumer **********")
end

---------------------------------获得消耗品价值钻石多少钱---------------------------------
function Consumer:getValueOfDiamond()
    for i = 2,#g_consumer_conf do 
        if g_consumer_conf[i].cs_itemid == self.id then
            if g_consumer_conf[i].cs_diamonds ~= "null" then 
                return g_consumer_conf[i].cs_diamonds
            else
                return 0
            end
        end
    end
    cclog("********** can not find the Consumer **********")
end

---------------------------------获得消耗品 在背包里的一个格子存个最大数量---------------------------------
function Consumer:getCapacityOfItemInUnit()
    for i = 2,#g_consumer_conf do 
        if g_consumer_conf[i].cs_itemid == self.id then
            if g_consumer_conf[i].cs_max ~= "null" then 
                return g_consumer_conf[i].cs_max
            else
                return 1        --这里暂时写默认1
            end
        end
    end
    cclog("********** can not find the Consumer **********")
end

---------------------------------获得消耗品的出现的 章节（带难度）---------------------------------


function Consumer:getMapOfEquitmentExist()
    for i = 2,#g_consumer_conf do 
        if g_consumer_conf[i].cs_itemid == self.id then
            if g_consumer_conf[i].cs_map ~= "null" then 
                return g_consumer_conf[i].cs_map
            else
                cclog("********** sorry! no remark **********")
                return  nil     --这里暂时写默认1
            end
        end
    end
    cclog("********** can not find the Consumer **********")
end




