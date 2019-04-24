audio_music_power:
.(
lda audio_music_enabled
beq disabled
lda #%00001111 ; ---DNT21
sta APU_STATUS ;
jmp end_enabled_check
disabled:
lda #%00001000 ; ---DNT21
sta APU_STATUS ;
end_enabled_check:

lda #%01111100 ; DDLCVVVV
sta audio_duty

lda #<track_main_square1
sta audio_square1_track
lda #>track_main_square1
sta audio_square1_track+1

lda #<track_main_square2
sta audio_square2_track
lda #>track_main_square2
sta audio_square2_track+1

lda #<track_main_triangle
sta audio_triangle_track
lda #>track_main_triangle
sta audio_triangle_track+1

jsr audio_reset_music

rts
.)

audio_music_weak:
.(
lda audio_music_enabled
beq disabled
lda #%00001011 ; ---DNT21
sta APU_STATUS ;
jmp end_enabled_check
disabled:
lda #%00001000 ; ---DNT21
sta APU_STATUS ;
end_enabled_check:

lda #%00000100 ; DDLCVVVV
sta audio_duty

lda #<track_menus_square1
sta audio_square1_track
lda #>track_menus_square1
sta audio_square1_track+1

lda #<track_menus_square2
sta audio_square2_track
lda #>track_menus_square2
sta audio_square2_track+1

lda #<track_menus_triangle
sta audio_triangle_track
lda #>track_menus_triangle
sta audio_triangle_track+1

jsr audio_reset_music

rts
.)

audio_music_gameover:
.(
lda audio_music_enabled
beq disabled
lda #%00001011 ; ---DNT21
sta APU_STATUS ;
jmp end_enabled_check
disabled:
lda #%00001000 ; ---DNT21
sta APU_STATUS ;
end_enabled_check:

lda #%01111100 ; DDLCVVVV
sta audio_duty

lda #<track_gameover_square1
sta audio_square1_track
lda #>track_gameover_square1
sta audio_square1_track+1

lda #<track_gameover_square2
sta audio_square2_track
lda #>track_gameover_square2
sta audio_square2_track+1

lda #<track_gameover_triangle
sta audio_triangle_track
lda #>track_gameover_triangle
sta audio_triangle_track+1

jsr audio_reset_music

rts
.)

audio_play_crash:
.(
lda #%00000100         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%00001100       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%00001000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_death:
.(
lda #%00000100         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%10001101       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%00001000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_hit:
.(
lda #%00000100         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%00000111       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%10110000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_parry:
.(
lda #%00000010         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%00000111       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%10110000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_shield_hit:
.(
lda #%00000010         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%00000111       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%10110000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_shield_break:
.(
lda #%00000100         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%00001011       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%10110000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)
