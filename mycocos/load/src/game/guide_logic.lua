module('game.guide_logic', package.seeall)

local _player = require('game.player')
local _guide = require('game.ui.guide')
local _mgr_scr = require('game.mgr_scr')
local _text_guide = require('data.text').guide

--[[
将各个新手引导集中到这里，方便统一
并非为封装，各部分实现还是和相应界面依赖较重

game.player.data.guide={
  main=true|false,  主界面进入普通战斗
  choose_hero=true|false, 普通战斗选进阶出击
  
  --battle=true|false,
  use_item=true|false,  普通战斗，使用道具
  level_up=true|false,  再玩一次，升级
  rescue=true|false,   初次营救，体验超级英雄
  
  main_rank=true|false, 初次普通战斗结算后，主界面点排行榜
  rank_1=true|false, 排行榜内的引导
  rank_2=true|false, 
  
  main_challenge=true|false, 主界面点挑战模式
  challenge_choose_hero=true|false, 挑战模式选进阶出击
  
  main_pet=true|false, 获得碎片后，主界面点宠物按钮
  pet=true|false, 宠物界面内的引导
  
  main_miracle=true|false, 主界面点奇迹按钮
  miracle=true|false, 奇迹界面内引导
}
]]

--[[
主界面升级引导
z
button:允许点击的button
cbClick:点击后的回调函数
返回：是否压入了引导界面
]]
function checkLevelUpGuide(z, button, cbClick)
  if _player.get().guide.level_up then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local box = button:getBoundingBox()
  
  _guide.setWordFrom(_text_guide.level_up, box.x+110 - 80, box.y+box.height)
  _guide.setHand(box.x +box.width*0.5, box.y+box.height+120, 'down',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=-30}),
        cc.MoveBy:create(0.5, {x=0, y=30})
    ) )
  )
  _guide.setBoundingBox(box.x-210, box.y-20, box.width+210, box.height+20,
    nil, 
    nil,
    function(touch)
      _player.get().guide.level_up = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil)
  
  return true
end


--[[
主界面的引导
z
button:允许点击的button
cbClick:点击后的回调函数
返回: 是否压入了引导界面
]]
function checkMainGuide(z, button, cbClick)
  if _player.get().guide.main then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local box = button:getBoundingBox()
  
  --_guide.setWordFrom(_text_guide.main_enter_game, box.x+90, box.y+box.height)
  _guide.setWordFrom()
  _guide.setHand(box.x +box.width*0.5, box.y+box.height+120, 'down',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=-30}),
        cc.MoveBy:create(0.5, {x=0, y=30})
    ) )
  )
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.main = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil)
  
  return true
end


--[[
选择英雄的引导
z
button:允许点击的button
cbClick:点击后的回调函数
from: 'battle' 或 'challenge'
返回：是否压入了引导界面
]]
function checkChooseHeroGuide(z, button, cbClick, from)
  local prior, name
  if from == 'battle' then
    prior, name = 'main', 'choose_hero'
  elseif from == 'challenge' then
    prior, name = 'main_challenge', 'challenge_choose_hero'
  else
    return false
  end
  if not _player.get().guide[prior]
    or _player.get().guide[name] 
  then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local box = button:getBoundingBox()
  
  --_guide.setWordFrom(_text_guide.choose_first_battle, box.x+110, box.y+box.height)
  _guide.setWordFrom()
  _guide.setHand(box.x +box.width*0.5, box.y+box.height+100, 'down',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=-30}),
        cc.MoveBy:create(0.5, {x=0, y=30})
    ) )
  )
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide[name] = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil)
  
  return true
end


--[[
战斗的引导
z:
返回：
{
touchForward(cbBegan,cbMoved,cbUp,cbCancelled)
  设置触摸回调函数，必须都存在
onStart(scene,team): 战斗开始时被调用，此处接管scene的injecting状态
onUpdate(scene,dt,team): 每帧update被调用，返回true表示inject结束
onEnd(scene,team): 退出前调用
}
如无需引导，返回nil
]]
--[[
function checkBattleGuide(z)
  if _player.get().guide.battle then
    return nil
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local data = {
    --cbBegan, cbMoved, cbUp, cbCancelled
    --touch_id, last_x
    move_left=0,
    move_right=0,
  }
  
  local touchBegan = function(touch)
    data.cbBegan(touch)
    data.touch_id = touch:getId()
  end
  local touchMoved = function(touch)
    data.cbMoved(touch)
    local x = g.node:convertToNodeSpace(touch:getLocation()).x
    local last = data.last_x
    data.last_x = x
    if last then
      local diff = x - last
      if diff > 0 then
        data.move_right = data.move_right + diff
      else
        data.move_left = data.move_left - diff
      end
    end
  end
  local touchUp = function(touch)
    data.cbUp(touch)
    data.touch_id, data.last_x = nil
  end
  local touchCancelled = function(touch)
    data.cbCancelled(touch)
    data.touch_id, data.last_x = nil
  end

  local design = require('config').design
  _guide.setWordFrom(_text_guide.battle_tip, 500, 350)
  local startx, starty = design.width*0.5, 280
  _guide.setHand(startx, starty, 'up',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.2, {x=0, y=-50}),
        cc.MoveBy:create(0.5, {x=-150, y=0}),
        cc.MoveBy:create(1, {x=300, y=0}),
        cc.MoveTo:create(0.2, {x=startx, y=starty}),
        cc.DelayTime:create(0.5)
    ) )
  )
  _guide.setBoundingBox(
    50, 50, design.width-100, 250,
    touchBegan, touchMoved, touchUp, touchCancelled)
  
  return {
    touchForward = function(cbBegan, cbMoved, cbUp, cbCancelled)
      data.cbBegan = cbBegan
      data.cbMoved = cbMoved
      data.cbUp = cbUp
      data.cbCancelled = cbCancelled
    end,
    
    onStart = function(scene, team)
    end,
  
    onUpdate = function(scene, dt, team)
      if not data.touch_id 
        and (data.move_left > 0
        or data.move_right > 0)
      then
        return true
      end
    end,
  
    onEnd = function(scene, team)
      _player.get().guide.battle = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
    end,
  }
end
]]

function needItemGuide()
  return not _player.get().guide.use_item
end

--[[
使用道具的引导
scene: 战斗scene
z
button:允许点击的button
cbClick:点击后的回调函数
]]
function checkItemGuide(scene, z, button, cbClick)
  if not needItemGuide() then
    return
  end
  
  --退出暂停后不显示go
  scene:pause(true)
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local box = button:getBoundingBox()
  
  --_guide.setWordFrom(_text_guide.choose_first_battle, box.x+110, box.y+box.height)
  _guide.setWordFrom()
  _guide.setHand(box.x +box.width*0.5, box.y+box.height+100, 'down',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=-30}),
        cc.MoveBy:create(0.5, {x=0, y=30})
    ) )
  )
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.use_item = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      scene:unpause()
      cbClick()
    end, 
    nil)
end


function needRescueGuide()
  return not _player.get().guide.rescue
end

--[[
营救引导
必须已弹框
z
box:允许点击区域{x,y,width,height}
cbClick:点击后的回调函数
]]
function checkRescueGuide(z, box, cbClick)
  if not needRescueGuide() then
    return
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  _guide.setWordFrom(nil)
  _guide.setHand(box.x +box.width*0.5, box.y-100, 'up',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=30}),
        cc.MoveBy:create(0.5, {x=0, y=-30})
    ) )
  )
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.rescue = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      
      cbClick()
    end, 
    nil)
end


--[[
主界面点击排行榜的引导
z
button:允许点击的button
cbClick:点击后的回调函数
返回: 是否压入了引导界面
]]
function needMainRankGuide()
  return not _player.get().guide.main_rank
end

function checkMainRankGuide(z, button, cbClick)
  if not needMainRankGuide() then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local box = button:getBoundingBox()
  
  _guide.setWordFrom(_text_guide.main_rank, box.x+120, box.y, 'down')
  _guide.setHand(box.x +box.width*0.5, box.y-120, 'up',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=30}),
        cc.MoveBy:create(0.5, {x=0, y=-30})
    ) )
  )
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.main_rank = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil)
  
  return true
end


--[[
排行界面内的引导1
z
box:允许点击的框
cbClick:点击后的回调函数
返回: 是否压入了引导界面
]]
function checkRank1Guide(z, box, cbClick)
  --必须主界面点奇迹按钮已完成才触发
  if not _player.get().guide.main_rank
    or _player.get().guide.rank_1
  then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  _guide.setWordFrom(_text_guide.rank_1, box.x+box.width*0.1, box.y, 'down')
  _guide.setHand()
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.rank_1 = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil,
    true)
  
  return true
end

--[[
排行界面内的引导2
z
button:允许点击的按钮
cbClick:点击后的回调函数
返回: 是否压入了引导界面
]]
function checkRank2Guide(z, button, cbClick)
  --必须主界面点奇迹按钮已完成才触发
  if not _player.get().guide.main_rank
    or not _player.get().guide.rank_1
    or _player.get().guide.rank_2
  then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local box = button:getBoundingBox()
    
  _guide.setWordFrom(_text_guide.rank_2, box.x+box.width*0.5, box.y, 'down', true)
  _guide.setHand(box.x+box.width*0.5, box.y-120, 'up',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=30}),
        cc.MoveBy:create(0.5, {x=0, y=-30})
    ) )
  )
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.rank_2 = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil)
  
  return true
end


--[[
主界面点击挑战模式的引导
z
button:允许点击的button
cbClick:点击后的回调函数
返回: 是否压入了引导界面
]]
function checkMainChallengeGuide(z, button, cbClick)
  if _player.get().guide.main_challenge then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local box = button:getBoundingBox()
  
  _guide.setWordFrom()
  _guide.setHand(box.x +box.width*0.5, box.y+box.height+120, 'down',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=-30}),
        cc.MoveBy:create(0.5, {x=0, y=30})
    ) )
  )
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.main_challenge = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil)
  
  return true
end



--[[
主界面点击宠物按钮的引导
z
button:允许点击的button
cbClick:点击后的回调函数
返回: 是否压入了引导界面
]]
function needMainPetGuide()
  return not _player.get().guide.main_pet
end

function checkMainPetGuide(z, button, cbClick)
  if not needMainPetGuide() then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local box = button:getBoundingBox()
  
  _guide.setWordFrom(_text_guide.main_pet, box.x+box.width*0.5+20, box.y+box.height, 'up', true)
  _guide.setHand(box.x+box.width*0.5, box.y+box.height+120, 'down',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=-30}),
        cc.MoveBy:create(0.5, {x=0, y=30})
    ) )
  )
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.main_pet = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil)
  
  return true
end

--[[
宠物界面内的引导
z
layer: 本对话框的顶层layer
button:允许点击的按钮
cbClick:点击后的回调函数
返回: 是否压入了引导界面
]]
function needPetGuide()
  --必须主界面点宠物按钮已完成才触发
  return _player.get().guide.main_pet
    and not _player.get().guide.pet
end

function checkPetGuide(z, layer, button, cbClick)
  if not needPetGuide() then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local scale = layer:getScale()
  layer:setScale(1)
  local box = button:getBoundingBox()
  local xy = button:convertToWorldSpace{x=0, y=0}
  layer:setScale(scale)
  box.x, box.y = xy.x, xy.y
    
  _guide.setWordFrom(_text_guide.pet, box.x+box.width*0.5, box.y, 'down')
  _guide.setHand()
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.pet = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil,
    true)
  
  return true
end

--[[
主界面点击奇迹按钮的引导
z
button:允许点击的button
cbClick:点击后的回调函数
返回: 是否压入了引导界面
]]
function checkMainMiracleGuide(z, button, cbClick)
  if _player.get().guide.main_miracle then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  local box = button:getBoundingBox()
  
  _guide.setWordFrom()
  _guide.setHand(box.x+box.width*0.5, box.y+box.height+120, 'down',
    cc.RepeatForever:create(
      cc.Sequence:create(
        cc.MoveBy:create(0.5, {x=0, y=-30}),
        cc.MoveBy:create(0.5, {x=0, y=30})
    ) )
  )
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.main_miracle = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil)
  
  return true
end

--[[
奇迹界面内的引导
z
layer: 本对话框的顶层layer
button:允许点击的按钮
cbClick:点击后的回调函数
返回: 是否压入了引导界面
]]
function checkMiracleGuide(z, layer, button, cbClick)
  --必须主界面点奇迹按钮已完成才触发
  if not _player.get().guide.main_miracle
    or _player.get().guide.miracle
  then
    return false
  end
  
  local g = _guide.create()
  g.z = z
  _mgr_scr.pushDialog(g)
  
  --对话框弹出时scale为0，需先恢复再取才可能
  local scale = layer:getScale()
  layer:setScale(1)
  local box = button:getBoundingBox()
  local xy = button:convertToWorldSpace{x=0,y=0}
  layer:setScale(scale)
  --WARNING TODO: fuck 2dx, 得到结果不正确。。暂硬来适应先
  box.x, box.y = xy.x-48, xy.y-108
    
  _guide.setWordFrom(_text_guide.miracle, box.x+box.width*0.5, box.y, 'down', true)
  _guide.setHand()
  _guide.setBoundingBox(box.x, box.y, box.width, box.height,
    nil, 
    nil,
    function(touch)
      _player.get().guide.miracle = true
      _player.setDirty()
      _player.save()
      _mgr_scr.popDialog()
      cbClick()
    end, 
    nil,
    true)
  
  return true
end


--检查加载的数据是否合理
function check(guide)
  local dirty = false
  
  if type(guide) ~= 'table' then
    guide, dirty = {}, true
  end
  
  for i, name in ipairs{'main', 'choose_hero', 
    'use_item', 'level_up', 'rescue',
    'main_rank', 'rank_1', 'rank_2',
    'main_challenge', 'challenge_choose_hero',
    'main_pet', 'pet',
    'main_miracle', 'miracle',
  }
  do
    if type(guide[name]) ~= 'boolean' then
      guide[name], dirty = false, true
    end
  end

  return guide, dirty
end
