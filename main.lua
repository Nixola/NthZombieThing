game = {}
local camera = require 'camera'
game.camera = camera
local player = require 'player'
game.player = player
local enemies = require 'enemies'
game.enemies = enemies

io.stdout:setvbuf 'no'

local lk = love.keyboard
local lg = love.graphics

love.load = function()
  camera:follow(player)
  player:setCamera(camera)
  player:load()
end


love.update = function(dt)
  player:update(dt)
  camera:update(dt)
  enemies:update(dt)
end


love.draw = function()
  camera:set()
    print(camera:getPosition())
  
    lg.setColor(192,32,32)
    for x = -1, 1 do
      for y = -1, 1 do
        lg.rectangle('fill', (math.floor(player.x/400) + x) * 400, (math.floor(player.y/300) + y)*300, 16, 16) --just some squares to know where you're going
      end
    end
    
    player:draw()
    enemies:draw()
  
  camera:unset()
  
  player:drawHud()
end


love.keypressed = function(k)
  player:keypressed(k)
  if k == 'h' then
    spawning = not spawning
  end
end


love.mousepressed = function(x, y, b)
  if not player.weapons.current.autofire and player.weapons.current.timer > 1/player.weapons.current.rate and b == 'l' then
    player.weapons:shoot(x,y)
  end
end