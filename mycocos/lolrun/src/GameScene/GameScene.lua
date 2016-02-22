local GameScene = 
{
   mainScene = nil;
   physics_draw = nil;
}--@ 游戏场景
local meta = GameScene
--引用和全局，初始化----------------------------------------------------------------------------------
local GameView = require "src/GameScene/GameV"
local GameBackGroundView = require "src/GameScene/gamevbackground"
local GameModel = require "src/GameScene/GameM"
local GameSceneUi = require "src/GameScene/GameSceneUi"
local GameSceneButton = require "src/GameScene/GameSceneButton"
local Rand = require "src/tool/rand.lua"
function meta:init( ... )
    meta.mainScene =  cc.Scene:create()

    GameModel:SetGameSetup(GAME_STEP.game_ready)
    g_isPause = false--刚开始游戏准备

    Rand:init()--随机数

    meta.mainScene:addChild(GameBackGroundView:init(),1)--背景层
    meta.mainScene:addChild(GameView:init(),2)--主逻辑碰撞层

    --主层已经初始化了res
    meta.mainScene:addChild(GameSceneUi:init(GameModel.Handler:getRole():GetRes()),3)--下面初始化一些数字--貌似传参比较好
    GameModel:initGameUI()--UI层初始化数据
    --控制层
    meta.mainScene:addChild(GameSceneButton:init(),4)

    --初始化新手引导(第一次才会进入)
    --GameModel:initLeader()

    --////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 --   meta.mainScene = cc.Scene:createWithPhysics()
    

 --   g_physics_debug = false
 --   meta.mainScene:getPhysicsWorld():setDebugDrawMask(g_physics_debug and cc.PhysicsWorld.DEBUGDRAW_ALL or cc.PhysicsWorld.DEBUGDRAW_NONE)

 --   local GameModel = require "src/GameScene/GameM"
 --   GameModel.world_G = GameModel.jump_height*2/(GameModel.jump_time/2*GameModel.jump_time/2)
 --   meta.mainScene:getPhysicsWorld():setGravity(cc.p(0,-GameModel.world_G))

	--meta.mainScene:addChild(GameBackGroundView:init())--背景层
	--meta.mainScene:addChild(GameView:init())--主逻辑碰撞层
 --   meta.mainScene:addChild(GameUIView:init())--界面UI层
 --   meta.mainScene:addChild(GameControlView:init())--控制层


	-----[[
 --     --物理世界所有怪物注入回调 --cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE
 --    local Contactlistener = cc.EventListenerPhysicsContact:create()
 --    Contactlistener:registerScriptHandler(MakeScriptHandler(GameView,GameView.onContactBegin), cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)--刚接触
 --    Contactlistener:registerScriptHandler(MakeScriptHandler(GameView,GameView.onContactSeperate), cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)--分离
 --    local ContacteventDispatcher = meta.mainScene:getEventDispatcher()
 --    ContacteventDispatcher:addEventListenerWithSceneGraphPriority(Contactlistener,meta.mainScene)
	-- --Contactlistener:registerScriptHandler(MakeScriptHandler(GameView,GameView.onContactPostsolve),cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE)--
 --    --注册了此函数会导致碰撞处理失效 需要程序员自行判断
 --    --Contactlistener:registerScriptHandler(MakeScriptHandler(GameView,GameView.onContactPresolve), cc.Handler.EVENT_PHYSICS_CONTACT_PRESOLVE)--接触中
 --    --]]

    return meta.mainScene
end



return GameScene

