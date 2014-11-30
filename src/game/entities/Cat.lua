local globals = GLOBALS
local Entity = require("game.entities.Entity")

local Cat = setmetatable({}, Entity)
Cat.__index = Cat

local PI, TAU = math.pi, math.pi*2
local sin, cos = math.sin, math.cos
local min, max = math.min, math.max


-- position is an angle, given as floating point number between 0 an 1
function Cat.new(planet, pos, h)
  local c = setmetatable(Entity.new(planet, pos, 0, h, 15), Cat)
  return c
end


function Cat:updateCustom(dt, currentZoom)
  self.isVisible = self.h*2/currentZoom >= 1
  
  -- update draw segments
  self.circleSegments = math.floor(self.h*2/currentZoom)
  if self.circleSegments < 5 then
    self.circleSegments = 5
  elseif self.circleSegments > 50 then
    self.circleSegments = 50
  end
end


local lg = love.graphics
function Cat:drawCustom()
  lg.circle("fill", 0, -self.planet.radius-self.h, self.h, self.circleSegments)
end

return Cat
