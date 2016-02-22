local _const = require('data.const')
local _config = require('config')
module('data.hero')

heros={
  [10001]={
    id = 10001,
    advance_id=18001,
    name = '剑士',
    min_level = 1,
    unlock = true,
    front_priority = 4,
    leave_priority = 1,
    collision = {-26, 26, 112, 0},
    knock_back = 300,
    attack = {
      'bullet',
      {
        {
          id = 30001,
          vector = {0,1},
          speed = 2000,
          offset = {0,90},
        },
      },
    },
    object = {
      animations = {
        stand = {
          loop = true,
          {
            0.5,
            {'hero/assassin/07.png',38,107},
          },
          {
            0.5,
            {'hero/assassin/08.png',38,107},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/assassin/01.png',35,113},
          },
          {
            0.2,
            {'hero/assassin/02.png',66,113},
          },
          {
            0.2,
            {'hero/assassin/03.png',72,108},
          },
          {
            0.2,
            {'hero/assassin/04.png',53,114},
          },
        },
        dead = {
          sound = 'sound/man1.mp3',
          {
            0.5,
            {'hero/assassin/05.png',112,86},
          },
          {
            0.5,
            {'hero/assassin/06.png',136,102},
          },
        },
      },
    },
  }, --10001

  [10002]={
    id = 10002,
    advance_id=10003,
    unlock_cascade_id=10003,
    name = '守护者',
    min_level = 0,
    unlock = false,
    front_priority = 10,
    leave_priority = 5,
    collision = {-20,20,88,0},
    knock_back = 300,
    attack = {
      'strips',
      {
        {
          id = 40005,
          vector = {0,1},
          speed = 2000,
          offset = {0,90},
        },
        {
          delay = 0.2,
          id = 40005,
          vector = {0,1},
          speed = 2000,
          offset = {-50,90},
        },
        {
          delay = 0.2,
          id = 40005,
          vector = {0,1},
          speed = 2000,
          offset = {50,90},
        }
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/femalemag/08.png',45,107},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/femalemag/01.png',33,92},
          },
          {
            0.2,
            {'hero/femalemag/02.png',31,87},
          },
          {
            0.2,
            {'hero/femalemag/03.png',33,106},
          },
          {
            0.2,
            {'hero/femalemag/04.png',33,112},
          },
        },
        dead = {
          sound = 'sound/woman1.mp3',
          {
            0.3,
            {'hero/femalemag/05.png',44,94},
          },
          {
            0.3,
            {'hero/femalemag/06.png',60,70},
          },
          {
            0.3,
            {'hero/femalemag/07.png',62,71},
          },
        },
      },
    },
  }, --10002
  
  [10003]={
    id = 10003,
    primitive_id=10002,
    unlock_cascade_id=10002,
    name = '进阶守护者',
    min_level = 0,
    unlock = false,
    front_priority = 12,
    leave_priority = 11,
    collision = {-22, 22, 95, -1},
    knock_back = 300,
    attack = {
      'flame',
      {
        {
          id=40006,
          sec_out=0.15,
          sec_out_inv=1/0.15,
          sec_keep=0.15+1.7,
          sec_keep_inv=1/1.7,
          sec_in=0.15+1.7+0.15,
          sec_in_inv=1/0.15,
          sec_rehit = 0.5,
          offset={0,120},
        },
        {
          id=40006,
          sec_out=0.15,
          sec_out_inv=1/0.15,
          sec_keep=0.15+1.7,
          sec_keep_inv=1/1.7,
          sec_in=0.15+1.7+0.15,
          sec_in_inv=1/0.15,
          sec_rehit = 0.5,
          offset={-50,120},
        },
        {
          id=40006,
          sec_out=0.15,
          sec_out_inv=1/0.15,
          sec_keep=0.15+1.7,
          sec_keep_inv=1/1.7,
          sec_in=0.15+1.7+0.15,
          sec_in_inv=1/0.15,
          sec_rehit = 0.5,
          offset={50,120},
        },
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/advmag/08.png',44,102},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/advmag/03.png',30,92},
          },
          {
            0.2,
            {'hero/advmag/02.png',43,110},
          },
          {
            0.2,
            {'hero/advmag/04.png',49,90},
          },
          {
            0.2,
            {'hero/advmag/05.png',45,111},
          },
        },
        dead = {
          sound = 'sound/woman1.mp3',
          {
            0.5,
            {'hero/advmag/06.png',88,100},
          },
          {
            0.5,
            {'hero/advmag/07.png',88,100},
          },
        },
      },
    },
  }, --10003
  
  [10004]={
    id = 10004,
    advance_id=10005,
    unlock_cascade_id=10005,
    name = '蚁人',
    min_level = 0,
    unlock = false,
    front_priority = 2,
    leave_priority = 6,
    collision = {-20,20,88,0},
    knock_back = 300,
    attack = {
      'ball',
      {
        id = 40007,
        offset = {0,235},
        sec = 3,
        sec_rehit = 0.5,
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/ant/08.png',40,109},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/ant/01.png',25,87},
          },
          {
            0.2,
            {'hero/ant/02.png',46,87},
          },
          {
            0.2,
            {'hero/ant/03.png',47,88},
          },
          {
            0.2,
            {'hero/ant/04.png',24,87},
          },
        },
        dead = {
          sound = 'sound/man1.mp3',
          {
            0.2,
            {'hero/ant/05.png',110,84},
          },
          {
            0.2,
            {'hero/ant/06.png',123,92},
          },
          {
            0.2,
            {'hero/ant/07.png',129,106},
          },
        },
      },
    },
  }, --10004
  
  [10005]={
    id = 10005,
    primitive_id=10004,
    unlock_cascade_id=10004,
    name = '进阶蚁人',
    min_level = 0,
    unlock = false,
    front_priority = 13,
    leave_priority = 13,
    collision = {-22, 22, 88, -1},
    knock_back = 300,
    attack = {
      'tracers',
      {
        {
          id = 40008,
          speed = 1500,
          turn_k = 3/_config.design.fps,
          offset = {-30,120},
          vector = {-1, 3},
        },
        {
          delay = 0.1,
          id = 40008,
          speed = 1500,
          turn_k = 3/_config.design.fps,
          offset = {30,120},
          vector = {2, 5},
        },
        {
          delay = 0.1,
          id = 40008,
          speed = 1200,
          turn_k = 2/_config.design.fps,
          offset = {-40,120},
          vector = {-1, 5},
        },
        {
          delay = 0.1,
          id = 40008,
          speed = 1200,
          turn_k = 2/_config.design.fps,
          offset = {40,120},
          vector = {1, 4},
        },
        {
          delay = 0.1,
          id = 40008,
          speed = 900,
          turn_k = 1/_config.design.fps,
          offset = {40,120},
          vector = {2, 3},
        },
        {
          delay = 0.1,
          id = 40008,
          speed = 900,
          turn_k = 1/_config.design.fps,
          offset = {-40,120},
          vector = {-2, 3},
        }
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/advant/12.png',32,102},
          },
        },
        walk = {
          loop = true,
          {
            0.15,
            {'hero/advant/01.png',31,86},
          },
          {
            0.15,
            {'hero/advant/02.png',30,86},
          },
          {
            0.15,
            {'hero/advant/03.png',34,85},
          },
          {
            0.15,
            {'hero/advant/04.png',30,86},
          },
          {
            0.15,
            {'hero/advant/05.png',32,86},
          },
          {
            0.15,
            {'hero/advant/06.png',25,85},
          },
          {
            0.15,
            {'hero/advant/07.png',25,84},
          },
          {
            0.15,
            {'hero/advant/08.png',30,85},
          },
        },
        dead = {
          sound = 'sound/man1.mp3',
          {
            0.2,
            {'hero/advant/09.png',110,84},
          },
          {
            0.2,
            {'hero/advant/10.png',123,92},
          },
          {
            0.2,
            {'hero/advant/11.png',129,106},
          },
        },
      },
    },
  }, --10005
  
  [11001]={
    id = 11001,
    advance_id=14001,
    unlock_cascade_id=14001,
    name = '弓箭手',
    min_level = 0,
    unlock = false,
    front_priority = 6,
    leave_priority = 2,
    collision = {-30, 23, 103, 0},
    knock_back = 300,
    attack = {
      'bullet',
      {
        {
          id = 30002,
          vector = {0,1},
          speed = 1000,
          offset = {0,90},
        },
      },
    },
    object = {
      animations = {
        stand = {
          loop = true,
          {
            0.5,
            {'hero/archer/07.png',53,102},
          },
          {
            0.5,
            {'hero/archer/08.png',53,102},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/archer/01.png',67,103},
          },
          {
            0.2,
            {'hero/archer/02.png',66,101},
          },
          {
            0.2,
            {'hero/archer/04.png',68,101},
          },
          {
            0.2,
            {'hero/archer/03.png',67,103},
          },
        },
        dead = {
          sound = 'sound/woman2.mp3',
          {
            0.5,
            {'hero/archer/05.png',112,86},
          },
          {
            0.5,
            {'hero/archer/06.png',136,102},
          },
        },
      },
    },
  }, --11001
  
  [12001]={
    id = 12001,
    advance_id=17001,
    unlock_cascade_id=17001,
    name = '法师',
    min_level = 0,
    unlock = false,
    front_priority = 7,
    leave_priority = 3,
    collision = {-20,24,90,-1},
    knock_back = 300,
    attack = {
      'bullet',
      {
        {
          id = 30003,
          vector = {0,1},
          speed = 1000,
          offset = {0,120},
        },
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/magician/05.png',68,115},
          },
        },
        walk = {
          loop = true,
          {
            0.3,
            {'hero/magician/01.png',31,93},
          },
          {
            0.3,
            {'hero/magician/02.png',29,93},
          },
          {
            0.3,
            {'hero/magician/03.png',26,91},
          },
          {
            0.3,
            {'hero/magician/04.png',30,92},
          },
        },
        dead = {
          sound = 'sound/man1.mp3',
          {
            0.3,
            {'hero/magician/06.png',43,82},
          },
          {
            0.3,
            {'hero/magician/07.png',42,69},
          },
          {
            0.3,
            {'hero/magician/08.png',52,66},
          },
          {
            0.3,
            {'hero/magician/09.png',29,68},
          },
        },
      },
    },
  }, --12001
  
  [13001]={
    id = 13001,
    advance_id = 15001,
    unlock_cascade_id = 15001,
    name = '斧手',
    min_level = 0,
    unlock = false,
    front_priority = 5,
    leave_priority = 4,
    collision = {-22, 22, 96, -3},
    knock_back = 300,
    attack = {
      'bullet',
      {
        {
          id = 30004,
          vector = {0,1},
          speed = 1000,
          offset = {0,120},
        },
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/axeman/04.png',30,91},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/axeman/01.png',30,91},
          },
          {
            0.2,
            {'hero/axeman/02.png',39,90},
          },
          {
            0.2,
            {'hero/axeman/03.png',31,89},
          },
          {
            0.2,
            {'hero/axeman/02.png',39,90},
          },
        },
        dead = {
          sound = 'sound/man1.mp3',
          {
            0.5,
            {'hero/axeman/05.png',108,126},
          },
          {
            0.5,
            {'hero/axeman/06.png',129,120},
          },
        },
      },
    },
  }, --13001

  [14001]={
    id = 14001,
    primitive_id=11001,
    unlock_cascade_id=11001,
    name = '进阶弓箭手',
    min_level = 0,
    unlock = false,
    front_priority = 8,
    leave_priority = 9,
    collision = {-26,22,100,-2},
    knock_back = 300,
    attack = {
      'bullet',
      {
        {
          id = 30002,
          vector = {0,1},
          speed = 1000,
          offset = {0,90},
        },
        {
          id = 30002,
          vector = {-1,3.5},
          speed = 1000,
          offset = {0,90},
        },
        {
          id = 30002,
          vector = {1,3.5},
          speed = 1000,
          offset = {0,90},
        },
      },
    },
    attack_alternate = {
      'bullet',
      {
        {
          id = 30002,
          vector = {0,1},
          speed = 1000,
          offset = {0,90},
        },
        {
          id = 30002,
          vector = {-1,2.25},
          speed = 1000,
          offset = {0,90},
        },
        {
          id = 30002,
          vector = {1,2.25},
          speed = 1000,
          offset = {0,90},
        },
        {
          id = 30002,
          vector = {-1,4.5},
          speed = 1000,
          offset = {0,90},
        },
        {
          id = 30002,
          vector = {1,4.5},
          speed = 1000,
          offset = {0,90},
        },
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/ranger/05.png',53,101},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/ranger/01.png',84,102},
          },
          {
            0.2,
            {'hero/ranger/02.png',84,102},
          },
          {
            0.2,
            {'hero/ranger/03.png',84,102},
          },
          {
            0.2,
            {'hero/ranger/04.png',83,102},
          },
        },
        dead = {
          sound = 'sound/woman2.mp3',
          {
            0.2,
            {'hero/ranger/06.png',110,84},
          },
          {
            0.2,
            {'hero/ranger/07.png',123,92},
          },
          {
            0.2,
            {'hero/ranger/08.png',129,106},
          },
          {
            0.2,
            {'hero/ranger/09.png',129,107},
          },
          {
            0.2,
            {'hero/ranger/10.png',125,113},
          },
        },
      },
    },
  }, --14001
  
  [15001]={
    id = 15001,
    primitive_id=13001,
    unlock_cascade_id=13001,
    name = '进阶斧手',
    min_level = 0,
    unlock = false,
    front_priority = 3,
    leave_priority = 11,
    collision = {-25, 25, 95, -5},
    knock_back = 300,
    attack = {
      'bullet',
      {
        {
          id = 30004,
          vector = {0,1},
          speed = 1000,
          offset = {0,120},
        },
        {
          id = 30004,
          vector = {-1,4},
          speed = 1000,
          offset = {0,120},
        },
        {
          id = 30004,
          vector = {1,4},
          speed = 1000,
          offset = {0,120},
        },
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/advaxe/04.png',44,109},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/advaxe/02.png',57,121},
          },
          {
            0.2,
            {'hero/advaxe/01.png',32,121},
          },
          {
            0.2,
            {'hero/advaxe/03.png',34,122},
          },
          {
            0.2,
            {'hero/advaxe/01.png',32,121},
          },
        },
        dead = {
          sound = 'sound/man1.mp3',
          {
            0.5,
            {'hero/advaxe/05.png',108,126},
          },
          {
            0.5,
            {'hero/advaxe/06.png',129,120},
          },
        },
      },
    },
  }, --15001

  [16001]={
    id = 16001,
    advance_id=19001,
    unlock_cascade_id=19001,
    name = '博士',
    min_level = 0,
    unlock = false,
    front_priority = 11,
    leave_priority = 7,
    collision = {-22, 22, 95, -1},
    --status = 'acceleration',
    knock_back = 300,
    attack = {
      'dropper',
      {
        id = 40002,
        down = 100,
        time = 0.2,
      },
    },
    --
    object = {
      animations = {
        stand = {
          loop=true,
          {
            0.2,
            {'hero/doctor/05.png',46,130},
          },
          {
            0.2,
            {'hero/doctor/06.png',46,130},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/doctor/01.png',28,100},
          },
          {
            0.2,
            {'hero/doctor/04.png',31,99},
          },
          {
            0.2,
            {'hero/doctor/03.png',30,100},
          },
          {
            0.2,
            {'hero/doctor/02.png',31,106},
          },
        },
        dead = {
          sound = 'sound/man1.mp3',
          {
            0.3,
            {'hero/doctor/07.png',52,98},
          },
          {
            0.3,
            {'hero/doctor/08.png',53,98},
          },
          {
            0.3,
            {'hero/doctor/09.png',53,98},
          },
          {
            0.3,
            {'hero/doctor/10.png',53,98},
          },
        },
      },
    },
  }, --16001
  
  [17001]={
    id = 17001,
    primitive_id=12001,
    unlock_cascade_id=12001,
    name = '进阶法师',
    min_level = 0,
    unlock = false,
    front_priority = 9,
    leave_priority = 10,
    collision = {-26, 27, 87, 1},
    knock_back = 300,
    attack={
      'tracer',
      {
        {
          id = 40003,
          speed = 1000,
          turn_k = 5/_config.design.fps,
          offset = {0,120},
          vector = {0, 1},
        },
      },
    },
    attack_alternate={
      'tracer',
      {
        {
          id = 40003,
          speed = 1000,
          turn_k = 5/_config.design.fps,
          offset = {-30,120},
          vector = {0, 1},
        },
        {
          id = 40003,
          speed = 1000,
          turn_k = 5/_config.design.fps,
          offset = {30,120},
          vector = {0, 1},
        },
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/sorcerer/03.png',68,116},
          },
        },
        walk = {
          loop = true,
          {
            0.4,
            {'hero/sorcerer/01.png',31,92},
          },
          {
            0.4,
            {'hero/sorcerer/02.png',27,93},
          },
        },
        dead = {
          sound = 'sound/woman1.mp3',
          {
            0.3,
            {'hero/sorcerer/04.png',51,80},
          },
          {
            0.3,
            {'hero/sorcerer/05.png',44,68},
          },
          {
            0.3,
            {'hero/sorcerer/06.png',50,68},
          },
          {
            0.3,
            {'hero/sorcerer/07.png',30,68},
          },
        },
      },
    },
  }, --17001
  
  [18001]={
    id = 18001,
    primitive_id=10001,
    name = '进阶剑士',
    min_level = 1,
    unlock = false,
    front_priority = 1,
    leave_priority = 8,
    collision = {-26, 27, 90, -1},
    knock_back = 300,
    attack={
      'bullet',
      {
        {
          id = 40001,
          vector = {0,1},
          speed = 800,
          offset = {0,90},
        },
      },
    },
    object = {
      animations = {
        stand = {
          {
            0,
            {'hero/guard/05.png',64,125},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/guard/01.png',38,101},
          },
          {
            0.2,
            {'hero/guard/02.png',40,121},
          },
          {
            0.2,
            {'hero/guard/03.png',41,114},
          },
          {
            0.2,
            {'hero/guard/04.png',38,102},
          },
        },
        dead = {
          sound = 'sound/man1.mp3',
          {
            0.3,
            {'hero/guard/06.png',38,91},
          },
          {
            0.3,
            {'hero/guard/07.png',42,69},
          },
          {
            0.3,
            {'hero/guard/08.png',52,71},
          },
          {
            0.3,
            {'hero/guard/09.png',37,67},
          },
        },
      },
    },
  }, --18001
  
  [19001]={
    id = 19001,
    primitive_id = 16001,
    unlock_cascade_id=16001,
    name = '绿巨人',
    min_level = 0,
    unlock = false,
    front_priority = 14,
    leave_priority = 14,
    collision = {-27, 27, 95, -4},
    knock_back = 300,
    attack = {
      'dropper',
      {
        id = 30007,
        down = 100,
        time = 0.2,
      },
    },
    object = {
      animations = {
        stand = {
          loop=true,
          {
            0.2,
            {'hero/green_giant/05.png',54,134},
          },
          {
            0.2,
            {'hero/green_giant/06.png',54,134},
          },
        },
        walk = {
          loop = true,
          {
            0.2,
            {'hero/green_giant/01.png',51,110},
          },
          {
            0.2,
            {'hero/green_giant/02.png',51,110},
          },
          {
            0.2,
            {'hero/green_giant/03.png',51,110},
          },
          {
            0.2,
            {'hero/green_giant/04.png',51,110},
          },
        },
        dead = {
          sound = 'sound/ogre.mp3',
          {
            0.3,
            {'hero/green_giant/07.png',51,112},
          },
          {
            0.3,
            {'hero/green_giant/08.png',51,112},
          },
          {
            0.3,
            {'hero/green_giant/09.png',51,112},
          },
          {
            0.3,
            {'hero/green_giant/10.png',51,112},
          },
        },
      },
    },
  }, --19001
  
}

