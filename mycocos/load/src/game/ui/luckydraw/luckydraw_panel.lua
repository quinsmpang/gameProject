module('game.ui.luckydraw.luckydraw_panel', package.seeall)

local _base_panel = require('game.ui.basepanel').BasePanel
local _luckydraw_data = require('game.ui.luckydraw.luckydraw_data')
local _tool   = require('util.tool')
local _misc = require('util.misc')
Panel = require('util.class').class(_base_panel)

local h       = ccui.Helper
local sWidget = h.seekWidgetByNameOnNode
local sNode   = h.seekNodeByNameOnNode
local sf      = string.format

--旋转状态
local ROTATE_START        = 1 --开始旋转
local ROTATE_SLOW_TO_FAST = 2 --慢到快旋转
local ROTATE_FAST         = 3 --快速旋转
local ROTATE_FAST_TO_SLOW = 4 --快到慢旋转
local ROTATE_END          = 5 --结束旋转
local ROTATE_STOP         = 6 --结束停止

local rotate_type         = ROTATE_START
local rotate_second       = 1--快速旋转时候 每秒旋转几圈
local cur_speed           = 0--当前速度
local cur_float           = 0--当前角度

local function setChance(panel)
    local _chance_num = sNode(h,panel,"chance_num")
    _chance_num:setString(_luckydraw_data.data.chance)
end
local function setData(panel)
    
    local _gold_num        = sNode(h,panel,"gold_num")
    local _bomb_num        = sNode(h,panel,"bomb_num")
    local _invincible_num  = sNode(h,panel,"invincible_num")
    local _rush_num        = sNode(h,panel,"rush_num")
    local _final_rush_num  = sNode(h,panel,"final_rush_num")
    local _life_single_num = sNode(h,panel,"life_single_num")
    local _life_group_num  = sNode(h,panel,"life_group_num")

    _gold_num:setString(sf("x%d",_luckydraw_data.data.gold))
    _bomb_num:setString(sf("x%d",_luckydraw_data.data.bomb))
    _invincible_num:setString(sf("x%d",_luckydraw_data.data.invincible))
    _rush_num:setString(sf("x%d",_luckydraw_data.data.rush))
    _final_rush_num:setString(sf("x%d",_luckydraw_data.data.final_rush))
    _life_single_num:setString(sf("x%d",_luckydraw_data.data.single))
    _life_group_num:setString(sf("x%d",_luckydraw_data.data.group))

    --提示字
    local _font_tips_bg = sWidget(h,panel,"font_tips_bg")
    local _font_tips    = sNode(h,panel,"font_tips")
    _font_tips:setString(_luckydraw_data.data.font_tips)
    _font_tips_bg:setContentSize(_font_tips:getContentSize().width+100,_font_tips_bg:getContentSize().height)
end
--旋转
local function rotateLogic(wheel,max_speed,addspeed)
    if rotate_type == ROTATE_SLOW_TO_FAST then
        cur_speed = cur_speed + addspeed
    elseif rotate_type == ROTATE_FAST then
        cur_speed = max_speed
    elseif rotate_type == ROTATE_FAST_TO_SLOW then
        if cur_speed > 0 then
            cur_speed = cur_speed - addspeed
        else
            cur_speed = 0
        end
        --cur_speed = cur_speed - addspeed
        --cclog("ROTATE_FAST_TO_SLOW cur_speed ============== " ..cur_speed)
    elseif rotate_type == ROTATE_END then
        cur_speed = 0
    end
    
    cur_float = cur_float + cur_speed
    wheel:setRotation(cur_float)
    --wheel_reverse:setRotation(-cur_float)
end
--变大
local function rotateScale(_prize_icon)
    local scaleby = cc.ScaleBy:create(1,1.2)
    _prize_icon:runAction(scaleby)
end
----结束一轮旋转后的效果
local function rotateLight(_rotate_wheel)
    local vector
    local prize_icon
    local light
    if _luckydraw_data.data.cur_id ~= 0 then
        vector      = _rotate_wheel:getChildByName(sf("vector_%d",_luckydraw_data.data.cur_id))
        prize_icon  = vector:getChildByName(sf("prize_icon_%d",_luckydraw_data.data.cur_id))
        light       = vector:getChildByName(sf("light_%d",_luckydraw_data.data.cur_id))
        if rotate_type == ROTATE_END then
            light:setVisible(true)
        else
            light:setVisible(false)
        end
        rotateScale(prize_icon)
    else
        
        for i=1,#_luckydraw_data.prize do
            vector      = _rotate_wheel:getChildByName(sf("vector_%d",i))
            prize_icon  = vector:getChildByName(sf("prize_icon_%d",i))
            light       = vector:getChildByName(sf("light_%d",i))
            light:setVisible(false)
            prize_icon:stopAllActions()
            prize_icon:setScale(1)
        end
    end

    _luckydraw_data.data.cur_id = 0
end
local function _onEnter(self,_cb_enter,_cb_endback)
    local panel = cc.CSLoader:createNode('ui/luckydraw.csb')

    setData(panel)
    setChance(panel)

    local rotate_wheel         = sNode(h,panel,"wheel_1")
    --local rotate_wheel_reverse = sNode(h,panel,"wheel_2")
    local _btn_lucky           = sNode(h,panel,"btn_lucky")

    local final_pos = 300
    local max_time = 3--预留2秒停止 全程大概5秒左右
    local luckyTime = max_time
    local fps = require('config').design.fps
    local t = fps
    local half = fps/2--半秒
    local max_speed = 360/fps
    local addspeed = max_speed/half

    local function cheat()
            --cclog("============= 快到慢旋转 ============= ")
            local cur_rotate = rotate_wheel:getRotation()--现在位置
            cur_rotate = cur_rotate % 360--换算成一个周期以内

            local real_float = (cur_rotate + (_luckydraw_data.data.cur_id-1)*(360/#_luckydraw_data.prize))%360--真实的角度
            local sum_float = math.abs(final_pos - real_float) + math.floor(real_float/final_pos)*final_pos

            --大于临界值特殊处理
            if sum_float > final_pos then
                sum_float = (final_pos - ( math.floor(sum_float/final_pos)*final_pos + sum_float%final_pos))+360
            end
            sum_float = sum_float + 360 + 65 --多跑一圈  防止停下刚好是选中位置
            addspeed = math.pow(cur_speed,2)/(sum_float*2)

    end
    local function listenBtn()
        if rotate_type == ROTATE_START then--开始旋转
            rotateLight(rotate_wheel)
            _btn_lucky:setSpriteFrame("ui/luckydraw/btn_stop.png")
            _luckydraw_data.subChance()
            setChance(panel)
            ---[[
            rotate_type = ROTATE_SLOW_TO_FAST
            luckyTime = max_time
            t = fps
            --计算异常
            if not _luckydraw_data.calcPrize() then
                _btn_lucky:setSpriteFrame("ui/luckydraw/btn_lucky.png")
                rotate_type = ROTATE_START
                panel:unscheduleUpdate()
                return
            end
            cur_speed = 0--当前速度
            addspeed = max_speed/half
            --cur_float = rotate_wheel:getRotation()--当前角度
            --cclog("============= 开始旋转 ============= ")
            --cclog("============= 慢到快旋转 ============= ")
            --]]
        elseif rotate_type == ROTATE_SLOW_TO_FAST then--慢到快旋转
            return

        elseif rotate_type == ROTATE_FAST then--快速旋转
            rotate_type = ROTATE_FAST_TO_SLOW
            cheat()
            _btn_lucky:setVisible(false)
        elseif rotate_type == ROTATE_FAST_TO_SLOW then--快到慢旋转
            return
        elseif rotate_type == ROTATE_END then--结束旋转
            return
        elseif rotate_type == ROTATE_STOP then--结束停止
            return
        end

        

        --更新
        local function update()
            if rotate_type == ROTATE_START or rotate_type == ROTATE_STOP then--开始旋转
                return
            end
            t = t - 1
            rotateLogic(rotate_wheel,max_speed,addspeed)

            if rotate_type == ROTATE_SLOW_TO_FAST then--慢到快旋转

                if cur_speed >= max_speed then--t <= half and luckyTime == max_time then
                    rotate_type = ROTATE_FAST
                    --cclog("============= 快速旋转 ============= ")
                end
                
            elseif rotate_type == ROTATE_FAST then--快速旋转
                
                if t <= half and luckyTime == 1 then
                    rotate_type = ROTATE_FAST_TO_SLOW
                    cheat()
                end
                
            elseif rotate_type == ROTATE_FAST_TO_SLOW then--快到慢旋转


                if cur_speed <= 0 then--t <= 0 and luckyTime <= 0 then
                    rotate_type = ROTATE_END
                    --cclog("============= 结束旋转 ============= ")
                end
                  

            elseif rotate_type == ROTATE_END then--结束旋转
                rotateLight(rotate_wheel)
                _btn_lucky:setVisible(true)
                _btn_lucky:setSpriteFrame("ui/luckydraw/btn_lucky.png")
                rotate_type = ROTATE_START
                panel:unscheduleUpdate()
                setData(panel)
                if _luckydraw_data.checkLife() then
                    --此处调用复活接口
                    callback(self,_cb_enter)
                    _luckydraw_data.release()--释放所有临时参数
                elseif not _luckydraw_data.isStart() then
--                    callback(self,_cb_enter)
--                    _luckydraw_data.release()--释放所有临时参数
                      rotate_type = ROTATE_STOP
                end
            elseif rotate_type == ROTATE_STOP then--结束旋转
                return
            end

            if t ~= 0 then
                return
            end
            --cclog("luckyTime ============= " ..luckyTime)
            t = fps
            luckyTime = luckyTime - 1
            

            
        end
        if rotate_type == ROTATE_SLOW_TO_FAST then
            panel:scheduleUpdateWithPriorityLua(update, 0)
        end
    end
    _tool.SpriteEventListener({cb_return = listenBtn,parent = panel,target = _btn_lucky})
    --增加滑动效果
    _tool.SpriteEventListener({cb_return = listenBtn,parent = panel,target = rotate_wheel,move = 2})

    local public_btn_close = ccui.Helper:seekWidgetByNameOnNode(panel, 'public_btn_close')
    public_btn_close:addTouchEventListener(
      _misc.createClickCB(function()
            if rotate_type == ROTATE_START or rotate_type == ROTATE_STOP then
                rotate_type = ROTATE_START
                callback(self,_cb_enter)
                _luckydraw_data.release()--释放所有临时参数
            end
      end)
    )


    return panel
end

--[[
tab={
  modal=true|false 是否模态
  ani=true|false  是否弹出效果
}
]]
Panel.ctor = function(self,tab)
    local _cb_enter     = tab.cb_enter
    local _cb_endback   = tab.endback
    
    --初始化数据
    _luckydraw_data.init()

    local panel = _onEnter(self,_cb_enter,_cb_endback)
    
    if not panel then
        cclog("panel is nil")
        return
    end

   self.__super_ctor__(self, panel, tab.modal, tab.ani)
   
end
function callback(self,cb_back)
    self:destroy()
    if type(cb_back) == "function" then
        cb_back()
    end
end

