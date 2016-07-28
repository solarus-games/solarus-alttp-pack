local game_manager = {}

-- Sets initial values to a new savegame file.
local function initialize_new_savegame(game)

  -- You can modify this function to initialize life and equipment
  -- and set the initial map.
  game:set_max_life(12)
  game:set_life(game:get_max_life())
  game:set_ability("lift", 1)
  game:set_ability("sword", 1)
  game:set_starting_location("first_map", "starting_destination")
end

-- Starts the game from savegame save1.dat,
-- initializing it if necessary.
function game_manager:start_game()

  local exists = sol.game.exists("save1.dat")
  local game = sol.game.load("save1.dat")
  if not exists then
    -- Initialize a new savegame.
    initialize_new_savegame(game)
  end
  game:start()
end

return game_manager

