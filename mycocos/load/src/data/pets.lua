module('data.pets')


--[[
宠物数据
  id = 宠物id
  name = 宠物名字
  debris_unlock = 宠物合成所需碎片数量
  debris_levelup = 升级所需碎片
  max_level = 等级上限
  --具体作用请看宠物ui、battle.pet的实现
  buff_1st = 1级数值
  buff_level = 1级后每级加成数值
  }
]]
pets = {
    [30001] = {
      id = 30001,
      name = "萌战野猪",
      debris_unlock = 10,
      debris_levelup = 20,
      max_level = 30,
      buff_1st = 1,
      buff_level = 0.2,
      object = {
        animations = {
          walk = {
            loop = true,
            {
              0.2,
              {'pet/pig/01.png',32,65},
            },
            {
              0.2,
              {'pet/pig/02.png',32,65},
            },
            {
              0.2,
              {'pet/pig/03.png',32,65},
            },
            {
              0.2,
              {'pet/pig/04.png',32,65},
            },
          },
        },
      },
    },
    [30002] = {
      id = 30002,
      name = "沙漠之鸡",
      debris_unlock = 20,
      debris_levelup = 30,
      max_level = 30,
      buff_1st = 1,
      buff_level = 0.2,
      object = {
        animations = {
          walk = {
            loop = true,
            {
              0.2,
              {'pet/chicken/01.png',32,93},
            },
            {
              0.2,
              {'pet/chicken/02.png',32,93},
            },
            {
              0.2,
              {'pet/chicken/03.png',32,93},
            },
            {
              0.2,
              {'pet/chicken/04.png',32,93},
            },
          },
        },
      },
    },
    [30003] = {
      id = 30003,
      name = "谜之树精",
      debris_unlock = 30,
      debris_levelup = 40,
      max_level = 30,
      buff_1st = 1,
      buff_level = 0.2,
      object = {
        animations = {
          walk = {
            loop = true,
            {
              0.15,
              {'pet/fairy/01.png',52,92},
            },
            {
              0.15,
              {'pet/fairy/02.png',52,92},
            },
            {
              0.15,
              {'pet/fairy/03.png',52,92},
            },
            {
              0.15,
              {'pet/fairy/04.png',52,92},
            },
            {
              0.15,
              {'pet/fairy/05.png',52,92},
            },
          },
        },
      },
    },
    [30004] = {
      id = 30004,
      name = "小恶魔",
      debris_unlock = 30,
      debris_levelup = 50,
      max_level = 30,
      buff_1st = 5,
      buff_level = 1,
      object = {
        animations = {
          walk = {
            loop = true,
            {
              0.2,
              {'pet/imp/01.png',52,92},
            },
            {
              0.2,
              {'pet/imp/02.png',52,92},
            },
            {
              0.2,
              {'pet/imp/03.png',52,92},
            },
            {
              0.2,
              {'pet/imp/04.png',52,92},
            },
          },
        },
      },
    },
    [30005] = {
      id = 30005,
      name = "钢铁超人",
      debris_unlock = 30,
      debris_levelup = 50,
      max_level = 30,
      buff_1st = 5,
      buff_level = 1,
      object = {
        animations = {
          walk = {
            loop = true,
            {
              0.2,
              {'pet/iron/01.png',46,98},
            },
            {
              0.2,
              {'pet/iron/02.png',46,98},
            },
            {
              0.2,
              {'pet/iron/03.png',46,98},
            },
            {
              0.2,
              {'pet/iron/04.png',46,98},
            },
          },
        },
      },
    },
}
