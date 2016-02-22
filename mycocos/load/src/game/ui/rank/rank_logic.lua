module('game.ui.rank.rank_logic', package.seeall)

local _player = require('game.player')
local _tool   = require('util.tool')
local _popupTip = require('game.mgr_scr').popupTip
local _rank_data = require('game.ui.rank.rank_data')
local _robot = require('game.ui.rank.robot')

rank = 
{
 index = 1,--机器人取名字用的索引
 [_rank_data.NOVICE] = {},
 [_rank_data.BRONZE] = {},
 [_rank_data.SILVER] = {},
 [_rank_data.GOLD]     = {},
 [_rank_data.PLATINUM] = {},
 [_rank_data.DIAMOND] = {}
}

--初始化组数据
local function initGroup(rank_type,_sum)
    local tab = {}
    local number = 1
    local robot_data = _tool.randomforSum(#_robot.robot,_sum)
    for i=1,#_rank_data.ruler[rank_type] do
        local d = _rank_data.ruler[rank_type][i]
        local t = _tool.randomforSumEx(d.score_max,
                                    d.rank_max - d.rank_min + 1,
                                    d.score_min)
        
        
        --分数高到低
        for j=#t,1,-1 do
            local info = {}
            info.number = number
            info.score = t[j]
            info.gold = d.gold
            info.group = d.group
            info.name = _robot.robot[robot_data[rank.index]].name
            table.insert(tab,info)
            
            number = number + 1
            rank.index = rank.index + 1
        end

    end

    
    return tab
end
--初始化排行榜数据
function init(update_group)
    --外部控制_player.get().rank.update是否需要刷新
    rank.index = 1
    local group = 6--6组
    local sum = 50--每组50
    if _player.get().rank.update then
        --cclog("=======================刷新数据=======================")
         --[[名字默认是 "我" 所以无需做这部
        if _player.get().rank.info.name then--排除角色名字在外
            local i = 1
            while (i<=#_robot.robot) do
                if _robot.robot[i].name == _player.get().rank.info.name then
                    --cclog("移除--------------》》》》》》》》》》》》" .._robot.robot[i].name)
                    table.remove(_robot.robot,i)
                    break
                end
                i = i + 1
            end
        end
        --]]
       --刷新数据
       for i=1,group do
           rank[i] = initGroup(i,group*sum)--索引就是类型
           _player.get().rank[i] = rank[i]
       end
    else
--        cclog("=======================无需刷新则从本地数据读取=======================")
--        cclog("_player.get().rank.info.name ================== " .._player.get().rank.info.name)
--        cclog("_player.get().rank.info.number ================== " .._player.get().rank.info.number)
--        cclog("_player.get().rank.info.score ================== " .._player.get().rank.info.score)
--        cclog("_player.get().rank.info.group ================== " .._player.get().rank.info.group)
        --无需刷新则从本地数据读取
        for i=1,group do
            rank[i] = _player.get().rank[i]
--            if i == 1 then
--                for j=1,#rank[i] do
--                    cclog("rank["..i.."]["..j.."].name=====" ..rank[i][j].name .."----score-----"..rank[i][j].score.."----number-----"..rank[i][j].number)
--                end
--            end
        end
        return
    end
    --不是第一天登录则插入数据到机器人中
    if not _player.get().rank.first then
        --cclog("=======================不是第一天登录则插入数据到机器人中=======================")
        if not _player.get().rank.info.name then--没名字一律不处理
            _popupTip("您还没取名")
            return
        end
        --初始化类型
        local _rank_type = _player.get().rank.info.rank_type
        if initInfo(_rank_type) then
            rank[_rank_data.NOVICE][#rank[_rank_data.NOVICE]] = _player.get().rank.info--覆盖最后一名机器人
            save()
            return
        end

        --是否更新组
        if update_group then
            if _player.get().rank.info.group == _rank_data.GROUP_UP then--升组区
                _rank_type = _rank_type + 1
            elseif _player.get().rank.info.group == _rank_data.GROUP_DOWN then--降组区
                _rank_type = _rank_type - 1
            else
                --不变
            end
        end
        
        --防止越界 一般情况下不可能出现以下情况
        if _rank_type <= _rank_data.NOVICE then
            _rank_type = _rank_data.NOVICE
        elseif _rank_type >= _rank_data.DIAMOND then
            _rank_type = _rank_data.DIAMOND
        end
        --cclog("_player.get().rank.info.score ================= " .._player.get().rank.info.score)
        local record = #rank[_rank_type]--默认是最后一名
        for k,v in ipairs(rank[_rank_type]) do
            if _player.get().rank.info.score >= v.score or k == record then
                --record = k--记录当前排名 k和number相同
                _player.get().rank.info.rank_type = _rank_type
                _player.get().rank.info.number = v.number
                _player.get().rank.info.gold = v.gold
                _player.get().rank.info.group = v.group
                v.score = _player.get().rank.info.score
                v.name  = _player.get().rank.info.name
--                cclog("_player.get().rank.info.name ================== " .._player.get().rank.info.name)
--                cclog("_player.get().rank.info.rank_type ================== " .._player.get().rank.info.rank_type)
--                cclog("_player.get().rank.info.number ================== " .._player.get().rank.info.number)
--                cclog("_player.get().rank.info.score ================== " .._player.get().rank.info.score)
--                cclog("_player.get().rank.info.group ================== " .._player.get().rank.info.group)
                break
            end
        end

        save()
        return
    end


end
--取名
function setName(name)
    if not name then
        _popupTip("名字不能为空")
        return false
    end

    local role_name = _player.get().rank.info.name
    if role_name then
        _popupTip("已取名")
        return false
    end

    _player.get().rank.info.name = name
    save()

    return true
end
function initInfo(_rank_type)
    --初始化类型
    if not _rank_type then
        _player.get().rank.info.rank_type = _rank_data.NOVICE--初始化为新手组
        _player.get().rank.info.number = _rank_data.ruler[_rank_data.NOVICE][#_rank_data.ruler[_rank_data.NOVICE]].rank_max
        _player.get().rank.info.gold = _rank_data.ruler[_rank_data.NOVICE][#_rank_data.ruler[_rank_data.NOVICE]].gold
        _player.get().rank.info.score = 0
        _player.get().rank.info.group = _rank_data.GROUP_FLAT
        
        return true
    end

    return false
end
--重置奖励
function resetGift()
    _player.get().rank.gift.rank_type   = _player.get().rank.info.rank_type
    _player.get().rank.gift.number      = _player.get().rank.info.number
    _player.get().rank.gift.gold        = _player.get().rank.info.gold
    _player.get().rank.gift.play        = _player.get().rank.play
    _player.get().rank.play             = false
    if _player.get().rank.gift.play then--至少进入过一次战斗
        _player.get().rank.gift.isget = _rank_data.GIFT_GET
    else
        _player.get().rank.gift.isget = _rank_data.GIFT_NO
    end
    save()
end
--重置成绩(奖励显示和排名显示是分开显示 需要区分)
function reset()
    --重置前刷新奖励领取数据(覆盖上一次奖励)
--    if not _player.get().rank.first then--非第一天登录才赋值奖励数据
--        resetGift()
--    end
    
    _player.get().rank.info.score     = 0

    save()
end
--检查是否需要刷新
function checkUpdate()
    local _is_update,tday = _tool.checkday(_tool.UPDATE_TYPE.rank)

    --异常
    if tday == nil then
        return false
    end

    if _is_update then
         --第一次登录
        if tday <= 0 then--如果同一天在下面处理  所以这里可以为0
            _player.get().rank.first = true
            _player.get().rank.update = true
            initInfo()
            init()
            save()
        elseif tday == 1 then
            if require('config').test_data then 
                _player.get().rank_day = _player.get().rank_day - 1 
            end
            _player.get().rank.first = false
            _player.get().rank.update = true
            resetGift()
            init(true)
            reset()
        else
            --tday>=2
            if require('config').test_data then  
                _player.get().rank_day = _player.get().rank_day - 1
            end
            _player.get().rank.first = false
            --_player.get().rank.update = true
            resetGift()
            init(true)
            reset()
        end
    else
        --同一天
        if _player.get().rank.first then
            _player.get().rank.first = false
            _player.get().rank.update = true
        end
        init()
    end

    local tmp = require('config').test_data
    if tmp and tmp.rank.btn then
        tmp.rank.btn:setTitleText(tostring(_player.get().rank_day)) 
    end

    return true
    
    
end
function getGift(unlock_id)
    if _player.get().rank.gift.isget == _rank_data.GIFT_GET then
        if not unlock_id then
            local golds = _player.get().golds
            golds = golds + _player.get().rank.gift.gold
        else
            --解锁对应英雄(难看了点。。。)
            require('game.charge').unconditionalUnlock(unlock_id)
        end
        _player.get().rank.gift.isget = _rank_data.GIFT_OK
        save()
    end
    
end
function battleResult(score)
  local ud = _player.get()
  ud.rank.info.score = ud.rank.info.score or 0
  ud.rank.refresh = ud.rank.refresh or 0
  if score > ud.rank.info.score then
    ud.rank.refresh = 0
    ud.rank.info.score = score
    _player.setDirty()
  else
    --累计没有刷新次数
    if ud.rank.refresh then
        if ud.rank.refresh < _rank_data.REFRESH then
          ud.rank.refresh = ud.rank.refresh + 1
        else
          ud.rank.update = true
        end
        _player.setDirty()
    else
        ud.rank.refresh = ud.rank.refresh or 1
        _player.setDirty()
    end
  end
   checkUpdate()--刷新一下排行榜
end
function save()
  _player.setDirty()
  _player.save()
end

function check(rank)
  local dirty = false
  
  if type(rank) ~= 'table' then
    rank, dirty = {}, true
  end
  if type(rank[_rank_data.NOVICE]) ~= 'table' then
    rank[_rank_data.NOVICE], dirty = {}, true
  end
  if type(rank[_rank_data.BRONZE]) ~= 'table' then
    rank[_rank_data.BRONZE], dirty = {}, true
  end
  if type(rank[_rank_data.SILVER]) ~= 'table' then
    rank[_rank_data.SILVER], dirty = {}, true
  end
  if type(rank[_rank_data.GOLD]) ~= 'table' then
    rank[_rank_data.GOLD], dirty = {}, true
  end
  if type(rank[_rank_data.PLATINUM]) ~= 'table' then
    rank[_rank_data.PLATINUM], dirty = {}, true
  end
  if type(rank[_rank_data.DIAMOND]) ~= 'table' then
    rank[_rank_data.DIAMOND], dirty = {}, true
  end
  if type(rank.first) ~= 'boolean' then
    rank.first, dirty = true, true
  end
  if type(rank.update) ~= 'boolean' then
    rank.update, dirty = true, true
  end
  if type(rank.last_time) ~= 'number' then
    rank.last_time, dirty = nil, true
  end
  if type(rank.play) ~= 'boolean' then
    rank.play, dirty = false, true
  end
  --个人
  if type(rank.info) ~= 'table' then
    rank.info, dirty = {}, true
    rank.info.name = "我"--默认名字(取消了取名界面)
  end

  --奖励数据
  if type(rank.gift) ~= 'table' then
    rank.gift, dirty = {}, true
  end

  
  return rank, dirty
end
