module('game.ui.guide', package.seeall)

local _data = {
  --ui_guide
  --ui_hand
  --ui_word_bg
  --ui_word
  
  --ui_allow
  --listener
  --rect={} 可点击范围，1-4分别是left,right,bottom,top
  --touch_id 触摸点id
  --cbDown, cbMove, cbUp, cbCancel
  --out_allowed 可点击区域外
}

local _WORD_LEFT_OFF = 31
local _WORD_TOP_OFF = 28
local _WORD_RIGHT_OFF = 60
local _WORD_BOTTOM_OFF = 30
local _WORD_BG_WIDTH_OFF = _WORD_LEFT_OFF + _WORD_RIGHT_OFF
local _WORD_BG_HEIGHT_OFF = _WORD_TOP_OFF + _WORD_BOTTOM_OFF


--[[
  设置允许点击的区域
  x,y,width,height 是可点击的矩形，y方向向上
  cbBegan,cbMoved,cbUp,cbCancelled 是触摸处理函数，不需要的可设为nil
  out_allowed 点击bounding box外的是否也处理
]]
function setBoundingBox(x, y, width, height, 
    cbBegan, cbMoved, cbUp, cbCancelled, out_allowed)
  local allow = _data.ui_allow
  if not allow then return end
  
  allow:setContentSize(width, height)
  allow:setPosition(x, y)
  
  local r = _data.rect
  r[1], r[2], r[3], r[4] = x, x+width, y, y+height
  _data.cbBegan = cbBegan
  _data.cbMoved = cbMoved
  _data.cbUp = cbUp
  _data.cbCancelled = cbCancelled
  _data.out_allowed = out_allowed
end

--[[
  设置文字，x,y是指向位置
  dir: 旋转方向
  flip: 左右翻转
]]
function setWordFrom(text, x, y, dir, flip)
  local bg, word = _data.ui_word_bg, _data.ui_word
  if not bg or not word then return end
  
  if not text then
    bg:setVisible(false)
    word:setVisible(false)
    return
  end

  bg:setVisible(true)
  word:setVisible(true)
  word:setString(text)
  
  local size = word:getContentSize()
  size.width = size.width
  size.height = size.height
  local wx, wy
  
  dir = dir or 'up'
  --背景锚点在右下角箭嘴，文字锚点在左下角。两个控件是兄弟关系
  if dir == 'up' then
    wx = flip and x+_WORD_RIGHT_OFF or x-size.width-_WORD_RIGHT_OFF
    wy = y + _WORD_BOTTOM_OFF
    size.width = size.width + _WORD_BG_WIDTH_OFF
    size.height = size.height + _WORD_BG_HEIGHT_OFF
  elseif dir == 'down' then
    bg:setRotation(180)
    wx = flip and x-size.width-_WORD_RIGHT_OFF or x+_WORD_RIGHT_OFF
    wy = y - size.height - _WORD_BOTTOM_OFF
    size.width = size.width + _WORD_BG_WIDTH_OFF
    size.height = size.height + _WORD_BG_HEIGHT_OFF
  elseif dir == 'left' then
    bg:setRotation(90)
    wx = x+_WORD_BOTTOM_OFF
    wy = flip and y-size.height-_WORD_RIGHT_OFF or y+_WORD_RIGHT_OFF
    local w = size.width
    size.width = size.height + _WORD_BG_WIDTH_OFF
    size.height = w + _WORD_BG_HEIGHT_OFF
  elseif dir == 'right' then
    bg:setRotation(-90)
    wx = x - size.width - _WORD_BOTTOM_OFF
    wy = flip and y+_WORD_RIGHT_OFF or y-size.height-_WORD_RIGHT_OFF
    local w = size.width
    size.width = size.height + _WORD_BG_WIDTH_OFF
    size.height = w + _WORD_BG_HEIGHT_OFF
  else
    error('guide.setWordFrom direction incorrect', 2)
  end
  word:setPosition(wx, wy)
  bg:setPosition(x, y)
  if flip then bg:setScaleX(-1) end
  bg:setContentSize(size)
end

--[[
  设置手的位置、方向、动作
  x, y
  direction='left', 'right', 'up', 'down'
  action
]]
function setHand(x, y, direction, action)
  local hand = _data.ui_hand
  if not hand then return end
  
  if not x then
    hand:setVisible(false)
    return
  end
  
  hand:setPosition(x, y)
  hand:stopAllActions()
  local ang
  if direction == 'up' then
    ang = 0
  elseif direction == 'down' then
    ang = 180
  elseif direction == 'left' then
    ang = 270
  elseif direction == 'right' then
    ang = 90
  else
    error('guide.setHand direction incorrect', 2)
  end
  hand:setRotation(ang)
  hand:runAction(action)
end


----
local _onTouchBegan
local _onTouchMoved
local _onTouchUp
local _onTouchCancelled

function create()
  local layer = cc.CSLoader:createNode('ui/guide.csb')
  _data.ui_guide = layer
  
  local h = ccui.Helper
  local s = h.seekNodeByNameOnNode
  local node
  node = s(h, layer, 'hand')
  node:setLocalZOrder(3)
  _data.ui_hand = node 
  node = s(h, layer, 'word_bg')
  node:setLocalZOrder(1)
  _data.ui_word_bg = node 
  node = s(h, layer, 'word')
  node:setLocalZOrder(2)
  _data.ui_word = node 
  
  local allow = cc.LayerColor:create{r=255, g=255, b=255}
  _data.ui_allow = allow
  s(h,layer,'panel'):addChild(allow)
  allow:setBlendFunc(gl.DST_COLOR, gl.ONE)
  
  _data.rect={0, 0, 0, 0}
  _data.cbBegan, _data.cbMoved, _data.cbUp, _data.cbCancelled = nil
  
  local lsn = cc.EventListenerTouchOneByOne:create()
  lsn:setSwallowTouches(true)
  lsn:registerScriptHandler(_onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
  lsn:registerScriptHandler(_onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
  lsn:registerScriptHandler(_onTouchUp, cc.Handler.EVENT_TOUCH_ENDED )
  lsn:registerScriptHandler(_onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
  layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(lsn, layer)
  _data.listener = lsn
    
  return {
    node=layer,
    onKeyBack=function() end,
  }
end


_onTouchBegan = function(touch)
  --已有处理的触摸点，截获但忽略其处理
  if _data.touch_id then
    return true 
  end
  
  if not _data.out_allowed then
    local pos = _data.ui_guide:convertToNodeSpace(touch:getLocation())
    local x, y = pos.x, pos.y
    local r = _data.rect
    --不在允许范围内，截获但忽略处理
    if x<r[1] or x>=r[2] or y<r[3] or y>=r[4] then
      return true
    end
  end
  
  _data.touch_id = touch:getId()
  if _data.cbBegan then
    _data.cbBegan(touch)
  end
  return true
end

_onTouchMoved = function(touch)
  if touch:getId() ~= _data.touch_id then
    return
  end
  
  if _data.cbMoved then
    _data.cbMoved(touch)
  end
end

_onTouchUp = function(touch)
  if touch:getId() ~= _data.touch_id then
    return
  end
  
  _data.touch_id = nil
  
  if not _data.out_allowed then
    local pos = _data.ui_guide:convertToNodeSpace(touch:getLocation())
    local x, y = pos.x, pos.y
    local r = _data.rect
    --不在指定范围内弹起等同cancelled
    if x<r[1] and x>=r[2] and y<r[3] and y>=r[4] then
      if _data.cbCancelled then
        _data.cbCancelled(touch)
      end
      return
    end
  end
  
  if _data.cbUp then
    _data.cbUp(touch)
  end
end

_onTouchCancelled = function(touch)
  if touch:getId() ~= _data.touch_id then
    return
  end
  
  _data.touch_id = nil
  if _data.cbCancelled then
    _data.cbCancelled(touch)
  end
end
