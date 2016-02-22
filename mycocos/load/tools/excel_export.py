#coding=utf-8

import xlrd
import math

from xlrd import XL_CELL_EMPTY, XL_CELL_TEXT, XL_CELL_NUMBER, \
     XL_CELL_DATE, XL_CELL_BOOLEAN, XL_CELL_ERROR, XL_CELL_BLANK
'''
XL_CELL_EMPTY	0	empty string u''
XL_CELL_TEXT	1	a Unicode string
XL_CELL_NUMBER	2	float
XL_CELL_DATE	3	float
XL_CELL_BOOLEAN	4	int; 1 means TRUE, 0 means FALSE
XL_CELL_ERROR	5	int representing internal Excel codes; for a text representation, refer to the supplied dictionary error_text_from_code
XL_CELL_BLANK	6	empty string u''
'''

def coli(col):
  if type(col)==int:
    return col
  if type(col)!=str:
    raise TypeError('unsupport type', type(col))
  col = col.upper()
  idx = -1
  for c in col:
    idx = (idx+1)*26 + ord(c) - 65
  return idx

def _vexp(row, col, desc, value):
  return ValueError('%s:%s' % (xlrd.cellname(row,col), desc), value)

def getNumber(sheet, row, col, default):
  t = sheet.cell_type(row, col)
  v = sheet.cell_value(row, col)
  if t==XL_CELL_NUMBER or t==XL_CELL_DATE or t==XL_CELL_BOOLEAN:
    return v
  elif t==XL_CELL_EMPTY or t==XL_CELL_BLANK:
    if default is not None:
      return float(default)
    raise _vexp(row, col, 'number required but EMPTY', None)
  elif t == XL_CELL_TEXT:
    try:
      v = float(v)
    except ValueError:
      raise _vexp(row, col, 'number require but TEXT', v)
    return v
  elif t == XL_CELL_ERROR:
    raise _vexp(row, col, 'number required but ERROR', v)

def getInt(sheet, row, col, default=None):
  t = sheet.cell_type(row, col)
  v = sheet.cell_value(row, col)
  if t==XL_CELL_NUMBER or t==XL_CELL_DATE:
    if math.fmod(v,1) > 1e-7:
      raise _vexp(row, col, 'int required but has float', v)
    return int(v)
  elif t==XL_CELL_EMPTY or t==XL_CELL_BLANK:
    if default is not None:
      return int(default)
    raise _vexp(row, col, 'int reuuired but EMPTY', None)
  elif t==XL_CELL_BOOLEAN:
    return v
  elif t==XL_CELL_TEXT:
    try:
      v = int(v)
    except ValueError:
      raise _vexp(row, col, 'int required but ERROR', v)
    return v
  elif t==XL_CELL_ERROR:
    raise _vexp(row, col, 'int required but ERROR', v)

def getUint(sheet, row, col, default=None):
  v = getInt(sheet, row, col, default)
  if v<0:
    raise _vexp(row, col, 'uint required but <0', v)
  return v

def getPosInt(sheet, row, col, default=None):
  v = getInt(sheet, row, col, default)
  if v<=0:
    raise _vexp(row, col, 'pos int required but <=0', v)
  return v

def getBoolean(sheet, row, col, default=None):
  t = sheet.cell_type(row, col)
  v = sheet.cell_value(row, col)
  if t==XL_CELL_BOOLEAN:
    return v==1
  elif t==XL_CELL_EMPTY or t==XL_CELL_BLANK:
    return False
  elif t==XL_CELL_NUMBER or t==XL_CELL_DATE:
    if v==1: return True
    elif v==0: return False
    else: raise _vexp(row, col, 'boolean required but has float', v)
  elif t==XL_CELL_TEXT:
    if v=='1': return True
    elif v=='0': return False
    else: raise _vexp(row, col, 'boolean required but has text', v)
  elif t==XL_CELL_ERROR:
    raise _vexp(row, col, 'int required but ERROR', v)

def getText(sheet, row, col, default=None):
  t = sheet.cell_type(row, col)
  v = sheet.cell_value(row, col)
  if t==XL_CELL_TEXT or t==XL_CELL_EMPTY or t==XL_CELL_BLANK:
    return v
  if t==XL_CELL_NUMBER or t==XL_CELL_DATE or t==XL_CELL_BOOLEAN:
    return u'%g' % v
  elif t==XL_CELL_ERROR:
    raise _vexp(row, col, 'text required but ERROR', v)

def literalNumber(sheet, row, col, default=None):
  return '%g' % getNumber(sheet, row, col, default)

def literalInt(sheet, row, col, default=None):
  return '%d' % getInt(sheet, row, col, default)

def literalUint(sheet, row, col, default=None):
  return '%d' % getUint(sheet, row, col, default)

def literalPosInt(sheet, row, col, default=None):
  return '%d' % getPosInt(sheet, row, col, default)

def literalBoolean(sheet, row, col, default=None):
  return getBoolean(sheet, row, col, default) and 'true' or 'false'

def reprText(text):
  i = text.find(u'\n')
  if i<0:
    i = text.find(u'\\')
    if i<0:
      i = text.find(u'"')
      if i<0: return '"%s"' % text.encode('utf-8')
      i = text.find("'")
      if i<0: return "'%s'" % text.encode('utf-8')
  e = 0
  while True:
    mid = u'='*e
    e += 1
    start = u'[' + mid + u'['
    end = u']' + mid + u']'
    if text.find(start)<0 and text.find(end)<0:
      return '%s%s%s' % \
        (start.encode('utf-8'), text.encode('utf-8'), end.encode('utf-8'))
    
def literalText(sheet, row, col, default=None):
  return reprText(getText(sheet, row, col, default))


###############
def export_ability():
  file_path = u'E:\\projects\\lordRoadFiles\\Y-英雄系统\\英雄数值表新.xlsx'
  out_path = u'E:\\projects\\lord_road\\src\\data\\ability.lua'
  sheet_index = 0

  col_key = [
    [coli('D'), 'level', literalPosInt, None],
    [coli('H'), 'golds', literalUint, None],
    [coli('E'), 'power', literalUint, None],
    [coli('F'), 'interval', literalUint, None],
    [coli('G'), 'distance', literalUint, None],
  ]

  with xlrd.open_workbook(file_path, on_demand=True) as wb:
    sheet = wb.sheet_by_index(sheet_index)
    with open(out_path, 'wb') as f:
      f.write("module('data.ability')\n\n")
      f.write('''--[[
  英雄的各级能力。
  由excel导出，不要编辑。
  ]]\n''')
      f.write("heros={\n")

      last = 0
      for r in xrange(1, sheet.nrows):
        v = getUint(sheet, r, 0, 0)
        if v != 0:
          if last != 0:
            f.write("  },\n")
          last = 0
          name = getText(sheet, r, 1, '')
          f.write("  [%d]={ --%s\n" % (v,name.encode('utf-8')))
        
        lv = getPosInt(sheet,r,col_key[0][0])
        if lv != last+1:
          _vexp(r,col_key[0][0],'Value not in order',lv)
        last = lv
        f.write("    {\n")
        for ck in col_key:
          f.write("      %s=%s,\n" % \
                  (ck[1], ck[2](sheet,r,ck[0],ck[3])))
        f.write("    },\n")
      if last != 0:
        f.write("  },\n")
      
      f.write("}")
      f.flush()
      f.close()


def export_shop():
  file_path = u'E:\\projects\\lordRoadFiles\\S-商店\\S-商店列表.xlsx'
  out_path = u'E:\\projects\\lord_road\\src\\data\\shop.lua'
  sheet_index = 0

  col_key = [
    [coli('D'), 'gold', literalPosInt, None],
    [coli('B'), 'money', literalPosInt, None],
  ]

  with xlrd.open_workbook(file_path, on_demand=True) as wb:
    sheet = wb.sheet_by_index(sheet_index)
    with open(out_path, 'wb') as f:
      f.write("module('data.shop')\n\n")
      f.write('''--[[
  商店数据，{金币, 元}。
  由excel导出，不要编辑。
  ]]\n''')
      f.write("shop={\n")
      for r in xrange(1, sheet.nrows):
        f.write("  {")
        for ck in col_key:
          f.write("%s, " % ck[2](sheet,r,ck[0],ck[3]) )
        f.write("},\n")
      
      f.write("}")
      f.flush()
      f.close()

def export_task():
  file_path = u'E:\\projects\\lordRoadFiles\\R-任务系统\\R-任务.xlsx'
  out_path = u'E:\\projects\\lord_road\\src\\data\\task.lua'
  sheet_index = 0

  with xlrd.open_workbook(file_path, on_demand=True) as wb:
    sheet = wb.sheet_by_index(sheet_index)
    with open(out_path, 'wb') as f:
      f.write("""
local _const = require('data.const')

module('data.task')

--[[
任务数据。
由excel导出，不要编辑。

每项内容
{
  index=在任务中的位置
  target=目标：跑多少米、杀多少敌人、营救多少英雄
  calc=计算类型：单场还是累计
  number=跑的米数、敌人个数、英雄个数
  extra=暂时目标为杀敌时用，表示要杀的id, 为nil则是任意敌人
  reward=奖励金币数
}
]]

local _TARGET_RUN = _const.TASK_TARGET_RUN
local _TARGET_KILL = _const.TASK_TARGET_KILL
local _TARGET_RESCUE = _const.TASK_TARGET_RESCUE

local _CALC_ONE_BATTLE = _const.TASK_CALC_ONE_BATTLE
local _CALC_ACCUMULATION = _const.TASK_CALC_ACCUMULATION

""")

      target = {
        1: '_TARGET_RUN',
        2: '_TARGET_KILL',
        3: '_TARGET_RESCUE',
      }
      calc = {
        1: '_CALC_ONE_BATTLE',
        2: '_CALC_ACCUMULATION',
      }

      f.write("tasks={\n")
      
      for r in xrange(1, sheet.nrows):
        f.write("  {\n")
        #index
        f.write("    index=%d,\n" % r)
        #target, calc
        n = getPosInt(sheet, r, coli('C'))
        f.write("    target=%s,\n" % target[n])
        n = getPosInt(sheet, r, coli('D'))
        f.write("    calc=%s,\n" % calc[n])
        #number
        f.write("    number=%s,\n" % literalPosInt(sheet,r,coli('E')) )
        #extra
        extra = getInt(sheet, r, coli('F'), -1)
        if extra >= 0:
          f.write("    extra=%d,\n" % extra)
        #reward
        f.write("    reward=%s,\n" % literalPosInt(sheet,r,coli('G')) )
        #
        f.write("  },\n")
      
      f.write("}\n")
      f.flush()
      f.close()
  
####
export_ability()
#export_shop()
export_task()
