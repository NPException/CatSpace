local globals = GLOBALS
local Body = require("game.bodies.Body")
local Planet = setmetatable({}, Body)
Planet.__index = Planet


local Entity = require("game.entities.Entity")

local min = math.min
local max = math.max
local sqrt = math.sqrt
local floor = math.floor

-- Planet class method new
function Planet.new(x, y, radius, gravity)
  -- set Planet as metatable so functions not overridden by the instance are looked up on Planet
  local p = setmetatable(Body.new(x, y, radius, gravity, {255,255,255}), Planet)
  
  -- VARIABLE   = VALUE       or DEFAULT --
  p.entities    = {}
  return p
end


function Planet:updateCustom(dt, currentZoom)
  -- update entities
  for _,e in ipairs(self.entities) do
    e:update(dt, currentZoom)
  end
end

local lg = love.graphics
function Planet:draw()
  self:drawBody()
  for _,e in ipairs(self.entities) do
    e:draw()
  end
  self:drawStatRings()
end


return Planet