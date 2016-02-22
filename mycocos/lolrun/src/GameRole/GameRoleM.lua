local GameRoleModel =
{
   --别忘了 加 逗号 “ , ”---------------
   role_start              = 0,
   change_scene            = 0,
   shopRoleName = 
   {
       "提百万",
       "草丛伦",
       "菊花信",
       "狐狸",
       "探险家",
       "剑圣"
   },
   --价格
   shopRolePrice = 
   {
       18888,
       280,
       380,
       880,
       580,
       1880
   },
   --技能背景
   skillBg = {
       "skillshowbg_tm.png",
       "skillshowbg_zx.png",
       "skillshowbg_ez.png",
       "skillshowbg_ali.png",
       "skillshowbg_gailun.png",
       "skillshowbg_js.png"
   },
}
local meta = GameRoleModel

--引用和全局，初始化----------------------------------------------------------------------------------

return GameRoleModel