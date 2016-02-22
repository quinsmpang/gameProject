module('util.misc', package.seeall)

local _TOUCH_BEGAN = ccui.TouchEventType.began
local _TOUCH_MOVED = ccui.TouchEventType.moved
local _TOUCH_ENDED = ccui.TouchEventType.ended
local _TOUCH_CANCELLED = ccui.TouchEventType.canceled

function createClickCB(func)
  return function(sender, evt)
    if evt == _TOUCH_ENDED then
      func(sender)
    end
  end
end

function createTouchCB(fbegan, fmoved, fended, fcancelled)
  return function(sender, evt)
    if evt == _TOUCH_BEGAN then
      if fbegan then fbegan(sender) end
      return true
    elseif evt == _TOUCH_MOVED then
      if fmoved then fmoved(sender) end
    elseif evt == _TOUCH_ENDED then
      if fended then fended(sender) end
    elseif evt == _TOUCH_CANCELLED then
      if fcancelled then fcancelled(sender) end
    end
  end
end
