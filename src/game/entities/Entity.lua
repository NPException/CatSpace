local globals = GLOBALS

local Entity = {}
Entity.__index = Entity

local PI, TAU = math.pi, math.pi*2
local sin, cos = math.sin, math.cos
local min, max = math.min, math.max


-- position is an angle, given as floating point number between 0 an 1
function Entity.new(planet, pos, w, h, speed)
  local e = setmetatable({}, Entity)
  
  -- VARIABLE   = VALUE       or DEFAULT --
  e.planet      = planet      or nil
  e.pos         = pos         or 0
  e.w           = w           or 1
  e.h           = h           or 2
  e.speed       = speed       or 10
  
  e.pos = e.pos % 1
  
  e.isVisible = true
  
  return e
end


function Entity:move(distance)
  local angle = (distance*0.5) / (PI*self.planet.radius) -- angle difference
  self.pos = (self.pos + angle) % 1
end


function Entity:calcVisibility(currentZoom)
  self.isVisible = (max(self.w,self.h)/currentZoom >= 1)
end


function Entity:update(dt)
  self:move(self.speed*dt)
  
  if self.updateCustom then
    self:updateCustom(dt)
  end
    
  self:calcVisibility(globals.config.currentZoom)
end

local lg = love.graphics
function Entity:draw()
  if not self.isVisible then return end
  
  lg.push()
    lg.setColor(255,255,255)
    lg.translate(self.planet.x, self.planet.y)
    lg.rotate(self.pos*TAU)
    if self.drawCustom then
      self:drawCustom()
    else
      lg.rectangle("fill", -self.w*0.5, -self.planet.radius-self.h, self.w, self.h)
    end
  lg.pop()
end


return Entity
