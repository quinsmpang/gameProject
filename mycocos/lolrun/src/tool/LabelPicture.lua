require "Cocos2d"
require "Cocos2dConstants"


local function cclog(...)
    print(string.format(...))
end

local winSize = cc.Director:getInstance():getWinSize()

--------------------------------------------------------------------------
-------LabelPicture     不用setPath，直接就可以使用
--------------------------------------------------------------------------
--******************* 使用方法

--require之后，使用new就可以继承全部方法，设置图片的相对路径后即可安全使用
--注意  require之后，一定要先设置数字路径，不然无法访问图片  函数：setPath（）

--*******************
--测试文件test.lua


local LabelPicture = {
    mainLayer = nil;
    --锚点
    anchorPointX = 0;
    anchorPointY = 0;
    --布景长宽
    mainLayerWidth = 200;
    mainLayerHeight = 45;


    labelString = "";
    spriteTable = {};
    --记录中间位置的坐标 （有为想到到锚点跟中间点分开，所以需要记录）
    midPos = {x = nil,y = nil};
    leftestPosX = nil;
    leftestPosY = nil;

    unitLen     = nil;  --单位长度

    --图片的大小
    picWidth    = 26;
    picHeight   = 40;

    --间距    两个数字的距离
    distant     = nil;
    distantScale = 1;
    --数字图片路径
    path = "";


    ----test number
    --num = 100;
    --test_distantScale = 0.1;

}
local meta = LabelPicture
LabelPicture.__index = LabelPicture

function LabelPicture:new()
    --比较好的面向对象事例
    local self = {}
    setmetatable(self,LabelPicture)
    self.mainLayer = cc.Layer:create()
    --self.mainLayer = cc.LayerColor:create(cc.c4b(255,0,0,255))
    self.mainLayer:retain()
    print("LabelPicture:new()")

    --设置布景大小
    self.mainLayer:setContentSize(cc.size(self.mainLayerWidth,self.mainLayerHeight))
    local size = self.mainLayer:getContentSize()

    --设置中间点
    self.midPos.x = size.width / 2
    self.midPos.y = size.height/2

    --初始化最左边的Y，免得后面麻烦
    self.leftestPosY = self.midPos.y

    ----test 
    --local function onTouchesMoved(touches, event )
    --    local diff = touches[1]:getDelta()
    --    local currentPosX, currentPosY=  self.mainLayer:getPosition()
    --    self.mainLayer:setPosition(cc.p(currentPosX + diff.x, currentPosY + diff.y))
    --    self.num =  self.num + 1
    --    self.test_distantScale = self.test_distantScale + 0.1
    --    self.distantScale = self.test_distantScale
    --    self:setString(self.num)
    --end

    --local listener = cc.EventListenerTouchAllAtOnce:create()
    --listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    --local eventDispatcher = self.mainLayer:getEventDispatcher()
    --eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.mainLayer)
    return self
end



function LabelPicture:setString(str)
    if self.labelString == "" then
        if tonumber(str) == nil then
            cclog("*****  The Arg[1] is illegal string")
            return  nil
        end
    else
        self:setStringRelease()
    end
    ---------------------------------------------
    --把字符串保存到自己的labelString里面
    ---------------------------------------------
    self.labelString = tostring(str)
    ---------------------------------------------
    --得到一串数字
    ---------------------------------------------
    local num = tonumber(str)
    ---------------------------------------------
    --把上面那一串数字拆分,存放在numTable里面
    ---------------------------------------------
    local numTable = {}
    local len = string.len(self.labelString)
    
    ---------------------------------------------
    --有时候，数字会记录成1.23456789123456e+017 然后得到的len会多出e+0 三个位置，本来长度是10，会变成13
    --一般超过21亿以上就会出现科学记数法 ，所以都是e+0XX
    --下面是修正
    ---------------------------------------------
    if string.find(self.labelString,"e++0") then        --测试发现居然要 "++" 等于 “+”
        len = len - 2                                   --减2是因为 本来数字是1..91..9，总长度18,变成科学记数法为
                                                        --理论上：1点2..91..9e+017，字符串长度 18 + 1（点） + len("e+017") = 
                                                        --实际上：只保留到小数点后13(四舍五入)位,即 1+1+13+5 = 20
                                                        --所以  
                                                        --实际长度 = 20  +4(小数点后面13位的4位) - 5（e+017） - 1(实际上没有小数点)
    end                                     
    ---------------------------------------------
    --从高位取出来
    ---------------------------------------------
    for i = len,1,-1 do 
        numTable[i] = math.floor(num %10)
        num  = math.floor(num / 10)

    end


    ---------------------------------------------
    --初始化数字对应的图片 然后存放到spriteTable里面
    ---------------------------------------------
    for i = 1,len do 
        --local picturePath = string.format("res/Digital/number%d.png",numTable[i])
        local picturePath = string.format("number_0%d.png",numTable[i])
        --local picturePath = string.format("%d.png",numTable[i])
        self.spriteTable[i] = cc.Scale9Sprite:createWithSpriteFrameName(picturePath)
        self.spriteTable[i]:setPosition(cc.p(0,0))
        self.spriteTable[i]:retain()
        self.mainLayer:addChild(self.spriteTable[i])

    end
    ---------------------------------------------
    --确认最左边位置
    ---------------------------------------------
    self.unitLen = self:getUnitLen()    --单位长度 = 图片宽度 * 缩放因子
    if len%2 == 0 then
        --  注释：  最左边位置 = 中间位置 - 单位长度 * （数字数量的一半  -  1） - 半个单位长度
        self.leftestPosX = self.midPos.x - self.unitLen * (len / 2 -1) -self.unitLen / 2  
    else --len%2 == 1
        --  注释:   单数：   最左边位置 = 中间位置 - 单位长度 * （数字长度 - 1） / 2
        self.leftestPosX = self.midPos.x - self.unitLen * (len - 1)/2
    end
    ---------------------------------------------
    --如果数字的最左边超越布景的（0,0）的X,，则最左边设置为0
    ---------------------------------------------

    if self.leftestPosX < 0 then
        self.leftestPosX = self.unitLen / 2
    end
    ---------------------------------------------
    --布置数字位置
    ---------------------------------------------
    for i = 1,len do 
        self.spriteTable[i]:setPosition(cc.p(self.leftestPosX + self.unitLen * (i - 1),self.leftestPosY))
    end





end


function LabelPicture:setPosition(_x,_y)
    cclog("setPosition")
    if nil == _y then
        local posx = _x.x - self.anchorPointX * self.mainLayerWidth
        local posy =  _x.y - self.anchorPointY * self.mainLayerHeight
         return self.mainLayer:setPosition(cc.p(posx,
                                                posy))
    else
         return self.mainLayer:setPosition(cc.p(_x - self.anchorPointX * self.mainLayerWidth,
                                                _y - self.anchorPointY * self.mainLayerHeight))
    end
end
---------------------------------------------
--得到单位长度
---------------------------------------------
function LabelPicture:getUnitLen()
    local scale = self.spriteTable[1]:getScale()
    self.distant = self.picWidth * scale
    return self.distant * self.distantScale
end
---------------------------------------------
--得到布景对象
---------------------------------------------
function LabelPicture:getLayer()
    return self.mainLayer
end

function LabelPicture:setAnchorPoint(_x,_y)

    if nil == _y then
        self.anchorPointX = _x.x
        self.anchorPointY = _x.y
    else
        self.anchorPointX = _x
        self.anchorPointY = _y
    end
    local posX,posY = self.mainLayer:getPosition()
    --刷新位置
    self:setPosition(cc.p(posX,posY))
end

function LabelPicture:setScale(s)
    if type(s) == "string" then 
        cclog("***** setScale arg must be number *****") 
        return
    end
    for i = 1,#self.spriteTable do 
        self.spriteTable[i]:setScale(s)
    end
end


--设置图片相对路径
--自从使用缓存图片功能之后，设置图片相对路径已经不需要了，直接使用就可以了
--function LabelPicture:setPath(s)
--    local len = string.len(s)
--    if string.find(s,'/',len - 1) then
--        self.path = s
--    else 
--        self.path = s..'/'
--    end
--end


function LabelPicture:setDistant(d)
    self.distantScale = d;
    if self.labelString ~= "" then
        self.setString(self.labelString)
    end
end
---------------------------------------------
--在如果调用setString，需要释放某些对象
---------------------------------------------
function LabelPicture:setStringRelease()
    labelString = "";
    for i = 1,#self.spriteTable do
        self.spriteTable[i]:removeFromParent()
        self.spriteTable[i]:release()
    end
    self.spriteTable = {}

end


------------------------------------------------------------------------------------------
--由于精灵retain，layer也是retain，因此，这个类不需要的时候，调用release
------------------------------------------------------------------------------------------
function LabelPicture:release()
    self.mainLayer:release()
    self.mainLayer = nil
    self:setStringRelease()
end


--test
function LabelPicture:log(t)
    for i = 1,#t do 
        cclog("t[%d] = %d",i,t[i])
    end
end


return meta