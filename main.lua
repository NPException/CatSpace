
-- main variables
local
  debug,
  fps,
  mspf

-- LOAD --
function love.load(arg)
  debug = false
  
  love.graphics.setDefaultFilter("nearest","nearest")
  love.graphics.setBackgroundColor(0,100,150)
end

-- KEYPRESSED --
function love.keypressed(key)
  if (key == "kp+") then
    debug = not debug
  end
  
  if (debug) then
    print(key)
  end
end

-- UPDATE --
function love.update(dt)
  
  if (debug) then
    fps = love.timer.getFPS()
    mspf = math.floor(100000/fps)/100
  end
end

-- DRAW --
function love.draw()
  -- draw stuff
  if (debug) then
    love.graphics.setColor(0,0,0,128)
    love.graphics.rectangle("fill",0,0,100,40)
    love.graphics.setColor(255,255,255)
    love.graphics.print("FPS:  "..fps, 5,5)
    love.graphics.print("msPF: "..mspf, 5,20)
  end
end