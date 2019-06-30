# Super Tilt Bro

Nintendo's consoles before the N64 do not have their Super Smash Bros game. Let's fix it! Super Tilt Bro is a NES hombrew project aiming at porting the "versus platformer fighting" to this good old system that made our childhood.

Last tagged build is [playable here](https://sgadrat.itch.io/super-tilt-bro).

## Building

You will need the XA cross assembler for 6502. It may be found on Archlinux in the package "community/xa", on ubuntu in the package "xa65"  and for others you may find information [here](http://www.floodgap.com/retrotech/xa/).

You will also need python >= 3.2 and the pillow library.

From the source repository run
```
./build.sh
```

It will generate the game as `Super_Tilt_Bro_(E).nes`. If any problem occurs you may find clues in the `build.log` file.

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
