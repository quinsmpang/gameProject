

--����
local mail = {
    --isMessage = nil;
    --gold_num = 0;
    --power_num = 0;
    --diamond = 0;
    --equipment_id = -1;
    --message = "";
    mail_box_data = nil;  --���ڱ����ѽ������������� table��ʽ


}
--local meta = mail

--����ʹ��
--�����ѽ���������Ϣ
function mail:saveMailData(mail_box_table)
    mail.mail_box_data = mail_box_table
end
--��ȡ������Ϣ
function mail:getMailData()
    assert(mail.mail_box_data,"mail.mail_box_data is nil ,init it before use it!")
    return mail.mail_box_data
end
--��ȡ�ʼ�����
function mail:getMailNum()
    assert(mail.mail_box_data,"mail.mail_box_data is nil ,init it before use it!")
    return #mail.mail_box_data
end

return mail