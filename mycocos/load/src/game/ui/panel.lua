module('game.ui.panel', package.seeall)

--BUYTIPS      = 0    --购买提示界面
ANNOUNCEMENT = 1    --公告界面
LOGIN        = 2    --登录界面
DIED         = 3    --死亡界面
REWARD       = 4    --道具礼包界面
THANK        = 5    --感恩礼包
GUIDE        = 6    --新手礼包界面
UNLOCK       = 7    --解锁英雄界面
HELP         = 8    --帮助界面
LUXURY       = 9    --豪华礼包界面
MAXLEVEL     = 10   --满级礼包界面
GOLD         = 11   --金币礼包
ALIVE        = 12   --复活确认
SIGN         = 13   --签到界面
ENCOURAGE    = 14   --鼓励界面
GOBOSS       = 15   --进入挑战boss界面
CHALLENGE    = 16   --挑战礼包
RESIGN       = 17   --补签界面

local _base_panel = require('game.ui.basepanel').BasePanel
local _misc = require('util.misc')
local _tool   = require('util.tool')
local _mgr_scr = require('game.mgr_scr')
local _heros_data = require('data.hero').heros

local _charge = require('game.charge')
local _charge_data = require('data.charge')
local _text = require('data.text')
local _sign = require('game.ui.sign')
local _resign = require('game.ui.resign')
local _player = require('game.player')

local _Animation = require('game.battle.ani')

Panel = require('util.class').class(_base_panel)

local _panel_data = 
{
    [LOGIN] = {
      charge_bag = _charge_data.login_bag;
    },
    [GUIDE] = {
      charge_bag = _charge_data.newbie_bag;
      GUIDE,
      "新手礼包",
      "\"只需要花费%d元即可购买%s\"",
      "ui/login/guide_value.png"
    },
    [LUXURY] = {
      charge_bag = _charge_data.luxury_bag;
      LUXURY,
      "豪华礼包",
      "\"只需要花费%.2g元即可购买%s\"",
      "ui/login/luxury_value.png"
    },
    [GOLD] = {
      charge_bag = _charge_data.gold_bag;
      GOLD,
      "金币礼包",
      "\"只需要花费%.2g元即可购买%s\"",
      "ui/login/gold_value.png"
    },
    [REWARD] = {
      charge_bag = _charge_data.item_bag,
      REWARD,
      "道具礼包",
      "\"只需要花费%.2g元即可购买%s\"",
      "ui/login/item_value.png"
    },

    [THANK] = {
        charge_bag = _charge_data.thank_bag,
      THANK,
      "感恩礼包",
      "\"只需要花费%.2g元即可购买%s\"",
      "ui/login/thank_value.png" ,
    },

    [CHALLENGE] = {
      charge_bag = _charge_data.challenge_bag,
      CHALLENGE,
      "挑战礼包",
      "\"只需要花费%.2g元即可购买%s\"",
      "ui/login/boss_value.png",
    },
}
local _effect_data = 
{
    --剑士
    [18001] = { rain_bg = "ui/hero/18001_1.png",
                light_bg = {r=255, g=255, b=255},
                sprite_bg = "ui/hero/18001_2.png",
                offset = {x= -8,y = 0},
                max_offset = {x= 0,y = 0}
               },
    --弓箭手
    [14001] = { rain_bg = "ui/hero/14001_1.png",
                light_bg = {r=255, g=218, b=111},
                sprite_bg = "ui/hero/14001_2.png",
                offset = {x= 0,y = 0},
                max_offset = {x= 7,y = 0}
               },
    --法师
    [17001] = { rain_bg = "ui/hero/17001_1.png",
                light_bg = {r=198, g=239, b=255},
                sprite_bg = "ui/hero/17001_2.png",
                offset = {x= -12,y = 0},
                max_offset = {x= -7,y = 0}
               },
    --绿巨人
    [19001] = { rain_bg = "ui/hero/19001_1.png",
                light_bg = {r=208, g=255, b=198},
                sprite_bg = "ui/hero/19001_2.png",
                offset = {x= 0,y = 0},
                max_offset = {x= 0,y = 0}
               },
    --斧手
    [15001] = { rain_bg = "ui/hero/15001_1.png",
                light_bg = {r=111, g=255, b=246},
                sprite_bg = "ui/hero/15001_2.png",
                offset = {x= -10,y = 0},
                max_offset = {x= 0,y = 0}
               },
    --守护者
    [10003] = { rain_bg = "ui/hero/10003_1.png",
                light_bg = {r=255, g=99, b=184},
                sprite_bg = "ui/hero/10003_2.png",
                offset = {x= 8,y = 0},
                max_offset = {x= 20,y = 0}
               },
     --蚁人
    [10005] = { rain_bg = "ui/hero/10003_1.png",
                light_bg = {r=255, g=100, b=81},
                sprite_bg = "ui/hero/10003_2.png",
                offset = {x= 8,y = 0},
                 max_offset = {x= 0,y = 0}
               },
}
local gift_tips=
{
    max = {
        [10001] = { tips = "花费%d元即可让剑士升到满级"},
        [11001] = { tips = "花费%d元即可让弓箭手升到满级"},
        [12001] = { tips = "花费%d元即可让法师升到满级"},
        [16001] = { tips = "花费%d元即可让绿巨人升到满级"},
        [13001] = { tips = "花费%d元即可让斧手升到满级"},
        [10002] = { tips = "花费%d元即可让守护者升到满级"},
        [10004] = { tips = "花费%d元即可让蚁人升到满级"},
    }
}

--礼包
local function _Login(self, cb_enter, cb_end, type_panel)
  local is_cost
  if type_panel == THANK then--只购买一次
     if _player.get().cost_gift[THANK] then
        _mgr_scr.popupTip("已经购买过该礼包")
        return nil
     end
     is_cost = true
  end
  
  local panel = cc.CSLoader:createNode('ui/login.csb')

  local action = cc.CSLoader:createTimeline('ui/login.csb')
  panel:runAction(action)
  action:gotoFrameAndPlay(0,true)

  --本界面的配置数据
  local panel_data = _panel_data[type_panel]
  
  --
  if #panel_data > 0 then
    local v = panel_data
    
    local _font_login_1 = panel:getChildByName("title")
    _font_login_1:setString(v[2])

    local _login_get = panel:getChildByName("login_get")
    local str = string.format(v[3],v.charge_bag.rmb,v[2])
    _login_get:setString(str)

    local _login_value = panel:getChildByName("login_value")
    _login_value:setSpriteFrame(v[4])


    --local _role_pic = panel:getChildByName("10001")
    --_role_pic:setSpriteFrame(v[5])
    --_role_pic:setPositionX(_role_pic:getPositionX())
  end

  --关闭、取消
  local function close()
    self:destroy()
    if type(cb_end) == "function" then
      cb_end()
    end
  end

  self.onKeyBack = close

  local _gift_close_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
  _gift_close_btn:addTouchEventListener(
    _misc.createClickCB(close))

  local _public_btn_cancel = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_cancel')
  _public_btn_cancel:addTouchEventListener(
    _misc.createClickCB(close))

    

  --资费、确认
--  ccui.Helper:seekWidgetByNameOnNode(panel, 'money_text'):setString(
--    string.format(_text.ui_charge_format, panel_data.charge_bag.rmb)
--  )

  local function pay()
    if not _charge.chargeForBag(panel_data.charge_bag) then
        return
    end
    if is_cost then
       _player.get().cost_gift[type_panel] = true
       _player.setDirty()
       _player.save()
    end
    self:destroy()
    if type(cb_enter) == "function" then
        cb_enter()
    end
  end

  

  local _gift_get_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_yellow')
  _gift_get_btn:addTouchEventListener(
    _misc.createClickCB(
      function()
      --此处直接接入付费
      pay()
      end
  ))

  
  return panel

--对精灵进行描边
--    local _pic_role = panel:getChildByName("10001")
--    local tex = _tool.createStroke({sprite = _pic_role,size = 2,color = cc.c3b(0,0,0),opacity = 50})
--    self.layer:addChild(tex)
 
 --   local panel = cc.CSLoader:createNode('xxxx/xxxx.csb')
end

--公告界面
local function _Announcement(self, cb)
   local panel = cc.CSLoader:createNode('ui/announcement.csb')

   local action = cc.CSLoader:createTimeline('ui/announcement.csb')
    panel:runAction(action)
    action:gotoFrameAndPlay(0,true)

    local function close()
      self:destroy()
      if type(cb) == "function" then
           cb()
       end
    end
    
    self.onKeyBack = close
    
   local _gift_close_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
   _gift_close_btn:addTouchEventListener(
      _misc.createClickCB(close))

    local _gift_get_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_yellow')
   _gift_get_btn:addTouchEventListener(
    _misc.createClickCB(close))

  return panel
end

local function _Died(self, endback, cb_die, died_tip) 
    local panel = cc.CSLoader:createNode('ui/died.csb')
    
    local action = cc.CSLoader:createTimeline('ui/died.csb')
    panel:runAction(action)
    action:gotoFrameAndPlay(0,true)

    --按下复活键的记录
    local _is_Click = false
    --倒计时
    local uptime = 5
    --二次确认是否弹出
    local is_sure = false
    
    local _died_time_label = ccui.Helper:seekWidgetByNameOnNode(panel, 'died_time')
    _died_time_label:setString(tostring(uptime))
    local _died_time_sacle = _died_time_label:getScale()
    if died_tip then
        local _died_text = ccui.Helper:seekWidgetByNameOnNode(panel, 'random_tips_text')
        _died_text:setString(died_tip)
        local _tip_bg = ccui.Helper:seekWidgetByNameOnNode(panel, 'tip_bg')
        if string.find(died_tip, "\n") then
            _tip_bg:setScaleY(1.5)
        else
            _tip_bg:setScaleY(1)
        end
    end
--    --开启放大缩小
--    local scaleby = cc.ScaleBy:create(1,_died_time_sacle+0.5)
--    local scalefunc = function()
--        _died_time_label:setScale(_died_time_sacle)
--    end
--    --local scaleby_reverse = scaleby:reverse()
--    local seq = cc.Sequence:create(cc.CallFunc:create(scalefunc),scaleby)
--    _died_time_label:runAction(cc.RepeatForever:create(seq))
    
    --
--    ccui.Helper:seekNodeByNameOnNode(panel, 'money_text'):setString(
--      string.format(_text.ui_charge_format, _charge_data.revive.rmb)
--    )
    
    local function func_click()
        _is_Click = true
        is_sure = false
    end
    local function func_back()
        _died_time_label:resume()
        is_sure = false
    end

    local _public_btn_yellow = panel:getChildByName('public_btn_yellow')
    _tool.SpriteEventListener{
      parent = panel,
      target = _public_btn_yellow,
      cb_return = function()
        _died_time_label:pause()
        is_sure = true
        local _alive = require('game.ui.panel')
        local dlg = _alive.Panel(
            {
                modal=true,
                ani=true,
                type_panel=ALIVE,
                cb_enter=func_click,
                endback=func_back,
                data=_charge_data.revive
            })

      end
    }
    _public_btn_yellow:removeFromParent()

    local _died_font_resurrection = ccui.Helper:seekWidgetByNameOnNode(panel, 'died_font_resurrection')
    _died_font_resurrection:removeFromParent()

    local _holesStencil_btn  = _public_btn_yellow

    local _holes_btn         = cc.Node:create()
    _holes_btn:addChild(_public_btn_yellow)
    _holes_btn:addChild(_died_font_resurrection)


    local _clippingNode_btn = _tool.createClippingNode{
      holesStencil=_holesStencil_btn,
      holes=_holes_btn,
      inverted=false,
      alpha=0.3,
      isblink=true
    }
    panel:addChild(_clippingNode_btn)

    --粒子
    local _particle_1 = cc.ParticleSystemQuad:create("effect/die/die_effect.plist")
    _particle_1:setPosition(cc.p(_public_btn_yellow:getPositionX(),_public_btn_yellow:getPositionY()))
    panel:addChild(_particle_1)

    --淡入淡出闪光
    local _blink_node = panel:getChildByName('blink_node')
     _tool.runFadeBlink(_blink_node)


    --闪烁背景
    local _died_bg = panel:getChildByName('died_blink')
    _tool.runFadeBlink(_died_bg,0.2)
--    local fade_out = cc.FadeOut:create(0.4);
--    local fade_in  = fade_out:reverse()
--    local seq      = cc.Sequence:create(fade_out,fade_in)
--    local _repeat  = cc.Repeat:create(seq,5)
--    _died_bg:runAction(cc.Sequence:create(_repeat,cc.CallFunc:create(function()
--        _tool.runFadeBlink(_died_bg,0.2)
--    end
--    )))


    --到时或取消
    local function close()
      --复活显示翼期间，不退出
      if not self.time_id then
        return
      end
      cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.time_id)
      self:destroy()
      if type(endback) == "function" then
        endback()
      end
    end
  
    self.onKeyBack = close
    
    
    --翅膀
    local _wings = panel:getChildByName('died_wings')
    _wings:setVisible(false)
     
    --开启倒计时
    local t = 1
    local sc = 1
    local function updateTime(dt)
      if is_sure then
        return
      end
      t = t - dt

      --缩放计算
      sc = sc + 0.1
      _died_time_label:setScale(sc)
      --未到一秒
      if t > 0 then
        return
      end
      sc = 1
      t = t + 1
      uptime = uptime - 1
      if uptime <= 0 and not _is_Click then
        close()
        return
      end
      if uptime > 0 then
       _died_time_label:setString(tostring(uptime))
      end
      

      if not _is_Click then
        return
      end
      --付费失败，重新点击
      if not _charge.charge(_charge_data.revive) then
        _is_Click = false
        return
      end

      cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.time_id)
      self.time_id = nil --禁止按下退出键

      --弹出当前框，将翅膀移到一个新的layer对话框显示
      _wings:retain()
      _wings:removeFromParent()
      _wings:setVisible(true)
      local layer = cc.Layer:create()
      layer:addChild(_wings)
      _wings:release()

      self:destroy()
      _mgr_scr.pushDialog{
        node = layer,
        block_bottom = true
      }

      _wings:runAction(
        cc.Sequence:create(
          cc.Spawn:create(
            cc.ScaleTo:create(1, 1.5),
            cc.FadeOut:create(1)
          ),
          cc.CallFunc:create(
            function()
                _mgr_scr.popDialog()
                if type(cb_die) == "function" then
                cb_die()
                end
            end
      ) ) )
    end --function updateTime
  
  self.time_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 0, false)
--    self.layer:scheduleUpdateWithPriorityLua(updateTime, 0)

  return panel

end

--帮助界面
local _Help = function(self,cb_endback)
   local panel = cc.CSLoader:createNode('ui/help.csb')

   local action = cc.CSLoader:createTimeline('ui/help.csb')
    panel:runAction(action)
    action:gotoFrameAndPlay(0,true)

  local function close()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.time_id)
    self:destroy()
    if type(cb_endback) == "function" then
      cb_endback()
    end
  end

  self.onKeyBack = close
  
   local _gift_close_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
   _gift_close_btn:addTouchEventListener(
    _misc.createClickCB(close))

    local _gift_get_btn = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_yellow')
   _gift_get_btn:addTouchEventListener(
    _misc.createClickCB(close))


    local _vector_ani = ccui.Helper:seekWidgetByNameOnNode(panel, 'vector_ani')

    local _ani_hero = cc.Node:create()
    local _sdata = _heros_data[19001]
    local _ani = _Animation.Animation(_sdata.object, nil, _ani_hero)
    _ani:play('walk')
    _vector_ani:addChild(_ani_hero)
    _ani_hero:setPosition(_vector_ani:getContentSize().width/2, _vector_ani:getContentSize().height/2+35)
    --左右移动
    local _move_left  = cc.MoveBy:create(1,cc.p(-150,0))
    local _delay_time = cc.DelayTime:create(1)
    local _move_right = _move_left:reverse()
    local _seq        = cc.Sequence:create(_delay_time,_move_left,_delay_time,_move_right,_delay_time,_move_right,_delay_time,_move_left)
    _vector_ani:runAction(cc.RepeatForever:create(_seq))

    local fps = require('config').design.fps
    local function updateTime(dt)
        local logic_dt = 1/fps
        _ani:update(logic_dt)
    end
    
    self.time_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 0, false)
    
    return panel
end

--满级礼包界面
local _MaxLevel = function(self, cb_enter, cb_endback, role_id)
  local panel = cc.CSLoader:createNode('ui/maxLevel.csb')

--  local action = cc.CSLoader:createTimeline('ui/maxLevel.csb')
--  panel:runAction(action)
--  action:gotoFrameAndPlay(0,true)

  --关闭、取消
  local function close()
    self:destroy()
    if type(cb_endback) == "function" then
      cb_endback()
    end
  end
  self.onKeyBack = close

  local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
  _public_btn_close:addTouchEventListener(
    _misc.createClickCB(close)
  )

  local _public_btn_cancel = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_cancel')
  _public_btn_cancel:addTouchEventListener(
    _misc.createClickCB(close)
  )

  --确认
  local charge_info = _charge_data.max_level[role_id]
  
--  local _money_text = ccui.Helper:seekWidgetByNameOnNode(panel, 'money_text')
--  _money_text:setString( 
--    string.format(_text.ui_charge_format, charge_info.rmb) 
--  )

    local function pay()
        if not _charge.charge(charge_info) then
          return
        end
        self:destroy()
        if type(cb_enter) == "function" then
          cb_enter()
        end
    end

    --按钮
    local _public_btn_yellow = panel:getChildByName('public_btn_yellow')
    _tool.runScale(_public_btn_yellow)
    _tool.SpriteEventListener{
      cb_return = function()
       --此处直接接入付费
       pay()
      end,
      parent = panel,
      target = _public_btn_yellow
    }
    --按钮特效
--    local _rotation = ccui.Helper:seekWidgetByNameOnNode(panel, 'rotation')
--    _tool.runRotate(_rotation, 2)
    
    --
    role_id = role_id or 10001
    local _role_data = _heros_data[role_id]

    local _before_path = "ui/heros/" ..tostring(_role_data.id) ..".png"
    local _after_path  = "ui/heros/" ..tostring(_role_data.advance_id) ..".png"
    local _advance_before = panel:getChildByName("advance_before")
    _advance_before:setSpriteFrame(_before_path)
    local _advance_after = panel:getChildByName("advance_after")
    _advance_after:setSpriteFrame(_after_path)

    local _font_pay = panel:getChildByName('font_pay')
    
    _font_pay:setString(string.format(gift_tips.max[_role_data.id].tips,_charge_data.max_level[_role_data.id].rmb))
    
    local _title = panel:getChildByName('title')
    _title:setString( _heros_data[_role_data.advance_id].name .."满级礼包")

    --特效图显示
    local hero_id = _role_data.advance_id
    local _rain_bg = panel:getChildByName('rain_bg')
    local _light_bg = panel:getChildByName('light_bg')
    local _sprite_bg = panel:getChildByName('sprite_bg')

    _rain_bg:setSpriteFrame(_effect_data[hero_id].rain_bg)
    _light_bg:setColor(_effect_data[hero_id].light_bg)
    _sprite_bg:setSpriteFrame(_effect_data[hero_id].sprite_bg)

    local _pos = cc.p(_advance_after:getPositionX(),_advance_after:getPositionY())
    _pos.x = _pos.x + _effect_data[hero_id].max_offset.x
    _pos.y = _pos.y + _effect_data[hero_id].max_offset.y
    _advance_after:setPosition(_pos)


    return panel
end
--签到界面
local _Sign = function(self, cb_enter, cb_endback)
    local panel = cc.CSLoader:createNode('ui/sign.csb')

     --关闭、取消
    local function close()
        self:destroy()
        if type(cb_endback) == "function" then
            cb_endback()
        end
    end

    local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(close)
      )

    local function signOK()
        _sign.getSign()
        self:destroy()
        if type(cb_enter) == "function" then
          cb_enter()
        end
    end
    local function setReSign()
        local _resign = require('game.ui.panel')
        local dlg = _resign.Panel(
            {
                modal=true,
                ani=true,
                type_panel=RESIGN,
                cb_enter=_sign.getSign,
                endback=close
            })
    end
    
    local _public_btn_yellow = panel:getChildByName('public_btn_yellow')
    _tool.runScale(_public_btn_yellow)
    _tool.SpriteEventListener{
      cb_return = function()
        if _sign.getRepair() then
            cclog("打开补签界面")
            setReSign()
        else
            signOK()
        end
        
      end,
      parent = panel,
      target = _public_btn_yellow
    }

    if not _sign.checkSign(panel) then
        --close()
        cclog("已经领取  无需再显示界面")
        if type(cb_endback) == "function" then
            cb_endback()
        end
        return nil
    end
    
    return panel
end
--补签界面
local _ReSign = function(self, cb_enter, cb_endback)
     local panel = cc.CSLoader:createNode('ui/resign.csb')

     --关闭、取消
    local function close()
        _resign.close()
        self:destroy()
        if type(cb_endback) == "function" then
            cb_endback()
        end
    end

     local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(close)
      )

      local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_cancel')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(close)
      )

      --购买
      local function pay()
           _resign.getResign()
           if _resign.getLevel() == #_resign.getRepairData() then
               if type(cb_enter) == "function" then
                  cb_enter()
                  cclog("补签+签到")
               end
           end
           self:destroy()
           if type(cb_endback) == "function" then
                cb_endback()
           end
      end

      local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_green')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(pay)
      )

      --重置所有的分块
      local function resetCell()
         for i=1,5 do
            tmp = string.format(_resign.getRes().cell,i)
            local _cell = ccui.Helper:seekWidgetByNameOnNode(panel, tmp)
            _cell:setVisible(false)
         end
      end

      --设置分块
      local function setCell(_list)
          local tmp
          for k,v in ipairs(_list) do
             tmp = string.format(_resign.getRes().cell,k)
             local _cell = ccui.Helper:seekWidgetByNameOnNode(panel, tmp) 
             _cell:setVisible(true)

             tmp = string.format(_resign.getRes().font,k)
             local _font = _cell:getChildByName(tmp)
             _font:setString(v.value)

             tmp = string.format(_resign.getRes().item,k)
             local _item = _cell:getChildByName(tmp)
             _item:setSpriteFrame(v.pic)
             _item:setScale(v.scale)
          end
      end

     

      --初始化
      _resign.init()
      
      local _font_day = ccui.Helper:seekWidgetByNameOnNode(panel, 'font_day')
      --_font_day:setString(string.format("%d天",_resign.getFont_day()))
      --setCell(_resign.getData())

      --两边按钮显隐
      local _onLeft = ccui.Helper:seekWidgetByNameOnNode(panel, 'onLeft')
      local _onRight = ccui.Helper:seekWidgetByNameOnNode(panel, 'onRight')

      --补签描述
      local _font_value = ccui.Helper:seekWidgetByNameOnNode(panel, 'font_value')
      

       --刷新左右按钮显隐
      local function updateBtn()
          resetCell()
          cclog("updateBtn ============= " ..#_resign.getRepairData()[#_resign.getRepairData()])
          if #_resign.getRepairData()[#_resign.getRepairData()] == 0 then
             _onLeft:setVisible(false)
             _onRight:setVisible(false)
          else
              if _resign.getLevel() >= 2 then
                 _onRight:setVisible(false)
                 _onLeft:setVisible(true)
              else
                 _onRight:setVisible(true)
                 _onLeft:setVisible(false)
              end
          end

          _font_day:setString(string.format("%d天",_resign.getFont_day()))--包括了今天
          _font_value:setString(string.format([[花费%d元即可进行补签，获得%d天签到奖励
   (取消则会从第1天开始签到)]],_charge_data.resign.sign[_resign.getLevel()].rmb,_resign.getFont_day()))
          setCell(_resign.getData())
      end
      updateBtn()

      _onLeft:addTouchEventListener(
        _misc.createClickCB(function()
            _resign.Reduce()
            updateBtn()
        end)
      )

      _onRight:addTouchEventListener(
        _misc.createClickCB(function()
            _resign.Add()
            updateBtn()
        end)
      )

      


     return panel
end
--鼓励界面
local _Encourage = function(self, cb_enter, cb_endback)
    local panel = cc.CSLoader:createNode('ui/encourage.csb')

    --关闭、取消
    local function close()
        self:destroy()
        if type(cb_endback) == "function" then
            cb_endback()
        end
    end

    local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(close)
      )

    return panel
end
--进入boss界面
local _Goboss = function(self, cb_enter, cb_endback)
    local panel = cc.CSLoader:createNode('ui/goboss.csb')

    local function close()
        self:destroy()
        if type(cb_endback) == "function" then
            cb_endback()
        end
    end

    local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(close)
      )

      local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'btn_boss')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(function()
            self:destroy()
            if type(cb_enter) == "function" then
                cb_enter()
            end
        end)
      )

      return panel
end
--解锁英雄界面
local _UnLock = function(self, cb_enter, cb_endback,hero_id)
  --确保是进阶id
  hero_id = _heros_data[hero_id].advance_id or hero_id
  
    local panel = cc.CSLoader:createNode('ui/unlock.csb')
    local function close()
        self:destroy()
        if type(cb_endback) == "function" then
            cb_endback()
        end
    end

    local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(close)
      )
    local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_cancel')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(close)
      )


    local function pay()
        if not _charge.chargeForUnlock(hero_id) then
          local info = require('data.charge').unlock[hero_id]
          --用金币的，弹金币礼包
          if info.golds then
            Panel{
              modal=true,
              ani=true,
              type_panel=GOLD,
            }
          end
          return
        end
        self:destroy()
        if type(cb_enter) == "function" then
          cb_enter()
        end
    end
    
    local _public_btn_green = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_green')
      _public_btn_green:addTouchEventListener(
        _misc.createClickCB(function()
            pay()
        end)
      )
      

      local sf = string.format("ui/heros/%d.png",hero_id)
      local _sprite = panel:getChildByName("sprite")
      _sprite:setSpriteFrame(sf)

      local _font_value = ccui.Helper:seekWidgetByNameOnNode(panel,"font_value")
      _font_value:setString(string.format("解锁后可使用%s和%s", 
          _heros_data[_heros_data[hero_id].primitive_id].name, 
          _heros_data[hero_id].name))

      local _font_pay = ccui.Helper:seekWidgetByNameOnNode(panel,"font_pay")
      _font_pay:setString(string.format(_charge_data.unlock[hero_id].cost))

      local _title = ccui.Helper:seekWidgetByNameOnNode(panel,"title")
      _title:setString(string.format("解锁%s",_heros_data[hero_id].name))

      --特效图显示
      local _rain_bg = panel:getChildByName('rain_bg')
      local _light_bg = panel:getChildByName('light_bg')
      local _sprite_bg = panel:getChildByName('sprite_bg')

      _rain_bg:setSpriteFrame(_effect_data[hero_id].rain_bg)
      _light_bg:setColor(_effect_data[hero_id].light_bg)
      _sprite_bg:setSpriteFrame(_effect_data[hero_id].sprite_bg)

      local _pos = cc.p(_sprite:getPositionX(),_sprite:getPositionY())
      _pos.x = _pos.x + _effect_data[hero_id].offset.x
      _pos.y = _pos.y + _effect_data[hero_id].offset.y
      _sprite:setPosition(_pos)

      --针对斧手按钮文字改变
      local _btn_font = _public_btn_green:getChildByName("btn_font")
      local _btn_font_path = "ui/public/btn_buy.png"
      if hero_id == 13001 or hero_id == 15001 then
         _btn_font_path = "ui/public/font_sure.png"
      end
      _btn_font:setSpriteFrame(_btn_font_path)
      
    return panel

end
--复活确认界面
local _Alive = function(self, _cb_enter, _cb_endback)
    local panel = cc.CSLoader:createNode('ui/diedSencond.csb')
    local function close()
        self:destroy()
        if type(_cb_endback) == "function" then
            _cb_endback()
        end
    end

    local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(close)
      )
    local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_cancel')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(close)
      )

      local _public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_green')
      _public_btn_close:addTouchEventListener(
        _misc.createClickCB(function()
            self:destroy()
            if type(_cb_enter) == "function" then
                _cb_enter()
            end
        end)
      )

      local _font_value = ccui.Helper:seekWidgetByNameOnNode(panel, 'font_value')
      _font_value:setString(string.format([[花费%d元即可获得复活机会
 让你以5个英雄回到战场!]],_charge_data.revive.rmb))

    return panel

end

--[[
tab={
  modal=true|false 是否模态
  ani=true|false  是否弹出效果
  type_panel=xx  顶部的对话框类型
  cb_endback=function() end  取消退出回调
  
  --登录礼包LOGIN、新手礼包GUIDE。。。
  cb_enter  确认退出回调
  --死亡界面
  cb_die 复活回调
  died_tip 设置文字
}
]]
Panel.ctor = function(self,tab)--{type_panel,modal,ani,tab.cb_die}
    local _type_panel   = tab.type_panel
    local _cb_enter     = tab.cb_enter
    local _cb_endback   = tab.endback
   
    local panel
   if _type_panel == ANNOUNCEMENT then
      panel = _Announcement(self, _cb_endback)
   elseif _type_panel == DIED then
      panel = _Died(self, _cb_endback, tab.cb_die, tab.died_tip)
    elseif _type_panel == HELP then
      panel = _Help(self, _cb_endback)
    elseif _type_panel == MAXLEVEL then
      panel = _MaxLevel(self, _cb_enter, _cb_endback, tab.role_id)
    elseif _type_panel == SIGN then
      panel = _Sign(self, _cb_enter, _cb_endback)
    elseif _type_panel == RESIGN then
      panel = _ReSign(self, _cb_enter, _cb_endback)
    elseif _type_panel == ENCOURAGE then
      panel = _Encourage(self, _cb_enter, _cb_endback)
    elseif _type_panel == GOBOSS then
      panel = _Goboss(self, _cb_enter, _cb_endback)
    elseif _type_panel == UNLOCK then
      panel = _UnLock(self, _cb_enter, _cb_endback,tab.hero_id)
    elseif _type_panel == ALIVE then
      panel = _Alive(self, _cb_enter, _cb_endback)
   elseif _type_panel == THANK or
          _type_panel == CHALLENGE or
          _type_panel == GOLD or
          _type_panel == LUXURY or
          _type_panel == GUIDE or
          _type_panel == REWARD or
          _type_panel == LOGIN
   then
        panel = _Login(self, _cb_enter, _cb_endback, _type_panel)
    else
      cclog("nothing for gift")
      return
    end

    if not panel then
        cclog("panel is nil")
        return
    end

   self.__super_ctor__(self, panel, tab.modal, tab.ani)
   
end

--[[使用例子
  local layer
  local _panel = require('game.ui.panel')
  _panel.Panel({type_panel = _panel.ANNOUNCEMENT})
 --]]

