local GameTaskView=
{
    mainLayer   = nil,  --本图层
    panel_task  = nil, 
    isOpened    = true ,  --本图层是否开启
    readyMeta   = nil,
}--@ 游戏逻辑主图层
local meta = GameTaskView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameTaskModel = require "src/GameTask/GameTaskM"
local GameGuideModel = require "src/GameGuide/GameGuideM"
function meta:init(...)
    meta.mainLayer = CCLayer:create()
    meta:createTask()
    meta.initTaskData()
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createTask()
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_task.ExportJson")
    --uiLayout:setPosition(g_origin.x,g_origin.y)
    meta.panel_task = uiLayout:getChildByName("Panel_task")
    local button_back = meta.panel_task:getChildByName("Button_back")
    meta.listView_endlessTask = meta.panel_task:getChildByName("ListView_endlessTask")
    meta.image_task1                =    meta.listView_endlessTask:getChildByName("Image_task1")
    meta.image_task2                =    meta.listView_endlessTask:getChildByName("Image_task2")
    meta.image_task3                =    meta.listView_endlessTask:getChildByName("Image_task3")
    meta.image_task4                =    meta.listView_endlessTask:getChildByName("Image_task4")
    meta.image_task5                =    meta.listView_endlessTask:getChildByName("Image_task5")
    meta.image_task6                =    meta.listView_endlessTask:getChildByName("Image_task6")
    meta.image_task7                =    meta.listView_endlessTask:getChildByName("Image_task7")
    meta.image_task8                =    meta.listView_endlessTask:getChildByName("Image_task8")

    meta.button_task1_get           =    meta.image_task1:getChildByName("Button_task1_get")
    meta.button_task2_get           =    meta.image_task2:getChildByName("Button_task2_get")
    meta.button_task3_get           =    meta.image_task3:getChildByName("Button_task3_get")
    meta.button_task4_get           =    meta.image_task4:getChildByName("Button_task4_get")
    meta.button_task5_get           =    meta.image_task5:getChildByName("Button_task5_get")
    meta.button_task6_get           =    meta.image_task6:getChildByName("Button_task6_get")
    meta.button_task7_get           =    meta.image_task7:getChildByName("Button_task7_get")
    meta.button_task8_get           =    meta.image_task8:getChildByName("Button_task8_get")
                                 
    meta.button_task1_go            =    meta.image_task1:getChildByName("Button_task1_go")
    meta.button_task2_go            =    meta.image_task2:getChildByName("Button_task2_go")
    meta.button_task3_go            =    meta.image_task3:getChildByName("Button_task3_go")
    meta.button_task4_go            =    meta.image_task4:getChildByName("Button_task4_go")
    meta.button_task5_go            =    meta.image_task5:getChildByName("Button_task5_go")
    meta.button_task6_go            =    meta.image_task6:getChildByName("Button_task6_go")
    meta.button_task7_go            =    meta.image_task7:getChildByName("Button_task7_go")
    meta.button_task8_go            =    meta.image_task8:getChildByName("Button_task8_go")

    
    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
           cclog(touch:getName())
           meta:remove()
       end 
    end 


    --无尽界面的go按键
    local function endlessTaskGoEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            cclog(GameGuideModel.curMyHero:getId())
            for i = 1 , #meta.readyMeta.myHero do 
                 if GameGuideModel.curMyHero:getId() == meta.readyMeta.myHero[i]:getId() then 
                    cclog("你有这个英雄")
                    cclog(touch:getName())
                    meta.readyMeta.enterKind()
                    meta.remove()
                    --isCanPlay = 1 
                    break 
                 else 
                     if i == #meta.readyMeta.myHero then 
                         cclog("你没有这个英雄")
                         --isCanPlay = 0
                         androidAlert("需要先购买此英雄")
                     end 
                 end 
            end     
        end 
    end 

    --无尽任务面板领取按键
    local function endlessTaskRewardEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            local touchName = touch:getName()
            cclog(touchName)
            local itid = 0
            local itemid = 0
            if touchName == "Button_task1_get" then
                itid = BOX.bronze_status
                itemid = 1
            elseif touchName == "Button_task2_get" then
                itid = BOX.silver_status
                itemid = 2
            elseif touchName == "Button_task3_get" then
                itid = BOX.gold_status
                itemid = 3
            elseif touchName == "Button_task4_get" then
                itid = BOX.platinum_status
                itemid = 4
            elseif touchName == "Button_task5_get" then
                itid = BOX.boss_1
                itemid = 5
            elseif touchName == "Button_task6_get" then
                itid = BOX.boss_2
                itemid = 6
            elseif touchName == "Button_task7_get" then
                itid = BOX.boss_3
                itemid = 7
            elseif touchName == "Button_task8_get" then
                itid = BOX.boss_4
                itemid = 8
            end 
            local requrl = g_url.reward_gift.."&uid=".. g_userinfo.uid .."&uname=".. g_userinfo.uname .."&sid=".. g_userinfo.sid .."&itid="..itid
            local function myInfo(msg)
                if msg ~= nil and msg ~= "" then 
                    local cjson = require "cjson"
                    local temp_conf = cjson.decode(msg)
                    g_userinfo.physical = tonumber(temp_conf.member_info.member_physical)
                    g_userinfo.gold     = tonumber(temp_conf.member_info.member_gold)
                    g_userinfo.diamond  = tonumber(temp_conf.member_info.member_diamond)
                    meta.readyMeta.setUserData()
                    meta.listView_endlessTask:removeChild(meta["image_task"..tostring(itemid)])
                    meta.listView_endlessTask:requestRefreshView()
                    GameTaskModel.changeTaskData(itemid)
                end 
            end 
            Func_HttpRequest(requrl,"",myInfo)
        end 
    end 

    --添加监听
    meta.button_task1_go:addTouchEventListener(endlessTaskGoEvent)
    meta.button_task2_go:addTouchEventListener(endlessTaskGoEvent)
    meta.button_task3_go:addTouchEventListener(endlessTaskGoEvent)
    meta.button_task4_go:addTouchEventListener(endlessTaskGoEvent)
    meta.button_task5_go:addTouchEventListener(endlessTaskGoEvent)
    meta.button_task6_go:addTouchEventListener(endlessTaskGoEvent)
    meta.button_task7_go:addTouchEventListener(endlessTaskGoEvent)
    meta.button_task8_go:addTouchEventListener(endlessTaskGoEvent)

    meta.button_task1_get:addTouchEventListener(endlessTaskRewardEvent)
    meta.button_task2_get:addTouchEventListener(endlessTaskRewardEvent)
    meta.button_task3_get:addTouchEventListener(endlessTaskRewardEvent)
    meta.button_task4_get:addTouchEventListener(endlessTaskRewardEvent)
    meta.button_task5_get:addTouchEventListener(endlessTaskRewardEvent)
    meta.button_task6_get:addTouchEventListener(endlessTaskRewardEvent)
    meta.button_task7_get:addTouchEventListener(endlessTaskRewardEvent)
    meta.button_task8_get:addTouchEventListener(endlessTaskRewardEvent)
    button_back:addTouchEventListener(backEvent)
    meta.mainLayer:addChild(uiLayout)
end 

--删除 主图层 函数
function meta:remove()
    meta.readyMeta:setTaskFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

--初始化任务数据
--function meta.initTaskData()
--    local function myInfo(msg)
--        if msg ~= "" or msg ~= nil then 
--            local cjson = require "cjson"
--            local temp_conf = cjson.decode(msg)
--            print(msg.pass_chest)
--            print("宝箱信息:"..msg)
--            if temp_conf.pass_chest == 0 then
--                print("数字0") 
--            else
--                local arrayPass_gstatus = Split(temp_conf.pass_gstatus,";")
--                for i = 1 , #arrayPass_gstatus do  
--                    if arrayPass_gstatus[i] == "0" then
--                        meta["button_task"..i.."_get"]:setVisible(true)
--                        meta["button_task"..i.."_go"]:setVisible(false)
--                    elseif arrayPass_gstatus[i] == "1" then 
--                        meta.listView_endlessTask:removeChild(meta["image_task"..i])
--                    end  
--                end 
--                if temp_conf.pass_chest ~= 0 then 
--                    local arrayPass_bstatus = Split(temp_conf.pass_bstatus,";")
--                    for i = 1+4 , # arrayPass_bstatus + 4 do 
--                        if arrayPass_bstatus[i - 4] == "0" then
--                            meta["button_task"..i.."_get"]:setVisible(true)
--                            meta["button_task"..i.."_go"]:setVisible(false)
--                        elseif arrayPass_bstatus[i-4] == "1" then 
--                            meta.listView_endlessTask:removeChild(meta["image_task"..i])
--                        end 
--                    end 
--                end 
--                meta.listView_endlessTask:requestRefreshView()
--            end  
--        end 
--    end 
--    local requrl = g_url.get_gift .. "&uid=" .. g_userinfo.uid  .."&uname=".. g_userinfo.uname .. "&sid=" .. g_userinfo.sid
--    Func_HttpRequest(requrl,"",myInfo)
--end 

function meta.initTaskData()
    for i = 1 , #GameTaskModel.arrayPass_gstatus do  
        if GameTaskModel.arrayPass_gstatus[i] == "0" then
            meta["button_task"..i.."_get"]:setVisible(true)
            meta["button_task"..i.."_go"]:setVisible(false)
        elseif GameTaskModel.arrayPass_gstatus[i] == "1" then 
            meta.listView_endlessTask:removeChild(meta["image_task"..i])
        end  
    end 
    for i = 1+4 , # GameTaskModel.arrayPass_bstatus + 4 do 
        if GameTaskModel.arrayPass_bstatus[i - 4] == "0" then
            meta["button_task"..i.."_get"]:setVisible(true)
            meta["button_task"..i.."_go"]:setVisible(false)
        elseif GameTaskModel.arrayPass_bstatus[i-4] == "1" then 
            meta.listView_endlessTask:removeChild(meta["image_task"..i])
        end 
    end 
    meta.listView_endlessTask:requestRefreshView()
end


    

return GameTaskView
