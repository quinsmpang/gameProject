local ipairs = ipairs
module('config')

design = {width=640, height=960, fps=30}
--[[
  指定各种比例的policy
  policy 0:exact-fit 1:no-border 2:show-all 3:fixed-height 4:fixed-width
]]
policy = function(w, h)
  --wh为 w/h，从大到小排列。
  ---[[
  local setup = {
    {wh=700/960, policy=2},
    --{wh=960/640, policy=1},
    {wh=600/960, policy=0},
    {wh=0, policy=2},
  }
  
  local policy = 0;
  local wh = w / h
  for i,p in ipairs(setup) do
    if wh >= p.wh then
      policy = p.policy
      break
    end
  end
  
  return policy
  --]]
end

volume = {
  music = 1;
  effects = 1;
}

--以下调试项，不需要注释即可
--show_stats = true
--show_file_util_notify = true
--debug_coll = true
--[[
test_data = {
    rank = {
        name = "排行榜",
        btn = nil
    },
    sign = {
        name = "签到%d天",
        btn = nil
    },
    challenge = {
        name = "挑战次数",
        btn = nil
    },
    pets = {
        name = "宠物碎片",
        btn = nil
    },
    lucky = {
        name = "抽奖次数",
        btn = nil
    },
    luckyV = {
        name = "抽奖界面",
        btn = nil
    },
--    petpause = {
--        name = "碎片界面",
--        btn = nil
--    }
}
--]]
