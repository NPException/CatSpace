local globals = GLOBALS
local Entity = require("game.entities.Entity")

local Cat = setmetatable({}, Entity)
Cat.__index = Cat

local image, imgOffsetX, imgHeight, imgWidth, scale

local PI, TAU = math.pi, math.pi*2
local sin, cos = math.sin, math.cos
local min, max = math.min, math.max


-- position is an angle, given as floating point number between 0 an 1
function Cat.new(planet, pos, size)
  
  
  if not image then
    image = love.graphics.newImage("assets/textures/cat.png")
    imgWidth = image:getWidth()
    imgHeight = image:getHeight()
    imgOffsetX = imgWidth/2
    scale = 0.2 * (size or 1)
  end
  
  local c = setmetatable(Entity.new(planet, pos, 0, imgHeight, 15), Cat)
  c.size = size or 1
  return c
end


function Cat:calcVisibility()
  self.isVisible = image:getWidth()*scale/globals.config.currentZoom >= 2
end


function Cat:updateCustom(dt)
  -- nothing to do yet
end


local lg = love.graphics
function Cat:drawCustom()
  lg.setColor(255,255,255)
  lg.draw(image, -imgOffsetX*scale, -self.planet.radius-imgHeight*scale, 0, scale)
end

return Cat
