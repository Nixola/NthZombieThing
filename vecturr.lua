local vector = {__mt = {}}
vector.new = function(self, x1, y1, x2, y2)
  local v = setmetatable({}, self.__mt)
  if x2 and y2 then
    v.x1 = x1
    v.x2 = x2
    v.y1 = y1
    v.y2 = y2
  else
    v.x1 = 0
    v.y1 = 0
    v.x2 = x1
    v.y2 = y1
  end
  return v
end

setmetatable(vector, {__call = vector.new})

vector.length = function(self)
  return (self.x*self.x + self.y*self.y)^.5
end

vector.add = function(v1, v2) -- Sum of two vectors
  v1.x2 = v1.x1+v1.x+v2.x
  v1.y2 = v1.y1+v1.y+v2.y
  return v1
end

vector.subtract = function(v1, v2) -- Difference of two vectors
  v1.x2 = v1.x1+v1.x-v2.x
  v1.y2 = v1.y1+v1.y-v2.y
  return v1
end

vector.scale = function(self, n) -- Multiplies a vector by n
  self.x2 = self.x1 + self.x*n
  self.y2 = self.y1 + self.y*n
  return self
end

vector.scaleTo = function(self, newLength) -- this is weird. Scales the vector TO a certain length
  --Assuming op1 is the vector, op2 is the length.
  if newLength == 0 then
    self.x = 0
    self.y = 0
  else
    self:normalize()
    self:scale(newLength)
  end
  return self
end

vector.dot = function(v1, v2) -- Dot product!
  return (v1.x*v2.x + v1.y*v2.y)
end

vector.normalize = function(self) -- Makes the vector be long 1
  local l = self:length()
  self.x2 = self.x1 + self.x/l
  self.y2 = self.y1 + self.y/l
  return self
end

vector.unpack = function(self)
  if self.x1 == 0 and self.y1 == 0 then
    return self.x2, self.y2
  else
    return self.x1, self.y1, self.x2, self.y2
  end
end

vector.print = function(self)
  print(string.format("{%.3f,%.3f} {%.3f,%02f}\n{%.3f,%.3f}", self.x1, self.y1, self.x2, self.y2, self.x, self.y))
  return self
end


vector.__mt.__index = function(vect, index) -- I want this
  return 
    (index == 'x' and vect.x2-vect.x1) or 
    (index == 'y' and vect.y2-vect.y1) or 
    (vector[index])
end

vector.__mt.__newindex = function(vect, index, value)
  if index == "x" then
    vect.x2 = vect.x1 + value
  elseif index == "y" then
    vect.y2 = vect.y1 + value
  else
    rawset(vect, index,value)
  end
end
vector.__mt.__add = vector.add
vector.__mt.__sub = vector.subtract
vector.__mt.__len = vector.length

vector.__mt.__mul = function(op1, op2)
  return
    (type(op1) == "number" and op2:scale(op1)) or
    (type(op2) == "number" and op1:scale(op2)) or
    op1:dot(op2)
end

vector.__mt.__mod = vector.scaleTo

vector.__mt.__call = function(self, x1, y1, x2, y2)
  if x2 and y2 then
    self.x1 = x1
    self.x2 = x2
    self.y1 = y1
    self.y2 = y2
  else
    self.x1 = 0
    self.y1 = 0
    self.x2 = x1
    self.y2 = y1
  end
  return self
end

return vector