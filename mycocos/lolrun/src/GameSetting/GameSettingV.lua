local GameSettingView=
{
    mainLayer      = nil,  --本图层
    panel_setting  = nil, 
    isOpened       = true ,  --本图层是否开启
    readyMeta      = nil,
}--@ 游戏逻辑主图层
local meta = GameSettingView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameSettingModel = require "src/GameSetting/GameSettingM"

function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createSetting()
    --统计成功进入设置界面
    statistics(1200)
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createSetting()
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/game_setting/game_setting.ExportJson")
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_setting.ExportJson")
    meta.panel_setting = uiLayout:getChildByName("Panel_setting")
    local button_back = meta.panel_setting:getChildByName("Button_back")
    local imageView_feedback = meta.panel_setting:getChildByName("Imageview_feedback")
    local imageView_systemSetting = meta.panel_setting:getChildByName("ImageView_systemSetting")

    --音效开关
    meta.pSwitchControl1 = cc.ControlSwitch:create(
                cc.Sprite:create("res/ui/game_setting/shezhi_anniu_05.png"),
                cc.Sprite:create("res/ui/game_setting/shezhi_anniu_02.png"),
                cc.Sprite:create("res/ui/game_setting/shezhi_anniu_01.png"),
                cc.Sprite:create("res/ui/game_setting/shezhi_anniu_06.png"),
                cc.Label:createWithSystemFont("", "Arial-BoldMT", 16),
                cc.Label:createWithSystemFont("", "Arial-BoldMT", 16)
            )
    meta.pSwitchControl1:setPosition(cc.p(352,310))
    imageView_systemSetting:addChild(meta.pSwitchControl1)

    --音乐开关
    meta.pSwitchControl2 = cc.ControlSwitch:create(
                cc.Sprite:create("res/ui/game_setting/shezhi_anniu_05.png"),
                cc.Sprite:create("res/ui/game_setting/shezhi_anniu_02.png"),
                cc.Sprite:create("res/ui/game_setting/shezhi_anniu_01.png"),
                cc.Sprite:create("res/ui/game_setting/shezhi_anniu_06.png"),
                cc.Label:createWithSystemFont("", "Arial-BoldMT", 16),
                cc.Label:createWithSystemFont("", "Arial-BoldMT", 16)
            )
    meta.pSwitchControl2:setPosition(cc.p(352,228))
    imageView_systemSetting:addChild(meta.pSwitchControl2)
    
    --按钮显示开关
    --local pSwitchControl3 = cc.ControlSwitch:create(
    --            cc.Sprite:create("res/ui/game_setting/shezhi_anniu_05.png"),
    --            cc.Sprite:create("res/ui/game_setting/shezhi_anniu_02.png"),
    --            cc.Sprite:create("res/ui/game_setting/shezhi_anniu_01.png"),
    --            cc.Sprite:create("res/ui/game_setting/shezhi_anniu_06.png"),
    --            cc.Label:createWithSystemFont("", "Arial-BoldMT", 16),
    --            cc.Label:createWithSystemFont("", "Arial-BoldMT", 16)
    --        )
    --pSwitchControl3:setPosition(cc.p(352,146))
    --imageView_systemSetting:addChild(pSwitchControl3)

    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
           playEffect("res/music/effect/fight/get_item.ogg")
           cclog(touch:getName())
           meta:remove()
       end 
    end 
    
     --音效开关
    local function effectChanged(pSender)
        if pSender:isOn() then 
            cclog("on")
            --统计成功开启音效
            statistics(1204)
            g_isEffect = true
            SimpleAudioEngine:getInstance():resumeAllEffects()--
        else 
            --统计成功关闭音效
            statistics(1203)
            cclog("off")
            g_isEffect = false
            SimpleAudioEngine:getInstance():stopAllEffects()--暂停所有音效
        end 
    end 

    -- 音乐开关
    local function musicChanged(pSender)
        if pSender:isOn() then 
            cclog("on")
            --统计成功开启音乐
            statistics(1202)
            g_isMusic = true
            SimpleAudioEngine:getInstance():resumeMusic()--
        else 
            cclog("off")
            --统计成功关闭音乐
            statistics(1201)
            g_isMusic = false
            SimpleAudioEngine:getInstance():stopMusic()--停止
        end 
    end 

    -- 按钮显示开关
    --local function showChanged(pSender)
    --    if pSender:isOn() then 
    --        cclog("on")
    --        --统计成功关闭显示按钮
    --        statistics(1206)
    --    else 
    --        cclog("off")
    --        --统计成功关闭显示按钮
    --        statistics(1205)
    --    end 
    --end 

    --设置按钮初始状态
    meta.pSwitchControl1:setOn(g_isEffect,false)
    meta.pSwitchControl2:setOn(g_isMusic,false)

    --添加监听
    button_back:addTouchEventListener(backEvent)
    meta.pSwitchControl1:registerControlEventHandler(effectChanged, cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
    meta.pSwitchControl2:registerControlEventHandler(musicChanged, cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
    --pSwitchControl3:registerControlEventHandler(showChanged, cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
    meta.mainLayer:addChild(uiLayout)
end 

--删除 主图层 函数
function meta:remove()
    meta.readyMeta:setSettingFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

return GameSettingView
