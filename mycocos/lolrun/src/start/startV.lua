
local startView = 
{
    mainLayer = nil, --本图层
	selectedArea = 1,  --选择的服务区(默认为1)
    signinDay = --签到控件,第一天到第7天
    {
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil
    },
    ignore = nil,--粒子特效
    btn    = nil,
    kaishiSch = nil,
    maskTime = 0,
    isCreated = 0,
    isBoy     = 1
}--@ 游戏逻辑主图层
local  meta = startView


--引用和全局，初始化----------------------------------------------------------------------------------
--require "src/Hero/Hero" 
require "src/SpritePartner/SpritePartner"
local UILayoutButton = require "src/tool/UILayoutButton"
g_md5 = require "src/tool/md5"

local PriorityLayer = require "src/common/priorityLayer"
local GameWjOverView = require "src/gameover/GameWjOverV"
function meta:init( ... )
    meta.mainLayer =  CCLayer:create()
    --local overLayer = GameWjOverView:init(1,2,{},1)
    --meta.mainLayer:addChild(overLayer)
    ---[[
    playMusic("res/music/sound/bgmusic.ogg",true)
	meta:createLogin()
    --meta:testHero()
    meta:LoginParticle()
    meta:createUpdate()
    --统计
    statistics(1000)
    --]]

    --[[新手引导1
        local leader = require "src/leader/leader1/leader1"
        local leader_layer = leader:create()
        meta.mainLayer:addChild(leader_layer,100000)
    --]]
    --meta:TestPay()--支付宝支付测试
    --meta:testServer()
    --meta:testSprite()
    --meta:testEquipmeng()
    --meta:testConsumer()
    --meta:testHeroSkill()
    --meta:testExperience()
    --[[
    ccLabel = cc.LabelTTF:create("nil!","宋体",48)
	ccLabel:setColor(cc.c3b(255,0,0))
	ccLabel:setPosition(200,500)
	meta.mainLayer:addChild(ccLabel)
    --meta:WritePath()

    --meta:createPay()
    --meta:createLable()
    --]]
    --http://www.lolrun.com/api/get_section.php?act=sale_gift&macode=lfjdlfdja&uid=800000001&uname=i1603275411&gname=%E5%93%88%E5%93%88&sid=1&itme_id=1&count=2 
     
     
     --[[测试安卓震动
     local targetPlatform = cc.Application:getInstance():getTargetPlatform()
     if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local function vibrate()
            ccLabel:setString("vibrate1")
            local ok,ret = Func_callJavaFun("org/cocos2dx/lua/AppActivity","Vibrator",{500},"(J)V")
             ccLabel:setString("vibrate2")
             if not ok then
                --print("call callback error")
                ccLabel:setString("call vibrate error = " ..tostring(ret))
             else
                ccLabel:setString("call vibrate success ")
             end
        end

         local runItem1 = cc.MenuItemFont:create("vibrate")
         runItem1:registerScriptTapHandler(vibrate)
         local menu = cc.Menu:create(runItem1)
         menu:setPosition(g_visibleSize.width/2,g_visibleSize.height*5/6)
         meta.mainLayer:addChild(menu)
     end
    --]]

    --[[安卓返回键
    local key_listener = cc.EventListenerKeyboard:create()
     
    --返回键回调
    local function key_return()
        --结束游戏
        --cc.Director:getInstance():endToLua()
    end
    --监听
    key_listener:registerScriptHandler(key_return,cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = startScene.mainLayer:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(key_listener,startScene.mainLayer)
    --]]

    -----------------------------测试assetmanager
    --meta:createAssetsManager()
    --meta:createAssetsManager_jump_version()
    --meta:test()
    -----------------------------测试assetmanager

	--[[
    --c++绑定box2d
	local test = MTPhysicsWorld:sharedPhysicsWorld()
	if test == nil then
		cclog("fuck")
	end
	local testS = MTPhysicsWorld:getBindingSprite(startModel.sprite)
	if testS ~= nil then
		 meta.mainLayer:addChild(testS)
	end
	]]--

    --local  test = CPayManager:jniTest()
    --if test == 8888 then
        --cclog("is ok")
    --end
    --[[
    -- -- 监听触摸事件
     local listener = cc.EventListenerTouchOneByOne:create()
     listener:registerScriptHandler(meta.onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
     listener:registerScriptHandler(meta.onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
     listener:registerScriptHandler(meta.onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
     local eventDispatcher = meta.mainLayer:getEventDispatcher()
     eventDispatcher:addEventListenerWithSceneGraphPriority(listener, meta.mainLayer)
     --]]

      --[[ --test 17 模态层
    local priorityLayerTest = nil
    local function funcClose()
        priorityLayerTest:removeFromParent(true)
        priorityLayerTest = nil
    end
    local function func1()
        print("func1")
    end
    local function func2()
        print("func2")
    end
     local function func3()
        print("func3")
    end
   local priorityLayerFile = require "src/common/priorityLayer"
   priorityLayerTest = priorityLayerFile:init({bCreateDlg = true,isCloseButton = true ,func = funcClose,width = 900,height =500
                                           ,event = {onTouchBegan = func1,onTouchMoved = func2,onTouchEnded = func3 }     })
    meta.mainLayer:addChild(priorityLayerTest,8888)--]]

    

    return meta.mainLayer

end



--界面布局----------------------------------------------------------------------------------
 


 --登陆界面
function meta:createLogin()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/game_guide/game_guide0.plist","res/ui/game_guide/game_guide0.pvr.ccz")
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_login.ExportJson")
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromBinaryFile("res/ui/game_guide/game_login.csb")
	uiLayout:setPosition(g_origin.x,g_origin.y)
    
    --登陆页面
    local panel_login =  uiLayout:getChildByName("Panel_login")
    local panel_server         = panel_login:getChildByName("Panel_server")
    local button_signup        = panel_login:getChildByName("Button_signup")
    meta.panel_create          = uiLayout:getChildByName("Panel_create")
    meta.textField_name        = meta.panel_create:getChildByName("TextField_name")
    meta.button_confirm        = meta.panel_create:getChildByName("Button_confirm")
    meta.image_tips            = meta.panel_create:getChildByName("Image_tips")
    meta.label_tips            = meta.image_tips:getChildByName("Label_tips")
    meta.button_random         = meta.panel_create:getChildByName("Button_random")
    local button_reset         = meta.image_tips:getChildByName("Button_reset")
    --登录请求事件
    local function loginRequestEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then
            statistics(1001)
            if g_debug_btn then 
                print(touch:getName())
                meta.btn:setTouchEnabled(false)
                meta:kaishiyouxi()
            else 
                print(touch:getName())
                meta.btn:setTouchEnabled(false)
                meta:autoLogin()
            end
        end
    end 

    local function createGnameEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then
            local gname = meta.textField_name:getStringValue()
            touch:setTouchEnabled(false)
            if gname == "" then 
                meta.label_tips:setString("昵称不能为空，请重新输入。")
                meta.image_tips:setVisible(true)
            else
                --创号接口
                --meta:createPlayer(gname) 
                --改名字
                meta:changeName(gname)
            end 
        end
    end 

    --重置创号按钮
    local function resetEvent(touch,eventType)
        if eventType == ccui.TouchEventType.ended then
            meta.button_confirm:setTouchEnabled(true)
            meta.image_tips:setVisible(false)
        end
    end 

    local function setRandomNameEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then
            meta.setGname()
        end
    end 

    --开始按钮
    meta.button_random:addTouchEventListener(setRandomNameEvent)  
    meta.btn = panel_login:getChildByName("Button_start")
	meta.btn:addTouchEventListener(loginRequestEvent)
    meta.button_confirm:addTouchEventListener(createGnameEvent)
    button_reset:addTouchEventListener(resetEvent)
    meta.mainLayer:addChild(uiLayout)
end

--释放
function meta:release()
    --登陆动画
    --startModel.heroSprite:setVisible(false)
    --startModel.heroSprite:stopAllActions()
    --startModel.heroSprite:removeFromParent(true)
    --粒子
    --startModel.ignore:removeFromParent(true)
    --特效
    --startModel.panel_particle:removeFromParent(true)
    --登陆layout
    
    startModel.uiLayout:removeFromParent(true)
    --登陆动画
    --startModel.heroSprite = nil
    --粒子
    --startModel.ignore = nil
    --特效
    --startModel.panel_particle = nil
    --登陆layout
    startModel.uiLayout = nil

    meta.mainLayer:removeAllChildren(true)
    meta.mainLayer:removeFromParent(true)
end

--测试英雄技能
function meta:testHeroSkill()
    require "src/HeroSkill/HeroSkill"
    print("Heroskill  ------------------------------")
    local skill = HeroSkill:create(1)
    print(skill:getHeroSkillId())    
    print(skill:getSkName())
    print(skill:getSkRemark())
    print(skill:getSkTarget())
    print(skill:isInvincible())
    print(skill:isFly())
    print(skill:getPic())
    print(skill:getSkDamage())
    print(skill:getEffectTime())
    print(skill:getAttackAddition())
    print(skill:isHaveShield())
    print(skill:getLife())
    print(skill:getAttack())
    print(skill:getDefense())
    print(skill:getCD())
    print(skill:getGrowEffectTime())
    print(skill:getGrowAttackAddition())
    print(skill:getGrowShield())
    print(skill:getGrowLife())
    print(skill:getGrowAttack())
    print(skill:getGrowDefense())
    print(skill:getGrowCD())
end

function meta:testExperience()
    require "src/Experience/Experience"
    print("experience~~~~~~~~~~~~~~~~~~~~~~")
    local exp = Experience:create()
    for i = 1,#g_experience_conf do 
        print(exp:getExpFromLevel(i))
    end
end


function meta:testConsumer()
    print("testConsumer---------------------------------")
    require "src/Consumer/Consumer"
    local consumer = Consumer:create(1)
    print(consumer:getConsumerId())
    print(consumer:getAttack())
    print(consumer:getDefense())
    print(consumer:getLife())
    print(consumer:getValueOfGold())
    print(consumer:getValueOfDiamond())
    print(consumer:getCapacityOfItemInUnit())
    print(consumer:getMapOfEquitmentExist())
end

function meta:testEquipmeng()
    print("testEquipmeng---------------------------------")
    require "src/Equipment/Equipment"
    local equip = Equipment:create(10001)
    print(equip:getEquipmentId())                               --10001
    print(equip:getAttack())                                    --6
    print(equip:getDefense())                                   --nil
    print(equip:getLife())                                      --4
    print(equip:getGoldRequireToUpdate())                       --nil
    print(table.concat(equip:getItemRequireToUpdate(),";"))     --""
    print(equip:getCapacityOfItemInUnit())                      --默认1
    print(equip:getType())                                      --nil
    print(equip:getEffectTime())                                --nil
    print(equip:getQuality())                                   --nil   
    print(equip:getSkillId())                                   --nil
end

function meta:testSprite()
    cclog("testSprite---------------------------------")
    local sp = SpritePartner:create(1)
    print(sp:getName())
    print(sp:getLevel())
    print(sp:getRemark())
    print(sp:getSkcd())
    if sp:isAddGold() then
        print("add gold")
    end
    if sp:isAddExp() then
        print("add exp")
    end
    if sp:isAddLife() then
        print("add life")
    end
    if sp:isAddDefense() then
        print("add isAddDefense")
    end
    if sp:isAddAttack() then
        print("add isAddAttack")
    end
    if sp:isAddrebirth() then
        print("add isAddrebirth")
    end
    if sp:isPunching() then
        print("add isPunching")
    end
end

--测试读写路径
function meta:WritePath()
    local path = nil
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        path = "/sdcard/mydata.txt"
        --path = cc.FileUtils:getInstance():getWritablePath() .."/mydata.txt"
    else
        path = cc.FileUtils:getInstance():getWritablePath() .."/mydata.txt"
        
    end
    ccLabel:setString(tostring(path))
    
    local tab = {["a"] = 101 }
    
    --写入
    local function testWrite()
        --local is_wirte = cc.FileUtils:getInstance():writeToFile(tab,path)
        --ccLabel:setString(tostring(is_wirte))
        setData("he",12)
        ccLabel:setString(tostring(12))
    end
    

     --读取
    local function testRead(touch,eventType)
        --local targetPlatform = cc.Application:getInstance():getTargetPlatform()
                
        --local dataMap = cc.FileUtils:getInstance():getValueMapFromFile(path)
        --for key,val in pairs(dataMap) do
    	   -- ccLabel:setString(val)
        --end
        local ee = getData("he")
        ccLabel:setString(tostring(ee))
    end

    --修改数据
    local function testChange()
        --local is_wirte = cc.FileUtils:getInstance():writeToFile(tab,path)
        --ccLabel:setString(tostring(is_wirte))
        setData("he",13)
        ccLabel:setString(tostring(13))
    end

    local function testAppend()
        setData("she",80)
        ccLabel:setString("追加数据she=80")
    end 

    local function testRead2()
        local ee = getData("she")
        ccLabel:setString(tostring(ee))
    end 

     local item_1 = cc.MenuItemFont:create("writeData12")
     item_1:registerScriptTapHandler(testWrite)
     item_1:setPosition(cc.p(0,0))

     local item_2 = cc.MenuItemFont:create("getData")
     item_2:registerScriptTapHandler(testRead)
     item_2:setPosition(cc.p(0,50))

     local item_3 = cc.MenuItemFont:create("修改数据13")
     item_3:setPosition(cc.p(0,100))
     item_3:registerScriptTapHandler(testChange)

     local item_4 = cc.MenuItemFont:create("追加数据")
     item_4:setPosition(cc.p(0,150))
     item_4:registerScriptTapHandler(testAppend)

     local item_5 = cc.MenuItemFont:create("读取追加数据")
     item_5:registerScriptTapHandler(testRead2)
     item_5:setPosition(cc.p(0,200))

     local menu = cc.Menu:create(item_1,item_2,item_3,item_4,item_5)
     menu:setPosition(cc.p(g_visibleSize.width/4, g_visibleSize.height/3))
     meta.mainLayer:addChild(menu)

end


--测试文字
function createLable(a,b)
    --cclog("a = " ..a)
    --print( "b = " ..b)

	ccLabel:setString("Success")
    return 351
end

--支付测试
function meta:createPay()
      local function PayEventListener(touch,eventType)
          --cclog("PayEventListener")
          if eventType == cc.CONTROL_EVENTTYPE_TOUCH_DOWN then
            --ccLabel:setString("CONTROL_EVENTTYPE_TOUCH_DOWN")
            ---[[
            local targetPlatform = cc.Application:getInstance():getTargetPlatform()
            if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
                --ccLabel:setString("PLATFORM_OS_ANDROID")
				local function callback(strhtml)
					if strhtml == "" then
						ccLabel:setString("111111")
					elseif strhtml == nil then
						ccLabel:setString("222222")
					else
						ccLabel:setString(strhtml)
					end
					
				end
				Func_login(callback)
				--[[
                local goods="钻石"
                local total=0.01
                local member="michael"
                local function GetOrderResult(order)
                    if order ~= "" then
                        --请求成功做处理
                        ccLabel:setString(order)


                        local function PayResult(param)
                            if "success" == param then
                                --print("java call back success")
                                --请求成功做处理
                                ccLabel:setString("java call back success")
                            else
                                --请求失败做处理
                                ccLabel:setString("other")
                            end
                        end
                        local ok,ret = Func_callJavaFun("org/cocos2dx/lua/AppActivity","Pay",{goods,total,tostring(order),PayResult},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
                        if not ok then
                            --print("call callback error")
                            ccLabel:setString("call callback error = " ..tostring(ret))
                        end

                    else
                        --请求失败做处理
                        ccLabel:setString("other")
                    end
                end
                local requrl="http://www.v5wan.com/api/lolrungetorder.php?act=getorder"
                requrl=requrl.."&member="..member
                requrl=requrl.."&total="..tostring(total)
                Func_HttpRequest(requrl,"",GetOrderResult)
                --]]
                --[[
                local luaj = require "luaj"
                local className = "org/cocos2dx/lua/AppActivity"
                
                --lua调用java
                local args = {"德玛","100","http"}
                local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"--括号里是参数  后面跟返回值  比如两个整形一个空返回:(II)V ，空参数返回字符串()Ljava/lang/String;
                local ok,ret  = luaj.callStaticMethod(className,"callbackLua",args,sigs)
                if not ok then
                    --print("luaj error:", ret)
                    ccLabel:setString("error =" ..tostring(ret))
                else
                    ccLabel:setString("success")
                end
                
                --java调lua
                --ccLabel:setString("PLATFORM_OS_ANDROID")
                local function callbackLua(param)
                    if "success" == param then
                        --print("java call back success")
                        ccLabel:setString("java call back success")
                    else
                        ccLabel:setString("other")
                    end
                end
                
                args = {"德玛","2","http",callbackLua}
                sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
                ok,ret = luaj.callStaticMethod(className,"callbackLua",args,sigs)
                if not ok then
                    --print("call callback error")
                    ccLabel:setString("call callback error = " ..tostring(ret))
                end
                --]]
            end
            --]]

            --[[c++
             CPayManager:CInterface()
             
             local test = CPayManager:jniTest()
                if test == 8888 then
                    cclog("is 8888")
                elseif test == -1 then
                    cclog("is -1")
                end
                --]]
          end
      end
     cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/gameIn/gamein.plist", "res/ui/gameIn/gamein.png")--战斗界面
     local arr = {
     label_type = LABEL_TYPE_ENUM.ttf,
     button_type = BUTTON_TYPE_ENUM.high,
     label = "",
     font = "",--字体 或 填字体库fnt
     font_size = 24,--fnt模式下 此参数用不上
     button1 = "button_05.png",
     button2 = "button_06.png",
     x = g_origin.x  + 74,
     y = g_origin.y  + 74
     }
     local btn = UILayoutButton:createUIButton(arr)
     btn:registerControlEventHandler(PayEventListener,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)--按下按钮

     meta.mainLayer:addChild(btn)

end

--粒子
function meta:LoginParticle()
    meta.ignore = cc.ParticleSystemQuad:create("res/ui/start/fire_1.plist")
    meta.ignore:setScaleX(5)
    meta.ignore:setScaleY(5)
    meta.ignore:setOpacity(200)
    meta.ignore:setPosition(g_visibleSize.width/2+45,g_visibleSize.height/2+50)
    meta.mainLayer:addChild(meta.ignore)
end


--界面逻辑回调与相关控制----------------------------------------------------------------------------------
--[[
 local function meta.onTouchBegan(touch, event)
     return true
 end
 
 local function meta.onTouchMoved(touch, event)    
    local x,y =g_label:getPosition()
    local diff = touch:getLocation()
    g_label:setPosition(cc.p(diff.x,diff.y))
 end

 local function meta.onTouchEnded(touch, event)    

 end
 --]]


function meta:createAssetsManager()
    --------------------------------------
    --test  AssetsManager   begin
    --------------------------------------
    local function onError(errorCode)
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            cclog("no new version")
            g_label:setString("no new version")
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            cclog("network error")
            g_label:setString("network error")
        elseif errorCode == cc.ASSETSMANAGER_CREATE_FILE then
            cclog("create file")
            g_label:setString("create file")
        elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
           cclog("uncompress")
           g_label:setString("uncompress")
        end
    end

    local function onProgress(percent)
        if percent == nil then 
            cclog("percent == nil")
            return
        end
        local str = string.format("%d%%",percent)
        g_label:setString(str)
        cclog("progress ...........................................%d",percent)

    end

    local function onSuccess()
        cclog("downloading ok")
        g_label:setString("downloading ok")
        local cat = cc.Sprite:create("res/cat.png")
        if cat then
            g_label2:setString("set cat")
            cat:setPosition(cc.p(100,100))
            meta.mainLayer:addChild(cat,1000061,1000061)
        else
            g_label2:setString("nocat")
        end

        local cat1 = cc.Sprite:create("res/cat1.png")
        if cat1 then
            local str = g_label2:getString()
            local str = str.."set cat1"
            g_label2:setString(str)
            cat1:setPosition(cc.p(600,100))
            meta.mainLayer:addChild(cat1,1000071,1000071)
        else
            g_label2:setString("nocat")
        end

    end

    local function menuCallBack(tag)
        cc.UserDefault:getInstance():setStringForKey("current-version-codezd","1.0")
        cc.UserDefault:getInstance():setStringForKey("downloaded-version-codezd","1.0")
        cc.UserDefault:getInstance():flush()
        local path = cc.FileUtils:getInstance():getWritablePath()
        cclog("%s",path)
        --local pathToSave = "D:/Documents2/CocoStudio/Source/3.0/cocos2d-x/tests/lua-empty-test/src/test_AssetsManager"
        local pathToSave = string.format("%s",path)
        g_label2:setString(pathToSave)
        local PackageUrl = 
                        "http://www.haohuiwan.com/uploadfiles/test1_res.zip"
                        --"http://www.haohuiwan.com/uploadfiles/test1_res.rar" 
                        --"http://www.haohuiwan.com/uploadfiles/cocos2dx-update-temp-package.zip"
                        --"https://raw.github.com/samuele3hu/AssetsManagerTest/master/package.zip"
        local versionFileUrl = --"https://raw.github.com/samuele3hu/AssetsManagerTest/master/version"
                                "http://www.v5fz.com/api/lolrun.php?act=getversion"
        local assetsManager = cc.AssetsManager:new(PackageUrl,
                                                   versionFileUrl,
                                                   pathToSave)

        assetsManager:retain()              --貌似没有这句话会蹦
        assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
        assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
        assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
        assetsManager:setConnectionTimeout(10)
        assetsManager:update()
    end
   cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GuideMap/MapGuide.plist","res/GuideMap/MapGuide.png")    --地图引导
    local nor    = cc.Scale9Sprite:createWithSpriteFrameName("ditu_fanhui_01_1.png")
    local select = cc.Scale9Sprite:createWithSpriteFrameName("ditu_fanhui_01_2.png")
    local dis    = cc.Scale9Sprite:createWithSpriteFrameName("ditu_fanhui_01_2.png")
    local button = cc.MenuItemSprite:create(nor,select,dis)
    button:setPosition(cc.p(0,-40))







    --菜单
    local menu = cc.Menu:create(button)
    menu:setPosition(cc.p(200,400))
    meta.mainLayer:addChild(menu,100000,1000000)
    button:registerScriptTapHandler(menuCallBack)
    --带颜色layer
    local cLayer = cc.LayerColor:create(cc.c4b(0,255,0,255))
    cLayer:setPosition(cc.p(0,g_visibleSize.height/3))
    cLayer:setContentSize(cc.size(1000,300))
    --全局
    g_label = cc.LabelTTF:create(">>>>>>>>> new2  <<<<<<<<<","宋体",24)
    g_label:setColor(ccc3(255,0,0))
    cLayer:addChild(g_label,10000,10000)
    g_label:setPosition(cc.p(300,200))
    g_label:setString(sys)

    g_label2 = cc.LabelTTF:create(">>>>>>>>>   <<<<<<<<<","宋体",24)
    g_label2:setColor(ccc3(255,0,0))
    g_label2:setPosition(cc.p(300,100))
    cLayer:addChild(g_label2,100002,100020)

    --g_label2:setString("")
    --可写路径
    --[[
    local path = cc.FileUtils:getInstance():getWritablePath()
    cclog("%s",path)
    --local pathToSave = "D:/Documents2/CocoStudio/Source/3.0/cocos2d-x/tests/lua-empty-test/src/test_AssetsManager"
    local pathToSave = string.format("%s",path)
    g_label2:setString(pathToSave)
    --]]

    meta.mainLayer:addChild(cLayer,10000,10000)
    ---[[
    --cat1
    local cat = cc.Sprite:create("res/cat.png")

    cat:setPosition(cc.p(600,300))
    meta.mainLayer:addChild(cat,1000011,1000011)

    --cat2
    local cat2 = cc.Sprite:create("res/cat.png")
    if cat2 then
        g_label2:setString("set cat")
        cat2:setPosition(cc.p(100,100))
        meta.mainLayer:addChild(cat2,1000041,1000041)
    else
        g_label2:setString("nocat")
    end
    --cat3
    local cat1 = cc.Sprite:create("res/cat1.png")
    if cat1 then
        local str = g_label2:getString()
        local str = str.."set cat1"
        g_label2:setString(str)
        cat1:setPosition(cc.p(600,100))
        meta.mainLayer:addChild(cat1,1000051,1000051)
    else
        g_label2:setString("nocat")
    end
    --]]

    ---[[
        cc.UserDefault:getInstance():setStringForKey("string", "value1")
        cc.UserDefault:getInstance():flush()

        local pathxml = cc.UserDefault:getXMLFilePath()
        g_label:setString(pathxml)
    
    --]]

    --[[测试系统命令与 getstringfromfile
        local path1 = cc.FileUtils:getInstance():getWritablePath()
        local cmd 
        if cc.FileUtils:getInstance():isFileExist(path1.."test") then
            cmd  =  "mkdir ".. path1.. "test"
            os.execute(cmd)
        end
        cmd = "echo \"hahahaha\" >> "..path1.."test/b.log"
        g_label:setPosition(cc.p(600,200))
        g_label:setString(cmd)
        local str = cc.FileUtils:getInstance():getStringFromFile(path1.."test/b.log")
        if str == "" then 
            g_label2:setString("no  str")
        else
            g_label2:setString(str)
        end
    --]]


    --[[
    if cc.FileUtils:getInstance():isFileExist("UserDefault.xml") then
        g_label2:setString("UserDefault is in the path")
    else
        g_label2:setString("not ~exit")
    end
    --]]

    --------------------------------------
    --test  AssetsManager    end
    --------------------------------------
end

function meta:createUpdate()
    local updateS = require "src/GameUpdate/GameUpdateS"
    updateS:init(meta.mainLayer)

end

function meta:registerMove(tar)
    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local posX,posY = target:getPosition()
        local delta = touch:getDelta()
        target:setPosition(cc.p(posX + delta.x, posY + delta.y))
        cclog("%d    %d",posX + delta.x,posY + delta.y)
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    --listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )

    local eventDispatcher = tar:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, tar)

end

--[[没有用的
function meta:maskbutton()
    if meta.maskTime >= 3 then 
        meta.maskTime = 1
        meta.btn:setTouchEnabled(true)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(meta.kaishiSch)
    else 
        meta.maskTime = meta.maskTime + 1
    end 
    print(meta.maskTime)
end 
--]]

function meta:kaishiyouxi()
    
    local gameUpdate = require "src/GameUpdate/GameUpdateS"
    gameUpdate:loadUiRes() 
end 




--查看有没有创号
function meta:selectServer(num)
    g_userinfo.sid = num
    local function mySelect(msg)
        if msg == "0" then 
           meta.isCreated = false 
           meta:createPlayer2()
            --选服失败
            --[[新手引导1
            local leader = require "src/leader/leader1/leader1"
            local leader_layer = leader:create()
            meta.mainLayer:addChild(leader_layer,100000)
            --数据赋值与选择模式
            local RoleModel = require "src/Role/RoleM"
            RoleModel:SetFightRole(meta:getHero())
            --]]
           --print(msg)
           --meta.setGname()
           --meta.panel_create:setVisible(true)
        elseif msg ~= "" and msg ~= nil then 
            cclog("成功选服")
            local cjson = require "cjson"
			local temp_conf = cjson.decode(msg) 
            cclog("初始化会员数据")
            g_userinfo.physical = temp_conf.member_physical
            g_userinfo.diamond = temp_conf.member_diamond
            g_userinfo.gold = temp_conf.member_gold
            g_userinfo.gname = temp_conf.member_gname
            g_userinfo.gid = temp_conf.member_gid
            g_userinfo.lastlogin = temp_conf.member_lastlogin
            g_userinfo.heros = {}
            for i=1,#temp_conf.heros do
                g_userinfo.heros[i] = {}
                g_userinfo.heros[i].level = temp_conf.heros[i].hero_level
                g_userinfo.heros[i].id = temp_conf.heros[i].hero_hrid
            end
         
            g_userinfo.leader = tonumber(temp_conf.step)
            g_userinfo.ranks = temp_conf.ranks
            g_userinfo.email = temp_conf.email
            g_userinfo.chest = temp_conf.chest
            
            --赋值排行榜
            local GameGuideModel = require "src/GameGuide/GameGuideM"
            GameGuideModel.initRanks(g_userinfo.ranks)
            local GameEmailModel = require "src/GameEmail/GameEmailM"
            GameEmailModel:saveMailData(g_userinfo.email)
            local GameTaskModel     =   require "src/GameTask/GameTaskM"
            GameTaskModel.initTaskData(g_userinfo.chest)

            meta:kaishiyouxi()
            cclog("预加载资源")
           
        else
            meta.btn:setTouchEnabled(true)
		end
    end 
	--local requrl = g_url.is_role.."&macode=".. g_userinfo.mac .."&uid=".. g_userinfo.uid .."&uname=".. g_userinfo.uname .."&sid=".. num
    local requrl = g_url.get_server .."?uid=" ..g_userinfo.uid .."&uname=" ..g_userinfo.uname .."&sid="..num
    cclog("选服："..requrl)
    Func_HttpRequest(requrl,"",mySelect)
end 

--注册
function meta:signup()
	local function mySignup(msg)
            cclog("注册返回")
			local cjson = require "cjson"
			local temp_conf = cjson.decode(msg)
			if tostring(temp_conf.code) == "100" then
                g_userinfo.uname = temp_conf.uname
                g_userinfo.upwd = temp_conf.pwd
                g_userinfo.uid = temp_conf.uid
			    --g_tips_setString("注册成功,返回登录",2)
			   --注册成功就登录
               print("注册成功")
			    meta:autoLogin()
			end
	end 

    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then   --安卓通讯
        g_userinfo.mac = Func_MacId()
        --setData(CONFIG_USER_DEFAULT.UserMac,Func_MacId())
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯
    else 
        require("src/local.lua")
    end
    local model = Func_GetModel()
    local apkname = Func_GetChannel()

	local requrl = g_url.register.."?macode="..g_userinfo.mac.."&advtype=" .. g_userinfo.advtype  .. "&subtype=" .. g_userinfo.subtype .. "&g_apkname=" .. apkname .. "&model=" .. model
    Func_HttpRequest(requrl,"",mySignup)
end

--自动登录,注册,选服,创号
function meta:autoLogin()
    if g_userinfo.uname == ""  then 
        cclog("你没有注册")
		meta:signup()
    else 
        --print("你已经注册")
		--g_tips_setString("你已注册账号,进去选服")
        local function mylogin(msg)
            if msg == nil then 
                --g_tips_setString("msg = nil",3)
            elseif msg == "" then 
                --g_tips_setString("msg = kong",3)
            else  
                cclog(msg)
                meta:selectServer(1)
            end     
        end 
		local requrl = g_url.login.."?macode=".. g_userinfo.mac  .."&uname=".. g_userinfo.uname .."&psw=".. g_userinfo.upwd
        --setData("dneglu",requrl)
        Func_HttpRequest(requrl,"",mylogin)
    end
end

function meta:init2()
    meta.mainLayer =  CCLayer:create()
    playMusic("res/music/sound/bgmusic.ogg",true)
    meta:createLogin()
    meta:setGname()
    meta.panel_create:setVisible(true)
    return meta.mainLayer
end 



--获得名字
function meta:setGname()
    local function  getrole(msg)
        cclog(msg)
        local cjson = require "cjson"
        local temp_conf = cjson.decode(msg)
        if temp_conf.code == 1 then 
            cclog(temp_conf.gname)
            meta.textField_name:setText(temp_conf.gname)
            meta.isBoy = meta.isBoy + 1
        end 
        
    end 
    local requrl = g_url.get_role .."?uid=" ..g_userinfo.uid .."&uname=" ..g_userinfo.uname .."&sid=".. g_userinfo.sid .. "&str=" .. meta.isBoy
    cclog(requrl)
    Func_HttpRequest(requrl,"",getrole)
end 



--改名字
function meta:changeName(gname)
    local function  changerole(msg)
        local cjson3 = require "cjson"
        local temp_conf = cjson3.decode(msg)
        if tonumber(temp_conf.code) == 1 then 
            cclog("改名字成功")
            --meta.panel_create:setVisible(false)
            --meta.kaishiyouxi()
            local changeScene = require "src/GameGuide/GameGuideScene"
            SimpleAudioEngine:getInstance():playMusic("res/music/sound/bgmusic.ogg",true)
            if cc.Director:getInstance():getRunningScene() then
		        cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,changeScene:init()))
	        else
                cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,changeScene:init()))
	        end

        elseif tonumber(temp_conf.code) == 0 then 
            androidAlert("已有相同的昵称，请重新输入")
            cclog("有相同的名字")
            meta.button_confirm:setTouchEnabled(true)
        else 
            cclog("改名失败")
        end
    end 
    local name = Func_UrlEncode(gname)
    local requrl = g_url.change_gname .."&uid=" ..g_userinfo.uid .."&uname=" ..g_userinfo.uname .."&sid=".. g_userinfo.sid .."&gname=" .. name
    
    Func_HttpRequest(requrl,"",changerole,false)
end 


function meta:createPlayer2()
	local function myPlayer(msg)
            cclog("创号返回："..msg)
            local cjson = require "cjson"
            local temp_conf = cjson.decode(msg)
            if temp_conf.code == 0 then 
                cclog("账号入库失败")
            elseif temp_conf.code == 1 then
                cclog("同名")
                meta.label_tips:setString("已有相同昵称，请重新输入。")
                meta.image_tips:setVisible(true)
            elseif temp_conf.code == 2 then 
                cclog("创号成功,登陆1服")
                
                meta:selectServer(1)

           
            end 
	end 
	local requrl = g_url.add_role .. "&uid=" .. g_userinfo.uid .. "&uname=" .. g_userinfo.uname .. "&gname=" .. "&sid=" .. g_userinfo.sid
    cclog("创号："..requrl)
    Func_HttpRequest(requrl,"",myPlayer)
end

return startView