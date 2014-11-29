-- camera code from the Love2D wiki (modified to be a class)

local Camera = {
    x = 0,
    y = 0,
    scaleX = 1,
    scaleY = 1,
    rotation = 0
  }
Camera.__index = Camera

function Camera.new()
  return setmetatable({}, Camera)
end

local lg = love.graphics

function Camera:set()
  lg.push()
  lg.rotate(-self.rotation)
  lg.scale(1 / self.scaleX, 1 / self.scaleY)
  lg.translate(-self.x, -self.y)
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

function Camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function Camera:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function Camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

return Camera