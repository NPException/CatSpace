local CameraFocus = {}
CameraFocus.__index = CameraFocus

function CameraFocus.new(x,y,scale,done)
  local cf = setmetatable({}, CameraFocus)
  -- VARIABLE   = VALUE   or DEFAULT --
  cf.x          = x       or 0
  cf.y          = y       or 0
  cf.scale      = scale   or 1
  return cf
end

function CameraFocus:move(dx,dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function CameraFocus:setFocus(camera)
  camera:setPosition(self.x,self.y)
  camera:setScale(self.scale)
end

function CameraFocus:fadeFocus(camera, dt)
  local dx = self.x - camera.x
  local dy = self.y - camera.y
  local ds = self.scale - camera.scale
  
  local speed = 5
  
  local changeX = dx*dt*speed
  local changeY = dy*dt*speed
  local changeScale = ds*dt*speed
  
  camera.x = camera.x + changeX
  camera.y = camera.y + changeY
  camera.scale = camera.scale + changeScale
end

return CameraFocus