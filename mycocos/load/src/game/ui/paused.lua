module('game.ui.paused', package.seeall)

local _misc = require('util.misc')
local _player = require('game.player')
local _task = require('game.task')
local _task_text = require('data.text').task

local _items = {
  {
    index = 1,
    name_panel='panel_task_1', panel=nil,
    name_desc='text_desc_1',  desc=nil,
    name_progress='text_progress_1', progress=nil,
    name_reward='text_reward_1', reward=nil,
    name_skip='btn_skip_1', skip=nil,
  },
  {
    index = 2,
    name_panel='panel_task_2', panel=nil,
    name_desc='text_desc_2',  desc=nil,
    name_progress='text_progress_2', progress=nil,
    name_reward='text_reward_2', reward=nil,
    name_skip='btn_skip_2', skip=nil,
  },
  {
    index = 3,
    name_panel='panel_task_3', panel=nil,
    name_desc='text_desc_3',  desc=nil,
    name_progress='text_progress_3', progress=nil,
    name_reward='text_reward_3', reward=nil,
    name_skip='btn_skip_3', skip=nil,
  },
}


local _resetTaskItems
_resetTaskItems = function()
  local fmt = string.format
  local tasks = _task.getInfo()
  for i, t in ipairs(tasks) do
    local item = _items[i]
    item.panel:setVisible(true)
    if not t then
      item.desc:setString('')
      item.progress:setString('')
      item.reward:setString('')
      item.skip:setVisible(false)
    else
      item.desc:setString(t.desc)
      item.progress:setString(fmt(_task_text.left_to_do, t.todo))
      item.reward:setString(fmt(_task_text.reward, t.reward))
      if _task.isTaskDone(i) then
        item.skip:setVisible(false)
      else
        item.skip:setVisible(true)
        item.skip:addTouchEventListener(
          _misc.createClickCB(
            function()
              --TODO: 处理动画效果
              _task.skipTask(i)
              _resetTaskItems()
              _player.save()
            end
          )
        )
      end
    end
  end
  for i=#tasks+1, #_items do
    _items[i].panel:setVisible(false)
  end
end


local function _initUI(dlg)
  local h = ccui.Helper
  local s = h.seekWidgetByNameOnNode
  for i, item in ipairs(_items) do
    item.panel = s(h, dlg, item.name_panel)
    item.desc = s(h, dlg, item.name_desc)
    item.progress = s(h, dlg, item.name_progress)
    item.reward = s(h, dlg, item.name_reward)
    
    item.skip = s(h, dlg, item.name_skip)
  end
  _resetTaskItems()
end

local function _onExit()
  for i, item in ipairs(_items) do
    item.panel = nil
    item.desc = nil
    item.progress = nil
    item.reward = nil
    item.skip = nil
  end
end

--[[
function cb_return(ret_code)
返回以下之一
]]
RET_RESUME = 0  --继续游戏
RET_TO_MAIN = 1 --结束并返回主界面

function create(cb_return)
  local paused = cc.CSLoader:createNode('ui/paused.csb')
  
  _initUI(paused)
  local h = ccui.Helper
  local s = h.seekWidgetByNameOnNode
  
  
  local function cbBack()
    cb_return(RET_RESUME)
  end
  s(h, paused, 'btn_return'):addTouchEventListener(
    _misc.createClickCB(cbBack)
  )
  
  s(h, paused, 'btn_main'):addTouchEventListener(
    _misc.createClickCB(
      function()
        cb_return(RET_TO_MAIN)
      end
    )
  )
  
  return {
    node=paused,
    block_bottom=true,
    pop_effect=true,
    reposition_center=true,
    onExit=_onExit,
    onKeyBack=cbBack,
  }
end

