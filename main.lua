local camera = require 'camera'
local player = require 'player'
local enemies = require 'enemies'
local weapons = require 'player.weapons'

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
  weapons:mousepressed(x,y,b)
end