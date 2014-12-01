local globals = GLOBALS
local Body = require("game.bodies.Body")
local Resource = setmetatable({}, Body)
Resource.__index = Resource


local PI, TAU = math.pi, math.pi*2
local sin, cos = math.sin, math.cos
local sqrt = math.sqrt
local floor = math.floor


-- Planet class method new
function Resource.new(parentBody, radius, pos)
  
  pos = (pos or 0) % 1
  
  if (radius > parentBody.radius-10) then
    error("Radius of resource too large for parent body. Maximum possible = "..(parentBody.radius-10)..", amount given: "..radius, 2)
  end
  
  local color = {50+math.random(-10,10),40+math.random(-10,10),20+math.random(-10,10)}
  local depth = parentBody.radius - radius - 10
  local x = parentBody.x + sin(pos*TAU)*depth
  local y = parentBody.y - cos(pos*TAU)*depth
  
  -- set Planet as metatable so functions not overridden by the instance are looked up on Planet
  local r = setmetatable(Body.new(x, y, radius, 0, color), Resource)
  
  -- VARIABLE   = VALUE
  r.parent                  = parentBody
  r.amount                  = radius*radius*PI
  r.initialRadius           = radius
  r.pos                     = pos
  r.depth                   = depth
  return r
end


function Resource:isPointInside(x,y)
  local dx = self.x - x
  local dy = self.y - y
  
  return (dx*dx + dy*dy) < (self.initialRadius*self.initialRadius)
end


-- returns how much was extracted
function Resource:decrease(decreaseAmount)
  self.amount = self.amount - decreaseAmount
  if self.amount < 0 then
    decreaseAmount = decreaseAmount+self.amount
  end
  self.radius = sqrt(self.amount/PI)
  return decreaseAmount
end


function Resource:updateCircleSegments(currentZoom)
  if not self.isVisible then return end
  
  Body.updateCircleSegments(self, currentZoom)
  
  self.initialCircleSegments = floor(self.initialRadius/currentZoom)
  if self.initialCircleSegments < 10 then
    self.initialCircleSegments = 10
  elseif self.initialCircleSegments > 500 then
    self.initialCircleSegments = 500
  end
end


function Resource:isEmpty()
  return self.amount <= 0
end


function Resource:update(dt)
  if self:isEmpty() then
    self.parent:removeResource(self)
    return
  end
  
  local currentZoom = globals.config.currentZoom
  self.isVisible = self.initialRadius*2 / currentZoom > 1
  
  Body.update(self, dt)
end


function Resource:setStatusRing(r,g,b,time, radius)
  radius = radius or self.initialRadius
  Body.setStatusRing(self, r,g,b,time,radius)
end


local lg = love.graphics
function Resource:draw()
  if not self.isVisible then return end
  lg.setColor(150,150,150)
  lg.circle("fill", self.x, self.y, self.initialRadius, self.initialCircleSegments)
  self:drawBody()
  self:drawStatRings()
end


return Resource