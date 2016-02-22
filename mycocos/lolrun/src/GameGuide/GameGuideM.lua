require "src/tool/enum"
local GameGuideModel =
{
   guide_start             = 0,
   change_scene            = 0,
   curMyHero               = nil,
   heroName = 
   {
    "Teemo",
    "zhaoxin",
    "Ezreal",
    "Ahri",
    "Garen",
    "JS"
   },
   ranks = {
        {
            mid   = 0,
            mname = "",
            gid   = 0,
            gname = "",
            hero_id  = 0,
            hero_level = 0,
            rank_level = 0,
            rank_score = 0,
            rank_dis   = 0 
        }
   },
   isFirst = true ,
}

local meta = GameGuideModel
--引用和全局，初始化----------------------------------------------------------------------------------

function meta.resetUserData()
    --异步
    local function mySelect(msg)
        if msg == "0" then 
            --选服失败
        elseif msg ~= "" and msg ~= nil then 
            local cjson = require "cjson"
			local temp_conf = cjson.decode(msg) 
            meta.initRanks(temp_conf.ranks)
            g_userinfo.physical = temp_conf.member_physical
            g_userinfo.diamond = temp_conf.member_diamond
            g_userinfo.gold = temp_conf.member_gold
            local GameEmailModel = require "src/GameEmail/GameEmailM"
            GameEmailModel.saveMailData(temp_conf.email)
            local GameGuideView     =   require "src/GameGuide/GameGuideV"
            local GameTaskModel     =   require "src/GameTask/GameTaskM"
            GameTaskModel.initRanks()
        end 
    end 
    local requrl = g_url.get_server.."?uid="..g_userinfo.uid.."&uname="..g_userinfo.uname.."&sid="..g_userinfo.sid
    Func_HttpRequest(requrl,"",mySelect)
end 

function meta.initRanks(ranksData)
    meta.ranks = {} 
    for i = 1 , #ranksData do
        cclog("排行"..i)
        meta.ranks[i] = {}
        meta.ranks[i].mid = ranksData[i].rank_mid
        meta.ranks[i].mname = ranksData[i].rank_mname
        meta.ranks[i].gid = ranksData[i].rank_gid
        meta.ranks[i].gname = ranksData[i].rank_gname
        meta.ranks[i].hero_id = ranksData[i].rank_hrid
        meta.ranks[i].hero_level = ranksData[i].rank_level
        meta.ranks[i].rank_score = ranksData[i].rank_score
        meta.ranks[i].rank_dis = ranksData[i].rank_dis
    end 
end 



return GameGuideModel