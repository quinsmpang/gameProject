local _const = require('data.const')
module('data.bullet')

bullets = {
  [30001] = {
    id = 30001,
    name = '刀剑',
    knock_back = 300,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_SWORD,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_SWORD,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_CUT,
    collision={-42,49,56,-45},
    object = {
      {'bullet/30001-1.png',47,59},
      animations={
        fly={
          sound='sound/blade1.mp3',
          loop=true,
          {
            0.04,
            init={scale={1,1}}
          },
          {
            0.04,
            init={scale={-1,1}}
          },
        },
        reflect={
          {
            0.1,
            actions={scale_y={1, -1}}
          },
          {
            0.1,
            actions={scale_y={-1, 1}}
          },
          {
            0.1,
            actions={scale_y={1, -1}}
          },
          {
            0.1,
            actions={scale_y={-1, 1}}
          },
          {
            0,
            init={scale={1, 1}},
          },
        },
      },
    },
  }, --30001
  
  [30002] = {
    id = 30002,
    name = '弓箭',
    knock_back = 400,
    hit_stub = 0.05,
    cancel_type = _const.CANCEL_TYPE_ARROW,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_ARROW,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_SHATTER,
    collision={-22,22,102,0},
    object = {
      animations={
        fly={
          sound='sound/arrow1.mp3',
          loop=true,
          {
            0.1,
            {'bullet/30002-1.png',34,116},
          },
          {
            0.1,
            {'bullet/30002-2.png',31,114},
          },
        },
        reflect={
          {
            0.4,
            actions={
              rotate={0, 540},
            }
          },
          {
            0,
            init={rotate=0},
          },
        },
      },
    },
  }, --30002
  
  [30003] = {
    id = 30003,
    name = '火球',
    knock_back = 150,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_MAGIC,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_MAGIC,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_FIRE,
    collision={-28,28,27,-27},
    object = {
      animations={
        fly={
          sound='sound/fireball.mp3',
          loop=true,
          {
            0.1,
            {'bullet/30003-1.png',32,27},
          },
          {
            0.1,
            {'bullet/30003-2.png',37,27},
          },
          {
            0.1,
            {'bullet/30003-3.png',38,28},
          },
          {
            0.1,
            {'bullet/30003-4.png',37,27},
          },
        },
        reflect={
          {
            0.4,
            actions={
              rotate={0, -180},
            }
          },
          {
            0,
            init={rotate=0},
          },
        },
      },
    },
  }, --30003
  
  [30004] = {
    id = 30004,
    name = '飞斧',
    knock_back = 280,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_SWORD,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_SWORD,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_CUT,
    collision={-28,28,36,-24},
    object = {
      animations={
        fly={
          sound='sound/blade1.mp3',
          loop=true,
          {
            0.3,
            {'bullet/30004-1.png',26,43},
            actions={
              rotate={0, 360},
            }
          },
        },
        reflect={
          {
            0.4,
            actions={
              rotate={0, -720},
            }
          },
        },
      },
    },
  }, --30004

  [30006] = {
    id = 30006,
    name = '冰弹',
    knock_back = 50,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_MAGIC,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_MAGIC,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_NONE,
    collision={-31,22,97,-1},
    --status = {'frozen', p=0.25, value=3},
    object = {
      {'bullet/30006-1.png',32,101},
      animations={
        fly={
          sound='sound/ice.mp3',
          loop=true,
          {
            0.05,
            init={scale={1,1}}
          },
          {
            0.05,
            init={scale={-1,1}}
          },
        },
        reflect={
          {
            0.4,
            actions={
              rotate={0, -180},
            }
          },
          {
            0,
            init={rotate=0},
          },
        },
      },
    },
  }, --30006
    
  [30007] = {
    id = 30007,
    name = '陨石',
    knock_back = 500,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_ALL,
    hit_type = _const.HIT_TYPE_MAGIC,
    kill_type = _const.KILL_TYPE_CRUSH,
    --原始资源对应的爆炸距离倒数，用于计算缩放
    spframe_distance_inv = 1.0/165,
    keep_pic = true,
    object = {
      animations={
        drop={
          sound='sound/meteor1.mp3',
          {
            0,
            {'bullet/30007-1.png',51,155},
          },
        },
        explode={
          sound='sound/meteor2.mp3',
          {
            0.05,
            {'bullet/30007-01.png',62,69},
          },
          {
            0.05,
            {'bullet/30007-02.png',112,101},
          },
          {
            0.05,
            {'bullet/30007-03.png',83,101},
          },
          {
            0.05,
            {'bullet/30007-04.png',102,106},
          },
          {
            0.05,
            {'bullet/30007-05.png',122,106},
          },
          {
            0.05,
            {'bullet/30007-06.png',122,101},
          },
          {
            0.05,
            {'bullet/30007-07.png',94,88},
          },
          {
            0.05,
            {'bullet/30007-09.png',96,91},
          },
          {
            0.05,
            {'bullet/30007-11.png',100,100},
          },
          {
            0.05,
            {'bullet/30007-13.png',62,59},
          },
        },
      },
    },
  }, --30007
  
  [30010] = {
    id = 30010,
    name = '羽箭',
    knock_back = 50,
    hit_stub = 0.05,
    cancel_type = _const.CANCEL_TYPE_ARROW,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_ARROW,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_NONE,
    collision={-20,15,55,-1},
    object = {
      animations={
        fly={
          {
            0,
            {'bullet/30010-1.png',21,57},
          },
        },
        reflect={
          {
            0.4,
            actions={
              rotate={0, 540},
            }
          },
          {
            0,
            init={rotate=0},
          },
        },
      },
    },
  }, --30010
  
  [30012] = {
    id = 30012,
    name = '投石',
    knock_back = 50,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_MAGIC,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_MAGIC,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_CRUSH,
    collision={-55,44,42,-36},
    object = {
      animations={
        fly={
          sound='sound/rock.mp3',
          loop=true,
          {
            0.1,
            {'bullet/30012-1.png',56,62},
          },
          {
            0.1,
            {'bullet/30012-2.png',57,56},
          },
        },
      },
    },
  }, --30012
  
  [30014] = {
    id = 30014,
    name = '飞斧',
    knock_back = 50,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_SWORD,
    cancel_count = 5,
    hit_type = _const.HIT_TYPE_SWORD,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_CUT,
    collision={-83,78,87,-10},
    z=_const.SCENE_Z_HIGH,
    object = {
      animations={
        fly={
          sound='sound/axe.mp3',
          loop=true,
          {
            0.2,
            {'bullet/30014-1.png',89,95},
            actions={
              rotate={0, 360},
            },
          },
        },
      },
    },
  }, --30014
  
  [30015] = {
    id = 30015,
    name = '大火球',
    knock_back = 50,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_MAGIC,
    cancel_count = 2,
    hit_type = _const.HIT_TYPE_MAGIC,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_FIRE,
    collision={-68,54,115,-13},
    z=_const.SCENE_Z_HIGH,
    object = {
      {'bullet/30015-1.png',69,124},
      animations={
        fly={
          sound='sound/fireball.mp3',
          loop=true,
          {
            0.05,
            init={scale={1,1}},
          },
          {
            0.05,
            init={scale={-1,1}},
          },
        },
      },
    },
  }, --30015
  
  [30017] = {
    id = 30017,
    name = '火柱',
    knock_back = 50,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_ALL,
    hit_type = _const.HIT_TYPE_MAGIC,
    kill_type = _const.KILL_TYPE_FIRE,
    collision={-76,76,0,-5},
    z=_const.SCENE_Z_HIGH,
    
    spframe_y = 1095,
    spframe_y_inv = 1/1095,
    object = {
      {'bullet/30017-1.png',76,1095},
      animations={
        shoot={
          sound='sound/fireball.mp3',
          loop=true,
          {
            0.1,
            actions={alpha={255,192}},
          },
          {
            0.1,
            actions={alpha={192,255}},
          },
        },
      },
    },
  }, --30017
  
  [40001] = {
    id = 40001,
    name = '大刀剑',
    knock_back = 300,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_SWORD,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_SWORD,
    hit_count = 3,
    kill_type = _const.KILL_TYPE_CUT,
    collision={-149,149,90,-6},
    object = {
      animations={
        fly={
          loop=true,
          sound='sound/blade1.mp3',
          {
            0.05,
            {'bullet/40001-1.png',155,105},
            actions={
              alpha={255,128},
            },
          },
          {
            0.05,
            actions={
              alpha={128,255},
            },
          },
          {
            0.05,
            {'bullet/40001-2.png',158,96},
            actions={
              alpha={255,128},
            },
          },
          {
            0.05,
            actions={
              alpha={128,255},
            },
          },
          {
            0.05,
            {'bullet/40001-3.png',170,104},
            actions={
              alpha={255,128},
            },
          },
          {
            0.05,
            actions={
              alpha={128,255},
            },
          },
        }, --fly
        reflect={
          {
            0.1,
            actions={scale_y={1, -1}}
          },
          {
            0.1,
            actions={scale_y={-1, 1}}
          },
          {
            0.1,
            actions={scale_y={1, -1}}
          },
          {
            0.1,
            actions={scale_y={-1, 1}}
          },
          {
            0,
            init={scale={1, 1}},
          },
        },
      }, --animations
    }, --object
  }, --40001
  
  [40002] = {
    id = 40002,
    name = '毒液',
    knock_back = 300,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_NONE,
    hit_type = _const.HIT_TYPE_MAGIC,
    kill_type = _const.KILL_TYPE_NONE,
    --原始资源对应的爆炸距离倒数，用于计算缩放
    spframe_distance_inv = 1.0/125,
    keep_pic = false,
    object = {
      animations={
        drop={
          sound='sound/meteor1.mp3',
          init={scale={2,2}},
          {
            0.05,
            {'bullet/40002-2.png',18,105},
          },
          {
            0.05,
            {'bullet/40002-4.png',32,142},
          },
          {
            0.05,
            {'bullet/40002-5.png',33,117},
          },
          {
            0.05,
            {'bullet/40002-6.png',42,80},
          },
        },
        explode={
          sound='sound/meteor2.mp3',
          init={scale={1,1}},
          {
            0.08,
            {'bullet/40002-04.png',84,44},
          },
          {
            0.08,
            {'bullet/40002-05.png',86,60},
          },
          {
            0.08,
            {'bullet/40002-07.png',84,72},
          },
          {
            0.08,
            {'bullet/40002-08.png',86,65},
          },
          {
            0.18,
            actions={alpha={255,0}}
          },
        },
      },
    },
  }, --40002
  
  [40003] = {
    id = 40003,
    name = '追踪火球',
    knock_back = 150,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_MAGIC,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_MAGIC,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_FIRE,
    bullet_follow = 40004, --击中后的后续攻击
    collision={-28,28,27,-27},
    object = {
      animations={
        fly={
          sound='sound/fireball.mp3',
          loop=true,
          {
            0.1,
            {'bullet/30003-1.png',32,27},
          },
          {
            0.1,
            {'bullet/30003-2.png',37,27},
          },
          {
            0.1,
            {'bullet/30003-3.png',38,28},
          },
          {
            0.1,
            {'bullet/30003-4.png',37,27},
          },
        },
        reflect={
          {
            0.4,
            actions={
              rotate={0, 720},
            }
          },
        },
      },
    },
  }, --40003

  [40004] = {
    id = 40004,
    name = '火球爆炸',
    knock_back = 100,
    hit_stub = 0,
    cancel_type = _const.CANCEL_TYPE_NONE,
    hit_type = _const.HIT_TYPE_NONE,
    kill_type = _const.KILL_TYPE_NONE,
    collision={-150,150,150,-150},
    z=0,
    object = {
      {'effect/magic_hit.png',54,48},
      animations={
        sputter={
          sound='sound/magic2.mp3',
          {
            0.1,
            actions={
              scale={2, 3.2},
              alpha = {255, 128},
            },
          },
          {
            0.1,
            actions={
              alpha={128,64},
            },
          },
        },
      },
    },
  }, --40004

  [40005] = {
    id = 40005,
    name = '小激光',
    knock_back = 150,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_MAGIC,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_MAGIC,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_NONE,
    collision={-8,8,0,0},
    --长度倒数，用于计算y缩放
    spframe_y = 230,
    spframe_y_inv = 1/230,
    object = {
      {'bullet/40005-1.png',8,230},
      animations={
        fly={
          sound='sound/breath.mp3',
          loop=true,
          {
            0.1,
            actions={
              alpha={255,128},
              scale_x={1,2},
            },
          },
          {
            0.1,
            actions={
              alpha={128,255},
              scale_x={2,1},
            },
          },
        },
      },
    },
  }, --40005
  
  [40006] = {
    id = 40006,
    name = '激光炮',
    knock_back = 150,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_NONE,
    hit_type = _const.HIT_TYPE_MAGIC,
    kill_type = _const.KILL_TYPE_NONE,
    collision={-21,21,0,0},
    
    spframe_y = 300,
    spframe_y_inv = 1/300,
    object = {
      {'bullet/40006-1.png',21,310},
      animations={
        shoot={
          sound='sound/breath.mp3',
          loop=true,
          {
            0.1,
            actions={
              alpha={255,128},
              scale_x={1,1.5},
            },
          },
          {
            0.1,
            actions={
              alpha={128,255},
              scale_x={1.5,1},
            },
          },
        },
      },
    },
  }, --40006
  
  [40007] = {
    id = 40007,
    name = '魔法球',
    knock_back = 300,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_ALL,
    cancel_count = 5,
    hit_type = _const.HIT_TYPE_MAGIC,
    kill_type = _const.KILL_TYPE_SHATTER,
    collision={-65,65,65,-65},
    
    object = {
      animations={
        shoot={
          sound='sound/magic3.mp3',
          loop=true,
          {
            0.1,
            {'bullet/40007-1.png', 80, 100}
          },
          {
            0.1,
            {'bullet/40007-2.png', 88, 100}
          },
          {
            0.1,
            {'bullet/40007-3.png', 83, 115}
          },
          {
            0.1,
            {'bullet/40007-4.png', 83, 70}
          },
        },
      },
    },
  }, --40007
  
  [40008] = {
    id = 40008,
    name = '蚁人弹',
    knock_back = 150,
    hit_stub = 0.1,
    cancel_type = _const.CANCEL_TYPE_MAGIC,
    cancel_count = 1,
    hit_type = _const.HIT_TYPE_MAGIC,
    hit_count = 1,
    kill_type = _const.KILL_TYPE_SHATTER,
    collision={-25,25,25,-25},
    object = {
      {'bullet/40008-1.png', 28, 34},
      animations={
        fly={
          sound='sound/ice.mp3',
          loop=true,
          {
            0.1,
            actions = {scale={1, 1.3}},
          },
          {
            0.1,
            actions = {scale={1.3, 1}},
          },
        },
        reflect={
          {
            0.4,
            actions={
              rotate={0, 720},
            }
          },
        },
      },
    },
  }, --40008
}
