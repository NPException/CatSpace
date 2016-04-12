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
  local min, max = 2, 5
  local size = image:getWidth()*scale/globals.config.currentZoom;
  self.isVisible = size >= min
  
  if size > max then
    self.alpha = 255
  else
    size = size - min
    self.alpha = size <= 0 and 0 or (255 * (size/ (max-min)))
  end
end


function Cat:updateCustom(dt)
  self.x = self.planet.x + sin(self.pos*TAU)*self.planet.radius
  self.y = self.planet.y - cos(self.pos*TAU)*self.planet.radius
end


local lg = love.graphics
function Cat:drawCustom()
  lg.setColor(255,255,255, self.alpha)
  lg.draw(image, -imgOffsetX*scale, -self.planet.radius-imgHeight*scale, 0, scale)
end

return Cat
