local GameService = 
{
   mainLayer = nil;
   label = nil;
   label_schedule = nil;
   max_str_len = 5;
   timeOut_schedule = nil;
   timeOut_time = 5;
   isTimeOut = false;

   wait_point = "";
   background = nil;--提示界面
   --

   metre      = nil;--米
   score      = nil;--表现分
   gold       = nil;--金币数
}
local meta = GameService
local UILayoutButton = require "src/tool/UILayoutButton"
local GameBackGroundView = require "src/GameScene/gamevbackground"
local GameView = require "src/GameScene/GameV"
local GameSceneUi = require "src/GameScene/GameSceneUi"
local GameSceneButton = require "src/GameScene/GameSceneButton"
local loadV = require "src/GameLoad/GameLoadV"
local cjson = require "cjson" 

local scheduler = cc.Director:getInstance():getScheduler()
local winSize = cc.Director:getInstance():getVisibleSize()
--引用和全局，初始化----------------------------------------------------------------------------------
-- "http://www.v5fz.com/api/accounts.php?act=accounts&uid=800000001&uname=i1603275411&sid=1&dis=3000"


function meta:init(dis,score,hero_id,hero_level)
   ---[[
   --local tmpScene = cc.Director:getInstance():getRunningScene()
   --meta.mainLayer = cc.LayerColor:create(cc.c4b(0,0,0,100))
   --tmpScene:addChild(meta.mainLayer,9999)

   meta.mainLayer = cc.LayerColor:create(cc.c4b(0,0,0,100))
   meta.metre = dis or 0
   meta.score = score or 0
   local www = meta:getlink(dis,hero_id,hero_level,score)--hero_id  hero_level用于服务器结算
   cclog("www == " ..www)
   Func_HttpRequest(www,"",meta.reasultPanelCallBack)
   --]]
   



--[[
    --meta.isTimeOut = true
   meta.label = nil;
   meta.label_schedule = nil;
   meta.max_str_len = 5;
   meta.timeOut_schedule = nil;
   meta.timeOut_time = 5;
   meta.isTimeOut = false;
   meta.metre = dis or 0
   meta.score = score or 0

   wait_point = "";
   background = nil;--提示界面


--半透明层
    local tmpScene = cc.Director:getInstance():getRunningScene()
    meta.mainLayer = cc.LayerColor:create(cc.c4b(0,0,0,100))

    
    --注册雾态
    meta:registerMuTai(meta.mainLayer)
    tmpScene:addChild(meta.mainLayer,10)

----------------------------------------------------------------------
--动画
    meta.label = cc.Label:create()
    meta.label:setSystemFontSize(36)
    meta.label:setString(".")
    meta.mainLayer:addChild(meta.label)
    meta.label:setPosition(winSize.width/2,winSize.height/2)
    meta.label_schedule = scheduler:scheduleScriptFunc(meta.runLabel, 1, false)
--20秒不反悔，则弄个重新连接
    meta.timeOut_schedule = scheduler:scheduleScriptFunc(meta.timeoutFunc, meta.timeOut_time, false)

--请求服务器
    dis = dis or 3000
    if dis == nil or dis == "" then
        dis = 0
        cclog("**************** error :传递的距离为nil 或者为 空string ****************")
        return
    end
    cclog("dis ==================== " ..dis)
    cclog("score ==================== " ..score)
    local www = meta:getlink(dis)
    cclog("www ==================== " ..www)
    Func_HttpRequest(www,"",meta.callback)
    --]]

    return meta.mainLayer
end
--进入结算界面回调
function meta.reasultPanelCallBack(msg)
    if msg == nil or msg == "" then 
        --local www = meta:getlink(dis)
        --Func_HttpRequest(www,"",meta.reasultPanelCallBack)
        --cclog("falil ====  " ..tostring(msg))
        meta:back()
    else
        --cclog("success!!!!")
        meta:release()
        --cc.Director:getInstance():popScene()
        local GameWjOverView = require "src/gameover/GameWjOverV"
        local function func(msg)
            local tab    = cjson.decode(msg)
            local itid   = tab.itid
            local status = tab.status
            local itid_tab   = Split(itid, ";")
            local status_tab = Split(status, ";")

            local bid_tab   = Split(tab.bid, ";")
            local bstatus_tab   = Split(tab.bstatus, ";")
            local temp = {}
            local btemp = {}
            for i=1,#itid_tab do
                local data = {}
                table.insert(data,itid_tab[i])
                table.insert(data,status_tab[i])
                table.insert(temp,data)
            end
            for i=1,#bid_tab do
                local data = {}
                table.insert(data,bid_tab[i])
                table.insert(data,bstatus_tab[i])
                table.insert(btemp,data)
                --cclog("bid_tab[i] == " ..bid_tab[i])
            end
            meta.gold = tab.gold--金币数
            return temp,btemp
        end
        cclog("msg ==================== " ..msg)
        local tab,btab = func(msg)
        local overLayer = GameWjOverView:init(meta.metre,meta.score,tab,btab,meta.gold)
        meta.mainLayer:addChild(overLayer)
    end
end

-----------------------------------------------------
--重试
function meta.tryAgain()
    cclog("tryAgain")
    meta.timeOut_schedule = scheduler:scheduleScriptFunc(meta.timeoutFunc, meta.timeOut_time, false)
    meta.label_schedule = scheduler:scheduleScriptFunc(meta.runLabel, 1, false)
    meta.background:setVisible(false)
    meta.label:setVisible(true)
    meta.isTimeOut = false
    local www = meta:getlink(dis)
    Func_HttpRequest(www,"",meta.callback)
end
--回调
function meta.callback(msg)
    scheduler:unscheduleScriptEntry(meta.label_schedule)
    scheduler:unscheduleScriptEntry(meta.timeOut_schedule)
    if msg == nil or msg == "" then 
        --meta.label:setString("get msg is nil or \"\"")
        --提示界面
        cclog("msg = nil")
        meta:createMenu(meta.mainLayer)
        meta.label:setVisible(false) 
        return
    end
    meta:release()
    local GameWjOverView = require "src/gameover/GameWjOverV"
    local function func(msg)
        local tab = cjson.decode(msg)
        local itid   = tab.itid
        local status = tab.status
        local itid_tab   = Split(itid, ";")
        local status_tab = Split(status, ";")
        local bid_tab   = Split(bid, ";")
        local bstatus_tab   = Split(bstatus, ";")
        local temp = {}
        local btemp = {}
        for i=1,#itid_tab do
            local data = {}
            table.insert(data,itid_tab[i])
            table.insert(data,status_tab[i])
            table.insert(temp,data)
        end
        for i=1,#bid_tab do
            local data = {}
            table.insert(data,bid_tab[i])
            table.insert(data,bstatus_tab[i])
            table.insert(btemp,data)
            cclog("bid_tab[i] == " ..bid_tab[i])
        end
        cclog("#bid_tab == " ..#bid_tab)

        meta.gold = tab.gold--金币数

        return temp,btemp
    end
    cclog("msg ==================== " ..msg)
    local tab,btab = func(msg)
    
    local overLayer = GameWjOverView:init(meta.metre,meta.score,tab,btab,meta.gold)
    meta.mainLayer:addChild(overLayer)
    --正常处理现有数据
    --meta.label:setString(msg)
end
--超时
function meta.timeoutFunc()
    cclog("超时")
    scheduler:unscheduleScriptEntry(meta.label_schedule)
    scheduler:unscheduleScriptEntry(meta.timeOut_schedule)
    --meta.label:setString("tiemout")
    meta.isTimeOut = true
    meta.label:setVisible(false)
    meta:createMenu(meta.mainLayer)--有则显示 无则创建
end
--返回
function meta:back()
    SimpleAudioEngine:getInstance():stopAllEffects()
    playEffect("res/music/effect/btn_click.ogg")
    --meta:release()--释放

    --背景层释放
    GameBackGroundView:ReleaseAll()
    --释放主层数据
    GameView:release()
    --释放UI层
    GameSceneUi:release()
    --释放控制层
    GameSceneButton:release()

    --loading
    cc.Director:getInstance():getRunningScene():addChild(loadV:initUiRes())
end

function meta:release()
    meta.mainLayer:removeAllChildren(true)--remove所有此界面子节点
end

----------------------------------------------------------------------------------------------------------private
--提示界面
function meta:createMenu(layer)
    
    if meta.background then
        meta.background:setVisible(true)
    else
        --背景框
        meta.background = cc.Scale9Sprite:createWithSpriteFrameName("tanchukuang_10.png")
        meta.background:setCapInsets(cc.rect(32,45,5,5))
        meta.background:setContentSize(cc.size(450,250))
        meta.background:setPosition(g_visibleSize.width/2,g_visibleSize.height/2)
        layer:addChild(meta.background)

        local tip_label = cc.LabelTTF:create("链接超时","宋体",30)
        --tip_label:setColor(cc.c3b(255,255,0))
        tip_label:setPosition(220,160)
        meta.background:addChild(tip_label)

        --重试按钮
        local arr = {
         label_type = LABEL_TYPE_ENUM.ttf,
         button_type = BUTTON_TYPE_ENUM.high,
         label = "重试",
         font = "宋体",--字体 或 填字体库fnt
         font_size = 24,--fnt模式下 此参数用不上
         button1 = "anniu1_01.png",
         button2 = "anniu1_02.png",
         x = 125,
         y = 50
     
         }
         local retry = UILayoutButton:createUIButton(arr)
         retry:registerControlEventHandler(meta.tryAgain,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)--按下按钮
         meta.background:addChild(retry)---重试


        --返回按钮
        local arr = {
         label_type = LABEL_TYPE_ENUM.ttf,
         button_type = BUTTON_TYPE_ENUM.high,
         label = "返回",
         font = "宋体",--字体 或 填字体库fnt
         font_size = 24,--fnt模式下 此参数用不上
         button1 = "anniu1_01.png",
         button2 = "anniu1_02.png",
         x = 325,
         y = 50
     
         }
         local back = UILayoutButton:createUIButton(arr)
         back:registerControlEventHandler(meta.back,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)--按下按钮
         meta.background:addChild(back)---返回
    end

end
function meta.runLabel()
    if meta.isTimeOut then
         meta.isTimeOut:setVisible(false)
    else
        local title = "请稍后"
        local len = string.len(meta.wait_point)
        if len >= meta.max_str_len then 
            meta.wait_point = "."
            meta.label:setString(title ..meta.wait_point)
        else
            meta.wait_point = meta.wait_point .."."
            meta.label:setString(title ..meta.wait_point)
        end
    end
end



function meta:getlink(dis,hero_id,hero_level,score)
    return --"http://www.v5fz.com/api/accounts.php?act=accounts&uid=800000001&uname=i1603275411&sid=1&dis=3000"
    g_wjjieurl .."&uid=" ..meta:get_uid() .."&uname=" ..meta:get_uname() .."&sid=" ..meta:get_sid() .."&dis=" ..tostring(dis) .."&hid=" ..tostring(hero_id) .."&level=" ..tostring(hero_level) .."&bid=" ..tostring(g_boss) .."&score=" ..tostring(score)
end

function meta:get_act()
    return "accounts"
end

function meta:get_uid()
    return  g_userinfo.uid
end

function meta:get_uname()
    return g_userinfo.uname
end

function meta:get_sid()
    return g_userinfo.sid
end



function meta:registerMuTai(tar)
    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchMoved(touch, event)

    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    local scene = cc.Director:getInstance():getRunningScene()
    local eventDispatcher = scene:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, tar)

end


return GameService

