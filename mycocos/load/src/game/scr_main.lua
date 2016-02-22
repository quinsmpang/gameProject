module('game.scr_main', package.seeall)

local _mgr_scr = require('game.mgr_scr')
local _mgr_snd = require('game.mgr_snd')
local _misc = require('util.misc')
local _player = require('game.player')
local _tool   = require('util.tool')

local _charge = require('game.charge')
local _charge_data = require('data.charge')
local _rank_data = require('game.ui.rank.rank_data')
local _guide_logic = require('game.guide_logic')

local _data = {
  --layer
  --main 主界面顶层node
  --bg 背景滚动层
}

local _checkGuide

--测试按钮
g_btn = nil

local function _onButtonSingle()
  local restore = function()
    _mgr_scr.popDialog()
    _data.main:setVisible(true)
  end
  local battle = function(hero_id)
    restore()
    _mgr_scr.pushScreen(
      require('game.scr_battle').create(hero_id)
    )
  end
  local heros_panel = require('game.ui.heropanel').create{
    cb_back = restore,
    cb_strike = battle,
    cb_advance_strike = battle,
    from = 'battle',
  }
  heros_panel.z = 1
  _mgr_scr.pushDialog(heros_panel)
  _data.main:setVisible(false)
end

local function _onButtonChallenge()
  local n = _player.get().pk_num
  if n <= 0 then
      local panel = require('game.ui.panel')
      local dlg = panel.Panel(
        {
          modal=true,
          ani=true,
          type_panel=panel.CHALLENGE,
          cb_enter=function()
            _charge.chargeForBag(_charge_data.challenge_bag)
          end
        })
    return
  end

  local restore = function()
    _mgr_scr.popDialog()
    _data.main:setVisible(true)
  end
  local challenge = function(hero_id)
    restore()
    _mgr_scr.pushScreen(
      require('game.scr_boss').create(hero_id)
    )
  end
  local heros_panel = require('game.ui.heropanel').create{
    cb_back = restore,
    cb_strike = challenge,
    cb_advance_strike = challenge,
    from = 'challenge',
  }
  heros_panel.z = 1
  _mgr_scr.pushDialog(heros_panel)
  _data.main:setVisible(false)
end

local function _onButtonShop()
  local shop
  shop = require('game.ui.shop').create(
    function()
      _mgr_scr.popDialog()
      _data.main:setVisible(true)
    end)
  shop.z = 1
  _mgr_scr.pushDialog(shop)
  _data.main:setVisible(false)
end

local function _onButtonRank()
--    if require('config').test_data then
--        local _luckydraw_data = require('game.ui.luckydraw.luckydraw_data')
--        if _luckydraw_data.isStart() then
--            local panel = require('game.ui.luckydraw.luckydraw_panel')
--           local dlg = panel.Panel(
--            {
--              modal=true,
--              ani=true
--            })
--        end
--    else
--        local panel = require('game.ui.rank.rank_panel')
--       local dlg = panel.RankPanel(
--        {
--          modal=true,
--          ani=true,
--          type_panel=panel.RANKMAIN
--        })
--    end
  if _tool.IsNetWork() then
      local function cb()
        _data.main:setVisible(true)
      end
      local panel = require('game.ui.rank.rank_panel')
      local dlg = panel.RankPanel{
        modal=true,
        ani=true,
        type_panel=panel.RANKMAIN,
        cb_enter=cb,
        endback=cb,
      }
      _data.main:setVisible(false)
  end
  
end

local function _onCheckboxMusic(chk)
  _mgr_snd.enableMusic(chk:isSelected())
end

local function _onCheckboxSound(chk)
  _mgr_snd.enableEffects(chk:isSelected())
end

local function _createCell(_cell,_data)
    local _title = _cell:getChildByName('Text_1')
    local _btn = _cell:getChildByName('btn_test')

    _title:setString(_data.name)

    local _config_debug = require('config').test_data
    --排行榜
    if _data == _config_debug.rank then
        _player.get().rank_day = _player.get().rank_day or 0
        _btn:setTitleText(tostring(_player.get().rank_day))
    --签到   
    elseif _data == _config_debug.sign then
        _title:setString(string.format(_data.name,_player.get().sign.cur_day))
        _player.get().unreal_day = _player.get().unreal_day or 0
        _btn:setTitleText(tostring(_player.get().unreal_day))
    --挑战boss
    elseif _config_debug.challenge == _data then
        _player.get().pk_num = _player.get().pk_num or 0
        _btn:setTitleText(tostring(_player.get().pk_num))
    --碎片数量
    elseif _config_debug.pets == _data then
        _player.get().pets.test_debris = _player.get().pets.test_debris or 0
        _btn:setTitleText(tostring(_player.get().pets.test_debris))
    --抽奖次数
    elseif _config_debug.lucky == _data then
        local _luckydraw_data = require('game.ui.luckydraw.luckydraw_data')
        _btn:setTitleText(tostring(_luckydraw_data.data.chance))
    --抽奖界面
    elseif _config_debug.luckyV == _data then
        _btn:setTitleText("抽奖界面")
    --碎片界面
    elseif _config_debug.petpause == _data then
        _btn:setTitleText("碎片界面")
    end
    _data.btn = _btn
    return _btn

end
local function _onTestBtn(_data)
    local _config_debug = require('config').test_data

    --排行榜
    if _data == _config_debug.rank then
        _player.get().rank_day = _player.get().rank_day or 0
        _player.get().rank_day = _player.get().rank_day + 1
        _data.btn:setTitleText(tostring(_player.get().rank_day))
        cclog("排行榜")

    --签到
    elseif _data == _config_debug.sign then
        _player.get().unreal_day = _player.get().unreal_day or 0
        _player.get().unreal_day = _player.get().unreal_day + 1
        if _player.get().unreal_day > 10 then
            _player.get().unreal_day = 0
        end
        _data.btn:setTitleText(tostring(_player.get().unreal_day))
        cclog("签到")
    --挑战boss
    elseif _config_debug.challenge == _data then
        _player.get().pk_num = _player.get().pk_num or 0
        _player.get().pk_num = _player.get().pk_num + 1
        _data.btn:setTitleText(tostring(_player.get().pk_num))
        cclog("挑战boss")
    --碎片数量
    elseif _config_debug.pets == _data then
        _player.get().pets.test_debris = _player.get().pets.test_debris or 0
        _player.get().pets.test_debris = _player.get().pets.test_debris + 1
        if _player.get().pets.test_debris > 30 then
            _player.get().pets.test_debris = 0
        end
        _data.btn:setTitleText(tostring(_player.get().pets.test_debris))
        cclog("碎片数量")
    --抽奖次数
    elseif _config_debug.lucky == _data then
        local _luckydraw_data = require('game.ui.luckydraw.luckydraw_data')
        _luckydraw_data.data.chance = _luckydraw_data.data.chance or 0
        _luckydraw_data.data.chance = _luckydraw_data.data.chance + 1
        _data.btn:setTitleText(tostring(_luckydraw_data.data.chance))
        cclog("抽奖次数")

        --测试碎片界面
--        local petpaused = require('game.ui.petpaused')
--        petpaused.setData(30003)
    --抽奖界面
    elseif _config_debug.luckyV == _data then
        local _luckydraw_data = require('game.ui.luckydraw.luckydraw_data')
        if _luckydraw_data.isStart() then
            local panel = require('game.ui.luckydraw.luckydraw_panel')
           local dlg = panel.Panel(
            {
              modal=true,
              ani=true
            })
        end
          --测试碎片界面
--        local petpaused = require('game.ui.petpaused')
--        petpaused.setData(30005)
    --碎片界面
    elseif _config_debug.petpause == _data then
        local petpaused = require('game.ui.petpaused')
        local dlg = petpaused.create(
          function(ret_code)
            if ret_code == petpaused.RET_RESUME then
                  --cclog("RET_RESUME")
                   _mgr_scr.popDialog()
            elseif ret_code == petpaused.RET_TO_MAIN then
                  --cclog("RET_TO_MAIN")
                  --petpaused.setData(30001)
                  _mgr_scr.popDialog()
            end
          end)
        _mgr_scr.pushDialog(dlg)
    end
    _player.setDirty()
    _player.save()


   --[[测试有无网络
   local check = false
   local _popupTip = require('game.mgr_scr').popupTip
   local targetPlatform = cc.Application:getInstance():getTargetPlatform()
   if  (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        check = plat.checkNetWork()
   elseif (cc.PLATFORM_OS_WINDOWS == targetPlatform)  then
        check = true
   end
   if check then
      _popupTip("网络状态良好")
   else
      _popupTip("请检查网络状态")
   end
    
   --]]

   --[[签到
   local panel = require('game.ui.panel')
   local dlg = panel.Panel(
    {
      modal=true,
      ani=true,
      type_panel=panel.SIGN
    })
   --]]

     --[[时间戳转时间
    local _popupTip = require('game.mgr_scr').popupTip
     local test_time = plat.getNetWorkTime()
    
    if test_time == -100 then
        _popupTip("无法连接服务器 请检查网络")
    elseif test_time == -200 then
        _popupTip("请求超时 请重试")
    elseif test_time == -300 then
        _popupTip("响应超时 请重试")
    elseif test_time == -400 then
        _popupTip("网络异常 请检查网络")
    else
        _popupTip("正常获取时间！")
        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        if  (cc.PLATFORM_OS_ANDROID == targetPlatform) then
            test_time = math.floor(test_time/1000)
        elseif (cc.PLATFORM_OS_WINDOWS == targetPlatform)  then

        end
         _popupTip(tostring(test_time))
         local tab = os.date("*t",test_time)
--         _popupTip(tostring(tab.year))
--         _popupTip(tostring(tab.month))
--          _popupTip(tostring(tab.day))
         cclog("tab.year = " ..tab.year)
         cclog("tab.month = " ..tab.month)
         cclog("tab.day = " ..tab.day)
         cclog("tab.hour = " ..tab.hour)
          -- cclog("tab.min = " ..tab.min)
          -- cclog("tab.sec = " ..tab.sec)
    end
    --]]

  --[[
  --公告界面:ANNOUNCEMENT
  --登录界面:LOGIN
  --新手界面:GUIDE
  --帮助界面:HELP 
  --豪华礼包:LUXURY
  --满级礼包:MAXLEVEL
  --复活界面:DIED
  --道具礼包界面:REWARD
  --宝箱大礼包:BIGREWARD
  --金币礼包:GOLD
  --购买提示界面:BUYTIPS
  --挑战礼包:CHALLENGE
  local function cb_enter()
     cclog("cb_enter====================cb_enter")
  end
  local panel = require('game.ui.panel')
  local dlg = panel.Panel(
    {
      modal=true,
      ani=true,
      type_panel=panel.CHALLENGE,
      cb_enter=cb_enter,
      endback=cb_enter
    })
  --]]



end

local function _onMiracle()
  require('game.ui.miracle').Panel{
    modal=true,
    ani=true,
    cb_endback=function()
      _data.main:setVisible(true)
    end
  }
  _data.main:setVisible(false)
end

local function _onPets()
  local panel = require('game.ui.pets')
  local dlg = panel.Pets{
    modal=true,
    ani=true,
    cbEndBack=function()
      _data.main:setVisible(true)
    end,
    cbFightBoss=function()
      _data.main:setVisible(true)
      _onButtonChallenge()
    end,
  }
  _data.main:setVisible(false)
end

local function _onNewGift()
  local panel = require('game.ui.panel')
  local dlg = panel.Panel(
    {
      modal=true,
      ani=true,
      type_panel=panel.GUIDE,
      cb_enter=function() end,
      endback=function() end,
    })
end

local function _showMain()
  local main = cc.CSLoader:createNode('ui/main.csb')
  _data.main = main
  _data.layer:addChild(main, 1)
  
  local h = ccui.Helper
  local s = h.seekWidgetByNameOnNode
  local btn
  
  btn = s(h, main, 'btn_single')
  btn:addTouchEventListener(_misc.createClickCB(_onButtonSingle))
  
  btn = s(h, main, 'btn_pk')
  btn:addTouchEventListener(_misc.createClickCB(_onButtonChallenge))

  btn = s(h, main, 'btn_shop')
  btn:addTouchEventListener(_misc.createClickCB(_onButtonShop))
  

  btn = s(h, main, 'btn_rank')
  btn:addTouchEventListener(_misc.createClickCB(_onButtonRank))

  
  btn = s(h, main, 'chk_music')
  btn:addTouchEventListener(_misc.createClickCB(_onCheckboxMusic))
  
  btn = s(h, main, 'chk_sound')
  btn:addTouchEventListener(_misc.createClickCB(_onCheckboxSound))

  btn = s(h, main, 'btn_gift')
  btn:addTouchEventListener(_misc.createClickCB(_onNewGift))
  _tool.runScale(btn)

  btn = s(h, main, 'btn_pets')
  btn:addTouchEventListener(_misc.createClickCB(_onPets))

  btn = s(h, main, 'btn_miracle')
  btn:addTouchEventListener(_misc.createClickCB(_onMiracle))

  --单元测试
  cclog("-----------单元测试-----------")
  local _list = s(h, main, 'test_ListView')
  local _cell = s(h, main, 'test_cell')
  if not require('config').test_data then
      _list:setVisible(false)
      _cell:setVisible(false)
  else
      _list:setItemModel(_cell)
      _cell:removeFromParent()
      local i=0
      for k,v in pairs(require('config').test_data) do
         _list:insertDefaultItem(i)
         local item = _list:getItem(i)
         btn = _createCell(item,v)
         btn:addTouchEventListener(
          _misc.createClickCB(function()
                      _onTestBtn(v)
                  end 
         ))
         i = i + 1
      end
  end
  
  _checkGuide()
end

_checkGuide = function()
  if _guide_logic.checkMainGuide(2, 
    ccui.Helper:seekWidgetByNameOnNode(_data.main, 'btn_single'),
    _onButtonSingle)
  then
    return
  end
  if _guide_logic.checkMainChallengeGuide(2,
    ccui.Helper:seekWidgetByNameOnNode(_data.main, 'btn_pk'),
    _onButtonChallenge)
  then
    return
  end
  if _guide_logic.checkMainMiracleGuide(2,
    ccui.Helper:seekWidgetByNameOnNode(_data.main, 'btn_miracle'),
    _onMiracle)
  then
    return
  end
end

local function _popLogin()
  local panel = require('game.ui.panel')
  local dlg = panel.Panel(
    {
      modal=false,
      ani=false,
      type_panel=panel.LOGIN,
      cb_enter=_showMain,
      endback=_showMain,
    })
end

local function _popHelp()
  local panel = require('game.ui.panel')
  local dlg = panel.Panel(
    {
      modal=false,
      ani=false,
      type_panel=panel.HELP,
      endback=_showMain,--_popLogin,
    })

end

local function _popAnnounce()
  local panel = require('game.ui.panel')
  local dlg = panel.Panel{
      modal=false,
      ani=false,
      type_panel=panel.ANNOUNCEMENT,
      endback=_popHelp,
    }
end

local function _popRankGift()
--    local _rank_logic = require('game.ui.rank.rank_logic')
--    _rank_logic.checkUpdate()--刷新一下排行榜
    if _player.get().rank.gift.isget == _rank_data.GIFT_GET then
        local rank_panel = require('game.ui.rank.rank_panel')
        local dlg = rank_panel.RankPanel(
        {
            modal=true,
            ani=true,
            type_panel=rank_panel.RANKGIFT,
            cb_enter=_popAnnounce,
            endback=_popAnnounce
        })
    else
        _popAnnounce()
    end
    
end

local function _popSign()
   local panel = require('game.ui.panel')
   local dlg = panel.Panel(
    {
      modal=false,
      ani=false,
      type_panel=panel.SIGN,
      cb_enter=_popRankGift,
      endback=_popRankGift
    })
end

--隔日刷新校验
local function _updateDay()
    if _tool.IsNetWork() then
        if _tool.checkday() then
            require('game.ui.pkboss').updateDialyPkNum()
        end
        require('game.ui.rank.rank_logic').checkUpdate()--刷新一下排行榜  
    end
end


local function _onKeyBack()
  if plat.confirm(
    '想要退出游戏吗？',
    '确认退出', '返回继续')
  then
    cc.Director:getInstance():endToLua()
  end
end

local function _bgRollingStart()
  local velocity = require('data.const').VELOCITY_NORMAL
  local logic_dt = 1/require('config').design.fps
  _data.layer:scheduleUpdateWithPriorityLua(
    function()
      _data.bg:scrollDown(velocity, logic_dt)
    end, 0)
end

local function _onEnter()
  _player.init()
  
  local panel = cc.CSLoader:createNode('ui/choose.csb') --坑爹的加载
  
  _mgr_snd.pushMusic('music/main.mp3')
  _data.bg = require('game.battle.bg').BG(_data.layer)
  _data.layer:addChild(_data.bg.node, -1)
  _bgRollingStart()
   
   _updateDay() 
  _popSign()
  
end

local function _onExit()
  _mgr_snd.popMusic()
  
  _player.free()
  require('game.mgr_spf').clear()
  for n,v in pairs(_data) do
    _data[n] = nil
  end
end

local function _onShow(from, action)
  _bgRollingStart()
  if not from then  --普通战斗界面返回
    if action == 'done_result' then
      --从结算界面返回
      if _guide_logic.needMainRankGuide() then
        --排行榜引导
        _guide_logic.checkMainRankGuide(2,
          ccui.Helper:seekWidgetByNameOnNode(_data.main, 'btn_rank'),
          _onButtonRank)
        return
      end
    end
  elseif from == 'scr_boss' then --挑战模式返回
    if action == 'got_debris' then
      if _guide_logic.needMainPetGuide() then
        --宠物引导
        _guide_logic.checkMainPetGuide(2,
          ccui.Helper:seekWidgetByNameOnNode(_data.main, 'btn_pets'),
          _onPets)
        return
      end
    elseif action == 'on_challenge' then
      --再挑战一次
      _onButtonChallenge()
      return
    end
  end
  --其它引导
  _checkGuide()
end

local function _onHide()
  _data.layer:unscheduleUpdate()
end

function create()
  _data.layer = cc.Layer:create()
  return {
    node = _data.layer;
    onEnter = _onEnter;
    onExit = _onExit;
    onShow = _onShow;
    onHide = _onHide;
    onKeyBack = _onKeyBack;
  }
end
