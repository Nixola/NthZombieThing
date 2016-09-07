local lg = love.graphics

local particle = lg.newParticleSystem(img.particle_levelup, 75)

particle:setParticleLifetime(0.5)
particle:setEmitterLifetime(0.5)
particle:setEmissionRate(75)

particle:setAreaSpread("normal", 10, 10)

particle:setLinearDamping(1, 16)

particle:setSpeed(0, 50)

particle:setTangentialAcceleration(1100, 2200)
particle:setRadialAcceleration(610, 820)

particle:setSpread(math.pi*2)
particle:stop()
return particle