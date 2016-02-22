module('game.ui.basepanel', package.seeall)

local _mgr_scr = require('game.mgr_scr')
local _misc = require('util.misc')

BasePanel = require('util.class').class()

--[[
layer: 
modal: boolean 是否模态
ani: boolean 弹出效果
]]
BasePanel.ctor = function(self, layer, modal, ani)
--cclog("==========BasePanel:ctor========!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
  _mgr_scr.pushDialog{
    node=layer,
    block_bottom=modal,
    bottom_color=modal,
    pop_effect=ani,
    reposition_center=true,
    onEnter=function()
      self:onEnter()
    end,
    onExit=function()
      self:onExit()
    end,
    onKeyBack=function()
      self:onKeyBack()
    end,
  }
end

BasePanel.inst_meta.destroy = function(self)
  _mgr_scr.popDialog()
end

BasePanel.inst_meta.onEnter = function(self)
end

BasePanel.inst_meta.onExit = function(self)
end

BasePanel.inst_meta.onKeyBack = function(self)
end
