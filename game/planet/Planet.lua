local globals = GLOBALS

local Planet = {}
Planet.__index = Planet

-- Planet class method new
function Planet.new(x, y, radius, gravity)
  local p = setmetatable({}, Planet) -- set Planet as metatable so functions not overridden by the instance are looked up on Planet
  
  -- VARIABLE   = VALUE       or DEFAULT --
  p.parent      = nil -- unused
  p.x           = x           or 0
  p.y           = y           or 0
  p.radius      = radius      or 100.0
  p.gravity     = gravity     or 9.81
  
  return p
end


function Planet:surfaceDistance(other)
  local radiusSum = self.radius + other.radius
  
  local dx = self.x - other.x
  local dy = self.y - other.y
  
  return math.sqrt(dx*dx + dy*dy) - radiusSum
end

function Planet:isPointInside(x,y)
  local dx = self.x - x
  local dy = self.y - y
  
  return (dx*dx + dy*dy) < (self.radius*self.radius)
end


function Planet:setHurt()
  self.hurt = 255
end


function Planet:update(dt)
  if (self.hurt) then
    self.hurt = self.hurt - 255*dt
    if (self.hurt <= 0) then
      self.hurt = nil
    end
  end
end


local lg = love.graphics

function Planet:draw()
  lg.setColor(255,255,255)
  lg.circle("fill", self.x, self.y, self.radius)
  
  if (self.hurt) then
    lg.setColor(255,0,0,self.hurt)
    lg.circle("fill", self.x, self.y, self.radius)
  end
  
  if (globals.debug) then
    lg.setColor(0,0,0)
    lg.print("x:"..self.x.." y:"..self.y, self.x, self.y)
    lg.print("r:"..self.radius, self.x, self.y+15)
  end
end

return Planet