--经验类
Experience = class("Experience")
Experience.__index = Experience




--创建经验
function Experience:create()
  local experience = Experience.new() 


  return experience
end 

--参数：等级
--注意：获得的值会带小数（小数在表里面可能不显示，但是实际上是存在的，显示格式问题）
function Experience:getExpFromLevel(_level)
    for j = 2,#g_experience_conf do 
        if g_experience_conf[j].exp_level == _level then
            if g_experience_conf[j].exp_level ~= "null" then 
                return g_experience_conf[j].exp_need
            else 
                cclog("********** can not find the value **********")
                return nil
            end
        end
    end
    cclog("********** can not find the ref **********")
end