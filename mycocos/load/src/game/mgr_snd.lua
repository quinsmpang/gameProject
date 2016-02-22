module('game.mgr_snd', package.seeall)

local _config = require('config')

--[[
  提供对音乐、音效的统一管理
]]

local _audio = cc.SimpleAudioEngine:getInstance()


local _music_stack = {
}

function init()
  _audio:setEffectsVolume(_config.volume.effects)
  _audio:setMusicVolume(_config.volume.music)
end

function load()
  local pl = require('data.preload')
  for i,sound in ipairs(pl.sounds) do
    --cclog('preload effect:%s', sound)
    _audio:preloadEffect(sound)
  end
end

function enableMusic(is_enabled)
  _audio:setMusicVolume(is_enabled and _config.volume.music or 0)
end

function enableEffects(is_enabled)
  _audio:setEffectsVolume(is_enabled and _config.volume.effects or 0)
end

--[[
bg music相关
]]
function switchMusic(path)
  local n = #_music_stack
  assert(n>0, 'switchMusic n==0')
  
  if _music_stack[n] ~= path then
    _audio:stopMusic(true)
    _music_stack[n] = path
    _audio:playMusic(path, true)
  end
end

function pushMusic(path)
  local n = #_music_stack
  if n>0 then
    _audio:stopMusic()
  end
  _music_stack[n+1] = path
  _audio:playMusic(path, true)
end

function popMusic()
  local n = #_music_stack
  if n>0 then
    _music_stack[n] = nil
    if n>1 then
      _audio:playMusic(_music_stack[n-1], true)
    else
      _audio:stopMusic(true)
    end
  end
end

--[[
音效相关
]]
function playEffect(path, is_loop)
  return _audio:playEffect(path, is_loop)
end

function stopEffect(sound)
  _audio:stopEffect(sound)
end

