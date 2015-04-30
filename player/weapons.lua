local vector = require 'vecturr'

local lg = love.graphics
local lm = love.mouse

local weapons = {}
c = function(t)
  return setmetatable(t, {__index = weapons})
end
weapons.list = {"gun", "uzi", "sniper", "shotgun", "laser"}
weapons.gun = {name = "Handgun",         damage = 25,  duration = .3,   rate = 2,  spread = .06, bullets = 1,  pierce = 1,  autofire = false}
weapons.uzi = {name = "Uzi",             damage = 4,   duration = 1/15, rate = 15, spread = .1,  bullets = 1,  pierce = 1,  autofire = true}
weapons.sniper = {name = "Sniper rifle", damage = 100, duration = 1,    rate = .5, spread = 0,   bullets = 1,  pierce = 1,  autofire = false}
weapons.shotgun = {name = "Shotgun",     damage = 5,   duration = 1,    rate = 1,  spread = .2,  bullets = 15, pierce = 1,  autofire = false}
weapons.laser = {name = "Laser",         damage = 20,  duration = .25,  rate = .5, spread = .05, bullets = 1,  pierce = 10, autofire = true}


weapons.lines = {}

weapons.current = c{timer = math.huge, rate = 1}

local p
weapons.setPlayer = function(self, player)
  p = player
end

weapons.set = function(self, name)
  if self.current.timer < 1/self.current.rate then return end

  if tonumber(name) then name = self.list[tonumber(name)] end

  local new = self[name]
  self.current.name = new.name
  self.current.damage = new.damage*p.damage
  self.current.duration = new.duration
  self.current.rate = new.rate
  self.current.autofire = new.autofire
  self.current.spread = new.spread
  self.current.bullets = new.bullets
  self.current.pierce = new.pierce
end


weapons.update = function(self, dt)
  if self.current.autofire and self.current.timer > 1/self.current.rate and lm.isDown 'l' then
    self.lines = {}
    for i = 1, self.current.bullets do
      self:shoot(lm.getPosition())
    end
  end
  self.current.timer = self.current.timer + dt
end


weapons.draw = function(self)
  if self.current.timer < self.current.duration then
    lg.setColor(255,255,255, (1-self.current.timer/self.current.duration)*255)
    for i, v in ipairs(self.lines) do
      local x1, y1, x2, y2 = v:unpack()
      lg.line(x2 and x1 or 0, y2 and y1 or 0, x2 or x1, y2 or y1)
    end
    --local v = vector(self.shot.px, self.shot.py, self.shot.x, self.shot.y)  % (self.shot.distance or 1100)

  end
end


weapons.shoot = function(self, x, y)
  self.current.timer = 0
  local cameraX, cameraY = game.camera:getPosition()
  x = x - cameraX
  y = y - cameraY
  local ray = vector(p.x, p.y, x, y)
  local angle = ray:angle() + (love.math.random()*self.current.spread-self.current.spread/2)*math.pi*p.spread
  local l = ray:length()
  ray(p.x, p.y, p.x + math.cos(angle), p.y + math.sin(angle))
  ray:scaleTo(l)
  x = ray.x2
  y = ray.y2

  self.shot = {x = x, y = y, px = p.x, py = p.y}
  local targets = {}
  for i, enemy in ipairs(game.enemies) do
    local rayStart = vector(p.x, p.y)
    local rayEnd = vector(x, y)
    local Enemy = vector(enemy.position.x, enemy.position.y)
    local d = rayEnd - rayStart
    local f = rayStart - Enemy

    local a = d*d
    local b = 2*(f*d)
    local c = f*f - enemy.r*enemy.r

    local Delta = b*b - 4*a*c

    if Delta >= 0 then
      local pos1 = (-b - Delta^.5)/(2*a)
      local pos2 = (-b + Delta^.5)/(2*a)
      if (0 <= pos1) or (0 <= pos2) then
        targets[#targets+1] = enemy
        --enemy.distance = vector(p.x, p.y, enemy.position.x, enemy.position.y):length()
        enemy.distance = vector(p.x, p.y, x, y):length()*pos1
      end
    end
  end

  table.sort(targets, function(a, b) return a.distance > b.distance end)
  while targets[#targets] and targets[#targets].dead do
    table.remove(targets, #targets)
  end
  if targets[#targets] then
    local lastTarget
    local pierce = self.current.pierce
    while pierce >= 1 and targets[#targets] do
      targets[#targets]:hit(self.current.damage)
      lastTarget = targets[#targets]
      pierce = pierce - 1
      table.remove(targets, #targets)
    end
    local line
    if pierce == 0 then
      line = vector(p.x, p.y, x, y)%lastTarget.distance
    else
      line = vector(p.x, p.y, x, y)%1100
    end
    self.lines[#self.lines+1] = line
  else
    self.lines[#self.lines+1] = vector(p.x, p.y, x, y)%1100
  end
end


weapons.mousepressed = function(self, x, y, b)

  if not self.current.autofire and self.current.timer > 1/self.current.rate and b == 'l' then
    self.lines = {}
    for i = 1, self.current.bullets do
      self:shoot(lm.getPosition())
    end
  end

end

return weapons