local GameGoldView=
{
    mainLayer   = nil,  --本图层
    panel_gold  = nil, 
    isOpened       = true ,  --本图层是否开启
    readyMeta      = nil,
}--@ 游戏逻辑主图层
local meta = GameGoldView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameGoldModel = require "src/GameGold/GameGoldM"

function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createGold()
    statistics(1600)
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createGold()
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/game_gold/game_gold.ExportJson")
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_gold.ExportJson")
    --uiLayout:setPosition(g_origin.x,g_origin.y)
    meta.panel_gold = uiLayout:getChildByName("Panel_gold")
    local button_back = meta.panel_gold:getChildByName("Button_back")
    local button_gold_1 = meta.panel_gold:getChildByName("Button_gold_1")
    local button_gold_2 = meta.panel_gold:getChildByName("Button_gold_2")
    local button_gold_3 = meta.panel_gold:getChildByName("Button_gold_3")
    local button_gold_4 = meta.panel_gold:getChildByName("Button_gold_4")
    local button_gold_5 = meta.panel_gold:getChildByName("Button_gold_5")
    local button_gold_6 = meta.panel_gold:getChildByName("Button_gold_6")
    local panel_goldYes = uiLayout:getChildByName("Panel_goldYes")
    local button_yes    = panel_goldYes:getChildByName("Button_yes")
    local button_no     = panel_goldYes:getChildByName("Button_no")
    local button_gift   = meta.panel_gold:getChildByName("Button_gift")

    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            print(touch:getName())
            --meta.mainLayer:removeFromParent()
            meta:remove()
        end 
    end 

    --购买事件
    function buyEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then 
            local pid = 0
            if touch:getName() == "Button_gold_1" then 
                pid = 180009
            elseif touch:getName() == "Button_gold_2" then 
                pid = 180010
            elseif touch:getName() == "Button_gold_3" then
                pid = 180011
            elseif touch:getName() == "Button_gold_4" then
                pid = 180012
            elseif touch:getName() == "Button_gold_5" then
                pid = 180013
            elseif touch:getName() == "Button_gold_6" then 
                pid = 180014
            end
            local function myBuyGold(msg)
                print(msg)
                local cjson = require "cjson" 
                local obj  = cjson.decode(msg)
                if tonumber(obj.code) == 1 then 
                    print("成功购买金币")
                    local tongjiNum = tonumber(tonumber((pid - 180008)) + 1600)
                    statistics(tongjiNum)
                    g_userinfo.gold =  obj.member_info.member_gold
                    g_userinfo.diamond =  obj.member_info.member_diamond
                    g_userinfo.physical =  obj.member_info.member_physical
                    meta.readyMeta.setUserData()
                    
                else 
                    print("购买金币不成功")
                    panel_goldYes:setVisible(true)
                end 
            end 
            --http://www.v5fz.com/api/consume.php?act=exchange_gold&uid=100000016&uname=b1148065466&sid=1&pid=180010
            local requrl = g_url.exchange_gold.."&uid=".. g_userinfo.uid  .."&uname=".. g_userinfo.uname .."&sid=".. g_userinfo.sid .."&pid="..pid
            if g_debug_btn then 
            else
                Func_HttpRequest(requrl,"",myBuyGold,false)
            end 
        end 
    end 

    local function confirmEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end 
        if eventType == ccui.TouchEventType.ended then 
            if touch:getName() == "Button_yes" then 
                --进入购买钻石界面
                print("yes")
                meta.readyMeta.enterDiamond()
                meta:remove()
            else 
                print("no")
                panel_goldYes:setVisible(false)
            end  
        end 
    end  


    --转活动界面
    local function toActivityEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end 
        if eventType == ccui.TouchEventType.ended then
            print(touch:getName())
            meta.readyMeta.enterActivity()
            meta.remove()
        end
    end

    --添加监听
    button_back:addTouchEventListener(backEvent)
    button_gold_1:addTouchEventListener(buyEvent)
    button_gold_2:addTouchEventListener(buyEvent)
    button_gold_3:addTouchEventListener(buyEvent)
    button_gold_4:addTouchEventListener(buyEvent)
    button_gold_5:addTouchEventListener(buyEvent)
    button_gold_6:addTouchEventListener(buyEvent)
    button_yes:addTouchEventListener(confirmEvent)
    button_no:addTouchEventListener(confirmEvent)
    button_gift:addTouchEventListener(toActivityEvent)
    meta.mainLayer:addChild(uiLayout)
end 



--删除 主图层 函数
function meta:remove()
    meta.readyMeta:setGoldFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

--

return GameGoldView
