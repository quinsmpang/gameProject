require "src/Hero/Hero"
local GameRoleView=
{
    mainLayer        = nil,  --本图层
    panel_role       = nil, 
    isOpened         = true ,  --本图层是否开启
    readyMeta        = nil,
    panel_upgrade    = nil,
    panel_advanced   = nil,
    panel_roleYes    = nil,
    isUpgradeOpened  = false,
    isAdvancedOpened = false, 
    loadingBar_level   = nil,
    loadingBar_blood   = nil,
    loadingBar_attack  = nil,
    loadingBar_crit    = nil,
    label_level        = nil,
    label_blood        = nil,
    label_attack       = nil,
    label_crit         = nil,
    label_jump         = nil,
    heroArmature       = nil,--保存英雄动画对象
    button_green       = {},
    imageView_rolePro_1= nil,
    imageView_rolePro_2= nil,
    hero_cur_action_idx    = 0,--当前动作，0表示run
    max = 
    { --进度条最大值
        level  = 75,
        life   = 300,
        attack = 400,
        crit   = 0.5
    },
    button_roleBuy    = nil,
    button_roleIsSeleced = nil,
    button_upgrade     = nil,
    label_heroTitle    = nil,
    curHero   = nil,
    curLevel  = nil,
    curLife   = nil,
    curAttack = nil,
    curCrit   = nil,
    curSymbol = {},
    curPro    = nil,
    upgradeAnimation = nil,            --升级界面 动画
    shoSkillAnimation1 = nil,            --技能展示界面动画--英雄
    shoSkillAnimation2 = nil,            --技能展示界面动画--冲刺  
    labelAtlas_heroStrength = nil,
    labelAtlas_heroGold     = nil,
    labelAtlas_heroDiamond  = nil,
    upgradePayType          = "钻石"  ,
    buyRolePayType          = "钻石"  ,
    upgTime    = 0,
    levelupAnimation        = nil ,    --升级动画
}--@ 游戏逻辑主图层
local meta = GameRoleView

--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local GameRoleModel  = require "src/GameRole/GameRoleM"
local GameGuideModel = require "src/GameGuide/GameGuideM"
--require "src/leader/leader3"

function meta:init(leadupdate)
    meta.mainLayer = CCLayer:create()
    meta:createRole()
    meta:setUserData()
    if leadupdate == 1 then
        meta.attatkToRolePanel()
        cclog("asdfasdfasdfasdfasdf")
    end 
    statistics(1800)
    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    meta.labelAtlas_heroStrength:setString(g_userinfo.physical)
    meta.labelAtlas_heroGold:setString(g_userinfo.gold) 
    meta.labelAtlas_heroDiamond:setString(g_userinfo.diamond)
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createRole()
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_role.ExportJson")
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromBinaryFile("res/ui/game_guide/game_role.csb")
    --uiLayout:setPosition(g_origin.x,g_origin.y)
    meta.panel_role               = uiLayout:getChildByName("Panel_role")                    --角色界面
    meta.panel_upgrade            = uiLayout:getChildByName("Panel_upgrade")                 --升级界面
    meta.panel_advanced           = uiLayout:getChildByName("Panel_advanced")
    meta.panel_roleYes            = uiLayout:getChildByName("Panel_roleYes")                 --是否转钻石界面
    meta.panel_showSkill          = uiLayout:getChildByName("Panel_showSkill")
    --角色界面控件               
                                 
    local button_advanced         = meta.panel_role:getChildByName("Button_advanced")
    local button_back             = meta.panel_role:getChildByName("Button_back")
                                 
    local imageView_bgLevel       = meta.panel_role:getChildByName("ImageView_bgLevel")
    local imageView_bgBlood       = meta.panel_role:getChildByName("ImageView_bgBlood")
    local imageView_bgAttack      = meta.panel_role:getChildByName("ImageView_bgAttack")
    local imageView_bgCrit        = meta.panel_role:getChildByName("ImageView_bgCrit")
    meta.loadingBar_level         = imageView_bgLevel:getChildByName("LoadingBar_level")
    meta.loadingBar_blood         = imageView_bgBlood:getChildByName("LoadingBar_blood")
    meta.loadingBar_attack        = imageView_bgAttack:getChildByName("LoadingBar_attack")
    meta.loadingBar_crit          = imageView_bgCrit:getChildByName("LoadingBar_crit")
    meta.label_level              = imageView_bgLevel:getChildByName("Label_level")
    meta.label_blood              = imageView_bgBlood:getChildByName("Label_blood")
    meta.label_attack             = imageView_bgAttack:getChildByName("Label_attack")
    meta.label_crit               = imageView_bgCrit:getChildByName("Label_crit")
    local listView_hero           = meta.panel_role:getChildByName("ListView_hero") 
    local button_heroShow_1       = listView_hero:getChildByName("Button_heroShow_1")
    local button_heroShow_2       = listView_hero:getChildByName("Button_heroShow_2")
    local button_heroShow_3       = listView_hero:getChildByName("Button_heroShow_3")
    local button_heroShow_4       = listView_hero:getChildByName("Button_heroShow_4")
    local button_heroShow_5       = listView_hero:getChildByName("Button_heroShow_5")
    local button_heroShow_6       = listView_hero:getChildByName("Button_heroShow_6")
    local button_skillShow              = meta.panel_role:getChildByName("Button_skillShow")
    local image_heroZero          = meta.panel_role:getChildByName("Image_heroZero") 
    local image_heroZero_1        = meta.panel_role:getChildByName("Image_heroZero_1")
    local image_heroZero_2        = meta.panel_role:getChildByName("Image_heroZero_2")
    meta.button_roleBuy           = meta.panel_role:getChildByName("Button_roleBuy")
    meta.button_roleIsSeleced     = meta.panel_role:getChildByName("Button_roleIsSeleced")
    meta.button_upgrade           = meta.panel_role:getChildByName("Button_upgrade")
    meta.label_heroTitle          = meta.panel_role:getChildByName("Label_heroTitle")
    meta.image_roleMoneyType_1   = meta.button_roleBuy:getChildByName("Image_roleMoneyType_1")
    meta.image_roleMoneyType_2   = meta.button_roleBuy:getChildByName("Image_roleMoneyType_2")
    meta.atlasLabel_rolePrice    = meta.button_roleBuy:getChildByName("AtlasLabel_rolePrice")
    local imageView_heroStrength  = meta.panel_role:getChildByName("ImageView_heroStrength")
    local imageView_heroGold      = meta.panel_role:getChildByName("ImageView_heroGold")
    local imageView_heroDiamond   = meta.panel_role:getChildByName("ImageView_heroDiamond")
    meta.labelAtlas_heroStrength  = imageView_heroStrength:getChildByName("LabelAtlas_heroStrength")
    meta.labelAtlas_heroGold      = imageView_heroGold:getChildByName("LabelAtlas_heroGold")
    meta.labelAtlas_heroDiamond   = imageView_heroDiamond:getChildByName("LabelAtlas_heroDiamond")
    local button_heroStrength     = meta.panel_role:getChildByName("Button_heroStrength")
    local button_heroGold         = meta.panel_role:getChildByName("Button_heroGold")
    local button_heroDiamond      = meta.panel_role:getChildByName("Button_heroDiamond")

    local imageView_upgLevel   = meta.panel_upgrade:getChildByName("ImageView_upgLevel")
    local imageView_upgBlood   = meta.panel_upgrade:getChildByName("ImageView_upgBlood")
    local imageView_upgAttack  = meta.panel_upgrade:getChildByName("ImageView_upgAttack")
    local imageView_upgCrit    = meta.panel_upgrade:getChildByName("ImageView_upgCrit")
    meta.label_upgLevel       = imageView_upgLevel:getChildByName("Label_upgLevel")
    meta.label_upgBlood       = imageView_upgBlood:getChildByName("Label_upgBlood")
    meta.label_upgAttack      = imageView_upgAttack:getChildByName("Label_upgAttack")
    meta.label_upgCrit        = imageView_upgCrit:getChildByName("Label_upgCrit")
    meta.loadingBar_upgLevel  = imageView_upgLevel:getChildByName("LoadingBar_upgLevel")
    meta.loadingBar_upgBlood  = imageView_upgBlood:getChildByName("LoadingBar_upgBlood")
    meta.loadingBar_upgAttack = imageView_upgAttack:getChildByName("LoadingBar_upgAttack")
    meta.loadingBar_upgCrit   = imageView_upgCrit:getChildByName("LoadingBar_upgCrit")
    meta.button_upgBuy        = meta.panel_upgrade:getChildByName("Button_upgBuy")
    meta.atlasLabel_upgPrice  = meta.button_upgBuy:getChildByName("AtlasLabel_upgPrice")
    meta.label_upgJump        = meta.panel_upgrade:getChildByName("Label_upgJump")
    meta.image_moneyType_1    = meta.button_upgBuy:getChildByName("Image_moneyType_1")
    meta.image_moneyType_2    = meta.button_upgBuy:getChildByName("Image_moneyType_2")
    meta.label_jump            = meta.panel_role:getChildByName("Label_jump") 
    local panel_heroGreen      = meta.panel_role:getChildByName("Panel_heroGreen")
    meta.button_green[1]       = panel_heroGreen:getChildByName("Button_green_1")
    meta.button_green[2]       = panel_heroGreen:getChildByName("Button_green_2")
    meta.button_green[3]       = panel_heroGreen:getChildByName("Button_green_3")
    local panel_upgGreen       = meta.panel_upgrade:getChildByName("Panel_upgGreen")
    meta.button_upgGreen      = {}
    meta.button_upgGreen[1]   = panel_upgGreen:getChildByName("Button_upgGreen_1")
    meta.button_upgGreen[2]   = panel_upgGreen:getChildByName("Button_upgGreen_2")
    meta.button_upgGreen[3]   = panel_upgGreen:getChildByName("Button_upgGreen_3")
    meta.imageView_rolePro_1   = meta.panel_role:getChildByName("ImageView_rolePro_1")
    meta.imageView_rolePro_2   = meta.panel_role:getChildByName("ImageView_rolePro_2")
    meta.image_upgPro_1       = meta.panel_upgrade:getChildByName("Image_upgPro_1")
    meta.image_upgPro_2       = meta.panel_upgrade:getChildByName("Image_upgPro_2")
    local button_heroActivity  = meta.panel_role:getChildByName("Button_heroActivity")
    button_heroActivity:setLocalZOrder(5)
    local button_yes           = meta.panel_roleYes:getChildByName("Button_yes")
    local button_no            = meta.panel_roleYes:getChildByName("Button_no")
    meta.label_tips            = meta.panel_roleYes:getChildByName("Label_tips")
    local button_shoSkillBack  = meta.panel_showSkill:getChildByName("Button_shoSkillBack")
    local image_shoSkill       = meta.panel_showSkill:getChildByName("Image_shoSkill")
    
    

    ---[[添加发光效果
    local faguang = ccs.Armature:create("kaifuguang")
    faguang:getAnimation():play("run")
    faguang:setPosition(cc.p(880,597))
    faguang:setScale(0.8)
    meta.panel_role:addChild(faguang,1,1)
    --]]

    --魔法阵旋转
    local function bianse()
        local tintto_a1 = cc.TintTo:create(4,255,0,0)
        local tintto_a2 = cc.TintTo:create(2,255,128,0)
        local tintto_a3 = cc.TintTo:create(2,255,255,0)
        local tintto_a4 = cc.TintTo:create(4,0,255,0)
        local tintto_a5 = cc.TintTo:create(4,0,255,255)
        local tintto_a6 = cc.TintTo:create(4,0,0,255)
        local tintto_a7 = cc.TintTo:create(2,128,0,255)
        local tintto_a8 = cc.TintTo:create(4,0,0,0)

        local tintto_b1 = cc.TintTo:create(4,128,0,255)
        local tintto_b2 = cc.TintTo:create(2,0,0,255)
        local tintto_b3 = cc.TintTo:create(4,0,255,255)
        local tintto_b4 = cc.TintTo:create(4,0,255,0)
        local tintto_b5 = cc.TintTo:create(4,255,255,0)
        local tintto_b6 = cc.TintTo:create(2,255,128,0)
        local tintto_b7 = cc.TintTo:create(2,255,0,0)
        local tintto_b8 = cc.TintTo:create(4,255,255,255)
        local seq1    = cc.Sequence:create(tintto_a1,tintto_a2,tintto_a3,tintto_a4,tintto_a5,tintto_a6,tintto_a7,tintto_a8)
        local seq2    = cc.Sequence:create(tintto_b1,tintto_b2,tintto_b3,tintto_b4,tintto_b5,tintto_b6,tintto_b7,tintto_b8)
        local seq3    = cc.Sequence:create(seq1,seq2)
        --local roa = cc.RotateBy:create(52,2340)
        --local rep    = cc.RepeatForever:create(roa)
        --local seqever2 = cc.RepeatForever:create(seq3)
        return seq3
        --local spa     = cc.Spawn:create(seq3,roa)
        --return spa
    end 
    local bianse1 = bianse()
    local bianse2 = bianse()
    local bianse3 = bianse()
    local roa = cc.RotateBy:create(52,2340)
    local spawn1    = cc.Spawn:create(bianse1,roa)
    local repeat1   = cc.RepeatForever:create(spawn1)
    local repeat2    = cc.RepeatForever:create(bianse2)
    local repeat3    = cc.RepeatForever:create(bianse3)
    local roaa = cc.RepeatForever:create(roa)
    image_heroZero:runAction(roaa)
    --image_heroZero_1:runAction(repeat2)
    --image_heroZero_2:runAction(repeat3)

    ---[[初始化 动画  ，进度条
    meta.heroArmature = ccs.Armature:create(GameGuideModel.heroName[meta.readyMeta.curHeroIdx])
    meta.heroArmature:setScale(1.5)
    meta.heroArmature:getAnimation():play("wait")
    --self.curPlayName = "run"
    meta.heroArmature:setPosition(cc.p(440,310))
    meta.panel_role:addChild(meta.heroArmature,3)
    --将准备界面所选的英雄curMyHero  赋值给  英雄界面的curHero
    --meta.curHero   = meta.readyMeta.curMyHero
    meta.curHero   = GameGuideModel.curMyHero
    meta.curLevel  = tonumber(meta.curHero:getLevel())
    meta.curLife   = tonumber(meta.curHero:getFinallife())
    meta.curAttack = tonumber(meta.curHero:getFinalattack())
    meta.curCrit   = tonumber(meta.curHero:getCrit())
    meta.curJump   = meta.curHero:getJump()
    meta.curSymbol = Split(meta.curHero:getSymbol(),";")
    meta.curPro    = meta.curHero:getType()
    meta.max.life  = tonumber(meta.curHero:getMaxHp())
    meta.max.attack= tonumber(meta.curHero:getMaxAttack())
    for i =1 , # meta.curSymbol do 
        meta.button_green[i]:setTitleText(meta.curSymbol[i])
    end
    if #meta.curSymbol == 2 then 
        meta.button_green[3]:setVisible(false)
    else
        meta.button_green[3]:setVisible(true)
    end 
    if meta.curPro == "近" then 
        meta.imageView_rolePro_1:setVisible(true)
        meta.imageView_rolePro_2:setVisible(false)
    else
        meta.imageView_rolePro_1:setVisible(false)
        meta.imageView_rolePro_2:setVisible(true)
    end 
    meta.loadingBar_level:setPercent(math.floor(meta.curLevel / meta.max.level * 100)) 
    meta.loadingBar_blood:setPercent(math.floor(meta.curLife / meta.max.life*100))
    meta.loadingBar_attack:setPercent(math.floor(meta.curAttack / meta.max.attack*100))
    meta.loadingBar_crit:setPercent(math.floor(meta.curCrit / meta.max.crit*100))
    meta.label_level:setString("等级"..meta.curLevel.."/"..meta.max.level)
    meta.label_blood:setString("血量"..meta.curLife.."/"..meta.max.life)
    meta.label_attack:setString("攻击力"..meta.curAttack.."/"..meta.max.attack)
    meta.label_crit:setString("暴击率"..tostring(meta.curCrit*100).."%/"..tostring(meta.max.crit*100).."%")
    meta.label_jump:setString("跳跃模式:"..meta.curJump)
    meta.label_heroTitle:setString(meta.curHero:getName())
    for i = 1 , #meta.readyMeta.myHero do 
        if meta.curHero:getId() == meta.readyMeta.myHero[i]:getId() then 
            cclog("你有这个英雄")
            meta.button_upgrade:setVisible(true)
            meta.button_roleIsSeleced:setVisible(true)
            meta.button_roleIsSeleced:setTouchEnabled(false)
            meta.button_roleBuy:setVisible(false)
            break 
        else 
            if i == #meta.readyMeta.myHero then 
                cclog("你没有这个英雄")
                cclog(meta.max.life)
                meta.button_upgrade:setVisible(false)
                meta.button_roleIsSeleced:setVisible(false)
                meta.button_roleIsSeleced:setTouchEnabled(true)
                meta.button_roleBuy:setVisible(true)
                local curName = meta.curHero:getName()
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
        end 
    end 
    --]]


    --升级界面
    local button_upgBack      = meta.panel_upgrade:getChildByName("Button_upgBack")
    
    --进阶界面
    local button_advBack      = meta.panel_advanced:getChildByName("Button_advBack")

    --[[设置进度方法参考
    loadingBar_blood:setSize(cc.size(100,25))
    loadingBar_blood:setPercent(50)
    --]]
    --返回(释放)事件 
    local function backEvent(touch,eventType)
       if eventType == ccui.TouchEventType.began then 
           playEffect("res/music/effect/fight/get_item.ogg")
           cclog(touch:getName())
           meta:remove()
        end
       if eventType == ccui.TouchEventType.began then 
       end 
    end 

    --确定进入界面接口
    local function confirmEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
            if touch:getName() == "Button_yes" then 
                --进入购买钻石界面
                cclog("yes")
                cclog(meta.label_tips:getTag())
                if meta.label_tips:getTag() == 2 then 
                    meta.readyMeta.enterGold()
                    meta.panel_roleYes:setVisible(false)
                    meta.label_tips:setString("钻石不足，是否购买?")
                elseif  meta.label_tips:getTag() == 1 then 
                    meta.readyMeta.enterDiamond()
                    meta.panel_roleYes:setVisible(false)
                end 
                --meta:remove()
            else 
                cclog("no")
                meta.panel_roleYes:setVisible(false)
            end  
        end
        if eventType == ccui.TouchEventType.began then 
        end 
    end
    
    --角色到升级界面
    local function roleToUpgradeEvent(touch,eventType)
       if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
       end
       if eventType == ccui.TouchEventType.began then 
           meta.loadingBar_upgLevel:setPercent(math.floor(meta.curLevel / meta.max.level * 100)) 
           meta.loadingBar_upgBlood:setPercent(math.floor(meta.curLife / meta.max.life*100))
           meta.loadingBar_upgAttack:setPercent(math.floor(meta.curAttack / meta.max.attack*100))
           meta.loadingBar_upgCrit:setPercent(math.floor(meta.curCrit / meta.max.crit*100))
           meta.label_upgLevel:setString("等级"..meta.curLevel.."/"..meta.max.level)
           meta.label_upgBlood:setString("血量"..meta.curLife.."/"..meta.max.life)
           meta.label_upgAttack:setString("攻击力"..meta.curAttack.."/"..meta.max.attack)
           meta.label_upgCrit:setString("暴击率"..tostring(meta.curCrit*100).."%/"..tostring(meta.max.crit*100).."%")
           meta.label_upgJump:setString("跳跃模式:"..meta.curJump)
           for i =1 , # meta.curSymbol do 
               meta.button_upgGreen[i]:setTitleText(meta.curSymbol[i])
           end
           if #meta.curSymbol == 2 then 
               meta.button_upgGreen[3]:setVisible(false)
           else
               meta.button_upgGreen[3]:setVisible(true)
           end 
           if meta.curPro == "近" then 
                meta.image_upgPro_1:setVisible(true)
                meta.image_upgPro_2:setVisible(false)
            else
                meta.image_upgPro_1:setVisible(false)
                meta.image_upgPro_2:setVisible(true)
            end
           local heroname = meta.curHero:getName()
           local animatureName = nil
           if heroname == "提百万" then 
                animatureName = GameGuideModel.heroName[1]
           elseif heroname == "菊花信" then
                animatureName = GameGuideModel.heroName[2]
           elseif heroname == "探险家" then
                animatureName = GameGuideModel.heroName[3]
           elseif heroname == "狐狸" then 
                animatureName = GameGuideModel.heroName[4]
           elseif heroname == "草丛伦" then
                animatureName = GameGuideModel.heroName[5]
           elseif heroname == "剑圣" then
                animatureName = GameGuideModel.heroName[6]
           end 

           meta.upgradeAnimation = ccs.Armature:create(animatureName)
           meta.upgradeAnimation:setScale(1.5)
           meta.upgradeAnimation:getAnimation():play("wait")
           meta.upgradeAnimation:setPosition(cc.p(380,200))
           meta.upgradeAnimation:setLocalZOrder(3)
           meta.panel_upgrade:addChild(meta.upgradeAnimation)

           --meta.levelupAnimation = ccs.Armature:create("levelup")
           --meta.levelupAnimation:setPosition(cc.p(290,200))
           --meta.levelupAnimation:setLocalZOrder(4)
           --meta.panel_upgrade:addChild(meta.levelupAnimation)

           local limitConf = #g_conf.g_upgrade_conf 
           if   meta.curLevel  > limitConf - 2 then 
                meta.atlasLabel_upgPrice:setString("0")
           elseif  meta.curLevel > 60 then 
                meta.atlasLabel_upgPrice:setString(g_conf.g_upgrade_conf[meta.curLevel+1].upgrade_needNum)
                meta.image_moneyType_1:setVisible(true)
                meta.image_moneyType_2:setVisible(false)
                meta.upgradePayType  = "钻石"
           else 
                meta.atlasLabel_upgPrice:setString(g_conf.g_upgrade_conf[meta.curLevel+1].upgrade_needNum)
                meta.image_moneyType_1:setVisible(false)
                meta.image_moneyType_2:setVisible(true)
                meta.upgradePayType  = "金币"
           end 

           cclog(g_conf.g_upgrade_conf[1].upgrade_level)
           cclog(tostring(meta.curLevel+1))
           cclog(#g_conf.g_upgrade_conf)
           meta.panel_upgrade:setVisible(true)  
       end
    end 



    --升级返回到角色界面
    local function upgradeBackEvent(touch,eventType)
       if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
       if eventType == ccui.TouchEventType.began then 
           if meta.levelupAnimation ~= nil then 
              meta.levelupAnimation:removeFromParent()
              meta.levelupAnimation = nil
           end 
           meta.panel_role:setVisible(true)
           meta.panel_upgrade:setVisible(false)
           meta.upgradeAnimation:removeFromParent()     
       end
    end 

    --角色到进阶界面
    local function roleToAdvancedEvent(touch,eventType)
       if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
       end
       if eventType == ccui.TouchEventType.began then 
           meta.panel_role:setVisible(false)
           meta.panel_advanced:setVisible(true)     
       end
    end 

    --进阶返回到角色界面
    local function advancedBackEvent(touch,eventType)
       if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
       end
       if eventType == ccui.TouchEventType.began then 
           meta.panel_role:setVisible(true)
           meta.panel_advanced:setVisible(false)     
       end
    end 

    --展示英雄
    local function heroShowEvent(touch,eventType)
       if eventType == ccui.TouchEventType.began then 
           local name = touch:getName()
           local idMax  = 0
           local idMin  = 0
           local isBuy  = false
           local curNum = 0
           if name == "Button_heroShow_1" then 
               meta:replaceHeroArmatureEvent("Garen")
               playEffect("res/music/effect/role/garen/Garen_start.ogg")
               idMax = 100014
               idMin = 100008
           elseif name == "Button_heroShow_2" then 
               meta:replaceHeroArmatureEvent("Teemo")
                playEffect("res/music/effect/role/teemo/Teemo_start.ogg")
               idMax = 100007
               idMin = 100001
           elseif name == "Button_heroShow_3" then
               meta:replaceHeroArmatureEvent("zhaoxin")
               playEffect("res/music/effect/role/zhaoxin/zhaoxi_start.ogg")
               idMax = 100021
               idMin = 100015
           elseif name == "Button_heroShow_4" then
               meta:replaceHeroArmatureEvent("Ahri")
               playEffect("res/music/effect/role/ahri/Ahri_start.ogg")
               idMax = 100028
               idMin = 100022
           elseif name == "Button_heroShow_5" then
               meta:replaceHeroArmatureEvent("JS")
               playEffect("res/music/effect/role/js/JS_start.ogg")
               idMax = 100049
               idMin = 100043
           elseif name == "Button_heroShow_6" then
               meta:replaceHeroArmatureEvent("Ezreal")
               playEffect("res/music/effect/role/ez/Ezreal_start.ogg")
               idMax = 100042
               idMin = 100036
           end 
           for i = 1,  #meta.readyMeta.myHero do 
                local id = tonumber(meta.readyMeta.myHero[i]:getId())
                if  id <= idMax and id >= idMin then 
                    isBuy  = true 
                    curNum = i
                end 
           end 
           if isBuy then 
                 cclog("你拥有这个英雄")
                 meta.curHero   = meta.readyMeta.myHero[curNum]
                 meta.curLevel  = tonumber(meta.curHero:getLevel())
                 meta.curLife   = tonumber(meta.curHero:getFinallife())
                 meta.curAttack = tonumber(meta.curHero:getFinalattack())
                 meta.curCrit   = tonumber(meta.curHero:getCrit())
                 meta.curSymbol = Split(meta.curHero:getSymbol(),";")
                 meta.curJump   = meta.curHero:getJump()
                 meta.curPro    = meta.curHero:getType()
                 meta.max.life  = tonumber(meta.curHero:getMaxHp())
                 meta.max.attack= tonumber(meta.curHero:getMaxAttack())
                 meta.loadingBar_level:setPercent(math.floor(meta.curLevel / meta.max.level * 100)) 
                 meta.loadingBar_blood:setPercent(math.floor(meta.curLife / meta.max.life*100))
                 meta.loadingBar_attack:setPercent(math.floor(meta.curAttack / meta.max.attack*100))
                 meta.loadingBar_crit:setPercent(math.floor(meta.curCrit / meta.max.crit*100))
                 meta.label_level:setString("等级"..meta.curLevel.."/"..meta.max.level)
                 meta.label_blood:setString("血量"..meta.curLife.."/"..meta.max.life)
                 meta.label_attack:setString("攻击力"..meta.curAttack.."/"..meta.max.attack)
                 meta.label_crit:setString("暴击率"..tostring(meta.curCrit*100).."%/"..tostring(meta.max.crit*100).."%")
                 if meta.curPro == "近" then 
                    meta.imageView_rolePro_1:setVisible(true)
                    meta.imageView_rolePro_2:setVisible(false)
                else
                    meta.imageView_rolePro_1:setVisible(false)
                    meta.imageView_rolePro_2:setVisible(true)
                end 
                 for i =1 , # meta.curSymbol do 
                    meta.button_green[i]:setTitleText(meta.curSymbol[i])
                 end
                 if #meta.curSymbol == 2 then 
                     meta.button_green[3]:setVisible(false)
                 else
                     meta.button_green[3]:setVisible(true)
                 end 
                 meta.label_jump:setString(meta.curJump)
                 meta.button_upgrade:setVisible(true)
                 meta.button_roleIsSeleced:setVisible(true)
                 meta.button_roleIsSeleced:setTouchEnabled(false)
                 meta.button_roleBuy:setVisible(false)
                 meta.label_heroTitle:setString(meta.curHero:getName())
           else 
                 cclog(idMin)
                 meta.curHero = Hero:create(tostring(idMin+2),"1","0")
                 meta.curLevel  = tonumber(meta.curHero:getLevel())
                 meta.curLife   = tonumber(meta.curHero:getFinallife())
                 meta.curAttack = tonumber(meta.curHero:getFinalattack())
                 meta.curCrit   = tonumber(meta.curHero:getCrit())
                 meta.curSymbol = Split(meta.curHero:getSymbol(),";")
                 meta.curJump   = meta.curHero:getJump()
                 meta.curPro    = meta.curHero:getType()
                 meta.max.life  = tonumber(meta.curHero:getMaxHp())
                 meta.max.attack= tonumber(meta.curHero:getMaxAttack())
                 meta.loadingBar_level:setPercent(math.floor(meta.curLevel / meta.max.level * 100)) 
                 meta.loadingBar_blood:setPercent(math.floor(meta.curLife / meta.max.life*100))
                 meta.loadingBar_attack:setPercent(math.floor(meta.curAttack / meta.max.attack*100))
                 meta.loadingBar_crit:setPercent(math.floor(meta.curCrit / meta.max.crit*100))
                 meta.label_level:setString("等级"..meta.curLevel.."/"..meta.max.level)
                 meta.label_blood:setString("血量"..meta.curLife.."/"..meta.max.life)
                 meta.label_attack:setString("攻击力"..meta.curAttack.."/"..meta.max.attack)
                 meta.label_crit:setString("暴击率"..tostring(meta.curCrit*100).."%/"..tostring(meta.max.crit*100).."%")
                 if meta.curPro == "近" then 
                    meta.imageView_rolePro_1:setVisible(true)
                    meta.imageView_rolePro_2:setVisible(false)
                else
                    meta.imageView_rolePro_1:setVisible(false)
                    meta.imageView_rolePro_2:setVisible(true)
                end 
                 for i =1 , # meta.curSymbol do 
                    meta.button_green[i]:setTitleText(meta.curSymbol[i])
                 end
                 if #meta.curSymbol == 2 then 
                     meta.button_green[3]:setVisible(false)
                 else
                     meta.button_green[3]:setVisible(true)
                 end 
                 meta.label_jump:setString(meta.curJump)
                 meta.button_upgrade:setVisible(false)
                 meta.button_roleIsSeleced:setVisible(false)
                 meta.button_roleBuy:setVisible(true)
                 meta.label_heroTitle:setString(meta.curHero:getName())
                 local curName = meta.curHero:getName()
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
                 cclog("你没有这个英雄")
           end 
       end
    end 

    --展示技能
    local function skillShowEvent(touch,eventType)
       if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
       end
       if eventType == ccui.TouchEventType.began then 
            local function run()
                meta.heroArmature:getAnimation():play("wait")
            end
            local function runNextAction()
                meta.heroArmature:getAnimation():play("attack")
            end
            meta.heroArmature:stopAllActions()
            meta.heroArmature:runAction(cc.Sequence:create(cc.CallFunc:create(runNextAction),cc.DelayTime:create(0.5),cc.CallFunc:create(run)))
       end
    end 

    --英雄升级方法
    local function heroUpgradeEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.began then
            cclog(touch:getName())
            cclog(g_conf.g_upgrade_conf[1].upgrade_level)
            cclog(meta.curHero:getName())
            local function myUpgrade(msg)
                cclog(msg)
                local cjson = require "cjson"
                local temp_conf = cjson.decode(msg)
                if temp_conf.code == 1 then 
                    cclog("升级成功")
                    if  meta.levelupAnimation == nil  then 
                        meta.levelupAnimation = ccs.Armature:create("levelup")
                        meta.levelupAnimation:setPosition(cc.p(380,160))
                        meta.levelupAnimation:setLocalZOrder(4)
                        meta.panel_upgrade:addChild(meta.levelupAnimation)
                    end 
                    meta.levelupAnimation:getAnimation():play("run")
                    statistics(1801)
                    --if meta.upgradePayType == "钻石" then 
                    --    meta.addDiamond((0 - tonumber(atlasLabel_upgPrice:getString())))
                    --elseif meta.upgradePayType == "金币" then
                    --    meta.addGold((0 - tonumber(atlasLabel_upgPrice:getString())))
                    --end 
                    local cjson = require "cjson"
			        local temp_conf = cjson.decode(msg)
                    g_userinfo.gold =  temp_conf.member_info.member_gold
                    g_userinfo.diamond =  temp_conf.member_info.member_diamond
                    g_userinfo.physical =  temp_conf.member_info.member_physical
                    local tempHeroId = meta.curHero:getId() 
                    g_userinfo.heros = {}
                    for i=1,#temp_conf.hero_info do
                        g_userinfo.heros[i] = {}
                        g_userinfo.heros[i].level = temp_conf.hero_info[i].hero_level
                        g_userinfo.heros[i].id = temp_conf.hero_info[i].hero_hrid
                        if tonumber(g_userinfo.heros[i].id) == tonumber(tempHeroId) then 
                            --meta.readyMeta.curMyHero = Hero:create(tostring(g_userinfo.heros[i].id),tostring(g_userinfo.heros[i].level),"0")
                            --meta.curHero = meta.readyMeta.curMyHero
                            GameGuideModel.curMyHero = Hero:create(tostring(g_userinfo.heros[i].id),tostring(g_userinfo.heros[i].level),"0")
                            meta.curHero = GameGuideModel.curMyHero
                        end 
                    end

                    --主界面的UserData
                    meta.readyMeta.setUserData()
                    --英雄界面的UserData 
                    meta.setUserData()
                    meta.readyMeta.initHeroData()
                    

                    --for i = 1 ,#meta.readyMeta.myHero do  
                    --    if meta.curHero:getName() == meta.readyMeta.myHero[i]:getName() then 
                    --        --meta.curHero:upgrade()
                    --        meta.readyMeta.myHero[i]:upgrade()
                    --        print(meta.curHero:getLevel())
                    --        print(meta.readyMeta.myHero[i]:getLevel())
                    --        break
                    --    end  
                    --end 
                    --meta.readyMeta.setUserData()
                    

                    print(meta.curHero:getLevel())
                    meta.curLevel  = tonumber(meta.curHero:getLevel())
                    meta.curLife   = tonumber(meta.curHero:getFinallife())
                    meta.curAttack = tonumber(meta.curHero:getFinalattack())
                    meta.curCrit   = tonumber(meta.curHero:getCrit())
                    meta.loadingBar_upgLevel:setPercent(math.floor(meta.curLevel / meta.max.level * 100)) 
                    meta.loadingBar_upgBlood:setPercent(math.floor(meta.curLife / meta.max.life*100))
                    meta.loadingBar_upgAttack:setPercent(math.floor(meta.curAttack / meta.max.attack*100))
                    meta.loadingBar_upgCrit:setPercent(math.floor(meta.curCrit / meta.max.crit*100))
                    meta.label_upgLevel:setString("等级"..meta.curLevel.."/"..meta.max.level)
                    meta.label_upgBlood:setString("血量"..meta.curLife.."/"..meta.max.life)
                    meta.label_upgAttack:setString("攻击力"..meta.curAttack.."/"..meta.max.attack)
                    meta.label_upgCrit:setString("暴击率"..tostring(meta.curCrit*100).."%/"..tostring(meta.max.crit*100).."%")
                    meta.max.life  = tonumber(meta.curHero:getMaxHp())
                    meta.max.attack= tonumber(meta.curHero:getMaxAttack())
                    meta.loadingBar_level:setPercent(math.floor(meta.curLevel / meta.max.level * 100)) 
                    meta.loadingBar_blood:setPercent(math.floor(meta.curLife / meta.max.life*100))
                    meta.loadingBar_attack:setPercent(math.floor(meta.curAttack / meta.max.attack*100))
                    meta.loadingBar_crit:setPercent(math.floor(meta.curCrit / meta.max.crit*100))
                    meta.label_level:setString("等级"..meta.curLevel.."/"..meta.max.level)
                    meta.label_blood:setString("血量"..meta.curLife.."/"..meta.max.life)
                    meta.label_attack:setString("攻击力"..meta.curAttack.."/"..meta.max.attack)
                    meta.label_crit:setString("暴击率"..tostring(meta.curCrit*100).."%/"..tostring(meta.max.crit*100).."%")
                    local limitConf = #g_conf.g_upgrade_conf 
                   if   meta.curLevel  > limitConf - 2 then 
                        meta.atlasLabel_upgPrice:setString("0")
                   elseif  meta.curLevel > 60 then 
                        if curLevel == 75 then 
                            meta.atlasLabel_upgPrice:setString("0")
                        else 
                            meta.atlasLabel_upgPrice:setString(g_conf.g_upgrade_conf[meta.curLevel+1].upgrade_needNum)
                        end 
                        meta.image_moneyType_1:setVisible(true)
                        meta.image_moneyType_2:setVisible(false)
                   elseif meta.curLevel  <= 60 then  
                        meta.atlasLabel_upgPrice:setString(g_conf.g_upgrade_conf[meta.curLevel+1].upgrade_needNum)
                        meta.image_moneyType_1:setVisible(false)
                        meta.image_moneyType_2:setVisible(true)
                   end
                else
                    if meta.image_moneyType_1:isVisible()  then 
                        meta.label_tips:setString("钻石不足，是否购买?")
                        meta.label_tips:setTag(1)
                    else 
                        meta.label_tips:setString("金币不足，是否购买?")
                        meta.label_tips:setTag(2)
                    end  
                    meta.panel_roleYes:setVisible(true)
                    print("升级失败") 
                end
                 
            end 
            --http://www.v5fz.com/api/experience.php?act=up_hero&uid=800000001&uname=i1603275411&sid=1&hid=100001&level=2
            print(meta.curHero:getId())
            local requrl = g_url.up_hero.."&uid=".. g_userinfo.uid .."&uname=".. g_userinfo.uname .."&sid=".. g_userinfo.sid .. "&hid=" .. meta.curHero:getId()
            --小于75级才请求服务器
            if tonumber(meta.curHero:getLevel()) < meta.max.level then 
                Func_HttpRequest(requrl,"",myUpgrade,false)
            end 
        end
    end 

    --购买英雄方法
    local function heroBuyEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.began then
            print(touch:getName())
            print(meta.curHero:getId())
            local function myBuyHero(msg) 
                local cjson = require "cjson"
                local temp_conf = cjson.decode(msg)
                if temp_conf.code == 1 or temp_conf.code == "1" then 
                    print("购买成功")
                    g_userinfo.gold =  temp_conf.member_info.member_gold
                    g_userinfo.diamond =  temp_conf.member_info.member_diamond
                    g_userinfo.physical =  temp_conf.member_info.member_physical
                    local tempHeroId = meta.curHero:getId() 
                    g_userinfo.heros = {}
                    for i=1,#temp_conf.hero_info do
                        g_userinfo.heros[i] = {}
                        g_userinfo.heros[i].level = temp_conf.hero_info[i].hero_level
                        g_userinfo.heros[i].id = temp_conf.hero_info[i].hero_hrid
                    end
                    meta.curHero = Hero:create(tostring(meta.curHero:getId()),"1","0")
                    meta.readyMeta.myHero[#meta.readyMeta.myHero + 1] = meta.curHero
                    --主界面的UserData
                    meta.readyMeta.setUserData()
                    --英雄界面的UserData 
                    meta.setUserData()
                    meta.readyMeta.initHeroData()
                    meta.button_upgrade:setVisible(true)
                    meta.button_roleIsSeleced:setVisible(true)
                    meta.button_roleIsSeleced:setTouchEnabled(false)
                    meta.button_roleBuy:setVisible(false)
                    meta.readyMeta:setUserData()
                else 
                    print(msg)
                    meta.label_tips:setTag(1)
                    meta.panel_roleYes:setVisible(true)
                end 
            end 
            local requrl = g_url.exchange_hero.."&uid=".. g_userinfo.uid .."&uname=".. g_userinfo.uname .."&sid=".. g_userinfo.sid .."&hid="..meta.curHero:getId()
            print("我要购买英雄的ID",tostring(meta.curHero:getId()))
            Func_HttpRequest(requrl,"",myBuyHero)
        end 
    end 

    local function toBuyEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end 
        if eventType == ccui.TouchEventType.began then
            local touchName = touch:getName()
            if touchName == "Button_heroGold" then 
                print("buyGold")
                meta.readyMeta.enterGold()
            elseif touchName == "Button_heroDiamond"  then 
                print("buyDiamond")
                meta.readyMeta.enterDiamond()
            elseif touchName == "Button_heroStrength" then 
                print("buyStrength")
                meta.readyMeta.enterStrength()
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

    local function toShowSkillEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.began then
            meta.panel_showSkill:setVisible(true)
            --meta.shoSkillAnimation1 ccs.Armature:create("kaifuguang")
           local heroname = meta.curHero:getName()
           local animatureName = nil
           local bgName        = nil
           if heroname == "提百万" then 
                animatureName = GameGuideModel.heroName[1]
                bgName        = GameRoleModel.skillBg[1]
           elseif heroname == "菊花信" then
                animatureName = GameGuideModel.heroName[2]
                bgName        = GameRoleModel.skillBg[2]
           elseif heroname == "探险家" then
                animatureName = GameGuideModel.heroName[3]
                bgName        = GameRoleModel.skillBg[3]
           elseif heroname == "狐狸" then 
                animatureName = GameGuideModel.heroName[4]
                bgName        = GameRoleModel.skillBg[4]
           elseif heroname == "草丛伦" then
                animatureName = GameGuideModel.heroName[5]
                bgName        = GameRoleModel.skillBg[5]
           elseif heroname == "剑圣" then
                animatureName = GameGuideModel.heroName[6]
                bgName        = GameRoleModel.skillBg[6]
           end 
           --cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/game_role/skillshowbg.plist","res/ui/game_role/skillshowbg.png")
           image_shoSkill:loadTexture(bgName,ccui.TextureResType.plistType)
           if heroname ~= "草丛伦" then 
               meta.shoSkillAnimation1 = ccs.Armature:create(animatureName)
               meta.shoSkillAnimation1:setPosition(cc.p(480,320))
               meta.shoSkillAnimation1:getAnimation():play("chongci")
               meta.shoSkillAnimation2 = ccs.Armature:create("chonci")
               meta.shoSkillAnimation2:getAnimation():play("run")
               meta.shoSkillAnimation2:setPosition(cc.p(480,320))
               meta.panel_showSkill:addChild(meta.shoSkillAnimation1,99,1)
               meta.panel_showSkill:addChild(meta.shoSkillAnimation2,100,1)
           end 
        end
    end 

    local function skoSkillBackEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            playEffect("res/music/effect/fight/get_item.ogg")
        end
        if eventType == ccui.TouchEventType.began then
            if meta.shoSkillAnimation1 ~= nil and meta.shoSkillAnimation2 ~= nil then 
                meta.shoSkillAnimation1:removeFromParent()
                meta.shoSkillAnimation2:removeFromParent() 
                meta.shoSkillAnimation1 = nil
                meta.shoSkillAnimation2 = nil 
            end 
            meta.panel_showSkill:setVisible(false)
        end
    end 



    --添加监听
    button_back:addTouchEventListener(backEvent)
    meta.button_upgrade:addTouchEventListener(roleToUpgradeEvent)
    button_upgBack:addTouchEventListener(upgradeBackEvent)
    button_advanced:addTouchEventListener(roleToAdvancedEvent)
    button_advBack:addTouchEventListener(advancedBackEvent)
    button_heroShow_1:addTouchEventListener(heroShowEvent)
    button_heroShow_2:addTouchEventListener(heroShowEvent)
    button_heroShow_3:addTouchEventListener(heroShowEvent)
    button_heroShow_4:addTouchEventListener(heroShowEvent)
    button_heroShow_5:addTouchEventListener(heroShowEvent)
    button_heroShow_6:addTouchEventListener(heroShowEvent)
    button_skillShow:addTouchEventListener(toShowSkillEvent)
    meta.button_upgBuy:addTouchEventListener(heroUpgradeEvent)
    meta.button_roleBuy:addTouchEventListener(heroBuyEvent)
    button_heroStrength:addTouchEventListener(toBuyEvent)
    button_heroGold:addTouchEventListener(toBuyEvent)
    button_heroDiamond:addTouchEventListener(toBuyEvent)
    button_heroActivity:addTouchEventListener(toActivityEvent)
    button_yes:addTouchEventListener(confirmEvent)
    button_no:addTouchEventListener(confirmEvent)
    button_shoSkillBack:addTouchEventListener(skoSkillBackEvent)
    meta.mainLayer:addChild(uiLayout)
end 

--替换英雄动画
function meta:replaceHeroArmatureEvent(heroname)
    meta.heroArmature:removeFromParent()
    meta.heroArmature = ccs.Armature:create(heroname)
    meta.heroArmature:setScale(1.5)
    meta.heroArmature:getAnimation():play("wait")
    meta.heroArmature:setPosition(cc.p(440,310))
    meta.panel_role:addChild(meta.heroArmature,3)
end 

--换数据
function meta:changeData(name)
    
end 

--删除 主图层 函数
function meta:remove()
    --if g_userinfo.leader == LEADER_ENUM.leader3 then 
    --    --进行无尽模式引导
    --    meta.readyMeta.leaderEndless()
    --end 
    meta.readyMeta:setResetPrice()
    meta.readyMeta:setRoleFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

--增加钻石值 
function meta.addDiamond(addDiamondNum)
    meta.readyMeta.addDiamond(addDiamondNum)
    meta.labelAtlas_heroDiamond:setString(meta.readyMeta.myDiamond)
end 

--增加金币值
function meta.addGold(addGoldNum)
    meta.readyMeta.addGold(addGoldNum)
    meta.labelAtlas_heroGold:setString(meta.readyMeta.myGold)
end 

--增加体力值
function meta.addStrength(addStrengthNum)
    meta.readyMeta.addStrength(addStrengthNum)
    meta.labelAtlas_heroStrength:setString(meta.readyMeta.myStrength)
end 

--设置钻石值
function meta.setDiamond()
    meta.labelAtlas_heroDiamond:setString(g_userinfo.diamond)
end 

--设置金币值
function meta.setGold()
    meta.labelAtlas_heroGold:setString(g_userinfo.gold)
end

--设置体力值
function meta.setStrength()
    meta.labelAtlas_heroStrength:setString(g_userinfo.physical)
end

function meta:attatkToRolePanel()
    meta.curHero   = GameGuideModel.curMyHero
    meta.curLevel  = tonumber(meta.curHero:getLevel())
    meta.curLife   = tonumber(meta.curHero:getFinallife())
    meta.curAttack = tonumber(meta.curHero:getFinalattack())
    meta.curCrit   = tonumber(meta.curHero:getCrit())
    meta.curJump   = meta.curHero:getJump()
    meta.curSymbol = Split(meta.curHero:getSymbol(),";")
    meta.curPro    = meta.curHero:getType()
    meta.max.life  = tonumber(meta.curHero:getMaxHp())
    meta.max.attack= tonumber(meta.curHero:getMaxAttack())
    for i =1 , # meta.curSymbol do 
        meta.button_green[i]:setTitleText(meta.curSymbol[i])
    end
    if #meta.curSymbol == 2 then 
        meta.button_green[3]:setVisible(false)
    else
        meta.button_green[3]:setVisible(true)
    end 
    if meta.curPro == "近" then 
        meta.imageView_rolePro_1:setVisible(true)
        meta.imageView_rolePro_2:setVisible(false)
    else
        meta.imageView_rolePro_1:setVisible(false)
        meta.imageView_rolePro_2:setVisible(true)
    end 
    meta.loadingBar_upgLevel:setPercent(math.floor(meta.curLevel / meta.max.level * 100)) 
    meta.loadingBar_upgBlood:setPercent(math.floor(meta.curLife / meta.max.life*100))
    meta.loadingBar_upgAttack:setPercent(math.floor(meta.curAttack / meta.max.attack*100))
    meta.loadingBar_upgCrit:setPercent(math.floor(meta.curCrit / meta.max.crit*100))
    meta.label_upgLevel:setString("等级"..meta.curLevel.."/"..meta.max.level)
    meta.label_upgBlood:setString("血量"..meta.curLife.."/"..meta.max.life)
    meta.label_upgAttack:setString("攻击力"..meta.curAttack.."/"..meta.max.attack)
    meta.label_upgCrit:setString("暴击率"..tostring(meta.curCrit*100).."%/"..tostring(meta.max.crit*100).."%")
    meta.label_upgJump:setString("跳跃模式:"..meta.curJump)
    for i =1 , # meta.curSymbol do 
        meta.button_upgGreen[i]:setTitleText(meta.curSymbol[i])
    end
    if #meta.curSymbol == 2 then 
        meta.button_upgGreen[3]:setVisible(false)
    else
        meta.button_upgGreen[3]:setVisible(true)
    end 
    if meta.curPro == "近" then 
        meta.image_upgPro_1:setVisible(true)
        meta.image_upgPro_2:setVisible(false)
    else
        meta.image_upgPro_1:setVisible(false)
        meta.image_upgPro_2:setVisible(true)
    end
    local heroname = meta.curHero:getName()
    local animatureName = nil
    if heroname == "提百万" then 
        animatureName = GameGuideModel.heroName[1]
    elseif heroname == "菊花信" then
        animatureName = GameGuideModel.heroName[2]
    elseif heroname == "探险家" then
        animatureName = GameGuideModel.heroName[3]
    elseif heroname == "狐狸" then 
        animatureName = GameGuideModel.heroName[4]
    elseif heroname == "草丛伦" then
        animatureName = GameGuideModel.heroName[5]
    elseif heroname == "剑圣" then
        animatureName = GameGuideModel.heroName[6]
    end 

    meta.upgradeAnimation = ccs.Armature:create(animatureName)
    meta.upgradeAnimation:setScale(1.5)
    meta.upgradeAnimation:getAnimation():play("wait")
    meta.upgradeAnimation:setPosition(cc.p(380,200))
    meta.panel_upgrade:addChild(meta.upgradeAnimation,3)

    local limitConf = #g_conf.g_upgrade_conf 
    if   meta.curLevel  > limitConf - 2 then 
        meta.atlasLabel_upgPrice:setString("0")
    elseif  meta.curLevel > 60 then 
        meta.atlasLabel_upgPrice:setString(g_conf.g_upgrade_conf[meta.curLevel+1].upgrade_needNum)
        meta.image_moneyType_1:setVisible(true)
        meta.image_moneyType_2:setVisible(false)
        meta.upgradePayType  = "钻石"
    else 
        meta.atlasLabel_upgPrice:setString(g_conf.g_upgrade_conf[meta.curLevel+1].upgrade_needNum)
        meta.image_moneyType_1:setVisible(false)
        meta.image_moneyType_2:setVisible(true)
        meta.upgradePayType  = "金币"
    end 
    print(g_conf.g_upgrade_conf[1].upgrade_level)
    print(tostring(meta.curLevel+1))
    print(#g_conf.g_upgrade_conf)
    meta.panel_upgrade:setVisible(true) 
end 



return GameRoleView
