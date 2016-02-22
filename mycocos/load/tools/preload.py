#coding=utf-8

def reprText(text):
  i = text.find('\n')
  if i<0:
    i = text.find('\\')
    if i<0:
      i = text.find('"')
      if i<0: return '"%s"' % text
      i = text.find("'")
      if i<0: return "'%s'" % text
  e = 0
  while True:
    mid = '='*e
    e += 1
    start = '[' + mid + '['
    end = ']' + mid + ']'
    if text.find(start)<0 and text.find(end)<0:
      return '%s%s%s' % (start, text, end)

    
def outputSprites(f, sprites):
  f.write('sprites={\n')
  for sp in sprites:
    f.write('  %s,\n' % reprText(sp))
  f.write('}\n\n')

def outputSound(f, sound_dir, prefix):
  import os
  f.write('sounds={\n')
  for fl in os.listdir(sound_dir):
    s = reprText('%s/%s' % (prefix, fl))
    f.write('  %s,\n' % s)
  f.write('}\n\n')
    
  
#######
sprites = [
          #'blizzard.png',
        ]
sound = ('res/sound', 'sound')
out_file = 'src\\data\\preload.lua'

if __name__=='__main__':
  import sys
  if len(sys.argv) < 2:
    print('preload.py game_proj_dir')
    sys.exit(1)
    
  game_proj_dir = sys.argv[1]
  
  import os.path
  abs_out_file = os.path.join(game_proj_dir, out_file)
  with open(abs_out_file, 'wb') as f:
    f.write('''module('data.preload')
--[[
记录预加载的sprite，声音
由preload.py生成，不要修改
]]
''')
    outputSprites(f, sprites)
    outputSound(f, os.path.join(game_proj_dir, sound[0]), sound[1])
    f.flush()
