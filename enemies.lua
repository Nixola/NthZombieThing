local vector = require 'vecturr'
local drops = require 'drops'
local lg = love.graphics

local circleColl = function(x1,y1,r1, x2,y2,r2)
  return (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1) <= (r2+r1)*(r2+r1)
end

local enemies = {}
local enemy = enemies
local W, H = love.window.getDimensions()
local p

enemies.load = function(self)

            enemies.hp = 90
        enemies.damage = 11
  enemies.damageSpread = .2
      enemies.maxSpeed = 135
  enemies.acceleration = 4000
             enemies.r = 18
         enemies.level = 1
         p = require 'player'
end

enemies.spawn = function(self, X, Y)
  local e = setmetatable({}, {__index = self})

  local x, y 
  repeat
    x = X or love.math.random(W) - W/2 + p.x
    y = Y or love.math.random(H) - H/2 + p.y
  until not circleColl(p.x, p.y, p.r*3, x, y, self.r*3)

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
      enemy.a(enemy.position.x, enemy.position.y, p.x, p.y):scaleTo(enemy.acceleration)
      enemy.velocity = enemy.velocity + enemy.a*dt
      if enemy.velocity:length() > enemy.maxSpeed then
        enemy.velocity:scaleTo(self.maxSpeed)
      end
      for i, e2 in ipairs(self) do
        if not (enemy == e2) and circleColl(enemy.position.x, enemy.position.y, enemy.r, e2.position.x, e2.position.y, e2.r) then
          e2:hit(0, enemy.position.x, enemy.position.y)
        end
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

  --and debug show their stuff
  --[[
  lg.setColor(255,255,255)
  for i, enemy in ipairs(self) do
    local x, y = enemy.position:unpack()
    lg.print(enemy.velocity:length(), x, y)
  end--]]

end


enemy.hit = function(self, damage, x, y)
  self.hp = self.hp - damage
  local bump = vector(x, y, self.position.x, self.position.y)%(damage*15+50)
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
  --spawn things, award exp to player
end

return enemies