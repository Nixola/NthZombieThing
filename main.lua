love.vM, love.vm = love.getVersion()
love.graphics.setLineJoin "none"


require 'images'

local t = love.timer.getTime

local camera = require 'camera'
local player = require 'player'
local enemies = require 'enemies'
local weapons = require 'player.weapons'
local drops = require 'drops'

local setColor = love.graphics.setColor

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
  love.graphics.setColor(255,255,255)
  love.graphics.print(love.timer.getFPS())
  camera:set()
  
    lg.setColor(192,32,32)
    for x = -1, 1 do
      for y = -1, 1 do
        lg.rectangle('fill', (math.floor(player.x/400) + x) * 400, (math.floor(player.y/300) + y)*300, 16, 16) --just some squares to know where you're going
      end
    end

    drops:draw()

    player:draw()

    enemies:draw()

  camera:unset()

  player:drawHud()

  if pause then
    love.graphics.setColor(192, 192, 192, 64)
    love.graphics.rectangle("fill", -1, -1, W+2, H+2)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(fonts.huge)
    love.graphics.printf("PAUSE", 0, H/2, W, "center")
    love.graphics.setFont(fonts.base)
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
