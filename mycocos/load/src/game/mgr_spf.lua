module('game.mgr_spf', package.seeall)

--[[
 负责预加载和缓存需要的sprite frame
 每项的形式如：[name]={width=xx, width_inv=1/xx, height=xx, height_inv=1/xx, frame=xx}
]]
sprite_frames = {}

function clear()
  local spfs = sprite_frames
  for n,spf in pairs(spfs) do
    spf.frame:release()
    spfs[n] = nil
  end
end

function load()
  local plists = require('data.sprframe').plists
  local spfc = cc.SpriteFrameCache:getInstance()
  for i, p in ipairs(plists) do
    --cclog('----- %s -----', p.plist)
    spfc:addSpriteFrames(p.plist)
    for j, f in ipairs(p) do
      local spf = spfc:getSpriteFrame(f)
      spf:retain()
      local size = spf:getOriginalSize()
      sprite_frames[f] = {
        width=size.width, width_inv=1/size.width,
        height=size.height, height_inv=1/size.height,
        frame=spf
      }
      --cclog('%s:%d %d %s', f, size.width, size.height, spf)
    end
    --cclog('--------------')
  end
  --预加载
  local pl = require('data.preload')
  for i,sp in ipairs(pl.sprites) do
    --cclog('preload sprite:%s', sp)
    cc.Sprite:create(sp)
  end
end

