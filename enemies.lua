local vector = require 'vecturr'
local drops = require 'drops'
local lg = love.graphics

local circleColl = function(x1,y1,r1, x2,y2,r2)
  return (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1) <= (r2+r1)*(r2+r1)
end

local enemies = {}
local enemy = enemies
local W, H = love.graphics.getDimensions()
local p

enemies.particles = {}

enemies.load = function(self)

  enemies.color = {16, 92, 16}
  enemies.level = 1
  enemies.damping = 0.1
  enemies.type = {
    base = setmetatable({
      hp = 90,
      damage = 11,
      damageSpread = .2,
      maxSpeed = 80,
      acceleration = 130,
      r = 18
    }, {__index = self}),

    small = setmetatable({
      hp = 20,
      damage = 5,
      damageSpread = .3,
      maxSpeed = 300,
      acceleration = 300,
      r = 9
    }, {__index = self}),

    psion = setmetatable({
      hp = 40,
      shields = 100,
      recharge = {
        delay = 3,
        rate = 25
      },
      damage = 15,
      damageSpread = 0,
      maxSpeed = 100,
      acceleration = 150,
      r = 18,
      color = {32, 184, 184}
    }, {__index = self})
  }
  enemy.types = {
    "base", "base", "base", "base", "base", "base",
    "small", 
    "psion",
  }
  p = require 'player'
end

enemies.spawn = function(self, X, Y)
  local typeName = self.types[love.math.random(#self.types)]
  local type = self.type[typeName]
  local level = self.level

  local e = setmetatable({}, {__index = type})

  local x, y 
  --[[old, flawed, in-screen spawning
  repeat
    x = X or love.math.random(W) - W/2 + p.x
    y = Y or love.math.random(H) - H/2 + p.y
  until not circleColl(p.x, p.y, p.r*3, x, y, self.r*3)
  --]]

  --new, hopefully better, off-screen spawning
  local a = love.math.random() * 2 * math.pi
  local x = math.cos(a) * ((W*W + H*H)^.5 + type.r)
  local y = math.sin(a) * ((W*W + H*H)^.5 + type.r)

  e.position = vector(x,y)
  e.velocity = vector(0,0)
  e.a = vector(0,0)
  e.hp = type.hp * (level / 10 + 1)
  e.maxHP = type.hp * (level / 10 + 1)
  if type.shields then
    e.shields = type.shields * (level / 10 + 1)
    e.maxShields = e.shields
  end
  e.damage = type.damage * (level / 4 + 1)
  e.maxSpeed = type.maxSpeed * (level / 6 + 1)
  e.acceleration = type.acceleration * (level / 10 + 1)
  e.damageSpread = type.damageSpread
  e.r = type.r + love.math.random(5)-3
  e.level = level


  table.insert(self, e)
end


enemies.update = function(self, dt)

  if love.math.random(100 + #self*3 - self.level*2) == 1 then self:spawn() end

  for i, particle in ipairs(self.particles) do
    particle:update(dt)
  end

  for i = #self, 1, -1 do
    local enemy = self[i]
    if enemy.dead then 
      table.remove(self, i)
    else
      enemy.a(enemy.position.x, enemy.position.y, p.x, p.y):scaleTo(enemy.acceleration)
      --if enemy.velocity:length() + enemy.a:length()*dt > enemy.maxSpeed then
        --enemy.a:scaleTo(math.max(0, (enemy.maxSpeed-enemy.velocity:length())/dt))
      --end
      enemy.velocity:scaleTo(enemy.velocity:length()*enemy.damping^dt)
      enemy.velocity = enemy.velocity + enemy.a*dt
      if enemy.velocity:length() > enemy.maxSpeed then
      	enemy.velocity:scaleTo(enemy.maxSpeed)
      end
      for i, e2 in ipairs(self) do
        if not (enemy == e2) and circleColl(enemy.position.x, enemy.position.y, enemy.r, e2.position.x, e2.position.y, e2.r) then
          e2:hit(0, enemy.position.x, enemy.position.y, 20)
        end
      end

      enemy.position = enemy.position + enemy.velocity*dt
      enemy.velocity = enemy.velocity * (1/dt)

      if enemy.shields then
        enemy.lastHit = (enemy.lastHit or 0) + dt
        if enemy.lastHit > enemy.recharge.delay then
          enemy.shields = math.min(enemy.shields + enemy.recharge.rate * dt, enemy.maxShields)
        end
      end


      if circleColl(enemy.position.x, enemy.position.y, enemy.r, p.x, p.y, p.r) then
        local diff = enemy.velocity - p.velocity
        p:hit(enemy.damage + enemy.damage * (love.math.random()-.5)*enemy.damageSpread + diff:length() / 10, enemy.position:unpack())
      end
    end

  end
  
end


enemies.draw = function(self)

  lg.setColor(255,255,255)
  for i, v in ipairs(self.particles) do
    lg.draw(v)
  end
  
  --draw their HP
  lg.setColor(255,0,0)
  for i, enemy in ipairs(self) do
    local x, y = enemy.position:unpack()
    --lg.arc('fill', x, y, enemy.r, 0, enemy.hp/enemy.maxHP*2*math.pi, enemy.r)
    lg.draw(img:arc(enemy.hp/enemy.maxHP), x, y, 0, enemy.r, enemy.r)
  end

  --draw their shields, if any
  lg.setColor(255,255,255)
  for i, enemy in ipairs(self) do
    if enemy.shields then
      local x, y = enemy.position:unpack()
      lg.draw(img:arc(enemy.shields / enemy.maxShields), x, y, 0, enemy.r, enemy.r)
    end
  end

  --and now draw them
  for i, enemy in ipairs(self) do
    local x,y = enemy.position:unpack()
    --lg.circle('fill', x, y, enemy.r-1, enemy.r)
    lg.setColor(enemy.color)
    lg.draw(img.circle, x, y, 0, enemy.r-1, enemy.r-1)
  end

  --and debug show their stuff
  --[[
  lg.setColor(255,255,255)
  for i, enemy in ipairs(self) do
    local x, y = enemy.position:unpack()
    lg.print(enemy.velocity:length(), x, y)
  end--]]

end


enemy.hit = function(self, damage, x, y, knockback)
  self.lastHit = damage == 0 and self.lastHit or 0
  if self.shields and self.shields > 0 then
    self.shields = math.max(self.shields - damage, 0)
    if self.shields == 0 then
      self:hit(self.maxHP / 5, x, y, 10000)
      return
    end
    damage = 0
  end
  if self.shields and damage > 0 then
    self:teleport()
  end
  self.hp = self.hp - damage
  local bump = vector(x, y, self.position.x, self.position.y)%(knockback or (damage+3)*15)
  self.velocity = self.velocity + bump
  if self.hp <= 0 then
    self:die()
  end
end


enemy.die = function(self)
  if self.dead then return end
  self.dead = true
  p:getExp(self.level)
  if love.math.random(10) == 1 then
    drops:new(function(p) p:heal(15) end, img.health, self.position.x, self.position.y)
  end
end

enemy.teleport = function(self)

  local x, y = self.position:unpack()

  local dx, dy = p.x - x, p.y - y

  local l = (dx*dx + dy*dy) ^ .5

  local a = love.math.random() * math.pi * 2

  local particle = require("particles.teleport"):clone()
  particle:setPosition(x, y)
  particle:start()

  table.insert(self.particles, particle)

  x = p.x + l * math.cos(a)
  y = p.y + l * math.sin(a)

  self.position(x, y)

end


return enemies
