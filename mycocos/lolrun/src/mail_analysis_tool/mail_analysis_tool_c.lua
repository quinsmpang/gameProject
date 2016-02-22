
C_game_mail_c = class("C_game_mail_c")

local mail_m = require "src/mail_analysis_tool/mail_analysis_tool_m"
local cjson = require "cjson"

function C_game_mail_c:create()
    local game_mail = C_game_mail_c:new()

    return game_mail
end

--[[
    1获取mail
    2callback
        解析邮件，保存到g_mail里面
        设置一下邮件的数量        
--]]
function C_game_mail_c:httpGetMyMailBox(callback)
    --Func_HttpRequest(requrl,extra,callback,needLoading)
    callback("success","type=1;mail_id=2;zhuanshi=10;jinbi=20;tili=30;message=abcdefg||type=0;;mail_id=3zhuanshi=10;jinbi=20;tili=30;message=abcdefg")
end

--[[解析 来自网络的邮箱数据
    把解析完的结果保存到 mail_m.mails
--]]
function C_game_mail_c:decodeMailData(str)  
   local decode_mail_data = cjson.decode(str)
   return decode_mail_data
end

--[[领取某邮件
    如果是资源，则会返回资源数量
    player_id   玩家id
    email       邮件信息
    callback    回调函数》》一般处理金币数量
--]]
function C_game_mail_c:openMailBox(player_id,email,callback)
    --http发送获取某email

end







