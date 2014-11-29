local game = {}

local Planet = require("game.planet.Planet")

local camera
local camFocus

local planets

local focusedPlanet


local function initPlanets()
  planets = {
    Planet.new()
  }
  
  focusedPlanet = planets[1]
  
  local tooClose = function(planet)
    local result = false
    local minDist = 100.0
    for _,p in ipairs(planets) do
      if planet:surfaceDistance(p) < minDist then
        result = true
        break
      end
    end
    return result
  end
  
  for i=1,math.random(50,100) do
    local newPlanet    
    repeat
      local x,y = math.random(-10000,10000), math.random(-10000,10000)
      local radius = math.random(25,300)
      newPlanet = Planet.new(x,y,radius)
    until not tooClose(newPlanet)
      
    table.insert(planets, newPlanet)
  end
end

local function updateCameraFocus(worldX, worldY, scale)
  camFocus.scale = scale
  camFocus.x = (-love.window.getWidth()/2 ) *scale + worldX
  camFocus.y = (-love.window.getHeight()/2 ) *scale + worldY
  camFocus.done = false
end

--------------------
-- INITIALIZATION --
--------------------
function game.load()
  -- init camera
  camera = require("camera.Camera").new()
  camFocus = require("camera.CameraFocus").new()
  updateCameraFocus(0,0, 1)
  camFocus:setFocus(camera)
  
  initPlanets()
end


function game.keypressed(key)
  if key == "kp-" then
    initPlanets()
  end
end

function game.mousepressed( x, y, button )
  if (button == "l") then
    local worldX = x*camera.scaleX + camera.x
    local worldY = y*camera.scaleY + camera.y
    
    for _,planet in ipairs(planets) do
      if planet:isPointInside(worldX, worldY) then
        focusedPlanet = planet
        focusedPlanet:setHurt()
        updateCameraFocus(focusedPlanet.x,focusedPlanet.y, camFocus.scale)
        break
      end
    end
    
  elseif (button == "wu") then
    updateCameraFocus(focusedPlanet.x,focusedPlanet.y, camFocus.scale*0.8)
  elseif (button == "wd") then
    updateCameraFocus(focusedPlanet.x,focusedPlanet.y, camFocus.scale*1.2)
  end
end


------------
-- UPDATE --
------------
function game.update(dt)
  for _,planet in ipairs(planets) do
    planet:update(dt)
  end
  
  if (not camFocus.done) then
    camFocus:fadeFocus(camera, dt)
  end
end


-------------
-- DRAWING --
-------------
function game.draw()
  camera:set()
  
  for _,p in ipairs(planets) do
    p:draw()
  end
  
  camera:unset()
end

function game.resize(w,h)
  -- update camera
  updateCameraFocus(focusedPlanet.x, focusedPlanet.y, camFocus.scale)
  camFocus:setFocus(camera)
end

return game
