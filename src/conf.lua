function love.conf(t)
  t.version = "0.10.1"               -- The LÖVE version this game was made for (string)
  t.window.title = "Prepurration for Space"
  t.window.icon = nil                -- Filepath to an image to use as the window's icon (string)
  t.window.width = 1280              -- The window width (number)
  t.window.height = 720              -- The window height (number)
  t.window.borderless = false        -- Remove all border visuals from the window (boolean)
  t.window.resizable = true          -- Let the window be user-resizable (boolean)
  t.window.minwidth = 640            -- Minimum window width if the window is resizable (number)
  t.window.minheight = 360           -- Minimum window height if the window is resizable (number)
  t.window.vsync = false             -- Enable vertical sync (boolean)
  t.console = true                   -- Attach a console (boolean, Windows only)
  
  --[[
    set msaa to 16 for release
    will stay 0 for development, since it could otherwise
    hide other performance bottlenecks
  ]]--
  t.window.msaa = 16                 -- The number of samples to use with multi-sampled antialiasing (number)
  t.window.display = 1               -- Index of the monitor to show the window in (number)
    
  t.modules.joystick = false         -- Enable the joystick module (boolean)
end


local config = {
  worldseed = "This is NOT Sparta!!!",
  limitFPS = true -- "Limits" the framerate. (this is merely a debugging option; max FPS is still above 600 if set to "true")
}
return config
