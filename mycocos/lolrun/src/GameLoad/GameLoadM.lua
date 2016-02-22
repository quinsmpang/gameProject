--中文


local GameLoadM = 
{
    --ui界面资源
    ui = {
        ExportJson = {
            "res/ani/role/Teemo/Teemo.csb";--加载新提莫
            "res/ani/role/zhaoxin/zhaoxin.csb";--加载赵信2
            "res/ani/role/Garen/Garen.csb";--加载德玛
            "res/ani/role/Ahri/Ahri.csb";--加载Ahri
            "res/ani/role/Ezreal/Ezreal.csb";--加载ez
            "res/ani/role/JS/JS.csb";--加载JS
            "res/ani/role/effect/chonci.csb";--加载冲刺
            "res/ui/game_ready/kaifuguang/kaifuguang.csb"; --主接卖弄开服活动的光
            "res/ani/levelup/levelup.csb";
        };
        plistAndPng = {
            --{"res/ui/game_ready/TPheroname.plist","res/ui/game_ready/TPheroname.png"};                --英雄名字
            {"res/ui/email/email.plist","res/ui/email/email.pvr.ccz"};  
        };
    };

    --战斗界面资源
    fighting = {
        ExportJson = {
            "res/ani/monster/jzb/jzb.csb";--加载近战兵
            "res/ani/monster/cjb/cjb.csb";--加载巨大兵
            "res/ani/role/effect/chonci.csb";--加载冲刺
            "res/ani/role/effect/Teemo_attack.csb";--加载Teemo毒箭
            "res/ani/role/effect/dun.ExportJson";--加载护盾动画
            "res/ani/role/effect/Ahri_attack.csb";--加载Ahri子弹
            "res/ani/role/effect/Ezreal_attack.csb";--加载EZ子弹
            "res/ani/role/effect/jump2.csb";--加载二段跳动画
            "res/ui/gameIn/jiesuan/wj/jinsekuang.csb";--加载宝箱点击框
            "res/ani/role/effect/JS_attack.csb";--加载JS_attack
            "res/ani/role/effect/Garen_attack.csb";--加载Garen_attack
            "res/ani/role/effect/zhaoxin_attack.csb";--加载zhaoxin_attack
            "res/ani/boss/xl/xl.csb";--加载小龙
            "res/ani/boss/dalang/dalang.csb";--加载dalang
            "res/ani/boss/nanbaba/nanbaba.csb";--加载nanbaba
            "res/ani/boss/dg/dg.csb";--加载dg
            "res/ani/boss/hbf/hbf.csb";--加载hbf
            "res/ani/role/effect/terminal.csb";--加载新手引导光圈
            "res/ani/role/JS/JSbig.csb";--加载js大招
            
        };
        plistAndPng = {
            {"res/ui/gameIn/background/zdcj.plist", "res/ui/gameIn/background/zdcj.pvr.ccz"};--战斗场景
            --{"res/gameIn/background/aircj.plist", "res/gameIn/background/aircj.pvr.ccz"};--奖励场景(透明度出问题)
            {"res/ui/gameIn/background/aircj.plist", "res/ui/gameIn/background/aircj.png"};--奖励场景
            {"res/ui/gameIn/background/bossBg.plist", "res/ui/gameIn/background/bossBg.pvr.ccz"};--boss场景
            {"res/ui/gameIn/UiAndButton/bossModel.plist", "res/ui/gameIn/UiAndButton/bossModel.pvr.ccz"};--bossUI
            
            {"res/ui/gameIn/jiesuan/wj/wjjiesuan.plist", "res/ui/gameIn/jiesuan/wj/wjjiesuan.pvr.ccz"};--无尽结算界面
            {"res/ui/gameIn/UiAndButton/zhandouUI.plist","res/ui/gameIn/UiAndButton/zhandouUI.pvr.ccz"};--战斗UI2
            {"res/ani/monster/png/monster.plist", "res/ani/monster/png/monster.pvr.ccz"};--加载新资源
            {"res/ui/gameIn/jiesuan/Digital/number.plist","res/ui/gameIn/jiesuan/Digital/number.png"};--结算界面
            --{"res/ui/gameIn/UiAndButton/zhandou_ui_button.plist","res/ui/gameIn/UiAndButton/zhandou_ui_button.png"};--战斗界面ui和button
            {"res/ui/gameIn/pause/fightpause.plist","res/ui/gameIn/pause/fightpause.png"};--战斗暂停界面
        };
    };

    --新手引导资源
    leader = {
        ExportJson = {
            "res/ani/monster/jzb/jzb.csb";--加载近战兵
            "res/ani/monster/cjb/cjb.csb";--加载巨大兵
            "res/ani/role/effect/chonci.csb";--加载冲刺
            "res/ani/role/effect/Teemo_attack.csb";--加载Teemo毒箭
            "res/ani/role/effect/dun.ExportJson";--加载护盾动画
            "res/ani/role/effect/Ahri_attack.csb";--加载Ahri子弹
            "res/ani/role/effect/Ezreal_attack.csb";--加载EZ子弹
            "res/ani/role/effect/jump2.csb";--加载二段跳动画
            "res/ui/gameIn/jiesuan/wj/jinsekuang.csb";--加载宝箱点击框
            "res/ani/role/effect/JS_attack.csb";--加载JS_attack
            "res/ani/role/effect/Garen_attack.csb";--加载Garen_attack
            "res/ani/role/effect/zhaoxin_attack.csb";--加载zhaoxin_attack
            "res/ani/boss/xl/xl.csb";--加载小龙
            "res/ani/boss/dalang/dalang.csb";--加载dalang
            "res/ani/boss/nanbaba/nanbaba.csb";--加载nanbaba
            "res/ani/boss/dg/dg.csb";--加载dg
            "res/ani/boss/hbf/hbf.csb";--加载hbf
            "res/ani/boss/dl/dl.csb";--加载dl
            "res/ani/role/effect/terminal.csb";--加载新手引导光圈
            "res/ani/role/JS/JSbig.csb";--加载js大招
        };
        plistAndPng = {
            {"res/ui/leader/fightleader.plist", "res/ui/leader/fightleader.pvr.ccz"};--新手引导阿狸
            {"res/ui/gameIn/background/zdcj.plist", "res/ui/gameIn/background/zdcj.pvr.ccz"};--战斗场景
            --{"res/gameIn/background/aircj.plist", "res/gameIn/background/aircj.pvr.ccz"};--奖励场景(透明度出问题)
            {"res/ui/gameIn/background/aircj.plist", "res/ui/gameIn/background/aircj.png"};--奖励场景
            {"res/ui/gameIn/background/bossBg.plist", "res/ui/gameIn/background/bossBg.pvr.ccz"};--boss场景
            {"res/ui/gameIn/UiAndButton/bossModel.plist", "res/ui/gameIn/UiAndButton/bossModel.pvr.ccz"};--bossUI
            
            {"res/ui/gameIn/jiesuan/wj/wjjiesuan.plist", "res/ui/gameIn/jiesuan/wj/wjjiesuan.pvr.ccz"};--无尽结算界面
            {"res/ui/gameIn/UiAndButton/zhandouUI.plist","res/ui/gameIn/UiAndButton/zhandouUI.pvr.ccz"};--战斗UI2
            {"res/ani/monster/png/monster.plist", "res/ani/monster/png/monster.pvr.ccz"};--加载新资源
            {"res/ui/gameIn/jiesuan/Digital/number.plist","res/ui/gameIn/jiesuan/Digital/number.png"};--结算界面
            --{"res/ui/gameIn/UiAndButton/zhandou_ui_button.plist","res/ui/gameIn/UiAndButton/zhandou_ui_button.png"};--战斗界面ui和button
            {"res/ui/gameIn/pause/fightpause.plist","res/ui/gameIn/pause/fightpause.png"};--战斗暂停界面

        };
    };

    tips = {
        {"duqu_yulantu.png","duqu_tishi_01.png","duqu_tishi_02.png"};
    
    };



}--@ 游戏逻辑主图层
local  meta = GameLoadM

return GameLoadM