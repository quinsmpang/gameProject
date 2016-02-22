require "src/tool/enum"
require "src/Hero/Hero"
--cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/game_ready/paihangbang_test2.plist","res/ui/game_ready/paihangbang_test2.png")

local GameGuideView=
{
    mainLayer      = nil,   --本图层
    starSch        = nil,   --流星定时器
    strengthSch    = nil,   --体力恢复定时器
    refreshTime    = 600 ,  --体力恢复时间 300秒
    strCheckSch    = nil ,  --体力检测器
    countDownTime  = 60 ,
    panel_ready    = nil,   --加在mainLayer的层
    isOpened =              --是否开启界面，安卓返回键使用.
    {
        strengthen = false , 
        setting    = false , 
        email      = false , 
        task       = false , 
        bag        = false ,
        --gift       = false , 
        mystery    = false ,
        mode       = false ,
        role       = false , 
        --section    = false ,
        activity   = false ,
        diamond    = false ,
        gold       = false ,
        strength   = false ,
        map        = false ,
        kind       = false , 
    },
    labelAtlas_userExp       = nil,      --用户经验半分比
    labelAtlas_userLevel     = nil,      --用户等级 
    labelAtlas_readyGold     = nil,      --金钱
    labelAtlas_readyDiamond  = nil,      --钻石
    labelAtlas_readyStrength = nil,      --体力 
    curHero = nil,                     
    curHeroIdx = 1,                    --现在选择的英雄idx ，这个是选择
    myHero     = {},                   --用户的英雄
    user_hero_tb  = {} ,               --选择英雄表
    user_hero_tbid = {},               --选择英雄表对应的英雄ID
    isFirst    = true,                  --是
    button_rank                = {},
    label_rankGname            = {},
    bitmapLabel_rankPoint      = {},
    image_rankStar             = {},
    image_rankHero             = {},
    playerArmature             = nil,
    image_newEmailNum          = nil,   --新邮件数量背景图
    atlasLabel_newEmailNum     = nil,   --新邮件数量数字标签
}--@ 游戏逻辑主图层
local meta = GameGuideView

local this = nil    --用于流星加到panel_ready

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
--require "src/tool/base64"
--require "src/tool/Sha1"
--require "src/tool/BitLibEmu"
local GameGuideModel     =   require "src/GameGuide/GameGuideM"
local LabelPicture       =   require "src/tool/LabelPicture"
local GameSettingView    =   require "src/GameSetting/GameSettingV"      --设置界面
local GameEmailView      =   require "src/GameEmail/GameEmailV"          --邮件界面
local GameTaskView       =   require "src/GameTask/GameTaskV"            --任务界面 
local GameBagView        =   require "src/GameBag/GameBagV"              --背包界面
--local GameGiftView       =   require "src/GameGift/GameGiftV"            --奖励界面
local GameMysteryView    =   require "src/GameMystery/GameMysteryV"      --商城界面
local GameModeView       =   require "src/GameMode/GameModeV"            --战役界面
local GameRoleView       =   require "src/GameRole/GameRoleV"            --角色选择界面
--local GameSectionView    =   require "src/GameSection/GameSectionV"      --章节界面
local GameActivityView   =   require "src/GameActivity/GameActivityV"    --活动界面
local GameDiamondView    =   require "src/GameDiamond/GameDiamondV"      --钻石界面
local GameGoldView       =   require "src/GameGold/GameGoldV"            --金币界面
local GameStrengthView   =   require "src/GameStrength/GameStrengthV"    --体力界面
local RoleModel          =   require "src/Role/RoleM"                    --战斗场景英雄
local GameMapView        =   require "src/GameMap/GameMapV"              --地图界面
local GameKindView       =   require "src/GameKind/GameKindV"            --模式界面
local GameRoleModel      =   require "src/GameRole/GameRoleM"         
local GameEmailModel     =   require "src/GameEmail/GameEmailM"          --邮件MODEL

function meta:init(leadOpen)
    --第一次进如游戏不会调用
    cclog("跑完出来后金币:"..g_userinfo.gold)
    cclog("跑完出来后钻石:"..g_userinfo.diamond)
    --GameGuideModel:resetUserData()
    meta.mainLayer = cc.Layer:create()
    meta.initHeroData()   
    meta:createGuide()    
    meta:setUserData()    
    meta:setRankData()
    meta:setEmailNum(GameEmailModel:getNotReadMail_Number())
    --我要变强
    if  leadOpen ~= nil then 
        meta.readyToUpgradeEvent()
    else  
    end 
    --体力恢复定时器
    meta.openCountDownTime()
    print("现在的引导是-------------------------------"..g_userinfo.leader)
    --新手引导
    meta:gotoLeader(leadOpen)
    
    --统计
    statistics(1100)

    --[[查看内外网
    local online_text = nil
    if g_is_online then
        online_text = cc.LabelTTF:create("外网","宋体",50)
    else
        online_text = cc.LabelTTF:create("内网","宋体",50)
    end
    online_text:setPosition(60,580)
    meta.mainLayer:addChild(online_text,999)
    --]]






    return meta.mainLayer
end 

--创建英雄数据
function meta.initHeroData()
    if not g_debug_btn then 
        for i =1 ,#g_userinfo.heros do 
            meta.myHero[i] = Hero:create(g_userinfo.heros[i].id,g_userinfo.heros[i].level,"0")
            cclog(meta.myHero[i]:getName())
        end 
    end
    meta.user_hero_tb = {1,2,3,4,5,6}
    meta.user_hero_tbid = {100003,100017,100038,100024,100010,100045}
    for i = 1,#meta.myHero do 
        if meta.myHero[i]:getId() == tostring(meta.user_hero_tbid[meta.curHeroIdx]) then 
            GameGuideModel.curMyHero = meta.myHero[i]
            break 
        end 
    end
end 

--设置用户数据函数-----------------------------------------------------------------------------------------
function meta:setUserData()
    if meta.isOpened.role  then 
        meta.setHeroDiamond()
        meta.setHeroGold()
    end 
    if meta.isOpened.activity then 
        meta.setAct4Diamond()
        meta.setAct4Gold()
    end
    meta.labelAtlas_readyStrength:setString(g_userinfo.physical)
    meta.labelAtlas_readyGold:setString(g_userinfo.gold)
    meta.labelAtlas_readyDiamond:setString(g_userinfo.diamond)
end 



--界面布局--------------------------------------------------------------------------------------------------



------------------------------英雄动画跑步动作------------------------------
function meta:createHeroPlatform()
    --local layer = cc.LayerColor:create(cc.c4b(0,255,0,255)) --到使用的使用换回 cc.Layer:create()就可以了
    local layer = cc.Layer:create()
    layer:setPosition(cc.p(500,200))
    layer:setAnchorPoint(cc.p(0,0))
    local wid = 90
    local hig = 150*2.5
    layer:setContentSize(cc.size(wid,hig))

    local RoleModel = require "src/Role/RoleM"
    if RoleModel.role_tag == ROLE_HERO_ENUM.tm then
        self.curHeroIdx = 1 --保存第几只英雄
    elseif RoleModel.role_tag ==  ROLE_HERO_ENUM.ez then
        self.curHeroIdx = 3 --保存第几只英雄
    elseif RoleModel.role_tag == ROLE_HERO_ENUM.zx then
        self.curHeroIdx = 2 --保存第几只英雄
    elseif RoleModel.role_tag ==  ROLE_HERO_ENUM.ah then
        self.curHeroIdx = 4 --保存第几只英雄
    elseif RoleModel.role_tag ==  ROLE_HERO_ENUM.dm then
        self.curHeroIdx = 5 --保存第几只英雄
    elseif RoleModel.role_tag ==  ROLE_HERO_ENUM.js then
        self.curHeroIdx = 6 --保存第几只英雄
    else
        self.curHeroIdx = 1
    end

    
    
    self.curHero = ccs.Armature:create(GameGuideModel.heroName[self.curHeroIdx])
    self.curHero:setScale(1.5)
    self.curHero:getAnimation():play("run")
    self.curPlayName = "run"
    self.curHero:setPosition(cc.p(wid-20,hig/3))
    layer:addChild(self.curHero)

    return layer
end

---------------------------------流星效果---------------------------------------------------------
function meta.createFlowStar(a)
    cclog("流星定时器")
    local starNum = starNum or 10       --每秒钟星星的数量
    local time = time or 1              --流星隐身的时间
    local kuan = 2                      --尾巴粗细
    local tail_len = 100                --尾巴长度
    local move_time   = 0.5             --移动时间
    local minX = 650                    --流星出现位置的最小X
    local maxX = 960                    --流星出现位置的最大X
    local minY = 500                    --流星出现位置的最小Y
    local maxY = 600                    --流星出现位置的最大Y
    local tail = "move_star_xx.png"
    local tail_sprite = cc.Sprite:createWithSpriteFrameName(tail)
    local rand = require "src/tool/rand"
    local function create1Star()
        local streak = cc.MotionStreak:create(time, 1/60, kuan, cc.c3b(255,255, 255), tail_sprite:getTexture())
        local function release()
            streak:removeFromParent()
        end
        streak:setPosition(rand:randnum(minX,maxX),rand:randnum(minY,maxY))
        streak:setVisible(true)
        meta.panel_ready:addChild(streak,15)
        local action2 = cc.MoveBy:create(move_time,cc.p(-tail_len+rand:randnum(0,10),-tail_len+rand:randnum(0,10)))
        streak:runAction(cc.Sequence:create(action2,cc.DelayTime:create(1),cc.CallFunc:create(release)))
    end
    create1Star()
end


function meta:createGuide()
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_ready.ExportJson")
	--local uiLayout = ccs.GUIReader:getInstance():widgetFromBinaryFile("res/ui/game_guide/game_ready.csb")
    meta.panel_ready    = uiLayout:getChildByName("Panel_ready")
    meta.panel_player   = uiLayout:getChildByName("Panel_player")
    meta.panel_kaichang = uiLayout:getChildByName("Panel_kaichang")
    meta.panel_readyYes = uiLayout:getChildByName("Panel_readyYes")

    --开场活动
    if #meta.myHero <= 3 then 
        meta.panel_kaichang:setVisible(true)
    else
        local buyNum = 0
        for i = 1 ,#meta.myHero do 
            local buyid = tonumber(meta.myHero[i]:getId())
            if buyid == 100017 or buyid == 100038 or buyid == 100010 then 
                buyNum = buyNum + 1
            end 
        end 
        if buyNum == 3 then 
            meta.panel_kaichang:setVisible(false)
        end 
    end 
    ---[[添加发光效果
    meta.faguang = ccs.Armature:create("kaifuguang")
    meta.faguang:getAnimation():play("run")
    meta.faguang:setPosition(cc.p(859,597))
    meta.panel_ready:addChild(meta.faguang,1,1)
    --]]

    

--[[添加英雄pageView层
    --pageview
    -----------------------------------------------------------------------------
    --self.panel_ready = panel_ready
    this = self
    self.pageView         =  self:createPageView()
    self.pageView:setPosition(cc.p(720,450))
    meta.panel_ready:addChild(self.pageView,16)
    --]]

    
    

    ---[[添加英雄动作层
    --local heroPlayIdx = 0
    self.heroPlatform = self:createHeroPlatform()
    self.heroPlatform:setPosition(cc.p(690,200))
    --self.mainLayer:addChild(self.heroPlatform,10001)
    meta.panel_ready:addChild(self.heroPlatform,15)
    --]]
    
    --开场活动按钮
    local button_33                 =    meta.panel_kaichang:getChildByName("Button_33")
    local button_yes                =    meta.panel_readyYes:getChildByName("Button_yes")
    local button_no                 =    meta.panel_readyYes:getChildByName("Button_no")

    local button_liqu               =    meta.panel_kaichang:getChildByName("Button_liqu")

    local panel_readyTouch          =    meta.panel_ready:getChildByName("Panel_readyTouch")       
    local button_readySetting       =    meta.panel_ready:getChildByName("Button_readySetting")    --设置按钮
    local button_readyTask          =    meta.panel_ready:getChildByName("Button_readyTask")       --任务按钮
    local button_readyEmail         =    meta.panel_ready:getChildByName("Button_readyEmail")      --邮件按钮
    local button_readyBag           =    meta.panel_ready:getChildByName("Button_readyBag")        --背包按钮
    local button_readyShop          =    meta.panel_ready:getChildByName("Button_readyShop")       --商店按钮
    local button_readyMode          =    meta.panel_ready:getChildByName("Button_readyMode")       --模式按钮
    meta.button_readySelectHero     =    meta.panel_ready:getChildByName("Button_readySeleceHero") --英雄按钮
    meta.button_readyStart          =    meta.panel_ready:getChildByName("Button_readyStart")      --开始按钮
    meta.button_readyActivity       =    meta.panel_ready:getChildByName("Button_readyActivity")   --开服活动按钮
    local button_readyGold          =    meta.panel_ready:getChildByName("Button_readyGold")       --金币按钮
    local button_readyDiamond       =    meta.panel_ready:getChildByName("Button_readyDiamond")    --钻石按钮
    local button_readyCombat        =    meta.panel_ready:getChildByName("Button_readyCombat")     --体力按钮
    local imageView_readyUser       =    meta.panel_ready:getChildByName("ImageView_readyUser")   
    local imageView_readyGold       =    meta.panel_ready:getChildByName("ImageView_readyGold")           
    local imageView_readyDiamond    =    meta.panel_ready:getChildByName("ImageView_readyDiamond")
    local imageView_readyStrength   =    meta.panel_ready:getChildByName("ImageView_readyStrength")
    meta.image_newEmailNum          =    meta.panel_ready:getChildByName("Image_newEmailNum")
    meta.atlasLabel_newEmailNum     =    meta.image_newEmailNum:getChildByName("AtlasLabel_newEmailNum")

    meta.labelAtlas_userExp         =    imageView_readyUser:getChildByName("LabelAtlas_userExp")             --用户等级标签
    meta.labelAtlas_userLevel       =    imageView_readyUser:getChildByName("LabelAtlas_userLevel")           --用户经验百分比标签
    meta.labelAtlas_readyStrength   =    imageView_readyStrength:getChildByName("LabelAtlas_readyStrength")   --体力数字标签
    meta.labelAtlas_readyGold       =    imageView_readyGold:getChildByName("LabelAtlas_readyGold")           --金币数字标签
    meta.labelAtlas_readyDiamond    =    imageView_readyDiamond:getChildByName("LabelAtlas_readyDiamond")     --钻石数字标签 
    local imageView_readyRank       =    meta.panel_ready:getChildByName("ImageView_readyRank")               --排行榜面板
    meta.listView_rank              =    imageView_readyRank:getChildByName("ListView_rank")
    meta.button_readyRoleBuy        =    meta.panel_ready:getChildByName("Button_readyRoleBuy")               --购买英雄按钮
    meta.image_roleMoneyType_1      =    meta.button_readyRoleBuy:getChildByName("Image_roleMoneyType_1")
    meta.image_roleMoneyType_2      =    meta.button_readyRoleBuy:getChildByName("Image_roleMoneyType_2")
    meta.atlasLabel_rolePrice       =    meta.button_readyRoleBuy:getChildByName("AtlasLabel_rolePrice")

    meta.button_readyUpgradeBuy     =    meta.panel_ready:getChildByName("Button_readyUpgradeBuy")            --升级英雄按钮
    meta.image_moneyType_1          =    meta.button_readyUpgradeBuy:getChildByName("Image_moneyType_1")      --升级钻石图标
    meta.image_moneyType_2          =    meta.button_readyUpgradeBuy:getChildByName("Image_moneyType_2")      --升级金币图标
    meta.atlasLabel_upgPrice        =    meta.button_readyUpgradeBuy:getChildByName("AtlasLabel_upgPrice")    

    meta.button_rank                = {}           --查看排行榜玩家按钮
    meta.label_rankGname            = {}           --排行榜玩家名
    meta.bitmapLabel_rankPoint      = {}           --排行榜分数
    meta.image_rankStar             = {}           --排行榜英雄星级
    meta.image_rankHero             = {}           --排行榜英雄头像
    meta.atlasLabel_rank            = {{star1=nil,star2=nil,star3=nil,star4=nil,star5=nil}}           --排行榜排名

    for i =1 ,20 do 
        meta.button_rank[i]           = meta.listView_rank:getChildByName(string.format("Button_rank_%d",i))
        local j = i 
        meta.atlasLabel_rank[i]       = meta.button_rank[i]:getChildByName("AtlasLabel_rank")
        meta.label_rankGname[i]       = meta.button_rank[i]:getChildByName("Label_rankGname")
        meta.bitmapLabel_rankPoint[j] = meta.button_rank[i]:getChildByName("BitmapLabel_rankPoint")
        meta.image_rankHero[i]        = meta.button_rank[i]:getChildByName("Image_rankHero")
        meta.image_rankStar[i]        = {}
        meta.image_rankStar[i].star1  = meta.button_rank[i]:getChildByName("Image_rankStar_1")
        meta.image_rankStar[i].star2  = meta.button_rank[i]:getChildByName("Image_rankStar_2")
        meta.image_rankStar[i].star3  = meta.button_rank[i]:getChildByName("Image_rankStar_3")
        meta.image_rankStar[i].star4  = meta.button_rank[i]:getChildByName("Image_rankStar_4")
        meta.image_rankStar[i].star5  = meta.button_rank[i]:getChildByName("Image_rankStar_5")
    end 

    --排行榜面板控件
    local label_plaName             =    meta.panel_player:getChildByName("Label_plaName")
    local atlasLabel_plaMeter       =    meta.panel_player:getChildByName("AtlasLabel_plaMeter")
    local image_plaHeroName         =    meta.panel_player:getChildByName("Image_plaHeroName")
    local bitmapLabel_plaPoint      =    meta.panel_player:getChildByName("BitmapLabel_plaPoint")
    local label_plaHeroLevel        =    meta.panel_player:getChildByName("Label_plaHeroLevel")
    local button_plaBack            =    meta.panel_player:getChildByName("Button_plaBack")

    local button_readyLeft         =    meta.panel_ready:getChildByName("Button_readyLeft") 
    local button_readyRight        =    meta.panel_ready:getChildByName("Button_readyRight")
    local panel_readyHero          =    meta.panel_ready:getChildByName("Panel_readyHero")
    imageView_heroStarA            =    {}
    imageView_heroStarA[1]         =    panel_readyHero:getChildByName("ImageView_heroStarA_1")
    imageView_heroStarA[2]         =    panel_readyHero:getChildByName("ImageView_heroStarA_2")
    imageView_heroStarA[3]         =    panel_readyHero:getChildByName("ImageView_heroStarA_3")
    imageView_heroStarA[4]         =    panel_readyHero:getChildByName("ImageView_heroStarA_4")
    imageView_heroStarA[5]         =    panel_readyHero:getChildByName("ImageView_heroStarA_5")
    imageView_heroPro_1            =    panel_readyHero:getChildByName("ImageView_heroPro_1")
    imageView_heroPro_2            =    panel_readyHero:getChildByName("ImageView_heroPro_2")
    imageView_roleName             =    panel_readyHero:getChildByName("Image_roleName")   
    
    require "src/Hero/Hero"
    for i = 1,#meta.myHero do 
        --有这个英雄
        if meta.myHero[i]:getId() == tostring(meta.user_hero_tbid[meta.curHeroIdx]) then 
            GameGuideModel.curMyHero = meta.myHero[i]
            meta.button_readyRoleBuy:setVisible(false)
            meta.button_readyUpgradeBuy:setVisible(true)
            meta:setUpgreadePrice()
            break 
        end 
        --没有这个英雄
        if i == #meta.myHero then 
            GameGuideModel.curMyHero = Hero:create(tostring(meta.user_hero_tbid[meta.curHeroIdx]),"1",0)
            meta.button_readyRoleBuy:setVisible(true)
            meta.button_readyUpgradeBuy:setVisible(false)
            meta:setRolePrice()
        end 
    end
    

                 --日常任务面板
    --安卓返回键
    ----"http://www.lolrun.com/api/get_server.php?macode=iphoke6s&uid=800000000&uname=i1622412093&sid=1"
    --http://www.lolrun.com/api/get_section.php?act=get_section&macode=lfjdlfdja&uid=800000001&uname=i1603275411&gname=%E5%93%88%E5%93%88&sid=1
    --http://www.lolrun.com/api/get_server.php?act=add_role& macode=iphoke6s&uid=800000000&uname=i1622412093&gname=women&sid=1
    --http://www.lolrun.com/api/login.php?macode=iphoke6s&uname=i1622412093&psw=i1622412093
    local key_listener = cc.EventListenerKeyboard:create()
    local function key_return()
        --strengthen = false , 
        --setting    = false , 
        --email      = false , 
        --task       = false , 
        --bag        = false ,
        --gift       = false , 
        --mystery    = false ,
        --mode       = false ,
        --role       = false , 
        --section    = false ,
        --activity   = false ,
        --diamond    = false ,
        --gold       = false ,
        --strength   = false 
        if meta.isOpened.setting == true then 
            --g_tips_setString("退出设置",1)
            if meta.mainLayer:getChildByTag(54) == nil then 
                GameSettingView:remove()
            end 
        elseif meta.isOpened.task == true then 
            --g_tips_setString("退出邮件",1)
            if meta.mainLayer:getChildByTag(54) == nil then 
                GameTaskView:remove()
            end 
        elseif meta.isOpened.email == true then
            --g_tips_setString("退出任务",1) 
            if meta.mainLayer:getChildByTag(54) == nil then 
                GameEmailView:remove()
            end 
        elseif meta.isOpened.bag == true then
            --g_tips_setString("退出背包",1) 
            if meta.mainLayer:getChildByTag(54) == nil then 
                GameBagView:remove()
            end 
        --elseif meta.isOpened.gift == true then
        --    g_tips_setString("退出奖励",1) 
        --    GameGiftView:remove()
        elseif meta.isOpened.mystery == true then
            --g_tips_setString("退出商店",1) 
            if meta.mainLayer:getChildByTag(54) == nil then
                GameMysteryView:remove()
            end 
        elseif meta.isOpened.mode == true then
            --g_tips_setString("退出模式",1)
            if meta.mainLayer:getChildByTag(54) == nil then
                GameModeView:remove()
            end 
        elseif meta.isOpened.role == true then
            if meta.mainLayer:getChildByTag(54) == nil then
                if meta.isOpened.strengthen == false then 
                    --g_tips_setString("退出英雄",1) 
                    GameRoleView:remove()   
                end 
            end 
        elseif meta.isOpened.map     == true  then 
            --g_tips_setString("退出章节",1)
            if meta.mainLayer:getChildByTag(54) == nil then
                GameMapView:remove()
            end 
        elseif meta.isOpened.activity == true then
            --g_tips_setString("退出首冲",1)
            if meta.mainLayer:getChildByTag(54) == nil then
                GameActivityView:remove()
            end 
        elseif meta.isOpened.diamond == true then
            --g_tips_setString("退出钻石",1)
            if meta.mainLayer:getChildByTag(54) == nil then
                GameDiamondView:remove()
            end 
        elseif meta.isOpened.gold == true then
            --g_tips_setString("退出金币",1)
            if meta.mainLayer:getChildByTag(54) == nil then
                GameGoldView:remove()
            end 
        elseif meta.isOpened.strength == true then
            --g_tips_setString("退出体力",1)
            if meta.mainLayer:getChildByTag(54) == nil then
                GameStrengthView:remove()
            end 
        end  
    end
    key_listener:registerScriptHandler(key_return,cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = meta.mainLayer:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(key_listener,meta.mainLayer)




    --英雄切换动画事件
    local function heroActionEvent(touch,eventType)
        --local arma_action = {
        --    "attack";
        --    "death";
        --    "Injured";
        --    "jump2";
        --    "skills";
        --}
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        --end
        --if eventType == ccui.TouchEventType.ended then 
            cclog(touch:getName())
            local hero = self.curHero:getAnimation()
            local heroPlayIdx = 1
            heroPlayIdx = (heroPlayIdx+1) % hero:getMovementCount()
            cclog("index = %d" , heroPlayIdx)

            local function run()
                self.curHero:getAnimation():play("run")
            end

            local function getNextAction()
                --if self.curPlayName == "run" then
                --    self.curPlayName = ROLE_SHWO_ACTION[1]
                --    cclog(ROLE_SHWO_ACTION[1])
                --    return ROLE_SHWO_ACTION[1]
                --else
                --    for key,val in pairs(ROLE_SHWO_ACTION) do 
                --        if val == self.curPlayName then
                --            cclog("self.curPlayName = " ..self.curPlayName)
                --            local idx = key % table.maxn(ROLE_SHWO_ACTION) + 1
                --            self.curPlayName = ROLE_SHWO_ACTION[idx]
                --            cclog(ROLE_SHWO_ACTION[idx])
                --            return ROLE_SHWO_ACTION[idx]
                --        end
                --    end
                --end
                self.curHero:getAnimation():play("attack")
            end

            local function moveAction()
                self.curHero:getAnimation():play(getNextAction())
            end
            self.mainLayer:stopAllActions()
            self.mainLayer:runAction(cc.Sequence:create(
                                                        cc.CallFunc:create(moveAction),
                                                        cc.DelayTime:create(1),
                                                        cc.CallFunc:create(run)
                                                        )
                                     )
       end
    end

    --星级，名字,属性
    local function setHeroPro()
         local starlevel = GameGuideModel.curMyHero:getStarlevel() 
         local pro       = GameGuideModel.curMyHero:getType()
         if pro == "远" then 
            imageView_heroPro_1:setVisible(false)
            imageView_heroPro_2:setVisible(true)
         else 
            imageView_heroPro_1:setVisible(true)
            imageView_heroPro_2:setVisible(false)
         end 
         
         for i = 1, 5 do 
            if i <= starlevel then 
                imageView_heroStarA[i]:setVisible(true)
            else 
                imageView_heroStarA[i]:setVisible(false)
            end 
         end 
        --local proname = meta.curMyHero:getName()
        local proname = GameGuideModel.curMyHero:getName()
        if proname == "提百万" then 
            imageView_roleName:loadTexture("kongzhi_yingxiong_timo.png",ccui.TextureResType.plistType)
        elseif proname == "草丛伦" then 
            imageView_roleName:loadTexture("kongzhi_yingxiong_gailun.png",ccui.TextureResType.plistType)
        elseif proname == "菊花信" then 
            imageView_roleName:loadTexture("kongzhi_yingxiong_zhaoxin.png",ccui.TextureResType.plistType)
        elseif proname == "狐狸"   then 
            imageView_roleName:loadTexture("kongzhi_yingxiong_ali.png",ccui.TextureResType.plistType)
        elseif proname == "剑圣"   then 
            imageView_roleName:loadTexture("kongzhi_yingxiong_jiansheng.png",ccui.TextureResType.plistType)
        elseif proname == "探险家" then 
            imageView_roleName:loadTexture("kongzhi_yingxiong_ez.png",ccui.TextureResType.plistType)
        end 
    end 

    setHeroPro()

    --准备界面  跳  设置界面 
    local function readyToSettingEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        --end
        -- if eventType == ccui.TouchEventType.ended then 
            meta.isOpened.setting = true
            GameSettingView:getGameGuideMeta(meta)
            meta.mainLayer:addChild(GameSettingView:init(),50,50)
        end
    end 

    --准备界面 跳 任务界面
    local function readyToTaskEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            cclog(touch:getName())
           meta.isOpened.task = true
           GameTaskView:getGameGuideMeta(meta)
           meta.mainLayer:addChild(GameTaskView:init(),50,50)
        end
       --if eventType == ccui.TouchEventType.ended then 
           
       --end 
    end 
    
    --准备界面  跳 邮件界面
    local function readyToEmailEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
       -- end
       --if eventType == ccui.TouchEventType.ended then 
           cclog(touch:getName())
           meta.isOpened.email = true
           GameEmailView:getGameGuideMeta(meta)
           meta.mainLayer:addChild(GameEmailView:init(),50,50)
       end 
    end
    
    --准备界面 跳 背包界面
    local function readyToBagEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
       if eventType == ccui.TouchEventType.ended then 
           cclog(touch:getName())
           meta.isOpened.bag = true
           GameBagView:getGameGuideMeta(meta)
           meta.mainLayer:addChild(GameBagView:init(),50,50)
       end 
    end

    ----战斗准备界面  转   礼包（奖励）界面
    --local function readyToGiftEvent(touch,eventType)
    --    if eventType == ccui.TouchEventType.began then 
    --        SimpleAudioEngine:getInstance():playEffect("res/music/effect/fight/get_item.ogg")
    --    end
    --    if  eventType == ccui.TouchEventType.ended then
    --       cclog(touch:getName())
    --       meta.isOpened.gift = true
    --       baGiftView:getGameGuideMeta(meta)
    --       meta.mainLayer:addChild(GameGiftView:init(),50,50)
    --    end
    --end 

    --准备战斗界面 转   神秘商店界面
    local function readyToMysteryEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then 
            cclog(touch:getName())
            meta.isOpened.mystery = true
            GameMysteryView:getGameGuideMeta(meta)
            meta.mainLayer:addChild(GameMysteryView:init(),50,50)
        end 
    end 

    --准备界面  转 战役界面
    local function readyToModeEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then
            cclog(touch:getName())
            meta.isOpened.mode = true
            GameModeView:getGameGuideMeta(meta)
            meta.mainLayer:addChild(GameModeView:init(),50,50)
        end
    end

    --战斗准备界面  转 选择英雄界面
    local function readyToRoleEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then 
            --panel_role:setVisible(true)
            cclog(touch:getName())
            touch:setLocalZOrder(5)
            meta.isOpened.role = true
            GameRoleView:getGameGuideMeta(meta)
            local roleview = GameRoleView:init()
            meta.mainLayer:addChild(roleview,50,50)
        end
    end 


    --准备   跳 章节界面
    local function loginEventListener(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        --end
        --if eventType == ccui.TouchEventType.ended then
            cclog(touch:getName())
            local isCanPlay = 0
            for i = 1 , #meta.myHero do 
                 if GameGuideModel.curMyHero:getId() == meta.myHero[i]:getId() then 
                    cclog("你有这个英雄")
                    isCanPlay = 1 
                    break 
                 else 
                     if i == #meta.myHero then 
                         cclog("你没有这个英雄")
                         isCanPlay = 0
                         androidAlert("需要先购买此英雄")
                     end 
                 end 
            end 
            if isCanPlay == 1 then  
                --playEffect("res/music/effect/sound002button.ogg")
                if RoleModel.role_type == nil then 
                    RoleModel.role_type = ROLE_HERO_ENUM.tm--战斗场景英雄角色
                end 
                meta.isOpened.kind = true
                GameKindView:getGameGuideMeta(meta)
                local kindview = GameKindView:init()
                meta.mainLayer:addChild(kindview,50,50)
            elseif isCanPlay == 0 then 

            end 
		end
    end

    --准备界面 跳 活动界面
    local function readyToActivityEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            --if touch:getName() == "Image_readyAct" then 
            --    meta.isOpened.activity = true
            --   GameActivityView:getGameGuideMeta(meta)
            --   meta.mainLayer:addChild(GameActivityView:init(),50,50)
            --end  
       -- end
       --if eventType == ccui.TouchEventType.ended then 
           cclog(touch:getName())
           meta.isOpened.activity = true
           GameActivityView:getGameGuideMeta(meta)
           --local actview = GameActivityView:init()
           meta.mainLayer:addChild(GameActivityView:init(),50,50)
       end 
    end

    --准备界面 跳 钻石界面
    function readyToDiamondEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        --end
        -- if eventType == ccui.TouchEventType.ended then 
            cclog(touch:getName())
            meta.isOpened.diamond = true
            GameDiamondView:getGameGuideMeta(meta)
            meta.mainLayer:addChild(GameDiamondView:init(),50,50)
        end
    end 

    --准备界面 跳 金币界面
    function readyToGoldEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        --end
        -- if eventType == ccui.TouchEventType.ended then 
            cclog(touch:getName())
            meta.isOpened.gold = true
            GameGoldView:getGameGuideMeta(meta)
            meta.mainLayer:addChild(GameGoldView:init(),50,50)
        end
    end 

    --准备界面 跳 体力界面
    function readyToStrengthEvent(touch,eventType)
         if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        --end
        -- if eventType == ccui.TouchEventType.ended then 
            --panel_strength:setVisible(true)
            cclog(touch:getName())
            meta.isOpened.strength = true
            GameStrengthView:getGameGuideMeta(meta)
            meta.mainLayer:addChild(GameStrengthView:init(),50,50)
        end
    end 


    local function HeroEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        local wid = 90
        local hig = 150*2.5
        if #meta.user_hero_tb <= 1 or #meta.user_hero_tb > #GameGuideModel.heroName then 
            return 
        end
        if eventType == ccui.TouchEventType.ended then 
            if touch:getName() == "Button_readyLeft" then 
                cclog(touch:getName())
                --if self.curHeroIdx == 1 then 
                --    self.curHeroIdx = #GameGuideModel.heroName
                --else 
                --    self.curHeroIdx = self.curHeroIdx-1 
                --end
                ----------------------------------

                for key,val in pairs(meta.user_hero_tb) do 
                    if val == self.curHeroIdx then 
                        if self.curHeroIdx == meta.user_hero_tb[1] then 
                            self.curHeroIdx = meta.user_hero_tb[#meta.user_hero_tb]
                            break
                        else
                            self.curHeroIdx = meta.user_hero_tb[key - 1]
                            break
                        end
                    end
                end
                --------------------------------------
                local RoleModel = require "src/Role/RoleM"
                if GameGuideModel.heroName[self.curHeroIdx] == "Teemo" then
                    RoleModel.role_tag = ROLE_HERO_ENUM.tm
                    playEffect("res/music/effect/role/teemo/Teemo_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "Ezreal" then
                    RoleModel.role_tag =  ROLE_HERO_ENUM.ez
                    playEffect("res/music/effect/role/ez/Ezreal_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "zhaoxin" then
                    RoleModel.role_tag = ROLE_HERO_ENUM.zx
                    playEffect("res/music/effect/role/zhaoxin/zhaoxi_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "Ahri" then
                   RoleModel.role_tag =  ROLE_HERO_ENUM.ah
                   playEffect("res/music/effect/role/ahri/Ahri_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "Garen" then
                   RoleModel.role_tag =  ROLE_HERO_ENUM.dm
                   playEffect("res/music/effect/role/garen/Garen_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "JS" then
                   RoleModel.role_tag =  ROLE_HERO_ENUM.js
                   playEffect("res/music/effect/role/js/JS_start.ogg")
                end
                
            else 
                -------------------------------------------------
                --cclog(touch:getName())
                --self.curHeroIdx = self.curHeroIdx%#GameGuideModel.heroName + 1
                -------------------------------------------------
                for key,val in pairs(meta.user_hero_tb) do 
                    if val == self.curHeroIdx then 
                        if self.curHeroIdx == meta.user_hero_tb[#meta.user_hero_tb] then 
                            self.curHeroIdx = meta.user_hero_tb[1]
                            break
                        else
                            self.curHeroIdx = meta.user_hero_tb[key + 1]
                            break
                        end
                    end
                end
                ------------------------------------------------
                if GameGuideModel.heroName[self.curHeroIdx] == "Teemo" then
                   RoleModel.role_tag = ROLE_HERO_ENUM.tm
                   playEffect("res/music/effect/role/teemo/Teemo_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "Ezreal" then
                   RoleModel.role_tag = ROLE_HERO_ENUM.ez
                   playEffect("res/music/effect/role/ez/Ezreal_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "zhaoxin" then
                   RoleModel.role_tag = ROLE_HERO_ENUM.zx
                   playEffect("res/music/effect/role/zhaoxin/zhaoxi_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "Ahri" then
                   RoleModel.role_tag = ROLE_HERO_ENUM.ah
                   playEffect("res/music/effect/role/ahri/Ahri_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "Garen" then
                   RoleModel.role_tag =  ROLE_HERO_ENUM.dm
                   playEffect("res/music/effect/role/garen/Garen_start.ogg")
                elseif GameGuideModel.heroName[self.curHeroIdx] == "JS" then
                   RoleModel.role_tag =  ROLE_HERO_ENUM.js
                   playEffect("res/music/effect/role/js/JS_start.ogg")
                end
            end 
            cclog("curHeroIdx = %d",self.curHeroIdx)
            cclog(meta.user_hero_tbid[meta.curHeroIdx])
          

            --[[以前切换英雄
            for i = 1,#meta.myHero do 
                if meta.myHero[i]:getId() == tostring(meta.user_hero_tbid[meta.curHeroIdx]) then 
                    GameGuideModel.curMyHero = meta.myHero[i]
                    break 
                end 
            end 
            --]]
            require "src/Hero/Hero"
            for i = 1,#meta.myHero do 
                --有这个英雄
                if meta.myHero[i]:getId() == tostring(meta.user_hero_tbid[meta.curHeroIdx]) then 
                    GameGuideModel.curMyHero = meta.myHero[i]
                    meta.button_readyRoleBuy:setVisible(false)
                    meta.button_readyUpgradeBuy:setVisible(true)
                    meta:setUpgreadePrice()
                    break 
                end 
                --没有这个英雄
                if i == #meta.myHero then 
                    GameGuideModel.curMyHero = Hero:create(tostring(meta.user_hero_tbid[meta.curHeroIdx]),"1",0)
                    meta.button_readyRoleBuy:setVisible(true)
                    meta.button_readyUpgradeBuy:setVisible(false)
                    meta:setRolePrice()
                end 
            end
            

            cclog(meta.user_hero_tbid[meta.curHeroIdx])
            cclog(GameGuideModel.curMyHero:getName())

            
            setHeroPro()
            self.curHero:removeFromParent()
            self.curHero =  ccs.Armature:create(GameGuideModel.heroName[self.curHeroIdx])
            self.curHero:setScale(1.5)
            self.curHero:getAnimation():play("run")
            self.curPlayName = "run"
            self.curHero:setPosition(cc.p(wid-20,hig/3))
            self.heroPlatform:addChild(self.curHero)
        end
    end
   

    --查看排行榜
    local function toRankEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then 
            cclog(touch:getName())
            local touchName = touch:getName() 
            local itemNum = tonumber(string.sub(touchName, 13))
            meta.panel_player:setVisible(true)
            --玩家名字
            label_plaName:setString(GameGuideModel.ranks[itemNum].gname)
            --距离
            atlasLabel_plaMeter:setString(GameGuideModel.ranks[itemNum].rank_dis)
            --得分
            local qianfenhao = ""
            local score = GameGuideModel.ranks[itemNum].rank_score
            local score2 = score 
            repeat
                score2 = score % 1000 
                score = math.floor( score / 1000 )
                if score > 0 then 
                    qianfenhao = string.format("%03d",score2)..qianfenhao
                    qianfenhao =","..qianfenhao 
                else 
                    qianfenhao = score2 .. qianfenhao
                end
            until score == 0
            bitmapLabel_plaPoint:setString(qianfenhao)
            --英雄等级
            label_plaHeroLevel:setString(GameGuideModel.ranks[itemNum].hero_level)
            local nameImgPath = Hero:getNamePathById(GameGuideModel.ranks[itemNum].hero_id)
            image_plaHeroName:loadTexture(nameImgPath,ccui.TextureResType.plistType)
            image_plaHeroName:setLocalZOrder(10)
            local armatureName = Hero:getDonghuaById(GameGuideModel.ranks[itemNum].hero_id)
            meta.playerArmature = ccs.Armature:create(armatureName)
            meta.playerArmature:getAnimation():play("wait")
            meta.playerArmature:setPosition(cc.p(480,250))
            meta.playerArmature:setScale(1.5)
            meta.panel_player:addChild(meta.playerArmature,5)
            cclog(GameGuideModel.ranks[itemNum].hero_id)
            cclog( Hero:getNamePathById(GameGuideModel.ranks[itemNum].hero_id).."12312312")
            cclog(Hero:getDonghuaById(GameGuideModel.ranks[itemNum].hero_id))
        end
    end 

    --关闭查看排行榜玩家信息
    local function playerBackEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then 
            meta.playerArmature:removeFromParent()
            meta.panel_player:setVisible(false)
        end
    end 

    --购买英雄方法
    local function heroBuyEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then
            local function myBuyHero(msg) 
                local cjson = require "cjson"
                local temp_conf = cjson.decode(msg)
                if temp_conf.code == 1 or temp_conf.code == "1" then 
                    cclog("购买成功")
                    g_userinfo.gold =  temp_conf.member_info.member_gold
                    g_userinfo.diamond =  temp_conf.member_info.member_diamond
                    g_userinfo.physical =  temp_conf.member_info.member_physical
                    g_userinfo.heros = {}
                    for i=1,#temp_conf.hero_info do
                        g_userinfo.heros[i] = {}
                        g_userinfo.heros[i].level = temp_conf.hero_info[i].hero_level
                        g_userinfo.heros[i].id = temp_conf.hero_info[i].hero_hrid
                    end
                    meta.setUserData()
                    meta.initHeroData()
                    meta.button_readyRoleBuy:setVisible(false)
                    meta.button_readyUpgradeBuy:setVisible(true)
                    meta:setUpgreadePrice()
                else 
                    cclog("购买失败")
                    --androidAlert("钻石不足")
                    meta.panel_readyYes:setVisible(true)
                end 
            end 
            local requrl = g_url.exchange_hero.."&uid=".. g_userinfo.uid .."&uname=".. g_userinfo.uname .."&sid=".. g_userinfo.sid .."&hid="..tostring(GameGuideModel.curMyHero:getId())
            Func_HttpRequest(requrl,"",myBuyHero)
        end 
    end 
    
    local function readyUpgradeBuyEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then
            meta:readyToUpgradeEvent()
        end
    end 

    local function kaichangBackEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            meta.panel_kaichang:setVisible(false)
        end
    end 

    local function gift28Event(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            meta.alipay("28")
        end
    end 

    --确定进入界面接口
    local function confirmEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.ended then 
            if touch:getName() == "Button_yes" then 
                meta.enterDiamond()
                meta.panel_readyYes:setVisible(false)
            else 
                cclog("no")
                meta.panel_readyYes:setVisible(false)
            end  
        end 
    end

    --添加回调事件
    panel_readyTouch:addTouchEventListener(heroActionEvent)
    button_readySetting:addTouchEventListener(readyToSettingEvent)
    button_readyTask:addTouchEventListener(readyToTaskEvent)
    button_readyEmail:addTouchEventListener(readyToEmailEvent)
    button_readyBag:addTouchEventListener(readyToBagEvent)
    button_readyShop:addTouchEventListener(readyToActivityEvent)
    button_readyMode:addTouchEventListener(readyToModeEvent)
    meta.button_readyStart:addTouchEventListener(loginEventListener)
    meta.button_readySelectHero:addTouchEventListener(readyToRoleEvent)
    meta.button_readyActivity:addTouchEventListener(readyToActivityEvent)
    button_readyGold:addTouchEventListener(readyToGoldEvent)
    button_readyCombat:addTouchEventListener(readyToStrengthEvent)
    button_readyDiamond:addTouchEventListener(readyToDiamondEvent)
    button_readyLeft:addTouchEventListener(HeroEvent)
    button_readyRight:addTouchEventListener(HeroEvent)
    
    meta.button_readyRoleBuy:addTouchEventListener(heroBuyEvent)
    meta.button_readyUpgradeBuy:addTouchEventListener(readyUpgradeBuyEvent)
    button_33:addTouchEventListener(kaichangBackEvent)
    button_liqu:addTouchEventListener(gift28Event)
    button_yes:addTouchEventListener(confirmEvent)
    button_no:addTouchEventListener(confirmEvent)
    for i = 1 , #meta.button_rank do 
        meta.button_rank[i]:addTouchEventListener(toRankEvent)
    end 
    button_plaBack:addTouchEventListener(playerBackEvent)           

    meta.mainLayer:addChild(uiLayout)
end 



--开启设置面板标记 为  false  
function meta:setSettingFalse()
    meta.isOpened.setting = false 
end 

--开启任务面板 标记 为  false  
function meta:setTaskFalse()
    meta.isOpened.task = false 
end 

--开启邮件面板标记 为  false  
function meta:setEmailFalse()
    meta.isOpened.email = false 
end 

--开启背包面板标记 为  false  
function meta:setBagFalse()
    meta.isOpened.bag = false 
end 

--开启背包面板标记 为  false  
function meta:setGiftFalse()
    meta.isOpened.gift = false 
end 

--开启神秘商店面板标记 为  false  
function meta:setMysteryFalse()
    meta.isOpened.mystery = false 
end 

--开启战役面板标记 为  false  
function meta:setModeFalse()
    meta.isOpened.mode = false 
end 

--开启英雄面板标记 为  false  
function meta:setRoleFalse()
    meta.isOpened.role = false 
end 

--开启章节面板标记 为  false  
--function meta:setSectionFalse()
--    meta.isOpened.section = false 
--end 

--开启地图面板标记 为false
function meta:setMapFalse()
    meta.isOpened.map = false 
end 

--开启首冲面板标记 为  false  
function meta:setActivityFalse()
    meta.isOpened.activity = false 
end 

--开启钻石面板标记 为  false  
function meta:setDiamondState(state)
    meta.isOpened.diamond = state 
end 

--开启金币面板标记 为  false  
function meta:setGoldFalse()
    meta.isOpened.gold = false 
end 

--开启钻石面板标记 为  false  
function meta:setStrengthFalse()
    meta.isOpened.strength = false 
end 

--开启模式面板标记为false
function meta:setKindFalse()
    meta.isOpened.kind = false
end 

----恢复体力
function meta:strengthRefresh()
    meta.countDownTime= meta.countDownTime - 1
    if meta.countDownTime < 0 then --倒计时完成
       meta.countDownTime = 60
       local function myPhysical(msg)
           cclog("请求恢复体力")
           g_userinfo.physical = tonumber(msg)
           meta.labelAtlas_readyStrength:setString(g_userinfo.physical)
	   end 
	   local requrl = g_url.get_physical.."&uid=" .. g_userinfo.uid .."&uname=".. g_userinfo.uname .. "&sid=".. g_userinfo.sid
       Func_HttpRequest(requrl,"",myPhysical,false)
    end 
    cclog(meta.countDownTime)
end 


--获得倒计时时间
function meta:getCountDownTime()
    return meta.countDownTime
end 

--开启倒计时定时器
function meta:openCountDownTime()
    if  tonumber(g_userinfo.physical) < 100 then 
        cclog("体力不满")
        if meta.strengthSch == nil  then 
            cclog("开启倒计时定时器")
            meta.strengthSch = cc.Director:getInstance():getScheduler():scheduleScriptFunc(meta.strengthRefresh,1,false)
        end 
    end 
end 

--关闭倒计时定时器
function meta:closeCountDownTime()
    if meta.strengthSch ~= nil  then 
            cclog("关闭倒计时定时器")
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(meta.strengthSch)
            meta.strengthSch = nil
    end 
end 

--进入钻石界面
function meta.enterDiamond()
    meta.isOpened.diamond = true
    GameDiamondView:getGameGuideMeta(meta)
    meta.mainLayer:addChild(GameDiamondView:init(),52,50)
end 

--进入金币界面
function meta.enterGold()
    meta.isOpened.gold = true
    GameGoldView:getGameGuideMeta(meta)
    meta.mainLayer:addChild(GameGoldView:init(),52,50)
end

--进入体力界面
function meta.enterStrength()
    meta.isOpened.strength = true
    GameStrengthView:getGameGuideMeta(meta)
    meta.mainLayer:addChild(GameStrengthView:init(),52,50)
end

--设置英雄界面的金钱数
function meta.setHeroGold()
    GameRoleView.setGold()
end 

--设置英雄界面的钻石
function meta.setHeroDiamond()
    GameRoleView.setDiamond()
end 

--设置英雄界面的体力
function meta.setHeroStrength()
    GameRoleView.setStrength()
end 

--设置首冲界面的金钱
function meta.setAct4Gold()
    GameActivityView.setGold()
end 

--设置首冲界面的体力
function meta.setAct4Strength()
    GameActivityView.setStrength()
end 

--设置首冲界面的钻石
function meta.setAct4Diamond()
    GameActivityView.setDiamond()
end 

--进入活动界面
function meta.enterActivity()
    --meta.isOpened.activity = true
    --GameActivityView:getGameGuideMeta(meta)
    --meta.mainLayer:addChild(GameActivityView:init(),52,50)
    meta.isOpened.activity = true
    GameActivityView:getGameGuideMeta(meta)
    local actview = GameActivityView:init()
    meta.mainLayer:addChild(actview,50,50)
end

--进入KIND界面
function meta.enterKind()
    meta.isOpened.kind = true
    GameKindView:getGameGuideMeta(meta)
    meta.mainLayer:addChild(GameKindView:init(),52,50)
end



--初始化排行榜
function meta:setRankData()
    for i = 1,#GameGuideModel.ranks do 
        meta.atlasLabel_rank[i]:setString(tostring(i))
        local qianfenhao = ""
        local score = GameGuideModel.ranks[i].rank_score
        local score2 = 0
        repeat
            score2 = score % 1000 
            score = math.floor( score / 1000 )
            if score > 0 then 
                qianfenhao = string.format("%03d",score2)..qianfenhao
                qianfenhao =","..qianfenhao 
            else 
                qianfenhao = score2 .. qianfenhao
            end 
        until score == 0
        meta.bitmapLabel_rankPoint[i]:setString(qianfenhao)
        meta.label_rankGname[i]:setString(GameGuideModel.ranks[i].gname)
        local headImgPath = Hero:getNameImageById(GameGuideModel.ranks[i].hero_id)
        meta.image_rankHero[i]:loadTexture(headImgPath,ccui.TextureResType.plistType)
    end 
end 


--战斗准备界面  转 界面
function meta:readyToUpgradeEvent() 
    meta.isOpened.role = true
    GameRoleView:getGameGuideMeta(meta)
    meta.mainLayer:addChild(GameRoleView:init(),50,50)
   GameRoleView:attatkToRolePanel()
end

-- 设置英雄价格
function meta:setRolePrice()
    local curName = GameGuideModel.curMyHero:getName()
    for i =1 ,#GameRoleModel.shopRolePrice do 
        if curName == GameRoleModel.shopRoleName[i] and i > 1 then 
            meta.image_roleMoneyType_2:setVisible(true)
            meta.image_roleMoneyType_1:setVisible(false)
            meta.atlasLabel_rolePrice:setString(GameRoleModel.shopRolePrice[i])
        elseif curName == GameRoleModel.shopRoleName[i] and i == 1 then   
            meta.image_roleMoneyType_2:setVisible(false)
            meta.image_roleMoneyType_1:setVisible(true)
            meta.atlasLabel_rolePrice:setString(GameRoleModel.shopRolePrice[i])  
        end 
    end 
end 

--设置英雄升级价格
function meta:setUpgreadePrice()
    local cjson = require "cjson"
    --local rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/upgradeconf.json")
    --g_conf.g_upgrade_conf = cjson.decode(rconf)
    local limitConf = #g_conf.g_upgrade_conf 
    cclog("英雄升级" .. #g_conf.g_upgrade_conf)
    local level = tonumber(GameGuideModel.curMyHero:getLevel())
    if   level  > limitConf - 2 then 
        meta.atlasLabel_upgPrice:setString("0")
        cclog(g_conf.g_upgrade_conf[level].upgrade_needNum)
    elseif  level > 60 then 
        meta.atlasLabel_upgPrice:setString(g_conf.g_upgrade_conf[level+1].upgrade_needNum)
        meta.image_moneyType_1:setVisible(true)
        meta.image_moneyType_2:setVisible(false)
        meta.upgradePayType  = "钻石"
    else 
        meta.atlasLabel_upgPrice:setString(g_conf.g_upgrade_conf[level+1].upgrade_needNum)
        meta.image_moneyType_1:setVisible(false)
        meta.image_moneyType_2:setVisible(true)
        meta.upgradePayType  = "金币"
    end 
end 

function meta.leaderUpgrade()
    require "src/leader/uileader"
    meta.mainLayer:addChild(UILeader:create(8),62,54)
end 

function meta.leaderEndless()
    require "src/leader/uileader"
    meta.mainLayer:addChild(UILeader:create(15),62,54)
end 

function meta.leaderActivity()
    require "src/leader/uileader"
    meta.mainLayer:addChild(UILeader:create(18),62,54)
end 

function meta.leaderLibao()
    require "src/leader/uileader"
    meta.mainLayer:addChild(UILeader:create(1),62,54)
end 

function meta.rewardGift(gift_id)
    local function myGift(msg)
        cclog(msg)
        local cjson = require "cjson"
		local obj = cjson.decode(msg)
        if obj.code == 1 then  
            cclog("领取礼包成功")
            g_userinfo.gold =  obj.member_info.member_gold
            g_userinfo.diamond =  obj.member_info.member_diamond
            g_userinfo.physical =  obj.member_info.member_physical
            g_userinfo.heros = {}
            for i=1,#obj.hero_info do
                g_userinfo.heros[i] = {}
                g_userinfo.heros[i].level = obj.hero_info[i].hero_level
                g_userinfo.heros[i].id = obj.hero_info[i].hero_hrid
            end
            meta.setUserData()
            meta.initHeroData()
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
            cclog("支付:"..msg)
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

--领取新手邮件
function meta.rewardEmailGift(email_id)
    local function myEmailGift(msg)
        local cjson = require "cjson"
		local obj = cjson.decode(msg)
        if obj.code == 1 then  
            cclog("领取礼包成功")
            g_userinfo.gold =  obj.member_info.member_gold
            g_userinfo.diamond =  obj.member_info.member_diamond
            g_userinfo.physical =  obj.member_info.member_physical
            meta.setUserData()
            GameEmailModel.removeNewPlayerGift()
        end 
          cclog("领取新手邮件返回："..msg)
    end
    local requrl = g_url.get_prize.."&uid=".. g_userinfo.uid .. "&uname=" .. g_userinfo.uname .. "&sid=" .. g_userinfo.sid .. "&email_id=" .. email_id
    Func_HttpRequest(requrl,"",myEmailGift)
end 

function meta:setEmailNum(emailNum)
    if tonumber(emailNum) == 0 then 
        meta.image_newEmailNum:setVisible(false)
    else 
        meta.atlasLabel_newEmailNum:setString(emailNum)
        meta.image_newEmailNum:setVisible(true)
    end 
end 

function meta:setResetPrice()
    require "src/Hero/Hero"
    for i = 1,#meta.myHero do 
        --有这个英雄
        if meta.myHero[i]:getId() == tostring(meta.user_hero_tbid[meta.curHeroIdx]) then 
            GameGuideModel.curMyHero = meta.myHero[i]
            meta.button_readyRoleBuy:setVisible(false)
            meta.button_readyUpgradeBuy:setVisible(true)
            meta:setUpgreadePrice()
            break 
        end 
        --没有这个英雄
        if i == #meta.myHero then 
            GameGuideModel.curMyHero = Hero:create(tostring(meta.user_hero_tbid[meta.curHeroIdx]),"1",0)
            meta.button_readyRoleBuy:setVisible(true)
            meta.button_readyUpgradeBuy:setVisible(false)
            meta:setRolePrice()
        end 
    end
end 

function meta:gotoLeader(leadOpen)
    if g_userinfo.leader == 0 then
       meta.panel_kaichang:setVisible(false)
       require "src/leader/uileader"
       meta.mainLayer:addChild(UILeader:create(1),62,54)
    else
       if g_userinfo.leader == 17 and leadOpen == nil then 
            cclog("进入活动功能界面")
            meta.panel_kaichang:setVisible(false)
            require "src/leader/uileader"
            meta.mainLayer:addChild(UILeader:create(18),62,54)
        end
    end

  
end 

return GameGuideView