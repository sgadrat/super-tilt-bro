Memory usage per component
==========================

Engine
------

Summary::

* Each frame: 14 bytes
* Peak: 68 bytes

Detail::

* Each frame: 7 bytes for player A's palette
* Each frame: 7 bytes for player B's palette
* When needed: 7 bytes for player A's damage
* When needed: 7 bytes for player B's damage
* When needed: 20 bytes for player A's stocks (4 buffers of 5 bytes)
* When needed: 20 bytes for player B's stocks (4 buffers of 5 bytes)

Stage: The Hunt
---------------

Summary::

* Each frame: 6 bytes
* Peak: 6 bytes

Detail::

* Each frame: 6 bytes for lava's palette swap

Character: VGSage
-----------------

Summary::

* Each frame: 0 byte
* Peak: 79 bytes

Detail::

* When needed: 20 bytes for fadout/fadein effects of the punch
* When needed: 65 bytes for Knight's illustration
