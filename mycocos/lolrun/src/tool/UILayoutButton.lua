local UILayoutButton = 
{

}
local meta = UILayoutButton


--引用和全局，初始化----------------------------------------------------------------------------------

--UIButton初始化
function meta:createUIButton(Arrbutton)
        --Arrbutton={label_type = ,button_type = ,label = "",font = "",font_size = ,button1 = "",button2 = "",x = , y= }
        --字体类型,按钮类型,内容,字体,字大小,按钮1,按钮2,x,y
        local controlBtn = nil
        local btn_size = nil
        -------------------------------- 一个按钮---------------------------------
        if Arrbutton.button_type == BUTTON_TYPE_ENUM.normal then 
            local btnNormal = cc.Scale9Sprite:createWithSpriteFrameName(Arrbutton.button1)
            btn_size = btnNormal:getContentSize()
            --字体类型
            local label = nil
            if Arrbutton.label_type == LABEL_TYPE_ENUM.ttf then
                label = cc.LabelTTF:create(Arrbutton.label,Arrbutton.font,Arrbutton.font_size)
            elseif Arrbutton.label_type == LABEL_TYPE_ENUM.bmfont then
                label = cc.LabelBMFont:create(Arrbutton.label,Arrbutton.font)
                
            end
            controlBtn = cc.ControlButton:create(label,btnNormal)--创建按钮
            
        -------------------------------- 两个按钮 ---------------------------------
        elseif Arrbutton.button_type == BUTTON_TYPE_ENUM.high then 
            local btnNormal =  cc.Scale9Sprite:createWithSpriteFrameName(Arrbutton.button1)
            local btnDown = cc.Scale9Sprite:createWithSpriteFrameName(Arrbutton.button2)
            btn_size = btnNormal:getContentSize()
            --字体类型
            local label = nil
            if Arrbutton.label_type == LABEL_TYPE_ENUM.ttf then
                label = cc.LabelTTF:create(Arrbutton.label,Arrbutton.font,Arrbutton.font_size)
            elseif Arrbutton.label_type == LABEL_TYPE_ENUM.bmfont then
                label = cc.LabelBMFont:create(Arrbutton.label,Arrbutton.font)
            end
            controlBtn = cc.ControlButton:create(label,btnNormal)--创建按钮
            controlBtn:setBackgroundSpriteForState(btnDown,cc.CONTROL_STATE_HIGH_LIGHTED)--高亮 按钮第二状态
        end

        
        controlBtn:setPreferredSize(btn_size)--固定按钮大小
        controlBtn:setPosition(Arrbutton.x,Arrbutton.y)
        
        --常用回调
        --controlBtn:registerControlEventHandler(testControl,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)--按钮内弹起
        --controlBtn:registerControlEventHandler(testControl,cc.CONTROL_EVENTTYPE_TOUCH_UP_OUTSIDE)--按钮外弹起
        --controlBtn:registerControlEventHandler(testControl,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)--按下按钮

        return controlBtn--返回出去自己写回调
end



return UILayoutButton

