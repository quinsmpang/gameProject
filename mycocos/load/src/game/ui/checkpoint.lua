module('game.ui.checkpoint', package.seeall)



local function _loadNormal(level)
    local panel = cc.CSLoader:createNode('ui/checkpoint.csb')
    
    local font_level = ccui.Helper:seekWidgetByNameOnNode(panel, 'font_level')
    font_level:setString(string.format('%d', level))

    local action = cc.CSLoader:createTimeline('ui/checkpoint.csb')
    panel:runAction(action)
    action:gotoFrameAndPlay(0,false)

    return panel
end

local function _loadBonus()
  local panel = cc.CSLoader:createNode('ui/bonus.csb')
  
  local action = cc.CSLoader:createTimeline('ui/bonus.csb')
  panel:runAction(action)
  action:gotoFrameAndPlay(0, false)
  
  local spr = panel:getChildByName('ui_bonus_chest')
  --用1/30秒做单位 WTF
  local sec = action:getDuration() * 0.033

  panel:runAction(
    cc.Sequence:create(
      cc.DelayTime:create(sec+0.1),
      cc.CallFunc:create(function() spr:setSpriteFrame('ui/bonus/chest_2.png') end),
      cc.DelayTime:create(0.1),
      cc.CallFunc:create(function() spr:setSpriteFrame('ui/bonus/chest_3.png') end)
    )
  )
  return panel
end

function create(level)
  if level then
    return _loadNormal(level)
  else
   return _loadBonus()
  end
end