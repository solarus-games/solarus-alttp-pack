-- The money counter shown in the game screen.

local rupees_builder = {}

local rupee_icon_img = sol.surface.create("hud/rupee_icon.png")

function rupees_builder:new(game, config)

  local rupees = {}

  local digits_text = sol.text_surface.create({
    font = "white_digits",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  })
  local money_displayed = game:get_money()

  local dst_x, dst_y = config.x, config.y

  function rupees:on_draw(dst_surface)

    local x, y = dst_x, dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    rupee_icon_img:draw(dst_surface, x + 8, y)
    digits_text:draw(dst_surface, x, y + 10)
  end

  -- Checks whether the view displays correct information
  -- and updates it if necessary.
  local function check()

    local need_rebuild = false
    local money = game:get_money()
    local max_money = game:get_max_money()

    -- Current money.
    if money ~= money_displayed then

      need_rebuild = true
      if money_displayed < money then
        money_displayed = money_displayed + 1
      else
        money_displayed = money_displayed - 1
      end

      if money_displayed == money  -- The final value was just reached.
          or money_displayed % 3 == 0 then  -- Otherwise, play sound "rupee_counter_end" every 3 values.
        sol.audio.play_sound("rupee_counter_end")
      end
    end

    if digits_text:get_text() == "" then
      need_rebuild = true
    end

    -- Update the text if something has changed.
    if need_rebuild then
      digits_text:set_text(string.format("%03d", money_displayed))

      -- Show in green if the maximum is reached.
      if money_displayed == max_money then
        digits_text:set_font("green_digits")
      else
        digits_text:set_font("white_digits")
      end
    end

    return true  -- Repeat the timer.
  end

  -- Periodically check.
  check()
  sol.timer.start(game, 40, check)

  return rupees
end

return rupees_builder

