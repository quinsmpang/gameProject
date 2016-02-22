collectgarbage("collect")
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)

--防止lua内置的路径扰乱
package.path = ';./?.lua;'
package.cpath = ''


-- cclog
function cclog(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function _setup()
  local file_util = cc.FileUtils:getInstance()
  file_util:addSearchPath('res')
  file_util:addSearchPath('src')
  
  local cfg = require('config')
  file_util:setPopupNotify(cfg.show_file_util_notify)
  
  -- CC_USE_DEPRECATED_API = true
  require("cocos.init")
    
  local director = cc.Director:getInstance()
  
  local view = director:getOpenGLView():getVisibleSize()  
  director:getOpenGLView():setDesignResolutionSize(
    cfg.design.width, cfg.design.height, 
    cfg.policy(view.width, view.height) )
  director:setAnimationInterval(1.0/cfg.design.fps)
  
  director:setDisplayStats(cfg.show_stats)
  
  local mgr = require('game.mgr_snd')
  mgr.init()
end


local function main()
  _setup()
  math.randomseed(os.time())
  
  local scene = cc.Scene:create()
  local dir = cc.Director:getInstance()
  if dir:getRunningScene()==nil then
    dir:runWithScene(scene)
  else
    dir:replaceScene(scene)
  end
  
  ---[[
  local mgr = require('game.mgr_scr')
  mgr.init(scene)
  mgr.pushScreen(require('game.scr_company').create())
  --]]
end

xpcall(main, __G__TRACKBACK__)
