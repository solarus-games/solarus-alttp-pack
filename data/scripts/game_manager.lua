local game_manager = {}

local initial_game = require("scripts/initial_game")

-- Starts the game from the given savegame file,
-- initializing it if necessary.
function game_manager:start_game(file_name)

  local exists = sol.game.exists(file_name)
  local game = sol.game.load(file_name)
  if not exists then
    -- Initialize a new savegame.
    initial_game:initialize_new_savegame(game)
  end
  game:start()
end

return game_manager

