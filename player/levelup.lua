local choices = {
  [0] = {func = function(player, weapons, enemies) 
      enemies.level = enemies.level + 1
    end,
    desc = "Want a challenge?"},

  {func = function(player, weapons, enemies)   -- more HPs!
    player.hp.max = player.hp.max+10
    player.hp.current = player.hp.current + 10
  end,
  desc = "Increase max HP by 10."},

  {func = function(player, weapons, enemies)  -- more damage! 5% more
    player.damage = player.damage + .05
  end,
  desc = "Increase damage by 5% (not compound)"},

  {func = function(player, weapons, enemies)  -- speeder
    player.maxvelocity = player.maxvelocity + 15
    player.acceleration = player.acceleration + 10
  end,
  desc = "Increase speed and acceleration"},

  {func = function(player, weapons, enemies)  -- less spread
    player.spread = player.spread*.9
  end,
  desc = "Decreases spread by 10% (compound)"
  },

  {func = function(player, weapons, enemies)  -- more critical chance!
    player.critical.chance = player.critical.chance + .15
  end,
  desc = "Increases critical chance by 15% (of the chance)"},

  {func = function(player, weapons, enemies)  -- more critical damage!
    player.critical.damage = player.critical.damage + .1
  end,
  desc = "Increases critical damage by 10%"},

  {func = function(player, weapons, enemies)  -- randomness!
    local weapon = weapons[weapons.list[love.math.random(#weapons.list)]]
    weapon.damage = weapon.damage * 1.1
    weapon.rate = weapon.rate * 1.1
    weapon.duration = math.min(weapon.duration, 1/weapon.rate)
    weapon.spread = weapon.spread * .9
    weapon.critical.chance = weapon.critical.chance * 1.1
    weapon.critical.damage = weapon.critical.damage * 1.1
    weapon.level = weapon.level + 1
    player.hud.weapons:draw()
  end,
  desc = "Increases by 10% EVERY attribute of a random weapon.",
  condition = function(player, weapons, enemies) return love.math.random(4) == 1 end}
}

return choices
