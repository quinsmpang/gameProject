module('game.battle.team', package.seeall)

local _const = require('data.const')
local _text = require('data.text')
local _Hero = require('game.battle.hero').Hero
local _heros = require('data.hero').heros
local _ability = require('data.ability').heros
local _effect = require('game.battle.effect')
local _effects_data = require('data.effect')
local _item = require('game.battle.item')
local _data_items = require('data.item').items
--local _sprite_frames = require('game.mgr_spf').sprite_frames

local _Animation = require('game.battle.ani').Animation
local _Pet = require('game.battle.pet').Pet

local _mgr_snd = require('game.mgr_snd')
local _player = require('game.player')

local _aniUpdate = _Animation.inst_meta.update
local _strfmt = string.format


--[[
负责记录当前己方角色队伍，
以及队伍的前进、排位等。

特殊成员：
user_result 类型table，外部设，可选，默认为nil
  若设置，stop后有如下信息
  {
    distance: 距离
    
    golds: 总金币数
    golds_raw: 金币原始数
    golds_bonus_percent: 附加百分比
    
    score: 总分数
    score_raw: 分数原始数
    score_bonus_percent: 附加百分比
  }
  

内部成员
scene: 所属的scene

index: team所属的玩家
ui_golds, ui_gold_added: 金币ui，不存在时scene的can_drop必须为false或nil
gold_x, gold_y: 金币飞向目标在屏幕上的位置，不存在时scene的can_drop必须为false或nil
golds, score: 游戏过程中统计分数

heros: 数组，记录组内成员，成员是game.battle.hero.Hero实例
heros_potential: number, 等待加入的成员个数
pet: 宠物（若存在）
bonus: 额外附加的数据
--vit: 体力
]]

Team = require('util.class').class()

local _START_COFF = {
  [1]={x=0.5, y=0},
  [2]={x=0.4, y=0},
  [3]={x=0.6, y=0},
  [4]={x=0.8, y=0},
};

--各位置角色应处的位置，以及跟随者。人数不同阵型也不同
local _FORM = {
  [0]={
    anchor_ref={0},anchor_coeff={0},
    pet={off_x=-100, off_y=150, max_x=800, max_y=600, follow=0},
  },
  [1]={
    {off_x=0, off_y=100, max_x=800, max_y=600, follow=0},
    anchor_ref={1},anchor_coeff={1},
    pet={off_x=-100, off_y=150, max_x=800, max_y=600, follow=0},
  },
  [2]={
    {off_x=0, off_y=100, max_x=800, max_y=600, follow=0},
    {off_x=0, off_y=-100, max_x=500, max_y=600, follow=1},
    anchor_ref={1},anchor_coeff={1},
    pet={off_x=-100, off_y=150, max_x=800, max_y=600, follow=0},
  },
  [3]={
    {off_x=0, off_y=100, max_x=800, max_y=600, follow=0},
    {off_x=-50, off_y=-100, max_x=500, max_y=600, follow=1},
    {off_x=50, off_y=-100, max_x=500, max_y=600, follow=1},
    anchor_ref={1},anchor_coeff={1},
    pet={off_x=-100, off_y=150, max_x=800, max_y=600, follow=0},
  },
  [4]={
    {off_x=-50, off_y=100, max_x=800, max_y=600, follow=0},
    {off_x=50, off_y=100, max_x=800, max_y=600, follow=0},
    {off_x=0, off_y=-100, max_x=500, max_y=600, follow=1},
    {off_x=0, off_y=-100, max_x=500, max_y=600, follow=2},
    anchor_ref={1,2},anchor_coeff={0.5,0.5},
    pet={off_x=-150, off_y=150, max_x=800, max_y=600, follow=0},
  },
  [5]={
    {off_x=0, off_y=100, max_x=800, max_y=600, follow=0},
    {off_x=-100, off_y=100, max_x=800, max_y=600, follow=0},
    {off_x=100, off_y=100, max_x=800, max_y=600, follow=0},
    {off_x=-50, off_y=-100, max_x=500, max_y=600, follow=1},
    {off_x=50, off_y=-100, max_x=500, max_y=600, follow=1},
    anchor_ref={1},anchor_coeff={1},
    pet={off_x=-200, off_y=150, max_x=800, max_y=600, follow=0},
  },
};

local _FORM_RUSH = {
  [0]={
    anchor_ref={0},anchor_coeff={0},
    pet={off_x=-100, off_y=330, max_x=8000, max_y=1000, follow=0},
  },
  [1]={
    {off_x=0, off_y=460, max_x=8000, max_y=1000, follow=0},
    anchor_ref={1},anchor_coeff={1},
    pet={off_x=-100, off_y=330, max_x=8000, max_y=1000, follow=0},
  },
  [2]={
    {off_x=0, off_y=460, max_x=8000, max_y=1000, follow=0},
    {off_x=0, off_y=-100, max_x=5000, max_y=1000, follow=1},
    anchor_ref={1},anchor_coeff={1},
    pet={off_x=-100, off_y=330, max_x=8000, max_y=1000, follow=0},
  },
  [3]={
    {off_x=0, off_y=460, max_x=8000, max_y=1000, follow=0},
    {off_x=-50, off_y=-100, max_x=5000, max_y=1000, follow=1},
    {off_x=50, off_y=-100, max_x=5000, max_y=1000, follow=1},
    anchor_ref={1},anchor_coeff={1},
    pet={off_x=-100, off_y=330, max_x=8000, max_y=1000, follow=0},
  },
  [4]={
    {off_x=-50, off_y=460, max_x=8000, max_y=1000, follow=0},
    {off_x=50, off_y=460, max_x=8000, max_y=1000, follow=0},
    {off_x=0, off_y=-100, max_x=5000, max_y=1000, follow=1},
    {off_x=0, off_y=-100, max_x=5000, max_y=1000, follow=2},
    anchor_ref={1,2},anchor_coeff={0.5,0.5},
    pet={off_x=-150, off_y=330, max_x=8000, max_y=1000, follow=0},
  },
  [5]={
    {off_x=0, off_y=460, max_x=8000, max_y=1000, follow=0},
    {off_x=-100, off_y=460, max_x=8000, max_y=1000, follow=0},
    {off_x=100, off_y=460, max_x=8000, max_y=1000, follow=0},
    {off_x=-50, off_y=-100, max_x=5000, max_y=1000, follow=1},
    {off_x=50, off_y=-100, max_x=5000, max_y=1000, follow=1},
    anchor_ref={1},anchor_coeff={1},
    pet={off_x=-150, off_y=330, max_x=8000, max_y=1000, follow=0},
  },
};

local _MAX_HEROS = #_FORM

--[[
local _VIT_MAX = 100
local _VIT_RESTORE_SEC = 20
local _VIT_MIN_START_RUN = 20
local _VIT_RUN_CONSUME_SEC = 25
]]

local _X_MIN = 50
local _X_MAX = require('config').design.width - 50

--local _RUN_EFFECT_SEC = 0.2
local _JOIN_INVINCIBLE = 3

--[[
金币增加的比例
每帧变化值 = （实际值-显示值）× RADIO
radio按最多n秒达到同步来计算：
  设变化率为r，则希望 (1-r)^(n*fps) < err
  err是个小的值，因每帧变化至少1，err含义是金钱相差最多为1/err时仍能在指定时间内同步。
  最终得以下计算式
]]
local _UI_GOLD_ADD_RATIO 
= 1 - math.exp( 
  math.log(0.001) / (5 * require('config').design.fps)
)


Team.ctor = function(self, scene, index, ui_golds, ui_gold_added)
  self.user_result = nil
  
  self.scene = scene
  self.index = index;
  self.ui_golds, self.ui_gold_added = ui_golds, ui_gold_added
  if ui_golds then
    self.gold_x, self.gold_y = ui_golds:getPosition()
    --处理金币变化所需
    self._golds_display = 0
    self._ani_golds_display = _Animation(_effects_data.ui_golds_display, nil, nil, ui_golds)
    self._gold_added = 0
    self._ani_gold_added = _Animation(_effects_data.ui_gold_added, nil, nil, ui_gold_added)
  end
  self.golds = 0
  self.score = 0
  
  self.bonus = {
    golds_percent = 0,
    score_percent = 0,
    item_invincible_sec = 0,
    item_rush_sec = 0,
    item_bomb_percent = 0,
    --[[
      把角色攻击增加百分比记在这里。
      目前只对奇迹的效果放这，宠物另外算。
      若有其它改变，再重构
      {[hero_id]=power_percent_bonus}
    ]]
    heros={},
  }
  require('game.battle.miracle').setupBonus(self.bonus)
  
  self._started = false
  --self._ani
    
  self.form = _FORM
  self.heros = {
    [0] = { --不是真正的英雄，只是便于控制第一个的位置
      x=0, y=0,
    }
    --1~.. Hero实例
  }
  self.heros_potential = 0
  --是否全部自动拒绝加入
  self._hero_not_join = false
  --本次自动拒绝未解锁英雄？
  self._hero_deny = false
  
  --self.pet = nil
  
  --self.vit = _VIT_MAX
  --self.move_x = 0
  --self.running = false
  --self._run_effect_left = 0
  
  --暂只有群体加速度，有需要再改
  --self.status_acc = 0
  
  --[[
    道具使用情况
    bomb=battle.item.Bomb, --爆炸道具使用中的实例
    --无敌道具记录
    invincible={sec,sec_inv, left_sec, ui_bg,ui_bar, ani}
    --冲刺道具记录
    rush={sec,sec_inv,left_sec, ui_bg,ui_bar, ani, cb}
  ]]
  self._items = {}
end

--获取队伍的锚点，返回全队状态显示的定位点
local function _getTeamAnchorPoint(self)
  local heros = self.heros
  local info = self.form[#heros]
  local ref, coeff = info.anchor_ref, info.anchor_coeff
  local x, y = 0, 0
  for i=1, #ref do
    local h = heros[ref[i]]
    x = x + coeff[i]*h.x
    y = y + coeff[i]*h.y
  end
  return x, y
end

--道具相关处理
local _clearItems, _updateItems, _newHeroItem


local function _heroEnqueue(self, hero)
  --[[
  --暂只按加速算
  if self.status_acc > 0 then
    hero:setAcceleration(self.status_acc)
  end
  ]]
  hero:teamJoined(self)
  if self.pet then
    self.pet:heroAffect(hero)
  end
  
  local bonus = self.bonus.heros[hero.sdata.id]
  if bonus and bonus>0 then
    local add = hero.ability.power * bonus
    hero.attack_power = hero.attack_power + bonus
  end
end

local function _heroDequeue(self, hero)
  --奇迹暂只是加攻击，不处理也没关系
  if self.pet then
    self.pet:heroUnaffect(hero)
  end
  hero:teamLeaved(self)
end

local function _putHeroAt(self, index, hero_id, x, y, no_status)
  local lv = _player.get().heros_level[hero_id]
  local abl = _ability[hero_id]
  lv = math.max(1, math.min(lv, #abl))
  abl = abl[lv]
  local h = _Hero(self.scene, hero_id, abl, x, y)
  self.heros[index] = h
  
  _heroEnqueue(self, h)
  
  if not no_status then
    h:setInvincible(_JOIN_INVINCIBLE)
    _newHeroItem(self, h)
  end
  
  return h
end

local function _findReplaceableHero(self)
  local n = #self.heros
  if n < _MAX_HEROS then
    return n + 1
  end
  
  local index
  local prio = math.huge
  for i, h in ipairs(self.heros) do
    local p = h.sdata.leave_priority
    if p < prio then
      prio = p
      index = i
    end
  end
  return index
end

local function _reorder(self)
  local heros = self.heros
  for i,h in ipairs(heros) do
    local prio = h.sdata.front_priority
    local pos = i
    while pos > 1 do
      local curr = heros[pos-1]
      if prio >= curr.sdata.front_priority then
        break
      end
      heros[pos] = curr
      pos = pos - 1
    end
    heros[pos] = h
  end
end

Team.inst_meta.addHero = function(self, hero_id, x, y, no_status)
  if not x then
    local coff = _START_COFF[self.index]
    x, y = self.scene.width*coff.x, self.scene.distance
  end
  
  local index = _findReplaceableHero(self)
  local old_hero = self.heros[index]
  if old_hero then
    _heroDequeue(self, old_hero)
  end
  local cur_hero = _putHeroAt(self, index, hero_id, x, y, no_status)
  _reorder(self)
  
  local mgr_evt = self.scene.mgr_evt
  if mgr_evt then
    mgr_evt.publish('team.hero_changed', self)
  end
  
  local uif = self.scene.ui_func
  if uif then
    if old_hero then
      uif.popTip(string.format(
          _text.HERO_REPLACE_FORMAT,
          cur_hero.sdata.name, old_hero.sdata.name))
    else
      uif.popTip(string.format(_text.HERO_JOIN_FORMAT, cur_hero.sdata.name))
    end
  end
  return cur_hero
end

Team.inst_meta.removeHero = function(self, hero)
  --cclog('removeHero')
  local heros = self.heros
  for i,h in ipairs(heros) do
    if h == hero then
      local n = #heros
      heros[i] = heros[n]
      heros[n] = nil
      _reorder(self)
      _heroDequeue(self, h)
      
      local mgr_evt = self.scene.mgr_evt
      if mgr_evt then
        mgr_evt.publish('team.hero_changed', self)
      end
      return
    end
  end
end

Team.inst_meta.removeAllHeros = function(self)
  local pet = self.pet
  local heros = self.heros
  for i,h in ipairs(heros) do
    heros[i] = nil
    _heroDequeue(self, h)
  end
  
  local mgr_evt = self.scene.mgr_evt
  if mgr_evt then
    mgr_evt.publish('team.hero_changed', self)
  end
end


Team.inst_meta.setPet = function(self, pet_id)
  local pet = self.pet
  if pet then
    for i,h in ipairs(self.heros) do
      pet:heroUnaffect(h)
    end
    pet:teamLeave(self)
    pet:clean()
    self.pet = nil
  end
  if pet_id then
    pet = _Pet(self.scene, pet_id)
    self.pet = pet
    for i,h in ipairs(self.heros) do
      pet:heroAffect(h)
    end
    pet:teamJoin(self)
  end
end

--start/stop 应由scene触发
Team.inst_meta.start = function(self)
  local coff = _START_COFF[self.index]
  local h0 = self.heros[0]
  h0.x, h0.y = self.scene.width *coff.x, self.scene.height *coff.y
  
  self.heros_potential = 0
  self._hero_deny = false
  --self.move_x = 0
  --self.running = false
  self._started = true
  self.form = _FORM
  
  --[[local ani = _Animation(_effects_data.team_tag[self.index])
  ani.x, ani.y, ani.z = pos.x, 0, _const.SCENE_Z_EFFECT
  ani.node = ani.ani_sprite
  self.scene:addObject(ani)
  self._ani = ani
  ]]
  --初始化信息
  --[[
  self.vit = _VIT_MAX
  local uif = self.scene.ui_func
  if uif then
    uif.setVit(self.index, self.vit)
  end
  ]]
  
  if self.ui_golds then
    self._golds_display = self.golds
    self._gold_added = 0
    self.ui_golds:setString(_strfmt('%dG', self.golds))
  end
end

local function _fillResult(self)
  local r = self.user_result
  if not r then return end
  
  r.distance = math.floor(self.scene.distance)
  r.golds_raw = self.golds
  r.golds_bonus_percent = self.bonus.golds_percent
  r.golds = math.floor(r.golds_raw * (1 + r.golds_bonus_percent))
  r.score_raw = self.score
  r.score_bonus_percent = self.bonus.score_percent
  r.score = math.floor(r.score_raw * (1 + r.score_bonus_percent))
end

Team.inst_meta.stop = function(self)
  --应最先记录结果，以便在宠物等清除前生效
  _fillResult(self)
  
  --self.scene:removeObject(self._ani)
  --self._ani = nil
  _clearItems(self)
  
  --self._hero_deny = false
  
  local heros = self.heros
  for i, h in ipairs(heros) do
    heros[i] = nil
    _heroDequeue(self, h)
    h:clean()
  end
  if self.pet then
    self.pet:teamLeave(self)
    self.pet:clean()
    self.pet = nil
  end
  
  --self.move_x = 0
  --[[
  if self.running then
    self.running = false
  end
  ]]
  
  --停止金币变动
  if self.ui_golds then
    self._golds_display = self.golds
    self._gold_added = 0
    self.ui_golds:setString(_strfmt('%dG', self.golds))
    self.ui_golds:setScale(_effects_data.ui_golds_display.init_scale)
    self.ui_gold_added:setVisible(false)
    self._ani_golds_display:stop()
    self._ani_gold_added:stop()
  end
  
  self._started = false
end

local _mmax, _mmin, _mfloor = math.max, math.min, math.floor

local function _updatePos(self, dt)
  local heros = self.heros
  
  heros[0].y = self.scene.distance
  --[[
  local h0 = heros[0]
  
  local x, y = h0.x, self.scene.distance
  x = _mmax(_X_MIN, _mmin(x + self.move_x*dt, _X_MAX))
  
  --self._ani.x, self._ani.y = x, y
  
  h0.x, h0.y = x, y
  ]]
  
  local function set(node, info, follow, dt)
    local x = follow.x + info.off_x
    local y = follow.y + info.off_y
    if node.x < x then
      node.x = _mmin(node.x+info.max_x*dt, x)
    elseif node.x > x then
      node.x = _mmax(node.x-info.max_x*dt, x)
    end
    if node.y < y then
      node.y = _mmin(node.y+info.max_y*dt, y)
    elseif node.y > y then
      node.y = _mmax(node.y-info.max_y*dt, y)
    end
  end

  local form = self.form[#heros]
  for i, h in ipairs(heros) do
    local info = form[i]
    set(h, info, heros[info.follow], dt)
  end
  
  local pet = self.pet
  if pet then
    local info = form.pet
    set(pet, info, heros[info.follow], dt)
  end
end

--[[
local function _updateRunEffect(self, dt)
  if not self.running then return end
  local t = self._run_effect_left - dt
  if t <= 0 then
    t = _RUN_EFFECT_SEC
    local scene, Effect = self.scene, _effect.Effect
    for i, h in ipairs(self.heros) do
      Effect(scene, h.x, h.y, 0, _effects_data.run)
    end
    _mgr_snd.playEffect('sound/step.mp3')
  end
  self._run_effect_left = t
end
]]

--[[
local function _updateVit(self, dt)
  local vit = self.vit
  if self.running then
    vit = vit - _VIT_RUN_CONSUME_SEC*dt
    if vit <= 0 then
      self.running = false
      vit = 0
    end
    local uif = self.scene.ui_func
    if uif then
      uif.setVit(self.index, vit)
    end
  elseif vit < _VIT_MAX then
    vit = _mmin(vit+_VIT_RESTORE_SEC*dt, _VIT_MAX)
    local uif = self.scene.uif
    if uif then
      uif.setVit(self.index, vit)
    end
  end
  self.vit = vit
end
]]

local function _updateUIGolds(self, dt)
  local golds_disp, golds = self._golds_display, self.golds
  local ani = self._ani_golds_display
  if golds_disp < golds then
    if ani:isEnd() then
      ani:play('adding')
    end
    local diff = _mfloor((golds - golds_disp) * _UI_GOLD_ADD_RATIO)
    golds_disp = golds_disp + _mmax(diff, 1)
    self._golds_display = golds_disp
    self.ui_golds:setString(_strfmt('%dG', golds_disp))
  end
  _aniUpdate(ani, dt)
  
  if self._gold_added ~= 0 then
    if _aniUpdate(self._ani_gold_added, dt) then
      self._gold_added = 0
    end
  end
end

Team.inst_meta.update = function(self, dt)
  _updatePos(self, dt)
  --_updateRunEffect(self, dt)
  --_updateVit(self, dt)
  _updateItems(self, dt)
  if self.ui_golds then
    _updateUIGolds(self, dt)
  end
end

Team.inst_meta.stageStart = function(self)
  for i, hero in ipairs(self.heros) do
    if hero.cross_level then
      hero.invincible_count = hero.invincible_count - 1
      hero.cross_level = nil
    end
  end
  --self._hero_deny = false
end

Team.inst_meta.stageEnd = function(self)
  _clearItems(self)
  for i, hero in ipairs(self.heros) do
    hero.cross_level = true
    hero.invincible_count = hero.invincible_count + 1
  end
  --self._hero_deny = false
end

Team.inst_meta.moveOffsetX = function(self, off_x, by_anchor)
  if not self._started then return end
  
  local x
  local heros = self.heros
  if by_anchor then
    x = _getTeamAnchorPoint(self)
  else
    x = heros[0].x
  end
  x = _mmax(_X_MIN, _mmin(x + off_x, _X_MAX))
  heros[0].x = x
end

--[[
Team.inst_meta.move = function(self, value)
  if self._started then
    self.move_x = value
  end
end
]]

--[[
Team.inst_meta.run = function(self, is_run)
  if not self._started or self.running == is_run then
    return
  end
  if is_run then
    if self.vit > _VIT_MIN_START_RUN then
      self.running = true
      self._run_effect_left = 0
    end
  else
    self.running = false
  end
end
]]

Team.inst_meta.addGolds = function(self, num)
  local n = self.golds + num
  self.golds = n
  
  if self.ui_golds then
    local added = self._gold_added + num
    self._gold_added = added
    self.ui_gold_added:setString(_strfmt('+%d', added))
    self._ani_gold_added:play('show')
  end
end

Team.inst_meta.addScore = function(self, num)
  local n = self.score + num
  self.score = n
end



local function _checkJoinImm(self, hero_id, cb_join)
  if not self.scene.ui_func 
    or self._hero_not_join  --当前忽略加入（如加速中）
  then
    cb_join(false)
    return true
  end
  
  local index = _findReplaceableHero(self)
  local hero = self.heros[index]
  --满员且全是进阶的英雄，拒绝之
  if hero and hero.sdata.primitive_id then
    cb_join(false)
    return true
  end
  
  --可加入，且该英雄已解锁，直接加入之
  if _player.get().heros_unlock[hero_id] then 
    cb_join(true)
    return true
  end
  
  --本次已默认拒绝，或是关卡设置不允许加入
  if self._hero_deny 
    or not self.scene.stage:allowJoin(hero_id)
  then
    cb_join(false)
    return true
  end
end
  

Team.inst_meta.askHeroJoin = function(self, hero_id, cb_join)
  self.heros_potential = self.heros_potential + 1
  
  self.scene:postChecker(
    _const.CHECKER_PRIO_JOIN,
    function()
      if _checkJoinImm(self, hero_id, cb_join) then
        self.heros_potential = self.heros_potential - 1
        return true
      end
            
      self.scene:pause(true)
      self.scene.ui_func.popPrisonerDialog(
        hero_id,
        function(ok)
          self.heros_potential = self.heros_potential - 1
          if not ok then
            --拒绝则本次不再问
            self._hero_deny = true
          end
          self.scene:unpause()
          cb_join(ok)
          self.scene:endChecker()
        end)
    end)
end


--目前只有加速，按需改进
--[[
Team.inst_meta.addStatus = function(self, status_type, status_value)
  local v = self.status_acc + status_value
  self.status_acc = v
  for i,h in ipairs(self.heros) do
    h:setAcceleration(v)
  end
end

Team.inst_meta.removeStatus = function(self, status_type, status_value)
  local v = self.status_acc- status_value
  self.status_acc = v
  for i,h in ipairs(self.heros) do
    h:setAcceleration(v)
  end
end
]]

------使用道具
--bomb
Team.inst_meta.checkUseItemBomb = function(self)
  return self._started
end

local function _clearBomb(self, bomb)
  bomb:cleanFromTeam()
  self._items.bomb = nil
end

Team.inst_meta.useItemBomb = function(self)
  local bomb = self._items.bomb
  if bomb then
    _clearBomb(self, bomb)
  end
  bomb = _item.Bomb(self, 1+self.bonus.item_bomb_percent)
  self._items.bomb = bomb
end

local function _updateBomb(self, dt, bomb)
  if bomb:isEnd() then
    _clearBomb(self, bomb)
  end
end


--invincible
Team.inst_meta.checkUseItemInvincible = function(self, sec)
  if not self._started then
    return nil
  end
  return sec + self.bonus.item_invincible_sec
end

Team.inst_meta.useItemInvincible = function(self, sec, ui_bg, ui_bar)
  if self._items.invincible then
    local inv = self._items.invincible
    inv.sec = sec
    inv.sec_inv = 100/sec
    inv.left_sec = sec
    return
  end

  local sdata = _data_items.invincible
  local ani = _Animation(sdata.object)
  local off_x, off_y = sdata.offset[1], sdata.offset[2]
  
  local h1 = self.heros[1]
  ani.x, ani.y, ani.z = h1.x+off_x, h1.y+off_y, _const.SCENE_Z_EFFECT
  ani.node = ani.ani_sprite
  self.scene:addObject(ani)
  ani:play('play')
  
  self._items.invincible = {
    sec=sec, sec_inv=100/sec,
    left_sec=sec,
    ui_bg=ui_bg, ui_bar=ui_bar,
    ani=ani,
    off_x=off_x, off_y=off_y
  }
  for i, h in ipairs(self.heros) do
    h.invincible_count = h.invincible_count + 1
    local g = h.guard
    for hit_type, count in pairs(g) do
      g[hit_type] = count + 1
    end
  end
  ui_bg:setVisible(true)
end

local function _newHeroInvincible(self, hero)
  hero.invincible_count = hero.invincible_count + 1
  local g = hero.guard
  for hit_type, count in pairs(g) do
    g[hit_type] = count + 1
  end
end

local function _clearInvincible(self, inv)
  self.scene:removeObject(inv.ani)
  for i, h in ipairs(self.heros) do
    h.invincible_count = h.invincible_count - 1
    local g = h.guard
    for hit_type, count in pairs(g) do
      g[hit_type] = count - 1
    end
  end
  inv.ui_bg:setVisible(false)
  self._items.invincible = nil
end

local function _updateInvincible(self, dt, inv)
  local left_sec = inv.left_sec - dt
  if left_sec <= 0 then
    _clearInvincible(self, inv)
    return
  end
  
  inv.left_sec = left_sec
  inv.ui_bar:setPercent(inv.sec_inv *left_sec)
  local ani = inv.ani
  _aniUpdate(ani, dt)
  
  local x, y = _getTeamAnchorPoint(self)
  ani.x, ani.y = x+inv.off_x, y+inv.off_y
end


--rush
Team.inst_meta.checkUseItemRush = function(self, sec)
  if not self._started then
    return nil
  end
  return sec + self.bonus.item_rush_sec
end

Team.inst_meta.useItemRush = function(self, sec, ui_bg, ui_bar, cb)
  if self._items.rush then
    local rush = self._items.rush
    rush.sec = sec
    rush.sec_inv = 100/sec
    rush.left_sec = sec
    return
  end

  local ani = _item.Rush(self, _getTeamAnchorPoint(self))
  self._items.rush = {
    sec=sec, sec_inv=100/sec,
    left_sec=sec,
    ui_bg=ui_bg, ui_bar=ui_bar,
    ani=ani,
    cb=cb,
  }
  self.form = _FORM_RUSH
  self._hero_not_join = true
  
  for i, h in ipairs(self.heros) do
    h.disable_attack = true
    h.invincible_count = h.invincible_count + 1
    local g = h.guard
    for hit_type, count in pairs(g) do
      g[hit_type] = count + 1
    end
  end
  self.scene.item_attractor = self.heros[1]
  
  ui_bg:setVisible(true)
end

local function _newHeroRush(self, hero)
  hero.disable_attack = true
  hero.invincible_count = hero.invincible_count + 1
  local g = hero.guard
  for hit_type, count in pairs(g) do
    g[hit_type] = count + 1
  end
end

local function _clearRush(self, rush)
  self._items.rush.ani:cleanFromTeam()
  
  for i, h in ipairs(self.heros) do
    h.disable_attack = false
    h.invincible_count = h.invincible_count - 1
    local g = h.guard
    for hit_type, count in pairs(g) do
      g[hit_type] = count - 1
    end
  end
  self.scene.item_attractor = false
  
  rush.ui_bg:setVisible(false)
  self.form = _FORM
  self._hero_not_join = false
  self._items.rush = nil
end

local function _updateRush(self, dt, rush)
  local left_sec = rush.left_sec - dt
  if left_sec <= 0 then
    local cb = rush.cb
    _clearRush(self, rush)
    if cb then cb() end
    return
  end
  
  rush.left_sec = left_sec
  rush.ui_bar:setPercent(rush.sec_inv *left_sec)
  rush.ani:updatePosition(_getTeamAnchorPoint(self))
end


--item
_clearItems = function(self)
  local c = self._items
  if c.bomb then
    _clearBomb(self, c.bomb)
  end
  if c.invincible then
    _clearInvincible(self, c.invincible)
  end
  if c.rush then
    _clearRush(self, c.rush)
  end
end

_updateItems = function(self, dt)
  local c = self._items
  if c.bomb then
    _updateBomb(self, dt, c.bomb)
  end
  if c.invincible then
    _updateInvincible(self, dt, c.invincible)
  end
  if c.rush then
    _updateRush(self, dt, c.rush)
  end
end

_newHeroItem = function(self, hero)
  local c = self._items
  if c.invincible then
    _newHeroInvincible(self, hero)
  end
  if c.rush then
    _newHeroRush(self, hero)
  end
end

