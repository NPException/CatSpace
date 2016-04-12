-- camera code from the Love2D wiki (modified to be a class)

local Camera = {
    x = 0,
    y = 0,
    scale = 1,
    rotation = 0
  }
Camera.__index = Camera

function Camera.new()
  return setmetatable({}, Camera)
end

local globals = GLOBALS
local lg = love.graphics

function Camera:set()
  lg.push()
  lg.rotate(-self.rotation)
  lg.scale(1 / self.scale, 1 / self.scale)
  lg.translate(-self.x + (globals.window.width/2)*self.scale, -self.y + (globals.window.height/2)*self.scale)
end

function Camera:unset()
  lg.pop()
end

function Camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function Camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function Camera:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function Camera:setScale(s)
  self.scale = s or self.scale
end

return Camera