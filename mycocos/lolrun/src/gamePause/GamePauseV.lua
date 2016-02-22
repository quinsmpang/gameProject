local GamePauseView = 
{
    mainLayer = nil;
}

local  meta = GamePauseView

local PriorityLayer = require "src/common/priorityLayer"
setmetatable(meta,PriorityLayer)--设置类型是RoleBase
meta.__index = meta--表设定为自身

--local GamePauseModel = require "src/gamePause/GamePauseM"
local UILayoutButton = require "src/tool/UILayoutButton"
local GameView = require "src/GameScene/GameV"
local GameSceneUi = require "src/GameScene/GameSceneUi"
function meta:init( ... )
    local self = {}
    self = PriorityLayer:initEx()
    setmetatable(self,meta)
    --self.mainLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 155), g_visibleSize.width, g_visibleSize.height) --全屏
    
    self:createMenu()

    --g_isPause = true
    
    -- 监听触摸事件
    --local listener = cc.EventListenerTouchOneByOne:create()
    --listener:setSwallowTouches(true)--阻止消息往下传递
    --local eventDispatcher = self.mainLayer:getEventDispatcher()
    --eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.mainLayer)

    return self
end
--释放
function meta:release()
    self.mainLayer:removeFromParent(true)
end
function meta:createMenu()
    
    --背景框
    local background = cc.Scale9Sprite:create("res/ui/gameIn/pause/tanchukuang_2.png")
    background:setCapInsets(cc.rect(40,65,5,5))
    background:setContentSize(cc.size(470,395))
    background:setPosition(g_visibleSize.width/2,g_visibleSize.height/2)
    self.mainLayer:addChild(background)

    local font_pause = cc.LabelTTF:create("暂 停","宋体",30)
    font_pause:setPosition(background:getContentSize().width/2,375)
    background:addChild(font_pause,1)

    ------------------------------继续游戏------------------------------
    local function func_continue()
        --cclog("继续游戏")
        --g_isPause = false
        playEffect("res/music/effect/btn_click.ogg")
        --[[正在用
        self.mainLayer:setVisible(false)
        cc.Director:getInstance():resume()
        self:release()
        --]]
       
        ---[[新继续游戏
            cc.Director:getInstance():popScene()
        --]]
    end
    local arr = {
             label_type = LABEL_TYPE_ENUM.ttf,
             button_type = BUTTON_TYPE_ENUM.normal,
             label = "",
             font = "",--字体 或 填字体库fnt
             font_size = 24,--fnt模式下 此参数用不上
             button1 = "zanting_button.png",
             button2 = "",
             x = background:getContentSize().width/2,
             y = 341 - 36 - 10
             }
     local continue = cc.Scale9Sprite:createWithSpriteFrameName("zanting_jixuyouxi.png")
     continue:setAnchorPoint(0.5,0.5)
     continue:setPosition(arr.x,arr.y)
     background:addChild(continue,3)
     self.btn_continue = UILayoutButton:createUIButton(arr)
     self.btn_continue:registerControlEventHandler(func_continue,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)--按下按钮
     background:addChild(self.btn_continue,2)

   --------------------------------重新开始------------------------------
   local function func_repeat()
        --cclog("重新开始")
        --[[正在用
        cc.Director:getInstance():resume()
        --]]
        SimpleAudioEngine:getInstance():stopAllEffects()
        --self:release()--释放
        ---[[重新开始
            cc.Director:getInstance():popScene()
        --]]
        --[[
        --背景层释放
        local GameBackGroundView = require "src/GameScene/gamevbackground"
        GameBackGroundView:ReleaseAll()
        --释放主层数据
        GameView:release()
        --释放UI层
        GameSceneUi:release()
        --释放控制层
        local GameSceneButton = require "src/GameScene/GameSceneButton"
        GameSceneButton:release()
        playEffect("res/music/effect/btn_click.ogg")

        SimpleAudioEngine:getInstance():rewindMusic()--重播
        local changeScene = require "src/GameScene/GameScene"
        if cc.Director:getInstance():getRunningScene() then         
           cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,changeScene:init()))--replaceScene此函数自动释放场景
	    else
		   cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,changeScene:init()))
	    end
        --]]
        --背景层释放
        local GameBackGroundView = require "src/GameScene/gamevbackground"
        GameBackGroundView:ReleaseAll()
        --释放主层数据
        GameView:release(true)--重来需要传true
        --释放UI层
        GameSceneUi:release()
        --释放控制层
        local GameSceneButton = require "src/GameScene/GameSceneButton"
        GameSceneButton:release()
        local repeat_id = 0
        local function repeatcallback()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(repeat_id)
            
            playEffect("res/music/effect/btn_click.ogg")

            SimpleAudioEngine:getInstance():rewindMusic()--重播
            local changeScene = require "src/GameScene/GameScene"
            if cc.Director:getInstance():getRunningScene() then         
               cc.Director:getInstance():replaceScene(cc.TransitionFade:create(1,changeScene:init()))--replaceScene此函数自动释放场景
	        else
		       cc.Director:getInstance():runWithScene(cc.TransitionFade:create(1,changeScene:init()))
	        end
        end
        repeat_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(repeatcallback,1/g_frame,false)
    end
   arr = {
         label_type = LABEL_TYPE_ENUM.ttf,
         button_type = BUTTON_TYPE_ENUM.normal,
         label = "",
         font = "",--字体 或 填字体库fnt
         font_size = 24,--fnt模式下 此参数用不上
         button1 = "zanting_button.png",
         button2 = "",
         x = background:getContentSize().width/2,
         y = 341 -72 - 36 - 50
         }
     local repeat_start = cc.Scale9Sprite:createWithSpriteFrameName("zanting_chongxinkaishi.png")
     repeat_start:setAnchorPoint(0.5,0.5)
     repeat_start:setPosition(arr.x,arr.y)
     background:addChild(repeat_start,3)
     self.btn_repeat_start = UILayoutButton:createUIButton(arr)
     self.btn_repeat_start:registerControlEventHandler(func_repeat,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)--按下按钮
     background:addChild(self.btn_repeat_start,2)
   --------------------------------返回主菜单------------------------------
   local function func_back()
        --cclog("返回主菜单")
        --[[正在用
        cc.Director:getInstance():resume()
        --]]
        SimpleAudioEngine:getInstance():stopAllEffects()
        --self:release()--释放
        ---[[返回主菜单
            cc.Director:getInstance():popScene()
        --]]
        --[[
        --背景层释放
        local GameBackGroundView = require "src/GameScene/gamevbackground"
        GameBackGroundView:ReleaseAll()
        --释放主层数据
        GameView:release()
        --释放UI层
        GameSceneUi:release()
        --释放控制层
        local GameSceneButton = require "src/GameScene/GameSceneButton"
        GameSceneButton:release()
        playEffect("res/music/effect/btn_click.ogg")
        --loading
        local loadV = require "src/GameLoad/GameLoadV"
        cc.Director:getInstance():getRunningScene():addChild(loadV:initUiRes())
        --]]
        --背景层释放
        local GameBackGroundView = require "src/GameScene/gamevbackground"
        GameBackGroundView:ReleaseAll()
        --释放主层数据
        GameView:release()
        --释放UI层
        GameSceneUi:release()
        --释放控制层
        local GameSceneButton = require "src/GameScene/GameSceneButton"
        GameSceneButton:release()
        local repeat_id = 0
        local function backcallback()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(repeat_id)
            playEffect("res/music/effect/btn_click.ogg")
            --loading
            local loadV = require "src/GameLoad/GameLoadV"
            cc.Director:getInstance():getRunningScene():addChild(loadV:initUiRes())
        end
        repeat_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(backcallback,1/g_frame,false)
    end
   arr = {
         label_type = LABEL_TYPE_ENUM.ttf,
         button_type = BUTTON_TYPE_ENUM.normal,
         label = "",
         font = "",--字体 或 填字体库fnt
         font_size = 24,--fnt模式下 此参数用不上
         button1 = "zanting_button.png",
         button2 = "",
         x = background:getContentSize().width/2,
         y = 341 -72*2 - 36 - 85
         }
     local back_menu = cc.Scale9Sprite:createWithSpriteFrameName("zanting_tuichuyouxi.png")
     back_menu:setAnchorPoint(0.5,0.5)
     back_menu:setPosition(arr.x,arr.y)
     background:addChild(back_menu,3)
     self.btn_back_menu = UILayoutButton:createUIButton(arr)
     self.btn_back_menu:registerControlEventHandler(func_back,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)--按下按钮
     background:addChild(self.btn_back_menu,2)

end

return GamePauseView
