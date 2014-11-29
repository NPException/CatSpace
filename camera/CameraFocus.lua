local CameraFocus = {}
CameraFocus.__index = CameraFocus

function CameraFocus.new(x,y,scale,done)
  local cf = setmetatable({}, CameraFocus)
  -- VARIABLE   = VALUE   or DEFAULT --
  cf.x          = x       or 0
  cf.y          = y       or 0
  cf.scale      = scale   or 1
  cf.done       = done    or true
  return cf
end

function CameraFocus:setFocus(camera)
  camera:setPosition(self.x,self.y)
  camera:setScale(self.scale, self.scale)
  self.done = true
end

function CameraFocus:fadeFocus(camera, dt)
  self.done = true
  
  local dx = self.x - camera.x
  local dy = self.y - camera.y
  local ds = self.scale - camera.scaleX
  
  local speed = 5
  
  local changeX = dx*dt*speed
  local changeY = dy*dt*speed
  local changeScale = ds*dt*speed
  
  local abs = math.abs
  
  if abs(changeX)+1 < abs(dx) then
    camera.x = camera.x + changeX
    self.done = false
  end
  
  if abs(changeY)+1 < abs(dy) then
    camera.y = camera.y + changeY
    self.done = false
  end
  
  if abs(changeScale)+0.001 < abs(ds) then
    camera.scaleX = camera.scaleX + changeScale
    camera.scaleY = camera.scaleY + changeScale
    self.done = false
  end
  
  if self.done then
    camera.x = self.x
    camera.y = self.y
    camera.scaleX = self.scale
    camera.scaleY = self.scale
  end
end

return CameraFocus