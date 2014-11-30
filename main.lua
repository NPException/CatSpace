-- global variables
GLOBALS = { debug = false }
local globals = GLOBALS
string.hash = require("lib.stringhash")

-- main variables
local
  fps,
  mspf

local state

-- LOAD --
function love.load(arg)
  globals.debug = false
  globals.config = require("conf")
  
  love.graphics.setDefaultFilter("nearest","nearest")
  love.graphics.setBackgroundColor(0,100,150)
  
  state = require("game.Game")
  state.load()
end

-- KEYPRESSED --
function love.keypressed(key)
  if (key == "kp+") then
    globals.debug = not globals.debug
  elseif (key == "escape") then
    love.event.quit()
  elseif (key == "return") then
    if (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
      love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
    end
  end
  
  if state.keypressed then
    state.keypressed(key)
  end
end

function love.mousepressed( x, y, button )
  if state.mousepressed then
    state.mousepressed(x, y, button)
  end
end

-- UPDATE --
function love.update(dt)
  state.update(dt)
  
  if (globals.debug) then
    fps = love.timer.getFPS()
    mspf = math.floor(100000/fps)/100
  end
end

-- DRAW --
function love.draw()
  state.draw()
  
  if (globals.debug) then
    love.graphics.setColor(0,0,0,128)
    love.graphics.rectangle("fill",0,0,100,40)
    love.graphics.setColor(255,255,255)
    love.graphics.print("FPS:  "..fps, 5,5)
    love.graphics.print("msPF: "..mspf, 5,20)
  end
end

function love.resize(w,h)
  if state.resize then
    state.resize(w,h)
  end
end