local camera = {}
camera.shake = {
  offset = {x = 0, y = 0},
  timer = 0,
  intensity = 0,
  duration = 1
}

local W, H = love.window.getDimensions()
camera.viewport = {W,H}

camera.setViewport = function(self, x, y)
  self.viewport.x = x or self.viewport.x or W
  self.viewport.y = y or self.viewport.y or H
end

camera.follow = function(self, p)
  self.following = p
end

camera.set = function(self)
  love.graphics.translate(self:getPosition())
end

camera.unset = function(self)
  local x, y = self:getPosition()
  love.graphics.translate(-x, -y)
end

setmetatable(camera.shake, {__call = function(self, i, duration)
  self.intensity = self.intensity + i
  self.timer = duration or .5
  self.duration = self.timer
end})

camera.update = function(self, dt)
  self.shake.timer = self.shake.timer - dt
  local i = self.shake.intensity * self.shake.timer / self.shake.duration
  if i < 0 then
    i = 0
    self.shake.intensity = 0
    self.shake.timer = 0
    self.shake.duration = 1
  end
  local a = love.math.random() * math.pi * 2
  self.shake.offset = {x = math.cos(a)*i, y = math.sin(a)*i}
end

camera.getPosition = function(self)
  return -self.following.x- self.shake.offset.x+self.viewport.x/2, -self.following.y- self.shake.offset.y+self.viewport.y/2
end

return camera