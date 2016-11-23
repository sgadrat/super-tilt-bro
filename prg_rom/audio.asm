audio_init:
.(
; Enable used channels
lda #%00001001 ; ---DNT21
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

audio_play_parry:
.(
lda #%00000100         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%10001101       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%00001000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_music_tick:
.(
; Decrement note counter
;  When it reach 0 mute the music for one frame
;  When it reach -1, begin to play the next note
lda audio_note_counter
cmp #$ff
beq next_note
cmp #0
bne dec_note_counter
lda #%10110000
sta APU_SQUARE1_ENVELOPE
dec_note_counter:
dec audio_note_counter
jmp end
next_note:

; Point on next note
lda audio_counter
asl
tax

; Play the note
lda #%10111111           ; DDLCVVVV
sta APU_SQUARE1_ENVELOPE ;
lda #%01000000         ; EPPPNSSS
sta APU_SQUARE1_PERIOD ;
lda music+1, x            ; TTTTTTTT
sta APU_SQUARE1_TIMER_LOW ;
lda music, x               ; LLLLLTTT
sta APU_SQUARE1_LENGTH_CNT ;

; Save duration to note counter
lsr
lsr
lsr
sta audio_note_counter

; Prepare next note
inc audio_counter
lda audio_counter
cmp #14
bne end
lda #0
sta audio_counter

end:
rts
.)
