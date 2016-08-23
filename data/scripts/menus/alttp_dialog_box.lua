-- Script that creates an ALTTP-looking dialog box for games.
--
-- Usage:
-- require("scripts/menus/alttp_dialog_box")
--
-- You really have nothing more to do:
-- the dialog box will automatically be used in games.
--
-- To customize the dialog box, call
-- local dialog_box = game:get_dialog_box()
-- to get it and then it provides the following functions:
--
-- - dialog_box:set_style(style):
--   Sets the style of the dialog box for subsequent dialogs.
--   style must be one of:
--   - "box" (default): Usual dialog box.
--   - "empty": No decoration.
--
-- - dialog_box:set_position(position):
--   Sets the vertical position of the dialog box for subsequent dialogs.
--   position must be one of:
--   - "auto": Choose automatically so that the hero is not hidden.
--   - "top": Top of the screen.
--   - "bottom" (default): Bottom of the screen.
--   - a table with x and y integer fields.
--
-- - dialog_box:get_bounding_box():
--   Returns the coordinates on screen and the size of the dialog box.
--   This also works when the dialog box is inactive: in this case it
--   returns the bounding box it would have if it was activated now.

local dialog_box_manager = {}

require("scripts/multi_events")

-- Creates and sets up a dialog box for the specified game.
local function create_dialog_box(game)

  local dialog_box = {

    -- Dialog box properties.
    dialog = nil,                -- Dialog being displayed or nil.
    first = true,                -- Whether this is the first dialog of a sequence.
    style = nil,                 -- "box" or "empty".
    position = "bottom",         -- "auto", "top", "bottom" or an x,y table.
    skip_mode = nil,             -- "none", "current", "all" or "unchanged".
    info = nil,                  -- Parameter passed to start_dialog().
    skipped = false,             -- Whether the player skipped the dialog.
    choices = {},                -- Whether there is a choice on each line. If yes,
                                 -- the value is the char index of the cursor.
    selected_choice = nil,       -- Selected line (1 is the first one) or nil if there is no question.

    -- Displaying text gradually.
    next_line = nil,             -- Next line to display or nil.
    line_it = nil,               -- Iterator over of all lines of the dialog.
    lines = {},                  -- Array of the text of the visible lines.
    line_surfaces = {},          -- Array of the nb_visible_lines text surfaces.
    line_index = nil,            -- Line currently being shown.
    char_index = nil,            -- Next character to show in the current line.
    char_delay = nil,            -- Delay between two characters in milliseconds.
    full = false,                -- Whether the visible lines have shown all their content.
    need_letter_sound = false,   -- Whether a sound should be played with the next character.
    gradual = true,              -- Whether text is displayed gradually.

    -- Graphics.
    dialog_surface = nil,        -- Intermediate surface where we draw the dialog.
    box_img = nil,               -- Image of the dialog box frame.
    box_dst_position = nil,      -- Destination coordinates of the dialog box.
    choice_cursor_img = nil,     -- Icon representing the selected choice in a question.
    choice_cursor_dst_position = -- Destination coordinates of the cursor icon.
        nil,
  }

  -- Constants.
  local nb_visible_lines = 4     -- Maximum number of lines in the dialog box.
  local char_delays = {
    slow = 60,
    medium = 40,
    fast = 20  -- Default.
  }
  local letter_sound_delay = 100
  local box_width = 220
  local box_height = 60

  -- Initialize dialog box data.
  local dialog_font, dialog_font_size = "alttp", nil
  for i = 1, nb_visible_lines do
    dialog_box.lines[i] = ""
    dialog_box.line_surfaces[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = dialog_font,
      font_size = dialog_font_size,
    }
  end
  dialog_box.dialog_surface = sol.surface.create(sol.video.get_quest_size())
  dialog_box.box_img = sol.surface.create("hud/dialog_box.png")
  dialog_box.choice_cursor_img = sol.text_surface.create{
    horizontal_alignment = "left",
    vertical_alignment = "top",
    font = dialog_font,
      font_size = dialog_font_size,
    text = ">",
  }

  -- Exits the dialog box system.
  function dialog_box:quit()
    if sol.menu.is_started(dialog_box) then
      sol.menu.stop(dialog_box)
    end
  end

  -- Called by the engine when a dialog starts.
  function game:on_dialog_started(dialog, info)

    dialog_box.dialog = dialog
    dialog_box.info = info
    sol.menu.start(game, dialog_box)
  end

  -- Called by the engine when a dialog finishes.
  function game:on_dialog_finished(dialog)

    if sol.menu.is_started(dialog_box) then
      sol.menu.stop(dialog_box)
    end
    dialog_box.dialog = nil
    dialog_box.info = nil
  end

  -- Determines the position of the dialog box on the screen.
  local function compute_position()

    local map = game:get_map()
    local camera_x, camera_y, camera_width, camera_height = map:get_camera():get_bounding_box()
    local top = false
    if dialog_box.position == "top" then
      top = true
    elseif dialog_box.position == "auto" then
      local hero_x, hero_y = map:get_entity("hero"):get_position()
      if hero_y >= camera_y + (camera_height / 2 + 10) then
        top = true
      end
    end

    -- Set the coordinates of graphic objects.
    local box_width, box_height = dialog_box.box_img:get_size()
    local x = camera_width / 2 - box_width / 2
    local y = top and x or (camera_height - x - box_height)

    if type(dialog_box.position) == "table" then
      -- Custom position.
      dialog_box.box_dst_position = dialog_box.position
    else
      dialog_box.box_dst_position = { x = x, y = y }
    end
  end

  -- Returns the dialog box.
  function game:get_dialog_box()
    return dialog_box
  end

  -- See the doc in the header comment.
  function dialog_box:set_style(style)

    dialog_box.style = style
  end

  -- See the doc in the header comment.
  function dialog_box:set_position(position)
    dialog_box.position = position
  end

  -- See the doc in the header comment.
  function dialog_box:get_bounding_box()
    compute_position()
    local width, height = self.box_img:get_size()
    return self.box_dst_position.x, self.box_dst_position.y, width, height
  end

  local function repeat_show_character()

    dialog_box:check_full()
    while not dialog_box:is_full()
        and dialog_box.char_index > #dialog_box.lines[dialog_box.line_index] do
      -- The current line is finished.
      dialog_box.char_index = 1
      dialog_box.line_index = dialog_box.line_index + 1
      dialog_box:check_full()
    end

    if not dialog_box:is_full() then
      dialog_box:add_character()
    else
      sol.audio.play_sound("message_end")
      if game.set_custom_command_effect ~= nil then
        if dialog_box:has_more_lines()
            or dialog_box.dialog.next ~= nil
            or dialog_box.selected_choice ~= nil then
          game:set_custom_command_effect("action", "next")
        else
          game:set_custom_command_effect("action", "return")
        end
        game:set_custom_command_effect("attack", nil)
      end
    end
  end

  -- The first dialog of a sequence starts.
  function dialog_box:on_started()

    -- Set the initial properties.
    -- Subsequent dialogs in the same sequence do not reset them.
    self.skip_mode = "current"
    self.char_delay = char_delays["fast"]
    self.selected_choice = nil

    compute_position()
    self.choice_cursor_dst_position = { x = 0, y = 0 }

    self:show_dialog()
  end

  -- The dialog box is being closed.
  function dialog_box:on_finished()

    -- Remove overriden command effects.
    if game.set_custom_command_effect ~= nil then
      game:set_custom_command_effect("action", nil)
      game:set_custom_command_effect("attack", nil)
    end
  end

  -- A dialog starts (not necessarily the first one of its sequence).
  function dialog_box:show_dialog()

    -- Initialize this dialog.
    local dialog = self.dialog

    local text = dialog.text
    if dialog_box.info ~= nil then
      -- There is a "$v" sequence to substitute.
      text = text:gsub("%$v", dialog_box.info)
    end
    -- Split the text in lines.
    text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
    self.line_it = text:gmatch("([^\n]*)\n")  -- Each line including empty ones.

    self.next_line = self.line_it()
    self.line_index = 1
    self.char_index = 1
    self.skipped = false
    self.full = false
    self.need_letter_sound = true
    self.selected_choice = nil

    if dialog.skip ~= nil then
      -- The skip mode changes for this dialog.
      self.skip_mode = dialog.skip
    end

    -- Start displaying text.
    self:show_more_lines()
  end

  -- Returns whether there are more lines remaining to display after the current
  -- group of nb_visible_lines lines.
  function dialog_box:has_more_lines()
    return self.next_line ~= nil
  end

  -- Updates the result of is_full().
  function dialog_box:check_full()
    if self.line_index >= nb_visible_lines
        and self.char_index > #self.lines[nb_visible_lines] then
      self.full = true
    else
      self.full = false
    end
  end

  -- Returns whether all current lines of the dialog box are entirely
  -- displayed.
  function dialog_box:is_full()
    return self.full
  end

  -- Shows the next dialog of the sequence.
  -- Closes the dialog box if there is no next dialog.
  function dialog_box:show_next_dialog()

    local next_dialog_id = self.dialog.next

    if next_dialog_id ~= nil then
      -- Show the next dialog.
      self.first = false
      self.selected_choice = nil
      self.dialog = sol.language.get_dialog(next_dialog_id)
      self:show_dialog()
    else
      -- Finish the dialog, returning the choice or nil if there was no question.
      local status = self.selected_choice

      -- Conform to the built-in handling of shop treasures.
      if self.dialog.id == "_shop.question" then
        -- The engine expects a boolean answer after the "do you want to buy"
        -- shop treasure dialog.
        status = self.selected_choice == 2  -- "Yes" is on the second line.
      end

      game:stop_dialog(status)
    end
  end

  -- Starts showing a new group of nb_visible_lines lines in the dialog.
  -- Shows the next dialog (if any) if there are no remaining lines.
  function dialog_box:show_more_lines()

    self.gradual = true

    if not self:has_more_lines() then
      self:show_next_dialog()
      return
    end

    -- Hide the action icon and change the sword icon.
    if game.set_custom_command_effect ~= nil then
      game:set_custom_command_effect("action", nil)
      if self.skip_mode ~= "none" then
        game:set_custom_command_effect("attack", "skip")
        game:set_custom_command_effect("action", "next")
      else
        game:set_custom_command_effect("attack", nil)
      end
    end

    -- Prepare the lines.
    for i = 1, nb_visible_lines do
      self.line_surfaces[i]:set_text("")
      if self:has_more_lines() then
        self.lines[i] = self.next_line
        self.next_line = self.line_it()
      else
        self.lines[i] = ""
      end
    end
    self.line_index = 1
    self.char_index = 1

    if self.gradual then
      sol.timer.start(self, self.char_delay, repeat_show_character)
    end
  end

  -- Adds the next character to the dialog box.
  -- If this is a special character (like $0, $v, etc.),
  -- the corresponding action is performed.
  function dialog_box:add_character()

    local line = self.lines[self.line_index]
    local current_char = line:sub(self.char_index, self.char_index)
    if current_char == "" then
      error("No remaining character to add on this line")
    end
    self.char_index = self.char_index + 1
    local additional_delay = 0
    local text_surface = self.line_surfaces[self.line_index]

    -- Special characters:
    -- - $1, $2 and $3: slow, medium and fast
    -- - $0: pause
    -- - $v: variable
    -- - $?: cursor for a choice
    -- - space: don't add the delay
    -- - 110xxxx: multibyte character

    local special = false
    if current_char == "$" then
      -- Special character.

      special = true
      current_char = line:sub(self.char_index, self.char_index)
      self.char_index = self.char_index + 1

      if current_char == "0" then
        -- Pause.
        additional_delay = 1000

      elseif current_char == "1" then
        -- Slow.
        self.char_delay = char_delays["slow"]

      elseif current_char == "2" then
        -- Medium.
        self.char_delay = char_delays["medium"]

      elseif current_char == "3" then
        -- Fast.
        self.char_delay = char_delays["fast"]

      elseif current_char == "?" then
        -- Cursor for a choice.
        self:add_choice(self.line_index, self.char_index - 2)
        current_char = " "
        special = false
      else
        -- Not a special char, actually.
        text_surface:set_text(text_surface:get_text() .. "$")
        special = false
      end
    end

    if not special then
      -- Normal character to be displayed.
      text_surface:set_text(text_surface:get_text() .. current_char)

      -- If this is a multibyte character, also add the next byte.
      local byte = current_char:byte()
      if byte >= 192 and byte < 224 then
        -- The first byte is 110xxxxx: the character is stored with
        -- two bytes (utf-8).
        current_char = line:sub(self.char_index, self.char_index)
        self.char_index = self.char_index + 1
        text_surface:set_text(text_surface:get_text() .. current_char)
      end

      if current_char == " " then
        -- Remove the delay for whitespace characters.
        additional_delay = -self.char_delay
      end
    end

    if not special and current_char ~= nil and self.need_letter_sound then
      -- Play a letter sound sometimes.
      sol.audio.play_sound("message_letter")
      self.need_letter_sound = false
      sol.timer.start(self, letter_sound_delay, function()
        self.need_letter_sound = true
      end)
    end

    if self.gradual then
      sol.timer.start(self, self.char_delay + additional_delay, repeat_show_character)
    end
  end

  -- Stops displaying gradually the current lines,
  -- shows them immediately.
  -- If the lines were already finished, the next group of lines starts
  -- (if any).
  function dialog_box:show_all_now()

    if self:is_full() then
      self:show_more_lines()
    else
      self.gradual = false
      -- Check the end of the current line.
      self:check_full()
      while not self:is_full() do

        while not self:is_full()
            and self.char_index > #self.lines[self.line_index] do
          self.char_index = 1
          self.line_index = self.line_index + 1
          self:check_full()
        end

        if not self:is_full() then
          self:add_character()
        end
        self:check_full()
      end
    end
  end

  -- Marks that a line contains a selectable choice.
  -- A cursor will be displayed at the specified index when this
  -- line is selected.
  function dialog_box:add_choice(line_index, char_index)

    self.choices[line_index] = char_index
    if self.selected_choice == nil then
      self:set_selected_choice(line_index)
    end
  end

  function dialog_box:set_selected_choice(line_index)

    self.selected_choice = line_index

    if line_index ~= nil then
      self.choice_cursor_dst_position.x = self.box_dst_position.x + self.choices[line_index] * 6
      self.choice_cursor_dst_position.y = self.box_dst_position.y - 8 + line_index * 16
    end
  end

  function dialog_box:on_command_pressed(command)

    if command == "action" then

      -- Display more lines.
      if self:is_full() then
        self:show_more_lines()
      elseif self.skip_mode ~= "none" then
        self:show_all_now()
      end

    elseif command == "attack" then

      -- Attempt to skip the dialog.
      if self.skip_mode == "all" then
        self.skipped = true
        game:stop_dialog("skipped")
      elseif self:is_full() then
        self:show_more_lines()
      elseif self.skip_mode == "current" then
        self:show_all_now()
      end

    elseif command == "up" or command == "down" then

      if self.selected_choice ~= nil
          and not self:has_more_lines()
          and self:is_full() then

        sol.audio.play_sound("cursor")
        local line_index = self.selected_choice

        if command == "down" then
          -- Move the cursor downwards.
          repeat
            line_index = line_index % nb_visible_lines + 1
          until self.choices[line_index] ~= nil
        else
          -- Move the cursor upwards.
          repeat
            line_index = (line_index - 2) % nb_visible_lines + 1
          until self.choices[line_index] ~= nil
        end
        self:set_selected_choice(line_index)
      end
    end

    -- Don't propagate the event to anything below the dialog box.
    return true
  end

  function dialog_box:on_draw(dst_surface)

    local x, y = self.box_dst_position.x, self.box_dst_position.y

    self.dialog_surface:clear()

    if self.style == "box" then
      -- Draw the dialog box.
      self.box_img:draw(self.dialog_surface, x, y)
    end

    -- Draw the text.
    local text_x = x + 8
    local text_y = y + 8
    for i = 1, nb_visible_lines do
      self.line_surfaces[i]:draw(self.dialog_surface, text_x, text_y)
      text_y = text_y + 16
    end

    -- Draw the answer arrow.
    if self.selected_choice ~= nil then
      self.choice_cursor_img:draw(self.dialog_surface,
          self.choice_cursor_dst_position.x, self.choice_cursor_dst_position.y)
    end

    -- Final blit.
    self.dialog_surface:draw(dst_surface)
  end

  dialog_box:set_style("box")
end

-- Set up the dialog box on any game that starts.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", create_dialog_box)

return dialog_box_manager

