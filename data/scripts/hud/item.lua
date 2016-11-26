-- An icon that shows the inventory item assigned to a slot.

local item_icon_builder = {}

local background_img = sol.surface.create("hud/item_icon.png")

function item_icon_builder:new(game, config)

  local item_icon = {}

  item_icon.slot = config.slot or 1
  item_icon.surface = sol.surface.create(22, 22)
  item_icon.item_sprite = sol.sprite.create("entities/items")
  item_icon.item_displayed = nil
  item_icon.item_variant_displayed = 0

  local dst_x, dst_y = config.x, config.y

  function item_icon:rebuild_surface()

    item_icon.surface:clear()

    -- Background image.
    background_img:draw(item_icon.surface)

    if item_icon.item_displayed ~= nil then
      -- Item.
      item_icon.surface:fill_color({0, 0, 0}, 3, 3, 16, 16)
      item_icon.item_sprite:draw(item_icon.surface, 3 + 8, 3 + 13)
    end
  end

  function item_icon:on_draw(dst_surface)

    local x, y = dst_x, dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    item_icon.surface:draw(dst_surface, x, y)
  end

  local function check()

    local need_rebuild = false

    -- Item assigned.
    local item = game:get_item_assigned(item_icon.slot)
    if item_icon.item_displayed ~= item then
      need_rebuild = true
      item_icon.item_displayed = item
      item_icon.item_variant_displayed = nil
      if item ~= nil then
        item_icon.item_sprite:set_animation(item:get_name())
      end
    end

    if item ~= nil then
      -- Variant of the item.
      local item_variant = item:get_variant()
      if item_icon.item_variant_displayed ~= item_variant then
        need_rebuild = true
        item_icon.item_variant_displayed = item_variant
        item_icon.item_sprite:set_direction(item_variant - 1)
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      item_icon:rebuild_surface()
    end

    return true  -- Repeat the timer.
  end

  -- Periodically check.
  check()
  sol.timer.start(game, 50, check)
  item_icon:rebuild_surface()

  return item_icon
end

return item_icon_builder


