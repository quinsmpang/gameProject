module('util.tool', package.seeall)
local _config = require('config')

local MSG_UNCONNECT  = -100 --无法连接服务器
local MSG_QUTIMEOUT  = -200 --请求超时
local MSG_POTIMEOUT  = -300 --响应超时
local MSG_NETWORKER  = -400 --网络异常

UPDATE_TYPE = {
    sign    = 1,
    rank    = 2,
}
--------------------------------------------------------------------------
--取随机整数(闭区间)
function randnum(min,max)
    local random_num
    if min == nil then
        random_num = math.random(min)--产生 （1,min） 之间的随机数
    elseif min == nil and max == nil then
        random_num = math.random()--产生 （0,1） 之间的浮点随机数
    else
        random_num = math.random(min,max)--产生 （min,max） 之间的随机数
    end
    
--    cclog("random_num ========= " ..random_num)
	return math.floor(random_num)
end

--裁剪
function createClippingNode(tab)
    local _clippingNode --裁剪节点
    local _holesStencil --模板节点(模板父节点)
    local _holes        --底板节点(底板父节点)
    local _alpha        --这个是区分可视模板的界限 即:大于此透明度的模板可显示(不是显示纹理 是显示模板形状)

    _holesStencil       = tab.holesStencil
    _holes              = tab.holes
    _alpha              = tab.alpha
    local _inverted     = tab.inverted
    
    local _isblink        = tab.isblink--按钮闪光效果

    if _isblink then
        local _blink = cc.Sprite:createWithSpriteFrameName("ui/public/blink.png")
        _blink:setAnchorPoint(cc.p(0,0))
        _blink:setScaleY(_config.design.height/_blink:getContentSize().height)
        _blink:setPosition(cc.p(-_blink:getContentSize().width,0))
        local moveAction = cc.MoveBy:create(2, cc.p(_config.design.width+_blink:getContentSize().width,0))
        local reverse    = moveAction:reverse()
        local seq        = cc.Sequence:create(moveAction,reverse)
        _blink:runAction(cc.RepeatForever:create(seq))
        _holes:addChild(_blink)
    end

    _clippingNode = cc.ClippingNode:create()
    _clippingNode:setStencil(_holesStencil)
    _clippingNode:addChild(_holes)

    _clippingNode:setInverted(_inverted)--false显示模板形状内的区域  true不显示模板形状 但显示形状外的区域
    _clippingNode:setAlphaThreshold(_alpha)--当模板的alpha值大于这个值 才会出现模板形状 0~1间浮点 默认是1

    return _clippingNode
end
--描边
function createStroke(tab)--CCSprite* sprite, int size, ccColor3B color, GLubyte opacity
    local _sprite          = tab.sprite
    local _size            = tab.size
    local _color           = tab.color
    local _opacity         = tab.opacity

    local rt                  = cc.RenderTexture:create(
        _sprite:getTexture():getContentSize().width + _size * 2,  
        _sprite:getTexture():getContentSize().height+_size * 2  
        )

    local _originalPos        = cc.p(_sprite:getPosition())
    local _originalColor      = _sprite:getColor()
    local _originalOpacity    = _sprite:getOpacity()
    local _originalVisibility = _sprite:isVisible()

    _sprite:setColor(_color)
    _sprite:setOpacity(_opacity)
    _sprite:setVisible(true)  

    local originalBlend = {}
    originalBlend.src,originalBlend.dst = _sprite:getBlendFunc()
--    cclog("originalBlend.src =============" ..originalBlend.src)
--    cclog("originalBlend.dst =============" ..originalBlend.dst)
    _sprite:setBlendFunc(gl.SRC_ALPHA, gl.ONE)

    local bottomLeft = cc.p(  
        _sprite:getTexture():getContentSize().width * _sprite:getAnchorPoint().x + _size,   
        _sprite:getTexture():getContentSize().height * _sprite:getAnchorPoint().y + _size) 

    local positionOffset= cc.p(  
        -_sprite:getTexture():getContentSize().width / 2,  
        -_sprite:getTexture():getContentSize().height / 2)  

    local position = cc.pSub(_originalPos, positionOffset) 

    rt:begin()  

    for i=1,361,15 do
        _sprite:setPosition(  
            cc.p(bottomLeft.x + math.asin(i)*_size, bottomLeft.y + math.acos(i)*_size)  
            )  
        _sprite:visit()
    end 

    rt:endToLua()

    _sprite:setPosition(_originalPos)
    _sprite:setColor(_originalColor) 
    _sprite:setBlendFunc(originalBlend.src,originalBlend.dst)
    _sprite:setVisible(_originalVisibility)
    _sprite:setOpacity(_originalOpacity)

    rt:setPosition(position);  

    return rt 

end
--精灵监听事件
function SpriteEventListener(tab)
    local _cb_return = tab.cb_return
    local _parent    = tab.parent--由谁来监听(一般是当前层或是父节点)
    local _target    = tab.target--被点选的目标精灵

    local ENUM_UP    = 1
    local ENUM_DOWN  = 2
    local _move      = tab.move--特殊效果 需要滑动才返回 1:上滑 2:下滑

    local temp_pos = {}
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
--        temp_pos = {x = target:getPositionX(),y = target:getPositionY()}
        if cc.rectContainsPoint(rect, locationInNode) then
--            local str = string.format("sprite began... x = %f, y = %f", locationInNode.x, locationInNode.y)
--            cclog(str)
            --写在这证明开始和结束都必须在按钮内 但这里如果不在这是不会响应end 所以没关系
            temp_pos = {x = target:getPositionX(),y = target:getPositionY()}
            return true
        end
        return false
    end
    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
--        local posX,posY = target:getPosition()
        local delta = touch:getDelta()
        --target:setPosition(cc.p(posX + delta.x, posY + delta.y))
        temp_pos.x = temp_pos.x + delta.x
        temp_pos.y = temp_pos.y + delta.y
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        if _move == ENUM_UP then
            local t_pos = {x = target:getPositionX(),y = target:getPositionY()}--屏幕坐标系 y往下递增
            if t_pos.y < temp_pos.y then
                --cclog("---------上滑---------")
                if type(_cb_return) == "function" then
                    _cb_return()
                end
            end
        elseif _move == ENUM_DOWN then
            local t_pos = {x = target:getPositionX(),y = target:getPositionY()}
            if t_pos.y > temp_pos.y then
                --cclog("---------下滑---------")
                if type(_cb_return) == "function" then
                    _cb_return()
                end
            end
        else
            local locationInNode = target:convertToNodeSpace(temp_pos)
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
            if target == _target and cc.rectContainsPoint(rect, locationInNode) then
                if type(_cb_return) == "function" then
                    _cb_return()
                end
            end
        end
        
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = _parent:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, _target)
end
--lua table copy
function copy_table(ori_tab)
    if (type(ori_tab) ~= "table") then
        return nil
    end
    local new_tab = {}
    for i,v in pairs(ori_tab) do
        local vtyp = type(v)
        if (vtyp == "table") then
            new_tab[i] = copy_table(v)
        elseif (vtyp == "thread") then
            new_tab[i] = v
        elseif (vtyp == "userdata") then
            new_tab[i] = v
        else
            new_tab[i] = v
        end
    end
    return new_tab
end
--取数字到底有几位
function getHowToNum(number)
    if type(number) ~= "number" then
        number = tonumber(number)
    end
    local sum = 1
    while (1) do
        number = math.floor(number/10)
        if number > 0 then
            sum = sum + 1
        else
            return sum
        end
    end
end
--播放动画
function playAnimation(obejct,path,num,dt)
    dt = dt or 0.1
    local cache = cc.SpriteFrameCache:getInstance()
    local _sprite = obejct--cc.Sprite:createWithSpriteFrameName("xx/xx/xx_1.png")
    local animFrames = {}
    for i = 1,num do 
        local frame = cache:getSpriteFrame( string.format("%s%d.png",path,i) )
        animFrames[i] = frame
    end
    local animation = cc.Animation:createWithSpriteFrames(animFrames, dt)
    _sprite:runAction( cc.RepeatForever:create( cc.Animate:create(animation) ) )
end
--检查网络是否连上
function IsNetWork()
   local check = false
   local _popupTip = require('game.mgr_scr').popupTip
   local targetPlatform = cc.Application:getInstance():getTargetPlatform()
   if  (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        check = plat.checkNetWork()
   elseif (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
        check = true
   end
   if check then
      --_popupTip("网络状态良好")
   else
      --_popupTip("网络异常 请检查网络")
   end

   return check
end
--检查是否隔日
function checkday(ud)
   local check = false
   local _d_t
   local _player = require('game.player')
   local _popupTip = require('game.mgr_scr').popupTip
   local cur_time
   if not _player.get().cur_time then--只在进入游戏时候获取一次当前时间
      cur_time = plat.getNetWorkTime()
      _player.get().cur_time = cur_time
   else
      cur_time = _player.get().cur_time
   end
    if cur_time == MSG_UNCONNECT then
        --_popupTip("无法连接服务器 请检查网络")
    elseif cur_time == MSG_QUTIMEOUT then
        --_popupTip("请求超时 请重试")
    elseif cur_time == MSG_POTIMEOUT then
        --_popupTip("响应超时 请重试")
    elseif cur_time == MSG_NETWORKER then
        --_popupTip("网络异常 请检查网络")
    else
        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        if  (cc.PLATFORM_OS_ANDROID == targetPlatform) then
            cur_time = math.floor(cur_time/1000)
        elseif (cc.PLATFORM_OS_WINDOWS == targetPlatform)  then

        end
       local cur = os.date("*t",cur_time)
--        cclog("cur.year = " ..cur.year)
--        cclog("cur.month = " ..cur.month)
--        cclog("cur.day = " ..cur.day)
--        cclog("cur.hour = " ..cur.hour)
--        cclog("cur.min = " ..cur.min)
--        cclog("cur.sec = " ..cur.sec)

        local _last_time
        local cur_time_0
        local pre_time_0
        local pre
        if require('config').test_data then
             if ud == UPDATE_TYPE.sign then
                _d_t = _player.get().unreal_day
            elseif ud == UPDATE_TYPE.rank then
                _d_t = _player.get().rank_day
            else
                _d_t = _player.get().unreal_day
            end
        else
            --根据类型选用对应的最后一次登录时间(这么做是为了时间不冲突  逻辑跟清晰)
            if ud == UPDATE_TYPE.sign then
                _last_time = _player.get().sign.last_time
                _player.get().sign.last_time = cur_time
            elseif ud == UPDATE_TYPE.rank then
                _last_time = _player.get().rank.last_time
                _player.get().rank.last_time = cur_time
            else
                _last_time = _player.get().last_time
                _player.get().last_time = cur_time
            end

            if not _last_time then
                
                return true,-1--负数代表第一次登录
            end

            pre = os.date("*t",_last_time)
            --当天当下时间戳AB   当天当下零时时间戳A1 B1   
            --（A1= A - 当天小时*3600 - 分钟*60 - 秒） 
            --日差 = （A1 - B1）/（60*60*24)
            cur_time_0 = cur_time   - cur.hour*3600 - cur.min*60 - cur.sec
            pre_time_0 = _last_time - pre.hour*3600 - pre.min*60 - pre.sec

            _d_t = cur_time_0 - pre_time_0
            _d_t = math.floor(_d_t/(60*60*24))
        end
        
        
        if _d_t >= 2 then
            --隔天
            check = true
        elseif _d_t == 1 then
            --连续第二天
            check = true
        else
            --同一天
            check = false
            _d_t = 0
        end

    end
        
   return check,_d_t
end
--max个数里面随机返回不重复的sum(不是绝对随机 但保证不重复 把max分区间取值 但是效率相对高  可用于对随机不苛刻的情况下使用)
function randomforSum(max,sum,min)--min<=max
    --cclog("***********************")
    local tab = {}
    local i= min or 1
    local n = max
    local k = sum
    for j=1,k do
        if j ~= 1 then
            i = i + 1
        end
        i=randnum(i,j*n/k)
        table.insert(tab,i)
        --cclog("i === " ..i)
    end
    return tab--从小到大返回
end
function randomforSumEx(max,sum,min)--min<=max
    local tab = {}
    local i= 1
    local k = sum
    for j=1,k do
        if j ~= 1 then
            i = i + 1
        end
        i=randnum(i,j*(max-min)/k)
        table.insert(tab,min+i)
        --cclog("i === " ..i)
    end
    return tab--从小到大返回
end
--------------动作函数:
--淡入淡出
function runFadeBlink(object,dt)
    dt = dt or 0.5
    local fade_out = cc.FadeOut:create(dt);
    local fade_in  = fade_out:reverse()
    local seq      = cc.Sequence:create(fade_out,fade_in)
    local forever  = cc.RepeatForever:create(seq)
    object:runAction(forever)
end
--放大缩小
function runScale(object,dt,scale)
    dt = dt or 0.5
    scale = scale or 0.2
    local scaleby = cc.ScaleBy:create(dt,1+scale)
    local reverse  = scaleby:reverse()
    local seq      = cc.Sequence:create(scaleby,reverse)
    local forever  = cc.RepeatForever:create(seq)
    object:runAction(forever)
end
--旋转(RotateTo 175度之后就逆转了)
function runRotate(object,dt)
    dt = dt or 0.5
    local ccRootate1 = cc.RotateTo:create(dt/3,120)
    local ccRootate2 = cc.RotateTo:create(dt/3,240)
    local ccRootate3 = cc.RotateTo:create(dt/3,360)
    object:runAction(cc.RepeatForever:create(cc.Sequence:create(ccRootate1,ccRootate2,ccRootate3)))
end