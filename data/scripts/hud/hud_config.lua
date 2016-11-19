-- Defines the elements to put in the HUD
-- and their position on the game screen.

-- You can edit this file to add, remove or move some elements of the HUD.

-- Each HUD element script must provide a method new()
-- that creates the element as a menu.
-- The created menu must then have at least the following method:
-- set_dst_position(x, y).
-- See for example scripts/hud/hearts.lua.

-- Negative x or y coordinates mean to measure from the right or bottom
-- of the screen, respectively.

local hud_config = {

  {
    menu_script = "scripts/hud/hearts",
    x = -88,
    y = 0,
  },

  -- You can add more HUD elements here.
}

return hud_config
