local globals = GLOBALS
local Body = {}
Body.__index = Body


local min = math.min
local max = math.max
local sqrt = math.sqrt
local floor = math.floor


function Body.new(x, y, radius, gravity, color)
  local p = setmetatable({}, Planet)
  
  -- VARIABLE   = VALUE       or DEFAULT --
  p.parent      = nil -- unused
  p.x           = x           or 0
  p.y           = y           or 0
  p.radius      = radius      or 100.0
  p.gravity     = gravity     or 9.81
  p.color       = color       or {0,0,0}
  
  p.statRings   = {}
  return p
end


function Body:surfaceDistance(other)
  local radiusSum = self.radius + other.radius
  
  local dx = self.x - other.x
  local dy = self.y - other.y
  
  return sqrt(dx*dx + dy*dy) - radiusSum
end


function Body:isPointInside(x,y)
  local dx = self.x - x
  local dy = self.y - y
  
  return (dx*dx + dy*dy) < (self.radius*self.radius)
end


-- rgb of the status ring, and the time in seconds it will be visible
function Body:setStatusRing(r,g,b,time)
  local ring = { r=r, g=g, b=b, time=time, radius=self.radius }
  table.insert(self.statRings, ring)
end


function Body:isInView(camX,camY,camW,camH)
  return (self.x+self.radius+50) > camX
      and (self.x-self.radius-50) < (camX+camW)
      and (self.y+self.radius+50) > camY
      and (self.y-self.radius-50) < (camY+camH)
end


function Body:update(dt, currentZoom)
  -- update draw segments
  self.circleSegments = floor(self.radius/currentZoom)
  if self.circleSegments < 10 then
    self.circleSegments = 10
  elseif self.circleSegments > 500 then
    self.circleSegments = 500
  end
  
  -- reverse iterate, so the remove does not break the iteration
  for i=#self.statRings,1,-1 do
    local ring = self.statRings[i]
    local dist = (self.radius/ring.time) * dt
    ring.radius = ring.radius - dist
    if (ring.radius <= 0) then
      table.remove(self.statRings,i)
    end
  end
  
  if self.updateCustom then
    self:updateCustom(dt, currentZoom)
  end
end


local lg = love.graphics
function Body:drawBody()
  lg.setColor(self.color)
  lg.circle("fill", self.x, self.y, self.radius, self.circleSegments)
end


function Body:drawStatRings()
  for _,ring in ipairs(self.statRings) do
    lg.setColor(ring.r,ring.g,ring.b,255*(ring.radius/self.radius))
    lg.circle("fill", self.x, self.y, ring.radius, self.circleSegments)
  end
end


return Body
