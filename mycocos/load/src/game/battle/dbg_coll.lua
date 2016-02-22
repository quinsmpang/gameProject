module('game.battle.dbg_coll', package.seeall)

DebugColl = require('util.class').class()

local _getDrawFunc

DebugColl.ctor = function(self, scene)
  self.scene = scene
  local gl = cc.GLNode:create()
  self.gl_node = gl
  
  gl:setAnchorPoint(0, 0)
  gl:registerScriptDrawHandler(_getDrawFunc(self))
end

DebugColl.inst_meta.getCocosNode = function(self)
  return self.gl_node
end


_getDrawFunc = function(self)
  return function(trans, flags)
    local director = cc.Director:getInstance()
    local mtype = cc.MATRIX_STACK_TYPE.MODELVIEW
    director:pushMatrix(mtype)
    director:loadMatrix(mtype, trans)
    
    local d = cc.DrawPrimitives
    gl.lineWidth(1)
    
    d.drawColor4B(255,0,255,255)
    local ori = {x=0, y=0}
    local dst = {x=0, y=0}
    
    local dist = self.scene.distance
    local colls = self.scene.coll.type2colls
    for i,tcoll in ipairs(colls) do
      for j,c in ipairs(tcoll) do
        local x, y = c.x, c.y-dist
        ori.x, ori.y = x+c.coll_left, y+c.coll_top
        dst.x, dst.y = x+c.coll_right, y+c.coll_bottom
        d.drawRect(ori, dst)
      end
    end
    
    director:popMatrix(mtype)
  end
end

