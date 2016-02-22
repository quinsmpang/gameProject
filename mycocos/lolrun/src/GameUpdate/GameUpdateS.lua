

local GameUpdateS = 
{
   mainScene = nil;
   loaded = nil;
   size = nil;
   progress = nil;
   --------------------
   musicSchdl = nil;
   musicCount = 1;
   --------------------
   configSchdl = nil;
   configCount = 1;
   --------------------
   musicSchdl_finish_mark = nil;    --如果配置音乐文件预加载加载完成就会设置为true，否则，false
   configSchdl_finish_mark  = nil;  --如果配置文件加载完成就会设置为true，否则，false
}--@ 开始场景
local meta = GameUpdateS


--引用和全局，初始化----------------------------------------------------------------------------------
local cjson = require "cjson"
local gameUpdateV = require "src/GameUpdate/GameUpdateV"
local scheduler = cc.Director:getInstance():getScheduler()
function meta:init(scene)
    self.mainScene = scene
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local versionUrl = gameUpdateV:getNewestVersionUrl()
    xhr:open("POST", versionUrl)
    local function receiveNewestVersion()
        if string.find(xhr.statusText,"OK") then 
            local newestVersion   = xhr.response
            local curVersion = gameUpdateV:getCurVersion()
            newestVersion = tonumber(newestVersion)
            curVersion = tonumber(curVersion)
            if curVersion ~= newestVersion then 
                --更新
                gameUpdateV:gotoUpdate(self.mainScene)
            end
        end
    end

    xhr:registerScriptHandler(receiveNewestVersion)
    xhr:send()
end

function meta:loadUiRes()
    local scene = cc.Director:getInstance():getRunningScene()
    --loading
    cclog("loading...")
    local progressBg = cc.Sprite:createWithSpriteFrameName("duqu_jindutiao_01.png")
    progressBg:setPosition(cc.p(443,48))
    scene:addChild(progressBg)
    self.progress = gameUpdateV:createProgress()
    --self.progress:setPercentage(100)

    scene:addChild(self.progress)
    local gameLoadM = require "src/GameLoad/GameLoadM"
    local ExportJson = gameLoadM.ui.ExportJson
    local plistAndPng = gameLoadM.ui.plistAndPng

    self.loaded = 0
    self.size = #ExportJson

    for i = 1,#plistAndPng do 
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistAndPng[i][1],plistAndPng[i][2])
    end
    for i = 1,#ExportJson do 
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(ExportJson[i],meta.loading)
    end

    --音效定时器
    meta.musicSchdl = scheduler:scheduleScriptFunc(meta.preLoadMusic, 1/10, false)
    meta.musicSchdl_finish_mark = false
    --开始配置定时器
    meta.configSchdl = scheduler:scheduleScriptFunc(meta.ReadLuaFile, 1/10, false)
    meta.configSchdl_finish_mark = false
    --开启loadbackground定时器
end

--新手引导使用
--只初始化 g_config 和 预加载music
function meta:updata_config_and_music()
    --音效定时器
    meta.musicSchdl = scheduler:scheduleScriptFunc(meta.preLoadMusic, 1/10, false)
    --开始配置定时器
    meta.configSchdl = scheduler:scheduleScriptFunc(meta.ReadLuaFile, 1/10, false)
end

--判断是否把配置文件，和音乐都加载完成
function meta.sche_changScene()
    local tmp_sche = nil
    local function isFinish()
        if meta.musicSchdl_finish_mark and meta.configSchdl_finish_mark then 
            scheduler:unscheduleScriptEntry(tmp_sche)
            meta.changScene()
        end
    end
    tmp_sche = scheduler:scheduleScriptFunc(isFinish, 1/60, false)
end


function meta.loading(precent)
    meta.loaded = meta.loaded + 1
    local pre = 100 * (meta.loaded / meta.size )
    local action = cc.ProgressTo:create(3, pre)
    if meta.loaded == meta.size then
        --meta.progress:runAction(cc.Sequence:create(action,
        --                                            cc.CallFunc:create(meta.changScene)))
        meta.progress:runAction(action)
        meta.sche_changScene()  --判断是否把配置文件，和音乐都加载完成，完成才进入下一个场景
    else
        meta.progress:runAction(action)
    end

end

function meta.changScene()
    if g_userinfo.leader == 0 then
        cclog("开始新手引导")
        ---[[新手引导1
        local scene = cc.Director:getInstance():getRunningScene()
        local leader = require "src/leader/leader1/leader1"
        local leader_layer = leader:create()
        scene:addChild(leader_layer,100000)
                
        --初始化角色数据赋值与选择模式
        local RoleModel = require "src/Role/RoleM"
        require "src/Hero/Hero"
        local hero = Hero:create(g_userinfo.heros[1].id,g_userinfo.heros[1].level,0)

        RoleModel:SetFightRole(hero)
    else
        local changeScene = require "src/GameGuide/GameGuideScene"
        --SimpleAudioEngine:getInstance():playMusic("res/music/sound/music001xzjm.mp3",true)
        SimpleAudioEngine:getInstance():playMusic("res/music/sound/bgmusic.ogg",true)
        if cc.Director:getInstance():getRunningScene() then
		    cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,changeScene:init()))
	    else
            cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,changeScene:init()))
	    end

    end
end
--------------------------配置文件(命名规则:g_文件_conf)-------------------------
local config = 
{
    "res/config/startconf.json";
    "res/config/gameconf.json";    --game
    "res/config/roleconf.json";    --role
    "res/config/heroconf.json";    --hero
    "res/config/heroskillconf.json";    --heroskill
    "res/config/equipconf.json";    --equip
    "res/config/spriteconf.json";    --sprite小伙伴
    "res/config/bossconf.json";    --boss
    "res/config/experienceconf.json";    --experience
    "res/config/consumerconf.json";    --consumer
    "res/config/gameshop.json";    --shop
    "res/config/monsterconf.json";    --monster
    --"res/config/versionconf.json";    --version
    "res/config/upgradeconf.json";
    "res/config/wjconf.json";--无尽模式
    "res/config/goldMapcof.json";--奖励模式
    "res/config/leaderconf.json";--新手引导地图
    
    
}
local confName = {
    "g_start_conf";
    "g_game_conf";
    "g_role_conf";
    "g_hero_conf";
    "g_heroskill_conf";
    "g_equip_conf";
    "g_sprite_conf";
    "g_boss_conf";
    "g_experience_conf";
    "g_consumer_conf";
    "g_shop_conf";
    "g_monster_conf";
    --"g_version"; -- 这个json会在main开始的时候初始化
    "g_upgrade_conf";
    "g_wj_conf";
    "g_jl_conf";
    "g_leader_conf";
}

function SaveTableContent(file, obj)
      local szType = type(obj);
      print(szType);
      if szType == "number" then
            file:write(obj);
      elseif szType == "string" then
            file:write(string.format("%q", obj));
      elseif szType == "table" then
            --把table的内容格式化写入文件
            file:write("{\n");
            for i, v in pairs(obj) do
                  file:write("[");
                  SaveTableContent(file, i);
                  file:write("]=");
                  SaveTableContent(file, v);
                  file:write(", \n");
             end
            file:write("}\n");
      else
      error("can't serialize a "..szType);
      end
end


function SaveTable(obj,filename)
      local file = io.open(filename, "w");
      --assert(file);
      file:write("local data = \n");
      --file:write("cha[1] = \n");
      SaveTableContent(file, obj);
      file:write("return data\n");
      file:close();
end

function meta.ReadLuaFile()--配置文件读取方法
    
  
    --local rconf = cc.FileUtils:getInstance():getStringFromFile(config[meta.configCount])
    --rconf = rever_dec(rconf)
    --g_conf[confName[meta.configCount]] = cjson.decode(rconf)
    --SaveTable(g_conf[confName[meta.configCount]],"D:\\conf\\" .. confName[meta.configCount] .. ".lua")
    local confile = "src/config/" .. confName[meta.configCount] .. ".lua"
    g_conf[confName[meta.configCount]] = require(confile)
    if meta.configCount >= #config then 
        meta.configCount = 1
        meta.configSchdl_finish_mark = true
        meta:initBackground()
        scheduler:unscheduleScriptEntry(meta.configSchdl)
    end
    meta.configCount = meta.configCount + 1



    

    --[[
    --local rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/startconf.json")
    ----rconf = rever_dec(rconf)
    --g_start_conf = cjson.decode(rconf)

    ----game
    --rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/gameconf.json")
    ----rconf = rever_dec(rconf)
    --g_game_conf = cjson.decode(rconf)
    
    ----role
    --rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/roleconf.json")
    ----rconf = rever_dec(rconf)
    --g_role_conf = cjson.decode(rconf)
    ----print(data)

    ----hero
    --rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/heroconf.json")
    ----rconf = rever_dec(rconf)
    --g_hero_conf = cjson.decode(rconf)

    ----heroskill
    --rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/heroskillconf.json")
    ----rconf = rever_dec(rconf)
    --g_heroskill_conf = cjson.decode(rconf)
    
    ----equip
    -- rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/equipconf.json")
    -- --rconf = rever_dec(rconf)
    --g_equip_conf = cjson.decode(rconf)

    ----sprite小伙伴
    -- rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/spriteconf.json")
    -- --rconf = rever_dec(rconf)
    --g_sprite_conf = cjson.decode(rconf)

    ----boss
    -- rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/bossconf.json")
    -- --rconf = rever_dec(rconf)
    --g_boss_conf = cjson.decode(rconf)

    ----experience
    -- rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/experienceconf.json")
    -- --rconf = rever_dec(rconf)
    --g_experience_conf = cjson.decode(rconf)

    ----consumer
    --rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/consumerconf.json")
    ----rconf = rever_dec(rconf)
    --g_consumer_conf = cjson.decode(rconf)

    ----shop
    --rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/gameshop.json")
    ----rconf = rever_dec(rconf)
    --g_shop_conf = cjson.decode(rconf)

    ----monster
    --rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/monsterconf.json")
    ----rconf = rever_dec(rconf)
    --g_monster_conf = cjson.decode(rconf)

    ----version
    --rconf = cc.FileUtils:getInstance():getStringFromFile("res/config/versionconf.json")
    ----rconf = rever_dec(rconf)
    --g_version = cjson.decode(rconf)
    --]]

end
local musicPath = {
    music = {
        "res/music/sound/music001xzjm.mp3";--ui界面
        "res/music/sound/music002zdjm.mp3";--战斗界面
        "res/music/sound/bgmusic.ogg";--战斗界面
        "res/music/effect/fight/endless.ogg";--无尽背景音乐
    };
    effect = {
        --"res/music/effect/sound001jump.ogg";--跳跃
        --"res/music/effect/sound002button.ogg";--按钮
        --"res/music/effect/sound003gold.ogg";
        --"res/music/effect/sound004countdown.ogg";
        --"res/music/effect/sound005map_change_chapter.mp3";--倒计时
        --"res/music/effect/sound006battle_win.mp3";--胜利
        --"res/music/effect/sound007battle_lose.mp3";--失败aa
        "res/music/effect/fight/get_item.ogg";--获取道具
        "res/music/effect/fight/get_box.ogg";--爆箱
        "res/music/effect/role/jump.ogg";--1跳
        "res/music/effect/role/jump2.ogg";--2跳 3 4 ...
        "res/music/effect/ui/selected.ogg";--确定按钮
        "res/music/effect/fight/shield_dis.ogg";--护盾消失
        "res/music/effect/btn_click.ogg";--所有按钮的点击
        
        --ahri
        "res/music/effect/role/ahri/Ahri_atchit.ogg";--击中
        "res/music/effect/role/ahri/Ahri_attack.ogg";--攻击
        "res/music/effect/role/ahri/Ahri_skill.ogg";--技能
        "res/music/effect/role/ahri/Ahri_start.ogg";--开场
        --ez
        "res/music/effect/role/ez/Ezreal_atchit.ogg";--击中
        "res/music/effect/role/ez/Ezreal_attack.ogg";--攻击
        "res/music/effect/role/ez/Ezreal_skill.ogg";--技能
        "res/music/effect/role/ez/Ezreal_start.ogg";--开场
        --garen
        "res/music/effect/role/garen/Garen_atchit.ogg";--击中
        "res/music/effect/role/garen/Garen_attack.ogg";--攻击
        "res/music/effect/role/garen/Garen_skill.ogg";--技能
        "res/music/effect/role/garen/Garen_start.ogg";--开场
        --js
        "res/music/effect/role/js/JS_atchit.ogg";--击中
        "res/music/effect/role/js/JS_attack.ogg";--攻击
        "res/music/effect/role/js/JS_skill.ogg";--技能
        "res/music/effect/role/js/JS_start.ogg";--开场
        --teemo
        "res/music/effect/role/teemo/Teemo_atchit.ogg";--击中
        "res/music/effect/role/teemo/Teemo_attack.ogg";--攻击
        "res/music/effect/role/teemo/Teemo_start.ogg";--开场
        --zhaoxin
        "res/music/effect/role/zhaoxin/zhaoxi_atchit.ogg";--击中
        "res/music/effect/role/zhaoxin/zhaoxi_attack.ogg";--攻击
        "res/music/effect/role/zhaoxin/zhaoxi_skill.ogg";--技能
        "res/music/effect/role/zhaoxin/zhaoxi_start.ogg";--开场
        --fight
        "res/music/effect/fight/gold.ogg";--金币
        "res/music/effect/fight/i_rush.ogg";--冲刺
        "res/music/effect/fight/jelly.ogg";--动物头象
        "res/music/effect/fight/r_spring.ogg";--弹簧
        "res/music/effect/fight/result.ogg";--结算
        --ui
        "res/music/effect/ui/level_up.ogg";--升级
        "res/music/effect/ui/shoping.ogg";--购买成功

    };
}
function meta.preLoadMusic()
    if meta.musicCount <= #musicPath.music then 
        SimpleAudioEngine:getInstance():preloadMusic(musicPath.music[meta.musicCount])
    else
        SimpleAudioEngine:getInstance():preloadEffect(musicPath.effect[meta.musicCount - #musicPath.music])
    end

    if meta.musicCount == #musicPath.music + #musicPath.effect then 
        meta.musicCount = 1
        meta.musicSchdl_finish_mark = true
        scheduler:unscheduleScriptEntry(meta.musicSchdl)
    end
    meta.musicCount = meta.musicCount + 1
end

function meta:initBackground()
    --先加载confi在运行这个
    local GameModel = require "src/GameScene/GameM"
    GameModel:LoadBackground()
end

return GameUpdateS

