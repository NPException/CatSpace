local globals = GLOBALS
local Body = {}
Body.__index = Body


local Resource
local timer = love.timer

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
  p.visible     = false
  
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
  for _,b in ipairs(bodies) do
    if self:surfaceDistance(b) < minDist then
      return true
    end
  end
  return false
end


function Body:isPointInside(x,y)
  local dx = self.x - x
  local dy = self.y - y
  
  return (dx*dx + dy*dy) < (self.radius*self.radius)
end


-- rgb of the status ring, and the time in seconds it will be visible and its radius
function Body:setStatusRing(r,g,b,time, radius)
  radius = radius or self.radius
  local ring = { r=r, g=g, b=b, startTime=timer.getTime(), time=time, initialRadius=radius }
  table.insert(self.statRings, ring)
end


function Body:isInView(camera)
  local camX = camera.x
  local camY = camera.y
  local camWHalf = globals.window.width*camera.scale*0.5
  local camHHalf = globals.window.height*camera.scale*0.5
  -- okay Jezza, you won.
  return  (self.x + self.radius + 50) > (camX - camWHalf)
      and (self.x - self.radius - 50) < (camX + camWHalf)
      and (self.y + self.radius + 50) > (camY - camHHalf)
      and (self.y - self.radius - 50) < (camY + camHHalf)
end


function Body:updateCircleSegments()
  self.circleSegments = floor(self.radius/(globals.config.currentZoom*0.7))
  if self.circleSegments < 10 then
    self.circleSegments = 10
  elseif self.circleSegments > 500 then
    self.circleSegments = 500
  end
end


function Body:update(dt)
  self.visible = self:isInView(globals.camera)
  for _,res in ipairs(self.resources) do
    res:update(dt)
  end
end

function Body:draw()
end


local lg = love.graphics
function Body:drawBody()
  lg.setColor(self.color)
  lg.circle("fill", self.x, self.y, self.radius, self.circleSegments)
end


function Body:drawStatRings()
  local now = timer.getTime()
  
  -- reverse iterate, so the remove does not break the iteration
  for i=#self.statRings,1,-1 do
    local ring = self.statRings[i]
    local ringRadius = ((now-ring.startTime-ring.time)/-ring.time) * ring.initialRadius
    if (ringRadius <= 0) then
      table.remove(self.statRings,i)
    else
      lg.setColor(ring.r,ring.g,ring.b,255*(ringRadius/self.radius))
      lg.circle("fill", self.x, self.y, ringRadius, self.circleSegments)
    end
  end
end


function Body:drawResources()
  for _,res in ipairs(self.resources) do
    res:draw()
  end
end

return Body
