module('game.scr_company', package.seeall)


--显示启动图并预加载资源
local _data = {
}


local function _loadResources(dt)
  cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_data.entry)
  
  local mgr
  --TODO: 按需改为显示进度
  mgr = require('game.mgr_spf')
  mgr.load()
  mgr = require('game.mgr_snd')
  mgr.load()
  
  mgr = require('game.mgr_evt')
  mgr.reset()
  
  mgr = require('game.mgr_scr')
  mgr.switchScreen(require('game.scr_main').create())
end

local function _onEnter()
  --cclog('scr_company enter')
  
  local layer = _data.layer
  
  cc.SpriteFrameCache:getInstance():addSpriteFrames('ui/ui3.plist')
  local bg = cc.Sprite:create()
  bg:setSpriteFrame('ui/died/died_bg.png')
  bg:setAnchorPoint(0, 0)
  
  layer:addChild(bg)
  
  --到下一帧才执行加载，让图标有机会显示
  _data.entry = cc.Director:getInstance():getScheduler()
                  :scheduleScriptFunc(_loadResources, 0, false)
end

local function _onExit()
  --cclog('scr_company exit')
  for n,v in pairs(_data) do
    _data[n] = nil
  end
end

function create()
  local layer = cc.Layer:create()  
  _data.layer = layer
  
  local scr = {
    node = layer;
    onEnter = _onEnter;
    onExit = _onExit;
  }
  return scr
end
