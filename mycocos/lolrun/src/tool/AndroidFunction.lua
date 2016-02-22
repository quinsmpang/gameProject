--local url = require("url")

local packsize = 5120 -- 以 5K 的字节块来接收数据，每个数据包的大小

math.randomseed(os.time())
math.random()
math.random()
math.random()




--调用JAVA静态方法 限安卓环境调用
function callJavaFun(className,funName,args,sigs)
    --if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
        local luaj = require "luaj"
        local ok,ret  = luaj.callStaticMethod(className,funName,args,sigs)
        return ok,ret
    --end
    --return false
end


local sdcardpath = nil

--获取安卓SDCARD目录  返回结果一般为 /sdcrad
function getSDCardPath()
    if sdcardpath == nil then
        local ok,ret = callJavaFun("org/cocos2dx/lua/AppActivity","getSDCardPath",{},"()Ljava/lang/String;")
        if ok then
            sdcardpath = ret;
        else
            sdcardpath = "";
        end
    end
    return sdcardpath
end

function httpSetPackSize(size)
    packsize = size
end
--[[
function Split(szFullString, szSeparator)  
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
--]]
function headerToTable(str)
    local t = Split(str,"\r\n")
    local header = {}
    for key, var in ipairs(t) do
        local sub = Split(var," ")
        if table.maxn(sub) >=2 then
            header[sub[1]] = sub[2]
        end
    end
    return header
end


--安卓支付宝快捷支付请求
function androidAlipaySec(product,productdesc,price,callback)
    local function androidCallBack(param)
        local t = Split(param,"|||")
        callback(t[1])
    end

    local args = { product,  productdesc, price, androidCallBack }
    local className = "org/cocos2dx/lua/AppActivity"
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local ok  = callJavaFun(className,"alipaySec",args,sigs)
    if not ok then
    else
    end
end
--检查是否有网络链接
function androidCheckNetWork()
    local args = {}
    local className = "org/cocos2dx/lua/AppActivity"
    local sigs = "()Z"
    local ok,ret  = callJavaFun(className,"isNetwork",args,sigs)
    if ok then
        return ret
    end
    return false
end

--安卓提示信息框
function androidAlert(msg)
    if cc.Application:getInstance():getTargetPlatform()==cc.PLATFORM_OS_ANDROID then--安卓通讯
        local args = { msg }
        local className = "org/cocos2dx/lua/AppActivity"
        local sigs = "(Ljava/lang/String;)V"
        local ok  = callJavaFun(className,"alert",args,sigs)
        if not ok then
        else
        end
    end 
end

--安卓获取渠道号
function androidGetChannel()
        local args = {  }
        local className = "org/cocos2dx/lua/AppActivity"
        local sigs = "()Ljava/lang/String;"
        local ok,ret  = callJavaFun(className,"getChannel",args,sigs)
        if ok then
            return ret;
        else
            return "";
        end

end

--安卓获取手机厂商设备及型号
function androidGetModel()
        local args = {  }
        local className = "org/cocos2dx/lua/AppActivity"
        local sigs = "()Ljava/lang/String;"
        local ok,ret  = callJavaFun(className,"getAndroid_model",args,sigs)
        if ok then
            return ret;
        else
            return "";
        end

end

--安卓HTTP异步请求
--requrl=请求URL,extra=额外参数,callback=function(result,extra)
function androidHttpRequest(requrl,extra,callback)
    local function androidCallBack(param)
        local t = Split(param,"|||")
        callback(t[2],t[1])
    end

    local args = { requrl,  extra, androidCallBack }
    local className = "org/cocos2dx/lua/AppActivity"
    local sigs = "(Ljava/lang/String;Ljava/lang/String;I)V"
    local ok  = callJavaFun(className,"httpRequest",args,sigs)
    if not ok then
    else
    end
end

--安卓HTTP异步下载
--downloadurl=请求URL,localfile=本地文件完整路径,extra=额外参数,callback=function(status,localfile,extra,persent)
function androidHttpDownload(downloadurl,localfile,extra,callback)
    local function androidCallBack(param)
        local t = Split(param,"|||")
        if t[1]=="ok" then
            callback(1,t[3],t[2],t[4])
        end
        if t[1]=="loading" then
            callback(2,t[3],t[2],t[4])
        end
    end

    local args = { downloadurl, localfile, extra, androidCallBack }
    local className = "org/cocos2dx/lua/AppActivity"
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local ok  = callJavaFun(className,"httpDownload",args,sigs)
    if not ok then
    else
    end
end

--安卓安装APK
--apkfilename=完整的APK路径
function androidSetup(apkfilename)
    local args = { apkfilename }
    local ok  =  callJavaFun("org/cocos2dx/lua/AppActivity","setup",args,"(Ljava/lang/String;)V")
    return ok
end

--开始一个下载管理器的下载任务  
--key=自定义任务的标识  url=下载地址  title=下载任务标题 filename=本地的文件名 callback=function(status,key,filepath)
function androidDownloadManager(key,url,title,filename,callback)
    local function callbackLua(param)
        local t = Split(param,"|||")
        if t[1]=="successful" then
            callback(1,t[2],t[3])
        end
        
    end
    local args = { key, url , title ,  filename , callbackLua }
    local className = "org/cocos2dx/lua/AppActivity"
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local ok = callJavaFun(className,"startDownload",args,sigs)
    return ok
end

function httpRequest(requrl,callback)
    --使用协程  异步下载HTTP文件
    
    
    --local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local co = coroutine.create(function ( a, b )   
        local socket = require("socket")
        
        
        -- 分解url  为host,port,path,query
        local urlpar = url.parse(requrl)
        local host = socket.dns.toip(urlpar.host)
        --local host = "183.60.44.74"
        local port = 80
        if urlpar.port ~= nil then
            port = urlpar.port
        end
        
        local tcp = socket:tcp()
        tcp:settimeout(0)
        
        local file = "/"
        if urlpar.path ~= nil then
            file = urlpar.path
        end
        if urlpar.query ~= nil then
            file = file .. "?" .. urlpar.query
        end 
        
        local sock = assert(socket.connect(host, port))  -- 创建一个 TCP 连接，连接到 HTTP 连接的标准端口 -- 80 端口上
        sock:send("GET " .. file .. " HTTP/1.0\r\n" .. "Host:" .. urlpar.host .. "\r\n\r\n" )
        --local path = writablePath .."abc.jpg"
        --local file = io.open(path, "wb")
        local hasHeader = false
        repeat
            coroutine.yield()
            local chunk, status, partial = sock:receive(packsize) 
            
            local mt = nil
            if chunk ~= nil then
                if hasHeader then
                    mt = chunk
                else 
                    mt = chunk:match("\r\n\r\n(.*)")
                    if mt ~= nil then
                        hasHeader = true
                        local header = headerToTable(string.sub(chunk,1,string.find(chunk,"\r\n\r\n")-1))
                        if header["location:"] ~= nil then
                            httpRequest(header["location:"],callback)
                            break
                        end
                    end
                end 
            else
                if hasHeader then
                    mt = partial
                else 
                    mt = partial:match("\r\n\r\n(.*)")
                    if mt ~= nil then
                        hasHeader = true
                        local header = headerToTable(string.sub(partial,1,string.find(partial,"\r\n\r\n")-1))
                        if header["location:"] ~= nil then
                            httpRequest(header["location:"],callback)
                            break
                        end
                    end
                end
            end
            
            if status=="closed" then
                callback(true,mt)
            else
                callback(false,mt)
            end
            -- print(chunk or partial)
        until status == "closed"
        sock:close()  -- 关闭 TCP 连接
    end)

    local sl = cc.Director:getInstance():getScheduler()
    local schedulerID = nil
    local function look()
        if coroutine.status(co) == "dead" then
            sl:unscheduleScriptEntry(schedulerID)
            --local path = writablePath .."abc.jpg"
            --local imgview=panel12:getChildByName("Image_13")
            --imgview:loadTexture(path)
        end
        coroutine.resume(co)
    end
    schedulerID = sl:scheduleScriptFunc(look, 1.0/60.0, false)--使用协程  异步下载HTTP文件

end


function httpDownload(requrl,filename,callback,pridata)
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local path = writablePath .. filename
    local file = io.open(path, "wb")
    local function reqcallback(isLast,data)
        
        file:write(data)
        if isLast then
            file:close()
        end
        if callback ~= nil then
            local l = string.len(data)
            callback(isLast,l,pridata)
        end
    end
    httpRequest(requrl,reqcallback)
end

function httpAsynRequest(requrl,callback)
    local retData = ""
    local function reqcallback(isLast,data)
        retData = retData .. data
        if isLast then
            callback(isLast,retData)
        end
    end
    httpRequest(requrl,reqcallback)
end