# Zelda ALTTP resource pack for Solarus

This repository provides musics, sounds, tilesets, sprites and scripts
from Legend of Zelda: A Link to the Past
for the
[Solarus engine](https://github.com/christopho/solarus).

You can use these resources if you want to develop a game with the
Solarus engine using Zelda ALTTP graphics.

One goal of this resource pack is also to provide at least all
[data files required by Solarus](https://github.com/christopho/solarus/blob/master/work/data_files.txt).

Since Zelda: A Link to the Past is huge,
there will always be missing or incomplete elements.
Feel free to contribute!

Also, there may be unwanted elements,
typically, resources that don't come from Zelda ALTTP
but that were created for Zelda Mystery of Solarus DX
and ended up here.
If you find such inconsistencies, please report them by
opening an issue.

## Branches

Branch master always points to the latest release of this resource pack.

The latest resource pack release is always compatible
with the latest Solarus version.


Resources compatible with older versions or development versions of Solarus
live in their own branches.

## Create a new quest with ALTTP resources

Using the ALTTP resource pack for a new quest is straightforward.
The idea is to create your quest as a copy of the ALTTP resource pack
rather than creating it from the quest editor:

- Create a new empty folder for your quest.
- Copy the `data` folder of the ALTTP resource pack and all its content
  into your quest's folder.
- You can now open your new quest with
  [Solarus Quest Editor](http://www.solarus-games.org/development/quest-editor]).
- Edit the quest properties (Ctrl+P) to set a title, a write directory
  and other information of your game.

## Integrate ALTTP resources into an existing quest

This might be quite tedious if your quest already has resources with the same
id as resources of this pack.
In future versions of Solarus Quest Editor, an import feature
will make the process easier.
Here is how to proceed:

- Make a backup of your quest.
- Copy the content of this repository's `data` directory into the `data`
  directory of your quest, except `project_db.dat`.
  (`project_db.dat` is the list of your quest and you don't want to lose the
  existing ones.)
  If you don't want the whole pack but only a few sprites, tilesets or sounds,
  you can also only pick the resources you need.
- Open your quest with
  [Solarus Quest Editor](http://www.solarus-games.org/development/quest-editor]).
- In the quest tree, all resources you just copied now appear with an
  interrogation mark icon.
  You can right-click them to add them to the quest.

