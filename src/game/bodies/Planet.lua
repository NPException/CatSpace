local globals = GLOBALS
local Body = require("game.bodies.Body")
local Planet = setmetatable({}, Body)
Planet.__index = Planet


-- Planet class method new
function Planet.new(x, y, radius, gravity)
  -- set Planet as metatable so functions not overridden by the instance are looked up on Planet
  local p = setmetatable(Body.new(x, y, radius, gravity, {255,255,255}), Planet)
  
  -- VARIABLE   = VALUE       or DEFAULT --
  p.entities    = {}
  return p
end


function Planet:update(dt)
  -- super call
  Body.update(self, dt)
  
  -- update entities
  for _,e in ipairs(self.entities) do
    e:update(dt)
  end
end

local lg = love.graphics
function Planet:draw()
  self:drawBody()
  self:drawResources()
  for _,e in ipairs(self.entities) do
    e:draw()
  end
  self:drawStatRings()
end


return Planet