#coding=utf-8

import struct
import os
from os import path as os_path
import sys

## bkdr
def bkdr(str):
  seed = 131 #31 131 1313 13131 131313
  h = 0
  for c in str:
    h = h*seed + ord(c)
    h &= 0xffffffff
  return h
  
## fnv 1a 32
def fnv(str):
  h = 2166136261
  for c in str:
    h ^= ord(c)
    h *= 16777619
    h &= 0xffffffff
  return h

def _str_32_8(str):
  l4 = len(str) // 4
  l1 = len(str) % 4
  v32 = list(struct.unpack('<%iI' % l4, str[:l4*4]))
  v8 = []
  if l1 != 0:
    for s in str[-l1:]:
      v8.append(ord(s))
  return v32, v8

## murmurmur3 hash 32
def mm3(str):
  c1 = 0xcc9e2d51
  c2 = 0x1b873593

  v32, v8 = _str_32_8(str)
  h = 0
  #body
  for k in v32:
    k = (k * c1) & 0xffffffff
    k = (k<<15) | (k>>17)
    k = (k * c2) & 0xffffffff
    h ^= k
    h = (h<<13) | (h>>19)
    h = h*5 + 0xe6546b64
    h &= 0xffffffff
  #tail
  if v8:
    k = 0
    shift = 0
    for t in v8:
      k ^= (t<<shift)
      shift += 8
    k = (k*c1) & 0xffffffff
    k = (k<<15) | (k>>17)
    k = (k*c2) & 0xffffffff
    h ^= k
  #finalize
  h ^= len(str)
  h ^= (h>>16)
  h = (h*0x85ebca6b) & 0xffffffff
  h ^= (h>>13)
  h = (h*0xc2b2ae35) & 0xffffffff
  h ^= (h>>16)

  return h

###########################################
header = {
  'tag': 'PK\x03\x04', #4byte ...
  'ver': 0,   #uint16
  'flags': 0, #uint16
  
  'file_size': 0, #uint32 本文件大小
  'entrys_start': 0, #uint32 entrys表开始位置
  
  'hash_start': 0, #uint32 hash表开始位置
  'entrys_count': 0, #uint16 entrys表的项数
  'hash_pot': 0, #uint8 hash表项数 = 2^hash_pot
  'reserved': '\x00', #...
}
HEADER_SIZE = 24

'''
entrys每项代表一个文件信息
{
'start': uint32 相对开始的位置
'data_size': uint32 数据大小
'store_size': uint32 存储大小
'flags': uint32 
}
'''
ENTRY_SIZE = 16

'''
hash_tbl每项代表一个hash入口信息
最多只能 65534个
{
'hash0': uint32 hash0的值
'hash1': uint32 hash1的值
'hash2': uint32 hash2的值
'next':  uint16 冲突链下一项，0xffff表示无
'_prev': 冲突链前一项，仅计算中用，0xffff表示无
'entry': uint16 对应的entry索引, 0xffff表示无
}
'''
HASH_SIZE = 16

#其它常量配置
INVALID_INDEX = 0xffff
FLAG_DEFLATE = 0x01
MAX_FILE_SIZE = (1<<26) #64M
MAX_FILES = 0x8000 #最多文件数
MAX_POT = 15
COLL_MAX = 5     #冲突链最大长度
COLL_AVG = 1.5   #冲突链平均长度

FLAT_SUFFIX = ['.mp3', '.ogg', '.mid',
               '.png', '.jpg', '.clr', '.opa']
FLAT_SIZE_MIN = 1024
FLAT_SIZE_MAX = (1<<19)
FLAT_RATIO_MIN = 0.9

######
'''
path : {
  #collectFilesInfo
  'size': uint32
  #calcPathsHash
  'h0': uint32
  'h1': uint32
  'h2': uint32
  #writeData
  'entry': index
  'store': store size
  'flags': ...
}
'''
files_info = {
}

verbose = False


########
def _findCollisionMaxAndAvg(hashes):
  #hashes需非空
  _max = max(hashes.itervalues())
  _sum = sum(hashes.itervalues(), 0)
  return _max, _sum*1.0/len(hashes)


def findHashTablePOT():
  '''
    尝试找合适的hash_tbl大小，在冲突率、大小之间折衷
  '''
  hashes = {}
  pot = MAX_POT
  mask = (1 << pot) - 1
  for p, info in files_info.iteritems():
    h0 = info['h0'] & mask
    hashes[h0] = hashes.get(h0,0) + 1
  coll_max, coll_avg = _findCollisionMaxAndAvg(hashes)
  #如未删减的值比期望要大，最好也就做到这
  coll_max = max(coll_max, COLL_MAX)
  coll_avg = max(coll_avg, COLL_AVG)

  cmax, cavg = coll_max, coll_avg
  while pot>0 and len(files_info) <= (1<<(pot-1)):
    mask >>= 1
    htbl = {}
    for h, c in hashes.iteritems():
      h &= mask
      htbl[h] = htbl.get(h,0) + c
    cm, ca = _findCollisionMaxAndAvg(htbl)
    if cm > coll_max or ca > coll_avg:
      break
    cmax, cavg = cm, ca
    pot -= 1
    hashes = htbl
  
  print('files:%d hashtbl:%d pot:%d max:%d avg:%.1f' % \
        (len(files_info), (1<<pot), pot, cmax, cavg) )
  if verbose:
    for h, c in hashes.iteritems():
      print('%d %d' % (h, c))
  
  return pot
  

def calcPathsHashes():
  #(h0,h1,h2):path
  hashes = {}
  for path,info in files_info.iteritems():
    p = path.decode().encode('utf-8')
    h = (mm3(p), fnv(p), bkdr(p))
    if hashes.has_key(h):
      raise RuntimeError( \
        'hash conflict.\n' \
        '   %s hash (%d %d %d)\n' \
        '-> %s' % (path, h[0], h[1], h[2], hashes[h]) )
    hashes[h] = path
    info['h0'] = h[0]
    info['h1'] = h[1]
    info['h2'] = h[2]
    

def collectFilesInfo(dir, rel_path):
  for name in os.listdir(dir):
    full_path = os_path.join(dir, name)
    if os_path.isdir(full_path):
      rel = ''.join( (rel_path, name, '/') )
      collectFilesInfo(full_path, rel)
    elif os_path.isfile(full_path):
      rel = rel_path + name
      size = os_path.getsize(full_path)
      if size > MAX_FILE_SIZE:
        raise RuntimeError('%s too large:%d' % (rel,size))
      files_info[rel] = {'size':size}
    else:
      raise RuntimeError('%s%s neither dir nor file' % (rel_path,name))


#返回 bool(是否压缩), data(数据)
def _compressIfOk(path, data):
  size = len(data)
  if os_path.splitext(path)[1].lower() in FLAT_SUFFIX \
     or size < FLAT_SIZE_MIN \
     or size > FLAT_SIZE_MAX:
    return False, data
  import zlib
  cd = zlib.compress(data, zlib.Z_BEST_COMPRESSION)
  if len(cd) >= size*FLAT_RATIO_MIN:
    return False, data
  return True, cd
  

def _findNextEmpty(hash_tbl, start):
  start = start or 0
  end = len(hash_tbl)
  while start < end \
    and hash_tbl[start]['entry'] != INVALID_INDEX:
    start = start + 1
  if start >= end:
    raise RuntimeError('impossible. 不能找到空位')
  return start
  
def _fillHashTable(pot):
  htbl = []
  size = (1 << pot)
  mask = size - 1
  for i in xrange(size):
    htbl.append({
      'hash0': 0,
      'hash1': 0,
      'hash2': 0,
      'next': INVALID_INDEX,
      '_prev': INVALID_INDEX,
      'entry': INVALID_INDEX
    })
  empty = None
  for info in files_info.itervalues():
    pos = info['h0'] & mask
    item = htbl[pos]
    if item['entry'] == INVALID_INDEX:
      assert item['_prev']==INVALID_INDEX
      assert item['next']==INVALID_INDEX
      pass
    elif pos == (item['hash0'] & mask):
      assert item['_prev']==INVALID_INDEX
      #产生冲突，找个空位加入该链表
      empty = _findNextEmpty(htbl, empty)
      new_item = htbl[empty]
      
      _next = item['next']
      item['next'] = empty
      new_item['next'] = _next
      new_item['_prev'] = pos
      if _next != INVALID_INDEX:
        htbl[_next]['_prev'] = empty
        
      item = new_item
    else:
      assert item['_prev'] != INVALID_INDEX
      #已有项属于其它链表，另找空位安置之，此处属于本项            
      _prev = item['_prev']
      _next = item['next']
      item['_prev'] = INVALID_INDEX
      item['next'] = INVALID_INDEX
      
      empty = _findNextEmpty(htbl, empty)
      new_item = htbl[empty]

      new_item['hash0'] = item['hash0']
      new_item['hash1'] = item['hash1']
      new_item['hash2'] = item['hash2']
      new_item['entry'] = item['entry']
      new_item['_prev'] = _prev
      new_item['next'] = _next
      if _prev != INVALID_INDEX:
        htbl[_prev]['next'] = empty
      if _next != INVALID_INDEX:
        htbl[_next]['_prev'] = empty
    #  
    item['hash0'] = info['h0']
    item['hash1'] = info['h1']
    item['hash2'] = info['h2']
    item['entry'] = info['entry']
  if verbose:
    for i,it in enumerate(htbl):
      sn = '-' if it['next']==INVALID_INDEX else ('%d'%it['next'])
      se = '-' if it['entry']==INVALID_INDEX else ('%d'%it['entry'])
      print('(%d h0:%08x h1:%08x h2:%08x next:%s entry:%s)' \
          % (i, it['hash0'], it['hash1'], it['hash2'], sn, se) )
  return htbl


def writeData(out_file, rel_dir, pot):
  out_file.seek(HEADER_SIZE)
  curr_pos = HEADER_SIZE

  global header
  entrys = []

  d = None
  #写入文件数据，填充entry表
  for path, info in files_info.iteritems():
    info['entry'] = len(entrys)
    
    data_size = info['size']
    #with open( os_path.join(rel_dir, path), 'rb' ) as f:
    f = open( os_path.join(rel_dir, path), 'rb' )
    d = f.read()
    f.close()
    
    if len(d) != data_size:
      raise RuntimeError( \
        '%s 大小从%d变化到%d. 操作中被改动?' % (path, data_size, len(d)) )

    ok, d = _compressIfOk(path, d)
    store_size = len(d)
    flags = FLAG_DEFLATE if ok else 0
    
    entrys.append({
      'start': curr_pos,
      'data_size': data_size,
      'store_size': store_size,
      'flags': flags
    })
    out_file.write(d)
    curr_pos += store_size
    d = None
    if verbose:
      print('%d %d(%d,%d) %s' % (info['entry'], \
            flags, store_size, data_size, path))
  #写入entry表数据
  header['entrys_start'] = curr_pos
  header['entrys_count'] = len(entrys)
  for e in entrys:
    d = struct.pack('<IIII', e['start'], e['data_size'], \
                    e['store_size'], e['flags'])
    out_file.write(d)
    curr_pos += ENTRY_SIZE
  #填充hash表，写入数据
  hash_tbl = _fillHashTable(pot)
  header['hash_start'] = curr_pos
  header['hash_pot'] = pot
  for h in hash_tbl:
    d = struct.pack('<IIIHH', h['hash0'], h['hash1'], h['hash2'], \
                    h['next'], h['entry'])
    out_file.write(d)
    curr_pos += HASH_SIZE
  #回填header
  header['file_size'] = curr_pos
  out_file.seek(0)
  d = '<%dsHHIIIHB%ds' % (len(header['tag']), len(header['reserved']))
  d = struct.pack(d, \
                  header['tag'], header['ver'], header['flags'], \
                  header['file_size'], header['entrys_start'], \
                  header['hash_start'], header['entrys_count'], \
                  header['hash_pot'], header['reserved'])
  out_file.write(d)

  

def packDirToFile(input_dir, output_file):
  collectFilesInfo(input_dir, '')
  if not files_info:
    raise RuntimeError('no file to pack')
  if len(files_info) > MAX_FILES:
    raise RuntimeError( \
      'cannot fit %d files, max %d' % (len(files_info), MAX_FILES))
  
  calcPathsHashes()
  pot = findHashTablePOT()
  
  #with open(output_file, 'wb') as f:
  f = open(output_file, 'wb')
  writeData(f, input_dir, pot)
  f.flush()
  f.close()
  

###################
def main():
  if len(sys.argv) < 3:
    print('usage: this.py input_dir output_file')
    return 1
  
  if len(sys.argv)>3 and sys.argv[3]=='verbose':
    global verbose
    verbose = True  
  try:
    input_dir = os_path.abspath(sys.argv[1])
    output_file = os_path.abspath(sys.argv[2])
    packDirToFile(input_dir, output_file)
  except:
    import traceback
    traceback.print_exc()
    return 1
  else:
    print('pack done!')
    return 0

sys.exit( main() )


