local W,H = (love.window.getDimensions or love.graphics.getDimensions)()
local lg = love.graphics

local hud = {
  height = 128,
  width = W,
  x = 0
}
hud.y = H-hud.height
hud.bg = {32,32,32}

local p
hud.setPlayer = function(self, player)
  p = player
  self:init()
end

hud.canvas = lg.newCanvas(W, hud.height)

hud.hp = {x = 0, y = 0, h = 16, w = 92}
hud.hp.draw = function(self, total)
  if not total then lg.setCanvas(hud.canvas) end
  lg.setColor(hud.bg)
  lg.rectangle("fill", self.x, self.y, self.w, self.h)
  lg.setColor(255 * (1 - p.hp.current / p.hp.max ), 255 / p.hp.max * p.hp.current , 0)
  lg.print("HP: " .. math.floor(p.hp.current) .. "/" .. math.floor(p.hp.max), self.x, self.y)
  if not total then lg.setCanvas() end
end

hud.exp = {x = 0, y = 16, h = 16, w = 92}
hud.exp.draw = function(self, total)
  if not total then lg.setCanvas(hud.canvas) end
  lg.setColor(hud.bg)
  lg.rectangle("fill", self.x, self.y, self.w, self.h)

  lg.setColor(128 + p.experience/p.level/10*96, 128 + p.experience/p.level/10*96, 255)
  lg.print("XP: " .. p.experience .. "/" .. p.level*10, self.x, self.y)

  lg.setColor(192,192,0)
  lg.printf("LV " .. p.level, self.x, self.y, self.w, "right")
  if not total then lg.setCanvas() end
end

hud.ammo = {x = 0, y = 32, h = 16, w = 96}
--[[
hud.ammo.draw = function(self, total)
  if not total then lg.setCanvas(hud.canvas) end
  lg.setColor(hud.bg)
  lg.rectangle("fill", self.x, self.y, self.w, self.h)

  local weapon = p.weapons.current
  lg.setColor(192,192,192)
  lg.print("Ammo: " .. math.ceil(weapon.ammo / weapon.bullets) .. "/" .. math.ceil(weapon.magazine / weapon.bullets), 0, self.y)
  if not total then lg.setCanvas() end
end--]]

hud.levelup = {x = 96, y = 40, w = hud.width-96, h = hud.height-44}
hud.levelup.draw = function(self, total)
  if not total then lg.setCanvas(hud.canvas) end
  lg.setColor(hud.bg)
  lg.rectangle("fill", self.x, self.y, self.w, self.h)

  if p.levelChoices.points > 0 then
    lg.setColor(192,192,192)
    lg.setLineWidth(1)
    for i = 1, 3 do
      local x = self.x + 192*(i-1)+1
      lg.rectangle("line", x, self.y+2, 88+96, self.h-4)
      lg.printf(p.levelChoices[i].desc, 4+x+96, self.y + 4, 80)
    end

    lg.rectangle('line', hud.width - 96, self.y+2, 88, self.h-4)
    lg.printf(p.levelChoices[0].desc, W - 88, self.y + 4, 80)
  end

  if not total then lg.setCanvas() end
end

hud.weapons = {x = 96, y = 0, w = hud.width-96, h = 40}
hud.weapons.draw = function(self, total)
  if not total then lg.setCanvas(hud.canvas) end
  lg.setColor(hud.bg)
  lg.rectangle("fill", self.x, self.y, self.w, self.h)

  if not p then return end

  lg.setLineWidth(1)

  for i = 1, #p.weapons.list do
    local weapon = p.weapons[p.weapons.list[i]]
    lg.setColor((weapon.name == p.weapons.current.name) and {224, 224, 224} or {160, 160, 160})
    lg.rectangle("line", 96*i, self.y + 8, 88, 24)
    lg.print(weapon.name .. ((weapon.level > 0) and (" +" .. weapon.level) or ''), 4+96*i, self.y+12)
  end
  if not total then lg.setCanvas() end
end

hud.init = function(self)
    lg.rectangle("fill", 0, 0, self.width, self.height)
    self.hp:draw()
    self.exp:draw()
    --self.ammo:draw(true)
    self.levelup:draw()
    self.weapons:draw()
  lg.setCanvas()
end

return hud

