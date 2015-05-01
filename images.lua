img = {}

setmetatable(img, {__index = function(self, name)
  name = name:gsub("_", "/")
  local r, img = pcall(love.graphics.newImage, "img/"..name..".png")
  if r then
    self[name] = img
  end
  return r and img
end})