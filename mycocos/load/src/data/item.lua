local _config = require('config')
local _const = require('data.const')

module('data.item')
  
golds = {
  drop = {
    0.5,
    height=100,
    a=-100, b=0, c=100
  },
  attract = 0.5,
  move = {
    0.5,
  },
  range = {
    left=-200, right=200, top=300, bottom=200,
    minx=50, maxx=-50
  },

  animations = {
    collect_up = {
      sound='sound/coin1.mp3',
      {
        0.3,
        actions={scale={1,2}},
      },
    },
  },

  {
    {'effect/gold1.png',18,16},
    coll = {-20,20,20,-20},
    value = 1,
  },
  {
    {'effect/gold5.png',24,20},
    coll = {-24,24,20,-20},
    value = 5,
  },
  {
    {'effect/gold10.png',20,20},
    coll = {-24,24,20,-20},
    value = 10,
  },
}; --golds

draw_coin = {
  {'effect/draw_coin.png',19,19},
  coll = {-20,20,20,-20},
  --
  effect = {
    {'effect/draw_coin_light.png', 26, 26},
    init={position={7,32,0}},
    animations = {
      shine = {
        loop=true,
        {
          0.1,
          actions={
            scale={0.5, 1},
            alpha={255, 128},
          },
        },
        {
          0.1,
          actions={
            scale={1, 0.5},
            alpha={128, 255},
          },
        },
      },
    },
  },
}; --draw_coin


prisoner = {
  collision={-40,40,80,0},
  
  fence={
    animations = {
      imprison={
        {
          0,
          {'effect/fence.png',42,81},
        },
      },
      rescue={
        {
          0,
          {'effect/fence_down.png',42,76},
        },
      },
    },
  },
  hero={
    init={
      position={42,0,-1},
    },
    z_rescued = 0,
  },
  word={
    animations={
      imprison={
        loop=true,
        {
          0.5,
          {'effect/word_help.png',53,105},
          init={
            position={40,120,0},
          },
          actions={
            scale={1,1.5}
          },
        },
        {
          0.5,
          actions={
            scale={1.5,1},
          },
        },
      },
      rescue={
        {
          1,
          {'effect/word_thankyou.png',47.5,98},
          init={
            position={40,120,1},
          },
          actions={
            scale={1,2}
          }
        },
        {
          0.5,
          actions={
            scale={2,1}
          }
        }
      },
      join={
        {
          0.8,
          {'effect/word_takeme.png',46,97},
          init={
            position={0,100,1},
          },
          actions={
            scale={1,1.5}
          }
        },
        {
          0.3,
          actions={
            scale={1.5,0}
          }
        },
      },
    },
  },
  
  sound_join = 'sound/join.mp3',
  
  items = {
    {p=0.35, {type='golds',0,0,1}},
    {p=0.3, {type='golds',3,0,1}},
    {p=0.25, {type='golds',1,1,1}},
    {p=0.1, {type='golds',1,2,1}},
  },
}; --prisoner


items={
  bomb = {
    power = 90,
    hit_stub = 0.1,
    knock_back = 500,
    cancel_type = _const.CANCEL_TYPE_ALL,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_MAGIC,
    kill_type = _const.KILL_TYPE_FIRE,
    collision = {-_config.design.width*2, _config.design.width*2, 
      _config.design.height*2, -_config.design.height*2},
    times = 9,
    range = {100, _config.design.width-100, 200, _config.design.height-150},
    object={
      init={
        scale={2, 2}
      },
      animations={
        explode={
          sound='sound/meteor2.mp3',
          {
            0.05,
            {'effect/item_bomb_1.png',76,82},
          },
          {
            0.05,
            {'effect/item_bomb_2.png',91,114},
          },
          {
            0.05,
            {'effect/item_bomb_3.png',115,119},
          },
          {
            0.05,
            {'effect/item_bomb_4.png',150,135},
          },
          {
            0.05,
            {'effect/item_bomb_5.png',115,155},
          },
          {
            0.05,
            {'effect/item_bomb_6.png',165,126},
          },
        },
      },
    }, --object
    
    effect = {
      {'effect/magic_hit.png',54,48},
      animations={
        play={
          sound='sound/magic2.mp3',
          {
            0.1,
            init={
              scale={1.5, 1.5},
            },
            actions={
              alpha = {255, 128},
            },
          },
          {
            0.1,
            actions={
              scale={1.5, 2},
              alpha={128,64},
            },
          },
        },
      },
    }, --effect
    
  }, --bomb
  
  invincible = {
    offset={0, -100},
    object={
      init={
        scale={2,2},
      },
      animations={
        play={
          loop=true,
          {
            0.1,
            {'effect/item_invincible_1.png', 86, 215},
          },
          {
            0.1,
            {'effect/item_invincible_2.png', 86, 215},
          },
          {
            0.1,
            {'effect/item_invincible_3.png', 86, 215},
          },
        },
      },
    },
  }, --invincible
  
  rush = {    
    power = 20,
    kill_instant_not_boss = true,
    hit_stub = 0,
    knock_back = 360,
    knock_back_coeff = 1,
    cancel_type = _const.CANCEL_TYPE_ALL,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_NONE,
    kill_type = _const.KILL_TYPE_APART,
    disable_dead_ani = true,
        
    collision={-128,128,16,-320},
    offset={0, 100},
    velocity = 800,
    hit_sound = 'sound/chongci.mp3',
    bg = {'effect/item_rush_0.png', 82, 15, 2},
    object={
      init={
        position={72, 68, 0},
      },
      animations={
        play = {
          loop=true,
          {
            0.1,
            {'effect/item_rush_1.png', 99, 15},
          },
          {
            0.1,
            {'effect/item_rush_2.png', 95, 15},
          },
          {
            0.1,
            {'effect/item_rush_3.png', 97, 15},
          },
          {
            0.1,
            {'effect/item_rush_4.png', 97, 15},
          },
        },
      },
    },
  }, --rush

}; --items
