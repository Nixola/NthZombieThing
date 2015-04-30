local lg = love.graphics

local particle = lg.newParticleSystem(love.graphics.newImage("img/health.png"), 100)

particle:setParticleLifetime(0.2, 2)
particle:setEmitterLifetime(1)
particle:setEmissionRate(0)

particle:setAreaSpread("normal", 16, 16)

particle:setLinearDamping(1, 16)

particle:setSpeed(1, 16)

particle:setTangentialAcceleration(0, 1)

particle:setSpread(math.pi*2)

return particle