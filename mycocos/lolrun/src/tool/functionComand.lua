
--安卓方法
require "src/tool/AndroidFunction"


--调用java方法
function Func_callJavaFun(className,funName,args,sigs)
    local ok,ret = nil,nil
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        ok,ret = callJavaFun(className,funName,args,sigs)
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯

    end

    return ok,ret
end
--获取sd card路径
function Func_getSDCardPath()
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        local sdcardpath = nil
         if sdcardpath == nil then
        local ok,ret = callJavaFun("org/cocos2dx/lua/AppActivity","getSDCardPath",{},"()Ljava/lang/String;")
            if ok then
                sdcardpath = ret;
            else
                sdcardpath = "";
            end
        end
        return sdcardpath
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯

    end
end

--获取唯一机器码
function Func_MacId()
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        local strtmp = nil
        if strtmp == nil then
            local ok,ret = callJavaFun("org/cocos2dx/lua/AppActivity","getAndroid_id",{},"()Ljava/lang/String;")
            if ok then
                strtmp = ret;
            else
                strtmp = "";
            end
        end
        return strtmp
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯
        return ""
    else
        return ""
    end
    
end
--登陆,需传入一个回调方法
function Func_login(callback)
    local MacId=Func_MacId()
    local requrl=g_inturl.."?act=login&advtype="..g_advtype.."&subtype="..g_subtype
    requrl=requrl.."&username="..MacId
    --登陆成功返回1,注册成功返回会员id(大于1),访问失败为空
    Func_HttpRequest(requrl,"",callback)
    --callback(requrl)
end

--获取会员信息,需传入一个回调方法
function Func_getMemberData(callback)
    local function mycb(strhtml)
        if(strhtml~="" and strhtml ~= nil) then
           --cc.UserDefault:getInstance():setIntegerForKey(CONFIG_USER_DEFAULT.Diamonds, strhtml)--设置游戏钻石
           --cc.UserDefault:getInstance():flush()
           setData(CONFIG_USER_DEFAULT.Diamonds, strhtml)--防止卸载APK包后数据不见
        end

        callback(strhtml)
    end
    local MacId=Func_MacId()
    local requrl=g_inturl.."?act=getmemberdata"
    requrl=requrl.."&username="..MacId
    Func_HttpRequest(requrl,"",mycb)
end

--钻石消费(物品名称,数量,总额,回调)
--回调方法格式为 callback(status)   status 1为成功,非1 为失败
function Func_useMemberMoney(goods,amount,total,callback)
    local MacId=Func_MacId()
    local requrl=g_inturl.."?act=usemoney"
    requrl=requrl.."&username="..MacId
    requrl=requrl.."&goods="..goods
    requrl=requrl.."&amount="..amount
    requrl=requrl.."&total="..total
    Func_HttpRequest(requrl,"",callback)
end

--生成Upay订单
function Func_getUpayOrder(total,callback)
    local goods="钻石"
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        local MacId=Func_MacId()
        local function GetOrderResult(order)
            if order ~= "" then
                local ok,ret = Func_callJavaFun("org/cocos2dx/lua/AppActivity","Pay",{goods,total,tostring(order),{}},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
                callback(ok)
            else
                callback("")
                --请求失败做处理
                print("network error")
            end
        end
        local requrl=g_inturl.."?act=getorder"
        requrl=requrl.."&member="..MacId
        requrl=requrl.."&total="..total
        Func_HttpRequest(requrl,"",GetOrderResult)
     
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯

    end
end

--生成随机订单号
function Func_genOrderCode()
    math.randomseed(os.time())
    return os.time() .. math.random(10000, 99999)
end

--支付宝快捷支付
--function paycallback(ret)
--      todo
--end
--Func_AlipaySec("物品名称","物品简介","价格",回调)(product,productdesc,price,callback)
function Func_AlipaySec(product,productdesc,price,callback)
	if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        androidAlipaySec(product,productdesc,price,callback)
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯
        
    else
        callback(Func_genOrderCode())
    end
end


function Func_GetChannel()
	if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
       return androidGetChannel()
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯
       return "" 
    else
       return ""
    end
end

function Func_GetModel()
	if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
       return androidGetModel()
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯
       return "" 
    else
       return ""
    end
end

function Func_UrlEncode(s)
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
     return string.gsub(s, " ", "+")
 end

function Func_ShowLoading(requrl,extra,callback,scriptid)
    
    local loadingLayer = nil
    local sc = cc.Director:getInstance():getRunningScene()
    if sc ~= nil then

        local function onTouchBegan()
        end
      
        local function loadTimeout()
            if scriptid ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scriptid)
            end
            if sc == cc.Director:getInstance():getRunningScene() then
                if loadingLayer ~= nil then
                    loadingLayer:removeFromParent()
                end
            end
            
            --网络不稳定 请重试
            local sc2 = cc.Director:getInstance():getRunningScene()
            if sc2 ~= nil then

                local layer  = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/loadingui/loadingui_2.ExportJson")

                local function onTouchTimeout(sender,eventType)
                    if eventType == ccui.TouchEventType.began then

                        if sc == cc.Director:getInstance():getRunningScene() then
                             layer:removeFromParent()
                        end

                        Func_HttpRequest(requrl,extra,callback,true)
                    end
                end

                -- 监听触摸事件
           
                layer:addTouchEventListener(onTouchTimeout)
        
                sc2:addChild(layer,99999)
            end
        end

        local layer  = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/loadingui/loadingui_1.ExportJson")

        local img_loading = layer:getChildByName("img_loading")
                   
        -- 监听触摸事件
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)--阻止消息往下传递
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
        
        sc:addChild(layer,99998)

        loadingLayer = layer
           
        local ro = cc.RotateBy:create(2,360)

        local re = cc.RepeatForever:create(ro)

        img_loading:runAction(re)


        loadingIsShowed = true

        scriptid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadTimeout,15,false)

        return scriptid,loadingLayer
    end

    return nil,nil
end

function Func_CheckNetWork()
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        return androidCheckNetWork()
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯
        return false
    else
        return true
    end
end

--http异步请求
function Func_HttpRequest(requrl,extra,callback,needLoading)
    --HTTP请求时 额外统计用户行为数据
    if #g_clickinfo > 0 then
        if string.find(requrl,"?") == nil then
            requrl = requrl .. "?"
        end
        requrl = requrl .. "&summac=" .. Func_MacId()
        for i=1,#g_clickinfo do
            requrl = requrl .. "&sumd[]=" .. g_clickinfo[i]
        end
        requrl = requrl .. "&sumsid=" .. g_userinfo.sid
        g_clickinfo = {}
    end
  
    
    if Func_CheckNetWork() ~= true then
        --网络未连接 请重试
        local sc2 = cc.Director:getInstance():getRunningScene()
        if sc2 ~= nil then
            local layer  = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/loadingui/loadingui_2.ExportJson")
            local function onTouchTimeout(sender,eventType)
                if eventType == ccui.TouchEventType.began then

                    if sc2 == cc.Director:getInstance():getRunningScene() then
                            layer:removeFromParent()
                    end

                    Func_HttpRequest(requrl,extra,callback,needLoading)
                end
            end

            -- 监听触摸事件
           
            layer:addTouchEventListener(onTouchTimeout)
        
            sc2:addChild(layer,99999)
        end

        return
    end

    if needLoading == nil then
        needLoading = true
    end

    local sc = cc.Director:getInstance():getRunningScene()
    local scriptid = nil
    local loadingLayer = nil 
    if needLoading then
        scriptid,loadingLayer = Func_ShowLoading(requrl,extra,callback,scriptid)
    end

    local function requestCallback(result,extra)
        
        if sc == cc.Director:getInstance():getRunningScene() then
            if loadingLayer ~= nil then
                loadingLayer:removeFromParent()
            end
        end
        if scriptid ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scriptid)
        end
        callback(result,extra)
        
    end
  
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        androidHttpRequest(requrl,extra,requestCallback)
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯
        
    else
        Win32HttpRequest(requrl,extra,requestCallback)
    end
end

function Win32HttpRequest(requrl,extra,callback)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", requrl)
    local function onReadyStateChange()
        callback(xhr.response,extra)
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

--http异步下载
function Func_HttpDownload(downloadurl,localfile,extra,callback)
     if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        androidHttpDownload(downloadurl,localfile,extra,callback)
     
     elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯

    end
    
end

--安装
function Func_Setup(apkfilename)
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        androidSetup(apkfilename)
     
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯

    end
    
end

--下载管理器
function Func_DownloadManager(key,url,title,filename,callback)
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        androidDownloadManager(key,url,title,filename,callback)
     
    elseif cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_IPHONE then--ios通讯

    end
end


--拆分函数
function Split(szFullString, szSeparator)--需要拆分的字符串,拆分符号 例如:("123;321",";")
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
       if not nFindLastIndex then
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
        break
       end
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)
       nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

--返回对象函数闭包的函数(情况:当传入的是对象函数指针的时候  而又无法传入对象指针的时候)
--例子：两句等价
--ani:runAction(cc.Sequence:create(cc.CallFunc:create( function() meta.role:blink_end() end  )))
--ani:runAction(cc.Sequence:create(cc.CallFunc:create( MakeScriptHandler(meta.role, meta.role.blink_end,1,2,...) )))
function MakeScriptHandler(target, selector,...)
    local args = {...}
    return function( ... )
        local internalArgs = { ... }
        for _,arg in pairs(args) do
            table.insert(internalArgs,arg)
        end
        return selector(target,unpack(internalArgs))
    end
end

--remove指定索引（tab = {[1]=1 [2]=2 [3]=3}  remove(tab,2) ---> tab = {[1]=1  [3]=3}）索引不往前移动
function removeTableFromIndex(tab,i)
     tab[i] = nil
end


--在物理世界中 一直以屏幕左下角为零点 但是在刚体中是默认中心为锚点 导致在主层(刚体)下的节点坐标都是以主层中心为零点
--转换世界坐标(必须以0,0为零点)
function ConvertToWorldSpace(object)
    local pos = object:convertToWorldSpace(cc.p(0,0))
    return pos
end
--速度转换像素
function velocity2px(v,frame)
	frame = frame or 30
	return v/frame
end
--像素转换成速度
function px2velocity(px,frame)
	frame = frame or 30
	return px * frame
end

--plist特效读取 返回一个node
function PlayEffectFromPlist(cache,name,dit)
    if cache == nil then
        return nil
    end
    dit = dit or 0.01
    local str = string.format("%s/0000",name)
    local plist_effect = cc.Sprite:createWithSpriteFrameName(str)
    local animFrames = {}
    local i = 1
    while true do

        local temp = string.format("%s/%02d",name,i-1)
        
        local frame = cache:getSpriteFrame(temp)
        if frame == nil then
            break
        end
        animFrames[i] = frame
        i = i +1
    end
    local animation = cc.Animation:createWithSpriteFrames(animFrames, dit)
    plist_effect:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))

    return plist_effect
end


--设置数据
function setData(key,value)
    --local path = cc.FileUtils:getInstance():getWritablePath()
    ----文件路径
    --local filepath = string.format("%s%s",path,"../mydata.txt")
    --value = enc_rever(value)
    --如果文件路径不存在
    local filepath = nil 
    filepath = cc.FileUtils:getInstance():getWritablePath() .."/mydata.txt"

    if cc.FileUtils:getInstance():isFileExist(filepath) == false then  
        local tb = {[key]=value}
        cc.FileUtils:getInstance():writeToFile(tb,filepath)
        return 
    end 
    local isSame = false --是否拥有相同字段
    local tb1 = cc.FileUtils:getInstance():getValueMapFromFile(filepath)
    for key1,var1 in pairs(tb1) do 
        if key1 == key then 
            --print("修改数据")
            tb1[key1]=value
            isSame = true
        end 
    end 
    if isSame == true then 
        --写数据 
        cc.FileUtils:getInstance():writeToFile(tb1,filepath)
    elseif isSame == false then 
        --print("追加数据")
        table.insert(tb1,key)
        tb1[key] = value 
        local tb2 = {}
        for k,v in pairs(tb1) do 
            if k ~= 1 then 
                tb2[k] = v
            end 
        end 
        cc.FileUtils:getInstance():writeToFile(tb2,filepath)
    end
end 

--获得数据（有字段的话返回对应的值， 否则返回nil）
function getData(key)
    local filepath = nil
    filepath = cc.FileUtils:getInstance():getWritablePath() .."/mydata.txt"

    local tb = cc.FileUtils:getInstance():getValueMapFromFile(filepath)
    --if tb[key] == "" or  tb[key] == nil then
        return tb[key]
    --end
    --return rever_dec(tb[key])

    
end 

---[[
-- 全局的 提示语，出现，然后渐渐消失
function g_tips_setString(str,time)
    
    if not g_tips then 
        g_tips = {
            background = nil;
            label = nil;
            --背景加宽
            offset = 50;
            bg_sub_y = 0;
        }
    else
        if  g_tips.background then
            g_tips.background:removeFromParent()
            g_tips.background:release()
            g_tips.background= nil
        end
        if  g_tips.label then
            g_tips.label:removeFromParent()
            g_tips.label:release()
            g_tips.label = nil
        end

    end

    local _font = "宋体"
    local _size = 50
    local _time = time or 2

    function g_tips:setString(str)
        --停止及删除动作
        self.label:stopAllActions()

        local function releaseLabel()
            self.label:removeFromParent()
            self.label = nil
        end

        local function releaseBg()
            self.background:removeFromParent()
            self.background = nil
        end

        self.label:setString(str)
        local size = self.label:getContentSize()

        -- 同步 背景图 跟lebel大小
        size.width = size.width + self.offset
        size.height = size.height - g_tips.bg_sub_y
        --设置背景图的大小
        self.background:setContentSize(size)


        -- 背景动作
        self.background:setOpacity(255)
        local actionBg = cc.FadeOut:create(_time)
        self.background:runAction(cc.Sequence:create(actionBg,cc.CallFunc:create(releaseBg)))


        -- 字体动作
        self.label:setOpacity(255)
        local actionLabel = cc.FadeOut:create(_time)
        self.label:runAction(cc.Sequence:create(actionLabel,cc.CallFunc:create(releaseLabel)))

    end



    --label init
    g_tips.label = cc.LabelTTF:create(str,_font,_size)
    g_tips.label:setAnchorPoint(cc.p(0,0))
    g_tips.label:setPosition(cc.p(g_tips.offset/2,0))
    g_tips.label:retain()
    
    -- 背景 init
    g_tips.background = cc.Scale9Sprite:create("res/ui/label_bg2.png")
    g_tips.background:setAnchorPoint(cc.p(0.5,0.5))
    g_tips.background:addChild(g_tips.label)
    g_tips.background:retain()

    -- 设置居中
    local winsize = cc.Director:getInstance():getWinSize()
    g_tips.background:setPosition(cc.p(winsize.width/2,winsize.height/2))
    --加入场景
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(g_tips.background,50000)


    g_tips:setString(str)
end
--]]

--获得本地数据的英雄装备数组
function getLocalTbEquip(id)
   local myData  = getData(CONFIG_USER_DEFAULT.HeroData)
   local oneHero = Split(myData,"||") 
   for i = 1,#oneHero do
        local properties = Split(oneHero[i],";")
        if properties[1] == id then 
            local equipStr = string.format("%s;%s;%s;%s;%s;%s",properties[3],properties[4],properties[5],properties[6],properties[7],properties[8])
            local equipTb  = Split(equipStr,";")
            return equipTb
        end 
   end 
end 

--获取本地数据的英雄等级
function getLocalLevel(id)
   local myData  = getData(CONFIG_USER_DEFAULT.HeroData)
   local oneHero = Split(myData,"||") 
   for i = 1,#oneHero do
        local properties = Split(oneHero[i],";")
        if properties[1] == id then 
            return properties[2]
        end 
   end 
end 
--post发送请求（一个方法的）
 --Posturl 
 --postbody ， 内容
 --func     ,  处理什么   
function onPostClicked(posturl,postbody,func)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST",posturl)
    local function onReadyStateChange()
        print(xhr.response)
        local cjson = require "cjson" 
        g_server_conf = cjson.decode(xhr.response)
        if g_server_conf.code == "100" or g_server_conf.code == 100 then 
            --local a = io.open("res/haha.json","a")
            --a:write(xhr.response)      
            --a:close()
            func(g_server_conf)
        end 
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(postbody)
end

------------------------加密解密--------------------
local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
--加密入口	里面加了一层string.reverse
function enc_rever(data)
    data = Base64Enc(data) 
    return string.reverse(data)
end
--解密入口  	里面加了一层string.reverse
function rever_dec(data)
    data = string.reverse(data)
    return Base64Dec(data)
end
--六十四加密
function Base64Enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

--六十四解密
function Base64Dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

--post发送请求（一个方法的）(没有判断100de )
 --Posturl 
 --postbody ， 内容
 --func     ,  处理什么   
function onPostClicked2(posturl,postbody,func)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST",posturl)
    local function onReadyStateChange()
        print(xhr.response)
        local cjson = require "cjson" 
        g_server_conf = cjson.decode(xhr.response)
        --local a = io.open("res/haha.json","a")
        --a:write(xhr.response)      
        --a:close()
        func(g_server_conf)
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(postbody)
end
----------------------------------------------------
function onGetClicked(posturl,func)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("Get",posturl)
    local function onReadyStateChange()
        print(xhr.response)
        local cjson = require "cjson" 
        g_server_conf = cjson.decode(xhr.response)
        func(g_server_conf)
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

--统计
function statistics(num)
    table.insert(g_clickinfo,num)
--[[旧统计接口
    if g_debug_btn then --测试不执行
        ----------空------------------
    else 
        local subtype =  ""
        local advtype =  ""
        local uname   =  ""
        local uid     =  ""
        local macode  =  ""
        local sid     =  ""
        local requrl  =  ""
        --机器码不为空 而且 服务不为空
        if getData(CONFIG_USER_DEFAULT.UserMac) ~= nil and getData(CONFIG_USER_DEFAULT.UserSid) ~= nil then 
            --http://www.v5fz.com/api/advt.php?act=click&type=1&subtype=10&advtype=10&uname=XXX&uid=80001&macode=fjdfjk&sid=1
            subtype = "&subtype=" .."10"
            advtype = "&advtype=" .."10"
            uname   = "&uname=" ..getData(CONFIG_USER_DEFAULT.UserName)
            uid     = "&uid=" ..getData(CONFIG_USER_DEFAULT.UserId)
            macode  = "&macode=" ..getData(CONFIG_USER_DEFAULT.UserMac)
            sid     = "&sid=" ..getData(CONFIG_USER_DEFAULT.UserSid)
            requrl  = g_url.act_click .."&type="..num..subtype..advtype..uname..uid..macode..sid 
        --机器码不为空 而且 服务器为空
        elseif getData(CONFIG_USER_DEFAULT.UserMac) ~= nil and getData(CONFIG_USER_DEFAULT.UserSid) == nil then 
            --http://www.v5fz.com/api/advt.php?act=click&type=1&subtype=10&advtype=10&uname=XXX&uid=80001&macode=fjdfjk&sid=1
            subtype = "&subtype=" .."10"
            advtype = "&advtype=" .."10"
            uname   = "&uname=" ..getData(CONFIG_USER_DEFAULT.UserName)
            uid     = "&uid=" ..getData(CONFIG_USER_DEFAULT.UserId)
            macode  = "&macode=" ..getData(CONFIG_USER_DEFAULT.UserMac)
            sid     = "&sid="
            requrl  = g_url.act_click .."&type=" ..num ..subtype ..advtype ..uname ..uid ..macode ..sid 
        else 
            subtype = "&subtype=" .."10"
            advtype = "&advtype=" .."10"
            uname   = "&uname="
            uid     = "&uid="
            macode  = "&macode=" ..Func_MacId()
            sid     = "&sid="
            requrl  = g_url.act_click .."&type=" ..num..subtype..advtype..uname..uid..macode..sid 
        end 
        local function myStatistics()
            print("统计："..num)
        end 
        Func_HttpRequest(requrl,"",myStatistics)
    end 
    ]]--
end 

--检查宝箱
function checkBoxStatus()
    
end 

--播放发音乐
function playMusic(path,is_repeat)
    if g_isMusic then  --静音
        is_repeat = is_repeat or true
        SimpleAudioEngine:getInstance():playMusic(path,is_repeat)
    end 
end

--播放音效
function playEffect(path)
    --if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
    if g_isEffect then  --静音
        SimpleAudioEngine:getInstance():playEffect(path)
    end 
end

--流水号
function serialNum()
    local myRand = require "src/tool/rand"
    rand = myRand:randnum(1,9999999)
    return 
end

--暂停处理
function PauseScene(callback)
    
    local fileName = "airmiddle1.png"
    
    local function afterCaptured(succeed, outputFile)
        if succeed then
            local sc = cc.Director:getInstance():getRunningScene()
            if sc ~= nil then
                
                local sc = cc.Scene:create()
                local visibleSize = cc.Director:getInstance():getVisibleSize()
                local spr = cc.Sprite:create(outputFile) 
                local size = spr:getContentSize()
                spr:setScaleX(visibleSize.width / size.width )
                spr:setScaleY(visibleSize.height / size.height )
                spr:setAnchorPoint(cc.p(0, 0))  
                --spr:setFlipY(true)
                sc:addChild(spr)

                cc.Director:getInstance():pushScene(sc)
                callback(sc)
                return
            end
        else
            cc.utils:captureScreen(afterCaptured, fileName)--截屏
        end
        callback()
    end
    cc.Director:getInstance():getTextureCache():removeTextureForKey(fileName)
    cc.utils:captureScreen(afterCaptured, fileName)--截屏
   
    --[[
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local renderTexture = cc.RenderTexture:create(visibleSize.width,visibleSize.height)
        renderTexture:begin()   
        sc:visit() 
        renderTexture:endToLua()

        local dialogScene = cc.Scene:create()
        local spr = cc.Sprite:createWithTexture(renderTexture:getSprite():getTexture()) 
        spr:setAnchorPoint(ccp(0, 0))  
        spr:setFlipY(true) 
        dialogScene:addChild(spr) 
        dialogScene:addChild(layer,9999)
        
        cc.Director:getInstance():pushScene(dialogScene)
        local ro = cc.RotateBy:create(2,360)
        local re = cc.RepeatForever:create(ro)
        img_loading:runAction(re)
        
        --local function nextFrame(dt)
            
        --end
        -- = cc.Director:getInstance():getScheduler():scheduleScriptFunc(nextFrame, g_frame, false)
        ]]--


end 


--新手引导
--给予一个rect，生成一个除了rect，其他地方被layercolor覆盖的层
--参数1：矩形
--参数2：c4b颜色，默认 cc.c4b(255,0,0,255) 红色
--参数3：是否屏蔽下面时间穿透，默认屏蔽
--注意：这个层是相对场景cc.p（0，0),若要转换到其他层，可以把此层add到该层，又或者转换出来
function createClippingBoard(rect,c4b,isSwallow)
    local node = cc.Node:create()

    local winSize = cc.Director:getInstance():getWinSize()

    local point = {} --顺时针  由左下角开始
    point[1] = cc.p(rect.x,rect.y)
    point[2] = cc.p(rect.x,rect.y + rect.height)
    point[3] = cc.p(rect.x+rect.width , rect.y + rect.height)
    point[4] = cc.p(rect.x+rect.width , rect.y)

    local layer = {} --顺时针  由左下角开始
    c4b = c4b or cc.c4b(255,0,0,255)
    for i = 1,4 do 
        layer[i] = cc.LayerColor:create(c4b)
        node:addChild(layer[i])
    end

    layer[1]:setPosition(cc.p(point[1].x-winSize.width,point[1].y))
    layer[2]:setPosition(cc.p(point[2].x,point[2].y))
    layer[3]:setPosition(cc.p(point[3].x,point[3].y-winSize.height))
    layer[4]:setPosition(cc.p(point[4].x-winSize.width,point[4].y-winSize.height))



    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        if cc.rectContainsPoint(rect, locationInNode) then
            --print(string.format("sprite began... x = %f, y = %f", locationInNode.x, locationInNode.y))
            --target:setOpacity(180)
            return true
        end
        return false
    end



    local listener1 
    local eventDispatcher
    for i = 1,4 do 
        if listener1 == nil then
            listener1 = cc.EventListenerTouchOneByOne:create()
            if isSwallow == nil then 
                isSwallow = true
            end
            listener1:setSwallowTouches(isSwallow)
            listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
            eventDispatcher = layer[i]:getEventDispatcher()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layer[i])
        else
            local listener2 = listener1:clone()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener2, layer[i])
        end
    end
    return node
end
--新手引导根据缩放值生成新rect
function ScaleToRect(scale_x,scale_y,rect)
    local new_rect = {}
    new_rect.x = rect.x - rect.width*scale_x/2
    new_rect.y = rect.y - rect.height*scale_y/2
    new_rect.width = rect.width*scale_x
    new_rect.height = rect.height*scale_y
    return new_rect
end
