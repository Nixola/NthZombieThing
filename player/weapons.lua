local vector = require 'vecturr'

local lg = love.graphics
local lm = love.mouse

local weapons = {}
c = function(t)
  return setmetatable(t, {__index = weapons})
end
weapons.list = {"gun", "uzi", "sniper"}
weapons.gun = {name = "Handgun",         damage = 20,  duration = .3,   rate = 2,    spread = .02, autofire = false}
weapons.uzi = {name = "Uzi",             damage = 20,   duration = 1/15, rate = 15,   spread = .05, autofire = true}
weapons.sniper = {name = "Sniper rifle", damage = 100, duration = 1,    rate = 2/3,  spread = 0,   autofire = false}

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
end


weapons.update = function(self, dt)
  if self.current.autofire and self.current.timer > 1/self.current.rate and lm.isDown 'l' then
    self:shoot(lm.getPosition())
  end
  self.current.timer = self.current.timer + dt
end


weapons.draw = function(self)
  if self.current.timer < self.current.duration then
    lg.setColor(255,255,255, (1-self.current.timer/self.current.duration)*255)
    local v = vector(self.shot.px, self.shot.py, self.shot.x, self.shot.y)  % (self.shot.distance or 1100)
    local x1, y1, x2, y2 = v:unpack()
    lg.line(x2 and x1 or 0, y2 and y1 or 0, x2 or x1, y2 or y1)
  end
end


weapons.shoot = function(self, x, y)
  self.current.timer = 0
  local cameraX, cameraY = game.camera:getPosition()
  x = x - cameraX
  y = y - cameraY
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
        enemy.distance = vector(p.x, p.y, enemy.position.x, enemy.position.y):length()
      end
    end
  end

  table.sort(targets, function(a, b) return a.distance < b.distance end)
  if targets[1] then 
    targets[1]:hit(self.current.damage)
    self.shot.distance = targets[1].distance
  end
end

return weapons