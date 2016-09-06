local lk = love.keyboard
local lg = love.graphics

local circleColl = function(x1,y1,r1, x2,y2,r2)
  return (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1) <= (r2+r1)*(r2+r1)
end

local W, H = love.graphics.getDimensions()

local vector = require 'vecturr'
local enemies = require 'enemies'
local drops = require 'drops'

local weapon

local bindings = {z = 1, x = 2, c = 3, ['0'] = 0}

local player = {
  x = 0,
  y = 0,
  r = 24,
  velocity = vector(0,0),
  acceleration = 400,
  maxvelocity = 180,
  damping = .1,
  experience = 0,
  level = 1,
  damage = 1,--damage multiplier
  spread = 1,--spread multiplier
  critical = {chance = 1, damage = 1}, -- critical multiplier
  levelChoices = {points = 0},
  hp = {max = 100, current = 100},
  particles = {
    health = require 'particles.health',
    levelup = require 'particles.levelup'
  },
  weapons = require 'player.weapons'
}

player.hud = require 'player.hud'

player.setCamera = function(self, t)
  self.camera = t
end

player.load = function(self)
  self.camera:setViewport(nil, self.hud.y)

  self.weapons:setPlayer(player)
  self.weapons:set "gun"
  self.hud:setPlayer(self)

end

weapon = player.weapons.current

player.update = function(self, dt)

  if self.hp.current < 0 then
    self:die()
  end
  self.weapons:update(dt)
  self.velocity:scaleTo(self.velocity:length()*self.damping^dt)

  local n = 0
  if lk.isDown 'w' then
    n = n + 1
  end
  if lk.isDown 's' then
    n = n + 1
  end
  if lk.isDown 'a' then
    n = n + 1
  end
  if lk.isDown 'd' then
    n = n + 1
  end

  if lk.isDown 'w' then
    self.velocity.y = self.velocity.y - self.acceleration*dt * (n == 1 and 1 or 2^.5/2)
  end
  if lk.isDown 's' then
    self.velocity.y = self.velocity.y + self.acceleration*dt * (n == 1 and 1 or 2^.5/2)
  end
  if lk.isDown 'a' then
    self.velocity.x = self.velocity.x - self.acceleration*dt * (n == 1 and 1 or 2^.5/2)
  end
  if lk.isDown 'd' then
    self.velocity.x = self.velocity.x + self.acceleration*dt * (n == 1 and 1 or 2^.5/2)
  end
  if self.velocity:length() > self.maxvelocity then
    self.velocity = self.velocity%self.maxvelocity
  end

  self.x = self.x + self.velocity.x*dt
  self.y = self.y + self.velocity.y*dt
  
  for i, particleSystem in pairs(self.particles) do
    particleSystem:setPosition(self.x, self.y)
    particleSystem:update(dt)
  end

  for i = #drops, 1, -1 do
    local drop = drops[i]
    if circleColl(drop.x, drop.y, drop.r, self.x, self.y, self.r) then
      drop.func(self)
      table.remove(drops, i)
    end
  end
end


player.die = function(self)

  error "DED"
  
end


player.getExp = function(self, amount)

  self.experience = self.experience + amount
  while self.experience >= self.level*10 do
    self.experience = self.experience - self.level*10
    self.level = self.level + 1
    self.particles.levelup:start()
    enemies.level = enemies.level + 1
    self.levelChoices.points = self.levelChoices.points + 1
    self.levelChoices:refresh()
  end
  self.hud.exp:draw()

end


player.hit = function(self, damage, x, y)

  self.hp.current = self.hp.current - damage
  self.camera.shake(damage/5)
  local direction = vector(x, y, self.x, self.y)%(damage*100)
  self.velocity = self.velocity + direction
  self.hud.hp:draw()
end


player.heal = function(self, amount)

  self.hp.current = math.min(self.hp.current + amount, self.hp.max)
  self.particles.health:setEmissionRate(amount)
  self.particles.health:start()
  self.hud.hp:draw()
  
end

player.draw = function(self)

  if self.weapons.current.reloading then
    lg.setColor(128,128,192)
    lg.draw(img:arc(self.weapons.current.reloading/self.weapons.current.reload), self.x, self.y, 0, self.r+2)
  end

  lg.setColor(192,192,192)
  lg.draw(img.circle, self.x, self.y, 0, self.r)
  for i, particleSystem in pairs(self.particles) do
    lg.draw(particleSystem)
  end
  self.weapons:draw()
end

player.drawHud = function(self)

  lg.setColor(255,255,255)
  lg.draw(self.hud.canvas, self.hud.x, self.hud.y)

  local mx, my = love.mouse.getPosition()
  lg.rectangle("fill", mx-1, my-8, 2, 16)
  lg.rectangle("fill", mx-8, my-1, 16, 2)

  local weapon = self.weapons.current
  lg.setColor(192,192,192)
  lg.print("Ammo: " .. math.ceil(weapon.ammo / weapon.bullets) .. "/" .. math.ceil(weapon.magazine / weapon.bullets), self.hud.ammo.x+self.hud.x, self.hud.ammo.y+self.hud.y)

end

player.keypressed = function(self, k)
  if tonumber(k) and player.weapons.list[tonumber(k)] then
    player.weapons:set(k)
  end
  if bindings[k] and self.levelChoices.points > 0 then
    self.levelChoices[bindings[k]].func(self, self.weapons, enemies)
    self.levelChoices.points = self.levelChoices.points - 1
    self.levelChoices:refresh()
    self.hud:init()
  end
end

player.mousepressed = function(self, x, y, b)
  if b == "wu" then
    local id = player.weapons.current.id
    id = id -1
    if id > #player.weapons.list then
      id = id - #player.weapons.list
    end
    player.weapons:set(id)
  elseif b == "wd" then
    local id = player.weapons.current.id
    id = id + 1
    if id == 0 then
      id = #player.weapons.list
    end
    player.weapons:set(id)
  end
end

player.wheelmoved = function(self, x, y)
  if y > 0 then
    self:mousepressed(nil, nil, "wu")
  elseif y < 0 then
    self:mousepressed(nil, nil, "wd")
  end
end


player.levelChoices.refresh = function(self)
  if self.points == 0 then
    for i, v in ipairs(self) do
      self[i] = nil
    end
    self[0] = nil
    player.hud.levelup:draw()
    return
  end
  local choices = love.filesystem.load 'player/levelup.lua' ()
  for i = #choices, 1, -1 do
    if choices.condition and not choices.condition() then
      table.remove(choice, i)
    end
  end
  for i = 1, 3 do
    local choice = love.math.random(#choices)
    self[i] = choices[choice]
    table.remove(choices, choice)
  end
  self[0] = choices[0]
  player.hud.levelup:draw()
end


return player
