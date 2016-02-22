module('game.charge', package.seeall)

local _player = require('game.player')
local _charge_data = require('data.charge')
local _popupTip = require('game.mgr_scr').popupTip

--[[
info={ --至少含如下两项
  name='charge_name',
  rmb=10, --单位元
},
no_save: 有改动时不保存（由调用者再保存，以减少保存次数）
]]
local function _charge(info, no_save)
  cclog('charge name:%s rmb:%d', info.name, info.rmb)
  return plat.charge('', info.name, info.rmb)
end


charge = _charge

function chargeForBag(bag)
  if not _charge(bag, true) then
    return false
  end
    
  local p = _player.get()
  if bag.golds then
    p.golds = p.golds + bag.golds
  end
  if bag.pk_num then
    p.pk_num = p.pk_num + bag.pk_num
  end
  
  if bag.items then
    local pitems = p.items
    for name,num in pairs(bag.items) do
      local i = pitems[name]
      if i then
        pitems[name] = i + num
      end
    end
  end
  
  _player.setDirty()
  _player.save()
  return true
end

------------------
--无条件解锁英雄
local function _unconditionalUnlock(hero_id)
  local heros_data = require('data.hero').heros
  local hlevel = _player.get().heros_level
  local hunlock = _player.get().heros_unlock
  
  hunlock[hero_id] = true
  hlevel[hero_id] = math.max(1, hlevel[hero_id])
  --相应进阶/原始角色也解锁，并设置级数
  local counter_hid = heros_data[hero_id].unlock_cascade_id
  if counter_hid then
    hunlock[counter_hid] = true
    hlevel[counter_hid] = math.max(1, hlevel[counter_hid])
  end

  _player.setDirty()
end

unconditionalUnlock = _unconditionalUnlock

--处理解锁逻辑 
--TODO: 另见game.player内的逻辑约束。看情况将这些逻辑整理到一起
function chargeForUnlock(hero_id)
  local info = _charge_data.unlock[hero_id]
  if info.rmb then
    --支付解锁
    if not _charge(info, true) then
      return false
    end
  elseif info.golds then
    --金币解锁
    local pd = _player.get()
    if pd.golds < info.golds then
      _popupTip(info.tip_failed)
      return false
    end
    pd.golds = pd.golds - info.golds
    _player.setDirty()
  else
    --其它特殊条件
    _popupTip(info.tip_failed)
    return false
  end
  
  _unconditionalUnlock(hero_id)
  _player.save()
  return true
end

