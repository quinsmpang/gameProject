module('game.mgr_evt', package.seeall)
local _assert = assert

--[[目前的事件（有变化需改动这里）
第一个参数总是事件名，以下列出从第2个开始
  事件名                参数
battle.start         1:game.battle.scene.Scene实例
                     2:game.scr_battle.cb_battle函数表
battle.play_update   1:game.battle.scene.Scene实例
                     2:dt 本帧时间
battle.boss_showed   1:game.battle.scene.Scene实例
battle.boss_died     1:game.battle.scene.Scene实例
battle.stop          1:game.battle.scene.Scene实例
hero.rescued         1:英雄的静态数据data.hero.heros下某项
team.changed         1:变化的team实例
                     2:true:加入 false:删除
team.hero_changed    1:变化的game.battle.team实例 
enemy.killed         1:game.battle.enemy.Enemy实例 
                     2:静态数据，在data.enemy.enemys下某项
task.done            暂未有参数
]]

--[[
事件系统，事件以名字标识，
调用subscribe(事件名, 函数) 监听某类事件
用publish(事件名,参数...)发布事件，
所有监听该类事件的处理函数均会被调用 func(事件名,参数...)
调用unsubscribe(事件名,函数) 取消监听.
]]
local _subscribers = {
}

local _publishing_evt
local _publishing_pending = {
}
local _subs_tmp = {
}

local function _mergePending(evt_subs)
  for func,is_add in pairs(_subs_tmp) do
    evt_subs[func] = (is_add and true or nil)
    _subs_tmp[func] = nil
  end
end

--发布一个事件，evt_name是事件名，...是参数
function publish(evt_name, ...)
  _assert(evt_name, 'mgr_evt.publish: evt_name is nil')
  
  if _publishing_evt then
    _publishing_pending[#_publishing_pending +1] = {evt_name, ...}
    return
  end
  
  local s = _subscribers[evt_name]
  if s then
    _publishing_evt = evt_name
    for func,valid in pairs(s) do
      if valid then
        func(evt_name, ...)
      end
    end
    _publishing_evt = nil
    _mergePending(s)
  end
    
  repeat
    local pend = _publishing_pending[1]
    if not pend then break end
    
    s = _subscribers[pend[1]]
    if s then
      _publishing_evt = evt_name
      for func,valid in pairs(s) do
        if valid then
          func(unpack(pend))
        end
      end
      _publishing_evt = nil
      _mergePending(s)
    end
    for i=1, #_publishing_pending do
      _publishing_pending[i] = _publishing_pending[i+1]
    end
  until false
end

--注册一个事件监听器
function subscribe(evt_name, func)
  if _publishing_evt and _publishing_evt==evt_name then
    _subs_tmp[func] = true
  else
    local s = _subscribers[evt_name]
    if not s then
      s = {}
      _subscribers[evt_name] = s
    end
    s[func] = true
  end
end

--移除一个事件监听器
function unsubscribe(evt_name, func)
  local s = _subscribers[evt_name]
  if not s then return end
  if _publishing_evt==evt_name then
    if s[func] then
      s[func] = false
      _subs_tmp[func] = false
    else --可能已加入但未处理
      _subs_tmp[func] = nil
    end
  else
    s[func] = nil
  end
end

--清除所有事件监听器
--约定：不能在事件通知中reset
function reset()
  _assert(_publishing_evt==nil, 'mgr_evt.reset: reset during publishing')
  for n,v in pairs(_subs_tmp) do
    _subs_tmp[n] = nil
  end
  for n,v in pairs(_subscribers) do
    _subscribers[n] = nil
  end
end


----for test
--[==[
function test()
  reset()
  
  local f1, f2, f3
  print('===subscribe 2 function to evt and publish:evt 10 20')
  f1 = function(evt_name,a,b)
    print('evt publish called f1', a, b)
  end
  f2 = function(evt_name,a,b)
    print('evt publish called f2', a, b)
  end
  subscribe('evt', f1)
  subscribe('evt', f2)
  publish('evt', 10, 20)
  print('...publish end')
  
  print('...unsubscribe f1 and publish:evt 30 40')
  unsubscribe('evt', f1)
  publish('evt', 30, 40)
  print('===publish end\n')
  
  reset()
  print('===subscribe f1 which subs f2 when called, then publish 3 times')
  f1 = function(evt_name, a, b, c)
    print('evt publish called f1', a, b, c)
    subscribe('evt', f2)
  end
  f2 = function(evt_name, a, b, c)
    print('evt publish called f2', a, b, c)
  end
  subscribe('evt', f1)
  publish('evt', 1, 2, 3)
  print('...publish 1 end')
  publish('evt', 4, 5, 6)
  print('...publish 2 end')
  publish('evt', 7, 8, 9)
  print('===publish 3 end\n')
  
  reset()
  print('===subscribe f1 and f2. f2 will unsubs f1 when called. then publish 3 times')
  f1 = function(evt_name, a, b)
    print('evt publish called f1', a, b)
  end
  f2 = function(evt_name, a, b)
    print('evt publish called f2', a, b)
    unsubscribe('evt', f1)
  end
  subscribe('evt', f2)
  subscribe('evt', f1)
  publish('evt', 1, 2)
  print('...publish 1 end')
  publish('evt', 3, 4)
  print('...publish 2 end')
  publish('evt', 5, 6)
  print('===publish 3 end\n')
  
  reset()
  print('===subscribe f1 which unsubs itself when called, then publish 3 times')
  f1 = function(evt_name)
    print('evt publish called f1')
    unsubscribe('evt', f1)
  end
  subscribe('evt', f1)
  publish('evt')
  print('...publish 1 end')
  publish('evt')
  print('...publish 2 end')
  publish('evt')
  print('===publish 3 end\n')
  
  reset()
  print([[
===subscribe f1 which subs f2 when called.
   f2 will subs f3, unsubs f1 and itself when called.
   f3 will subs then unsubs f1.
   then publish 3 times]])
  f1 = function(evt_name)
    print('evt publish called f1')
    subscribe('evt', f2)
  end
  f2 = function(evt_name)
    print('evt publish called f2')
    subscribe('evt', f3)
    unsubscribe('evt', f1)
    unsubscribe('evt', f2)
  end
  f3 = function(evt_name)
    print('evt publish called f3')
    subscribe('evt', f1)
    unsubscribe('evt', f1)
  end
  subscribe('evt', f1)
  publish('evt')
  print('...publish 1 end')
  publish('evt')
  print('...publish 2 end')
  publish('evt')
  print('...publish 3 end')
  publish('evt')
  print('===publish 4 end\n')
end
]==]
