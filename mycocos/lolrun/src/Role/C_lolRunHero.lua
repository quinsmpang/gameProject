
C_lolRunHero = class("C_lolRunHero",function()
    return cc.Node:create()
end)



--[[����
    require "src/C_lolRunHero/C_lolRunHero"
    local jumpRole = C_lolRunHero:create(Role)      --ע�� Role.ani��������addChild
    jumpRole:setPosition(cc.p(winSize.width/2,winSize.height/2))
    scene:addChild(jumpRole)
    jumpRole:addPhysicsBody()

--]]



-------------------------------------------private
C_lolRunHero.node = nil --����Ӣ�۵Ľڵ�   ò��ֱ����self�Ϳ�����
C_lolRunHero.role = nil
C_lolRunHero.hero = nil --Ӣ�۶���
C_lolRunHero.x = nil    --Ӣ��Ŀǰ��������x
C_lolRunHero.y = nil    --Ӣ��Ŀǰ��������y
C_lolRunHero.toX = nil  --Ӣ����һ֡��Ҫ�����λ��x
C_lolRunHero.toY = nil  --Ӣ����һ����Ҫ�����λ��y
C_lolRunHero.stdX = 200 --��׼λ�ã������Ǳ���Ҫʹ�� --��ҪԤ�ȳ�ʼ�� --δ��
C_lolRunHero.stdY = nil --��׼λ��
C_lolRunHero.scheduler = nil
-------------------------------------------private �������
C_lolRunHero.vx0 = 0;           --ˮƽ������ٶ�
C_lolRunHero.vx = 0;            --ˮƽ����˲ʱ�ٶ�
C_lolRunHero.vx_a = 0;          --ˮƽ������ٶ�
C_lolRunHero.vx_k = 100;          --ˮƽ������ϵ��������ȫ�ǵ���ϵ����
C_lolRunHero.diffX = 0;

C_lolRunHero.vy0 = 0;           --��ֱ������ٶ�
C_lolRunHero.vy = 0;            --��ֱ����˲ʱ�ٶ�
C_lolRunHero.G = 150;           --��ֱ������ٶ�
C_lolRunHero.diffY  = 0;
------------------------------------------���ڲ���
C_lolRunHero.H1 = 130;           --1������Ծ�߶�
C_lolRunHero.H2 = 130            --2������Ծ�߶�
C_lolRunHero.T1 = 0.25;          --1�����ڿ�ʱ��   --�ڿ�ʱ��Ϊ:[0,H1]��ʹ�õ�ʱ��
C_lolRunHero.T2 = 0.25;          --2�����ڿ�ʱ��   --�ڿ�ʱ��Ϊ:[0,H2]��ʹ�õ�ʱ��
C_lolRunHero.H3 = 130            --3������Ծ�߶�
C_lolRunHero.T3 = 0.25;          --3�����ڿ�ʱ��   --�ڿ�ʱ��Ϊ:[0,H3]��ʹ�õ�ʱ��
C_lolRunHero.Ht = 200            --���ɵĸ߶�
C_lolRunHero.Tt = 0.25;          --�������ʱ��   --�ڿ�ʱ��Ϊ:[0,Ht]��ʹ�õ�ʱ��
C_lolRunHero.Hg = 640            --����߶�
C_lolRunHero.Th = 6;             --����ʱ��   --�ڿ�ʱ��Ϊ:[0,Hg]��ʹ�õ�ʱ��
------------------------------------------
C_lolRunHero.second = 1/60;     -- һ֡��ʱ��
C_lolRunHero.jumpCount = 0      --��Ծ���� ��¼��ÿ��һ�μ�1
 


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
--������������
function C_lolRunHero:addPhysicsBody()
    local frame = 1
    
    local function tick(dt)
        
        if g_isPause then--��ͣʱ ��ֹ�ٶ���������
            return
        end

        local num = 60/g_frame
        if frame % num == 0 then
            frame = 1

            self.x,self.y = self:getPosition()
            --Y
            local diffY = self.vy*self.second - 0.5*self.G*self.second*self.second
            self.vy = self.vy - self.G*self.second
            self.toY = self.y + diffY   --��¼δ����λ��
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
        --�⿪ע�ͣ�����������Ȼ����
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
--��ȡԤ��λ��
function C_lolRunHero:getNextPosition()
    return {x = self.toX,y = self.toY}
end
--��ȡ��ǰλ��
function C_lolRunHero:getCurPosition()
    return {x = self.x,y = self.y}
end
--1��
function C_lolRunHero:jump1()
    --self.G = 2*self.H1/self.T1/self.T1
    self:setG(self.H1,self.T1)
    self:setVy(2*self.H1/self.T1)
end
--2��
function C_lolRunHero:jump2()
    --self.G = 2*self.H2/self.T2/self.T2
    self:setG(self.H2,self.T2)
    self:setVy(2*self.H2/self.T2)
end
--3��
function C_lolRunHero:jump3()
    --self.G = 2*self.H3/self.T3/self.T3
    self:setG(self.H3,self.T3)
    self:setVy(2*self.H3/self.T3)
end
--4��(4����3��һ��)
function C_lolRunHero:jump4()
    --self.G = 2*self.H3/self.T3/self.T3
    self:setG(self.H3,self.T3)
    self:setVy(2*self.H3/self.T3)
end
--����
function C_lolRunHero:jumpTan()
    --self.G = 2*self.Ht/self.Tt/self.Tt
    self:setG(self.Ht,self.Tt)
    self:setVy(2*self.Ht/self.Tt)
end
--����
function C_lolRunHero:jumpGliding()
    self:setG(self.Hg,self.Th)
end
--������ֱ�����ٶ�
function C_lolRunHero:setVy(vy)
    self.vy = vy
end
--����ˮƽ�����ٶ�
function C_lolRunHero:setVx(vx)
    self.vx = vx
end
--������ֱ�����ٶ�Ϊ��
function C_lolRunHero:setVyZero()
    self:initStdG()
    self.vy = 0
end
--����ˮƽ�����ٶ�Ϊ��
function C_lolRunHero:setVxZero()
    self.vx = 0
end
--����X����ı�׼λ��
--���ã����Ӣ���뿪���λ�õ�ʱ�򣬻��ܵ�һ�����ɵĵ���������Ӣ�ۻ���һ�������ᵽX�����׼λ�õ���
function C_lolRunHero:setStdX(stdx)
    self.stdX = stdx
end
function C_lolRunHero:getStdX()
    return self.stdX
end
function C_lolRunHero:initStdG()
    self:setG(self.H1,self.T1)
end
--����֡���ʵ�����ֵ(�������һ����ֵ)
function C_lolRunHero:AdjustFrame(frame)
    if frame >= 50 then
        self.second = 1/60--֡��ʱ��
        self.vx_k   = 100--����ϵ��
    else 
        self.second = 1/30--֡��ʱ��
        self.vx_k   = 50--����ϵ��
    end
end
--���ݳ����ٶ�������Ծʱ��
function C_lolRunHero:SetTimes(scene_speed)
    self.T1 = 0.25*7/scene_speed;       --1�����ڿ�ʱ��   --�ڿ�ʱ��Ϊ:[0,H1]��ʹ�õ�ʱ��
    self.T2 = 0.25*7/scene_speed;                     --2�����ڿ�ʱ��   --�ڿ�ʱ��Ϊ:[0,H2]��ʹ�õ�ʱ��
    self.T3 = 0.25*7/scene_speed;                     --3�����ڿ�ʱ��   --�ڿ�ʱ��Ϊ:[0,H3]��ʹ�õ�ʱ��
    self.Tt = 0.25*7/scene_speed;                     --�������ʱ��   --�ڿ�ʱ��Ϊ:[0,Ht]��ʹ�õ�ʱ��
    self.Th = 6*7/scene_speed;                        --����ʱ��   --�ڿ�ʱ��Ϊ:[0,Hg]��ʹ�õ�ʱ��
end

---------------------------------------------private
---------------------------------------------private
---------------------------------------------private
---------------------------------------------private
---------------------------------------------private
--�������һ���ٶ�
--function C_lolRunHero:setVelocityY(y)
--    self.vy = y
--end
--function C_lolRunHero:setVelocityX(x)
--    self.vx = x
--end
function C_lolRunHero:setG(h,t)     --hΪ��߸߶ȣ�t�Ǵ���������߸߶ȵ�ʱ��
    self.G = 2*h/t/t
end
function C_lolRunHero:getAnimation()
    return self.hero:getAnimation()
end

function C_lolRunHero:getDiff()
    return {x = self.diffX,y = self.diffY}
end


--------------------------------------------����
----ɾ����������
--function C_lolRunHero:removePhysicsBody()
--    scheduler:unscheduleScriptEntry(self.scheduler)
--end
