local GameDiamondView=
{
    mainLayer   = nil,  --本图层
    panel_diamond  = nil, 
    isOpened       = true ,  --本图层是否开启
    readyMeta      = nil,
    button_back    = nil,
}--@ 游戏逻辑主图层
local meta = GameDiamondView
--setmetatable(meta,meta)
--meta.__index=meta


--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameDiamondModel = require "src/GameDiamond/GameDiamondM"

function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createDiamond()
    statistics(1700)
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
--返回(释放)事件 

function meta:createDiamond()
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/game_diamond/game_diamond.ExportJson")
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_diamond.ExportJson")

    --uiLayout:setPosition(g_origin.x,g_origin.y)
    meta.panel_diamond = uiLayout:getChildByName("Panel_diamond")
    meta.button_back = meta.panel_diamond:getChildByName("Button_back")
    local button_diamond_1 = meta.panel_diamond:getChildByName("Button_diamond_1")
    local button_diamond_2 = meta.panel_diamond:getChildByName("Button_diamond_2")
    local button_diamond_3 = meta.panel_diamond:getChildByName("Button_diamond_3")
    local button_diamond_4 = meta.panel_diamond:getChildByName("Button_diamond_4")
    local button_diamond_5 = meta.panel_diamond:getChildByName("Button_diamond_5")
    local button_diamond_6 = meta.panel_diamond:getChildByName("Button_diamond_6")
    local button_gift      = meta.panel_diamond:getChildByName("Button_gift")

    --转活动界面
    local function toActivityEvent(touch,eventType)
         if eventType == ccui.TouchEventType.began then
            playEffect("res/music/effect/fight/get_item.ogg")
            print(touch:getName())
            meta.readyMeta.enterActivity()
            meta.remove()
        end
    end

    --添加监听
    meta.button_back:addTouchEventListener(meta.backEvent)
    button_diamond_1:addTouchEventListener(meta.buyDiamondEvent)
    button_diamond_2:addTouchEventListener(meta.buyDiamondEvent)
    button_diamond_3:addTouchEventListener(meta.buyDiamondEvent)
    button_diamond_4:addTouchEventListener(meta.buyDiamondEvent)
    button_diamond_5:addTouchEventListener(meta.buyDiamondEvent)
    button_diamond_6:addTouchEventListener(meta.buyDiamondEvent)
    button_gift:addTouchEventListener(toActivityEvent)
    meta.mainLayer:addChild(uiLayout)      
end 

 
function meta.backEvent(touch,eventType)
    if eventType == ccui.TouchEventType.ended then 
        print(touch:getName())
        --meta.mainLayer:removeFromParent()
        meta:remove()
    end 
end

--购买钻石
function meta.buyDiamondEvent(touch,eventType)
    if eventType == ccui.TouchEventType.ended then 
        print(touch:getName())
    end 
    if eventType == ccui.TouchEventType.ended then 
        if touch:getName() == "Button_diamond_1" then 
            --统计意图购买钻石
            meta.alipay(GameDiamondModel.diamondPrice[1])
        elseif touch:getName() == "Button_diamond_2" then
            --统计意图购买钻石
            meta.alipay((GameDiamondModel.diamondPrice[2]))
        elseif touch:getName() == "Button_diamond_3" then
            --统计意图购买钻石
            meta.alipay((GameDiamondModel.diamondPrice[3]))
        elseif touch:getName() == "Button_diamond_4" then
            --统计意图购买钻石
            meta.alipay((GameDiamondModel.diamondPrice[4]))
        elseif touch:getName() == "Button_diamond_5" then
            --统计意图购买钻石
            meta.alipay((GameDiamondModel.diamondPrice[5]))
        elseif touch:getName() == "Button_diamond_6" then
            --统计意图购买钻石
            meta.alipay((GameDiamondModel.diamondPrice[6]))
        end 
    end 
end 

--支付
function meta.alipay(payMoney)
     ---[[
     local money = payMoney
     local function SendToSever(msg)
            if msg ~= "" then
                local cjson = require "cjson"
			    local obj = cjson.decode(msg)
                if tonumber(obj.code) == 1 then
                    if money == (GameDiamondModel.diamondPrice[1]) then 
                        statistics(1701)
                    elseif money == GameDiamondModel.diamondPrice[2] then
                        statistics(1702)
                    elseif money == GameDiamondModel.diamondPrice[3] then
                        statistics(1703)
                    elseif money == GameDiamondModel.diamondPrice[4] then
                        statistics(1704)
                    elseif money == GameDiamondModel.diamondPrice[5] then
                        statistics(1705)
                    elseif money == GameDiamondModel.diamondPrice[6] then
                        statistics(1706)
                    end 
                    g_userinfo.gold =  obj.member_info.member_gold
                    g_userinfo.diamond =  obj.member_info.member_diamond
                    g_userinfo.physical =  obj.member_info.member_physical
                end
                meta.readyMeta.setUserData()
            else
                --获取钻石失败
            end
    end
    
    local function payCallBack(param)--返回订单号
        if param ~= "" then
            local uid         = "&uid=" ..g_userinfo.uid
            local uname       = "&uname=" ..g_userinfo.uname
            local usid        = "&sid=" .. g_userinfo.sid
            local trans_code  = "&trans_code=" ..param --订单号
            local trans_money = "&trans_money=" ..money--价格
            local url = g_payurl..uid ..uname ..usid ..trans_code ..trans_money
            Func_HttpRequest(url,"",SendToSever)
        else
         --返的订单号是空
        end
    end
    local function testPay()
        local uid         = g_userinfo.uid
        local uname       = g_userinfo.uname
        local usid        = g_userinfo.sid
        local role_data   = uid .. ";" .. uname ..";" ..usid ..";" .."type="
        --androidAlipaySec(money.."元钻石",role_data,money,payCallBack)
        Func_AlipaySec(money.."元钻石",role_data,money,payCallBack)
    end
    testPay()
    --]]
end

--删除 主图层 函数
function meta.remove()
    meta.readyMeta:setDiamondState(false)
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

return GameDiamondView
