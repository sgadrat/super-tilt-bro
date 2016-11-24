audio_init:
.(
; Enable used channels
lda #%00001011 ; ---DNT21
sta APU_STATUS ;

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

audio_music_tick:
.(
music = tmpfield3
audio_counter = tmpfield5
audio_note_counter = tmpfield6
square_registers = tmpfield7

lda #<music_square1
sta music
lda #>music_square1
sta music+1
lda audio_square1_counter
sta audio_counter
lda audio_square1_note_counter
sta audio_note_counter
lda #$00
sta square_registers
jsr square_channel_tick
lda audio_counter
sta audio_square1_counter
lda audio_note_counter
sta audio_square1_note_counter

lda #<music_square2
sta music
lda #>music_square2
sta music+1
lda audio_square2_counter
sta audio_counter
lda audio_square2_note_counter
sta audio_note_counter
lda #$04
sta square_registers
jsr square_channel_tick
lda audio_counter
sta audio_square2_counter
lda audio_note_counter
sta audio_square2_note_counter

rts

square_channel_tick:
.(
; Decrement note counter
;  When it reach 0 mute the music for one frame
;  When it reach -1, begin to play the next note
lda audio_note_counter
cmp #$ff
beq next_note
cmp #0
bne dec_note_counter
ldx #$00
lda #%10110000
sta $4000, x
dec_note_counter:
dec audio_note_counter
jmp end
next_note:

; Point on next entry
lda audio_counter
clc
adc audio_counter
adc audio_counter
tay

lda (music), y
asl
tax
lda opcodes, x
sta tmpfield1
lda opcodes+1, x
sta tmpfield2
jmp (tmpfield1)

loop:
lda #$ff
sta audio_counter
sta audio_note_counter
jmp next_entry

silence:
lda #$00
jsr point_to_register
lda #%10110000 ; DDLCVVVV
sta $4000, x   ;
iny
lda (music), y
sta audio_note_counter
jmp next_entry

play_note:
; Play the note
lda #$00
jsr point_to_register
lda #%10110100 ; DDLCVVVV
sta $4000, x   ;
lda #$01
jsr point_to_register
lda #%01000000 ; EPPPNSSS
sta $4000, x   ;
iny
iny
lda #$02
jsr point_to_register
lda (music), y ; TTTTTTTT
sta $4000, x   ;
dey
lda #$03
jsr point_to_register
lda (music), y ; LLLLLTTT
sta $4000, x   ;

; Save duration to note counter
lsr
lsr
lsr
sta audio_note_counter

next_entry:
; Prepare next entry
inc audio_counter

end:
rts

; Opcodes jump table
opcodes:
.word play_note, silence, loop
.)

point_to_register:
.(
clc
adc square_registers
tax
rts
.)
.)
