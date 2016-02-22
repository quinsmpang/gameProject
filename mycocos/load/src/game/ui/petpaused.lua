module('game.ui.petpaused', package.seeall)

local _misc = require('util.misc')
local _player = require('game.player')

local _CLR_BLACK  = {r=0,g=0,b=0}
local _CLR_NORMAL = {r=255,g=255,b=255}

local h = ccui.Helper
local s = h.seekWidgetByNameOnNode

local _data = {
--    pos_id   number
--    pic      boolean
--    debris   boolean
--    nothing  boolean
--    num      number
}
local str = "pet_%d"

local _pets = {
    {id = 30001,res = "ui/heros/30001.png"},
    {id = 30002,res = "ui/heros/30002.png"},
    {id = 30003,res = "ui/heros/30003.png"},
    {id = 30004,res = "ui/heros/30004.png"},
    {id = 30005,res = "ui/heros/30005.png"}
}

local function updateUI(panel)
    for i,v in pairs(_data) do
        local sf = string.format(str,v.pos_id)
        local vec      = panel:getChildByName(sf)
        local _pic     = vec:getChildByName("pic")
        local _debris  = vec:getChildByName("debris")
        local _num     = vec:getChildByName("num")
        local _nothing = vec:getChildByName("nothing")
        _pic:setSpriteFrame(_pets[v.pos_id].res)
        _pic:setColor(v.pic)
        _debris:setVisible(v.debris)
        _nothing:setVisible(v.nothing)
        _num:setVisible(not v.nothing)
        _num:setString("+" ..v.num)
    end
end

local function _onExit()
    --cclog("_onExit")
    _data = {}--返回主界面要清空本地数据
end
--初始化数据
local function init(panel)
    for i,v in ipairs(_pets) do
        --cclog(" _data["..v.id .."..] =========== " ..tostring( _data[v.id]))
        if not _data[v.id] then
            local _d   = {}
            _d.pos_id  = i
            _d.pic     = _CLR_BLACK
            _d.debris  = false
            _d.nothing = true
            _d.num     = 0
            _data[v.id] = _d
        end
    end
    
    updateUI(panel)
end
--[[
function cb_return(ret_code)
返回以下之一
]]
RET_RESUME = 0  --继续游戏
RET_TO_MAIN = 1 --结束并返回主界面

function create(cb_return)
  local panel = cc.CSLoader:createNode('ui/petpause.csb')
  
  init(panel)

  local h = ccui.Helper
  local s = h.seekWidgetByNameOnNode


  local function cbBack()
    cb_return(RET_RESUME)
  end
  s(h, panel, 'btn_return'):addTouchEventListener(
    _misc.createClickCB(cbBack)
  )

  s(h, panel, 'btn_main'):addTouchEventListener(
    _misc.createClickCB(
      function()
        cb_return(RET_TO_MAIN)
      end
    )
  )

  return {
    node=panel,
    block_bottom=true,
    pop_effect=true,
    reposition_center=true,
    onExit=_onExit,
    onKeyBack=cbBack,
  }
end
-------------------数据接口---------------------
--设置对应宠物数据
function setData(id)--宠物id
    --cclog(" setData["..id .."..] =========== " ..tostring( _data[id]))
    if _data[id] then
        _data[id].pic        = _CLR_NORMAL
        _data[id].debris     = true
        _data[id].nothing    = false
        _data[id].num        = _data[id].num + 1
    else
        for i,v in ipairs(_pets) do
            if v.id == id then
                local _d   = {}
                _d.pos_id  = i
                _d.pic     = _CLR_NORMAL
                _d.debris  = true
                _d.nothing = false
                _d.num     = _d.num or 0
                _d.num     = _d.num + 1
                _data[id]  = _d
                --cclog("_pets["..i.."]======== " ..v.id)
            end
        end
    end
end

