module('game.ui.warning', package.seeall)


local _data = {}

function Pause()
    --cclog("Pause ================ ")
end

function Resume()
    
end
local function _WarningFont(spr)
    local fade_out = cc.FadeOut:create(0.5);
    local fade_in  = fade_out:reverse()
    local seq      = cc.Sequence:create(fade_out,fade_in)
    local forever  = cc.RepeatForever:create(seq)
    spr:runAction(forever)
end
local function _onEnter()
    local panel = cc.CSLoader:createNode('ui/warning.csb')
    _data.layer:addChild(panel)
--    local _warning_font = panel:getChildByName("warning_font")
--    _WarningFont(_warning_font)

    local action = cc.CSLoader:createTimeline('ui/warning.csb')
    panel:runAction(action)
    action:gotoFrameAndPlay(0,false)
    
    --[[
    --开启倒计时
    local uptime = 2
    local t = 1
    local fps = require('config').design.fps
    local function updateTime(dt)
        t = t + 1
        if uptime > 0 then
            if t%fps == 0 then
                t = 0
                uptime = uptime - 1
            end
        else
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_data.time_id)
            _data.layer:removeFromParent()
        end
    end

    _data.time_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 0, false)
    ]]
end
local function _onExit()


end

function create()
   --cclog("==========warning create========!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
   _data.layer = cc.Layer:create()
   _onEnter()
   return _data.layer
end