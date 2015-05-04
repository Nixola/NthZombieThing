require 'images'

local t = love.timer.getTime

local camera = require 'camera'
local player = require 'player'
local enemies = require 'enemies'
local weapons = require 'player.weapons'
local drops = require 'drops'

local setColor = love.graphics.setColor

io.stdout:setvbuf 'line'

local lk = love.keyboard
local lg = love.graphics

love.load = function()
  camera:follow(player)
  player:setCamera(camera)
  player:load()
  enemies:load()
end

local t1, t2, t3, t4, t5, t6, t7
love.update = function(dt)
  player:update(dt)
  camera:update(dt)
  enemies:update(dt)
end


love.draw = function()
  t1 = t()
  camera:set()
  
    lg.setColor(192,32,32)
    for x = -1, 1 do
      for y = -1, 1 do
        lg.rectangle('fill', (math.floor(player.x/400) + x) * 400, (math.floor(player.y/300) + y)*300, 16, 16) --just some squares to know where you're going
      end
    end
    t2 = t()
    drops:draw()
    t3 = t()
    player:draw()
    t4 = t()
    enemies:draw()
    t5 = t()
  camera:unset()


--  lg.setColor(0,0,0)
--  lg.setColor = function() end
  t6 = t()
  player:drawHud()
  t7 = t()
--  lg.setColor = setColor
  --print(love.graphics.getStats().drawcalls)
  local d1 = t2-t1
  local d2 = t3-t2
  local d3 = t4-t3
  local d4 = t5-t4
  local d5 = t7-t6
  local dtot = t7-t1
  print(string.format("%d%% %d%% %d%% %d%% %d%%", d1/dtot*100, d2/dtot*100, d3/dtot*100, d4/dtot*100, d5/dtot*100))
  --print(t1,t2,t3,'\n', ut,dt, '\n')
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
