local lk = love.keyboard
local lg = love.graphics

local W, H = love.window.getDimensions()

local vector = require 'vecturr'

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
  damage = 1,
  levelChoices = {points = 0},
  hp = {max = 100, current = 100},
  particles = {
    health = require 'particles.health'
  },
  weapons = require 'player.weapons'
}

player.hud = {
  height = 128
}
player.hud.y = H - player.hud.height

player.setCamera = function(self, t)
  self.camera = t
end

player.load = function(self)
  self.camera:setViewport(nil, self.hud.y)

  player.weapons:setPlayer(player)
  player.weapons:set "gun"

end

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
end


player.die = function(self)

  error "DED"
  
end


player.getExp = function(self, amount)

  self.experience = self.experience + amount
  while self.experience >= self.level*10 do
    self.experience = self.experience - self.level*10
    self.level = self.level + 1
    game.enemies.level = game.enemies.level + 1
    self.levelChoices.points = self.levelChoices.points + 1
    self.levelChoices:refresh()
  end

end


player.hit = function(self, damage, x, y)

  self.hp.current = self.hp.current - damage
  self.camera.shake(damage/5)
  local direction = vector(x, y, self.x, self.y)%(damage*100)
  self.velocity = self.velocity + direction
end


player.heal = function(self, amount)

  self.hp.current = math.min(self.hp.current + amount, self.hp.max)
  self.particles.health:setEmissionRate(amount)
  self.particles.health:start()
  
end

player.draw = function(self)

  lg.setColor(255,255,255)
  lg.circle("fill", self.x, self.y, self.r, self.r)
  for i, particleSystem in pairs(self.particles) do
    lg.draw(particleSystem)
  end
  self.weapons:draw()
end

player.drawHud = function(self)

  lg.setColor(32,32,32)
  lg.rectangle('fill', 0, self.hud.y, lg.getWidth(), self.hud.height)

  lg.setColor(255 * (1 - self.hp.current / self.hp.max ), 255 / self.hp.max * self.hp.current , 0)
  lg.print("HP: " .. math.floor(self.hp.current), 0, self.hud.y)

  lg.setColor(128 + self.experience/self.level/10*96, 128 + self.experience/self.level/10*96, 255)
  lg.print("XP: " .. self.experience .. "/" .. self.level*10, 0, self.hud.y + 16)

  lg.setColor(192,192,192)

  if self.levelChoices.points > 0 then 
    for i = 1, 3 do
      lg.rectangle("line", 96*i, self.hud.y + 40, 88, self.hud.height - 16)
      lg.printf(self.levelChoices[i].desc, 4+96*i, self.hud.y + self.hud.height/2, 80)
    end
  end

  for i = 1, #self.weapons.list do
    local weapon = self.weapons[self.weapons.list[i]]
    lg.setColor((weapon.name == self.weapons.current.name) and {224, 224, 224} or {160, 160, 160})
    lg.rectangle("line", 96*i, self.hud.y + 8, 88, 24)
    lg.print(weapon.name, 4+96*i, self.hud.y+12)
  end

end

player.keypressed = function(self, k)
  if tonumber(k) and player.weapons.list[tonumber(k)] then
    player.weapons:set(k)
  end
  if bindings[k] and self.levelChoices.points > 0 then
    self.levelChoices[bindings[k]].func()
    self.levelChoices.points = self.levelChoices.points - 1
    self.levelChoices:refresh()
  end
end


player.levelChoices.refresh = function(self)
  if self.points == 0 then
    for i, v in ipairs(self) do
      self[i] = nil
    end
    self[0] = nil
    return
  end
  local choices = dofile 'player/levelup.lua'
  for i = 1, 3 do
    local choice = love.math.random(#choices)
    self[i] = choices[choice]
    table.remove(choices, choice)
  end
  self[0] = choices[0]

end


return player