#coding=utf-8

import os
from os import path
import subprocess
import zipfile
import sys

############################################################ 
#http://www.coolcode.org/archives/?article-307.html
############################################################ 

import struct 

_DELTA = 0x9E3779B9  

def _long2str(v, w):  
    n = (len(v) - 1) << 2  
    if w:  
        m = v[-1]  
        if (m < n - 3) or (m > n): return ''  
        n = m  
    s = struct.pack('<%iL' % len(v), *v)  
    return s[0:n] if w else s  
  
def _str2long(s, w):  
    n = len(s)  
    m = (4 - (n & 3) & 3) + n  
    s = s.ljust(m, "\0")  
    v = list(struct.unpack('<%iL' % (m >> 2), s))  
    if w: v.append(n)  
    return v  
  
def encrypt(str, key):  
    if str == '': return str  
    v = _str2long(str, True)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    sum = 0  
    q = 6 + 52 // (n + 1)  
    while q > 0:  
        sum = (sum + _DELTA) & 0xffffffff  
        e = sum >> 2 & 3  
        for p in xrange(n):  
            y = v[p + 1]  
            v[p] = (v[p] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            z = v[p]  
        y = v[0]  
        v[n] = (v[n] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[n & 3 ^ e] ^ z))) & 0xffffffff  
        z = v[n]  
        q -= 1  
    return _long2str(v, False)  
  
def decrypt(str, key):  
    if str == '': return str  
    v = _str2long(str, False)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    q = 6 + 52 // (n + 1)  
    sum = (q * _DELTA) & 0xffffffff  
    while (sum != 0):  
        e = sum >> 2 & 3  
        for p in xrange(n, 0, -1):  
            z = v[p - 1]  
            v[p] = (v[p] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            y = v[p]  
        z = v[n]  
        v[0] = (v[0] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[0 & 3 ^ e] ^ z))) & 0xffffffff  
        y = v[0]  
        sum = (sum - _DELTA) & 0xffffffff  
    return _long2str(v, True)  

#####
_lua = path.abspath(
         path.normpath(
           path.join(
             path.dirname(__file__),
             'lua/luajit.exe'
           )
         )
       )

_ext = None
_key = None
_sign = None

def _compileDir(src, dst):
  global _lua, _ext, _key, _sign
  if not path.exists(dst):
    os.makedirs(dst)
  for file in os.listdir(src):
    spath = path.join(src, file)
    if path.isdir(spath):
      _compileDir(spath,
        path.join(dst, file) )
    elif path.isfile(spath):
      dpath = path.join(dst, path.splitext(file)[0]) + _ext
      
      cmd = '"%s" -b "%s" "%s"' % (_lua, spath, dpath)
      print(cmd)
      status = subprocess.call(cmd)
      if status != 0:
        raise RuntimeError('%s\nstatus %d' % (cmd,status))

      bytes = None
      with open(dpath, 'rb') as f:
          bytes = f.read()

      zip = zipfile.ZipFile(dpath, 'w', zipfile.ZIP_DEFLATED)
      zip.writestr('1', bytes)
      zip.close()
      
      with open(dpath, 'rb+') as f:
        enc = encrypt(f.read(), _key)
        f.seek(0)
        f.write(_sign)
        f.write(enc)
      

def luaCompile(src_dir, dst_dir):
  src_dir = path.abspath(src_dir)
  dst_dir = path.abspath(dst_dir)
  _compileDir(src_dir, dst_dir)
  

#####
if len(sys.argv) < 1+5:
  print('usage: luac.py src_dir dst_dir file_ext xxxtea_key xxxtea_sign')
  sys.exit(1)
try:
  _ext = sys.argv[3]
  if _ext[0] != '.':
    _ext = '.'+_ext
  _key = sys.argv[4]
  _sign = sys.argv[5]
  luaCompile(sys.argv[1], sys.argv[2])
except:
  import traceback
  traceback.print_exc()
  sys.exit(1)
else:
  sys.exit(0)
  

