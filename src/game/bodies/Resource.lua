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
  local r = setmetatable(Body.new(x, y, radius, 0, {150,150,150}), Resource)

  -- VARIABLE   = VALUE
  r.parent                  = parentBody
  r.amount                  = radius*radius*PI
  r.amountRadius            = radius
  r.resColor                = color
  r.pos                     = pos
  r.depth                   = depth
  return r
end


-- returns how much was extracted
function Resource:decrease(decreaseAmount)
  self.amount = self.amount - decreaseAmount
  if self.amount < 0 then
    decreaseAmount = decreaseAmount+self.amount
  end
  self.amountRadius = sqrt(self.amount/PI)
  return decreaseAmount
end


function Resource:updateCircleSegments()
  if not self.isVisible then return end

  local currentZoom = globals.config.currentZoom
  Body.updateCircleSegments(self, currentZoom)

  self.amountCircleSegments = floor(self.amountRadius/currentZoom)
  if self.amountCircleSegments < 10 then
    self.amountCircleSegments = 10
  elseif self.amountCircleSegments > 500 then
    self.amountCircleSegments = 500
  end
end


function Resource:isEmpty()
  return self.amount <= 0
end


function Resource:update(dt)
--  if self:isEmpty() then
--    self.parent:removeResource(self)
--    return
--  end

  self.isVisible = self.radius*2 / globals.config.currentZoom > 1

  Body.update(self, dt)
end


local lg = love.graphics
function Resource:draw()
  if not self.isVisible then return end
  self:drawBody()
  if not self:isEmpty() then
    lg.setColor(self.resColor)
    lg.circle("fill", self.x, self.y, self.amountRadius, self.amountCircleSegments)
  end
  self:drawStatRings()
end


return Resource