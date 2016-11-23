audio_init:
.(
; Enable noise channel
lda #%00001000 ; ---DNT21
sta APU_STATUS ;

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
