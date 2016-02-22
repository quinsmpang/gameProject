module('game.ui.pkboss', package.seeall)

local _base_panel = require('game.ui.basepanel').BasePanel
local _misc = require('util.misc')
local _player = require('game.player')
local _pets_sdata = require('data.pets').pets
local _popupTip = require('game.mgr_scr').popupTip

local _CLR_BLACK = {r=0,g=0,b=0}
local _CLR_TIP = {r=255,g=255,b=0}

local _ui_data = {
  bosses = {
    {id=20013, name_frame='frame_20013', name_pic='boss_20013', name_kill='kill_20013'},
    {id=20014, name_frame='frame_20014', name_pic='boss_20014', name_kill='kill_20014'},
    {id=20015, name_frame='frame_20015', name_pic='boss_20015', name_kill='kill_20015'},
    {id=20016, name_frame='frame_20016', name_pic='boss_20016', name_kill='kill_20016'},
    {id=20017, name_frame='frame_20017', name_pic='boss_20017', name_kill='kill_20017'},
  },
  pets = {
    {id=30001, name_frame='frame_30001', name_pic='pet_30001', name_debris='debris_30001'},
    {id=30002, name_frame='frame_30002', name_pic='pet_30002', name_debris='debris_30002'},
    {id=30003, name_frame='frame_30003', name_pic='pet_30003', name_debris='debris_30003'},
    {id=30004, name_frame='frame_30004', name_pic='pet_30004', name_debris='debris_30004'},
    {id=30005, name_frame='frame_30005', name_pic='pet_30005', name_debris='debris_30005'},
  },
}


local function _updatePets(boss_index)
  local pets_ud = _player.get().pets
  local pets_data = _ui_data.pets
  
  local level_debris = 0
  for i=1, boss_index-1 do
    local id = pets_data[i].id
    local ud = pets_ud[id]
    if ud.level > 0 then
      --已有宠物，加到升级碎片
      level_debris = level_debris + 1
      if require('config').test_data then--用于方便测试碎片
         _player.get().pets.test_debris = _player.get().pets.test_debris or 0
         level_debris = level_debris + _player.get().pets.test_debris
         cclog("level_debris ================ " ..level_debris)
      end
    else
      local sdata = _pets_sdata[id]
      local debris = ud.debris + 1
      if require('config').test_data then--用于方便测试碎片
         _player.get().pets.test_debris = _player.get().pets.test_debris or 0
         debris = debris + _player.get().pets.test_debris
         cclog("debris ================ " ..debris)
      end
      if debris < sdata.debris_unlock then
        --加入合成碎片
        ud.debris = debris
      else
        --已足够合成。剩余碎片清0...
        ud.level = 1
        ud.debris = 0
        _popupTip(
          string.format('宠物%s已合成', sdata.name),
          _CLR_TIP)
      end
    end
  end
  
  pets_ud.level_debris = pets_ud.level_debris + level_debris
  _player.setDirty()
end

local function _updatePkNum(boss_index)
  --至少打完一个boss才算
  local minus = 0
  if boss_index > 1 then
    minus = 1
    _player.setDirty()
  end  
  local ud = _player.get()
  local left = ud.pk_num - minus
  if left<0 then left=0 end
  ud.pk_num = left
  return minus, left
end

----------- 演示相关 -----
local function _actWaitInit(self, info)
  self._act_t = info.sec
end

local function _actWaitUpdate(self, info, dt)
  local t = self._act_t - dt
  if t > 0 then
    self._act_t = t
  else
    self._act_t = nil
    return true
  end
end

local function _actShowOneInit(self, info)
  self._act_index = 0
  self._act_t = 0
end

local function _actShowOneUpdate(self, info, dt)
  local t = self._act_t - dt
  if t > 0 then
    self._act_t = t
    return
  end
  
  local index = self._act_index + 1
  if index >= self._boss_index then
    self._act_index, self._act_t = nil
    return true
  end
  
  self._act_index = index
  self._act_t = info.sec
  
  local boss = _ui_data.bosses[index]
  local frame = ccui.Helper:seekWidgetByNameOnNode(self._panel, boss.name_frame)
  frame:getChildByName(boss.name_pic):setColor(_CLR_BLACK)
  frame:getChildByName(boss.name_kill):setVisible(true)
  
  local pet = _ui_data.pets[index]
  frame = ccui.Helper:seekWidgetByNameOnNode(self._panel, pet.name_frame)
  frame:getChildByName(pet.name_debris):setVisible(true)
end

local function _actSaveInit(self, info)
  _updatePets(self._boss_index)
  local minus, left = _updatePkNum(self._boss_index)
  _player.save()
  
  self._pk_num:setString( string.format('%d',left) )
end

local function _actSaveUpdate(self, info, dt)
  return true
end

local _actions = {
  {init=_actWaitInit, update=_actWaitUpdate, sec=1},
  {init=_actShowOneInit, update=_actShowOneUpdate, sec=0.5},
  {init=_actSaveInit, update=_actSaveUpdate},
}


--[[
tab={
modal, ani: 模态、弹出动画
index=最后未打死的boss索引
cbAgain=function() 再玩一次
cbHome=function() 回主界面
}
]]
PKBoss = require('util.class').class(_base_panel)

PKBoss.ctor = function(self, tab)
  self._boss_index = tab.index
  if self._boss_index > #_ui_data.bosses then
    self._boss_index = #_ui_data.bosses + 1
  end
  self._user_table = tab
  
  local panel = cc.CSLoader:createNode('ui/bossmain.csb')
  self._panel = panel
  self.__super_ctor__(self, panel, tab.modal, tab.ani)
  
  local h = ccui.Helper
  local s = h.seekWidgetByNameOnNode
  
  self._pk_num = s(h, panel, 'pk_num')
  self._pk_num:setString('')
  
  self._btn_close = s(h, panel, 'public_btn_close')
  self._btn_close:setVisible(false)
  self._btn_home = s(h, panel, 'btn_home')
  self._btn_home:setVisible(false)
  self._btn_again = s(h, panel, 'btn_again')
  self._btn_again:setVisible(false)
  
  --self._curr_act_index 当前演示项
  --self._act_xxx 演示过程的变量
end

local function _setupListener(self)
  local function home()
    self:destroy()
    self._user_table.cbHome()
  end
  
  self.onKeyBack = home
  
  self._btn_close:setVisible(true)
  self._btn_close:addTouchEventListener(
    _misc.createClickCB(home))
  self._btn_home:setVisible(true)
  self._btn_home:addTouchEventListener(
    _misc.createClickCB(home))
  self._btn_again:setVisible(true)
  self._btn_again:addTouchEventListener(
    _misc.createClickCB(
      function()
        self:destroy()
        self._user_table.cbAgain()
      end
  ))
end

PKBoss.inst_meta.onEnter = function(self)
  --启动演示过程
  self._curr_act_index = 1
  _actions[1].init(self, _actions[1])
  self._panel:scheduleUpdateWithPriorityLua(
    function(dt)
      local index = self._curr_act_index
      local info = _actions[index]
      if info.update(self, info, dt) then
        index = index + 1
        if index <= #_actions then
          self._curr_act_index = index
          info = _actions[index]
          info.init(self, info)
        else
          self._panel:unscheduleUpdate()
          _setupListener(self)
        end
      end
    end, 0
  )
end

--------------
--每日更新次数
function updateDialyPkNum()
  local ud = _player.get()
  if ud.pk_num < 3 then
    ud.pk_num = 3
    _player.setDirty()
    _player.save()
  end
end

--检查要扣的次数，并记录之
function checkPkNumConsumed(boss_index)
  local minus = _updatePkNum(boss_index)
  if minus > 0 then
    _player.save()
  end
end

