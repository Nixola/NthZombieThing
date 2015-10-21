local lg = love.graphics

local particle = lg.newParticleSystem(img.particle_teleport, 100)

particle:setParticleLifetime(0.2)
particle:setEmitterLifetime(0.1)
particle:setEmissionRate(100)

particle:setAreaSpread("normal", 16, 16)

particle:setLinearDamping(1, 16)

particle:setSpeed(1, 16)

particle:setTangentialAcceleration(1100, 2200)
particle:setRadialAcceleration(-300, 300)

particle:setSpread(math.pi*2)
particle:stop()

return particle