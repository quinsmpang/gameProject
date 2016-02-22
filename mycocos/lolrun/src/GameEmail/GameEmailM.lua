local GameEmailModel =
{
   --别忘了 加 逗号 “ , ”---------------
   email_start              = 0,
   change_scene            = 0,
   -------------------------------------------
    mail_box_data = nil;  --用于保存已解析的邮箱数据 table格式


}
local meta = GameEmailModel

local email_status = {
    lastest = "0";      --未处理==未阅读 + 未领取
    had_read = "1";     --已阅读 == 已阅读 + 未领取
    had_lingqu = "2";   --已领取


}
--引用和全局，初始化----------------------------------------------------------------------------------
function GameEmailModel:saveMailData(mail_box_table)
    self.mail_box_data = mail_box_table
end

--领取新手礼包
function GameEmailModel:removeNewPlayerGift()
    for i = 1,#GameEmailModel.mail_box_data do 
        if GameEmailModel.mail_box_data[i].email_id == "12" then  --新手礼包号 邮件号为 12
            table.remove(GameEmailModel.mail_box_data, i)
            return
        end
    end
end

--获取当前未阅读邮件数量
function GameEmailModel:getNotReadMail_Number()
    local num = 0
    for i = 1,#GameEmailModel.mail_box_data do 
        if GameEmailModel.mail_box_data[i].email_status == email_status.lastest then  --新手礼包号 邮件号为 12
            num = num + 1
        end
    end
    return num
end



function GameEmailModel:quickSort_onetime_withKey(tb,idx_begin,idx_end,key,chang_func)
    local val_flag = tb[idx_begin]
    local left = idx_begin
    local right = idx_end

    --self:log(tb,key)    
    while left < right do 
        while left < right and chang_func(val_flag[key])<=chang_func(tb[right][key]) do    -- 相等的统一放在左边
            right =right - 1
        end

        if left < right then 
            tb[left] = tb[right]
            left = left + 1
        end

        while left < right and chang_func(tb[left][key]) <= chang_func(val_flag[key])do     -- 相等的统一放在左边
            left = left + 1
        end
        if left < right then 
            tb[right] = tb[left]
            right = right - 1
        end
        --self:log(tb,key)    

    end
    tb[left] = val_flag
    --self:log(tb,key)
    return left

end


function GameEmailModel:quickSort_withKey(tb,idx_begin,idx_end,key,chang_func)
    --cclog("%d--%d",idx_begin,idx_end)
    if idx_begin < idx_end then 
        local half = GameEmailModel:quickSort_onetime_withKey(tb,idx_begin,idx_end,key,chang_func)
        GameEmailModel:quickSort_withKey(tb,idx_begin,half-1,key,chang_func)
        GameEmailModel:quickSort_withKey(tb,half+1,idx_end,key,chang_func)
    end
end

return GameEmailModel