module('game.ui.heropanel', package.seeall)

--英雄选择界面
local _guide_logic = require('game.guide_logic')
local _tool   = require('util.tool')
local _misc   = require('util.misc')

local _player = require('game.player')
local _data_heros = require('data.hero').heros
local _data_ability = require('data.ability').heros

local _charge = require('game.charge')
local _charge_data = require('data.charge')
local _text = require('data.text')

local _popupTip = require('game.mgr_scr').popupTip

--全动态数据
local _data = {
    --layer
    --user_table  --玩家传入的参数
    --ignore_advance_strike_charge  --进阶出击不付费，引导时用
    
    --left_data_index  --显示角色部分，最左角色对应在_roles_data的索引
    --cur_choose_id --当前所选英雄的id
    --[[
    pop_max_level={
      [role_id]=boolean,  点升级时，该角色是否弹满级礼包
    }
    ]]
}
--滚动选择英雄相关数据
local _scroll_data = {
    _roles = {},--用于滑动功能英雄数据

    child_data = 
    {
        pic   = "pic",
        lock  = "lock",
        name  = "name",
        tag   = "tag",
        level = "level",
        cur   = "cur"
    },
    cur_move = 0,--当前总单位移动位置
    unit     = 34,--单位移动位置  34:7个  50:6个  94:5个
    offset   = 0--移动偏移量
}


--界面元素。部分动态数据，控件名字静态，其它则在打开时引用内部对象，退出时清除引用
local _ui_data ={
    --cur_power
    --next_power
    --cur_interval
    --next_interval
    --cur_distance
    --next_distance
    --my_gold
    --require_gold

    --ui中，4个角色位置的元素，是 名字：实际对象
    roles = {
      {
        name_pic='pic_1', pic=nil,
        name_lock='lock_1', lock=nil,
        name_lv_tag='level_tag_1', lv_tag=nil,
        name_lv_text='level_text_1', lv_text=nil,
        name_career='font_1', career=nil,
      },
      {
        name_pic='pic_2', pic=nil,
        name_lock='lock_2', lock=nil,
        name_lv_tag='level_tag_2', lv_tag=nil,
        name_lv_text='level_text_2', lv_text=nil,
        name_career='font_2', career=nil,
      },
      {
        name_pic='pic_3', pic=nil,
        name_lock='lock_3', lock=nil,
        name_lv_tag='level_tag_3', lv_tag=nil,
        name_lv_text='level_text_3', lv_text=nil,
        name_career='font_3', career=nil,
      },
      {
        name_pic='pic_4', pic=nil,
        name_lock='lock_4', lock=nil,
        name_lv_tag='level_tag_4', lv_tag=nil,
        name_lv_text='level_text_4', lv_text=nil,
        name_career='font_4', career=nil,
      }
    },
    --btn_left  左按钮
    --btn_right 右按钮

    --choose
    --levelup_btn
    --advanced_btn
    --advanced_btn_rect
    --money_text

    ---演示相关
    --l_hole r_hole
    --l_scene r_scene

    --进阶演示、出击的粒子特效元素
    --effect_1 ~ effect_6
    --particle_1 ~ particle_5
}

--以下是静态配置，运行时不应修改及增删内容

--角色id -> _roles_data表索引
local _roles_id_index = {
  [10001]=1,
  [11001]=2,
  [12001]=3,
  [16001]=4,
  [13001]=5,
  [10002]=6,
  [10004]=7,
}
--各角色的配置数据
local _roles_data = {
  [1]={
    index=1,
    id=10001,
    --该角色的图片、职业
    pic_path = 'ui/heros/10001.png',
    career_path = 'ui/choose/font_js.png',
    --进阶角色演示、进阶出击元素的特效
    effect_1_path = 'ui/choose/js_effect_1.png',
    effect_2_path = 'ui/choose/js_effect_2.png',
    effect_3_path = 'ui/choose/js_effect_3.png',
    effect_4_path = 'ui/choose/js_effect_4.png',
    effect_5_path = 'ui/choose/js_effect_5.png',
    effect_6_path = 'ui/choose/js_effect_6.png',

    particle_1_path = "res/effect/fire/js_fire_1.plist",
    particle_2_path = "res/effect/fire/js_fire_2.plist",
    particle_3_path = "res/effect/fire/js_fire_3.plist",
    particle_4_path = "res/effect/fire/js_fire_4.plist",
    particle_5_path = "res/effect/fire/js_effect.plist",

  },
  [2]={
    index=2,
    id=11001,
    
    pic_path = 'ui/heros/11001.png',
    career_path = 'ui/choose/font_gjs.png',
    
    effect_1_path = 'ui/choose/gjs_effect_1.png',
    effect_2_path = 'ui/choose/gjs_effect_2.png',
    effect_3_path = 'ui/choose/gjs_effect_3.png',
    effect_4_path = 'ui/choose/gjs_effect_4.png',
    effect_5_path = 'ui/choose/gjs_effect_5.png',
    effect_6_path = 'ui/choose/gjs_effect_6.png',

    particle_1_path = "res/effect/fire/gjs_fire_1.plist",
    particle_2_path = "res/effect/fire/gjs_fire_2.plist",
    particle_3_path = "res/effect/fire/gjs_fire_3.plist",
    particle_4_path = "res/effect/fire/gjs_fire_4.plist",
    particle_5_path = "res/effect/fire/gjs_effect.plist",
  },
  [3]={
    index=3,
    id=12001,
    
    pic_path = 'ui/heros/12001.png',
    career_path = 'ui/choose/font_mfs.png',
    
    effect_1_path = 'ui/choose/mfs_effect_1.png',
    effect_2_path = 'ui/choose/mfs_effect_2.png',
    effect_3_path = 'ui/choose/mfs_effect_3.png',
    effect_4_path = 'ui/choose/mfs_effect_4.png',
    effect_5_path = 'ui/choose/mfs_effect_5.png',
    effect_6_path = 'ui/choose/mfs_effect_6.png',

    particle_1_path = "res/effect/fire/mfs_fire_1.plist",
    particle_2_path = "res/effect/fire/mfs_fire_2.plist",
    particle_3_path = "res/effect/fire/mfs_fire_3.plist",
    particle_4_path = "res/effect/fire/mfs_fire_4.plist",
    particle_5_path = "res/effect/fire/mfs_effect.plist",
  },
  [4]={
    index=4,
    id=16001,
    
    pic_path = 'ui/heros/16001.png',
    career_path = 'ui/choose/font_cjs.png',
    
    effect_1_path = 'ui/choose/kxj_effect_1.png',
    effect_2_path = 'ui/choose/kxj_effect_2.png',
    effect_3_path = 'ui/choose/kxj_effect_3.png',
    effect_4_path = 'ui/choose/kxj_effect_4.png',
    effect_5_path = 'ui/choose/kxj_effect_5.png',
    effect_6_path = 'ui/choose/kxj_effect_6.png',

    particle_1_path = "res/effect/fire/ljr_fire_1.plist",
    particle_2_path = "res/effect/fire/ljr_fire_2.plist",
    particle_3_path = "res/effect/fire/ljr_fire_3.plist",
    particle_4_path = "res/effect/fire/ljr_fire_4.plist",
    particle_5_path = "res/effect/fire/ljr_effect.plist",
  },
  [5]={
    index=5,
    id=13001, 
    
    pic_path = 'ui/heros/13001.png',
    career_path = 'ui/choose/font_fs.png',
    
    effect_1_path = 'ui/choose/js_effect_1.png',
    effect_2_path = 'ui/choose/js_effect_2.png',
    effect_3_path = 'ui/choose/js_effect_3.png',
    effect_4_path = 'ui/choose/js_effect_4.png',
    effect_5_path = 'ui/choose/js_effect_5.png',
    effect_6_path = 'ui/choose/js_effect_6.png',

    particle_1_path = "res/effect/fire/js_fire_1.plist",
    particle_2_path = "res/effect/fire/js_fire_2.plist",
    particle_3_path = "res/effect/fire/js_fire_3.plist",
    particle_4_path = "res/effect/fire/js_fire_4.plist",
    particle_5_path = "res/effect/fire/js_effect.plist",
  },
  [6]={
    index=6,
    id=10002, 

    pic_path = 'ui/heros/10002.png',
    career_path = 'ui/choose/font_shz.png',

    effect_1_path = 'ui/choose/mfs_effect_1.png',
    effect_2_path = 'ui/choose/mfs_effect_2.png',
    effect_3_path = 'ui/choose/mfs_effect_3.png',
    effect_4_path = 'ui/choose/mfs_effect_4.png',
    effect_5_path = 'ui/choose/mfs_effect_5.png',
    effect_6_path = 'ui/choose/mfs_effect_6.png',

    particle_1_path = "res/effect/fire/mfs_fire_1.plist",
    particle_2_path = "res/effect/fire/mfs_fire_2.plist",
    particle_3_path = "res/effect/fire/mfs_fire_3.plist",
    particle_4_path = "res/effect/fire/mfs_fire_4.plist",
    particle_5_path = "res/effect/fire/mfs_effect.plist",
  },
  [7]={
    index=7,
    id=10004, 

    pic_path = 'ui/heros/10004.png',
    career_path = 'ui/choose/font_yr.png',

    effect_1_path = 'ui/choose/gjs_effect_1.png',
    effect_2_path = 'ui/choose/gjs_effect_2.png',
    effect_3_path = 'ui/choose/gjs_effect_3.png',
    effect_4_path = 'ui/choose/gjs_effect_4.png',
    effect_5_path = 'ui/choose/gjs_effect_5.png',
    effect_6_path = 'ui/choose/gjs_effect_6.png',

    particle_1_path = "res/effect/fire/gjs_fire_1.plist",
    particle_2_path = "res/effect/fire/gjs_fire_2.plist",
    particle_3_path = "res/effect/fire/gjs_fire_3.plist",
    particle_4_path = "res/effect/fire/gjs_fire_4.plist",
    particle_5_path = "res/effect/fire/gjs_effect.plist",
  },
} --_roles_data


local _ROLE_DEFAULT_ID = 10001
local _CLR_BLACK = {r=0,g=0,b=0}
local _CLR_NORMAL = {r=255,g=255,b=255}

local _ROLES_POS_NUM = #_ui_data.roles
local _ROLES_DATA_NUM = #_roles_data


--local function _indexData2pos(data_index)
--  return data_index - _data.left_data_index + 1
--end

--local function _indexPosndex2data(pos_index)
--  return _data.left_data_index + pos_index - 1
--end

--local function _roleid2PosIndex(role_id)
--  return _roles_id_index[role_id] - _data.left_data_index + 1
--end

--local function _roleidFromPosIndex(pos_index)
--  return _roles_data[_data.left_data_index + pos_index - 1].id
--end

--local function _dataFromRoleid(role_id)
--  return _roles_data[_roles_id_index[role_id]]
--end
--local function _roleidFromDataIndex(data_index)
--  return _roles_data[data_index].id
--end

--[[
说明：这里很复杂，说明一下
界面信息主要分5部分管理：
  角色头像部分：包括角色图、职业名、级数、解锁等等。
    _resetRolePic、_makeRoleVisible、_resetAllPos、_onButtonLeft(Right)
  角色相关数据：包括三围数值、升级金钱。_showRoleData
  角色演示demo：_showDemo
  角色相关特效：_showEffect
  玩家金钱：_resetGold
  打勾的位置: _setChooseArrow ...
  
ui上只有固定个数的角色头像，这些头像的位置顺序称为位置索引 pos_index.
  ui上的控件对象信息，记录在 _ui_data.roles[...] 里
实际角色比ui多，这些角色有不同的 头像图、职业名、特效等，
  其数据记录在 _roles_data[..] 里，在此处的索引称为位置索引 data_index.
运行时，根据当前操作，不断更新ui几个位置的信息，以达到滚动效果。

根据当前拖动情况，pos_index, data_index, 角色id可以互转，
上面提供一些函数辅助操作。
更细节关系，请看 _roles_id_index, _roles_data, _ui_data.roles 这几个表的数据
]]

--战斗demo函数（在后面定义）
local _showDemo

--显示拥有金钱数
local function _resetGold()
  _ui_data.my_gold:setString(string.format('%.0fG', _player.get().golds))
end

--更新选中勾的位置
--local function _setChooseArrow(pos_index)
--  local lock = _ui_data.roles[pos_index].lock
--  _ui_data.choose:setPosition(lock:getPosition())
--end
local function _setChooseArrowEx(pos_index)
    for i,v in ipairs(_scroll_data._roles) do
        local _cur = v:getChildByName(_scroll_data.child_data.cur)
        if i == pos_index then
            _cur:setVisible(true)
        else
            _cur:setVisible(false)
        end
    end
end

--升级
local function _doLevelUp(role_id)
  local player_data = _player.get()
  
  local info = _data_ability[role_id]
  local next_lv = player_data.heros_level[role_id] + 1
  if next_lv > #info then
    _popupTip(_text.tips[2])
    return
  end
  
  --金钱不足，弹金币礼包
  if player_data.golds < info[next_lv].golds then
    _popupTip(_text.tips[3])
    
    local panel = require('game.ui.panel')
    local dlg = panel.Panel{
      modal=true,
      ani=true,
      type_panel=panel.GOLD,
      cb_enter=_resetGold,
      endback=function() end,
    }
    return false
  end
  
  --更新自己和进阶者的级数，马上保存一下
  player_data.golds = player_data.golds - info[next_lv].golds
  player_data.heros_level[role_id] = next_lv
  local adv_id = _data_heros[role_id].advance_id
  player_data.heros_level[adv_id] = next_lv
  _player.setDirty()
  _player.save()
  return true
end

--
local function _MaxLevelUp(role_id)
  local info  = _data_ability[role_id]
  local hlevel = _player.get().heros_level
  
  if hlevel[role_id] >= #info then
    _popupTip(_text.tips[2])
    return false
  end

  hlevel[role_id] = #info
  local sdata = _data_heros[role_id]
  hlevel[sdata.primitive_id or sdata.advance_id] = #info
  _player.setDirty()
  _player.save()
  return true
end

--出击
local function _onButtonStrike()
  local heros_level = _player.get().heros_level
  local id = _data.cur_choose_id
  if heros_level[id] <= 0 then
    _popupTip(_text.tips[4])
    return
  end
  _data.user_table.cb_strike(id)
end

--进阶出击
local function _onButtonAdvanceStrike()
  local id = _data.cur_choose_id
  local adv_id = _data_heros[id].advance_id

  local function notify(id)
    _data.user_table.cb_advance_strike(id)
  end

  --不收费或已解锁
  if _data.ignore_advance_strike_charge 
     or _player.get().heros_unlock[adv_id] 
  then
    notify(adv_id)
    return
  end

  --有可能是金币解锁，玩家购买或消耗了金币
  --但不管如何都设下数值，没什么影响。。。
  local panel = require('game.ui.panel')
  local dlg = panel.Panel{
    modal=true,
    ani=true,
    type_panel=panel.UNLOCK,
    hero_id=adv_id,
    cb_enter=function()
      _resetGold()
      notify(adv_id)
    end,
    endback=function()
      _resetGold()
    end
  }

end

--返回
local function _onButtonBack()
  local cb = _data.user_table.cb_back
  if cb then cb() end
end


--
--[[
  重置一个角色的头像等信息
  role_id: 角色id。若为nil则用默认id
  pos_index: 位置索引。若为nil则查找当前索引并按需更新
]]
--local function _resetRolePic(role_id, pos_index)
--  role_id = role_id or _data.cur_choose_id

--  if not role_id then return end

--  if not pos_index then
--    pos_index = _roleid2PosIndex(role_id)
--    if pos_index<1 or pos_index>_ROLES_POS_NUM then

--      return
--    end
--  end

--  local level = _player.get().heros_level[role_id]
--  local data = _dataFromRoleid(role_id)
--  local ui = _ui_data.roles[pos_index]
--  ui.pic:loadTexture(data.pic_path, ccui.TextureResType.plistType)
--  ui.career:loadTexture(data.career_path, ccui.TextureResType.plistType)


--  local ability = _data_ability[role_id]
--  if level <= 0 then
--    ui.pic:setColor(_CLR_BLACK)
--    ui.lock:setVisible(false) --改  ui.lock:setVisible(true)
--    ui.lv_tag:setVisible(false)

--  else
--    ui.pic:setColor(_CLR_NORMAL)
--    ui.lock:setVisible(false)
--    ui.lv_tag:setVisible(false)--改    ui.lv_tag:setVisible(true)
--  end
--end
local function _resetRolePicEx(role_id, pos_index)
    local level = _player.get().heros_level[role_id]
    --local ui = _ui_data.roles[pos_index]

    local _scroll_roles = _scroll_data._roles[pos_index]
    local ability = _data_ability[role_id]
    local _tag = _scroll_roles:getChildByName(_scroll_data.child_data.tag)
    local _level = _tag:getChildByName(_scroll_data.child_data.level)
    if level <= 0 then
        _scroll_roles:getChildByName(_scroll_data.child_data.pic):setColor(_CLR_BLACK)
        _scroll_roles:getChildByName(_scroll_data.child_data.lock):setVisible(true)
        _scroll_roles:getChildByName(_scroll_data.child_data.tag):setVisible(false)

        _level:setScale(1)
    else
        _scroll_roles:getChildByName(_scroll_data.child_data.pic):setColor(_CLR_NORMAL)
        _scroll_roles:getChildByName(_scroll_data.child_data.lock):setVisible(false)
        _scroll_roles:getChildByName(_scroll_data.child_data.tag):setVisible(true)

        _level:setString(level<#ability and tostring(level) or 'MAX')
        _level:setScale(0.7)
        --ui.lv_text:setString(level<#ability and tostring(level) or 'MAX')
    end
end
local function _resetAllPos(left_data_index)
--  _data.left_data_index = left_data_index
--  for i=1, _ROLES_POS_NUM do
--    _resetRolePic(_roleidFromPosIndex(i), i)
--  end
--  _ui_data.btn_left:setVisible(true)   --改  _ui_data.btn_left:setVisible( left_data_index > 1)
--  _ui_data.btn_right:setVisible(true)  --改 _ui_data.btn_right:setVisible(left_data_index + _ROLES_POS_NUM <= _ROLES_DATA_NUM)

  --同步
  for i=1,_ROLES_DATA_NUM do
    _resetRolePicEx(_roles_data[i].id, i)
  end
end

--让指定角色可见。返回该角色在ui上的位置索引
--注：不更新选择位置
local function _makeRoleVisible(rold_id)
--  local left = _data.left_data_index
  local index = _roles_id_index[rold_id]
--  if index < left then
--    left = index
--  elseif index >= left + _ROLES_POS_NUM then
--    left = index - _ROLES_POS_NUM + 1
--  end
  _resetAllPos()--(left)
  --return index-left+1
  return index
end

--显示英雄相关的数据信息
local function _showRoleData(role_id)
  local level = _player.get().heros_level[role_id]
  local ability = _data_ability[role_id]
  
  local info = ability[level]
  --数据
  local f = string.format
  if level > 0 then
    _ui_data.cur_power:setString(f('%d', info.power))
    _ui_data.cur_interval:setString(f('%d', info.interval))
    _ui_data.cur_distance:setString(f('%d', info.distance))
  else
    _ui_data.cur_power:setString('')
    _ui_data.cur_interval:setString('')
    _ui_data.cur_distance:setString('')
  end
  
  if level < #ability then
    local n = ability[level+1]
    _ui_data.next_power:setString(f('%d', n.power))
    _ui_data.next_interval:setString(f('%d', n.interval))
    _ui_data.next_distance:setString(f('%d', n.distance))
    _ui_data.require_gold:setString(f('%.0f', n.golds))
  else
    _ui_data.next_power:setString('')
    _ui_data.next_interval:setString('')
    _ui_data.next_distance:setString('')
    _ui_data.require_gold:setString('')
  end
  --解锁升级按钮
  if level < #ability then
    _ui_data.levelup_btn:setVisible(true)
    _ui_data.levelup_btn:setTitleText(level<=0 and "解锁" or "升级")
    _ui_data.require_gold:setVisible(level>0)
  else
    _ui_data.levelup_btn:setVisible(false)
  end

  --显示资费信息
  local advance_id = _data_heros[role_id].advance_id
  local unlocks = _player.get().heros_unlock
  if _data.ignore_advance_strike_charge
    or unlocks[advance_id] 
  then
    --_ui_data.money_text:setVisible(false)
  else
--    _ui_data.money_text:setVisible(true)
--    _ui_data.money_text:setString(
--      string.format(_text.ui_charge_format, _charge_data.unlock[advance_id].rmb)
--    )
  end
end


--移出所有粒子
local function _resetParticle()
  local d = _ui_data
  if d.particle_1 then
    d.particle_1:removeFromParent()
    d.particle_2:removeFromParent()
    d.particle_3:removeFromParent()
    d.particle_4:removeFromParent()
    d.particle_5:removeFromParent()
    d.particle_1 = nil
    d.particle_2 = nil
    d.particle_3 = nil
    d.particle_4 = nil
    d.particle_5 = nil
  end
end

--显示特效
local function _showEffect(role_id)
  local r = _roles_data[_roles_id_index[role_id]]
  local d = _ui_data
  
  --切换图片
  d.effect_1:setSpriteFrame(r.effect_1_path)
  d.effect_2:setSpriteFrame(r.effect_2_path)
  d.effect_3:setSpriteFrame(r.effect_3_path)
  d.effect_4:setSpriteFrame(r.effect_4_path)
  d.effect_5:setSpriteFrame(r.effect_5_path)
  d.effect_6:setSpriteFrame(r.effect_6_path)

  --设置粒子
  _resetParticle()

  --演示框
  d.particle_1 = cc.ParticleSystemQuad:create(r.particle_1_path)--左
  d.particle_2 = cc.ParticleSystemQuad:create(r.particle_2_path)--上
  d.particle_3 = cc.ParticleSystemQuad:create(r.particle_3_path)--右
  d.particle_4 = cc.ParticleSystemQuad:create(r.particle_4_path)--下

  d.particle_1:setPosition(d.effect_1:getPosition())
  d.particle_2:setPosition(d.effect_2:getPosition())
  d.particle_3:setPosition(d.effect_3:getPosition())
  d.particle_4:setPosition(d.effect_4:getPositionX(), d.effect_4:getPositionY()-30)

  --进阶出击
  d.particle_5 = cc.ParticleSystemQuad:create(r.particle_5_path)
  d.particle_5:setPosition(d.advanced_btn_rect.x, 
    d.advanced_btn_rect.y - d.advanced_btn_rect.height*0.5)

  _data.layer:addChild(d.particle_1,10)
  _data.layer:addChild(d.particle_2,10)
  _data.layer:addChild(d.particle_3,10)
  _data.layer:addChild(d.particle_4,10)
  _data.layer:addChild(d.particle_5,10)
end

--选择英雄
local function _chooseRole(pos_index)
  local role_id = _roles_data[pos_index].id--_roleidFromPosIndex(pos_index)
  if _data.cur_choose_id == role_id then
    return
  end
  _showRoleData(role_id)
  _showDemo(role_id)
  _showEffect(role_id)
  --_setChooseArrow(pos_index)
  _setChooseArrowEx(pos_index)
  _data.cur_choose_id = role_id
end
--再一次进入游戏默认选中刚玩的英雄
local function _ResumeRole(panel,index)
  local _ScrollView = panel:getChildByName("ScrollView")
  local n = _scroll_data.unit*(index-1)
  _ScrollView:scrollToPercentHorizontal(n,0.1,true)--0~100,time,滚动动画
end
--
--local function _updateChoose()
--  if not _data.cur_choose_id then
--    return
--  end
--  local pos = _roleid2PosIndex(_data.cur_choose_id)
--  if pos < 1 then
--    _chooseRole(1)
--  elseif pos > _ROLES_POS_NUM then
--    _chooseRole(_ROLES_POS_NUM)
--  else
--    _setChooseArrow(pos)
--  end
--end

--左右箭头逻辑
--local function _onButtonLeft()
--  local left = _data.left_data_index
--  if left > 1 then
--    _resetAllPos(left -1)
--    _updateChoose()
--  end
--end
local function _onButtonLeftEx(_ScrollView,cell_width)
    _scroll_data.offset = _ScrollView:getInnerContainer():getPositionX()
    local _ofset =  math.floor(math.abs(_scroll_data.offset)/cell_width)
    if _ofset == 0 then
        _ofset = 1
        _scroll_data.cur_move = 0
    else
        _scroll_data.cur_move = _scroll_data.unit*_ofset
    end
    _scroll_data.cur_move = _scroll_data.cur_move-_scroll_data.unit
               
    if _scroll_data.cur_move <= 0 then
        _scroll_data.cur_move = 0
    end
    _ScrollView:scrollToPercentHorizontal(_scroll_data.cur_move,1,true)--0~100,time,滚动动画
end

--local function _onButtonRight()
--  local left = _data.left_data_index
--  if left + _ROLES_POS_NUM <= _ROLES_DATA_NUM then
--    _resetAllPos(left +1)
--    _updateChoose()
--  end
--end
local function _onButtonRightEx(_ScrollView,cell_width)
    _scroll_data.offset = _ScrollView:getInnerContainer():getPositionX()
    local _ofset =  math.floor(math.abs(_scroll_data.offset)/cell_width)
    if _ofset == 0 then
        _ofset = 1
        _scroll_data.cur_move = 0
    else
        _scroll_data.cur_move = _scroll_data.unit*_ofset
    end
    for i = 1,_ofset do
        _scroll_data.cur_move = _scroll_data.cur_move + _scroll_data.unit
        if _scroll_data.cur_move >= 100 then
            _ScrollView:scrollToPercentHorizontal(100,1,true)--0~100,time,滚动动画
            return
        end
    end
    _ScrollView:scrollToPercentHorizontal(_scroll_data.cur_move,1,true)--0~100,time,滚动动画
end
--
local function _onButtonLevelUp()
  local _heros_level = _player.get().heros_level
  local id = _data.cur_choose_id
  local pos_id = _roles_id_index[id]
  --未解锁的提示
  if _heros_level[id] <= 0 then
    _popupTip(_text.tips[4])
    return
  end

  --正常升级(由于仓促  先暂时临时判断  这几个英雄直接升级不弹满级礼包)
  if not _data.pop_max_level[id] then
    if _doLevelUp(id) then
      _resetGold()
      --_resetRolePic(id)
      _resetRolePicEx(id,pos_id)
      _showRoleData(id)
      --升级后，用新的数值演示
      _showDemo(id)
    end
    return
  end
  
  --满级礼包
  _data.pop_max_level[id] = false
  local level = _heros_level[id]
  local ability = _data_ability[id]
  if level < #ability then
    local _panel = require('game.ui.panel')
    _panel.Panel{
      type_panel =_panel.MAXLEVEL,
      role_id = id,
      cb_enter = function()
        cclog("英雄升到满级")
        if _MaxLevelUp(id) then
          --_resetRolePic(id)
          _resetRolePicEx(id,pos_id)
          _showRoleData(id)
          _showDemo(id)
        end
      end,
      endback = function()
      end,
    }
  end
end
local function createScrollRole(panel,cell_width)
    local _ScrollView = ccui.Helper:seekWidgetByNameOnNode(panel, 'ScrollView')
    _ScrollView:setTouchEnabled(true)

    local offsetX = (#_roles_data-1)*10
    local _model = ccui.Helper:seekWidgetByNameOnNode(panel, 'cell')
    local _pic   = _model:getChildByName(_scroll_data.child_data.pic)
    
    local _lock  = _model:getChildByName(_scroll_data.child_data.lock)
    local _name  = _model:getChildByName(_scroll_data.child_data.name)
    local _tag   = _model:getChildByName(_scroll_data.child_data.tag)
    local _level = _tag:getChildByName(_scroll_data.child_data.level)
    local _textColor = _level:getColor()
    local _cur   = _model:getChildByName(_scroll_data.child_data.cur)
    _model:setVisible(false)
    
    _ScrollView:setInnerContainerSize(cc.size(#_roles_data*cell_width+offsetX,_ScrollView:getContentSize().height))
    
    for i,v in ipairs(_roles_data) do
        local _cell = ccui.ImageView:create()
        _cell:setAnchorPoint(_model:getAnchorPoint())
        _cell:loadTexture("ui/choose/hero_bg.png",ccui.TextureResType.plistType)
        _cell:setTouchEnabled(true)
        _cell:setScale9Enabled(true)
        _cell:setCapInsets(cc.rect(50,20,5,5))
        _cell:setContentSize(_model:getContentSize().width,_model:getContentSize().height)

        local _c_pic   = cc.Sprite:createWithSpriteFrameName(v.pic_path)
        local _c_lock  = cc.Sprite:createWithSpriteFrameName("ui/choose/lock.png")
        local _c_level = ccui.Text:create()
        local _c_name  = cc.Sprite:createWithSpriteFrameName(v.career_path)
        local _c_tag   = cc.Sprite:createWithSpriteFrameName("ui/choose/level_tag.png")
        local _c_cur   = cc.Sprite:createWithSpriteFrameName("ui/choose/gou.png")
        

        _c_level:setColor(_textColor)
        _c_level:setString(tostring(i))
        _c_level:setFontSize(_level:getFontSize())
        if i == 1 then
            _c_lock:setVisible(false)
            _c_cur:setVisible(true)
        else
            _c_cur:setVisible(false)
        end

        _c_pic:setPosition(cc.p(_pic:getPosition()))
        _c_lock:setPosition(cc.p(_lock:getPosition()))
        _c_level:setPosition(cc.p(_level:getPosition()))
        _c_name:setPosition(cc.p(_name:getPosition()))
        _c_tag:setPosition(cc.p(_tag:getPosition()))
        _c_cur:setPosition(cc.p(_cur:getPosition()))

        local _px = (i-1)*cell_width+(i-1)*10
        _cell:setPosition(_px,_ScrollView:getContentSize().height/2)

        _cell:addChild(_c_pic)
        _cell:addChild(_c_lock)
        _c_tag:addChild(_c_level)
        _cell:addChild(_c_name)
        _cell:addChild(_c_tag)
        _cell:addChild(_c_cur)

        _c_pic:setName(_pic:getName())
        _c_lock:setName(_lock:getName())
        _c_level:setName(_level:getName())
        _c_name:setName(_name:getName())
        _c_tag:setName(_tag:getName())
        _c_cur:setName(_cur:getName())

        _scroll_data._roles[i] = _cell
        _ScrollView:addChild(_cell)

        _cell:addTouchEventListener(function(object, event)
            if event == ccui.TouchEventType.began then
                --f = _ScrollView:getInnerContainer():getPositionX()
                --cclog("began = " ..f)
            elseif event == ccui.TouchEventType.moved then
                --f = local _px = _ScrollView:getInnerContainer():getPositionX()
                --cclog("moved = " ..f)
            elseif event == ccui.TouchEventType.ended then
                _chooseRole(i)
--                cclog("v.id =========== " ..v.id)
--               _ScrollView:scrollToPercentHorizontal(n,1,true)--0~100,time,滚动动画
            end

        end)
    end
    
--    --
--    _ScrollView:addTouchEventListener(function(object, event)
--            if event == ccui.TouchEventType.began then
--                --f = _ScrollView:getInnerContainer():getPositionX()
--                --cclog("ScrollViewbegan = " ..f)
--            elseif event == ccui.TouchEventType.moved then
--                --f = _ScrollView:getInnerContainer():getPositionX()
--                --cclog("ScrollViewmoved = " .._px)
--            elseif event == ccui.TouchEventType.ended then
--                cclog("ended")
--            end
--    end)
    return _ScrollView

end
--

local function _setupUI(demo_bg_alpha)
    local panel = cc.CSLoader:createNode('ui/choose.csb')
    _data.layer:addChild(panel,2)
    local _ScrollView
    --模板(把模板形状放在这里 用透明度来区分哪些模板可显示)
    ---[[
    local _holesStencil  = cc.Node:create()
    local Stencil_A = panel:getChildByName("Stencil_1")
    local Stencil_B = panel:getChildByName("Stencil_2")
    
    --从父节点取出放入裁剪节点
     Stencil_A:removeFromParent()
     Stencil_B:removeFromParent()
     _holesStencil:addChild(Stencil_A)
     _holesStencil:addChild(Stencil_B)

    --底板(把地图滚动 英雄攻击展示放在这个节点里)
    local holes = cc.Node:create()--返回外部处理

    local _clippingNode = _tool.createClippingNode{
      holesStencil = _holesStencil,
      holes = holes,
      inverted = false,
      alpha = 0.8
    }
    _data.layer:addChild(_clippingNode, 1)
    

    local createNodeForScene = function(stencil)
      local node = cc.Node:create()
      local x, y = stencil:getPosition()
      node:setPosition(x, y)
      holes:addChild(node)
      if demo_bg_alpha > 0 then
        local bg = cc.Sprite:createWithSpriteFrame(stencil:getSpriteFrame())
        bg:setAnchorPoint(0, 0)
        bg:setPosition(x, y)
        bg:setOpacity(demo_bg_alpha)
        bg:setLocalZOrder(-1)
        holes:addChild(bg)
      end
      return node
    end
    _ui_data.l_hole = createNodeForScene(Stencil_A)
    _ui_data.r_hole = createNodeForScene(Stencil_B)
    
    
    --升级按钮
    _ui_data.levelup_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_levelup')
    _ui_data.levelup_btn:addTouchEventListener(
      _misc.createClickCB(_onButtonLevelUp)
    )

    --返回
    local _back_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'back')
    _back_btn:addTouchEventListener(
      _misc.createClickCB(_onButtonBack)
    )

    --资费
    --_ui_data.money_text = ccui.Helper:seekNodeByNameOnNode(panel, 'money_text')
        
    --进阶出击
    --(widget在安卓机上不能正常被设置成模板)
--    local advanced_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'advanced_strike')
--    advanced_btn:addTouchEventListener(
--      _misc.createClickCB(_onButtonAdvanceStrike)
--    )
--    advanced_btn:removeFromParent()
    
    local advanced_btn = panel:getChildByName('advanced_strike')
    _ui_data.advanced_btn = advanced_btn
    _tool.SpriteEventListener{
      cb_return = _onButtonAdvanceStrike,
      parent = panel,
      target = advanced_btn
    }
    advanced_btn:removeFromParent()

    --用于给粒子特效定位
    _ui_data.advanced_btn_rect = {
      x = advanced_btn:getPositionX(),
      y = advanced_btn:getPositionY(),
      width = advanced_btn:getContentSize().width,
      height = advanced_btn:getContentSize().height
    }

    local _font_levelup = ccui.Helper:seekWidgetByNameOnNode(panel, 'font_advanced_strike')
    _font_levelup:removeFromParent()

    local _holesStencil_btn  = advanced_btn

    local _holes_btn         = cc.Node:create()
    _holes_btn:addChild(advanced_btn)
    _holes_btn:addChild(_font_levelup)
    

    local _clippingNode_btn = _tool.createClippingNode{
      holesStencil=_holesStencil_btn,
      holes=_holes_btn,
      inverted=false,
      alpha=0.3,
      isblink=true
    }
    panel:addChild(_clippingNode_btn)


    --出击
    local _strike_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'strike')
    _strike_btn:addTouchEventListener(
      _misc.createClickCB(_onButtonStrike)
    )
    
    --选中的勾
    _ui_data.choose = ccui.Helper:seekWidgetByNameOnNode(panel, 'gou')

    --左右箭头
    _ui_data.btn_left  = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_left')
    _ui_data.btn_right = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_right')

    local cell_width = 130
    _scroll_data.cur_move = 0
    --_scroll_data.unit     = 34
    _scroll_data.offset   = 0
    _ui_data.btn_left:addTouchEventListener(function(object, event)
            if event == ccui.TouchEventType.ended then
                _onButtonLeftEx(_ScrollView,cell_width)
            end
    end)
    --(
      --_misc.createClickCB(_onButtonLeft)
    --)

    _ui_data.btn_right:addTouchEventListener(function(object, event)
            if event == ccui.TouchEventType.ended then
                _onButtonRightEx(_ScrollView,cell_width)
            end
    end)
    --(
      --_misc.createClickCB(_onButtonRight)
    --)
    
    --角色数据ui元素
    _ui_data.cur_power = ccui.Helper:seekWidgetByNameOnNode(panel, 'cur_power')
    _ui_data.next_power = ccui.Helper:seekWidgetByNameOnNode(panel, 'next_power')
    _ui_data.cur_interval = ccui.Helper:seekWidgetByNameOnNode(panel, 'cur_interval')
    _ui_data.next_interval = ccui.Helper:seekWidgetByNameOnNode(panel, 'next_interval')
    _ui_data.cur_distance = ccui.Helper:seekWidgetByNameOnNode(panel, 'cur_distance')
    _ui_data.next_distance = ccui.Helper:seekWidgetByNameOnNode(panel, 'next_distance')
    _ui_data.my_gold = ccui.Helper:seekWidgetByNameOnNode(panel, 'my_gold')
    _ui_data.require_gold = ccui.Helper:seekWidgetByNameOnNode(panel, 'require_gold')

    --滑动选择英雄
    _ScrollView = createScrollRole(panel,cell_width)
    

    ---[[
    --角色的显示信息
    for index, r in pairs(_ui_data.roles) do
      r.pic = ccui.Helper:seekWidgetByNameOnNode(panel, r.name_pic)
      r.lock = ccui.Helper:seekWidgetByNameOnNode(panel, r.name_lock)
      r.lv_tag = panel:getChildByName(r.name_lv_tag)
      r.lv_text = r.lv_tag:getChildByName(r.name_lv_text)
      r.career = ccui.Helper:seekWidgetByNameOnNode(panel, r.name_career)
      r.pic:addTouchEventListener(
        function(object, event)
          if event == ccui.TouchEventType.ended then
            _chooseRole(index)
          end
        end
      )
    end
    --]]


    --特效信息
    local effect_node = panel:getChildByName('effect_node')
    effect_node:runAction(
      cc.RepeatForever:create(
        cc.Sequence:create(
          cc.FadeOut:create(0.5),
          cc.FadeIn:create(0.5)
    ) ) )
    --进阶演示边框
    _ui_data.effect_1 = effect_node:getChildByName("effect_1")--左
    _ui_data.effect_2 = effect_node:getChildByName("effect_2")--上
    _ui_data.effect_3 = effect_node:getChildByName("effect_3")--右
    _ui_data.effect_4 = effect_node:getChildByName("effect_4")--下
    --进阶出击按钮附近
    _ui_data.effect_5 = effect_node:getChildByName("effect_5")
    _ui_data.effect_6 = effect_node:getChildByName("effect_6")

    return panel
end



local function _onEnter()
  local tab = _data.user_table
  
  --初始化必须数据
  _data.left_data_index = 1
  --第一次选中必有效
  _data.cur_choose_id = nil
  --开始全部弹满级礼包
  _data.pop_max_level = {}
  for id, _ in pairs(_roles_id_index) do
    if id ~= 10002 and id ~= 10003 and id ~= 13001 and id ~= 15001 and 
        id ~= 10004 and id ~= 10005
    then
        _data.pop_max_level[id] = true
    end
  end
  
  local panel = _setupUI(tab.demo_bg_alpha or 0)
  --
  local init_id
  
  if tab.guide_level_up 
    and _guide_logic.checkLevelUpGuide(
      10, _ui_data.levelup_btn, 
      function() end)
  then
     init_id = _ROLE_DEFAULT_ID
  end
  
  if _guide_logic.checkChooseHeroGuide(10,
      _ui_data.advanced_btn, 
      _onButtonAdvanceStrike,
      tab.from)
  then
    _data.ignore_advance_strike_charge = true
  else
    --不用引导，则认为是第二次(或之后)游戏
    local pd = _player.get()
    if not pd.is_second_game then
      pd.is_second_game = true
      _player.setDirty()
      _player.save()
    end
  end

  init_id = init_id or tab.init_id or _ROLE_DEFAULT_ID
  
  if not _roles_id_index[init_id] then
    --本ui不包含，应是进阶后的id，找其原始角色id
    init_id = _data_heros[init_id].primitive_id
  end
  local index = _makeRoleVisible(init_id)
  _resetGold()
  _chooseRole(index)
  _ResumeRole(panel,index)

  --cclog(" ============================= 初始化完成 ============================= ")  
end

local function _onExit()
  for n,v in pairs(_data) do
    _data[n] = nil
  end
  
  local roles = _ui_data.roles
  for n,v in pairs(_ui_data) do
    _ui_data[n] = nil
  end
  _ui_data.roles = roles
  for id,r in pairs(roles) do
    r.pic, r.lock, r.lv_tag, r.lv_text, r.career = nil
  end
end

--[[
tab={
  init_id [可选],初始选中的英雄id
  demo_bg_alpha [可选],demo底板可见度，默认为0不可见[0-255]
  guide_level_up [可选], 若为true, 弹升级引导（已引导过则忽略）
  from [可选], 可以是'battle'、'challenge' 之一，相应检查引导
  cb_back=function() [可选]退出时调用
  cb_strike=function(hero_id) 点击出击调用
  cb_advance_strike=function(hero_id)  进阶出击调用，已是进阶英雄的id
}
]]
function create(tab)
   _data.layer = cc.Layer:create()
   _data.user_table = tab
   return {
     node = _data.layer,
     block_bottom = true,
     pop_effect = true,
     onEnter = _onEnter,
     onExit = _onExit,
     onKeyBack = _onButtonBack,
   }
end


----- 演示相关
--暂用个伪scene模拟，更多的待改进

--偏移位置，与角色站位匹配
local _SCENE_OFFSET = {0, -80}
--
local _SCENE_SIZE = {300, 500}
--
local _ENEMY_ID = 20000
--敌人位置x坐标，相对场景中心
local _ENEMY_X = {0, -80, 80}
local _ENEMY_Y = {420, 380, 380}
--与敌人速度匹配
local _VELOCITY = 0
--敌人出现间隔
local _ENEMY_SHOW_SEC = 2
--与高度匹配
local _Z_SUBS = 500
local _OBJ_CLEAN_DOWN = -5

local _TYPE_ENEMY = require('data.const').COLL_TYPE_ENEMY

local _DemoScene = require('util.class').class()

_DemoScene.ctor = function(self, enemy_num)
  self.layer = cc.Layer:create()
  self.layer:setPosition(_SCENE_OFFSET[1], _SCENE_OFFSET[2])
  
  --mgr_evt ui_func can_drop
  self.effect_sec = 2
  
  self.distance = 0
  self.width, self.height = _SCENE_SIZE[1], _SCENE_SIZE[2]
  
  self.velocity = _VELOCITY
  
  self.objects = {}
  self._obj_tmp = {}
    
  self.coll = require('game.battle.coll').Collision(self)
  
  self.teams = {}
  self._enemy_num = enemy_num
  self._next_show = 0
  
end

local function _mergePendingObjects(self)
  local objs = self.objects
  local objt = self._obj_tmp
  for obj,flag in pairs(objt) do
    objs[obj] = flag or nil
    objt[obj] = nil
  end
end

local function _updateScene(self)
  local off = self.distance
  local objs = self.objects
  for obj, valid in pairs(objs) do
    if valid then
      local dy = obj.y - off
      if dy > _OBJ_CLEAN_DOWN then
        obj.node:setPosition(obj.x, dy)
        obj.node:setLocalZOrder(obj.z or _Z_SUBS-dy)
      else
        obj:clean()
      end
    end
  end
end

local function _checkEnemy(self, dt)
  if next(self.coll.type2colls[_TYPE_ENEMY]) ~= nil then
    return
  end
  local t = self._next_show - dt
  if t <= 0 then
    t = _ENEMY_SHOW_SEC
    local _Enemy = require('game.battle.enemy').Enemy
    for i=1, self._enemy_num do
      --hp默认,加速=1
      local e = _Enemy(self, _ENEMY_ID,
          self.width*0.5 +_ENEMY_X[i],
          self.distance +_ENEMY_Y[i])
      e.disable_attack = true
    end
  end
  self._next_show = t
end


local function _getUpdateOfDemo(self, st)
  local logic_dt = 1/require('config').design.fps
  return function()
    self.distance = self.distance + self.velocity *logic_dt
    for team,_ in pairs(self.teams) do
      team:update(logic_dt)
    end
    for obj,valid in pairs(self.objects) do
      if valid then obj:update(logic_dt) end
    end
    self.coll:check()
    
    _checkEnemy(self, logic_dt)
    _mergePendingObjects(self)
    _updateScene(self)
  end
end

_DemoScene.inst_meta.start = function(self, ui_func)
  self.distance = 0
  
  _mergePendingObjects(self)
  _updateScene(self)
  self.layer:scheduleUpdateWithPriorityLua(_getUpdateOfDemo(self), 0)
end

_DemoScene.inst_meta.stop = function(self)
  self.layer:unscheduleUpdate()
  local team = self.teams[1]
  if team then
    team:stop()
    self.teams[team] = nil
  end
end

_DemoScene.inst_meta.addTeam = function(self, team)
  assert(not self.teams[team], 'Scene.addTeam team already in scene')
  self.teams[team] = team
  team:start()
end

_DemoScene.inst_meta.removeTeam = function(self, team)
  if self.teams[team] then
    self.teams[team] = nil
    team:stop()
  end
end

_DemoScene.inst_meta.addObject = function(self, obj)
  self._obj_tmp[obj] = true
  self.layer:addChild(obj.node)
  --位置、z值在updateScene会调整
end

_DemoScene.inst_meta.removeObject = function(self, obj)
  if self.objects[obj] then
    self.objects[obj] = false
    self._obj_tmp[obj] = false
    obj.node:removeFromParent()
  elseif self._obj_tmp[obj] then
    self._obj_tmp[obj] = nil
    obj.node:removeFromParent()
  end
end

_DemoScene.inst_meta.clearAll = function(self)
  for team, _ in pairs(self.teams) do
    for i=#team.heros, 1, -1 do
      team:removeHero(team.heros[i])
    end
  end
  for obj, _ in pairs(self.objects) do
    obj:clean()
  end
  _mergePendingObjects(self)
  self._next_show = 0
end

local function _resetScene(scene_name, hole_name, enemy_num, hero_id)
  local scene = _ui_data[scene_name]
  if not scene then
    scene = _DemoScene(enemy_num)
    scene:start()
    local team = require('game.battle.team').Team(scene, 1)
    scene:addTeam(team)
    _ui_data[hole_name]:addChild(scene.layer)
    _ui_data[scene_name] = scene
  else
    scene:clearAll()
  end
  local team = next(scene.teams)
  local h = team:addHero(hero_id, 
    scene.width*0.5, scene.distance,
    true  --开始无特殊状态
  )
end

_showDemo = function(role_id)
  _resetScene('l_scene', 'l_hole', 3, role_id)
  _resetScene('r_scene', 'r_hole', 3, _data_heros[role_id].advance_id)
end
