#coding=utf-8

import plistlib

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


def output(items, out_file):
  f = open(out_file, 'wb')
  f.write('''module('data.sprframe')
--[[
记录所有sprite frame
由.plist生成，不要修改
]]
plists={
''')

  for it in items:
    f.write("  {\n")
    f.write("    plist=%s;\n" % reprText(it[1]))
    d = plistlib.readPlist(it[0])
    ks = d['frames'].keys()
    ks.sort()
    for k in ks:
      f.write('    %s,\n' % reprText(k))
    f.write('  },\n')
    
  f.write('}')
  f.flush()
  f.close()

#######
game_plists = [
          ('bg.plist', 'bg.plist'),
          ('bonus.plist', 'bonus.plist'),
          ('boss.plist', 'boss.plist'),
          ('enemy.plist', 'enemy.plist'),
          ('hero.plist', 'hero.plist'),
          ('bullet.plist', 'bullet.plist'),
          #('ui.plist', 'ui/ui.plist'),
        ]
out_file = 'src\\data\\sprframe.lua'

if __name__=='__main__':
  import sys
  if len(sys.argv) < 3:
    print('sprframe.py plist_dir game_proj_dir')
    sys.exit(1)
    
  plist_dir = sys.argv[1]
  game_proj_dir = sys.argv[2]
  
  import os.path
  abs_out_file = os.path.join(game_proj_dir, out_file)
  items = []
  for plist in game_plists:
    it = (os.path.join(plist_dir, plist[0]), plist[1])
    items.append(it)
  output(items, abs_out_file)
  
