local game = {}

local Planet = require("game.planet.Planet")

local camera
local camFocus

local planets
local focusedPlanet

local
  shader,
  canvas,
  time,
  config

local function updateShader(w, h)
  canvas = love.graphics.newCanvas(w,h)
  canvas:setFilter("nearest","nearest")
  
  local str = love.filesystem.read('shaders/'..config.shadername..'.frag')
  shader = love.graphics.newShader(str)
  
  if (shader) then
    local inputSize = config.shadervars['inputSize']
    if inputSize then
      shader:send('inputSize', {w*inputSize, h*inputSize})
    end
    
    local outputSize = config.shadervars['outputSize']
    if outputSize then
      shader:send('outputSize', {w*outputSize, h*outputSize})
    end
    
    local textureSize = config.shadervars['textureSize']
    if textureSize then
      shader:send('textureSize', {w*textureSize, h*textureSize})
    end
  end
end

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
      local x,y = math.random(-12800,12800), math.random(-7200,7200)
      local radius = math.random(25,300)
      newPlanet = Planet.new(x,y,radius)
    until not tooClose(newPlanet)
      
    table.insert(planets, newPlanet)
  end
end

local function updateCameraFocus(worldX, worldY, scale)
  camFocus.scale = math.min(scale,(720*23)/love.window.getHeight())
  camFocus.x = (-love.window.getWidth()/2 ) * camFocus.scale + worldX
  camFocus.y = (-love.window.getHeight()/2 ) * camFocus.scale + worldY
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
  
  time = 0
  
  config = require("conf")
  
  updateShader(love.graphics.getWidth(), love.graphics.getHeight())
end


function game.keypressed(key)
  if key == "kp-" then
    initPlanets()
  end
end

--[[
local function undistort(x,y)
  local w = love.window.getWidth()
  local h = love.window.getHeight()
  
  local texW = w*config.shadervars['textureSize']
  local texH = h*config.shadervars['textureSize']
  local inW = w*config.shadervars['inputSize']
  local inH = h*config.shadervars['inputSize']
  
  local result -- we need this
  
  local coord = {x=x, x=y}
  local ratio = {x=inW/texW, y=inH/texH} -- should be 1
  local offsety = 1.0 - ratio.y

  coord.y = coord.y - offsety
  coord.y = coord.y / ratio.y
  coord.x = coord.x / ratio.x
  
    -- those four lines must be "undone"
    local coord.y = result.y + cc.y * (1.0 + dist) * dist;
    local coord.x = result.x + cc.x * (1.0 + dist) * dist;
    
    local dist = ((cc.x*cc.x) + (cc.y*cc.y)) * 0.2;
  
    local cc = {x=result.x-0.5, y=result.y-0.5}
    
  result.y = result.y * ratio.y
  result.x = result.x * ratio.x
  
  result.y = result.y + offsety
    
  return result;
end
]]--

function game.mousepressed( x, y, button )
  if (button == "l") then
    local worldX = x*camera.scaleX + camera.x
    local worldY = y*camera.scaleY + camera.y
    
    for _,planet in ipairs(planets) do
      if planet:isPointInside(worldX, worldY) then
        focusedPlanet = planet
        focusedPlanet:setStatusRing(0,0,255,0.5)
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
  
  if config.shadervars['time'] then
    shader:send('time', {time})
  end
  
  for _,planet in ipairs(planets) do
    planet:update(dt)
  end
  
  camFocus:fadeFocus(camera, dt)
end



-------------
-- DRAWING --
-------------
local lg, lw = love.graphics, love.window
function game.draw()
  lg.setCanvas(canvas)
    lg.setBackgroundColor(0,150,200)
    --lg.setBackgroundColor(0,0,0)
    lg.clear()
    
    camera:set()
      for _,p in ipairs(planets) do
        if p:isInView(camera.x, camera.y, lw.getWidth()*camera.scaleX, lw.getHeight()*camera.scaleY) then
          p:draw()
        end
      end
    camera:unset()
  lg.setCanvas()
  
  --lg.setShader(shader)
    lg.setColor(255,255,255)
    lg.draw(canvas,0,0)
  lg.setShader()
end

function game.resize(w,h)
  updateShader(w,h)
  -- update camera
  updateCameraFocus(focusedPlanet.x, focusedPlanet.y, camFocus.scale)
  camFocus:setFocus(camera)
end

return game
