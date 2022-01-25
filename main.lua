love.vM, love.vm = love.getVersion()
love.graphics.setLineJoin "none"


require 'images'

local t = love.timer.getTime

local camera = require 'camera'
local player = require 'player'
local enemies = require 'enemies'
local weapons = require 'player.weapons'
local drops = require 'drops'

io.stdout:setvbuf 'no'

local lk = love.keyboard
local lg = love.graphics

local fonts = {
  huge = love.graphics.newFont(64)
}

love.load = function()
  W, H = lg.getDimensions()

  fonts.base = love.graphics.getFont()

  love.mouse.setVisible(false)
  
  camera:follow(player)
  player:setCamera(camera)
  player:load()
  enemies:load()
end

love.update = function(dt)
  if pause then return end
  player:update(dt)
  camera:update(dt)
  enemies:update(dt)
end


love.draw = function()
  camera:set()
  
    lg.setColor(1/16,1/16,1/16)
    for x = -4, 4 do
      for y = -3, 3 do
        lg.rectangle('fill', (math.floor(player.x/128) + x) * 128, (math.floor(player.y/128) + y)*128, 124, 124) --just some squares to know where you're going
      end
    end

    drops:draw()

    player:draw()

    enemies:draw()

  camera:unset()

  lg.setColor(1,1,1)
  lg.print(love.timer.getFPS())

  player:drawHud()

  if pause then
    lg.setColor(12/16, 12/16, 12/16, 4/16)
    lg.rectangle("fill", -1, -1, W+2, H+2)
    lg.setColor(1, 1, 1)
    lg.setFont(fonts.huge)
    lg.printf("PAUSE", 0, H/2, W, "center")
    lg.setFont(fonts.base)
  end

end


love.keypressed = function(k)
  player:keypressed(k)
  if k == 'h' then
    spawning = not spawning
  end
  if k == "escape" then
    pause = not pause
  end
end

love.mousepressed = function(x, y, b)
  if pause then return end
  weapons:mousepressed(x, y, b)
  player:mousepressed(x, y, b)
end

love.wheelmoved = function(x, y)
  player:wheelmoved(x, y)
end
