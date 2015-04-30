local vector = require 'vecturr'
local lg = love.graphics

local circleColl = function(x1,y1,r1, x2,y2,r2)
  return (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1) <= (r2+r1)*(r2+r1)
end

local enemies = {}
local enemy = enemies
local W, H = love.window.getDimensions()
local p = game.player

            enemies.hp = 90
        enemies.damage = 11
  enemies.damageSpread = .2
      enemies.maxSpeed = 135
  enemies.acceleration = 400
             enemies.r = 18
         enemies.level = 1

enemies.spawn = function(self, X, Y)
  local e = setmetatable({}, {__index = self})

  local x, y 
  repeat
    x = X or love.math.random(W) - W/2 + p.x
    y = Y or love.math.random(H) - H/2 + p.y
  until not circleColl(p.x, p.y, p.r*2, x, y, self.r*2)

  e.position = vector(x,y)
  e.velocity = vector(0,0)
  e.a = vector(0,0)
  e.hp = self.hp + self.level*10
  e.maxHP = self.hp + self.level*10
  e.damage = self.damage + self.level*4
  e.maxSpeed = self.maxSpeed + self.level*15
  e.damageSpread = self.damageSpread
  e.r = self.r + love.math.random(5)-3
  e.level = self.level


  table.insert(self, e)
end


enemies.update = function(self, dt)

  if love.math.random(100 + #self*3 - self.level*2) == 1 then self:spawn() end

  for i = #self, 1, -1 do
    local enemy = self[i]
    if enemy.dead then 
      table.remove(self, i)
    else
      enemy.a(enemy.position.x, enemy.position.y, p.x, p.y):scaleTo(enemy.acceleration*dt)
      enemy.velocity = enemy.velocity + enemy.a
      if enemy.velocity:length() > enemy.maxSpeed then
        print "not so fast"
        enemy.velocity:scaleTo(self.maxSpeed)
      end

      enemy.position = enemy.position + enemy.velocity*dt

      if circleColl(enemy.position.x, enemy.position.y, enemy.r, p.x, p.y, p.r) then
        p:hit(enemy.damage + enemy.damage * (love.math.random()-.5)*enemy.damageSpread, enemy.position:unpack())
      end
    end

  end
  
end


enemies.draw = function(self)
  
  --draw their HP
  lg.setColor(255,0,0)
  for i, enemy in ipairs(self) do
    local x, y = enemy.position:unpack()
    lg.arc('fill', x, y, enemy.r, 0, enemy.hp/enemy.maxHP*2*math.pi, enemy.r)
  end

  --and now draw them
  lg.setColor(16, 92, 16)
  for i, enemy in ipairs(self) do
    local x,y = enemy.position:unpack()
    lg.circle('fill', x, y, enemy.r-1, enemy.r)
  end

  --and debug show their level
  lg.setColor(255,255,255)
  for i, enemy in ipairs(self) do
    local x, y = enemy.position:unpack()
    lg.print(enemy.level, x, y)
  end

end


enemy.hit = function(self, damage)
  self.hp = self.hp - damage
  if self.hp <= 0 then
    self:die()
  end
end


enemy.die = function(self)
  if self.dead then return end
  self.dead = true
  p:getExp(self.level)
  --spawn things, award exp to player
end

return enemies