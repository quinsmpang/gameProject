local _const = require('data.const')
module('data.enemy')

--[=[
每个敌人的描述：
{
  collision={l,r,t,b}, --相对于定位点的碰撞框
  hp=number, --hp值
  --与英雄身体碰撞后的结果,XX见data.const, =KNOCK_BACK表示后退，=KNOCK_DEAD表示英雄死亡
  knock_type=_const.XX,
  knock_back_coeff=1, --碰撞或受击后退的系数。英雄对其产生的后退值×系数=实际后退值
  attack_interval=2, --攻击间隔秒数。!=0时需要有attacks项（见下）;==0表示无攻击。
  
  --防御指定属性的攻击，若一项都没有可写
  guard={
    --见data.const里的攻击属性 HIT_TYPE_XXX
    [_const.HIT_TYPE_SWORD] = true,
  },
  
  --免疫状态，若一项都没有可不写
  immune={
    --目前只有冻结
    frozen=true,
  },
  
  --[[表示当处于离屏幕底<=100像素时，将跳到离底部=场景高+50像素处，跳跃时间1秒
    没有可不填这项。
    该项存在时，必须有名为 jump_back 的动画。
  ]]
  jump_back = {100, 50, 1},
  
  --[[移动逻辑，第一项是逻辑标识名，之后是相应参数。目前有：
    'fixed_fixed',0,90,1000  x方向以固定速度移动，用参数2（移动0像素/秒）, 
                             y方向也是以固定速度移动，用参数3、4，若离底部<1000像素，则以90像素/秒移动，否则不动（=0）
    'random_fixed',100,90,100, x方向以100像素/秒，随机选一个方向移动，选中后碰到屏幕边则相反；
                               y方向用第3、4参数，含义同fixed_fixed。
    'follow_fixed',100,90,1000, x方向向着目标所在的x坐标移动，速度为100像素/秒。
                                y方向参数和逻辑同fixed_fixed。
    'fixed_keep',0,100,600,700, x方向以固定速度移动，用参数2，含义同fixed_fixed.
                                y方向用参数3-5，与底部保持一定距离。若与底部<600，则以速度100像素/秒移动，直到与底部距离>=700停止。
                                这里600/700之间留有一定缓冲，防止移动/停止太快交替看起来不自然。
    'random_keep',100,100,600,700 x方向用参数2，含义同random_fixed.
                                  y方向用参数3-5，含义同fixed_keep.
    'follow_keep',100,100,600,700 x方向用参数2，含义同follow_fixed.
                                  y方向用参数3-5，含义同fixed_keep.
    'thief_move',0,-150,200 小偷特有的移动，移到<=200时笑一次
  ]]
  move = {'follow_fixed', 100, 70, 1000},
  
  --[[攻击方式，有多项时，则在攻击时随机选一种
    目前可用的攻击方式有：
    --发射物。需要有名为 pre_bullet的动画
      发射前先播pre_bullet动画，结束后才发射子弹并回到移动逻辑。
    {'bullet', 
      {  --参数含多项，每项表示一个发射物
        {
          id=30001, --发射物的id，对应data.bullet.bullets内的描述
          speed=1000, --速度，单位像素/秒
          distance=1000, --像素距离，达到后消失
          vector={x,y}, --方向向量，例如垂直向下为{0,-1}, 45度向左下为{-1,-1}
                          若这项不填，则目标点为队伍所在位置
          vecoff={x,y}, --无vector时，定位目标点为相对于队伍位置的偏移，
                          x的方向偏移如下：若敌人在队伍左边，则目标为队伍位置-x，否则为+x
                          y方向偏移则直接+y
          offset={x,y}, --开始点相对于发射者位置的偏移。
                          如{0,50},发射者定位点在两脚中心，则发射物从两脚中心向上50像素处出现并发射
        },
        { --本次攻击有更多发射物可继续填
        },
      }
    },
    --冲撞。需要有名为 pre_dash, dash 两个动画
      先播放pre_dash动画，结束后才冲撞并播放dash动画。
      该攻击不会自己停止，只有boss后跳才会主动取消，按需要改。
    {'dash',
      {--限死了只能垂直向下撞，需要再改
        speed=300, --冲撞的速度，单位 像素/秒
        collision={l,r,t,b}, --冲撞时的碰撞矩形。
      },
    },
    --敲击。需要有名为 pre_knock, knock 两个动画。
      先播放pre_knock动画，结束后再播放knock动画，knock动画结束后攻击结束。
    {'knock',
      {
        collision={l,r,t,b}, --敲击时的碰撞矩形
      },
    },
    --火柱。需要有名为 pre_flaming, flaming 两个动画。
      先播放pre_flaming动画，结束后再播放flaming动画并喷出火柱，到指定时间后结束。
    {'flaming',
      {
        id = 30017, --火柱的id
        seconds = 5, --喷火持续时间
        offset={0,0}, --出火点相对于敌人定位点的偏移
      },
    },
  ]]
  attacks = {
    { --攻击第一项
      ‘bullet’, --攻击名
      {}  --该项攻击的参数
    },
    { --攻击第二项
      ‘dash’,
      {}
    },
    ...
  },
  
  --角色的描述和动画
  object={
    animations={
      walk={ --行走，所有都需要
      },
      dead={ --死亡，所有都需要
      },
      pre_bullet={ --发射物动作，有bullet攻击方式时需存在
      },
      jump_back={ --后跳动画，有jump_back设置时需存在
      },
      pre_dash={ --准备冲撞动作，有dash攻击时需存在
      },
      dash={ --冲撞动画，有dash攻击时需存在
      },
      pre_knock={ --准备敲击动作，有knock攻击时需存在
      },
      knock={ --敲击动作，有knock攻击时需存在
      },
      laugh={ --笑，小偷特有的动作
      },
    }
  },
  
  --分数
  score=20,
  
  --[[道具掉落，
    每项是一种掉落方式，
    p=xx，0<xx<1 是掉落概率，所有项的p加起来应为1.
    之后是列表，{type=xxx, 1, 2, ...}
    type=golds, 有3项，是各类金币的掉落个数，分别是 铜币、金砖、钻石
    type=draw, 有1项，是抽奖币个数
  ]]
  items={
    {p=0.3, {type='golds', 1,0,1}},
    {p=0.2, {type='draw', 1}},
    ...
  },
}
]=]

enemys={
  [20000] = {
    id = 20000,
    name = '乌龟',
    collision = {-31,32,90,10},---2},
    hp = 42,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 2,
    move = {'fixed_fixed', 0, -35, 1000},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30001,
            speed = 300,
            distance = 150,
            vector = {0,-1},
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20000/01.png',39,95},
          },
          {
            0.2,
            {'enemy/20000/02.png',40,95},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20000/05.png',59,108},
          },
        },
        pre_bullet={
          {
            0.3,
            {'enemy/20000/03.png',52,109},
          },
          {
            0.2,
            {'enemy/20000/04.png',36,95},
          },
        },
      },
    },
    score = 20,
    items = {
      {p=0.3, {type='golds',3,0,0}},
      {p=0.2, {type='golds',0,1,0}},
      {p=0.2, {type='golds',1,1,0}},
      {p=0.1, {type='golds',2,1,0}},
      {p=0.1, {type='golds',3,1,0}},
      {p=0.1, {type='golds',4,1,0}},
    },
  }, --20000
  
  [20001] = {
    id = 20001,
    name = '剑兵',
    collision = {-31,32,99,10},-- -2},
    hp = 42,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 2,
    move = {'fixed_fixed', 0, -35, 1000},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30001,
            speed = 300,
            distance = 150,
            vector = {0,-1},
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20001/01.png',37,103},
          },
          {
            0.2,
            {'enemy/20001/02.png',39,102},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20001/05.png',61,90},
          },
        },
        pre_bullet={
          {
            0.3,
            {'enemy/20001/03.png',55,106},
          },
          {
            0.2,
            {'enemy/20001/04.png',41,101},
          },
        },
      },
    },
    score = 20,
    items = {
      {p=0.3, {type='golds',3,0,0}},
      {p=0.2, {type='golds',0,1,0}},
      {p=0.2, {type='golds',1,1,0}},
      {p=0.1, {type='golds',2,1,0}},
      {p=0.1, {type='golds',3,1,0}},
      {p=0.1, {type='golds',4,1,0}},
    },
  }, --20001
  
  [20002] = {
    id = 20002,
    name = '剑盾兵',
    collision = {-37,32,111,14},--2},
    hp = 95,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 1.2,
    guard = {
      [_const.HIT_TYPE_ARROW] = true,
    },
    move = {'fixed_fixed', 0, -100, 1000},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30001,
            speed = 1000,
            distance = 150,
            vector = {0,-1},
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20002/01.png',59,118},
          },
          {
            0.2,
            {'enemy/20002/02.png',48,115},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20002/04.png',64,110},
          },
        },
        pre_bullet={
          {
            0.1,
           {'enemy/20002/03.png',48,118},
          }
        },
      },
    },
    score = 20,
    items = {
      {p=0.2, {type='golds',0,0,1}},
      {p=0.2, {type='golds',2,0,1}},
      {p=0.2, {type='golds',2,1,1}},
      {p=0.2, {type='golds',1,1,1}},
      {p=0.1, {type='golds',4,0,2}},
      {p=0.1, {type='golds',1,1,1}},
    },
  }, --20002
  
  [20003] = {
    id = 20003,
    name = '斧头兵',
    collision = {-68*0.6,61*0.6,150*0.6,10},--0},
    hp = 120,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 2,
    move = {'follow_fixed', 100, -50, 1000},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30001,
            speed = 1000,
            distance = 200,
            vector = {0,-1},
            offset = {0,0},
          },
        },
      },
    },
    object = {
      init={scale={0.8,0.8}},
      animations = {
        walk={
          loop=true,
          {
            0.3,
            {'enemy/20003/07.png',71,164},
          },
          {
            0.3,
            {'enemy/20003/08.png',71,165},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20003/04.png',74,160},
          },
        },
        pre_bullet={
          {
            0.2,
            {'enemy/20003/01.png',94,175},
          },
          {
            0.2,
            {'enemy/20003/03.png',62,177},
          },
          {
            0.2,
            {'enemy/20003/02.png',72,170},
          }
        },
      },
    },
    score = 20,
    items = {
      {p=0.3, {type='golds',3,0,0}},
      {p=0.2, {type='golds',0,1,0}},
      {p=0.2, {type='golds',1,1,0}},
      {p=0.1, {type='golds',2,1,0}},
      {p=0.1, {type='golds',3,1,0}},
      {p=0.1, {type='golds',4,1,0}},
    },
  }, --20003

  [20004] = {
    id = 20004,
    name = '弓箭兵',
    collision = {-22,22,76,0},
    hp = 122,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 2,
    move = {'random_fixed', 100, 90, 1000},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30002,
            speed = 400,
            distance = 2000,
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20004/01.png',56,103},
          },
          {
            0.2,
            {'enemy/20004/02.png',54,104},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20004/06.png',53,93},
          },
        },
        pre_bullet={
          {
            0.2,
            {'enemy/20004/03.png',56,103},
          },
          {
            0.2,
            {'enemy/20004/04.png',58,100},
          },
          {
            0.2,
            {'enemy/20004/05.png',54,102},
          }
        },
      },
    },
    score = 20,
    items = {
      {p=0.3, {type='golds',3,0,0}},
      {p=0.2, {type='golds',0,1,0}},
      {p=0.2, {type='golds',1,1,0}},
      {p=0.1, {type='golds',2,1,0}},
      {p=0.1, {type='golds',3,1,0}},
      {p=0.1, {type='golds',4,1,0}},
    },
  }, --20004
  
  [20005] = {
    id = 20005,
    name = '软泥怪',
    collision = {-46,45,94,-1},
    hp = 300,
    knock_type = _const.KNOCK_DEAD,
    knock_back_coeff = 1,
    attack_interval = 0,
    move = {'follow_fixed', 100, -30, 1000},
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20005/01.png',51,98},
          },
          {
            0.2,
            {'enemy/20005/02.png',53,102},
          },
          {
            0.2,
            {'enemy/20005/03.png',55,102},
          },
          {
            0.2,
            {'enemy/20005/04.png',51,104},
          },         
        },
        dead={
          sound='sound/zombie.mp3',
          {
            0.2,
            {'enemy/20005/05.png',55,92},
          },
        },
      },
    },
    score = 100,
    items = {
      {p=0.2, {type='golds',4,1,2}},
      {p=0.2, {type='golds',4,0,1}},
      {p=0.2, {type='golds',1,1,1}},
      {p=0.2, {type='golds',2,1,1}},
      {p=0.2, {type='golds',4,1,1}},
    },
  }, --20005
  
  [20006] = {
    id = 20006,
    name = '火法师',
    collision = {-38,32,119,2},
    hp = 135,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 2,
    move = {'follow_fixed', 100, 50, 1000},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30003,
            speed = 300,
            distance = 2000,
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20006/01.png',46,127},
          },
          {
            0.2,
            {'enemy/20006/02.png',46,122},
          },
          {
            0.2,
            {'enemy/20006/03.png',49,123},
          },
          {
            0.2,
            {'enemy/20006/04.png',48,122},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20006/08.png',52,117},
          },
        },
        pre_bullet={
          {
            0.2,
            {'enemy/20006/03.png',48,119},
          },
          {
            0.2,
            {'enemy/20006/04.png',48,118},
          },
          {
            0.2,
            {'enemy/20006/05.png',48,120},
          }
        },
      },
    },
    score = 20,
    items = {
      {p=0.3, {type='golds',3,0,0}},
      {p=0.2, {type='golds',0,1,0}},
      {p=0.2, {type='golds',1,1,0}},
      {p=0.1, {type='golds',2,1,0}},
      {p=0.1, {type='golds',3,1,0}},
      {p=0.1, {type='golds',4,1,0}},
    },
  }, --20006
  
  [20007] = {
    id = 20007,
    name = '冰法师',
    collision = {-38,32,119,2},
    hp = 180,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 2,
    move = {'fixed_fixed', 0, 0, 0},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30006,
            speed = 300,
            distance = 2000,
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20007/01.png',46,127},
          },
          {
            0.2,
            {'enemy/20007/02.png',46,122},
          },
          {
            0.2,
            {'enemy/20007/03.png',49,123},
          },
          {
            0.2,
            {'enemy/20007/04.png',48,122},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20007/08.png',52,117},
          },
        },
        pre_bullet={
          {
            0.2,
            {'enemy/20007/05.png',48,119},
          },
          {
            0.2,
            {'enemy/20007/06.png',48,118},
          },
          {
            0.2,
            {'enemy/20007/07.png',48,120},
          }
        },
      },
    },
    score = 160,
    items = {
      {p=0.2, {type='golds',1,0,2}},
      {p=0.2, {type='golds',4,0,4}},
      {p=0.2, {type='golds',2,1,2}},
      {p=0.2, {type='golds',4,2,2}},
      {p=0.1, {type='golds',2,1,3}},
      {p=0.1, {type='golds',4,2,3}},
    },
  }, --20007
  
  [20008] = {
    id = 20008,
    name = '射手怪',
    collision = {-22,22,76,0},
    hp = 180,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 2,
    move = {'random_fixed', 100, 90, 1000},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30002,
            speed = 300,
            distance = 2000,
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20008/01.png',56,103},
          },
          {
            0.2,
            {'enemy/20008/02.png',54,104},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20008/06.png',53,90},
          },
        },
        pre_bullet={
          {
            0.2,
            {'enemy/20008/03.png',56,103},
          },
          {
            0.2,
            {'enemy/20008/04.png',58,100},
          },
          {
            0.2,
            {'enemy/20008/05.png',54,102},
          }
        },
      },
    },
    score = 120,
    items = {
      {p=0.2, {type='golds',1,0,1}},
      {p=0.2, {type='golds',2,1,1}},
      {p=0.2, {type='golds',3,1,1}},
      {p=0.2, {type='golds',1,1,1}},
      {p=0.1, {type='golds',3,2,1}},
      {p=0.1, {type='golds',0,2,1}},
    },
  }, --20008
  
  [20009] = {
    id = 20009,
    name = '鹰身女妖',
    collision = {-71,62,180,-3},
    hp = 200,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 2,
    move = {'random_keep',50,50,600,700},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30010,
            speed = 300,
            distance = 2000,
            vector = {0,-1},
            offset = {0,0},
          },
          {
            id = 30010,
            speed = 300,
            distance = 2000,
            vector = {-1,-4},
            offset = {0,0},
          },
          {
            id = 30010,
            speed = 300,
            distance = 2000,
            vector = {1,-4},
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.4,
            {'enemy/20009/01.png',123,191},
          },
          {
            0.4,
            {'enemy/20009/02.png',156,223},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20009/01.png',123,191},
          },
        },
        pre_bullet={
          {
            0.2,
            {'enemy/20009/01.png',123,191},
          },
          {
            0.2,
            {'enemy/20009/02.png',156,223},
          }
        },
      },
    },
    score = 300,
    items = {
      {p=0.2, {type='golds',1,1,1}},
      {p=0.2, {type='golds',1,2,1}},
      {p=0.2, {type='golds',0,1,2}},
      {p=0.2, {type='golds',4,2,2}},
      {p=0.1, {type='golds',2,1,2}},
      {p=0.1, {type='golds',1,1,2}},
    },
  }, --20009
 
  [20010] = {
    id = 20010,
    name = '滚地怪',
    collision = {-109,-10,113,8},
    hp = 210,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 3.5,
    guard = {
      [_const.HIT_TYPE_ARROW] = true,
    },
    move = {'follow_fixed', 100, 100, 1000},
    attacks = {
      {
        'dash',
        {
          speed = 600,
          collision={-109,-10,113,8},
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20010/01.png',118,125},
          },
          {
            0.2,
            {'enemy/20010/02.png',118,126},
          },
           {
            0.2,
            {'enemy/20010/03.png',117,128},
          },
          {
            0.2,
            {'enemy/20010/04.png',124,125},
          },         
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20010/09.png',62,115},
          },
        },
        pre_dash={
          {
            0.2,
            {'enemy/20010/05.png',117,121},
          },
        },
        dash={
          sound='sound/rolling.mp3',
          loop=true,
          {
            0.1,
            {'enemy/20010/05.png',117,121},
          },
          {
            0.1,
            {'enemy/20010/06.png',119,122},
          },
          {
            0.1,
            {'enemy/20010/07.png',118,124},
          },
          {
            0.1,
            {'enemy/20010/08.png',124,120},
          },
          {
            0.1,
            {'enemy/20010/07.png',118,124},
          },
          {
            0.1,
            {'enemy/20010/06.png',119,122},
          },
        },
      },
    },
    score = 200,
    items = {
      {p=0.2, {type='golds',1,0,1}},
      {p=0.2, {type='golds',2,1,1}},
      {p=0.2, {type='golds',3,2,1}},
      {p=0.2, {type='golds',2,1,1}},
      {p=0.1, {type='golds',1,1,1}},
      {p=0.1, {type='golds',2,1,1}},
    },
  }, --20010
  
  [20011] = {
    id = 20011,
    name = '蛮兵',
    collision = {-67*0.8,61*0.8,163*0.8,-1*0.8},
    hp = 400,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 2,
    move = {'random_fixed', 80, 90, 1000},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30001,
            speed = 1000,
            distance = 200,
            vector = {0,-1},
            offset = {0,0},
          },
        },
      },
    },
    object = {
      init={scale={0.8,0.8}},
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20011/01.png',69,180},
          },
          {
            0.2,
            {'enemy/20011/02.png',69,179},
          },
        },
        dead={
          sound='sound/gob.mp3',
          {
            0.2,
            {'enemy/20011/05.png',64,147},
          },
        },
        pre_bullet={
          {
            0.2,
            {'enemy/20011/03.png',68,182},
          },
          {
            0.2,
            {'enemy/20011/04.png',65,165},
          },
        },
      },
    },
    score = 500,
    items = {
      {p=0.2, {type='golds',2,1,1}},
      {p=0.2, {type='golds',1,0,3}},
      {p=0.2, {type='golds',0,1,3}},
      {p=0.2, {type='golds',2,1,3}},
      {p=0.1, {type='golds',3,2,4}},
      {p=0.1, {type='golds',2,1,4}},
    },
  }, --20011
  
  [20012] = {
    id = 20012,
    name = '小偷',
    collision = {-46,45,94,-1},
    hp = 20,
    knock_type = _const.KNOCK_BACK,
    knock_back_coeff = 1,
    attack_interval = 0,
    move = {'thief_move', 0, -800, 300},
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20012/01.png',35,97},
          },
          {
            0.2,
            {'enemy/20012/02.png',37,97},
          },
          {
            0.2,
            {'enemy/20012/03.png',36,93},
          },
          {
            0.2,
            {'enemy/20012/04.png',37,98},
          },         
        },
        dead={
          sound='sound/laught.mp3',
          {
            0.2,
            {'enemy/20012/05.png',38,95},
          },
        },
        laugh={
          sound = 'sound/laught.mp3',
          {
            0.2,
            {'enemy/20012/02.png',37,97},
          },
          {
            0.2,
            {'enemy/20012/04.png',37,98},
          },
          {
            0.2,
            {'enemy/20012/02.png',37,97},
          },
          {
            0.2,
            {'enemy/20012/04.png',37,98},
          },   
        },
      },
    },
    score = 300,
    items={
      {p=0.1, {type='draw', 1}},
      {p=0.2, {type='golds',2,1,6}},
      {p=0.2, {type='golds',1,1,7}},
      {p=0.2, {type='golds',3,1,8}},
      {p=0.1, {type='golds',2,1,9}},
      {p=0.1, {type='golds',3,2,10}},
      {p=0.1, {type='golds',2,1,10}},
    },
  }, --20012
  
  [20013] = {
    id = 20013,
    name = '野猪头目',
    boss = true,
    collision = {-85,81,187,3},
    hp = 3000,
    knock_type = _const.KNOCK_DEAD,
    knock_back_coeff = 0.3,
    attack_interval = 1.5,
    immune = {
      frozen=true,
    },
    move={'random_fixed', 100, 190, 500},
    jump_back={100, 50, 0.5},
    attacks = {
      {
        'knock',
        {
          collision={-85,81,187,3},
        },
      },
      {
        'dash',
        {
          speed = 800,
          collision={-59,59,62,-61},
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.3,
            {'enemy/20013/01.png',107,214},
          },
          {
            0.3,
            {'enemy/20013/02.png',116,213},
          },
        },
        dead={
          sound='sound/pig.mp3',
          {
            0.5,
            {'enemy/20013/11.png',107,205},
          },
        },
        jump_back={
          {
            0,
            {'enemy/20013/10.png',109,208},
          },
        },
        pre_knock={
          {
            0.4,
            {'enemy/20013/03.png',106,222},
          },
        },
        knock={
          {
            0.1,
            {'enemy/20013/04.png',137,212},
          },          
          {
            2,
            {'enemy/20013/05.png',152,211},
          }
        },
        pre_dash={
          {
            0.4,
            {'enemy/20013/03.png',106,222},
          },
        },
        dash={
          sound='sound/golem.mp3',
          loop=true,
          {
            0.1,
            {'enemy/20013/06.png',73,72},
          },
          {
            0.1,
            {'enemy/20013/07.png',69,72},
          },
          {
            0.1,
            {'enemy/20013/08.png',69,77},
          },
          {
            0.1,
            {'enemy/20013/09.png',71,82},
          },
        },
      },
    },
    score = 700,
    items = {
      {p=0.2, {type='golds',2,1,5}},
      {p=0.2, {type='golds',1,0,6}},
      {p=0.2, {type='golds',3,1,7}},
      {p=0.2, {type='golds',2,1,8}},
      {p=0.1, {type='golds',1,2,9}},
      {p=0.1, {type='golds',2,1,9}},
    },
  }, --20013
 
  [20014] = {
    id = 20014,
    name = '泥人头目',
    boss = true,
    collision = {-99,85,220,0},
    hp = 4000,
    knock_type = _const.KNOCK_DEAD,
    knock_back_coeff = 0.3,
    guard = {
      [_const.HIT_TYPE_ARROW] = true,
    },    
    attack_interval = 1,
    immune = {
      frozen=true,
    },
    move={'random_fixed', 100, 190, 500},
    jump_back={100, 50, 0.5},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30012,
            speed = 700,
            distance = 2000,
            vector = {0,-1},
            offset = {0,0},
          },
        },
      },
      {
        'bullet',
        {
          {
            id = 30012,
            speed = 700,
            distance = 2000,
            vector = {0,-1},
            offset = {0,0},
          },
          {
            id = 30012,
            speed = 700,
            distance = 2000,
            vector = {-1,-3},
            offset = {0,0},
          },
          {
            id = 30012,
            speed = 700,
            distance = 2000,
            vector = {1,-3},
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.5,
            {'enemy/20014/01.png',111,232},
          },
          {
            0.5,
            {'enemy/20014/02.png',88,234},
          },
        },
        dead={
          sound='sound/ogre.mp3',
          {
            0.5,
            {'enemy/20014/07.png',108,232},
          },
        },
        jump_back={
          {
            0,
            {'enemy/20014/06.png',111,228},
          },
        },
        pre_bullet={
          {
            0.4,
            {'enemy/20014/03.png',121,230},
          },
        },
      },
    },
    score = 1500,
    items = {
      {p=0.15, {type='golds',2,1,15}},
      {p=0.2, {type='golds',1,1,16}},
      {p=0.25, {type='golds',4,1,17}},
      {p=0.2, {type='golds',2,1,18}},
      {p=0.1, {type='golds',3,2,19}},
      {p=0.1, {type='golds',2,1,19}},
    },
  }, --20014
  
  [20015] = {
    id = 20015,
    name = '树精头目',
    boss = true,
    collision = {-145,151,351,10},
    hp = 6000,
    knock_type = _const.KNOCK_DEAD,
    knock_back_coeff = 0.1,
    attack_interval = 1.5,
    immune = {
      frozen=true,
    },
    move={'random_fixed', 100, 190, 500},
    jump_back={100, 50, 0.5},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30014,
            speed = 500,
            distance = 2000,
            offset = {0,150},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.5,
            {'enemy/20015/01.png',150,368},
          },
          {
            0.5,
            {'enemy/20015/02.png',159,364},
          },
        },
        dead={
          sound='sound/cow.mp3',
          {
            0.5,
            {'enemy/20015/08.png',145,334},
          },
        },
        jump_back={
          {
            0,
            {'enemy/20015/07.png',154,370},
          },
        },
        pre_bullet={
          {
            0.3,
            {'enemy/20015/03.png',186,371},
          },
        },
      },
    },
    score = 1500,
    items = {
      {p=0.15, {type='golds',1,1,16}},
      {p=0.2, {type='golds',2,1,17}},
      {p=0.25, {type='golds',3,1,18}},
      {p=0.2, {type='golds',1,1,19}},
      {p=0.15, {type='golds',2,2,20}},
      {p=0.05, {type='golds',1,1,22}},
    },
  }, --20015
  
  [20016] = {
    id = 20016,
    name = '石像鬼头目',
    boss = true,
    collision = {-97,91,183,-3},
    hp = 3500,
    knock_type = _const.KNOCK_DEAD,
    knock_back_coeff = 0.5,
    attack_interval = 1.5,
    immune = {
      frozen=true,
    },
    move={'random_keep',200,190,600,700},
    jump_back={100, 50, 0.5},
    attacks = {
      {
        'bullet',
        {
          {
            id = 30015,
            speed = 1000,
            distance = 2000,
            offset = {0,0},
          },
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.2,
            {'enemy/20016/01.png',146,203},
          },
          {
            0.2,
            {'enemy/20016/02.png',132,191},
          },
        },
        dead={
          sound='sound/gargoyle.mp3',
          {
            0.2,
            {'enemy/20016/05.png',151,205},
          },
        },
        jump_back={
          {
            0,
            {'enemy/20016/02.png',132,191},
          },
        },
        pre_bullet={
          {
            0.4,
            {'enemy/20016/03.png',160,202},
          },
        },
      },
    },
    score = 500,
    items = {
      {p=0.15, {type='golds',2,1,16}},
      {p=0.2, {type='golds',3,1,17}},
      {p=0.25, {type='golds',2,1,18}},
      {p=0.2, {type='golds',2,1,19}},
      {p=0.15, {type='golds',3,1,21}},
      {p=0.05, {type='golds',2,1,23}},
    },
  }, --20016
  
  [20017] = {
    id = 20017,
    name = '巨石像头目',
    boss = true,
    collision = {-154,145,306,-1},
    hp = 8000,
    knock_type = _const.KNOCK_DEAD,
    knock_back_coeff = 0,
    attack_interval = 1.5,
    immune = {
      frozen=true,
    },
    move={'random_fixed', 100, 190, 500},
    jump_back={100, 50, 0.5},
    attacks = {
      {
        'bullet',
        {
          {
            id=30015,
            speed=700,
            distance=2000,
            offset={0,0},
          },
        },
      },
      {
        'flaming',
        {
          id=30017,
          sec_out=0.2,
          sec_out_inv=1/0.2,
          sec_keep=0.2+1,
          sec_keep_inv=1,
          sec_in=0.2+1+0.2,
          sec_in_inv=1/0.2,
          sec_rehit = 2,
          offset={0,142},
          _distance=1000,
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.5,
            {'enemy/20017/01.png',161,309},
          },
          {
            0.5,
            {'enemy/20017/02.png',174,312},
          },
        },
        dead={
          sound='sound/dragon.mp3',
          {
            0.2,
            {'enemy/20017/08.png',223,320},
          },
          {
            0.2,
            {'enemy/20017/09.png',257,320},
          },
        },
        jump_back={
          {
            0,
            {'enemy/20017/07.png',170,313},
          },
        },
        pre_bullet={
          {
            0.1,
            {'enemy/20017/03.png',183,298},
          },
          {
            0.1,
            {'enemy/20017/04.png',185,292},
          },
          {
            0.1,
            {'enemy/20017/05.png',179,295},
          },
          {
            0.1,
            {'enemy/20017/06.png',182,291},
          },  
        },
        pre_flaming={
          {
            0.1,
            {'enemy/20017/03.png',183,298},
          },
          {
            0.1,
            {'enemy/20017/04.png',185,292},
          },
          {
            0.1,
            {'enemy/20017/05.png',179,295},
          },
          {
            0.1,
            {'enemy/20017/06.png',182,291},
          },          
        },
        flaming={
          sound='sound/breath.mp3',
          {
            0,
            {'enemy/20017/06.png',182,291},
          }          
        },
      },
    },
    score = 3000,
    items = {
      {p=0.15, {type='golds',1,1,12}},
      {p=0.2, {type='golds',1,1,15}},
      {p=0.25, {type='golds',1,1,18}},
      {p=0.2, {type='golds',1,1,21}},
      {p=0.15, {type='golds',4,2,24}},
      {p=0.05, {type='golds',1,1,27}},
    },
  }, --20017
  
  [20018] = {
    id = 20018,
    name = '野猪头目削弱版',
    boss = true,
    collision = {-85,81,187,3},
    hp = 3000,
    knock_type = _const.KNOCK_DEAD,
    knock_back_coeff = 0.3,
    attack_interval = 1.5,
    immune = {
      frozen=true,
    },
    move={'random_fixed', 100, 190, 500},
    jump_back={100, 50, 0.5},
    attacks = {
      {
        'dash',
        {
          speed = 800,
          collision={-59,59,62,-61},
        },
      },
    },
    object = {
      animations = {
        walk={
          loop=true,
          {
            0.3,
            {'enemy/20013/01.png',107,214},
          },
          {
            0.3,
            {'enemy/20013/02.png',116,213},
          },
        },
        dead={
          sound='sound/pig.mp3',
          {
            0.5,
            {'enemy/20013/11.png',107,205},
          },
        },
        jump_back={
          {
            0,
            {'enemy/20013/10.png',109,208},
          },
        },
        pre_dash={
          {
            0.4,
            {'enemy/20013/03.png',106,222},
          },
        },
        dash={
          sound='sound/golem.mp3',
          loop=true,
          {
            0.1,
            {'enemy/20013/06.png',73,72},
          },
          {
            0.1,
            {'enemy/20013/07.png',69,72},
          },
          {
            0.1,
            {'enemy/20013/08.png',69,77},
          },
          {
            0.1,
            {'enemy/20013/09.png',71,82},
          },
        },
      },
    },
    score = 700,
    items = {
      {p=0.2, {type='golds',2,1,5}},
      {p=0.2, {type='golds',1,0,6}},
      {p=0.2, {type='golds',3,1,7}},
      {p=0.2, {type='golds',2,1,8}},
      {p=0.1, {type='golds',1,2,9}},
      {p=0.1, {type='golds',2,1,9}},
    },
  }, --20018
}
