local globals = GLOBALS
local Entity = require("game.entities.Entity")

local Cat = setmetatable({}, Entity)
Cat.__index = Cat

local image, imgOffsetX, imgHeight

local PI, TAU = math.pi, math.pi*2
local sin, cos = math.sin, math.cos
local min, max = math.min, math.max


-- position is an angle, given as floating point number between 0 an 1
function Cat.new(planet, pos)
  if not image then
    image = love.graphics.newImage("assets/textures/cat.png")
    imgOffsetX = image:getWidth()/2
    imgHeight = image:getHeight()
  end
  
  local c = setmetatable(Entity.new(planet, pos, 0, imgHeight, 15), Cat)
  return c
end


function Cat:updateCustom(dt, currentZoom)
  self.isVisible = image:getWidth()/currentZoom >= 1
end


local lg = love.graphics
function Cat:drawCustom()
  --lg.circle("fill", 0, -self.planet.radius-self.h, self.h, self.circleSegments)
  lg.draw(image, -imgOffsetX, -self.planet.radius-imgHeight)
end

return Cat
