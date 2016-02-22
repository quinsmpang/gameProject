module('game.ui.sign', package.seeall)

local _player = require('game.player')
local _popupTip = require('game.mgr_scr').popupTip
local _tool   = require('util.tool')
local _charge_data = require('data.charge')
local _resign = require('game.ui.resign')

MSG_UNCONNECT  = -100 --无法连接服务器
MSG_QUTIMEOUT  = -200 --请求超时
MSG_POTIMEOUT  = -300 --响应超时
MSG_NETWORKER  = -400 --网络异常


SIGN_TYPE = {
   NO     = 1,       --不可领取
   GET    = 2,      --可领取 但未领取
   OK     = 3,       --已领取
   REPAIR = 4    --补签
}

local s = string.format

local _CLR_GRAY = {r=174,g=174,b=174}

local _data = 
{
    --    编号    金币         炸弹           无敌      冲刺     解锁英雄id     类型(补签需要识别)
    [1] = {id = 1,gold = 500,   bomb = 0,invincible = 0,rush = 0,hero = 0,    tp = _resign.ITEM_TYPE.GOLD},
    [2] = {id = 2,gold = 0,     bomb = 2,invincible = 0,rush = 0,hero = 0,    tp = _resign.ITEM_TYPE.BOMB},
    [3] = {id = 3,gold = 2000,  bomb = 0,invincible = 0,rush = 0,hero = 0,    tp = _resign.ITEM_TYPE.GOLD},
    [4] = {id = 4,gold = 0,     bomb = 0,invincible = 2,rush = 0,hero = 0,    tp = _resign.ITEM_TYPE.INVINCIBLE},
    [5] = {id = 5,gold = 5000,  bomb = 0,invincible = 0,rush = 0,hero = 0,    tp = _resign.ITEM_TYPE.GOLD},
    [6] = {id = 6,gold = 0,     bomb = 0,invincible = 0,rush = 2,hero = 0,    tp = _resign.ITEM_TYPE.RUSH},
    [7] = {id = 7,gold = 100000,bomb = 0,invincible = 0,rush = 0,hero = 14001,tp = _resign.ITEM_TYPE.HERO},
}

local _resPath =
{
    hight_bg  = "ui/sign/hight_bg.png",
    hight_di  = "ui/sign/di_hight.png",
    hight_num = "ui/sign/day_%d_hight.png",
    height_day= "ui/sign/day_hight.png",
    gold      = "ui/sign/gold.png",
}

local _is_repair--是否为补签按钮
function getRepair()
    return _is_repair
end

function init(panel,tday)
    if not panel then
        return
    end
    _is_repair = false
    local cur_day = _player.get().sign.cur_day
    for i=1,#_data do
        --cclog("_player.get().sign.day[" ..tostring(i) .."]===" ..tostring(_player.get().sign.day[i]))
        local bg       = ccui.Helper:seekNodeByNameOnNode(panel, s("bg_%d",i))--高亮背景
        local hight_bg = ccui.Helper:seekNodeByNameOnNode(panel, s("hight_%d",i))--高亮透明
        if i == cur_day then
            bg:setSpriteFrame(_resPath.hight_bg)
            hight_bg:setVisible(true)
            local day_font_di   = ccui.Helper:seekNodeByNameOnNode(panel, s("day_font_di_%d",i))--第
            local day_font      = ccui.Helper:seekNodeByNameOnNode(panel, s("day_font_%d",i))--n
            local day_font_tian = ccui.Helper:seekNodeByNameOnNode(panel, s("day_font_tian_%d",i))--天
            day_font_di:setSpriteFrame(_resPath.hight_di)
            day_font:setSpriteFrame(s(_resPath.hight_num,i))
            day_font_tian:setSpriteFrame(_resPath.height_day)
            if _is_repair then--出现补签情况把本次签到奖励也算进去
                _resign.setRepairIndex(_data[i])
            end
        elseif i > cur_day then
            hight_bg:setVisible(false)
        else
            --小于当前天
            if _player.get().sign.day[i] ~= SIGN_TYPE.OK then
                _player.get().sign.day[i] = SIGN_TYPE.REPAIR
                _is_repair = true
                _resign.setRepairIndex(_data[i])
            end
        end
        local day_get  = ccui.Helper:seekNodeByNameOnNode(panel, s("day_get_%d",i))
        if _player.get().sign.day[i] == SIGN_TYPE.OK then
            --已领取
            day_get:setVisible(true)
            bg:setColor(_CLR_GRAY)
        elseif _player.get().sign.day[i] == SIGN_TYPE.REPAIR then
            --补签
            day_get:setSpriteFrame("ui/sign/resign_icon.png")
            local _pos = cc.p(day_get:getPosition())
            day_get:setPosition(cc.p(_pos.x+30,_pos.y+30))
        else
            --未领取 SIGN_TYPE.NO
            --可领取 SIGN_TYPE.GET
            day_get:setVisible(false)
        end
    end

    if _player.get().heros_unlock[11001] or _player.get().heros_unlock[14001] then
        --已解锁
        local item = ccui.Helper:seekNodeByNameOnNode(panel, "day_item_7")
        item:setSpriteFrame(_resPath.gold)
        item:setScale(ccui.Helper:seekNodeByNameOnNode(panel, "day_item_1"):getScaleX())--用金币图缩放大小
        local _font = ccui.Helper:seekWidgetByNameOnNode(panel:getChildByName('bg_7'), 'day_gold_7')
        _font:setString(tostring(_data[7].gold))
    else
        
    end

    if _is_repair then
        local _public_btn_yellow = panel:getChildByName('public_btn_yellow')
        local _btn_font = _public_btn_yellow:getChildByName("btn_font")
        _public_btn_yellow:setSpriteFrame("ui/public/public_btn_green_new.png")
        _btn_font:setSpriteFrame("ui/sign/resign_font.png")
        _btn_font:setPosition(cc.p(_public_btn_yellow:getContentSize().width/2,_public_btn_yellow:getContentSize().height/2))
    end

end

function reset(panel)
    if not panel then
        return
    end
    --重置
    for i=1,#_data do
        _player.get().sign.day[i] = SIGN_TYPE.GET
        _player.get().sign.cur_day = 1
        local hight_bg = ccui.Helper:seekNodeByNameOnNode(panel, s("hight_%d",i))
        local day_get  = ccui.Helper:seekNodeByNameOnNode(panel, s("day_get_%d",i))
        hight_bg:setVisible(false)
        day_get:setVisible(false)
    end
end

--检查是否显示签到
function checkSign(panel)
    local _is_update,tday = _tool.checkday(_tool.UPDATE_TYPE.sign)
    --cclog("checkSign->tday ============ " ..tostring(tday))
    --异常
    if tday == nil then
        cclog("异常")
        return false
    end

    if _is_update then
         --第一次登录
        if tday < 0 then
            reset(panel)--_player.get().sign.cur_day = 1
            init(panel)
            save()
        
        elseif tday == 1 then
            add(panel)
            init(panel)
            save()
        else
            --tday>=2
            addEx(tday)
            init(panel)
            save()
        end
        
    else
        --同一天
        init(panel)

         --当天是否已经领取
        local cur_day = _player.get().sign.cur_day
        if _player.get().sign.day[cur_day] == SIGN_TYPE.OK then
            _popupTip("您今天已经签过到")
            return false
        end
    end

    _popupTip("开始签到")
    return true

end
function add(panel)
    local cur_day = _player.get().sign.cur_day
    if cur_day + 1 > #_data then
        reset(panel)
    else
        _player.get().sign.cur_day = cur_day + 1
    end
end
function addEx(dt)
    local cur_day = _player.get().sign.cur_day
    local _aday = dt
    if cur_day + _aday > #_data then
        _player.get().sign.cur_day = #_data
    else
        _player.get().sign.cur_day = cur_day + _aday
    end
end
function save()
  _player.setDirty()
  _player.save()
end
--领取签到奖励
function getSign()
    local cur_day = _player.get().sign.cur_day
    if _player.get().sign.day[cur_day] == SIGN_TYPE.OK then
        _popupTip("已经领过")
        return false--已经领过
    end

    local info = _data[cur_day]

    if cur_day == #_data then
        --未解锁奖励英雄
        if not _player.get().heros_unlock[info.hero] then
            require('game.charge').unconditionalUnlock(info.hero)
        else
        --已解锁奖励金币
            _player.get().golds = _player.get().golds + info.gold
        end
    else
        _player.get().golds            = _player.get().golds              + info.gold
        _player.get().items.bomb       = _player.get().items.bomb         + info.bomb
        _player.get().items.invincible = _player.get().items.invincible   + info.invincible
        _player.get().items.rush       = _player.get().items.rush         + info.rush
    end

    _player.get().sign.day[cur_day] = SIGN_TYPE.OK
    save()

    _popupTip("领取成功")
    return true
end
function check(sign)
  local dirty = false
  
  if type(sign) ~= 'table' then
    sign, dirty = {}, true
  end
  if type(sign.day) ~= 'table' then
    sign.day, dirty = {}, true
  end
  if type(sign.cur_day) ~= 'number' then
    sign.cur_day, dirty = 1, true
  end
  if type(sign.last_time) ~= 'number' then
    sign.last_time, dirty = nil, true
  end

  return sign, dirty
end


