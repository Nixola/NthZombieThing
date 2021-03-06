img = {}

setmetatable(img, {__index = function(self, name)
  name = name:gsub("_", "/")
  local r, img = pcall(love.graphics.newImage, "img/"..name..".png")
  if r then
    self[name] = img
  end
  return r and img
end})


local segments = 50
local t = {{0,0,0,0}}
for i = 0, segments do
  t[i+2] = {math.cos(math.pi*2/(segments)*i), math.sin(math.pi*2/(segments)*i),0,0}
end
t[#t+1] = t[2]
segments = segments+1

img.circle = love.graphics.newMesh(t)

local arc = love.graphics.newMesh(t)

if love.vm == 9 and love.vM == 0 then
  img.circle:setVertexColors(false)
  arc:setVertexColors(false)
elseif love.vm == 10 and love.vM == 0 then
  img.circle:setAttributeEnabled("VertexColor", false)
  arc:setAttributeEnabled("VertexColor", false)
end

local floor = math.floor

img.arc = function(self, fraction)
  local n = floor(fraction * segments + .5)
  arc:setDrawRange(1, n+2)
  return arc
end

img.ring = function(self, radius, fraction)
  local vertices = {}
  local n = floor(fraction * segments + .5)

  for i = 0, n do
    vertices[#vertices + 1] = t[i+2][1] * radius
    vertices[#vertices + 1] = t[i+2][2] * radius
  end

  return vertices
end


local imgD = love.image.newImageData(1,1)
imgD:setPixel(0,0,255,255,255,255)
img.white = love.graphics.newImage(imgD)
