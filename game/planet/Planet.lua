local globals = GLOBALS

local Planet = {}
Planet.__index = Planet

local PI, TAU = math.pi, math.pi*2

-- Planet class method new
function Planet.new(x, y, radius, gravity)
  local p = setmetatable({}, Planet) -- set Planet as metatable so functions not overridden by the instance are looked up on Planet
  
  -- VARIABLE   = VALUE       or DEFAULT --
  p.parent      = nil -- unused
  p.x           = x           or 0
  p.y           = y           or 0
  p.radius      = radius      or 100.0
  p.gravity     = gravity     or 9.81
  p.statRings   = {}
  
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

-- rgb of the status ring, and the time in seconds it will be visible
function Planet:setStatusRing(r,g,b,time)
  local ring = { r=r, g=g, b=b, time=time, radius=self.radius }
  table.insert(self.statRings, ring)
end

function Planet:isInView(camX,camY,camW,camH)
  return (self.x+self.radius+50) > camX
      and (self.x-self.radius-50) < (camX+camW)
      and (self.y+self.radius+50) > camY
      and (self.y-self.radius-50) < (camY+camH)
end

function Planet:update(dt)
  -- reverse iterate, so the remove does not break the iteration
  for i=#self.statRings,1,-1 do
    local ring = self.statRings[i]
    local dist = (self.radius/ring.time) * dt
    ring.radius = ring.radius - dist
    if (ring.radius <= 0) then
      table.remove(self.statRings,i)
    end
  end
end


local lg = love.graphics

function Planet:draw()
  lg.setColor(255,255,255)
  lg.circle("fill", self.x, self.y, self.radius)
  
  for _,ring in ipairs(self.statRings) do
    lg.setColor(ring.r,ring.g,ring.b,255*(ring.radius/self.radius))
    lg.circle("fill", self.x, self.y, ring.radius)
  end
  
  if (globals.debug) then
    lg.setColor(0,0,0)
    lg.print("x:"..self.x.." y:"..self.y, self.x, self.y)
    lg.print("r:"..self.radius, self.x, self.y+15)
  end
end

return Planet