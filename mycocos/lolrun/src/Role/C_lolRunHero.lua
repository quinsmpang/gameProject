
C_lolRunHero = class("C_lolRunHero",function()
    return cc.Node:create()
end)



--[[例子
    require "src/C_lolRunHero/C_lolRunHero"
    local jumpRole = C_lolRunHero:create(Role)      --注意 Role.ani不能事先addChild
    jumpRole:setPosition(cc.p(winSize.width/2,winSize.height/2))
    scene:addChild(jumpRole)
    jumpRole:addPhysicsBody()

--]]



-------------------------------------------private
C_lolRunHero.node = nil --包着英雄的节点   貌似直接用self就可以了
C_lolRunHero.role = nil
C_lolRunHero.hero = nil --英雄动画
C_lolRunHero.x = nil    --英雄目前所在坐标x
C_lolRunHero.y = nil    --英雄目前所在坐标y
C_lolRunHero.toX = nil  --英雄这一帧需要到达的位置x
C_lolRunHero.toY = nil  --英雄这一整需要到达的位置y
C_lolRunHero.stdX = 200 --标准位置，弹力那边需要使用 --需要预先初始化 --未做
C_lolRunHero.stdY = nil --标准位置
C_lolRunHero.scheduler = nil
-------------------------------------------private 物理相关
C_lolRunHero.vx0 = 0;           --水平方向初速度
C_lolRunHero.vx = 0;            --水平方向瞬时速度
C_lolRunHero.vx_a = 0;          --水平方向加速度
C_lolRunHero.vx_k = 100;          --水平方向弹性系数（不完全是弹性系数）
C_lolRunHero.diffX = 0;

C_lolRunHero.vy0 = 0;           --竖直方向初速度
C_lolRunHero.vy = 0;            --竖直方向瞬时速度
C_lolRunHero.G = 150;           --竖直方向加速度
C_lolRunHero.diffY  = 0;
------------------------------------------调节参数
C_lolRunHero.H1 = 130;           --1跳的跳跃高度
C_lolRunHero.H2 = 130            --2跳的跳跃高度
C_lolRunHero.T1 = 0.25;          --1跳的腾空时间   --腾空时间为:[0,H1]所使用的时间
C_lolRunHero.T2 = 0.25;          --2跳的腾空时间   --腾空时间为:[0,H2]所使用的时间
C_lolRunHero.H3 = 130            --3跳的跳跃高度
C_lolRunHero.T3 = 0.25;          --3跳的腾空时间   --腾空时间为:[0,H3]所使用的时间
C_lolRunHero.Ht = 200            --弹簧的高度
C_lolRunHero.Tt = 0.25;          --弹簧落地时间   --腾空时间为:[0,Ht]所使用的时间
C_lolRunHero.Hg = 640            --滑翔高度
C_lolRunHero.Th = 6;             --滑翔时间   --腾空时间为:[0,Hg]所使用的时间
------------------------------------------
C_lolRunHero.second = 1/60;     -- 一帧的时间
C_lolRunHero.jumpCount = 0      --跳跃次数 记录，每跳一次加1
 


--------------------------------------------public
--------------------------------------------public
--------------------------------------------public
--------------------------------------------public
--------------------------------------------public
function C_lolRunHero:create(role)
    self = C_lolRunHero.new()
    self.role = role
    self.hero = role.ani
    local parent = self.hero:getParent()
    if parent then 
        cclog("********** Err :".."C_lolRunHero create false".." **********")
        cclog("********** Err :".."role must be no parent".." **********")
        
    else 
        this = self
        self.hero:setPosition(cc.p(0,0))
        self:addChild(self.hero)
    end
    self:initStdG()
    return self
    
end

function C_lolRunHero:getRole()
    return self.role
end

---[[
--生成物理特性
function C_lolRunHero:addPhysicsBody()
    local frame = 1
    
    local function tick(dt)
        
        if g_isPause then--暂停时 防止速度无限增大
            return
        end

        local num = 60/g_frame
        if frame % num == 0 then
            frame = 1

            self.x,self.y = self:getPosition()
            --Y
            local diffY = self.vy*self.second - 0.5*self.G*self.second*self.second
            self.vy = self.vy - self.G*self.second
            self.toY = self.y + diffY   --记录未来的位置
            --X
            self.vx_a = self.vx_k*(self.stdX - self.x)
            --self.vx = self.vx + self.vx_a*self.second
            local diffX = self.vx*self.second + 0.5*self.vx_a * self.second * self.second
            self.toX = self.x + diffX
            --if self.toX > self.stdX and self.vx_a >0 then 
            --    self.toX = self.stdX
            --    self.vx = 0
            --end
            --if math.abs(self.stdX-self.toX) <= 5 then 
            --    self.toX = self.stdX
            --    self.vx = 0
            --end
        else
            frame = frame + 1
        end
        
        --[[
        --解开注释，可以让其自然下落
        if self.toY <=200 then 
            self.toY = 200
            self.vy = 0
        end
        if math.abs(self.stdX-self.toX) <= 2 then 
            self.toX = self.stdX
            self.vx = 0
        end
        self:setPosition(cc.p(self.toX,self.toY))
        --]]
    end
    --local scheduler = cc.Director:getInstance():getScheduler()
    --self.scheduler = scheduler:scheduleScriptFunc(tick, 0, false)
    self:scheduleUpdateWithPriorityLua(tick,0)
end

--]]
--获取预判位置
function C_lolRunHero:getNextPosition()
    return {x = self.toX,y = self.toY}
end
--获取当前位置
function C_lolRunHero:getCurPosition()
    return {x = self.x,y = self.y}
end
--1跳
function C_lolRunHero:jump1()
    --self.G = 2*self.H1/self.T1/self.T1
    self:setG(self.H1,self.T1)
    self:setVy(2*self.H1/self.T1)
end
--2跳
function C_lolRunHero:jump2()
    --self.G = 2*self.H2/self.T2/self.T2
    self:setG(self.H2,self.T2)
    self:setVy(2*self.H2/self.T2)
end
--3跳
function C_lolRunHero:jump3()
    --self.G = 2*self.H3/self.T3/self.T3
    self:setG(self.H3,self.T3)
    self:setVy(2*self.H3/self.T3)
end
--4跳(4跳和3跳一样)
function C_lolRunHero:jump4()
    --self.G = 2*self.H3/self.T3/self.T3
    self:setG(self.H3,self.T3)
    self:setVy(2*self.H3/self.T3)
end
--弹簧
function C_lolRunHero:jumpTan()
    --self.G = 2*self.Ht/self.Tt/self.Tt
    self:setG(self.Ht,self.Tt)
    self:setVy(2*self.Ht/self.Tt)
end
--滑翔
function C_lolRunHero:jumpGliding()
    self:setG(self.Hg,self.Th)
end
--设置竖直方向速度
function C_lolRunHero:setVy(vy)
    self.vy = vy
end
--设置水平方向速度
function C_lolRunHero:setVx(vx)
    self.vx = vx
end
--设置竖直方向速度为零
function C_lolRunHero:setVyZero()
    self:initStdG()
    self.vy = 0
end
--设置水平方向速度为零
function C_lolRunHero:setVxZero()
    self.vx = 0
end
--设置X方向的标准位置
--作用：如果英雄离开这个位置的时候，会受到一个弹簧的弹力，导致英雄会有一个被拉会到X方向标准位置的力
function C_lolRunHero:setStdX(stdx)
    self.stdX = stdx
end
function C_lolRunHero:getStdX()
    return self.stdX
end
function C_lolRunHero:initStdG()
    self:setG(self.H1,self.T1)
end
--根据帧速率调节数值(传入的是一个均值)
function C_lolRunHero:AdjustFrame(frame)
    if frame >= 50 then
        self.second = 1/60--帧的时间
        self.vx_k   = 100--弹性系数
    else 
        self.second = 1/30--帧的时间
        self.vx_k   = 50--弹性系数
    end
end
--根据场景速度设置跳跃时间
function C_lolRunHero:SetTimes(scene_speed)
    self.T1 = 0.25*7/scene_speed;       --1跳的腾空时间   --腾空时间为:[0,H1]所使用的时间
    self.T2 = 0.25*7/scene_speed;                     --2跳的腾空时间   --腾空时间为:[0,H2]所使用的时间
    self.T3 = 0.25*7/scene_speed;                     --3跳的腾空时间   --腾空时间为:[0,H3]所使用的时间
    self.Tt = 0.25*7/scene_speed;                     --弹簧落地时间   --腾空时间为:[0,Ht]所使用的时间
    self.Th = 6*7/scene_speed;                        --滑翔时间   --腾空时间为:[0,Hg]所使用的时间
end

---------------------------------------------private
---------------------------------------------private
---------------------------------------------private
---------------------------------------------private
---------------------------------------------private
--给予对象一个速度
--function C_lolRunHero:setVelocityY(y)
--    self.vy = y
--end
--function C_lolRunHero:setVelocityX(x)
--    self.vx = x
--end
function C_lolRunHero:setG(h,t)     --h为最高高度，t是从起跳到最高高度的时间
    self.G = 2*h/t/t
end
function C_lolRunHero:getAnimation()
    return self.hero:getAnimation()
end

function C_lolRunHero:getDiff()
    return {x = self.diffX,y = self.diffY}
end


--------------------------------------------遗弃
----删除物理特性
--function C_lolRunHero:removePhysicsBody()
--    scheduler:unscheduleScriptEntry(self.scheduler)
--end
