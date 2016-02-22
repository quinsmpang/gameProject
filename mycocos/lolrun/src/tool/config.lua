--初始化的一些东西。一些全局变量
cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(960,640,0)--注意: 先适配好再获取屏幕宽高 这样才能按照自己定制的宽高去适配
g_visibleSize = cc.Director:getInstance():getVisibleSize()
g_origin = cc.Director:getInstance():getVisibleOrigin()


g_conf = {
    g_start_conf = nil;
    g_game_conf = nil;
    g_role_conf = nil;
    g_hero_conf = nil;
    g_heroskill_conf = nil;
    g_equip_conf = nil;
    g_sprite_conf = nil;
    g_boss_conf = nil;
    g_experience_conf = nil;
    g_consumer_conf = nil;
    g_shop_conf = nil;
    g_monster_conf = nil;
    g_version = nil;
    g_upgrade_conf = nil;
    g_wj_conf = nil;
    g_jl_conf = nil;
    g_leader_conf = nil;
}


--用户基本数据
g_userinfo = {
    physical = 0; --体力
    gold   = 0;    --金币
    diamond  = 0;  --钻石
    uname =  "";  --会员名
    upwd = "";    --会员密码
    uid = 0;  --会员ID
    mac = "";    --机器码
    sid = 0 ;  --服号
    gid = 0;  --角色ID
    gname = "";  --角色名
    lastlogin = 0;  --最后登陆时间
    advtype = 1;  --渠道号
    subtype = 1;  --子渠道号
    heros = {
        {
            id = 100003; --提莫ID
            level = 1 ;   --等级
        };
    };
    leader = 0;--新手引导步骤   -1=新手引导已完成
    ranks = {};   --排行榜数据
    email =  {};  --邮件数据
    chest =  {};   --任务数据
}





g_clickinfo = {}  --用户点击行为信息

g_start_conf = nil
g_game_conf = nil
g_role_conf = nil
g_shop_conf = nil
g_test_conf = nil
g_server_conf = nil   --存服务器拿下来的conf
g_frame = 60--帧速率
g_debug_btn = false --测试专用按钮

--全局变量
g_isPause = false--开始暂停
g_res = nil--加载资源状态
g_isEffect = true --是否静音音效
g_isMusic =  true --是否静音音乐
g_progress = 0--loading进度
g_isInjured = false--主角受伤暂停怪物场景移动
g_physics_debug = false--测试专用:刚体是否开启
g_tips          = nil   --标签
g_monster_conf  = nil --怪物表
g_boss = 0;--记录当前boss模式中正在打的boss(暂时不需要服务器返回 根据宝箱状态自己判断是否开启)



g_isLoadSuccess = false;--加载完成

--声音
g_btn_sound = nil--继续游戏 退出游戏 返回上一级菜单 返回菜单
g_eat_gold = nil--吃金币
g_role_jump = nil--英雄跳跃
g_choice_sound = nil--英雄选择 切换地图
g_role_injured = nil--英雄受伤
g_customs = nil--关卡开始前三秒
g_win = nil--通关成功
g_faile = nil--通关失败
g_pause_soud = nil--暂停恢复倒计时

--用于记录原场景内存

--服务器设置
g_is_online = true --设置内外网链接
--g_inturl="http://www.v5fz.com/api/lolrun.php?"  --网站接口url(热更新)
--g_payurl="http://www.v5fz.com/api/get_order.php?"--支付入口
g_advtype=0 --渠道编码
g_subtype="" --子站编码
g_onlineUrl = "http://api.lszyouxi.com/" --服务器设置(外网)
g_inlineUrl = "http://www.v5fz.com/" --内网
if g_is_online then
    --外网
    g_url = 
    {
        login             = g_onlineUrl .. "api/login.php",                          -- login测试用
        register          = g_onlineUrl .. "api/register.php",                       -- 本地注册用 
        is_role           = g_onlineUrl .. "api/get_server.php?act=is_role",         -- 选服
        get_server        = g_onlineUrl .. "api/get_server.php",                     --选服用
        add_role          = g_onlineUrl .. "api/get_server.php?act=add_role",        --创号用
        up_hero           = g_onlineUrl .. "api/experience.php?act=up_hero",         -- 英雄升级用
        exchange_hero     = g_onlineUrl .. "api/consume.php?act=exchange_hero",      -- 购买英雄用
        get_physical      = g_onlineUrl .. "api/get_physical.php?act=add_physical",  -- 恢复体力接口
        get_section       = g_onlineUrl .. "api/get_section.php?act=is_section",     -- 进入无尽接口
        exchange_physical = g_onlineUrl .. "api/consume.php?act=exchange_physical",  -- 购买体力接口
        act_click         = g_onlineUrl .. "api/advt.php?act=click",                 -- 统计接口
        exchange_gold     = g_onlineUrl .. "api/consume.php?act=exchange_gold",      -- 购买金币
        member_info       = g_onlineUrl .. "api/member_info.php?act=get_info",       -- 基本信息  
        first_gift        = g_onlineUrl .. "api/first_gift.php?act=get_gift",        -- 领取首冲礼包
        get_gift          = g_onlineUrl .. "api/get_section.php?act=get_gift",       -- 获取可领取的宝箱信息
        reward_gift       = g_onlineUrl .. "api/accounts.php?act=get_gift",          -- 领取宝箱状励
        get_step          = g_onlineUrl .. "api/get_step.php",                       -- 步骤
        get_prize         = g_onlineUrl .. "api/emails.php?act=get_prize",           -- 领取邮件
        get_email         = g_onlineUrl .. "api/emails.php?act=get_email",           -- 获取邮件内容
        get_role          = g_onlineUrl .. "api/get_role.php?",                      -- 获取随机名字用 
        change_gname      = g_onlineUrl .. "api/get_role.php?act=change",            -- 改名字接口
    };

    g_payurl = g_onlineUrl .."api/get_order.php?act=getorder";--支付入口
    g_inturl = g_onlineUrl .."api/lolrun.php?act=getversion";  --网站接口url(热更新)

    g_wjjieurl = g_onlineUrl .."api/accounts.php?act=accounts";--无尽根据米数结算
    g_wjurl    = g_onlineUrl .."api/accounts.php?act=score"; --无尽结算领取奖励
    g_wjbxurl  = g_onlineUrl .."api/accounts.php?act=get_gift"; --无尽结算宝箱领取


else
    --内网
    g_url = 
    {
        login             = g_inlineUrl .. "api/login.php",                            -- login测试用
        register          = g_inlineUrl .. "api/register.php",                         -- 本地注册用 
        is_role           = g_inlineUrl .. "api/get_server.php?act=is_role",           -- 选服
        get_server        = g_inlineUrl .. "api/get_server.php",                       --选服用
        add_role          = g_inlineUrl .. "api/get_server.php?act=add_role",          --创号用
        up_hero           = g_inlineUrl .. "api/experience.php?act=up_hero",           -- 英雄升级用
        exchange_hero     = g_inlineUrl .. "api/consume.php?act=exchange_hero",        -- 购买英雄用
        get_physical      = g_inlineUrl .. "api/get_physical.php?act=add_physical",    -- 恢复体力接口
        get_section       = g_inlineUrl .. "api/get_section.php?act=is_section",       -- 进入无尽接口
        exchange_physical = g_inlineUrl .. "api/consume.php?act=exchange_physical",    -- 购买体力接口
        act_click         = g_inlineUrl .. "api/advt.php?act=click",                   -- 统计接口
        exchange_gold     = g_inlineUrl .. "api/consume.php?act=exchange_gold",        -- 购买金币
        member_info       = g_inlineUrl .. "api/member_info.php?act=get_info",         -- 基本信息  
        first_gift        = g_inlineUrl .. "api/first_gift.php?act=get_gift",          -- 领取首冲礼包
        get_gift          = g_inlineUrl .. "api/get_section.php?act=get_gift",         -- 获取可领取的宝箱信息
        reward_gift       = g_inlineUrl .. "api/accounts.php?act=get_gift",            -- 领取宝箱状励
        get_step          = g_inlineUrl .. "api/get_step.php",                         -- 步骤
        get_prize         = g_inlineUrl .. "api/emails.php?act=get_prize",             -- 领取邮件
        get_email         = g_inlineUrl .. "api/emails.php?act=get_email",             -- 获取邮件内容
        get_role          = g_inlineUrl .. "api/get_role.php?",                        -- 获取随机名字用
        change_gname      = g_inlineUrl .. "api/get_role.php?act=change",              -- 改名字接口
    };
    g_payurl = g_inlineUrl .."api/get_order.php?act=getorder"--支付入口
    g_inturl = g_inlineUrl .."api/lolrun.php?act=getversion"  --网站接口url(热更新)

    g_wjjieurl = g_inlineUrl .."api/accounts.php?act=accounts"--无尽根据米数结算
    g_wjurl    = g_inlineUrl .."api/accounts.php?act=score" --无尽结算领取奖励
    g_wjbxurl  = g_inlineUrl .."api/accounts.php?act=get_gift" --无尽结算宝箱领取
    
end
              
g_key = "lol888run999"   

--当前难度
g_cur_difficult_level = 1;  --1=普通    2=中等    3=困难    默认普通
g_cur_zhang           = 1;
g_cur_jie             = 1;

--主界面
g_gameGuideSch = nil -- 主界面的cc.Director:getInstance():getScheduler()
g_countDown = nil    -- 主界面倒计时定时器 
g_strCheckStr = nil  -- 体力检测定时器
--md5校验
g_md5 = nil

--记录服务器
g_uid = nil    --uid   在startV.lua初始化
g_uname = nil  --账号  在startV.lua初始化
g_xhr   = nil

--邮件
g_mail = nil  --里面记录接受到的邮件
g_mail_type = {
    isMessage = 0;
    isbonus = 1;
}