# Super Tilt Bro

Nintendo's consoles before the N64 do not have their Super Smash Bros game. Let's fix it! Super Tilt Bro is a NES hombrew project aiming at porting the "versus platformer fighting" to this good old system that made our childhood.

Last tagged build is [playable here](https://sgadrat.itch.io/super-tilt-bro).

## Building

Build dependencies
------------------

- XA cross assembler for 6502.
  - Actually a fork of it, with increased memory limits. You can find it [here](https://github.com/sgadrat/xa65-stb).
- 6502-gcc
  - [Build it from](https://github.com/itszor/gcc-6502-bits)
- Huffmunch
  - [Build it from](https://github.com/bbbradsmith/huffmunch)
- python >= 3.2
- pillow library for python

A script to get all dependencies built and setup is in `deps/`.

(You may still want to install python and pillow by yourself, the script will install it only it it has root privilege.)

```
$ deps/build-deps.sh
```

Building
--------

If you built dependencies in `deps/`, from the source repository run
```
$ XA_BIN=$(pwd)/deps/xa65-stb/xa/xa CC_BIN=$(pwd)/deps/gcc-6502-bits/prefix/bin/6502-gcc HUFFMUNCH_BIN=$(pwd)/deps/huffmunch/huffmunch ./build.sh
```

It will generate the game as `Super_Tilt_Bro_(E).nes`. If any problem occurs you may find clues in the `build.log` file.

Note: `Super_Tilt_Bro_(E).nes` requires the support for the RAINBOW mapper, which is not yet included in any emulator. You can play it with a fork of FCEUX [here](https://github.com/sgadrat/fceux/tree/rainbow-stable) or play `tilt_no_network_unrom_(E).nes` (without networking) in any emulator.

## Playing

You will need a NES emulator with two controllers configured. Each controller controls a character and the goal is to send the other out of screen.

Controller mapping:
```
          Jump
            |
Move left   |      Unused   Unused
     |   +--+         |        |
+----|---|------------|--------|------------------------+
|    |   |            |        |                        |
|    | +-|-+          |        |                        |
|    | | o |          |        |                        |
|  +-|-+   +---+      |        |                        |
|  | o       o |      o        o        ---     ---     |
|  +---+   +-|-+   (select) (start)    ( B )   ( A )    |
|      | o | |                          -o-     -o-     |
|      +-|-+ |                           |       |      |
+--------|---|---------------------------|-------|------+
         |   +---+                       |       +---+
       Shield    |                 Special moves     |
                 |                                   |
            Move right                            Attacks
```

You can use different moves by holding a direction when pressing the attack or special move button.
