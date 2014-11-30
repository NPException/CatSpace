local globals = GLOBALS
local Game = {}


local camera
local camFocus

local WorldGen = require("game.worldgen.WorldGenerator")

local universe
local focusedPlanet

local
  time,
  config


local function updateCameraFocus(worldX, worldY, scale)
  camFocus.scale = math.min(scale,(720*23)/love.window.getHeight())
  local minScale = (focusedPlanet.radius*2) / (love.window.getHeight()-100)
  camFocus.scale = math.max(camFocus.scale, minScale)
  camFocus.x = (-love.window.getWidth()/2 ) * camFocus.scale + worldX
  camFocus.y = (-love.window.getHeight()/2 ) * camFocus.scale + worldY
  camFocus.done = false
end


--------------------
-- INITIALIZATION --
--------------------
function Game.load()  
  universe = WorldGen.createUniverseFromSeed(globals.config.worldseed)
  focusedPlanet = universe.planets[1]
  
  -- init camera
  camera = require("camera.Camera").new()
  camFocus = require("camera.CameraFocus").new()
  updateCameraFocus(0,0, 1)
  camFocus:setFocus(camera)
  
  time = 0
end


-----------------
-- KEY PRESSED --
-----------------
function Game.keypressed(key)
  if key == "kp-" then
    universe = WorldGen.createUniverseFromSeed()
    focusedPlanet = universe.planets[1]
    updateCameraFocus(0,0, camera.scaleX)
  end
end


local function getPlanetInWorld(worldX, worldY)
  for _,planet in ipairs(universe.planets) do
    if planet:isPointInside(worldX, worldY) then
      return planet
    end
  end
  return nil
end


local function getPlanetOnScreen(x,y)
  local worldX = x*camera.scaleX + camera.x
  local worldY = y*camera.scaleY + camera.y
  return getPlanetInWorld(worldX, worldY)
end


-------------------
-- MOUSE PRESSED --
-------------------
function Game.mousepressed( x, y, button )
  if (button == "l") then
    local planet = getPlanetOnScreen(x, y)
    if planet then
      focusedPlanet = planet
      focusedPlanet:setStatusRing(0,0,255,0.5)
      updateCameraFocus(focusedPlanet.x,focusedPlanet.y, camFocus.scale)
    end
    
  elseif (button == "r") then
    local planet = getPlanetOnScreen(x, y)
    if planet then
      local Cat = require("game.entities.Cat")
      table.insert(planet.entities, Cat.new(planet,0,5))
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
function Game.update(dt)
  time = time + dt
  
  local kb = love.keyboard
  if (kb.isDown("up")) then
    camFocus:move(0, -1000*dt) 
  end
  if (kb.isDown("down")) then
    camFocus:move(0, 1000*dt) 
  end
  if (kb.isDown("left")) then
    camFocus:move(-1000*dt, 0) 
  end
  if (kb.isDown("right")) then
    camFocus:move(1000*dt, 0) 
  end
  
  for _,planet in ipairs(universe.planets) do
    planet:update(dt, camera.scaleX)
  end
  
  camFocus:fadeFocus(camera, dt)
end


-------------
-- DRAWING --
-------------
local lg, lw = love.graphics, love.window
function Game.draw()
  lg.setBackgroundColor(0,150,200)
  --lg.setBackgroundColor(0,0,0)
  lg.clear()
  
  camera:set()
    if focusedPlanet then
      lg.setColor(255,255,255,50)
      lg.circle("fill",focusedPlanet.x,focusedPlanet.y,focusedPlanet.radius*2, focusedPlanet.circleSegments*2)
    end
  
    for _,p in ipairs(universe.planets) do
      if p:isInView(camera.x, camera.y, lw.getWidth()*camera.scaleX, lw.getHeight()*camera.scaleY) then
        p:draw()
      end
    end
  camera:unset()
  
  if globals.debug then
    lg.setColor(0,0,0,150)
    lg.rectangle("fill",0,100,200,620)
    
    local printY = 103
    
    local px =  function(indent)
                  return 3 + (indent or 0)*15
                end
    
    local py =  function()
                  local current = printY
                  printY = printY + 20
                  return current
                end
    
    lg.setColor(255,255,255)
    lg.print("zoom: "..(math.floor(camera.scaleX*1000)/1000), px(),py())
    
    py()
    local allEntities = 0
    local visibleEntities = 0
    for _,p in ipairs(universe.planets) do
      allEntities = allEntities + #p.entities
      if p:isInView(camera.x, camera.y, lw.getWidth()*camera.scaleX, lw.getHeight()*camera.scaleY) then
        for _,e in ipairs(p.entities) do
          if e.isVisible then
            visibleEntities = visibleEntities + 1
          end
        end
      end
    end
    lg.print("overall entities: "..allEntities, px(),py())
    lg.print("visible entities: "..visibleEntities, px(),py())
    
    -- focused planet debug
    py()
    lg.print("FOCUSED PLANET", px(),py())
    
    lg.print("x="..focusedPlanet.x..", y="..focusedPlanet.y, px(1), py())
    lg.print("radius: "..focusedPlanet.radius,px(1),py())
    local circleSegments = math.floor(focusedPlanet.radius/camera.scaleX)
    if circleSegments < 10 then
      circleSegments = 10
    elseif circleSegments > 500 then
      circleSegments = 500
    end
    lg.print("visible segments: "..circleSegments, px(1),py())
    lg.print("gravity: "..focusedPlanet.gravity,px(1),py())
    lg.print("number of entities: "..#focusedPlanet.entities,px(1),py())
  end
end

function Game.resize(w,h)
  -- update camera
  updateCameraFocus(focusedPlanet.x, focusedPlanet.y, camFocus.scale)
  camFocus:setFocus(camera)
end

return Game
