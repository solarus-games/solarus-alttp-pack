-- Hearts view used in game screen and in the savegames selection screen.

local hearts_builder = {}

local hearts_img = sol.surface.create("hud/hearts.png")

function hearts_builder:new(game, config)

  local hearts = {}

  hearts.surface = sol.surface.create(80, 16)
  hearts.dst_x = config.x
  hearts.dst_y = config.y
  hearts.max_life_displayed = game:get_max_life()
  hearts.current_life_displayed = game:get_life()

  function hearts:repeat_danger_sound()

    if game:get_life() <= game:get_max_life() / 4 then

      sol.audio.play_sound("danger")
      hearts.danger_sound_timer = sol.timer.start(hearts, 750, function()
        hearts:repeat_danger_sound()
      end)
      hearts.danger_sound_timer:set_suspended_with_map(true)
    else
      hearts.danger_sound_timer = nil
    end
  end

  function hearts:rebuild_surface()

    hearts.surface:clear()

    local life = hearts.current_life_displayed
    local max_life = hearts.max_life_displayed
    for j = 1, max_life do
      if j % 2 == 0 then
        local x, y
        if j <= 20 then
          x = 4 * (j - 2)
          y = 0
        else
          x = 4 * (j - 22)
          y = 8
        end
        if life >= j then
          hearts_img:draw_region(0, 0, 8, 8, hearts.surface, x, y)
        else
          hearts_img:draw_region(16, 0, 8, 8, hearts.surface, x, y)
        end
      end
    end
    if life % 2 == 1 then
      local x, y
      if life <= 20 then
        x = 4 * (life - 1)
        y = 0
      else
        x = 4 * (life - 21)
        y = 8
      end
      hearts_img:draw_region(8, 0, 8, 8, hearts.surface, x, y)
    end
  end

  function hearts:on_draw(dst_surface)

    local x, y = hearts.dst_x, hearts.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    hearts.surface:draw(dst_surface, x, y + 18)
  end

  -- Checks whether the view displays correct information
  -- and updates it if necessary.
  local function check()

    local need_rebuild = false

    -- Maximum life.
    local max_life = game:get_max_life()
    if max_life ~= hearts.max_life_displayed then
      need_rebuild = true
      hearts.max_life_displayed = max_life
    end

    -- Current life.
    local current_life = game:get_life()
    if current_life == hearts.current_life_displayed then
      hearts.sound_remainder = nil
    else

      need_rebuild = true
      if current_life < hearts.current_life_displayed then
        hearts.current_life_displayed = hearts.current_life_displayed - 1
      else
        hearts.current_life_displayed = hearts.current_life_displayed + 1
        if game:is_started() then
          if hearts.sound_remainder == nil then
            hearts.sound_remainder = hearts.current_life_displayed % 4
          end
          if hearts.current_life_displayed % 4 == hearts.sound_remainder then
            sol.audio.play_sound("heart")
          end
        end
      end
    end

    -- If we are in-game, play an animation and a sound if the life is low.
    if game:is_started() then

      if game:get_life() <= game:get_max_life() / 4
          and not game:is_suspended() then
        need_rebuild = true
        if hearts.danger_sound_timer == nil then
          hearts.danger_sound_timer = sol.timer.start(hearts, 250, function()
            hearts:repeat_danger_sound()
          end)
          hearts.danger_sound_timer:set_suspended_with_map(true)
        end
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      hearts:rebuild_surface()
    end

    return true  -- Repeat the timer.
  end

  function hearts:on_started()

    -- This function is called when the HUD starts or
    -- was disabled and gets enabled again.
    -- Unlike other HUD elements, the timers were canceled because they
    -- are attached to the menu and not to the game
    -- (this is because the hearts may also be used in the savegame menu).
    hearts.danger_sound_timer = nil
    -- Periodically check.
    check()
    sol.timer.start(hearts, 50, check)
    hearts:rebuild_surface()
  end

  return hearts
end

return hearts_builder
