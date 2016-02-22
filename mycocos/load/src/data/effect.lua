local _const = require('data.const')

module('data.effect')

ready_go = {
  animations={
    play={
      {
        0.5,
        {'effect/ready.png', 123, 44},
        actions={scale={0,1},},
      },
      {
        0.25,
        actions={alpha={255,0},},
      },
      {
        0.5,
        {'effect/go.png', 52, 40},
        init={alpha=255},
        actions={scale={0,1},},
      },
      {
        0.25,
        actions={alpha={255,0},},
      },
    },
  },
}

unpausing = {
  animations={
    play={
      {
        0.5,
        {'effect/go.png', 52, 40},
        init={alpha=255},
        actions={scale={0,1},},
      },
      {
        0.25,
        actions={alpha={255,0},},
      },
    },
  },
}

vortex_in = {
  {'bg/vortex.png', 512, 512},
  animations={
    play={
      sound='sound/blizzard.mp3',
      {
        1.5,
        actions={
          rotate={0,720},
          alpha={0,255},
          scale={0,1.2},
        },
      },
      {
        1,
        actions={
          rotate={0,1440},
        }
      },
      {
        0.5,
        actions={
          rotate={0,720},
          alpha={255,0},
          scale={1.2,0},
        }
      },
    },
  },
}

vortex_out = {
  {'bg/vortex.png', 512, 512},
  animations={
    play={
      sound='sound/blizzard.mp3',
      {
        1.5,
        actions={
          rotate={720,0},
          alpha={0,255},
          scale={0,1.2},
        },
      },
      {
        1,
        actions={
          rotate={1440,0},
        },
      },
      {
        0.5,
        actions={
          rotate={720,0},
          alpha={255,0},
          scale={1.2,0},
        },
      },
    },
  },
}


bonus_light = {
  {'bg/bonus_light.png', 15, 430},
  animations={
    play={
      {
        0.5,
        actions={
          alpha={0,255},
          scale={0, 1.2},
        },
      },
      {
        0.3,
        actions={
          alpha={255,0},
          scale={1.2, 0},
        },
      },
    }
  }
}

boss_tag = {
  animations={
    play={
      loop=true,
      {
        0.5,
        {'effect/boss.png', 125, 55},
        init={position={0,0,-1}},
        actions={scale={1, 1.5},},
      },
      {
        0.5,
        actions={scale={1.5, 1},},
      },
    },
  },
}

boss_dying = {
  animations={
    play={
      loop=true,
      {
        0.5,
        actions={
          color={{255,255,255}, {255,0,0}}
        },
      },
      {
        0.5,
        actions={
          color={{255,0,0}, {255,255,255}}
        },
      },
    },
  }
}


cancelled = {
  [_const.CANCEL_TYPE_SWORD] = {
    {'effect/cancel.png',45,32},
    animations={
      play={
        sound='sound/blade3.mp3',
        {
          0.2,
          actions={
            scale={1,2},
            alpha={255,0},
          },
        },
      },
    },
  },
  [_const.CANCEL_TYPE_ARROW] = {
    {'effect/cancel.png',45,32},
    animations={
      play={
        sound='sound/arrow3.mp3',
        {
          0.2,
          actions={
            scale={1,2},
            alpha={255,0},
          },
        },
      },
    },
  },
  [_const.CANCEL_TYPE_MAGIC] = {
    {'effect/cancel.png',45,32},
    animations={
      play={
        sound='sound/magic3.mp3',
        {
          0.2,
          actions={
            scale={1,2},
            alpha={255,0},
          },
        },
      },
    },
  },
}

hit = {
  guard = {
    {'effect/guard.png',38,14},
    animations={
      play={
        {
          0.2,
          actions={
            scale={1,1.2},
            alpha={255,0},
          },
        },
      },
    },
  },
  
  reflect = {
    {'effect/reflect.png',43,41},
    animations={
      play={
        sound='sound/reflect.mp3',
        {
          0.2,
          actions={
            scale={1,2},
            alpha={255,0},
          },
        },
      },
    },
  },
  
  knock_dead = {
    {'effect/sword_hit.png',55,14},
    init={
      rotation_range={0,180},
    },
    animations={
      play={
        {
          0.2,
          actions={
            scale_x={1,200},
            scale_y={0.5,0},
          },
        },
      },
    },
  },
  
  [_const.HIT_TYPE_SWORD] = {
    {'effect/sword_hit.png',55,14},
    init={
      rotation_range={0,180},
    },
    animations={
      play={
        sound='sound/blade2.mp3',
        {
          0.1,
          init={
            scale={1,0.5},
          },
        },
        {
          0.1,
          actions={
            scale_x={1,5},
            scale_y={0.5,0},
            alpha={255,64},
          },
        },
      },
    },
  },
  [_const.HIT_TYPE_ARROW] = {
    {'effect/arrow_hit.png',35,37},
    animations={
      play={
        sound='sound/arrow2.mp3',
        {
          0.1,
          init={
            scale={1,1},
          },
          actions={
            alpha={255,128},
          },
        },
        {
          0.1,
          actions={
            scale = {1, 2},
            alpha = {128, 64},
          },
        },
      },
    },
  },
  [_const.HIT_TYPE_MAGIC] = {
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
  },
} --hit
  
run={
  {'effect/run.png',20,22},
  animations={
    play={
      {
        0.3,
        actions={
          scale={1,2.5},
          alpha={255,0}
        },
      },
    },
  },
}

ui_golds_display = {
  init_scale = 1.3,
  animations = {
    adding = {
      {
        0.5,
        actions={ scale={1.3, 1.5} }
      },
      {
        0.5,
        actions={ scale={1.5, 1.3} }
      }
    }
  }
}

ui_gold_added = {
  animations = {
    show = {
      {
        0.3,
        init={
          visible=true,
          alpha=255,
        },
        actions = {
          scale={1, 1.2},
        }
      },
      {
        0.3,
        actions = {
          scale={1.2, 1},
          alpha={255, 0},
        }
      },
      {
        0,
        init={visible=false},
      }
    }
  } --animations
} --ui_gold_added

jump_down={
  {'effect/jump_down.png', 76, 56},
  animations={
    play={
      sound = 'sound/down.mp3',
      {
        0.5,
        actions={
          scale={1,2.5},
          alpha={255,0},
        },
      },
    },
  },
}

status={
  --[[
  frozen = {
    id='frozen',
    {'effect/frozen.png',67,123},
    init={position={0,0,1}},
  }, --frozen
  ]]
  
  --[[
  acceleration = {
    id='acceleration',
    {'effect/accelerate.png',31,21},
    init={
      position={0,0,-1},
    },
    animations={
      play={
        loop=true,
        {
          1,
          actions={
            scale_x = {1,1.2},
            scale_y = {1,0.8},
            alpha = {255,128},
          },
        },
        {
          1,
          actions={
            scale_x = {1.2,1},
            scale_y = {0.8,1},
            alpha = {128,255},
          },
        },
      },
    },
  }, --acceleration
  ]]
  
  invincible = {
    id='invincible',
    animations={
      play={
        loop=true,
        {
          0.15,
          init={visible=false},
        },
        {
          0.15,
          init={visible=true},
        },
      },
      exit={
        {
          0,
          init={visible=true},
        },
      },
    },
  }, --invincible
  
  
}; --status


dead={
  shatter = {
    animations = {
      dead = {
        {
          0.2,
          {'effect/dead_normal_1.png',110,84},
        },
        {
          0.2,
          {'effect/dead_normal_2.png',129,106},
        },
        {
          0.2,
          {'effect/dead_normal_3.png',125,113},
        }
      },
    },
  },
  cut = {
    animations = {
      dead_left = {
        {
          0.5,
          actions = {
            rotate = {0, -90},
            alpha = {255, 0},
          },
        },
      },
      dead_right = {
        {
          0.5,
          actions = {
            rotate = {0, 90},
            alpha = {255, 0},
          },
        },
      },
      dead_bottom = {
        {
          0.5,
          actions = {
            alpha = {255, 0},
          },
        },
      },
      dead_top = {
        {
          0.5,
          actions = {
            alpha = {255, 0},
          },
        },
      },
    },
  },
  fire = {
    init = {
      scale={1.5, 1.5},
    },
    animations = {
      dead = {
        {
          0.05,
          {'effect/dead_fire_01.png', 25, 44},
        },
        {
          0.05,
          {'effect/dead_fire_02.png', 38, 71},
        },
        {
          0.1,
          {'effect/dead_fire_03.png', 51, 103},
        },
        {
          0.1,
          {'effect/dead_fire_04.png', 58, 103},
        },
        {
          0.1,
          {'effect/dead_fire_03.png', 51, 103},
        },
        {
          0.1,
          {'effect/dead_fire_04.png', 58, 103},
        },
        {
          0.1,
          {'effect/dead_fire_03.png', 51, 103},
        },
        {
          0.1,
          {'effect/dead_fire_04.png', 58, 103},
        },
        {
          0.05,
          {'effect/dead_fire_05.png', 61, 102},
        },
        {
          0.05,
          {'effect/dead_fire_06.png', 48, 69},
        },
        {
          0.08,
          {'effect/dead_fire_07.png', 43, 69},
        },
        {
          0.08,
          {'effect/dead_fire_08.png', 51, 68},
        },
        {
          0.08,
          {'effect/dead_fire_09.png', 58, 64},
        },
        {
          0.08,
          {'effect/dead_fire_10.png', 51, 52},
        },
        {
          0.08,
          {'effect/dead_fire_11.png', 43, 42},
        },
        {
          0.08,
          {'effect/dead_fire_12.png', 50, 37},
        },
        {
          0.2,
          actions={
            alpha={255,64},
          },
        },
      },
    },
  },
  crush = {
    animations = {
      dead = {
        {
          0.1,
          actions = {
            scale_y = {1, 0.1},
          },
        },
        {
          0.3,
          actions = {
            alpha = {255, 0},
          },
        },
      },
    },
  },
  none = {
    animations = {
      dead = {
        {
          0.2,
          actions = {
            alpha = {255, 0},
          },
        },
      },
    },
  },
  apart = {
    left_dx = -100,
    left_dy = 300,
    right_dx = 100,
    right_dy = 300,
    k = 10,
    animations = {
      dead = {
        {
          0.5,
          actions = {
            alpha = {255, 0},
          },
        },
      },
    },
  },
}; --dead

