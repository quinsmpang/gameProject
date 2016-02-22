local GameEmailView=
{
    mainLayer = nil,  --本图层
    panel_email = nil, 
    isOpened       = true ,  --本图层是否开启
    readyMeta      = nil,
    -----------------------------jie
    ListView_email = nil;   --listview
    data = nil;             --邮件数据
    email_number_label = nil;
    black_board = nil ;     --用于阅读邮件的界面
    back_board_textfield = nil; --阅读文字的容器
    new_tag = 1;
    content_max_len = 16 * 3;
    cur_listview_Idx = nil; --当前点击listview的idx

    -----------------------------jie
}--@ 游戏逻辑主图层
local meta = GameEmailView
local cjson = require "cjson"
--引用和全局，初始化----------------------------------------------------------------------------------
require "src/init"
local EmailM = require "src/GameEmail/GameEmailM"
local email_type = {
    notification = "1";   --公告
    reward = "2";         --奖励
    onsale = "3";         --订单
}

local email_status = {
    lastest = "0";      --未处理==未阅读 + 未领取
    had_read = "1";     --已阅读 == 已阅读 + 未领取
    had_lingqu = "2";   --已领取
}
local email_icon = {
    gold = "1";
    diamond = "2";
    physics = "3";
}

function meta:init(...)
    meta.mainLayer = CCLayer:create()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/email/email.plist")
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/ani/lingqu_texiao/getitem/getitem.csb")
    meta:createEmail()

    
    --统计成功进入邮件界面

    return meta.mainLayer
end 

----设置系统的数据---------------------------------------------------------------------------------------------
function meta:setUserData()
    
end 

--界面布局--------------------------------------------------------------------------------------------------
--游戏引导界面
function meta:createEmail()
    --local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/game_email/game_email.ExportJson")
    local uiLayout = ccs.GUIReader:getInstance():widgetFromJsonFile("res/ui/game_guide/game_email.ExportJson")
    --uiLayout:setPosition(g_origin.x,g_origin.y)
    meta.panel_email = uiLayout:getChildByName("Panel_email")
    local button_back = meta.panel_email:getChildByName("Button_back")

--阅读层 返回按钮
    local function black_bord_back_TouchEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
            cclog("black_bord_back_TouchEvent")
            --local not_read_mail_num = EmailM:getNotReadMail_Number()
            --meta.readyMeta:setEmailNum(not_read_mail_num)
            meta:setNotReadMailNumber()
            meta.black_board:setVisible(false)
            local list_view = meta.black_board:getChildByTag(1) --1表示listview
            list_view:removeFromParent()
            meta.back_board_textfield = nil
        end
    end

    meta.black_board = uiLayout:getChildByName("Panel_look")
    local black_bord_back = meta.black_board:getChildByName("Button_lookBack")
    black_bord_back:addTouchEventListener(black_bord_back_TouchEvent)
    --meta.black_board:setVisible(true)
    --local list_view = meta.black_board:getChildByName("scroll_view")
    --local size = list_view:getContentSize()
    --local x,y = list_view:getPosition()
    --[[删除
    meta.back_board_textfield = meta.black_board:getChildByName("scroll_view"):getChildByName("Label_lookEmail")
    meta.back_board_textfield:setAnchorPoint(cc.p(0,1))
    meta.back_board_textfield:setPosition(list_view:getInnerContainer():convertToNodeSpace(cc.p(x,y+size.height)))
    --]]
--listview
    meta.ListView_email = meta.panel_email:getChildByName("ListView_email")
    self:initMailBox()




    --返回(释放)事件 
    local function backEvent(touch,eventType)
        if eventType == ccui.TouchEventType.began then 
           print(touch:getName())
           meta:remove()
       end 
    end 
    
    --添加监听
    button_back:addTouchEventListener(backEvent)
    meta.mainLayer:addChild(uiLayout)


end 

--listview callback touchevent
function meta.list_view_touch_event(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_START then
        cclog("list_view")
        print("select child index = ",sender:getCurSelectedIndex())
        meta.cur_listview_Idx = sender:getCurSelectedIndex()
    end
end

--领取回调
function meta.lingqu_TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        cclog("lingqu")

        local email = meta.data[meta.cur_listview_Idx+1]
        cclog("ling qu~~~~")           
        --创建领取雾态窗口
        local lingqu_lingqu = meta:lingqu_window()
        meta.panel_email:addChild(lingqu_lingqu,9999)

        --发送领取请求
        local function lingqu_callback(msg,a,b)
            local decode_msg = cjson.decode(msg)
            cclog("msg")  --暂时貌似是返回true
            local lingqu_texiao = nil
            if decode_msg.code == 1 then   --表示成功
                lingqu_lingqu:removeFromParent()    --这个事领取时候的loading层
                local list_view = meta.ListView_email
                --创建层
                --local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
                local layer = cc.Layer:create()
                meta:registerNoTouch(layer)
                meta.panel_email:addChild(layer,9999)
                --加入动画
                lingqu_texiao = ccs.Armature:create("getitem")
                --lingqu_texiao:setScale(3)
                lingqu_texiao:setPosition(cc.p(480,320))
                lingqu_texiao:getAnimation():play("run")
                layer:addChild(lingqu_texiao)
                lingqu_texiao:setScale(0.1)
                local action = cc.ScaleTo:create(0.3,5)
                lingqu_texiao:runAction(action)
                --加入图片，如果是金币，则加入金币图片，钻石跟体力都一样
                local email = meta.data[meta.cur_listview_Idx+1]
                local icon = email.email_icon
                local pic = nil
                if icon == email_icon.gold then 
                    pic = cc.Sprite:createWithSpriteFrameName("goumaijinbi_jinbi_03.png")
                elseif icon == email_icon.diamond then 
                    pic = cc.Sprite:createWithSpriteFrameName("goumaizuanshi_zuanshi_03.png")
                elseif  icon == email_icon.physics then 
                    pic = cc.Sprite:createWithSpriteFrameName("youxiang_tili.png")
                end
                pic:setPosition(cc.p(480,320))
                layer:addChild(pic)

                --更改邮件数量
                --meta.email_number_label:setString(tostring(#meta.data))506
                meta:setNotReadMailNumber()
                --改变金币
                local function lingqu2_touchEvent(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        --删除listview对应的item
                        list_view:removeItem(meta.cur_listview_Idx)
                        table.remove(meta.data, meta.cur_listview_Idx+1)
                        --刷新用户数据
                        g_userinfo.physical = tonumber(decode_msg.member_info.member_physical)
                        g_userinfo.gold = tonumber(decode_msg.member_info.member_gold)
                        g_userinfo.diamond = tonumber(decode_msg.member_info.member_diamond)
                        meta.readyMeta.setUserData()
                        layer:removeFromParent()
                        --更新未读邮件数量
                        meta:setNotReadMailNumber()
                    end
                end
                --领取按钮
                local lingqu_button = ccui.Button:create()
                lingqu_button:setTouchEnabled(true)
                lingqu_button:loadTextures("youjian_lingqu.png", "youjian_lingqu.png", "",ccui.TextureResType.plistType)
                lingqu_button:addTouchEventListener(lingqu2_touchEvent)        
                layer:addChild(lingqu_button)
                lingqu_button:setPosition(cc.p(480,100))
            else
                --领取失败
                lingqu_lingqu:removeFromParent()    --这个事领取时候的loading层
                cclog("******** lingqu lose ********")
            end
            --更新未读邮件数量
            meta:setNotReadMailNumber()

        end
        meta:lingqu_mail_from_server(email,lingqu_callback)
    end
end

--背景 按钮  阅读邮件
function meta.touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        cclog("button bg")
        local list_view = meta.ListView_email
        local email = meta.data[meta.cur_listview_Idx+1]
        cclog("read the mail id is " .. email.email_id)

    --如果是奖品邮件，则领取
    --如果是阅读邮件，则打开阅读

        if email.email_type == email_type.notification then
            --标记已阅读
            email.email_status = email_status.had_read

            --隐藏new精灵
            cclog("touchEvent"..meta.cur_listview_Idx+1)
            local new_pic = sender:getParent():getChildByTag(meta.new_tag)
            new_pic:setVisible(false) 
            --打开阅读界面
            meta:show_email(email)
            --发送 “已经读某邮件”信息到服务器
            meta:read_the_mail_from_server(email)
        elseif email.email_type == email_type.reward then   --奖品（体力金币钻石）
            meta.lingqu_TouchEvent(sender, ccui.TouchEventType.ended)
        end
        --更新未读邮件数量
        meta:setNotReadMailNumber()

    end
end

--初始化邮箱  加入邮件
function meta:initMailBox()


    local list_view = meta.ListView_email
    
    local size = {}
    size.width = 496
    size.height = 92

    --local curIdx = nil  --记录当前list的标签

    --测试
    --EmailM.removeNewPlayerGift()
    --测试
    --local number = EmailM:getNotReadMail_Number()
    self.data = self:getMailData()
 

    --设置邮件数量
    meta.image_emailNum     = meta.panel_email:getChildByName("Image_emailNum")
    meta.image_emailNum:setVisible(true)
    --meta:registerMove(meta.image_emailNum)
    meta.email_number_label = meta.image_emailNum:getChildByName("AtlasLabel_emailNum")
    --meta.email_number_label:setString(tostring(#self.data))
    meta:setNotReadMailNumber()

    --排序 把状态为未处理 == "0"的置前
    local lastest_number = 0 --用于计算有多少个未处理邮件
    for i = 1,#meta.data do 
        if meta.data[i].email_status == email_status.lastest then 
            local b = meta.data[i]
            table.remove(meta.data, i)
            table.insert(meta.data, 1, b)
            lastest_number = lastest_number + 1
        end
    end

    --对可获取的奖品的邮件置前
    for i = 1,#meta.data do 
        if meta.data[i].email_type == email_type.reward then 
            local b = meta.data[i]
            table.remove(meta.data, i)
            table.insert(meta.data, 1, b)
        end
    end

    --对未读邮件排序   修改排序字段
    EmailM:quickSort_withKey(meta.data,1,lastest_number,"email_addtime",tonumber)
    --对已读邮件排序
    EmailM:quickSort_withKey(meta.data,lastest_number+1,#meta.data,"email_addtime",tonumber)



    list_view:addEventListener(meta.list_view_touch_event)

    for i = 1,#meta.data do 

        local layout = ccui.Layout:create()
        layout:setContentSize(size) --背景框大小
        layout:setPosition(cc.p(size.width / 2.0,size.height/2))--layout:getContentSize().height / 2.0))
        layout:setTag(1)
        list_view:addChild(layout,0,i)
    
        --背景按钮
        local custom_button = ccui.Button:create()
        custom_button:setTouchEnabled(true)
        --custom_button:setPressedActionEnabled(true)
        custom_button:loadTextures("youjian_biankuang_01.png", "youjian_biankuang_01.png", "",ccui.TextureResType.plistType)
        --custom_button:setContentSize(cc.size(size.width,size.height/6))
        --custom_button:setScale9Enabled(true)
        custom_button:addTouchEventListener(meta.touchEvent)        
        layout:addChild(custom_button)
        custom_button:setPosition(cc.p(size.width/2,size.height/2))--size.height/2))

        --阿狸头像图片
        local head_pic = cc.Sprite:createWithSpriteFrameName("youjian_touxiang_01.png")
        layout:addChild(head_pic)
        head_pic:setPosition(cc.p(55,46))

        --“new”的图片
        local new_pic = cc.Sprite:createWithSpriteFrameName("youjian_new.png")
        layout:addChild(new_pic,0,meta.new_tag)
        new_pic:setPosition(cc.p(381,62))
        if meta.data[i].email_status ~= "0" then 
            new_pic:setVisible(false)
        end

        --获取按钮
        local ling_qu = ccui.Button:create()
        ling_qu:setTouchEnabled(false)
        ling_qu:setPressedActionEnabled(true)
        ling_qu:loadTextures("youjian_jianglineirong_01.png", 
                             "youjian_jianglineirong_01.png", 
                             "",
                             ccui.TextureResType.plistType)
        ling_qu:addTouchEventListener(meta.lingqu_TouchEvent)        
        layout:addChild(ling_qu)
        ling_qu:setPosition(cc.p(447,50))--size.height/2))
        if meta.data[i].email_type == email_type.notification then 
            ling_qu:setVisible(false)
        end

        --邮件标题
        ---[[ccui.text:create()实现
        local head_line = ccui.Text:create()
        head_line:setString(meta.data[i].email_name)
        --head_line:setString("索拉卡维克多重做归来再加六个字符索")
        head_line:setTextAreaSize(cc.size(250,28))
        head_line:setFontSize(24)
        head_line:setAnchorPoint(cc.p(0,0))
        head_line:setColor(cc.c3b(0x80,0xb9,0xff))
        head_line:setPosition(cc.p(size.width/2-140,50))
        layout:addChild(head_line)
        head_line:setTouchEnabled(false)
        --]]


        --邮件内容
        local content = ccui.Text:create()
        content:setString(meta.data[i].email_remark)
        --content:setString("索拉卡维克多重做归来再加六个字符索拉卡维克多重做归来再加六个字符")
        content:setTextAreaSize(cc.size(285,23))
        content:setFontSize(18)
        content:setAnchorPoint(cc.p(0,0))
        content:setColor(cc.c3b(0xff,0xff,0xff))
        content:setPosition(cc.p(size.width/2-140,20))
        layout:addChild(content)
        content:setTouchEnabled(false)

        cclog("create mail " .. meta.data[i].email_id)
    end
    --更新未读邮件数量
    meta:setNotReadMailNumber()
end



--删除 主图层 函数
function meta:remove()
    meta.readyMeta:setEmailFalse()
    meta.mainLayer:removeFromParent()
end 

--获得 GameGuideView  isOpened的信息 
function meta:getGameGuideMeta(ready) 
    meta.readyMeta = ready
end 

--获取邮箱信息
function meta:getMailData()
    assert(EmailM.mail_box_data,"mail.mail_box_data is nil ,init it before use it!")
    return EmailM.mail_box_data
end
--获取邮件数量
function meta:getMailNum()
    assert(EmailM.mail_box_data,"mail.mail_box_data is nil ,init it before use it!")
    return #EmailM.mail_box_data
end

--读邮件
function meta:show_email(email)
    meta.black_board:setVisible(true)
    --local list_view = meta.black_board:getChildByName("scroll_view")
    local listView = ccui.ListView:create()

    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    --listView:setBackGroundImage("cocosui/green_edit.png")
    listView:setBackGroundImageScale9Enabled(true)
    listView:setContentSize(cc.size(580, 380))
    local size = meta.black_board:getContentSize()
    listView:setPosition(cc.p(208,116))
    meta.black_board:addChild(listView,1,1)  --tag = 1未listview
    --meta:registerMove(listView)

    local str = email.email_remark

    local n_num = 1
    for i in string.gmatch(str, "\n") do 
        n_num = n_num + 1
    end
    local fontSize = 18 --meta.back_board_textfield:getFontSize()
    cclog("fontSize   = "..fontSize)

    --创建ccui.text

        meta.back_board_textfield = ccui.Text:create()
        meta.back_board_textfield:setFontName("微软雅黑")
        meta.back_board_textfield:setString(email.email_remark)
        --head_line:setString("索拉卡维克多重做归来再加六个字符索")
        meta.back_board_textfield:setTextAreaSize(cc.size(550,fontSize*(n_num+string.len(str)/90)+50))
        meta.back_board_textfield:setFontSize(fontSize)
        listView:addChild( meta.back_board_textfield)
        meta.back_board_textfield:setTouchEnabled(false)
    --[[删除  留下contentsize
    meta.back_board_textfield:setContentSize(cc.size(550,fontSize*(n_num+string.len(str)/90)))
    --meta:registerMove(meta.back_board_textfield)
    meta.back_board_textfield:setString(email.email_remark)
    --]]

end
--阅读邮件 想服务器发送
function meta:read_the_mail_from_server(email)

    local link = g_url.get_email .. 
                "&uid=" .. g_userinfo.uid .. 
                "&uname=" ..g_userinfo.uname ..
                "&sid=" .. g_userinfo.sid ..
                "&email_id=" .. email.email_id
    cclog(link)

    local function callback(msg)
        cclog(msg)
    end

    Func_HttpRequest(link,"",callback,false)
end

--领取邮件 想服务器发送
function meta:lingqu_mail_from_server(email,callback)
    --http://www.v5fz.com/api/emails.php?act=get_prize&uid=500000026&uname=fdfj124566fsd&sid=1&email_id=2
    local link = g_url.get_prize ..
                 "&uid=" .. g_userinfo.uid .. 
                 "&uname=" .. g_userinfo.uname ..
                 "&sid=" .. g_userinfo.sid ..
                 "&email_id=" .. email.email_id
    cclog(link)
    Func_HttpRequest(link,"",callback,false)
end

--创建领取层
function meta:lingqu_window()
    local node = cc.Node:create()
    local bg = cc.Sprite:createWithSpriteFrameName("youjian_lingqubiankuang.png")
    node:addChild(bg)
    bg:setPosition(cc.p(480,320))
    meta:registerNoTouch(node)
    --meta:registerMove(node)

    local circle = cc.Sprite:createWithSpriteFrameName("youjian_jiazai.png")
    node:addChild(circle)
    circle:setPosition(cc.p(480,320))

    local action = cc.RotateBy:create(1 , 360)
    circle:runAction(cc.RepeatForever:create(action))

    return node
end

function meta:registerMove(layer,isSwallow)
    local  listenner = cc.EventListenerTouchOneByOne:create()
    isSwallow = isSwallow or true
    listenner:setSwallowTouches(isSwallow)

    local function touchesBegin(touch,event)
        
        return true
    end
    local function touchesMove(touch,event)
        local x,y = layer:getPosition()
        local delta = touch:getDelta()
        cclog("x = %d     y = %d",x,y)
        layer:setPosition(cc.p(x+delta.x,y+delta.y))
    end
    local function touchesEnd(touch,event)
        
    end

    listenner:registerScriptHandler(touchesBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(touchesMove,cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(touchesEnd,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layer)

end



function meta:registerNoTouch(node)
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)

    local function touchesBegin(touch,event)
        
        return true
    end
    --local function touchesMove(touch,event)
    --    local x,y = node:getPosition()
    --    local delta = touch:getDelta()
    --    cclog("x = %d     y = %d",x,y)
    --    node:setPosition(cc.p(x+delta.x,y+delta.y))
    --end

    listenner:registerScriptHandler(touchesBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    --listenner:registerScriptHandler(touchesMove,cc.Handler.EVENT_TOUCH_MOVED )
    --listenner:registerScriptHandler(touchesEnd,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, node)

end

--设置未读邮件的数量
function meta:setNotReadMailNumber()
---[[
    local not_read_mail_num = EmailM:getNotReadMail_Number()
--邮件内部显示未读有邮件数量
    if not_read_mail_num ==0 then 
        meta.image_emailNum:setVisible(false)
    else
        meta.image_emailNum:setVisible(true)
    end
    meta.email_number_label:setString(tostring(not_read_mail_num))
--gameguide主场景 邮件按钮 的未读邮件数
    meta.readyMeta:setEmailNum(not_read_mail_num)
--]]
end

return GameEmailView
