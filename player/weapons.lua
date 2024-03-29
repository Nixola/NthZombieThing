local vector = require 'vecturr'
local camera = require 'camera'
local enemies = require 'enemies'

local lg = love.graphics
local lm = love.mouse

local weapons = {}
c = function(t)
  return setmetatable(t, {__index = weapons})
end
weapons.list = {"gun", "uzi", "sniper", "shotgun", "laser", "explosion",
                gun=1, uzi=2, sniper=3, shotgun=4, laser=5, explosion = 6}
weapons.gun = {name = "Handgun",         damage = 25,  magazine = 6,   reload = 1.5, duration = .3,   rate = 2,  spread = .06,                                           critical = {chance = .1, damage = 1.5},  level = 0, autofire = false, knockback = 200,  continuous = false} -- Handgun
weapons.uzi = {name = "Uzi",             damage = 4,   magazine = 30,  reload = 1,   duration = 1/15, rate = 15, spread = .1,                                            critical = {chance = .08, damage = 2},   level = 0, autofire = true,  knockback = 100,  continuous = false}  -- Uzi
weapons.sniper = {name = "Sniper rifle", damage = 80,  magazine = 4,   reload = 2,   duration = 1,    rate = .5, spread = .03,                pierce = {n = 5,  d = .5}, critical = {chance = .2, damage = 3},    level = 0, autofire = false, knockback = 1100, continuous = false} -- Sniper rifle
weapons.shotgun = {name = "Shotgun",     damage = 5,   magazine = 75,  reload = 1.5, duration = 1,    rate = 1,  spread = .2,  bullets = 15,                             critical = {chance = .08, damage = 1.5}, level = 0, autofire = false, knockback = 220,  continuous = false} -- Shotgun
weapons.laser = {name = "Laser",         damage = 30,  magazine = 100, reload = 1.5, duration = 0,    rate = 0,  spread = .01,                pierce = {n = 10, d = 1},  critical = {chance = 0, damage = 1},     level = 0, autofire = true,  knockback = 14,   continuous = 66.666}  -- Laser
weapons.explosion = {name = "Explosion", damage = 1, magazine = 1, reload = 5, duration = 2, rate = 1, exploding=256, pierce = { n = 6/0, d = 1}, critical = {chance = 1, damage = 1}, level = 0, autofire = false, knockback = 1000, target = "player"} --explosion

weapons.lines = {}
weapons.circles = {}

weapons.current = c{timer = math.huge, rate = 1}

local p
weapons.setPlayer = function(self, player)
  p = player
end

weapons.set = function(self, name)
  if (self.current.timer < 1/self.current.rate and not self.current.continuous) or self.current.reloading then return end

  if tonumber(name) then name = self.list[tonumber(name)] end
  self.lines = {}
  self.circles = {}
  local new = self[name]
  self.current.name = new.name
  self.current.id = self.list[name]
  self.current.damage = new.damage*p.damage
  self.current.duration = new.duration
  self.current.rate = new.rate
  self.current.autofire = new.autofire
  self.current.spread = new.spread
  self.current.bullets = new.bullets or 1
  self.current.pierce = new.pierce or {n = 1, d = 1}
  self.current.critical = new.critical
  self.current.magazine = new.magazine
  self.current.ammo = new.magazine
  self.current.reload = new.reload
  self.current.level = new.level
  self.current.continuous = new.continuous
  self.current.knockback = new.knockback
  self.current.exploding = new.exploding
  self.current.target = new.target or "pointer"

  p.hud.weapons:draw()
end


weapons.update = function(self, dt)
  if (self.current.autofire and self.current.timer > 1/self.current.rate or self.current.continuous) and lm.isDown((love.vM == 0 and love.vm == 9) and 'l' or 1) and not self.current.reloading then
    self.lines = {}
    self.circles = {}
    for i = 1, self.current.bullets do
      self:shoot(dt, lm.getPosition())
    end
    self.current.shooting = true
  else
    self.current.shooting = false
  end
  self.current.timer = self.current.timer + dt
  self.current.reloading = self.current.reloading and self.current.reloading - dt
  if self.current.reloading and self.current.reloading <= 0 then
    self.current.reloading = false
    self.current.ammo = self.current.magazine
  end
end


weapons.draw = function(self)
  if self.current.timer < self.current.duration or (self.current.continuous and self.current.shooting) then
    lg.setLineWidth(1)
    ---[[
    local C = {}
    local nonC = {}

    local alpha = self.current.continuous and 1 or (1-self.current.timer/self.current.duration)^2

    for i, v in ipairs(self.lines) do
      local t = v.critical and C or nonC
      local x1,y1,x2,y2 = v:unpack()
      x1 = x2 and x1 or 0
      y1 = y2 and y1 or 0
      x2 = x2 or x1
      y2 = y2 or y1
      local l = #t
      t[l+1] = x1
      t[l+2] = y1
      t[l+3] = x2
      t[l+4] = y2
    end
    if C[1] then
      C[#C+1] = C[1]
      C[#C+1] = C[2]
      lg.setColor(1,0,0,alpha)
      lg.line(C)
    end
    if nonC[1] then
      nonC[#nonC+1] = nonC[1]
      nonC[#nonC+1] = nonC[2]
      lg.setColor(1,1,1,alpha)
      lg.line(nonC)
    end

    for i, v in ipairs(self.circles) do
      local r = v.r * (self.current.timer / self.current.duration)^0.03
      lg.setColor(1, 1, 1, alpha)
      love.graphics.circle("fill", v.x, v.y, r, r*4)
    end
  end

end


weapons.shoot = function(self, dt, x, y)
  dt = self.current.continuous and dt or 1
  if self.current.reloading then return end
  self.current.ammo = self.current.ammo - dt * (self.current.continuous or 1)
  if self.current.ammo <= 0 then
    self.current.reloading = self.current.reload
  end
  self.current.timer = 0
  if self.current.target == "pointer" then
    local cameraX, cameraY = camera:getPosition()
    x = x - cameraX
    y = y - cameraY
  elseif self.current.target == "player" then
    x = p.x
    y = p.y
  end
  local targets = {}

  if self.current.exploding then
    self.circles[#self.circles+1] = {x = x, y = y, r = self.current.exploding, critical = false}
    for i, enemy in ipairs(enemies) do
      local d = vector(x, y, enemy.position.x, enemy.position.y)
      if d:length() < self.current.exploding then
        targets[#targets+1] = enemy
	enemy.distance = d:length()
      end
    end
  else
    local ray = vector(p.x, p.y, x, y)
    local angle = ray:angle() + (love.math.random()*self.current.spread-self.current.spread/2)*math.pi*p.spread
    local l = ray:length()
    ray(p.x, p.y, p.x + math.cos(angle), p.y + math.sin(angle))
    ray:scaleTo(l)
    x = ray.x2
    y = ray.y2

    self.shot = {x = x, y = y, px = p.x, py = p.y}
    for i, enemy in ipairs(enemies) do
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
          enemy.distance = vector(p.x, p.y, x, y):length()*pos1
        end
      end

    end
  end

  table.sort(targets, function(a, b) return a.distance > b.distance end)
  while targets[#targets] and targets[#targets].dead do
    table.remove(targets, #targets)
  end

  local Odamage, critical = self.current.damage, false
  if love.math.random() <= self.current.critical.chance*p.critical.chance then      
    Odamage = Odamage * self.current.critical.damage * p.critical.damage
    critical = true
  end

  if targets[#targets] then
    local lastTarget
    local pierce = self.current.pierce.n
    local damage = self.current.pierce.d
    local knock  = self.current.knockback

    local d = 1

    while pierce >= 1 and targets[#targets] do
      targets[#targets]:hit(Odamage*d*dt, p.x, p.y, knock)
      d = d * damage
      lastTarget = targets[#targets]
      pierce = pierce - 1
      table.remove(targets, #targets)
    end

    local line
    if pierce == 0 then
      line = vector(p.x, p.y, x, y)%lastTarget.distance
    else
      line = vector(p.x, p.y, x, y)% 1100
    end
    line.critical = critical
    self.lines[#self.lines+1] = line
  else
    self.lines[#self.lines+1] = vector(p.x, p.y, x, y)% 1100
  end
end


weapons.mousepressed = function(self, x, y, b)
  if not self.current.autofire and self.current.timer > 1/self.current.rate and (b == ((love.vM == 0 and love.vm == 9) and 'l' or 1)) and not self.current.reloading then
    self.lines = {}
    self.circles = {}
    for i = 1, self.current.bullets do
      self:shoot(1, lm.getPosition())
    end
  end

end

return weapons
