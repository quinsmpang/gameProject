local GameActivityView=
{
    mainLayer   = nil,  --本图层
    panel_activity  = nil, 
    isOpened       = true ,  --本图层是否开启
    readyMeta      = nil,
    panel_activity_1 = nil,
    panel_activity_2 = nil,
    panel_activity_3 = nil,
    panel_activity_4 = nil,
    labelAtlas_act4Diamond = nil,
    labelAtlas_act4Gold    = nil,
    labelAtlas_act4Strength= nil,
    haveGift1       = 0 ,
    haveGift2       = 0 ,
    button_act4reward_28 ,
    button_act4reward_58 ,
}--@ 游戏逻辑主图层
local meta = GameActivityView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameActivityModel = require "src/GameActivity/GameActivityM"

function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createActivity()
    meta.setUserData()
    statistics(2100)
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    meta.labelAtlas_act4Diamond:setString(g_userinfo.diamond)    
    meta.labelAtlas_act4Gold:setString(g_userinfo.gold)       
    meta.labelAtlas_act4Strength:setString(g_userinfo.physical)
    meta.haveGift1 = 0
    meta.haveGift2 = 0
    for i=1,#g_userinfo.heros do 
        print("1")
        if tonumber(g_userinfo.heros[i].id) == 100010 then  --盖伦
            meta.haveGift1 = meta.haveGift1 + 1 
        elseif tonumber(g_userinfo.heros[i].id) == 100017 then --赵信
            meta.haveGift1 = meta.haveGift1 + 1 
        elseif tonumber(g_userinfo.heros[i].id) == 100024 then --狐狸
            meta.haveGift2 = meta.haveGift2 + 1 
        elseif tonumber(g_userinfo.heros[i].id) == 100038 then --探险家
            meta.haveGift1 = meta.haveGift1 + 1 
        elseif tonumber(g_userinfo.heros[i].id) == 100045 then --剑圣
            meta.haveGift2 = meta.haveGift2 + 1
        end 
    end 
    if meta.haveGift1 >= 3 then 
        meta.button_act4reward_28:setVisible(false)
    end 
    if meta.haveGift2 >= 2 then 
        meta.button_act4reward_58:setVisible(false)
    end 
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createActivity()
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/game_activity/game_activity.ExportJson")
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_activity.ExportJson")
    --uiLayout:setPosition(g_origin.x,g_origin.y)
    meta.panel_activity = uiLayout:getChildByName("Panel_activity")
    meta.panel_activity_1 = uiLayout:getChildByName("Panel_activity_1")
    meta.panel_activity_2 = uiLayout:getChildByName("Panel_activity_2")
    meta.panel_activity_3 = uiLayout:getChildByName("Panel_activity_3")
    meta.panel_activity_4 = uiLayout:getChildByName("Panel_activity_4")
    local button_back              = meta.panel_activity:getChildByName("Button_back")
    local listView_activity        = meta.panel_activity:getChildByName("ListView_activity")
    local image_act_1              = listView_activity:getChildByName("Image_act_1")
    local image_act_2              = listView_activity:getChildByName("Image_act_2")
    local image_act_3              = listView_activity:getChildByName("Image_act_3")
    local image_act_4              = listView_activity:getChildByName("Image_act_4")
    local button_act_1             = image_act_1:getChildByName("Button_act_1")
    local button_act_2             = image_act_2:getChildByName("Button_act_2")
    local button_act_3             = image_act_3:getChildByName("Button_act_3")
    local button_act_4             = image_act_4:getChildByName("Button_act_4")
    local button_act2_back         = meta.panel_activity_2:getChildByName("Button_act2_back")
    local button_act1_back         = meta.panel_activity_1:getChildByName("Button_act1_back")
    local button_act4_back         = meta.panel_activity_4:getChildByName("Button_act4_back")
    local listView_act2            = meta.panel_activity_2:getChildByName("ListView_act2")
    local image_act2_1             = listView_act2:getChildByName("Image_act2_1")
    local image_act2_2             = listView_act2:getChildByName("Image_act2_2")
    local image_act2_3             = listView_act2:getChildByName("Image_act2_3")
    local progressBar_act2_1       = image_act2_1:getChildByName("ProgressBar_act2_1")
    local progressBar_act2_2       = image_act2_1:getChildByName("ProgressBar_act2_2")
    local progressBar_act2_3       = image_act2_1:getChildByName("ProgressBar_act2_3")
    local panel_fox                = meta.panel_activity_4:getChildByName("Panel_fox")
    local panel_fox2               = meta.panel_activity_4:getChildByName("Panel_fox2")
    meta.button_act4reward_28     = panel_fox:getChildByName("Button_act4reward_28")
    meta.button_act4reward_58     = panel_fox:getChildByName("Button_act4reward_58")
    local imageView_act4Strength   = meta.panel_activity_4:getChildByName("ImageView_act4Strength")
    local imageView_act4Diamond    = meta.panel_activity_4:getChildByName("ImageView_act4Diamond")
    local imageView_act4Gold       = meta.panel_activity_4:getChildByName("ImageView_act4Gold")
    meta.labelAtlas_act4Diamond    = imageView_act4Diamond:getChildByName("LabelAtlas_act4Diamond")
    meta.labelAtlas_act4Gold       = imageView_act4Gold:getChildByName("LabelAtlas_act4Gold")
    meta.labelAtlas_act4Strength   = imageView_act4Strength:getChildByName("LabelAtlas_act4Strength")
    local button_act4Diamond       = meta.panel_activity_4:getChildByName("Button_act4Diamond")
    local button_act4Gold          = meta.panel_activity_4:getChildByName("Button_act4Gold")
    local button_act4Strength      = meta.panel_activity_4:getChildByName("Button_act4Strength")
    --progressBar_act2_1:setPercent(50)

    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            print(touch:getName())
           --meta.mainLayer:removeFromParent()
           meta:remove()
        end
       -- if eventType == ccui.TouchEventType.ended then 
           
       --end 
    end 
    
    --进入其他子界面
    local function toSonPanelEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then 
           print(touch:getName())
           local name = touch:getName()
           if name == "Button_act_1" then 
                meta.panel_activity_2:setVisible(true)
           elseif  name == "Button_act_2" then 
                meta.panel_activity_1:setVisible(true)
           elseif  name == "Button_act_3" then 
                meta.panel_activity_4:setVisible(true)
           elseif  name == "Button_act_4" then 
            
           end 
       end 
    end

    --子界面转活动界面的方法
    local function toParentPanelEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
             print(touch:getName())
           local name = touch:getName()
           if name == "Button_act1_back" then 
                meta.panel_activity_1:setVisible(false)
           elseif  name == "Button_act2_back" then 
                meta.panel_activity_2:setVisible(false)
           elseif  name == "Button_act3_back" then 
           elseif  name == "Button_act4_back" then 
                meta:remove()
                --meta.panel_activity_4:setVisible(false)
           end 
        end
       
    end


    local function getGiftEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        --end
        --if eventType == ccui.TouchEventType.began then 
        --end 
        --if eventType == ccui.TouchEventType.ended then 
           --print(touch:getName())
           local touchName = touch:getName()
           if touchName == "Button_act4reward_28" then 
                meta.alipay("28")
                 print("28")
           elseif touchName == "Button_act4reward_58" then 
                meta.alipay("58")
                print("58")
           end 
        end 
    end 

    --进去购买界面
    local function toBuyEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            local touchName = touch:getName()
            if touchName == "Button_act4Gold" then 
                print("buyGold")
                meta.readyMeta.enterGold()
            elseif touchName == "Button_act4Diamond"  then 
                print("buyDiamond")
                meta.readyMeta.enterDiamond()
            elseif touchName == "Button_act4Strength" then 
                print("buyStrength")
                meta.readyMeta.enterStrength()
            end 
        end
    end 

    --添加监听
    button_back:addTouchEventListener(backEvent)
    button_act_1:addTouchEventListener(toSonPanelEvent)
    button_act_2:addTouchEventListener(toSonPanelEvent)
    button_act_3:addTouchEventListener(toSonPanelEvent)
    button_act_4:addTouchEventListener(toSonPanelEvent)
    button_act1_back:addTouchEventListener(toParentPanelEvent)
    button_act2_back:addTouchEventListener(toParentPanelEvent)
    button_act4_back:addTouchEventListener(toParentPanelEvent)
    meta.button_act4reward_28:addTouchEventListener(getGiftEvent) 
    meta.button_act4reward_58:addTouchEventListener(getGiftEvent)
    button_act4Diamond:addTouchEventListener(toBuyEvent)
    button_act4Gold:addTouchEventListener(toBuyEvent)
    button_act4Strength:addTouchEventListener(toBuyEvent)

    meta.mainLayer:addChild(uiLayout)
end 

--删除 主图层 函数
function meta:remove()
    print(meta.mainLayer:getName())
    meta.readyMeta:setActivityFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

--设置钻石值
function meta.setDiamond()
    meta.labelAtlas_act4Diamond:setString(g_userinfo.diamond)
end 

--设置金币值
function meta.setGold()
    meta.labelAtlas_act4Gold:setString(g_userinfo.gold)
end

--设置体力值
function meta.setStrength()
    meta.labelAtlas_act4Strength:setString(g_userinfo.physical)
end


function meta.rewardGift(gift_id)
    local function myGift(msg)
        print(msg)
        local cjson = require "cjson"
		local obj = cjson.decode(msg)
        if obj.code == 1 then  
            g_userinfo.gold =  obj.member_info.member_gold
            g_userinfo.diamond =  obj.member_info.member_diamond
            g_userinfo.physical =  obj.member_info.member_physical
            g_userinfo.heros = {}
            for i=1,#obj.hero_info do
                g_userinfo.heros[i] = {}
                g_userinfo.heros[i].level = obj.hero_info[i].hero_level
                g_userinfo.heros[i].id = obj.hero_info[i].hero_hrid
            end
            meta.readyMeta.setUserData()
            meta.readyMeta.initHeroData()
            meta.setUserData()
        end 
    end
    local requrl = g_url.first_gift.."&uid=".. g_userinfo.uid .. "&uname=" .. g_userinfo.uname .. "&sid=" .. g_userinfo.sid .. "&gift_id=" .. gift_id
    Func_HttpRequest(requrl,"",myGift)
end 


--支付
function meta.alipay(payMoney)
     ---[[
     local money = payMoney
     local function SendToSever(msg)
            print("支付:"..msg)
            if msg ~= "" then
                local cjson = require "cjson"
			    local obj = cjson.decode(msg)
                if tonumber(obj.code) == 1 then
                    if tostring(money) == "28" then 
                        meta.rewardGift(1)     --获得礼包一
                        statistics(2101)
                    elseif tostring(money) == "58" then 
                        meta.rewardGift(2)     --获得礼包二
                        statistics(2102)
                    end 
                end
            else
                --获取钻石失败
            end
    end
    
    local function payCallBack(param)--返回订单号
        if param ~= "" then
            local act         = "act=getorder"
            local uid         = "&uid=" .. g_userinfo.uid
            local uname       = "&uname=" .. g_userinfo.uname
            local usid        = "&sid=" .. g_userinfo.sid
            local trans_code  = "&trans_code=" ..param --订单号
            local trans_money = "&trans_money=" ..money--价格
            local atype       = ""
            if tostring(money) == "28" then 
                atype       = "&type=1"
            elseif tostring(money) == "58" then 
                atype       = "&type=2"
            end 
            local url = g_payurl..uid ..uname ..usid ..trans_code ..trans_money..atype
            Func_HttpRequest(url,"",SendToSever)
        else
         --返的订单号是空
            --androidAlert("空订单")
        end
    end

    local function testPay()
        local uid         = g_userinfo.uid
        local uname       = g_userinfo.uname
        local usid        = g_userinfo.sid
        local role_data   = uid .. ";" .. uname ..";" ..usid ..";" .."type=1"
        --androidAlipaySec(money.."元钻石",role_data,money,payCallBack)
        Func_AlipaySec(money.."元钻石",role_data,money,payCallBack)
    end
    testPay()
    --]]
end

return GameActivityView
