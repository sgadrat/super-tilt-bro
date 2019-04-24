audio_init:
.(
jsr audio_mute_music
rts
.)

audio_mute_music:
.(
lda #$00
sta audio_music_enabled

lda #%00001000 ; ---DNT21
sta APU_STATUS ;

rts
.)

audio_unmute_music:
.(
lda #$01
sta audio_music_enabled

lda #%00001011 ; ---DNT21
sta APU_STATUS ;
rts
.)

audio_reset_music:
.(
lda #$00
ldx #0
reset_counter:
sta audio_square1_track_counter, x
sta audio_square1_sample_counter, x
sta audio_square1_note_counter, x
inx
cpx #3
bne reset_counter

rts
.)

audio_music_tick:
.(
track = tmpfield1 ; note that it is overriden by square_channel_tick
sample = tmpfield3
audio_counter = tmpfield5
audio_note_counter = tmpfield6
square_registers = tmpfield7
next_sample = tmpfield8

.(
lda audio_music_enabled
beq end

ldx #0
jsr channel_tick

ldx #1
jsr channel_tick

ldx #2
jsr channel_tick

end:
rts
.)

; A tick on any channel
;  register X - 0 = square1 ; 1 = square2 ; 2 = triangle
channel_tick:
.(
; Set channel mode
#define AUDIO_TRIANGLE_CHANNEL_NUM 2
lda #AUDIO_CHANNEL_SQUARE
cpx #AUDIO_TRIANGLE_CHANNEL_NUM
bne store_mode
lda #AUDIO_CHANNEL_TRIANGLE
store_mode:
sta audio_channel_mode

; Store track vector to fixed location
txa
asl
tax
lda audio_square1_track, x
sta track
lda audio_square1_track+1, x
sta track+1

; Store sample vector to a fixed location
txa
lsr
tax
lda audio_square1_track_counter, x
asl
tay
lda (track), y
sta sample
iny
lda (track), y
sta sample+1

; Store in-sample counters to a fixed location
lda audio_square1_sample_counter, x
sta audio_counter
lda audio_square1_note_counter, x
sta audio_note_counter

; Store where to find channel's registers ($4000 + chan_num * 4)
txa
asl
asl
sta square_registers

; Reset next sample indicator
lda #0
sta next_sample

; Do the hard work
txa
pha
jsr square_channel_tick
pla
tax

; Store advanced counters to there reserved location
lda audio_counter
sta audio_square1_sample_counter, x
lda audio_note_counter
sta audio_square1_note_counter, x

; Point to the next sample if requested
lda next_sample     ; Check that next sample was requested
beq end_next_sample ;

inc audio_square1_track_counter, x ; Increment sample's counter

txa                                 ;
asl                                 ;
tax                                 ;
                                    ;
lda audio_square1_track, x          ;
sta track                           ;
lda audio_square1_track+1, x        ;
sta track+1                         ; Get MSB of new sample's adress
                                    ;
txa                                 ;
lsr                                 ;
tax                                 ;
                                    ;
lda audio_square1_track_counter, x  ;
asl                                 ;
tay                                 ;
iny                                 ;
lda (track), y                      ;

bne end_next_sample                 ;
sta audio_square1_track_counter, x  ; Loop if sample's MSB is zero
end_next_sample:                    ;

rts
.)

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

lda audio_channel_mode ; Hack, do not mute for triangle at the end of a note
bne next_note          ;
jsr mute_current_channel

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

lda (sample), y
asl
tax
lda opcodes, x
sta tmpfield1
lda opcodes+1, x
sta tmpfield2
jmp (tmpfield1)

loop:
.(
lda #$ff
sta audio_counter
sta audio_note_counter
sta next_sample
jmp next_entry
.)

silence:
.(
jsr mute_current_channel
iny
lda (sample), y
sta audio_note_counter
jmp next_entry
.)

play_note:
.(
; Play the note
lda audio_channel_mode
cmp #AUDIO_CHANNEL_TRIANGLE
beq play_triangle

lda #$00
jsr point_to_register
lda audio_duty
sta $4000, x
lda #$01
jsr point_to_register
lda #%01000000 ; EPPPNSSS
sta $4000, x   ;
iny
iny
lda #$02
jsr point_to_register
lda (sample), y ; TTTTTTTT
sta $4000, x   ;
dey
lda #$03
jsr point_to_register
lda (sample), y ; DDDDDTTT (with D being the note's duration in video frames)
and #%00000111 ; Replace D by a big L value
ora #%00001000 ;
sta $4000, x ; LLLLLTTT
lda (sample), y ; Reload D, save_duration needs it in register A
jmp save_duration

play_triangle:
lda #%10000001 ; CRRRRRRR
sta $4008      ;
iny
iny
lda (sample), y ; TTTTTTTT
sta $400a       ;
dey
lda (sample), y ; LLLLLTTT
sta $400b       ;

; Save duration to note counter
save_duration:
lsr
lsr
lsr
sta audio_note_counter
.)

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

mute_current_channel:
.(
lda audio_channel_mode
cmp #AUDIO_CHANNEL_TRIANGLE
beq mute_triangle

; Mute a square channel
lda #$00
jsr point_to_register
lda #%10110000 ; DDLCVVVV
sta $4000, x   ;
jmp end

mute_triangle:
;lda #%00001011 ; ---DNT21
;sta APU_STATUS ;
lda #%00000000
sta APU_TRIANGLE_LINEAR_CNT ; CRRRRRRR
sta APU_TRIANGLE_LENGTH_CNT ; LLLLLTTT

end:
rts
.)
.)
