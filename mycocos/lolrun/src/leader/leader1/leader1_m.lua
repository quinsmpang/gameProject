


local leader1_m = {
    Hero_ExportJson = {
        "res/ani/role/Teemo/Teemo.csb";--加载新提莫
        "res/ani/role/zhaoxin/zhaoxin.csb";--加载赵信2
        "res/ani/role/Garen/Garen.csb";--加载德玛
        "res/ani/role/Ahri/Ahri.csb";--加载Ahri
        "res/ani/role/Ezreal/Ezreal.csb";--加载ez
        "res/ani/role/JS/JS.csb";--加载JS

        --"res/ani/boss/xl/xl.csb";--加载小龙
        "res/ani/boss/dalang/dalang.csb";--加载dalang
        "res/ani/boss/nanbaba/nanbaba.csb";--加载nanbaba
        "res/ani/boss/dg/dg.csb";--加载dg
            "res/ani/boss/hbf/hbf.csb";
            "res/ani/boss/dl/dl.csb"
    };

    heroName = 
    {
        "Teemo",
        "Garen",
        "Ezreal",
        "Ahri",
        "JS",
    };

    bossName = {
        "dalang";
        "dg";
        "nanbaba";
        "hbf";
        --"xl";
        "dl";
    };

    Zorder = {
        bg1 = 1; --第一个场景的说明
        bg2 = 2; --第二个场景
        progressTimer = 3;
    };
    tag = {
        bg1_label_tag  = 1;
    };
    boss_scale = {
        0.8,
        1,
        0.6,
        1.3,
        0.6
    };
    boss_pos = {
        cc.p(-81,29);
        cc.p(-34,5);
        cc.p(-14,-33);
        cc.p(-32,7);
        cc.p(-61,-138);

        --cc.p(-74,29);
        --cc.p(-4,-32);
        --cc.p(-20,-43);
        --cc.p(-32,7);
        --cc.p(-61,-138);
    };

}


return leader1_m