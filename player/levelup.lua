local choices = {
  [0] = {func = function() game.enemies.level = game.enemies.level + 1 end; desc = "Want a challenge?"},
  {func = function()  -- more HPs!
    game.player.hp.max = game.player.hp.max+10
    game.player.hp.current = game.player.hp.current + 10
  end,
  desc = "Increase max HP by 10."},

  {func = function() -- more damage! 5% more
    game.player.damage = game.player.damage + .05
  end,
  desc = "Increase damage by 5% (no compound)"},

  {func = function() -- speeder
    game.player.maxvelocity = game.player.maxvelocity + 15
    game.player.acceleration = game.player.acceleration + 10
  end,
  desc = "Increase speed and acceleration"}
}

return choices