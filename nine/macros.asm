;
; Run-length compression for zeros
;  ZIPNT_ZEROS(n) - output n zeros (0 < n < 256)
;  ZIPZ - output one zero
;  ZIPNT_END - end of compressed sequence
;

#define ZIPNT_ZEROS(n) $00, n
#define ZIPZ $00, $01
#define ZIPNT_END $00, $00

; VECTOR(lbl) - Place data representing label's address in little endian
;#define VECTOR(lbl) .byt <lbl, >lbl
#define VECTOR(lbl) .word lbl

;
; Audio data representation
;  TIMED_OX_X(duration) - play the described note for <duration> frames
;  AUDIO_SILENCE(duration) - play no note for <duration> frames
;  SAMPLE_END - end of the sample
;  MUSIC_END - end of the music
;
; Example:
;  sample1:
;  TIMED_O2_C(20)
;  TIMED_O2_D(20)
;  TIMED_O2_E(20)
;  TIMED_O2_F(20)
;  TIMED_O2_G(20)
;  TIMED_O3_A(20)
;  TIMED_O3_B(20)
;  TIMED_O3_C(20)
;  AUDIO_SILENCE(5)
;  SAMPLE_END
;
;  music_scale_c:
;  .word sample1
;  MUSIC_END
;

#define TIMED_O1_A(duration) .byt $00, (duration << 3) + (NOTE_O1_A >> 8), (NOTE_O1_A & $ff)
#define TIMED_O1_B(duration) .byt $00, (duration << 3) + (NOTE_O1_B >> 8), (NOTE_O1_B & $ff)
#define TIMED_O1_C(duration) .byt $00, (duration << 3) + (NOTE_O1_C >> 8), (NOTE_O1_C & $ff)
#define TIMED_O1_D(duration) .byt $00, (duration << 3) + (NOTE_O1_D >> 8), (NOTE_O1_D & $ff)
#define TIMED_O1_E(duration) .byt $00, (duration << 3) + (NOTE_O1_E >> 8), (NOTE_O1_E & $ff)
#define TIMED_O1_F(duration) .byt $00, (duration << 3) + (NOTE_O1_F >> 8), (NOTE_O1_F & $ff)
#define TIMED_O1_G(duration) .byt $00, (duration << 3) + (NOTE_O1_G >> 8), (NOTE_O1_G & $ff)
#define TIMED_O2_A(duration) .byt $00, (duration << 3) + (NOTE_O2_A >> 8), (NOTE_O2_A & $ff)
#define TIMED_O2_B(duration) .byt $00, (duration << 3) + (NOTE_O2_B >> 8), (NOTE_O2_B & $ff)
#define TIMED_O2_C(duration) .byt $00, (duration << 3) + (NOTE_O2_C >> 8), (NOTE_O2_C & $ff)
#define TIMED_O2_D(duration) .byt $00, (duration << 3) + (NOTE_O2_D >> 8), (NOTE_O2_D & $ff)
#define TIMED_O2_E(duration) .byt $00, (duration << 3) + (NOTE_O2_E >> 8), (NOTE_O2_E & $ff)
#define TIMED_O2_F(duration) .byt $00, (duration << 3) + (NOTE_O2_F >> 8), (NOTE_O2_F & $ff)
#define TIMED_O2_G(duration) .byt $00, (duration << 3) + (NOTE_O2_G >> 8), (NOTE_O2_G & $ff)
#define TIMED_O3_A(duration) .byt $00, (duration << 3) + (NOTE_O3_A >> 8), (NOTE_O3_A & $ff)
#define TIMED_O3_B(duration) .byt $00, (duration << 3) + (NOTE_O3_B >> 8), (NOTE_O3_B & $ff)
#define TIMED_O3_C(duration) .byt $00, (duration << 3) + (NOTE_O3_C >> 8), (NOTE_O3_C & $ff)
#define TIMED_O3_D(duration) .byt $00, (duration << 3) + (NOTE_O3_D >> 8), (NOTE_O3_D & $ff)
#define TIMED_O3_E(duration) .byt $00, (duration << 3) + (NOTE_O3_E >> 8), (NOTE_O3_E & $ff)
#define TIMED_O3_F(duration) .byt $00, (duration << 3) + (NOTE_O3_F >> 8), (NOTE_O3_F & $ff)
#define TIMED_O3_G(duration) .byt $00, (duration << 3) + (NOTE_O3_G >> 8), (NOTE_O3_G & $ff)
#define TIMED_O4_A(duration) .byt $00, (duration << 3) + (NOTE_O4_A >> 8), (NOTE_O4_A & $ff)
#define TIMED_O4_B(duration) .byt $00, (duration << 3) + (NOTE_O4_B >> 8), (NOTE_O4_B & $ff)
#define TIMED_O4_C(duration) .byt $00, (duration << 3) + (NOTE_O4_C >> 8), (NOTE_O4_C & $ff)
#define TIMED_O4_D(duration) .byt $00, (duration << 3) + (NOTE_O4_D >> 8), (NOTE_O4_D & $ff)
#define TIMED_O4_E(duration) .byt $00, (duration << 3) + (NOTE_O4_E >> 8), (NOTE_O4_E & $ff)
#define TIMED_O4_F(duration) .byt $00, (duration << 3) + (NOTE_O4_F >> 8), (NOTE_O4_F & $ff)
#define TIMED_O4_G(duration) .byt $00, (duration << 3) + (NOTE_O4_G >> 8), (NOTE_O4_G & $ff)
#define TIMED_O5_A(duration) .byt $00, (duration << 3) + (NOTE_O5_A >> 8), (NOTE_O5_A & $ff)
#define TIMED_O5_B(duration) .byt $00, (duration << 3) + (NOTE_O5_B >> 8), (NOTE_O5_B & $ff)
#define TIMED_O5_C(duration) .byt $00, (duration << 3) + (NOTE_O5_C >> 8), (NOTE_O5_C & $ff)
#define TIMED_O5_D(duration) .byt $00, (duration << 3) + (NOTE_O5_D >> 8), (NOTE_O5_D & $ff)
#define TIMED_O5_E(duration) .byt $00, (duration << 3) + (NOTE_O5_E >> 8), (NOTE_O5_E & $ff)
#define TIMED_O5_F(duration) .byt $00, (duration << 3) + (NOTE_O5_F >> 8), (NOTE_O5_F & $ff)
#define TIMED_O5_G(duration) .byt $00, (duration << 3) + (NOTE_O5_G >> 8), (NOTE_O5_G & $ff)
#define TIMED_O6_A(duration) .byt $00, (duration << 3) + (NOTE_O6_A >> 8), (NOTE_O6_A & $ff)
#define TIMED_O6_B(duration) .byt $00, (duration << 3) + (NOTE_O6_B >> 8), (NOTE_O6_B & $ff)
#define TIMED_O6_C(duration) .byt $00, (duration << 3) + (NOTE_O6_C >> 8), (NOTE_O6_C & $ff)
#define TIMED_O6_D(duration) .byt $00, (duration << 3) + (NOTE_O6_D >> 8), (NOTE_O6_D & $ff)
#define TIMED_O6_E(duration) .byt $00, (duration << 3) + (NOTE_O6_E >> 8), (NOTE_O6_E & $ff)
#define TIMED_O6_F(duration) .byt $00, (duration << 3) + (NOTE_O6_F >> 8), (NOTE_O6_F & $ff)
#define TIMED_O6_G(duration) .byt $00, (duration << 3) + (NOTE_O6_G >> 8), (NOTE_O6_G & $ff)
#define TIMED_O7_A(duration) .byt $00, (duration << 3) + (NOTE_O7_A >> 8), (NOTE_O7_A & $ff)
#define TIMED_O7_B(duration) .byt $00, (duration << 3) + (NOTE_O7_B >> 8), (NOTE_O7_B & $ff)
#define TIMED_O7_C(duration) .byt $00, (duration << 3) + (NOTE_O7_C >> 8), (NOTE_O7_C & $ff)
#define TIMED_O7_D(duration) .byt $00, (duration << 3) + (NOTE_O7_D >> 8), (NOTE_O7_D & $ff)
#define TIMED_O7_E(duration) .byt $00, (duration << 3) + (NOTE_O7_E >> 8), (NOTE_O7_E & $ff)
#define TIMED_O7_F(duration) .byt $00, (duration << 3) + (NOTE_O7_F >> 8), (NOTE_O7_F & $ff)
#define TIMED_O7_G(duration) .byt $00, (duration << 3) + (NOTE_O7_G >> 8), (NOTE_O7_G & $ff)
#define TIMED_O8_A(duration) .byt $00, (duration << 3) + (NOTE_O8_A >> 8), (NOTE_O8_A & $ff)
#define TIMED_O8_B(duration) .byt $00, (duration << 3) + (NOTE_O8_B >> 8), (NOTE_O8_B & $ff)
#define TIMED_O8_C(duration) .byt $00, (duration << 3) + (NOTE_O8_C >> 8), (NOTE_O8_C & $ff)
#define TIMED_O8_D(duration) .byt $00, (duration << 3) + (NOTE_O8_D >> 8), (NOTE_O8_D & $ff)
#define TIMED_O8_E(duration) .byt $00, (duration << 3) + (NOTE_O8_E >> 8), (NOTE_O8_E & $ff)
#define TIMED_O8_F(duration) .byt $00, (duration << 3) + (NOTE_O8_F >> 8), (NOTE_O8_F & $ff)

#define AUDIO_SILENCE(duration) .byt $01, duration, $00

#define SAMPLE_END .byt $02, $00, $00
#define MUSIC_END .byt $00, $00

;
; Animation data representation
;  ANIM_FRAME_BEGIN(duration) - animation frame header
;  ANIM_FRAME_END - animation frame footer
;  ANIM_ANIMATION_END - animation footer
;  ANIM_SPRITE(y,tile,attr,x) - sprite description
;  ANIM_SPRITE_FOREGROUND(y,tile,attr,x) - sprite alway drawn on top of others
;
; Example:
;  animation_data:
;  ; Frame 1
;  ANIM_FRAME_BEGIN(32)
;  ANIM_SPRITE_FOREGROUND($f9, TILE_PARTY_HAT, $01, $00) ; Y, tile, attr, X
;  ANIM_SPRITE($00, TILE_OPEN_ARMS_SINBAD_HEAD, $00, $00)
;  ANIM_SPRITE($08, TILE_OPEN_ARMS_SINBAD_BODY, $00, $00)
;  ANIM_FRAME_END
;  ; Frame 2
;  ANIM_FRAME_BEGIN(32)
;  ANIM_SPRITE_FOREGROUND($f9, TILE_PARTY_HAT, $01, $ff) ; Y, tile, attr, X
;  ANIM_SPRITE($00, TILE_OPEN_ARMS_SINBAD_HEAD, $40, $00)
;  ANIM_SPRITE($08, TILE_OPEN_ARMS_SINBAD_BODY, $40, $00)
;  ANIM_FRAME_END
;  ; End of animation
;  ANIM_ANIMATION_END
;

#define ANIM_FRAME_BEGIN(duration) .byt duration
#define ANIM_FRAME_END .byt $00

#define ANIM_ANIMATION_END .byt $00

#define ANIM_SPRITE(y,tile,attr,x) .byt $01, y, tile, attr, x
#define ANIM_SPRITE_FOREGROUND(y,tile,attr,x) .byt $11, y, tile, attr, x
