

C_Rect = class("C_Rect")

--[[例子
    require "src/C_Rect/C_Rect"
    local CRect = C_Rect.new()
    local xx = winSize.width/2
    local yy = winSize.height/2
    local rect1 = {x = xx,y = yy, width = 100,height = 100}
    local rect2 = {x = xx,y = yy +90 ,width = 100,height = 110}
    local point = CRect:Collision(rect1, rect2)
--]]



-----------------------------------------------public
--A1原来位置
--A2预判位置
--B1原来位置
--B2预判位置
function C_Rect:Collision(A1,A2,B1,B2)
    if cc.rectIntersectsRect( A2, B2 ) then --相对A来说
        if self:rButton(A1) >= self:rHead(B1) then --地板
            --cclog("button")
            return cc.p(0,-1)
        elseif self:rHead(A1) <= self:rButton(B1)  then --楼顶
            --cclog("head")
            return cc.p(0,1)
        elseif self:rRight(A1) <= self:rLeft(B1) then --右边
            --cclog("right")
            return cc.p(1,0)

        elseif self:rLeft(A1) >= self:rRight(B1)  then --左边
            --cclog("left")
            return cc.p(-1,0)

        end
    end

    --cclog("no")
    return cc.p(0,0)    --表示没有碰撞
end
--------------------------------------------------回去碰撞后，相交的矩形
function C_Rect:CollisionRect(A,B)
    return cc.rectIntersection(A,B)
end



-------------------------------------------private
function C_Rect:rLeft(rect)
    return rect.x
end
function C_Rect:rRight(rect)
    return rect.x+rect.width
end
function C_Rect:rHead(rect)
    return rect.y+rect.height
end
function C_Rect:rButton(rect)
    return rect.y
end
--------------------------------------------private
--function C_Rect:pointButton()
--    return {x = 0,y = -1}
--end
--function C_Rect:pointLeft()
--    return {x = -1,y = 0}
--end
--function C_Rect:pointRight()
--    return {x = 1,y = 0}
--end 
--function C_Rect:pointHead()
--    return {x = 0,y = 1}
--end
--------------------------------------------private
--获取两个远点的向量，由rect1的原点指向rect2的原点
--rect1为第一个位置
--rect2为第二个位置
--function C_Rect:Vector(rect1,rect2)
--    local p = {x = 0,y=0}
--    p.x = rect2.x - rect1.x
--    p.y = rect2.y - rect1.y
--    return p
--end
--function C_Rect:isVectorEqual(p1,p2)
--    if p1.x == p2.x and p1.y == p2.y then 
--        return true
--    end
--    return false
--end


-------------------------------------------------遗弃
--A设第一个为主角
--判断矩形A,矩形B是否相交
--以A为第一人称
--有优先级  下>右>上>左
--优先级的意思，假如A的右上角与B的左下角相交，会有限判定是右相交
--function C_Rect:Collision(A, B)
--    if cc.rectIntersectsRect( A, B ) then --相对A来说
--        if self:rButton(A) < self:rHead(B) and self:rHead(A) > self:rHead(B) then --地板
--            cclog("button")
--            return cc.p(0,-1)
--        elseif self:rRight(A) > self:rLeft(B) and self:rLeft(A) < self:rLeft(B) then --右边
--            cclog("right")
--            return cc.p(1,0)
--        elseif self:rHead(A) > self:rButton(B) and self:rButton(A) <self:rButton(B) then --楼顶
--            cclog("head")
--            return cc.p(0,1)
--        elseif self:rLeft(A) < self:rRight(B) and self:rRight(A) > self:rRight(B) then --左边
--            cclog("left")
--            return cc.p(-1,0)
--        end
--    end
--    cclog("no")
--    return cc.p(0,0)    --表示没有碰撞
--end