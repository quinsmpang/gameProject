local GameTaskModel =
{
   --别忘了 加 逗号 “ , ”---------------
   task_start              = 0,
   change_scene            = 0,
   taskFinishNum           = 0,
   arrayPass_gstatus       = {},
   arrayPass_bstatus       = {},
}
local meta = GameTaskModel

function meta.initTaskData(temp_conf)
    if temp_conf.pass_chest ~= 0 then
        meta.arrayPass_gstatus = {}
        meta.arrayPass_gstatus = Split(temp_conf.pass_gstatus,";")
    end  
    if temp_conf.pass_bchest ~= 0 then
        meta.arrayPass_bstatus = {}
        meta.arrayPass_bstatus = Split(temp_conf.pass_bstatus,";")
    end 
end 

function meta.changeTaskData(pos)
    if pos <= 4 and pos >= 1 then
        meta.arrayPass_gstatus[pos] = "1"
    elseif pos >= 5 and pos <= 8 then 
        meta.arrayPass_bstatus[pos - 4] = "1"
    end 
end 

--引用和全局，初始化----------------------------------------------------------------------------------

return GameTaskModel