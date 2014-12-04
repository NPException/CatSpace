local globals = GLOBALS
local Body = {}
Body.__index = Body


local Resource

local min = math.min
local max = math.max
local sqrt = math.sqrt
local floor = math.floor


function Body.new(x, y, radius, gravity, color)
  if not Resource then
    Resource = require("game.bodies.Resource")
  end  

  local p = setmetatable({}, Body)
  
  -- VARIABLE   = VALUE       or DEFAULT --
  p.x           = x           or 0
  p.y           = y           or 0
  p.radius      = radius      or 100.0
  p.gravity     = gravity     or 9.81
  p.color       = color       or {0,0,0}
  
  p.resources   = {}
  p.statRings   = {}
  return p
end

-- returns whether the resource could be added successfully or not
function Body:addResource(radius, pos)
  local resource = Resource.new(self, radius, pos)
  local invalid = resource:closeToOtherBody(self.resources, 2)
  
  if invalid then return false end
  
  table.insert(self.resources, resource)
  return true
end


function Body:removeResource(resource)
  for i,res in ipairs(self.resources) do
    if res == resource then
      table.remove(self.resources, i)
      break
    end
  end
end


function Body:surfaceDistance(other)
  local radiusSum = self.radius + other.radius
  
  local dx = self.x - other.x
  local dy = self.y - other.y
  
  return sqrt(dx*dx + dy*dy) - radiusSum
end


function Body:closeToOtherBody(bodies, minDist) 
  local result = false
  for _,b in ipairs(bodies) do
    if self:surfaceDistance(b) < minDist then
      result = true
      break
    end
  end
  return result
end


function Body:isPointInside(x,y)
  local dx = self.x - x
  local dy = self.y - y
  
  return (dx*dx + dy*dy) < (self.radius*self.radius)
end


-- rgb of the status ring, and the time in seconds it will be visible and its radius
function Body:setStatusRing(r,g,b,time, radius)
  radius = radius or self.radius
  local ring = { r=r, g=g, b=b, time=time, radius=radius, initialRadius=radius }
  table.insert(self.statRings, ring)
end


local lw = love.window
function Body:isInView(camera)
  local camX = camera.x
  local camY = camera.y
  local camWHalf = lw.getWidth()*camera.scale*0.5
  local camHHalf = lw.getHeight()*camera.scale*0.5
  -- okay Jezza, you won.
  return  (self.x + self.radius + 50) > (camX - camWHalf)
      and (self.x - self.radius - 50) < (camX + camWHalf)
      and (self.y + self.radius + 50) > (camY - camHHalf)
      and (self.y - self.radius - 50) < (camY + camHHalf)
end


function Body:updateCircleSegments()
  self.circleSegments = floor(self.radius/globals.config.currentZoom)
  if self.circleSegments < 10 then
    self.circleSegments = 10
  elseif self.circleSegments > 500 then
    self.circleSegments = 500
  end
end


function Body:update(dt)
  -- update draw segments
  self:updateCircleSegments()
  
  for _,res in ipairs(self.resources) do
    res:update(dt)
  end
  
  -- reverse iterate, so the remove does not break the iteration
  for i=#self.statRings,1,-1 do
    local ring = self.statRings[i]
    local dist = (ring.initialRadius/ring.time) * dt
    ring.radius = ring.radius - dist
    if (ring.radius <= 0) then
      table.remove(self.statRings,i)
    end
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


function Body:drawResources()
  for _,res in ipairs(self.resources) do
    res:draw()
  end
end

return Body
