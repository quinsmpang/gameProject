module('game.mgr_scr', package.seeall)

local _config = require('config')

local _screen_stack = {
  scene = nil;
--[[
  1~... 各层screen的描述table
  {
    node 该screen对应的顶层node
    onEnter [opt]进入时被调用
    onExit  [opt]被弹出前被调用
    onHide  [opt]被新screen放在上，自身隐藏前调用
    onShow  [opt]其上screen离开，显示前被调用
    
    --本screen的dialog层,从顶往下
    _dialog = {
      node = xx 传入的node
      z = xx 处于screen node的z值
      block_bottom = true|false
      bottom_color = true|false
      pop_effect = true|false
      reposition_center = true|false
      onEnter = function() end
      onExit = function() end
      onKeyBack = function() end
      _next = xx 下一层的table
    }
  }
]]

  --截获输入的层及其listener
  bottom = {
    --layer, listener, is_attached
  },
  bottom_color = {
    --layer, listener, is_attached
  },
  
  lsn_keys = nil,
  
} --screen_stack


-----tip相关数据
local _tips = {
  entry = nil; --定时函数
  --[[
    1~... 各个tip,新来的放到1，旧的依次往后退
    每元素 {
      tip=label, --相应的label
      update=function(tip, dt), --当前update函数
      xxx  --其它设定数值
    }
  ]]
}

--弹出tip的参数
local _TIP_X = _config.design.width * 0.5
local _TIP_Y = _config.design.height - 100
local _TIP_Z = 1000
local _TIP_PUSH_Y = -20
local _TIP_COLOR = {r=255, g=255, b=255}

local _TIP_SCALE = {0.8, 1.2, 0.2}
local _TIP_WAIT = 1
local _TIP_MOVE_FADE = {-100, 0.5}

local function _tipMoveAndFadeOut(tip, dt)
  local t = tip.t + dt
  local total = _TIP_MOVE_FADE[2]
  if t < total then
    tip.t = t
    local r = t/_TIP_MOVE_FADE[2]
    local label = tip.label
    local y = label:getPositionY()
    label:setPositionY( y + _TIP_MOVE_FADE[1]*dt )
    label:setOpacity( 255*(1-r) )
  else
    --清理。保证从尾到头调用
    tip.label:removeFromParent()
    _tips[#_tips] = nil
  end
end

local function _tipWait(tip, dt)
  local t = tip.t + dt
  if t < _TIP_WAIT then
    tip.t = t
  else
    tip.t = 0
    tip.update = _tipMoveAndFadeOut
  end
end

local function _tipScale(tip, dt)
  local t = tip.t + dt
  local total = _TIP_SCALE[3]
  if t < total then
    tip.t = t
  else
    t = total
    tip.t = 0
    tip.update = _tipWait
  end
  local r = t / total
  tip.label:setScale(_TIP_SCALE[1]*(1-r) + _TIP_SCALE[2]*r)
end

local function _tipUpdate(dt)
  for i=#_tips, 1, -1 do
    local tip = _tips[i]
    tip.update(tip, dt)
  end
  if #_tips == 0 then
    cc.Director:getInstance():getScheduler()
      :unscheduleScriptEntry(_tips.entry)
    _tips.entry = nil
  end
end

local function _tipStart(tip)
  local n = #_tips
  if n==0 then
    _tips.entry = cc.Director:getInstance():getScheduler()
                  :scheduleScriptFunc(_tipUpdate, 0, false)
  else
    local t, y
    for i=n, 1, -1 do
      t = _tips[i]
      y = t.label:getPositionY()
      t.label:setPositionY( y + _TIP_PUSH_Y )
      _tips[i+1] = t
    end
  end
  _tips[1] = tip
  
  tip.update = _tipScale
  tip.t = 0
  tip.label:setScale(_TIP_SCALE[1])
end


--[[
弹出提示
]]
function popupTip(text,_color,pos)
  local label = cc.Label:createWithSystemFont(text, '', 24)
  label:setAnchorPoint(0.5, 0.5)
  if not pos then
    label:setPosition(_TIP_X, _TIP_Y)
  else
    label:setPosition(pos.x, pos.y)
  end
  label:setLocalZOrder(_TIP_Z)
  if not _color then
    label:setColor(_TIP_COLOR)
  else
    label:setColor(_color)
  end
  _screen_stack.scene:addChild(label)
  
  local tip = {label=label}
  _tipStart(tip)
end


----dialog操作相关
--[[
参数dialog = {
  node = dialog的顶层node
  z = 期望的z值，应为正整数。返回实际的值
  block_bottom = true|false 是否模态（阻止下次处理输入）
  bottom_color = true|false 模态下，底层是否用暗色
  pop_effect = true|false 是否有弹出效果
  reposition_center = true|false 有弹出效果时，是否重设其anchorpoint和position到屏幕中心
  onEnter: [opt]function() end，初次加入时通知
  onExit: [opt]function() end，最后退出时通知
  onKeyBack: [opt]function() end，按下back键时处理
              未指定，或返回true，由下一级指定
              否则返回即处理完
返回：实际设置的z值
约定：
  提交之后不应修改table以上表项内容，
  不能操作 _ 开头名字的值
}
]]
function pushDialog(dialog)
  local ss = _screen_stack
  local scr = ss[#ss]
  
  local z_target = scr._dialog and scr._dialog.z+1 or 1
  if dialog.block_bottom then
    z_target = z_target + 1
  end
  local z = dialog.z
  if not z or z<z_target then
    z = z_target
  end
  
  if dialog.block_bottom then
    local tbl = dialog.bottom_color and ss.bottom_color or ss.bottom
    if tbl.is_attached then
      tbl.layer:removeFromParent()
    end
    scr.node:addChild(tbl.layer)
    tbl.is_attached = true
    tbl.layer:setLocalZOrder(z - 1)
  end
  
  dialog.z = z
  scr.node:addChild(dialog.node)
  dialog.node:setLocalZOrder(z)

  dialog._next = scr._dialog
  scr._dialog = dialog
  
  if dialog.pop_effect then
    local node = dialog.node
    if dialog.reposition_center then
      node:setAnchorPoint(0.5, 0.5)
      node:setPosition(_config.design.width*0.5, _config.design.height*0.5)
    end
    node:setScale(0)
    node:runAction(
      cc.EaseBackOut:create(
        cc.ScaleTo:create(0.3, 1)
    ) )
  end
  if dialog.onEnter then
    dialog.onEnter()
  end
  return z
end


local function _resetPrevBlockLayer(screen)
  local btm = _screen_stack.bottom
  local clr = _screen_stack.bottom_color
  local dlg = screen._dialog
  while dlg and
    (not btm.is_attached or not clr.is_attached)
  do
    if dlg.block_bottom then
      local tbl = dlg.bottom_color and clr or btm
      if not tbl.is_attached then
        screen.node:addChild(tbl.layer)
        tbl.layer:setLocalZOrder(dlg.z -1)
        tbl.is_attached = true
      end
    end
    dlg = dlg._next
  end
end

--[[
弹出当前screen的顶层dialog
]]
local function _popDialog()
  local ss = _screen_stack
  local scr = ss[#ss]
  local dlg = scr._dialog
  
  scr._dialog = dlg._next
  if dlg.block_bottom then
    local tbl = dlg.bottom_color and ss.bottom_color or ss.bottom
    --连续pop多个screen时，中间screen的dialog可能没attached
    if tbl.is_attached then
      tbl.layer:removeFromParent()
      tbl.is_attached = false
      _resetPrevBlockLayer(scr)
    end
  end
  dlg.node:removeFromParent()

  if dlg.onExit then
    dlg.onExit()
  end
end

popDialog = _popDialog

local function _popAllDialogs(screen)
  while screen._dialog do
    _popDialog()
  end
end

local function _procKeys(keycode)
  if keycode ~= cc.KeyCode.KEY_BACK then
    return
  end
  --当前scene
  local scr = _screen_stack[#_screen_stack]
  local dlg = scr._dialog
  while dlg do
    if dlg.onKeyBack then
      if not dlg.onKeyBack() then
        return
      end
    end
    dlg = dlg._next
  end
  if scr.onKeyBack then
    if not scr.onKeyBack() then
      return
    end
  end
end

local function _initDialogs(scene)
  local function setupLayer(tbl, layer)
    layer:retain()
    tbl.layer = layer
    tbl.is_attached = false
    
    local lsn = cc.EventListenerTouchOneByOne:create()
    lsn:setSwallowTouches(true)
    lsn:registerScriptHandler(function() return true end, cc.Handler.EVENT_TOUCH_BEGAN )
    lsn:registerScriptHandler(function() end, cc.Handler.EVENT_TOUCH_MOVED )
    lsn:registerScriptHandler(function() end, cc.Handler.EVENT_TOUCH_ENDED )
    lsn:registerScriptHandler(function() end, cc.Handler.EVENT_TOUCH_CANCELLED)
    layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(lsn, layer)
    tbl.listener = lsn
  end

  local layer = cc.LayerColor:create{r=0,g=0,b=0,a=128}
  setupLayer(_screen_stack.bottom_color, layer)
  
  setupLayer(_screen_stack.bottom, cc.Layer:create())
  
  local lsn = cc.EventListenerKeyboard:create()
  lsn:registerScriptHandler(
    _procKeys, 
    cc.Handler.EVENT_KEYBOARD_RELEASED )
  scene:getEventDispatcher():addEventListenerWithSceneGraphPriority(lsn, scene)
  _screen_stack.lsn_keys = lsn
end

local function _clearDialogs()
  local function freeLayer(tbl)
    tbl.layer:getEventDispatcher():removeEventListener(tbl.listener)
    tbl.layer, tbl.listener, tbl.is_attached = nil
  end

  local ss = _screen_stack
  freeLayer(ss.bottom)
  freeLayer(ss.bottom_color)
  
  ss.scene:removeEventListener(ss.lsn_keys)
  ss.lsn_keys = nil
end

----screen操作相关
--[[
参数scr = {
  node: cocos2d-x node
  
  onEnter: [opt]函数，初次加入时通知
  onExit: [opt]函数，最后退出时通知
  onHide: [opt]函数，被遮盖时通知
  onShow: [opt]函数，重新出现后通知
  
  onKeyBack: [opt]函数，按下back键时处理
              未指定，或返回true，由下一级指定
              否则处理完即截获
约定：以上函数内不能进行screen切换操作
  提交之后不应修改table以上表项内容，
  不能操作 _ 开头名字的值
}
]]

--[[
切换screen
参数：scr新的screen，符合scr要求
  level：切换的层，
    若不指定则是最顶层，相对于pop再push。
    否则，所有>level的screen被pop出。
]]
function switchScreen(scr, level)
  local n = #_screen_stack
  
  level = (level and level>0) and level or n
  if level > n then
    error('switchScreen level too high', 2)
  end
  
  while n >= level do
    local s = _screen_stack[n]
    _popAllDialogs(s)
    if s.onExit then s.onExit() end
    s.node:removeFromParent()
    _screen_stack[n] = nil
    n = n - 1
    --连续pop的，中间不 _resetPrevBlockLayer
  end
  
  _screen_stack.scene:addChild(scr.node)
  scr.node:setLocalZOrder(level)
  scr._dialog = nil
  _screen_stack[level] = scr
  if scr.onEnter then scr.onEnter() end
end

--[[
压入screen
参数: 新的screen，符合scr要求
]]
function pushScreen(scr)
  local level = #_screen_stack
  
  if level>0 then
    local s = _screen_stack[level]
    s.node:setVisible(false)
    if s.onHide then s.onHide() end
  end
  
  _screen_stack.scene:addChild(scr.node)
  scr.node:setLocalZOrder(level+1)
  scr._dialog = nil
  _screen_stack[level+1] = scr
  if scr.onEnter then scr.onEnter() end
end

--[[
弹出最顶层screen
参数：任意
若之前的screen被压，会恢复。
  此时调用其 onShow，并将参数转发过去
]]
local function _popScreen(...)
  local n = #_screen_stack
  if n == 0 then return end
  
  local s = _screen_stack[n]
  _popAllDialogs(s)
  if s.onExit then s.onExit() end
  s.node:removeFromParent()
  _screen_stack[n] = nil
  
  n = #_screen_stack
  if n > 0 then
    s = _screen_stack[n]
    _resetPrevBlockLayer(s)
    s.node:setVisible(true)
    if s.onShow then s.onShow(...) end
  end
end

popScreen = _popScreen

-----------------------------------------
function init(scene)
  assert(not _screen_stack.scene and scene, 'mgr_scr.init: wrong...')
  
  _initDialogs(scene)
  _screen_stack.scene = scene;
end

function clear()
  local ss = _screen_stack
  if not ss.scene then
    return
  end
  
  while #ss > 0 do
    _popScreen()
  end
  
  _clearDialogs()
  _screen_stack.scene = nil
end
