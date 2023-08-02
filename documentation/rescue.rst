Super Tilt Bro.'s rescue
========================

Introduction
------------

Super Tilt Bro. can be updated online. There are a handful of ways it can go wrong: power-off during update, corrupted updated file, incorectly flashed bytes, ... In almost all cases, it can make the game cart unusable.

To easily recover from that, the Rainbow cart comes with a rescue mode, re-flashing the game with the original version flashed at factory. Making the game usable again.

Note that it is an easy way to fix the cart. For more advanced users it may be prefereable to use the BrokeStudio's bootrom and it's more flexible tools.

Vocabulary:
 - BrokeStudio's bootrom: Standard bootrom and menus in rainbow carts. (START+SELECT at boot)
 - Boot code: Boot code that is executed before game code only on rainbow carts.
 - Rescue mode: Menu to reset the flash to factory state. (START+B at boot)
 - Flash / ROM: The flash chip containing Super Tilt Bro.'s code, including the game, boot code and rescue mode.
 - Game: Super Tilt Bro.'s code common to all mappers versions

Flash Layout
------------

::

	+--------------------------------------------------+---------------------+
	| Boot sector |                 Game               |        Backup       |
	|    64 KB    |                512 KB              |        448 KB       |
	+-------------+------------------------------------+---------------------+

The flash capacity is the double of the game's size. It allows to store the boot code, rescue mode and a compressed backup of the game alongside the game.

The flash's space is split in three regions:
 - The boot sector contains the boot code and rescue mode
 - The game is stored after it
 - A compressed backup of the game is stored at the end of the flash's space.

Be it by the update process or by the rescue mode, only the game region can be re-writen.

Note: The game is not stored at the begining or the end of the flash. Some models have different-sized sectors at this places, we don't want to have to handle it.

Backup region
-------------

The backup region contains:
 - some free space,
 - a compressed version of Game,
 - a list of CRC-32 for each KB of Game,
 - an index to find compressed data banks.

The region is organized in 16 KB banks.

Free banks are place at the begining of the region, allowing future reuse to expand Game's size.

Banks of compressed data contain a blob of Huffmunch compressed data. Each stream in the blob is 256 bytes of uncompressed data. A bank contains multiple streams.

The last bank contains the CRC-32 list, and an index of which stream can be found in which bank of compressed data.

Rescue algorithm
----------------

::

	For each 64 KB sector of the Game region
		- Erase the sector
		- For each 1 KB segment of the sector
			- For each 256 bytes page in the sector
				- Locate corresponding compressed stream with the index
				- Decompress the stream in RAM
				- Program the 256 bytes in Flash
			- Verify segment's CRC-32 against the one in the backup region

For more details, read the code:
 - Rescue mode and boot code can be found in the ``rainbow_boot/`` directory
 - Backup region is built by ``build.sh``
 - Compression is done by Brad Smith's Huffmunch: https://github.com/bbbradsmith/huffmunch
