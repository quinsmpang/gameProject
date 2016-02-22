local setmetatable = setmetatable
local type = type
local assert = assert
local pairs = pairs
local strfind = string.find
local strsub = string.sub
local error = error
local print = print

module('util.class')

--[[
辅助构建类对象。
将返回：
{
  --该类实例用的metatable
  inst_meta = {
    --如果有基类，将如下构建层叠结构
    setmetatable(super_type, inst_meta)
    __super__ = 基类的inst_meta
    __super_ctor__ = 基类ctor
      
    --类实例的方法，使用者赋值
  }
  inst_meta.__index = inst_meta
  
  __call = function(...) 构造类的实例
  
  -- 构造方法（若存在，需使用者赋值）
  ctor = function(cls, ...) end
  
  __super__ = 基类对象
}

使用：
--创建类
CLS = class(BASE_TYPE)       
--类的构造函数
CLS.ctor = function(self, ...)
  self.__super_ctor__(self, ...) --基类构造
  --初始化实例
end
--类的成员方法
function CLS.inst_meta.method(self, ...)
 ...
 --调用基类同名方法
 self.__super__.func(self, ...)
end

--从类创建实例
inst = CLS(a,b) --a,b作为ctor的参数
--调用成员函数
inst:method(a,b,c)
]]
function class(super_type)
  assert(super_type==nil or type(super_type)=='table' and super_type.inst_meta,
    'super_type must be nil OR created by class')
  
  local cls = {}
  setmetatable(cls, cls) --for __call below
  
  local inst_meta = {}
  inst_meta.__index = inst_meta
  if super_type then
    setmetatable(inst_meta, super_type.inst_meta)
    inst_meta.__super__ = super_type.inst_meta
    inst_meta.__super_ctor__ = super_type.ctor
  end
  
  cls.inst_meta = inst_meta
  cls.ctor = function(self, ...) end
  cls.__super__ = super_type
  cls.__call = function(cls, ...)
    local self = {}
    setmetatable(self, cls.inst_meta)
    cls.ctor(self, ...)
    return self
   end
     
  return cls
end

--inst是否cls的实例
function isInstance(cls, inst)
  local m = cls.inst_meta
  local i = getmetatable(inst)
  repeat
    if i==m then return true end
    i = getmetatable(i)
    if not i then return false end
  until false
end


--[=[
辅助构造状态机，支持嵌套状态

使用:
fsm = fsmComplete{...} --{}是状态机的定义，见下
fsm_data = {}  --状态机运行时存数据的地方
fsm:start(fsm_data, ...)  --启动状态机，这使其进入初始状态
fsm:call(fsm_data, 'method', ...) --调用状态机的处理方法method, 并传入参数
fsm:toState(fsm_data, 'st_name', ...)  --跳转到状态st_name，并传参数给_enter
fsm:isIn(fsm_data, 'st_name') --检查是否在st_name状态
fsm:stop(fsm_data) --跳出当前状态

fsm只是声明状态机的结构，运行时维护的数据都放在fsm_data中.
fsm_data中，fsm管理的有：
 _curr: 指向当前所处的状态（即fsm内的某个table）
        该值在状态的 _enter、_exit处理中无效，具体见下toState
 [1]={} [2]={} ... [n]={}，运行时各特定状态存储数据的地方
   n是状态的最大深度，fsmComplete时会算出。
 其它名字可根据需要加上。
这样，同一个fsm可以被多个地方同时使用，因为运行时状态保持在各自的fsm_data中。


状态机的定义：
fsm = { --fsm是一个table，内部状态也是table。fsmComplete为各状态table附加一些值，便于操作。
  _init = 'state_1'; --初始状态的名字, fsmComplete处理后指向实际的table
  
  --[[状态定义，约定状态名不以 _ 开头，值为table
    _enter,_exit是function，进入、退出状态时调用。可忽略。
    其它function则是该状态下的处理方法。
    所有function前三个参数都是 fsm(状态机本身)，fsm_data(运行时数据table)，curr（当前状态）
      之后是外部传入的参数
      _enter的参数在 fsm:toState(fsm_data, 'name', ...) 时传入
      其它函数则在 fsm:call 或 fsm:message时传入
      _enter、其它函数可以有返回值，具体见下 toState, call, message的说明
      _exit则无需返回值。
    fsmComplete为每个状态附加的项：
     _depth: 该状态深度。处理时附加，最外层(fsm直接子状态)=1，其子状态+1=2，以此类推
         约定处理函数用 fsm_data[curr._depth] 来记录该状态特定的数据
     _parent: 父状态table
  ]]
  state_1 = {
    _depth = 1; _parent = fsm; --附加项
    _enter = function(fsm,fsm_data,curr,...) end;
    _exit = function(fsm,fsm_data,curr) end;
    --嵌套子状态
    state_1_1 = {
      _depth = 2; _parent = state_1 --附加项
      _exit = function(fsm,fsm_data,curr,...) end
    };
  };
  state_2 = {
    _depth = 1; _parent = fsm; --附加项
    _enter = function(fsm,fsm_data,curr) end;
    state_2_1 = {
      _depth=2; _parent=state_2
    };
    state_2_2 = {
      _depth=2; _parent=state_2;
    };
  };

  --附加项，状态最大深度。
  _max_depth = 2;
  
  --以下是fsm附加的函数
  --进入初始状态，并为fsm_data附加_curr, [1]..[_max_depth]的table
  start = function(fsm,fsm_data) end;
  --退出当前状态，即所处状态的 _exit 被调用，直到最外层
  stop = function(fsm,fsm_data) end;
  --[[
    切换状态，...是传给对应状态_enter的参数
    切换状态只能往同层或顶层走，不能往嵌套状态走。
      如上例，当前处在state_2_1, 可转到state_2_2, state_1, 但不能直接指到 state_1_1。
    如指定的状态有子状态，需要转到某一子状态，需调用子状态的 _enter(fsm, fsm_data, curr, ...)
      并返回子状态table，这将fsm_data._curr设为子状态。
  ]]
  toState = function(fsm, fsm_data, 'st_name', ...) end;
  --[[
    检查是否在st_name状态
    st_name形如 st 或 st1.st11，从最顶层开始引用内部状态
  ]]
  isIn = function(fsm, fsm_data, 'st_name) end;
  --[[
    调用当前状态的处理方法，名为method, ...是参数。
    如果当前状态无指定名的方法则保持。
    返回：处理方法的返回值。
  ]]
  call = function(fsm, fsm_data, 'method', ...) end;
  --[[
    传递消息给当前状态。参数含义同call，但允许从嵌套状态、父状态、fsm全局依次处理。
    若当前状态无'method'的处理方法，则寻找其父状态。
      若有，其返回值表示是否允许父状态层继续处理，false则马上中止，true则继续往父状态找。
    以上过程可以一直到fsm table自身。即fsm可以附带全局的消息处理方法，
      全局方法同样可返回值，含义同上。用于与fsm外的消息处理写作。
    返回：消息的处理情况。false表示已处理，不应在做后续处理；true则相反。
  ]]
  message = function(fsm, fsm_data, 'method', ...) end;
}
]=]
local function _fsmStart(fsm, fsm_data, ...)
  assert(fsm.curr==nil, 'fsm.start: start while running')
  for i=1, fsm._max_depth do
    fsm_data[i] = {}
  end
  local curr = fsm._init
  if curr._enter then
    curr = curr._enter(fsm, fsm_data, curr, ...) or curr
  end
  fsm_data._curr = curr
end

local function _fsmStop(fsm, fsm_data)
  local curr = fsm_data._curr
  while curr do
    local func = curr._exit
    if func then
      func(fsm, fsm_data, curr)
    end
    curr = curr._parent
  end
  fsm_data._curr = nil
end


local function _fsmToState(fsm, fsm_data, name, ...)
  local curr, func = fsm_data._curr, nil
  repeat
    func = curr._exit
    if func then
      func(fsm, fsm_data, curr) 
    end
    curr = curr._parent
    if curr == nil then
      error('fsm:toState: state name not exist', 1)
    end
  until curr[name]
  curr = curr[name]
  func = curr._enter
  if func then
    curr = func(fsm, fsm_data, curr, ...) or curr
  end
  fsm_data._curr = curr
end

local function _fsmIsIn(fsm, fsm_data, name)
  local st = fsm
  local s = 1
  repeat
    local e = strfind(name, '.', s, true)
    if not e then --name无 . 时避免建立string
      name = (s==1 and name or strsub(name,s))
      break
    end
    st = st[strsub(name, s, e-1)]
    if st==nil then
      return false
    end
    s = e+1
  until false
  st = st[name]
  if st==nil then return false end
  
  local curr = fsm_data._curr
  while curr do
    if curr==st then return true end
    curr = curr._parent
  end
  return false
end

local function _fsmCall(fsm, fsm_data, method, ...)
  local curr = fsm_data._curr
  return curr[method](fsm, fsm_data, curr, ...)
end

local function _fsmMessage(fsm, fsm_data, method, ...)
  local curr = fsm_data._curr
  while curr do
    local func = curr[method]
    if func and
      not func(fsm, fsm_data, curr, ...)
    then
      return false
    end
    curr = curr._parent
  end
  return true
end

function fsmComplete(fsm)
  fsm._init = fsm[fsm._init]
  --fsm._max_depth = 0
  fsm.start = _fsmStart
  fsm.stop = _fsmStop
  fsm.toState = _fsmToState
  fsm.isIn = _fsmIsIn
  fsm.call = _fsmCall
  fsm.message = _fsmMessage
  
  local max_depth = 0
  local f 
  f = function(curr, depth)
    if max_depth<depth then max_depth=depth end
    for n,st in pairs(curr) do
      if type(st)=='table' and strfind(n,'_',1,true)~=1 then
        st._parent = curr
        st._depth = depth
        f(st, depth+1)
      end
    end
  end
  f(fsm, 1)
  fsm._max_depth = max_depth - 1
  
  return fsm
end

--[[for test
function test()
  local fsm = fsmComplete{
    _init = 'idle';
    idle={
    };
    st={
      st1={
        tost2 = function(fsm,data,curr)
          fsm:toState(data, 'st2')
        end;
      };
      st2={
      };
      _enter=function(fsm,data,curr)
        return curr.st1
      end
    };
  }
  local data = {}
  fsm:start(data)
  print('start')
  print(fsm:isIn(data, 'idle'))
  print(fsm:isIn(data, 'st'))
  print(fsm:isIn(data, 'st.st1'))
  print(fsm:isIn(data, 'st.st2'))
  print('to st')
  fsm:toState(data, 'st')
  print(fsm:isIn(data, 'idle'))
  print(fsm:isIn(data, 'st'))
  print(fsm:isIn(data, 'st.st1'))
  print(fsm:isIn(data, 'st.st2'))
  print('msg to st2')
  fsm:message(data, 'tost2')
  print(fsm:isIn(data, 'idle'))
  print(fsm:isIn(data, 'st'))
  print(fsm:isIn(data, 'st.st1'))
  print(fsm:isIn(data, 'st.st2'))
end
--]]
