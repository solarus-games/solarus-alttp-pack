-- Extracts tilesets files from ffomega's Absolute Dungeon zip and puts them
-- into a quest. Renames them with better tileset ids.
-- Requires mkdir, unzip, dos2unix commands in the path.

-- TODO
-- - Extract tileset-specific sprite files too.
-- - Extract dungeon minimap tileset.
-- - Extract outside tileset.

local zip_file, quest_path = ...
if zip_file == nil or quest_path == nil then
  print("Usage: lua update_ffomega_tilesets.lua absolute_tilesets.zip quest_path")
  os.exit(1)
end

local input = io.open(zip_file)
if input == nil then
  print("Cannot open zip file " .. zip_file)
  os.exit(1)
end

input = io.open(quest_path .. "/data/quest.dat")
if input == nil then
  print("No quest was found in directory " .. quest_path)
  os.exit(1)
end

os.execute("mkdir \"" .. quest_path .. "/data/tilesets/dungeon\"")  -- Silently fails if already exists.

if os.execute("unzip \"" .. zip_file .. "\"") ~= 0 then
  print("Failed to extract zip file " .. zip_file)
  os.exit(1)
end

-- Ffomega's names to my names.
local new_tileset_ids = {
  ["Absolute Dungeon 01"] = "yellow",
  ["Absolute Dungeon 02"] = "blue",
  ["Absolute Dungeon 03"] = "light_brown",
  ["Absolute Dungeon 04"] = "green",
  ["Absolute Dungeon 05"] = "brown",
  ["Absolute Dungeon 06"] = "pink",
  ["Absolute Dungeon 07"] = "dark_brown",
  ["Absolute Dungeon 08"] = "gray_brown",
  ["Absolute Dungeon 09"] = "gray",
  ["Absolute Dungeon 10"] = "light_green",
  ["Absolute Dungeon 11"] = "light_blue",
  ["Absolute Dungeon 12"] = "gray_blue",
  ["Absolute Dungeon 13"] = "gray_pink",
  ["Absolute Dungeon 14"] = "dark_yellow",
  ["Absolute Dungeon 15"] = "purple",
  ["Absolute Dungeon 16"] = "gray_yellow",
}

for old_id, new_id in pairs(new_tileset_ids) do

  local old_prefix = "data/tilesets/" .. old_id
  local old_data_file = old_prefix .. ".dat"
  local old_tiles_file = old_prefix .. ".tiles.png"
  local old_entities_file = old_prefix .. ".entities.png"
  local new_prefix = quest_path .. "/data/tilesets/dungeon/" .. new_id
  local new_data_file = new_prefix .. ".dat"
  local new_tiles_file = new_prefix .. ".tiles.png"
  local new_entities_file = new_prefix .. ".entities.png"
  
  local _, error_message = os.rename(old_data_file, new_data_file)
  if error_message ~= nil then
    print("Failed to replace tileset data file " .. old_id .. ": " .. error_message)
    os.exit(1)
  end
  os.execute("dos2unix " .. new_data_file)  -- Nevermind if it fails.
  local _, error_message = os.rename(old_tiles_file, new_tiles_file)
  if error_message ~= nil then
    print("Failed to replace tiles PNG file " .. old_id .. ": " .. error_message)
    os.exit(1)
  end
  local _, error_message = os.rename(old_entities_file, new_entities_file)
  if error_message ~= nil then
    print("Failed to replace entities PNG file " .. old_id .. ": " .. error_message)
    os.exit(1)
  end
end

