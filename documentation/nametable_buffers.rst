Memory usage per component
==========================

Engine
------

Summary::

* Each frame: 14 bytes (unprotected)
* Peak: 68 bytes (unprotected)

Detail::

* Each frame: 7 bytes for player A's palette
* Each frame: 7 bytes for player B's palette
* When needed: 7 bytes for player A's damage
* When needed: 7 bytes for player B's damage
* When needed: 20 bytes for player A's stocks (4 buffers of 5 bytes)
* When needed: 20 bytes for player B's stocks (4 buffers of 5 bytes)

Stages
------

Stages have to handle fadeout and screen restore. They mostly share the same code, so here is the stage's impact if not specified.

Summary::

* Each frame: 0 byte
* Peak: 36 bytes (protected) + 0 byte (unprotected)

Detail::

* When needed (protected): 20 bytes for fadeout
* When needed (protected): 36 bytes for repair (only if no fadeout occuring)

Stage: The Hunt
---------------

Summary::

* Each frame: 6 bytes (protected) + 0 byte (unprotected)
* Peak: 36 bytes (protected) + 0 byte (unprotected)

Detail::

* Each frame (protected): 6 bytes for lava's palette swap
* When needed (protected): 20 bytes for fadeout
* When needed (protected): 36 bytes for repair

Notes::

* Will each frame do lava's animation, or fadeout, or repair (only one out of the three)

Character: VGSage
-----------------

Summary::

* Each frame: 0 byte
* Peak: 79 bytes (protected) + 0 byte (unprotected)

Detail::

* When needed (protected): 20 bytes for fadout/fadein effects of the punch
* When needed (protected): 36 bytes for Knight's animation
* When needed (protected): 65 bytes for Knight's illustration
