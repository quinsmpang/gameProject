

--属性
local mail = {
    --isMessage = nil;
    --gold_num = 0;
    --power_num = 0;
    --diamond = 0;
    --equipment_id = -1;
    --message = "";
    mail_box_data = nil;  --用于保存已解析的邮箱数据 table格式


}
--local meta = mail

--啊洪使用
--保存已解析邮箱信息
function mail:saveMailData(mail_box_table)
    mail.mail_box_data = mail_box_table
end
--获取邮箱信息
function mail:getMailData()
    assert(mail.mail_box_data,"mail.mail_box_data is nil ,init it before use it!")
    return mail.mail_box_data
end
--获取邮件数量
function mail:getMailNum()
    assert(mail.mail_box_data,"mail.mail_box_data is nil ,init it before use it!")
    return #mail.mail_box_data
end

return mail