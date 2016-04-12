* = 0 ; We just use * to count position in the CHR-rom, begin with zero is easy

; TILE $00
;
; XXXXXXXX
; XooooooX
; XooooooX
; XooooooX
; XooooooX
; XooooooX
; XooooooX
; XXXXXXXX
.byt $FF, $81, $81, $81, $81, $81, $81, $FF
.byt $00, $7E, $7E, $7E, $7E, $7E, $7E, $00

; TILE $01
;
; XXXXXXXX
; XooooooX
; XooooooX
; Xoo##ooX
; Xoo##ooX
; XooooooX
; XooooooX
; XXXXXXXX
.byt $FF, $81, $81, $81, $81, $81, $81, $FF
.byt $00, $7E, $7E, $66, $66, $7E, $7E, $00

; TILE $02
;
; XXXXXXXX
; XooooooX
; Xooo##oX
; Xooo##oX
; Xo##oooX
; Xo##oooX
; XooooooX
; XXXXXXXX
.byt $FF, $81, $81, $81, $81, $81, $81, $FF
.byt $00, $7E, $72, $72, $4E, $4E, $7E, $00

; TILE $03
;
; XXXXXXXX
; Xoooo##X
; Xoooo##X
; Xoo##ooX
; Xoo##ooX
; X##ooooX
; X##ooooX
; XXXXXXXX
.byt $FF, $81, $81, $81, $81, $81, $81, $FF
.byt $00, $78, $78, $66, $66, $1E, $1E, $00

#if $1000-* < 0
#echo *** Error: VRAM bank1 data occupies too much space 
#else
.dsb $1000-*, 0
#endif

; TILE $00
;
; 00000000
; 00000000
; 11111111
; 11111111
; 22222222
; 22222222
; 33333333
; 33333333
.byt $00, $00, $00, $00, $ff, $ff, $ff, $ff
.byt $00, $00, $ff, $ff, $00, $00, $ff, $ff

; TILE $01
;
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
.byt $00, $00, $00, $00, $00, $00, $00, $00
.byt $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

#if $2000-* < 0
#echo *** Error: VRAM bank2 data occupies too much space 
#else
.dsb $2000-*, 0
#endif
