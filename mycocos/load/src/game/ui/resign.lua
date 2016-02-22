module('game.ui.resign', package.seeall)

local _tool   = require('util.tool')
local _player = require('game.player')
local _sign = require('game.ui.sign')
local _popupTip = require('game.mgr_scr').popupTip

--奖励类型
ITEM_TYPE = 
{
    GOLD       = 1,--金币
    BOMB       = 2,--炸弹
    INVINCIBLE = 3,--无敌
    RUSH       = 4,--冲刺
    HERO       = 5 --英雄
}

local _resPath = {
    cell = "cell_%d",
    item = "item_%d",
    font = "font_%d",
}

local _data = {
    [1] = {},--{pic = "",scale = ,value = ,gold = 0,bomb = 0,invincible = 0,rush = 0,hero = 0,tp =},
    [2] = {},--{pic = "",scale = ,value = ,gold = 0,bomb = 0,invincible = 0,rush = 0,hero = 0,tp =},
    [3] = {},--{pic = "",scale = ,value = ,gold = 0,bomb = 0,invincible = 0,rush = 0,hero = 0,tp =},
    [4] = {},--{pic = "",scale = ,value = ,gold = 0,bomb = 0,invincible = 0,rush = 0,hero = 0,tp =},
    [5] = {} --{pic = "",scale = ,value = ,gold = 0,bomb = 0,invincible = 0,rush = 0,hero = 0,tp =}
}
--需要补签的数据列表(分一档次 二档次)
local _repair_data = {
    [1] = {},-- 一档 1~3
    [2] = {} -- 二档 4~6
}
local _point = 5--因为有一天是当天  所以需要从5开始才能保证补签天数是1~3 4~6两个档次
local _count = 0--计算总共补签天数计数器
local _font_day = 0--显示补签天数
local cur_level --当前所在档次
--主 次
local function setData(src,des)
    if src.tp == ITEM_TYPE.GOLD then
        src.gold = src.gold + des.gold
    elseif src.tp == ITEM_TYPE.BOMB then
        src.bomb = src.bomb + des.bomb
    elseif src.tp == ITEM_TYPE.INVINCIBLE then
        src.invincible = src.invincible + des.invincible
    elseif src.tp == ITEM_TYPE.RUSH then
        src.rush = src.rush + des.rush
    elseif src.tp == ITEM_TYPE.HERO then
        src.hero = des.hero
    end
end

function init()
    if #_repair_data == 0 or #_repair_data[1] > 5 or #_repair_data[2] > 5 then
        cclog("初始化失败")
    end
--    cclog("#_repair_data[1] ================== " .. #_repair_data[1])
--    cclog("#_repair_data[2] ================== " .. #_repair_data[2])
    _font_day = _count

    for i=1,#_repair_data do
        local _list = _repair_data[i]
        for k,v in ipairs(_list) do
            if v.tp == ITEM_TYPE.GOLD then
                v.pic = "ui/sign/gold.png"
                v.scale = 0.65
                v.value = v.gold
            elseif v.tp == ITEM_TYPE.BOMB then
                v.pic = "ui/battle/icon_bomb.png"
                v.scale = 0.85
                v.value = "x"..v.bomb
            elseif v.tp == ITEM_TYPE.INVINCIBLE then
                v.pic = "ui/battle/icon_invincible.png"
                v.scale = 0.85
                v.value = "x"..v.invincible
            elseif v.tp == ITEM_TYPE.RUSH then
                v.pic = "ui/battle/icon_rush.png"
                v.scale = 0.85
                v.value = "x"..v.rush
            elseif v.tp == ITEM_TYPE.HERO then
                v.pic = "ui/heros/" ..v.hero.. ".png"
                v.scale = 0.55
                v.value = "解锁"
            end
        end
    end
    

end
--关闭补签界面
function close()
    --重置签到数据
    for i=1,7 do
        _player.get().sign.day[i] = _sign.SIGN_TYPE.GET
        _player.get().sign.cur_day = 1
    end

    _player.setDirty()
    _player.save()
end
--领取补签奖励(不包括签到奖励 外部调用回原来接口)
function getResign()
    for k,v in ipairs(_repair_data[cur_level]) do
        if _player.get().sign.day[v.id] == _sign.SIGN_TYPE.OK then
            --_popupTip("异常领过id = " ..v.id)
        else
            v.gold       = v.gold or 0
            v.bomb       = v.bomb or 0
            v.invincible = v.invincible or 0
            v.rush       = v.rush or 0
            v.hero       = v.hero or 0

            --未解锁奖励英雄
            if v.hero ~= 0 and not _player.get().heros_unlock[v.hero] then
                require('game.charge').unconditionalUnlock(v.hero)
            else
            --已解锁奖励金币
                _player.get().golds        = _player.get().golds              + v.gold
            end

            _player.get().items.bomb       = _player.get().items.bomb         + v.bomb
            _player.get().items.invincible = _player.get().items.invincible   + v.invincible
            _player.get().items.rush       = _player.get().items.rush         + v.rush

            _player.get().sign.day[v.id] = _sign.SIGN_TYPE.OK
        end
    end
    _player.setDirty()
    

    _popupTip("补签成功")

end

--数据获取接口
function getFont_day()
    --先暂时这么判断
    if _count >= (_point - 1) then
        if _count == (_point - 1)  then
            return _font_day-1--包含本身
        elseif cur_level == 1 then
            return _font_day
        else
            return _font_day-1--包含本身
        end
    end
    return _font_day - 1--包含本身
end
function getData()
    local _list = _repair_data[cur_level]
    return _list
end
function getRes()
    return _resPath
end
--此接口在init之前就调用 在sign中
function setRepairIndex(_data)
    _count = _count + 1
    local _list = {}
    if _count == _point then
        _repair_data[2] = _tool.copy_table(_repair_data[1])
        _list = _repair_data[2]
        cur_level = 2
    elseif _count > (_point - 1) then
        _list = _repair_data[2]
        cur_level = 2
    else
        _list = _repair_data[1]
        cur_level = 1
    end
    for i=1,#_list do
        if _list[i].tp == _data.tp then
            setData(_list[i],_data)
            return
        end
    end
    table.insert(_list,_data)
end
--总数据列表
function getRepairData()
    return _repair_data
end
--获取档次
function getLevel()
    return cur_level
end
--减少一个档次
function Reduce()
    cur_level = cur_level - 1
    if cur_level <= 1 then
        cur_level = 1
        _font_day = 3 --只有一个档次的时候不会有左按钮 所以当可以减少档次 意味着最少是有2个档次或以上
    end

    return cur_level
end
--增加一个档次
function Add()
    cur_level = cur_level + 1
    if cur_level >= #_repair_data then
        cur_level = #_repair_data
        _font_day = _count
    end

    return cur_level
end
