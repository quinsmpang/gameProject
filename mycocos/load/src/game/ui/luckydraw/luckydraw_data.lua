module('game.ui.luckydraw.luckydraw_data', package.seeall)

local _player = require('game.player')
local _popupTip = require('game.mgr_scr').popupTip
local _tool   = require('util.tool')
---------------data
PRIZE_GOLD         = 1  --金币
PRIZE_BOMB         = 2  --炸弹
PRIZE_INVINCIBLE   = 3  --无敌
PRIZE_RUSH         = 4  --冲刺
PRIZE_FINAL_RUSH   = 5  --最终冲刺
PRIZE_SINGLE       = 6  --单体复活
PRIZE_GROUP        = 7  --群体复活

prize = 
{
    [1] = 
    {   
        --奖励道具
        item = 
        {
            [PRIZE_GOLD]       = 0,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 1,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },

        --权重
        weight = 4,
        tips = "太幸运，逆转成功，马上复活！"
    },
    [2] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 500,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 500,
        tips = "恭喜你，获得500金币"
    },
    [3] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 0,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 2,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 10,
        tips = "真厉害，获得冲刺道具2个"
    },
    [4] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 0,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 1,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 50,
        tips = "真厉害，获得无敌道具1个"
    },
    [5] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 1500,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 110,
        tips = "恭喜你，获得1500金币"
    },
    [6] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 0,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 1,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 5,
        tips = "太棒了，额外获得再冲刺一段距离。"
    },
    [7] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 0,--金币
            [PRIZE_BOMB]       = 2,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 10,
        tips = "真厉害，获得炸弹道具2个"
    },
    [8] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 0,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 1 --群体复活
        },
        
        weight = 1,
        tips = "超级幸运，超级逆转，使用豪华阵容复活！"
    },
    [9] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 0,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 2,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 10,
        tips = "真厉害，获得无敌道具2个"
    },
    [10] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 0,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 1,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 50,
        tips = "真厉害，获得冲刺道具1个"
    },
    [11] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 1000,--金币
            [PRIZE_BOMB]       = 0,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 200,
        tips = "恭喜你，获得1000金币"
    },
    [12] = 
    {   
        item = 
        {
            [PRIZE_GOLD]       = 0,--金币
            [PRIZE_BOMB]       = 1,--炸弹
            [PRIZE_INVINCIBLE] = 0,--无敌
            [PRIZE_RUSH]       = 0,--冲刺
            [PRIZE_FINAL_RUSH] = 0,--最终冲刺
            [PRIZE_SINGLE]     = 0,--单体复活
            [PRIZE_GROUP]      = 0 --群体复活
        },
        
        weight = 50,
        tips = "真厉害，获得炸弹道具1个"
    }
  
}
data =
{
    --gold       --金币
    --bomb       --炸弹
    --invincible --无敌
    --rush       --冲刺
    --final_rush --最终冲刺
    --single     --单体复活
    --group      --群体复活

    --chance     --抽奖机会次数
    --prePoint   --最近一次获得抽奖的关卡
    --firstPoint --第一关奖励特殊对待 0:第一关还没有抽奖 1:第一关已经抽奖了
    --font_tips  --抽奖提示

    --cur_id     --中奖id(索引)
}

---------------function
function init()
    data.cur_id = 0
    data.gold = 0
    data.bomb = 0
    data.invincible = 0
    data.rush = 0
    data.final_rush = 0
    data.single = 0
    data.group = 0
    data.chance = data.chance or 0
    data.prePoint = data.prePoint or 0
    data.firstPoint = data.firstPoint or 0
    data.font_tips = "击杀哥布林有几率获得抽奖币，增加1次机会"
end
function checkLife()
    if data.single ~=0 or data.group ~= 0 then
        --_popupTip("复活啦")
        return true
    end
    return false
end
--得出奖品结果
function calcPrize()
    local weight = _tool.randnum(1,totalWeight())
    return addItem(weight)
end

--增加一次机会
function addChance()
  data.chance = (data.chance or 0) + 1
end

--减少一次机会
function subChance()
    data.chance = data.chance or 0
    if data.chance <= 0 then
        return false
    end
    data.chance = data.chance - 1

    local tmp = require('config').test_data
    if tmp then
        if tmp.lucky.btn then 
            tmp.lucky.btn:setTitleText(tostring(data.chance)) 
        end
    end
    
    return true
end
--是否有机会抽奖
function isStart()
    --cclog("isStart ========= " ..data.chance)
    data.chance = data.chance or 0
    if data.chance == 0 then
        --_popupTip("没有抽奖机会")
        return false
    end
    _popupTip("抽奖开始")
    return true
end
--总权重
function totalWeight()
    local weight = 0
    for i=1,#prize do
        weight = weight + prize[i].weight
    end
    return weight
end
--根据权重增加道具
function addItem(weight)
    local _golds      = _player.get().golds
    local _bomb       = _player.get().items.bomb
    local _invincible = _player.get().items.invincible
    local _rush       = _player.get().items.rush

    local sum = 0
    for i=1,#prize do
        sum = sum + prize[i].weight
        if sum >= weight then
            local add_gold       = prize[i].item[PRIZE_GOLD]
            local add_bomb       = prize[i].item[PRIZE_BOMB]
            local add_invincible = prize[i].item[PRIZE_INVINCIBLE]
            local add_rush       = prize[i].item[PRIZE_RUSH]
            local add_final_rush = prize[i].item[PRIZE_FINAL_RUSH]
            local add_single     = prize[i].item[PRIZE_SINGLE]
            local add_group      = prize[i].item[PRIZE_GROUP]

            _player.get().golds             = _golds      + add_gold
            _player.get().items.bomb        = _bomb       + add_bomb
            _player.get().items.invincible  = _invincible + add_invincible
            _player.get().items.rush        = _rush       + add_rush

            --用于显示抽到的道具
            data.gold                      = data.gold       + add_gold
            data.bomb                      = data.bomb       + add_bomb
            data.invincible                = data.invincible + add_invincible
            data.rush                      = data.rush       + add_rush
            data.final_rush                = data.final_rush + add_final_rush
            data.single                    = data.single     + add_single
            data.group                     = data.group      + add_group
            data.font_tips                 = prize[i].tips

            save()
            
            data.cur_id = i
            cclog("data.cur_id = " ..data.cur_id)
            return true
        end
    end 
    
    return false
    
end
function save()
  _player.setDirty()
  _player.save()
end
function release()
    data.cur_id = 0
    data.gold = 0
    data.bomb = 0
    data.invincible = 0
    data.rush = 0
    data.final_rush = 0
    data.single = 0
    data.group = 0
    data.chance = 0
    data.prePoint = 0
    data.firstPoint = 0
    data.font_tips = ""
end