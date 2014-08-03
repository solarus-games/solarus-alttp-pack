# Zelda ALTTP resource pack for Solarus

This repository provides musics, sounds, tilesets and sprites
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

In the branch master of this repository, resources are always compatible with
the latest release of Solarus.
Resources compatible with older versions or development versions of Solarus
live in their own branches.

## Create a new quest with ALTTP resources

Using the ALTTP resource pack in a new quest is straightforward.

- Create a new quest with [Solarus Quest Editor](http://www.solarus-games.org/development/quest-editor]).
- Close the quest editor.
- Copy the content of this repository's `data` directory into the `data`
  directory of your quest, overwriting the existing `project_db.dat` file.

## Integrate ALTTP resources into an existing quest

This might be quite tedious if your quest already has resources with the same
id as resources of this pack.
In future versions of Solarus Quest Editor, an import feature
will make the process easier.
Here is how to proceed:

- Make a backup of your quest.
- Copy the content of this repository's `data` directory into the `data`
  directory of your quest, except `project_db.dat`.
- `project_db.dat` is the list of resources of your quest.
  Append the text of `project_db.dat` of this repository into your own
  `project_db.dat`. Make sure there are no duplicated ids.


