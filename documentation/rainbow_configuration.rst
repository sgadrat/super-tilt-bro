Rainbow config for Super Tilt Bro.
==================================

Super Tilt Bro. uses few features aside the internet connectivity. Also, care is taken to stay as close as UNROM-512 as possible to propose an offline ROM file for UNROM-512.

Most Rainbow configuration is done in ``game/logic/mapper_init.asm`` and doesn't change after that.

Memory map
----------

* $0000-$07ff: system memory
* $4800-$4fff: FPGA-RAM high 2 KB (mirrors $7800-$7fff)
* $6000-$7fff: FPGA-RAM full 8 KB
* $8000-$bfff: Swapable bank
* $c000-$ffff: Fixed bank

ROM banking
-----------

Fixed bank: Mapped at $c000-$ffff, the code does not expect it to be swapped.

Swappable bank: Mapped at $8000-bfff, the code swap's it at will.

RAM layout
----------

System RAM
~~~~~~~~~~

Mapped at $0000-$07ff, the standard NES RAM.

FPGA-RAM
~~~~~~~~

8 KB from the FPGA on the Rainbow cart are available. Can only be used safely in online parts of the game as they are not on UNROM-512 boards.

Configured to be permanently mapped at $6000-$7fff. The last 2 KB of it is also mirrored at $4800-$4fff (mirror of $7800-$7fff.)

$4800-$48ff is configured as the Rainbow RX buffer, the code expects it to never change.

$4900-$49ff is configured as the Rainbow TX buffer, the code expects it to never change.

PRG-RAM
~~~~~~~

Super Tilt Bro. does not use Rainbow PRG-RAM and shall never try to access it. Carts can safely be produced ommiting this chip.
