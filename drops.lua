local drops = {}

drops.draw = function(self)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setLineWidth(1)
  for i, drop in ipairs(self) do
    local w, h = drop.icon:getWidth(), drop.icon:getHeight()
    love.graphics.circle('line', drop.x, drop.y, drop.r, drop.r)
    love.graphics.draw(drop.icon, drop.x - w/2, drop.y - h/2)
  end
end

drops.new = function(self, func, icon, x, y)
  local d = {func = func, icon = icon, x = x, y = y, r = 16}
  self[#self+1] = d
end

return drops