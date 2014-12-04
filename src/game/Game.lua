local globals = GLOBALS
local Game = {}


local camera
local camFocus

local WorldGen = require("game.worldgen.WorldGenerator")

local universe
local focusedPlanet


local function updateCameraFocus(worldX, worldY, scale)
  camFocus.scale = math.min(scale,(720*23)/love.window.getHeight())
  local radius = focusedPlanet:isInView(camera) and focusedPlanet.radius or 20 -- 20 is the minimum planet radius
  local minScale = (radius*2) / (love.window.getHeight()-100)
  camFocus.scale = math.max(camFocus.scale, minScale)

  camFocus.x = (-love.window.getWidth()/2) * camFocus.scale + worldX
  camFocus.y = (-love.window.getHeight()/2) * camFocus.scale + worldY
end


local function updateCameraFocusWithMouse(scale)
  local scaleThreshold = 5*( (focusedPlanet.radius*2) / (love.window.getHeight()-100) )
  if scale < scaleThreshold and focusedPlanet:isInView(camera) then
    updateCameraFocus(focusedPlanet.x, focusedPlanet.y, scale)
    return
  end
  
  local mouseX, mouseY =  love.mouse.getPosition()
  
  local mouseWX = mouseX*camera.scale + camera.x
  local mouseWY = mouseY*camera.scale + camera.y

  camFocus.scale = math.min(scale,(720*23)/love.window.getHeight())
  local radius = focusedPlanet:isInView(camera) and focusedPlanet.radius or 20 -- 20 is the minimum planet radius
  local minScale = (radius*2) / (love.window.getHeight()-100)
  camFocus.scale = math.max(camFocus.scale, minScale)
  
  camFocus.x = mouseWX - (mouseX)*camFocus.scale
  camFocus.y = mouseWY - (mouseY)*camFocus.scale
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
end


-----------------
-- KEY PRESSED --
-----------------
function Game.keypressed(key)
  if key == "kp-" then
    universe = WorldGen.createUniverseFromSeed()
    focusedPlanet = universe.planets[1]
    updateCameraFocus(0,0, camera.scale)
  elseif key == "." or key == "kp." or key == "kp," then
    updateCameraFocus(focusedPlanet.x, focusedPlanet.y, camFocus.scale)
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

local function toWorldCoordinates(winX, winY)
  local worldX = winX*camera.scale + camera.x
  local worldY = winY*camera.scale + camera.y
  return worldX, worldY
end


-------------------
-- MOUSE PRESSED --
-------------------
function Game.mousepressed( x, y, button )
  if (button == "l") then
    local worldX, worldY = toWorldCoordinates(x,y)
    local planet = getPlanetInWorld(worldX, worldY)
    if planet then
      if focusedPlanet == planet then
        for _,resource in ipairs(focusedPlanet.resources) do
          if resource:isPointInside(worldX, worldY) and (not resource:isEmpty()) then
            resource:setStatusRing(0,255,0, 0.3)
            resource:decrease(10)
          end
        end
      else
        focusedPlanet = planet
        focusedPlanet:setStatusRing(0,0,255,0.5)
        updateCameraFocus(focusedPlanet.x,focusedPlanet.y, camFocus.scale)
      end
    end

  elseif (button == "r") then
    local worldX, worldY = toWorldCoordinates(x,y)
    local planet = getPlanetInWorld(worldX, worldY)
    if planet then
      local Cat = require("game.entities.Cat")
      local pos = math.random()
      table.insert(planet.entities, Cat.new(planet, pos, 1))
    end

  elseif (button == "wu") then
    --updateCameraFocus(focusedPlanet.x,focusedPlanet.y, camFocus.scale*0.8)
    updateCameraFocusWithMouse(camFocus.scale*0.8)

  elseif (button == "wd") then
    --updateCameraFocus(focusedPlanet.x,focusedPlanet.y, camFocus.scale*1.2)
    updateCameraFocusWithMouse(camFocus.scale*1.2)
  end
end


------------
-- UPDATE --
------------
function Game.update(dt)
  local kb = love.keyboard
  if (kb.isDown("up")) then
    camFocus:move(0, -1000*dt*camFocus.scale) 
  end
  if (kb.isDown("down")) then
    camFocus:move(0, 1000*dt*camFocus.scale) 
  end
  if (kb.isDown("left")) then
    camFocus:move(-1000*dt*camFocus.scale, 0) 
  end
  if (kb.isDown("right")) then
    camFocus:move(1000*dt*camFocus.scale, 0) 
  end

  camFocus:fadeFocus(camera, dt)

  globals.config.currentZoom = camera.scale

  for _,planet in ipairs(universe.planets) do
    planet:update(dt)
  end
end


-------------
-- DRAWING --
-------------
local lg, lw = love.graphics, love.window
local function drawDebugInfo()
  lg.setColor(0,0,0,150)
  lg.rectangle("fill",0,50,200,lw.getHeight()-50)

  local printY = 53

  local px =  function(indent)
    return 3 + (indent or 0)*15
  end

  local py =  function()
    local current = printY
    printY = printY + 20
    return current
  end

  lg.setColor(255,255,255)
  lg.print("== camera ==", px(),py())
  lg.print("zoom: "..(math.floor(camera.scale*1000)/1000), px(1),py())
  lg.print("camera x: "..math.floor(camera.x), px(1),py())
  lg.print("camera y: "..math.floor(camera.y), px(1),py())
  lg.print("focus zoom: "..(math.floor(camFocus.scale*1000)/1000), px(1),py())
  lg.print("focus x: "..math.floor(camFocus.x), px(1),py())
  lg.print("focus y: "..math.floor(camFocus.y), px(1),py())
  
  py()
  lg.print("== mouse ==", px(),py())
  local mouseX, mouseY = love.mouse.getPosition()
  lg.print("screen x:"..mouseX, px(1), py())
  lg.print("screen y:"..mouseY, px(1), py())
  mouseX, mouseY = toWorldCoordinates(mouseX, mouseY)
  lg.print("world x:"..math.floor(mouseX), px(1), py())
  lg.print("world y:"..math.floor(mouseY), px(1), py())

  py()
  local allEntities = 0
  local visibleEntities = 0
  for _,p in ipairs(universe.planets) do
    allEntities = allEntities + #p.entities
    if p:isInView(camera) then
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
  lg.print("== focused planet ==", px(),py())

  lg.print("x="..focusedPlanet.x..", y="..focusedPlanet.y, px(1), py())
  lg.print("radius: "..focusedPlanet.radius,px(1),py())
  local circleSegments = math.floor(focusedPlanet.radius/camera.scale)
  if circleSegments < 10 then
    circleSegments = 10
  elseif circleSegments > 500 then
    circleSegments = 500
  end
  lg.print("visible segments: "..circleSegments, px(1),py())
  lg.print("gravity: "..focusedPlanet.gravity,px(1),py())
  lg.print("number of entities: "..#focusedPlanet.entities,px(1),py())
  local visibleResources = 0
  
  lg.print("== resources: "..#focusedPlanet.resources.." ==", px(1),py())
  for _,res in ipairs(focusedPlanet.resources) do
    if res.isVisible then
      visibleResources = visibleResources + 1
    end
  end
  lg.print("visible: "..visibleResources, px(2),py())
  for i,res in ipairs(focusedPlanet.resources) do
    lg.print("["..i.."]: "..res.amount, px(2),py())
  end
end


function Game.draw()
  lg.setBackgroundColor(0,150,200)
  lg.clear()

  camera:set()
  if focusedPlanet then
    lg.setColor(255,255,255,50)
    lg.circle("fill",focusedPlanet.x,focusedPlanet.y,focusedPlanet.radius*2, focusedPlanet.circleSegments*2)
  end

  for _,p in ipairs(universe.planets) do
    if p:isInView(camera) then
      p:draw()
    end
  end
  camera:unset()

  if globals.debug then
    drawDebugInfo()
  end
end


function Game.resize(w,h)
  -- update camera
  updateCameraFocus(focusedPlanet.x, focusedPlanet.y, camFocus.scale)
  camFocus:setFocus(camera)
end


return Game
