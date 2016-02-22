local GameStrengthView=
{
    mainLayer         = nil,  --本图层
    panel_strength    = nil, 
    isOpened          = true ,  --本图层是否开启
    readyMeta         = nil,
    downTimeSch       = nil,   --倒数定时器
    label_refreshTime = nil , 
    tbGoldPrice    =            ---没有梯级以后清掉
    {
        50,
        50,
        100,
        100,
        200,
        200,
        500,
        500
    },
    label_price      = nil,
    label_buyTen     = nil,
    label_buyOne     = nil,
}--@ 游戏逻辑主图层
local meta = GameStrengthView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameStrengthModel = require "src/GameStrength/GameStrengthM"

function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createStrength()
    meta.setUserData()
    --统计
    statistics(1500)
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 


--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createStrength()
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_strength.ExportJson")

    meta.panel_strength     = uiLayout:getChildByName("Panel_strength")
    local button_back       = meta.panel_strength:getChildByName("Button_back")
    local button_buyOne     = meta.panel_strength:getChildByName("Button_buyOne")
    local imageView_dialog  = meta.panel_strength:getChildByName("ImageView_dialog")
    meta.label_refreshTime  = imageView_dialog:getChildByName("Label_refreshTime")
    meta.downTimeSch        = cc.Director:getInstance():getScheduler():scheduleScriptFunc(meta.showTime,1,false)
    local panel_strengthYes = uiLayout:getChildByName("Panel_strengthYes")
    local button_yes        =  panel_strengthYes:getChildByName("Button_yes")
    local button_no         =  panel_strengthYes:getChildByName("Button_no")
    meta.label_price       =  meta.panel_strength:getChildByName("Label_price")

    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
           playEffect("res/music/effect/fight/get_item.ogg")
        end 
        if eventType == ccui.TouchEventType.ended then 
           print(touch:getName())
           meta:remove()
       end 
    end 
    
    --购买事件
    local function buyEvent(touch,eventType)
        ---[[
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            local amount = 1
            local function myBuyStrength(msg)
                if msg == "" then 
                    print("购买不成功")
                else
                    local cjson = require "cjson"
                    local temp_conf = cjson.decode(msg)
                    if temp_conf.code == 1 then 
                        print("购买成功")
                        statistics(1501)
                        print(msg)
                        local cjson = require "cjson"
			            local obj = cjson.decode(msg)
                        g_userinfo.gold =  obj.member_info.member_gold
                        g_userinfo.diamond =  obj.member_info.member_diamond
                        g_userinfo.physical =  obj.member_info.member_physical
                        meta.readyMeta.setUserData()
                        if meta.readyMeta.isOpened.kind then 
                            meta:remove()
                        end 
                    else 
                        panel_strengthYes:setVisible(true)
                        print("购买不成功")
                    end 
                end 
            end 

            local requrl = g_url.exchange_physical.."&uid=".. g_userinfo.uid .. "&uname=" .. g_userinfo.uname .. "&sid=" .. g_userinfo.sid .."&amount="..amount
            if g_debug_btn then
            else  
                Func_HttpRequest(requrl,"",myBuyStrength,false)
            end 
        end 
        --]]
    end 
   
   --钻石不足，是否进入钻石界面
   local function confirmEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
           playEffect("res/music/effect/fight/get_item.ogg")
        end 
        if eventType == ccui.TouchEventType.ended then 
            print(touch:getName())
            if touch:getName() == "Button_yes" then 
                --进入购买钻石界面
                print("yes")
                meta.readyMeta.enterDiamond()
                meta:remove()
            else 
                print("no")
                panel_strengthYes:setVisible(false)
            end  
        end 
    end 

    --添加监听
    button_back:addTouchEventListener(backEvent)
    button_buyOne:addTouchEventListener(buyEvent)
    button_yes:addTouchEventListener(confirmEvent)
    button_no:addTouchEventListener(confirmEvent)
    meta.mainLayer:addChild(uiLayout)
end 

function meta:showTime()
    local countdownTime = meta.readyMeta:getCountDownTime()
    local minTime = string.format("%02d:%02d",math.floor( countdownTime / 60),math.floor( countdownTime % 60))
    meta.label_refreshTime:setString(minTime)
end 

--删除 主图层 函数
function meta:remove()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(meta.downTimeSch)
    meta.readyMeta:setStrengthFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

--设置金币数量
function meta:setDiamondPrice()
    local strengthCountField = nil 
    strengthCountField = getData(CONFIG_USER_DEFAULT.UserId)..getData(CONFIG_USER_DEFAULT.UserSid)
end 

--显示体力的价格
function meta.recordStrengthCount()
    local strengthCountField = nil 
    strengthCountField = getData(CONFIG_USER_DEFAULT.UserId)..getData(CONFIG_USER_DEFAULT.UserSid)
    local strengthCount = getData(strengthCountField)
    if strengthCount ~= nil then 
        local tb_strengthCount =Split(strengthCount,";")
        if tb_strengthCount[1] == os.date("%Y-%m-%d") then 
            print("是今天")
            meta.setStrengthPrice()
        else 
            local strengthCountData  = os.date("%Y-%m-%d")..";".."0"
            setData(strengthCountField,strengthCountData)
            meta.setStrengthPrice()
        end 
    else 
        local firstStrength = os.date("%Y-%m-%d")..";".."0"
        setData(strengthCountField,firstStrength)
    end 
end

--[[
function meta.setStrengthPrice()
     local strengthCountField = nil 
    strengthCountField = getData(CONFIG_USER_DEFAULT.UserId)..getData(CONFIG_USER_DEFAULT.UserSid)
    meta.label_price:setString("1")  
    meta.label_buyTen:setString("2") 
    meta.label_buyOne:setString("3")     
    local strengthData = getData(strengthCountField)
    local tb_strengthCount =Split(strengthData,";")
    print(tb_strengthCount[2])
    local curNOPrice  = tb_strengthCount[2]+1 
    if curNOPrice <= 9 then 
        local curPrice = meta.tbGoldPrice[tb_strengthCount[2]+1]
        meta.label_price:setString("x"..curPrice)  
        meta.label_buyTen:setString("x"..curPrice*8.8) 
        meta.label_buyOne:setString("x"..curPrice)
    else
         meta.label_price:setString("一天最多充值八次")
         meta.label_buyTen:setString("不能购买") 
         meta.label_buyOne:setString("不能购买")
    end 
end 
--]]

return GameStrengthView
