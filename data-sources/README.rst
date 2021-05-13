Data sources
============

This folder contains "source files" for some data of the game. That are files used to generate parts of the ``game-mod`` or data directly included in the source code.

These files are not necessary to build the game. Everything should have already be imported in versionned code. To re-generate the data from these files you should have everything you need in the ``tools/`` folder (may require some extra nerdiness.)

File types
----------

``.ora`` are characters animation data. It is an OpenRaster file with special meaning carried in layer names. You should be able to open it in any good image editor (like The Gimp or Krita.) It can be used to update the ``game-mod`` with ``tools/ora-to-char.py``.
