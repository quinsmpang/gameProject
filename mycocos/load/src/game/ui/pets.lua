module('game.ui.pets', package.seeall)

local _base_panel = require('game.ui.basepanel').BasePanel
local _misc = require('util.misc')
local _player = require('game.player')
local _pets_sdata = require('data.pets').pets
local _popupTip = require('game.mgr_scr').popupTip


local _CLR_TIP = {r=255, g=255, b=0}
local _CLR_NORMAL = {r=255, g=255, b=255}
local _CLR_BLACK = {r=0,g=0,b=0}

--各ui元素的名字
local _ui_data = {
  {
    name_container='pet_1',
    name_frame='pet_frame_1',
    name_level_bg='pet_type_1',
    name_level_text='pet_level_1',
    name_pic='pet_pic_1',
    name_pet_name='pet_name_1',
    name_debris='pet_font_1'
  },
  {
    name_container='pet_2',
    name_frame='pet_frame_2',
    name_level_bg='pet_type_2',
    name_level_text='pet_level_2',
    name_pic='pet_pic_2',
    name_pet_name='pet_name_2',
    name_debris='pet_font_2'
  },
  {
    name_container='pet_3',
    name_frame='pet_frame_3',
    name_level_bg='pet_type_3',
    name_level_text='pet_level_3',
    name_pic='pet_pic_3',
    name_pet_name='pet_name_3',
    name_debris='pet_font_3'
  }
--  {
--    name_container='pet_4',
--    name_frame='pet_frame_4',
--    name_level_bg='pet_type_4',
--    name_level_text='pet_level_4',
--    name_pic='pet_pic_4',
--    name_pet_name='pet_name_4',
--    name_debris='pet_font_4'
--  },
}

local _UI_NUM = #_ui_data

--位置/宠物数据
local _pet_id_index={
  [30001]=1,
  [30002]=2,
  [30003]=3,
  [30004]=4,
  [30005]=5,
}
local _pet_data = 
{
  {
    id = 30001,
    index = 1,
    path_pic = 'ui/heros/30001.png',
    path_name = 'ui/pets/font_pet_2.png',
    desc_format = [[
宠物能力(等级%d/%d)
无敌道具的时间加成%.2g秒
进阶剑士获得免疫弓箭伤害的能力]],
    desc_format_level = "升级要求:升级碎片%d",
    offset = {x=0,y=0},
    pos = {}
  },
  {
    id = 30002,
    index = 2,
    path_pic = 'ui/heros/30002.png',
    path_name = 'ui/pets/font_pet_4.png',
    desc_format = [[宠物能力(等级%d/%d)
冲刺道具的时间加成%.2g秒
进阶弓手可射出5支箭。]],
    desc_format_level = "升级要求:升级碎片%d",
    offset = {x=0,y=0},
    pos = {}
  },
  {
    id = 30003,
    index = 3,
    path_pic = 'ui/heros/30003.png',
    path_name = 'ui/pets/font_pet_3.png',
    desc_format = [[
宠物能力(等级%d/%d)
炸弹道具的时间加成%.2g秒
进阶法师可施放两个火球。]],
    desc_format_level = "升级要求:升级碎片%d",
    offset = {x=0,y=0},
    pos = {}
  },
  {
    id = 30004,
    index = 4,
    path_pic = 'ui/heros/30004.png',
    path_name = 'ui/pets/font_pet_5.png',
    desc_format = [[
宠物能力(等级%d/%d)
获得金币的量加成%.2g%%
绿巨人的技能间隔时间缩短。]],
    desc_format_level = "升级要求:升级碎片%d",
    offset = {x=0,y=0},
    pos = {}
  },
  {
    id = 30005,
    index = 5,
    path_pic = 'ui/heros/30005.png',
    path_name = 'ui/pets/font_pet_1.png',
    desc_format = [[
宠物能力(等级%d/%d)
英雄的攻击力增加%.2g%%
]],
    desc_format_level = "升级要求:升级碎片%d",
    offset = {x=0,y=-10},
    pos = {}
  },
}

local _PET_NUM = #_pet_data


------
local function _pos2data(self, pos_index)
  return _pet_data[self._left_data_index + pos_index - 1]
end

local function _id2data(self, id)
  return _pet_data[ _pet_id_index[id] ]
end

local function _id2pos(self, id)
  local data_index = _pet_id_index[id]
  return data_index - self._left_data_index + 1
end


local function _setEquipArrow(self)
  if not _player.get().pets.cur then
    return
  end
  local pos = _id2pos(self,_player.get().pets.cur)
  if pos < 1 or pos > _UI_NUM then
     self._pet_equip:setVisible(false)
     return
  end
  local ui = self._pet_items[pos]
  local cx, cy = ui.cont:getPosition()
  local px, py = ui.pic:getPosition()
  self._pet_equip:setPosition( cx+px, cy+py-15 )
  self._pet_equip:setVisible(true)

end

local function _setChooseArrow(self)
  local pos = _id2pos(self, self._curr_choose_id)
  local ui = self._pet_items[pos]
  
  local cx, cy = ui.cont:getPosition()
  local px, py = ui.pic:getPosition()
  self._pet_choose:setPosition( cx+px, cy+py-15 )
end

local function _resetPetDesc(self)
  local data = _id2data(self, self._curr_choose_id)
  
  local pdata = _player.get().pets[self._curr_choose_id]
  local sdata = _pets_sdata[self._curr_choose_id]
  
  local buff = 0
  local lv = pdata.level
  if lv > 0 then
    buff = sdata.buff_1st + sdata.buff_level*(lv-1)
  end
  self._pet_desc:setString(
    string.format(data.desc_format,
      pdata.level, sdata.max_level, buff)
  )
  self._pet_value_level:setString(
    string.format(data.desc_format_level,sdata.debris_levelup)
  )

  local pos_id = _pet_id_index[self._curr_choose_id]
  self._pet_desc:setPosition(_pet_data[pos_id].pos)
  self._pet_value_level:setPositionX(self._pet_desc:getPositionX())
end

local function _resetPetDebris(self)
  local num = _player.get().pets.level_debris
  self._pet_debris:setString( string.format('%d', num) )
end

local function _resetOnePic(self, pos, pet_data)
  local ui = self._pet_items[pos]
  local pdata = _player.get().pets[pet_data.id]
  local sdata = _pets_sdata[pet_data.id]
  
  ui.pic:setSpriteFrame(pet_data.path_pic)
  ui.pet_name:setSpriteFrame(pet_data.path_name)
  
  if pdata.level <= 0 then
    ui.pic:setColor(_CLR_BLACK)
    ui.level_bg:setSpriteFrame('ui/pets/font_no.png')
    ui.level_text:setVisible(false)
    ui.debris:setVisible(true)
    ui.debris:setString( 
      string.format('%d/%d', 
        pdata.debris, sdata.debris_unlock)
    )
    ui.level_bg:setPosition(ui.level_bg_pos[2])
  else
    ui.pic:setColor(_CLR_NORMAL)
    ui.level_bg:setSpriteFrame('ui/pets/pets_level.png')
    ui.level_text:setVisible(true)
    ui.level_text:setString( string.format('%d', pdata.level) )
    --合成的宠物隐藏碎片
    ui.debris:setVisible(false)
    ui.level_bg:setPosition(ui.level_bg_pos[1])
  end

end

local function _resetAllPos(self, start)  
  self._left_data_index = start
  for i=1, _UI_NUM do
    local data = _pos2data(self, i)
    _resetOnePic(self, i, data)
  end
  self._btn_left:setVisible( start > 1)
  self._btn_right:setVisible( start + _UI_NUM <= _PET_NUM )
end
------
local function _onBtnGet(self)
  local panel = require('game.ui.panel')
  local dlg = panel.Panel{
    modal=true,
    ani=true,
    type_panel=panel.GOBOSS,
    cb_enter = function()
      self:destroy()
      self._user_table.cbFightBoss()
    end,
  }
end

local function _onBtnLevelUp(self)
  local pets = _player.get().pets
  local id = self._curr_choose_id
    
  local level  = pets[id].level
  local pos    = cc.p(self._pet_choose:getPosition())
  pos.y = pos.y + 120
  if level <= 0 then
    _popupTip("这个宠还未合成",_CLR_TIP,pos)
    return
  end

  

  local sdata = _pets_sdata[id]
  if level >= sdata.max_level then
    _popupTip("宠物已满级",_CLR_TIP,pos)
    return
  end
  
  local debris = pets.level_debris
  if debris < sdata.debris_levelup then
    _popupTip("碎片不足",_CLR_TIP,pos)
    return
  end
    
  pets[id].level = level + 1
  pets.level_debris = debris - sdata.debris_levelup
  
  _player.setDirty()
  _player.save()
  
  _resetOnePic(self, _id2pos(self,id), _id2data(self,id))
  _resetPetDesc(self)
  _resetPetDebris(self)
end

local function _onBtnEquip(self)
  local id = self._curr_choose_id
  local pets = _player.get().pets
  local pos    = cc.p(self._pet_choose:getPosition())
  if pets.cur == id then
       --卸下宠物
       self._pet_equip:setVisible(false)

        pets.cur = nil
  else
     --装备/切换宠物
     if pets[id].level <= 0 then
        _popupTip("这个宠还未合成", _CLR_TIP,{x=pos.x,y=pos.y+110})
        return
     end
     self._pet_equip:setVisible(true)
     self._pet_equip:setPosition(pos)

     pets.cur = id
  end
  
  
  _player.setDirty()
  _player.save()

end
local _initEquip
local function _choose(self, pos)
  local id = _pos2data(self, pos).id
  if self._curr_choose_id == id then
    return
  end

  self._curr_choose_id = id
  _setChooseArrow(self)
  _setEquipArrow(self)
  _resetPetDesc(self)
end


local function _updateChoose(self)
  if not self._curr_choose_id then
    return
  end
  local pos = _id2pos(self, self._curr_choose_id)
  if pos < 1 then
    _choose(self, 1)
  elseif pos > _UI_NUM then
    _choose(self, _UI_NUM)
  else
    _setChooseArrow(self)
  end
end

local function _updateEquip(self)
  if not _player.get().pets.cur then
    return
  end
  local pos = _id2pos(self,_player.get().pets.cur)
  local is_equip
  if pos < 1 or pos > _UI_NUM then
     is_equip = false
  else
     is_equip = true
     _setEquipArrow(self)
  end
  self._pet_equip:setVisible(is_equip)
end
_initEquip =  function(self)
    if _player.get().pets.cur then
        local pos = _id2pos(self,_player.get().pets.cur)
        if pos >= 1 and pos <= _UI_NUM then
            _updateEquip(self)
            return
        end
    end
    self._pet_equip:setVisible(false)
end
local function _onBtnLeft(self)
  local left = self._left_data_index
  if left > 1 then
    _resetAllPos(self, left -1)
    _updateChoose(self)
    _updateEquip(self)
  end
end

local function _onBtnRight(self)
  local left = self._left_data_index
  if left + _UI_NUM <= _PET_NUM then
    _resetAllPos(self, left +1)
    _updateChoose(self)
    _updateEquip(self)
  end
end

local function _load(self)
  local panel = cc.CSLoader:createNode('ui/pets.csb')

  self._pet_choose = ccui.Helper:seekWidgetByNameOnNode(panel, 'pet_choose')
  self._pet_equip  = ccui.Helper:seekWidgetByNameOnNode(panel, 'pet_equip')
  
  local btn
  btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_left')
  btn:addTouchEventListener(
    _misc.createClickCB(function()
      _onBtnLeft(self)
    end
  ))
  self._btn_left = btn

  btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_right')
  btn:addTouchEventListener(
    _misc.createClickCB(function()
      _onBtnRight(self)
    end
  ))
  self._btn_right = btn

  self._pet_items = {}
  for i,names in ipairs(_ui_data) do
    local t = {}
    self._pet_items[i] = t
    
    local cont = ccui.Helper:seekWidgetByNameOnNode(panel, names.name_container)
    
    t.cont = cont
    t.frame = cont:getChildByName(names.name_frame)
    t.level_bg = panel:getChildByName(names.name_level_bg)
    t.level_text = t.level_bg:getChildByName(names.name_level_text)
    t.pic = cont:getChildByName(names.name_pic)
    t.pet_name = cont:getChildByName(names.name_pet_name)
    t.debris = ccui.Helper:seekWidgetByNameOnNode(panel, names.name_debris)
    
    t.level_bg_pos = {cc.p(t.level_bg:getPosition()),
                      cc.p(t.level_bg:getPositionX()+66,t.level_bg:getPositionY()+14)}
      
    cont:addTouchEventListener(
      _misc.createClickCB(
        function()
          _choose(self, i)
        end
    ) )
  end
  self._pet_desc = ccui.Helper:seekWidgetByNameOnNode(panel, 'pets_value')
  self._pet_debris = ccui.Helper:seekWidgetByNameOnNode(panel, 'pet_debris')
  self._pet_value_level = ccui.Helper:seekWidgetByNameOnNode(panel, 'pets_value_level')

  local tmp_pos = cc.p(self._pet_desc:getPosition())
  for i=1,#_pet_data do
      _pet_data[i].pos.x = tmp_pos.x + _pet_data[i].offset.x
      _pet_data[i].pos.y = tmp_pos.y + _pet_data[i].offset.y
  end
  


  btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
  btn:addTouchEventListener(
    _misc.createClickCB(
      function()
        self:destroy()
        self._user_table.cbEndBack()
      end
  ))
  
  btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_get')
  btn:addTouchEventListener(
    _misc.createClickCB(function()
      _onBtnGet(self)
    end
  ))

  btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_uplevel')
  btn:addTouchEventListener(
    _misc.createClickCB(function()
      _onBtnLevelUp(self)
    end
  ))

  btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_wear')
  btn:addTouchEventListener(
    _misc.createClickCB(function()
      _onBtnEquip(self)
    end
  ))

  
  return panel
end


Pets = require('util.class').class(_base_panel)

--[[
tab: 回调函数表
{
cbFightBoss: 进入boss战斗
cbEndBack: 取消
}
]]
Pets.ctor = function(self, tab)
  local panel = _load(self)
  self._panel = panel
  self._user_table = tab
  self.__super_ctor__(self, panel, tab.modal, tab.ani)
  --Test(self)
  
  --_left_data_index 最左位置对应的pet_data索引
  --_curr_choose_id  --当前选中的id
  
  --_pet_equip  装备
  --_pet_choose 选择勾
  --_btn_left
  --_btn_right
  --_pet_desc 描述
  --_pet_value_level 描述升级碎片
  --_pet_debris 碎片
  --_pet_items ui对象，从_ui_data的名字查得，名为去掉 name_ 得到
end

Pets.inst_meta.onEnter = function(self)
  local start = 1
  _resetAllPos(self, start)
  
  self._curr_choose_id = nil
  _initEquip(self)
  _choose(self, start)
  _resetPetDebris(self)
  
  local guide = require('game.guide_logic')
  guide.checkPetGuide(2, 
    self._panel, self._pet_items[1].frame,
    function() end)
end
---------滑动测试---------
function Test(self)
    local n = 0
    local _ScrollView = self._panel:getChildByName('ScrollView_1')
    for i=1,8 do
        local btn = _ScrollView:getChildByName(string.format("p_%d",i))
        btn:addTouchEventListener(function(object, event)
          if event == ccui.TouchEventType.ended then
            if n >= 100 then
                n = -25
            end
            n = n + 25
            cclog("i ==== " ..i)
            _ScrollView:scrollToPercentHorizontal(n,1,true)--0~100,time,滚动动画
          end
        end)
    end
    _ScrollView:setInnerContainerSize(cc.size(9*100,_ScrollView:getContentSize().height))
    --_ScrollView:setInertiaScrollEnabled(false)
   
    local _spr = ccui.ImageView:create()
    _spr:setAnchorPoint(0,0.5)
    _spr:loadTexture("ui/heros/10001.png",ccui.TextureResType.plistType)--cc.Sprite:createWithSpriteFrameName("ui/heros/10001.png")
    _ScrollView:addChild(_spr)
    _spr:setTouchEnabled(true)
    
    --self._panel:addChild(_spr)
    local btn = _ScrollView:getChildByName(string.format("p_%d",8))
    _spr:setPosition(cc.p(btn:getPositionX()+100,btn:getPositionY()))
    _spr:addTouchEventListener(function(object, event)
          if event == ccui.TouchEventType.ended then
             if n >= 100 then
                n = -25
             end
             n = n + 25
             cclog("i ==== 9")
             _ScrollView:scrollToPercentHorizontal(n,0,false)--0~100,time,滚动动画
          end
        end)
end

