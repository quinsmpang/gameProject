#coding=utf-8

class Rect(object):
  def __init__(self, x, y, w, h):
    self.w = w
    self.h = h
    self.x = x
    self.y = y
    self.is_rotate = False


_INFINITY = 0x7fffffff

def _score(free, rect, can_rotate, sp_x, sp_y):
  #Best Short Side Fit
  w = rect.w + sp_x
  h = rect.h + sp_y
  if can_rotate:
    wr = rect.h + sp_x
    hr = rect.w + sp_y
  
  index = None
  score = _INFINITY
  for f in free:
    if f.w >= w and f.h >= h:
      sc = min(f.w-w, f.h-h)
      if sc < score:
        score = sc
        rect.x, rect.y, rect.is_rotate = f.x, f.y, False
    if can_rotate and f.w >= wr and f.h >= hr:
      sc = min(f.w-wr, f.h-hr)
      if sc < score:
        score = sc
        rect.x, rect.y, rect.is_rotate = f.x, f.y, True
        
  return score
  

def _split(free, free2, rect, sp_x, sp_y):
  x, y = rect.x, rect.y
  if rect.is_rotate:
    w, h = rect.h+sp_x, rect.w+sp_y
  else:
    w, h = rect.w+sp_x, rect.h+sp_y
  x1, y1 = x+w, y+h
  
  for f in free:
    sx, sy = f.x, f.y
    ex, ey = sx+f.w, sy+f.h
    if x>=ex or x1<=sx or y>=ey or y1<=sy:
      free2.append(f)
    else:
      if x<ex and x1>sx:
        if y>sy and y<ey:
          free2.append(Rect(sx, sy, f.w, y-sy))
        if y1 < ey:
          free2.append(Rect(sx, y1, f.w, ey-y1))
      if y<ey and y1>sy:
        if x>sx and x<ex:
          free2.append(Rect(sx, sy, x-sx, f.h))
        if x1 < ex:
          free2.append(Rect(x1, sy, ex-x1, f.h))
      

def _merge(free2, free):
  n = len(free2)
  i = 0
  while i<n:
    ri = free2[i]
    if ri:
      j = i+1
      while j<n:
        rj = free2[j]
        if rj:
          if ri.x>=rj.x and ri.x+ri.w<=rj.x+rj.w \
             and ri.y>=rj.y and ri.y+ri.h<=rj.y+rj.h:
            free2[i] = None
            break
          if rj.x>=ri.x and rj.x+rj.w<=ri.x+ri.w \
             and rj.y>=ri.y and rj.y+rj.h<=ri.y+ri.h:
            free2[j] = None
        j += 1
    i += 1
  for r in free2:
    if r:
      free.append(r)

  
def _calc(rects, can_rotate, sp_x, sp_y, width, height):
  #从左下开始放，右上方向的spacing在排位时算在内
  free = [Rect(sp_x, sp_y, width-sp_x, height-sp_y)]
  free2 = []
  #shallow, 对Rect实例的修改仍会起作用
  #work = rects.copy()
  work = rects[:] 
  while work:
    score = _INFINITY
    index = None
    for i,r in enumerate(work):
      sc = _score(free, r, can_rotate, sp_x, sp_y)
      if sc < score:
        index, score = i, sc
    if index is None:
      return False
    #free2.clear()
    del free2[:]
    _split(free, free2, work[index], sp_x, sp_y)
    #free.clear()
    del free[:] 
    _merge(free2, free)
    del work[index]
  return True
  

def calcPlacement(rects, can_rotate, spacing, max_size):
  '''
  计算矩形的布局
    rects: [], 每个元素是{}, ['w'],['h']分别是宽高。
       如果布局成功，每个元素被附加 ['x'], ['y'], ['is_rotate']
       x, y是左下角顶点位置
    can_rotate: 是否允许旋转
    spacing: 矩形在横竖向预留的空位(1,1)
    max_size: 最大矩形大小(2048,2048)
  返回:
    若成功，是(w,h)矩形大小
    否则，返回None
  '''
  best = []
  for r in rects:
    best.append(Rect(0, 0, r['w'], r['h']))
  if not _calc(best, can_rotate, \
               spacing[0], spacing[1], max_size[0], max_size[1]):
    return None
  width, height = max_size[0], max_size[1]

  curr = []
  for r in best:
    curr.append(Rect(0,0,r.w,r.h))
  wl, wh = 1, max_size[0]
  while wl <= wh:
    w = (wl+wh)//2
    ok = False
    hl, hh = 1, max_size[1]
    while hl <= hh:
      h = (hl+hh)//2
      if w*h > width*height or \
         w*h==width*height and abs(w/h -1) > abs(width/height -1):
        hh = h - 1
        continue
      if _calc(curr, can_rotate, spacing[0], spacing[1], w, h):
        width, height = w, h
        for b,r in zip(best,curr):
          b.x, b.y, b.rotate = r.x, r.y, r.is_rotate
        ok = True
        hh = h-1
      else:
        hl = h+1
    if ok:
      wh = w-1
    else:
      wl = w+1

  for b,r in zip(best,rects):
    r['x'], r['y'], r['is_rotate'] = b.x, b.y, b.is_rotate
  return (width, height)
  

if __name__=='__main__':
  rects = [
    {'w':50, 'h':20},
    {'w':100, 'h':90},
    {'w':290, 'h':23},
    {'w':53, 'h':272},
    {'w':59, 'h':45},
    {'w':400, 'h':100},
    {'w':20, 'h':10},
  ]
  width, height = calcPlacement(rects, True, (1,1), (2048,2048))
  print(width, height)
  for r in rects:
    print('x:%d y:%d w:%d h:%d r:%d' % \
          (r['x'], r['y'], r['w'], r['h'], r['is_rotate']))

    
