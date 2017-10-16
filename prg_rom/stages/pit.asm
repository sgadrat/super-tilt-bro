#define STAGE_PIT_MOVING_PLATFORM_1_OFFSET 10
#define STAGE_PIT_MOVING_PLATFORM_2_OFFSET 14

#define STAGE_PIT_MOVING_PLATFORM_SPRITES $20
#define STAGE_PIT_NB_MOVING_PLATFORM_SPRITES 8


#define STAGE_PIT_PLATFORM_MAX_HEIGHT 64
#define STAGE_PIT_PLATFORM_MIN_HEIGHT 200

stage_pit_init:
.(
; Generic initialization stuff
jsr stage_generic_init

; Set stage's state
lda #1
sta stage_pit_platform1_direction
lda #$ff
sta stage_pit_platform2_direction

; Place moving platform sprites
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP ;
clc
adc #15
sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4                                                 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4                                             ; Y positions
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4                                             ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4                                             ;
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_2_OFFSET+STAGE_PLATFORM_OFFSET_TOP ;
clc
adc #15
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4                                             ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4                                             ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4                                             ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4                                             ;

lda #TILE_MOVING_PLATFORM                                ;
sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4+1     ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4+1 ; Tile number
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4+1 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4+1 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4+1 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4+1 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4+1 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4+1 ;

lda #%00000011                                           ;
sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4+2     ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4+2 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4+2 ; Attributes
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4+2 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4+2 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4+2 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4+2 ;
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4+2 ;

lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_LEFT ;
clc
adc #7
sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4+3                                                ;
adc #8
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4+3                                            ;
adc #8
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4+3                                            ; X positions
adc #8
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4+3                                            ;
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_2_OFFSET+STAGE_PLATFORM_OFFSET_LEFT ;
adc #7
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4+3                                            ;
adc #8
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4+3                                            ;
adc #8
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4+3                                            ;
adc #8
sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4+3                                            ;

rts
.)

stage_pit_tick:
.(
; Change platforms direction
ldy #0 ; Y = platform index
ldx #0 ; X = platform offset in stage data from first moving platform
change_one_platform_direction:

lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP, x
cmp #STAGE_PIT_PLATFORM_MAX_HEIGHT
beq change_direction
cmp #STAGE_PIT_PLATFORM_MIN_HEIGHT
bne next_platform

change_direction:
lda stage_pit_platform1_direction, y
eor #%11111111
clc
adc #1
sta stage_pit_platform1_direction, y

next_platform:
ldx #STAGE_SMOOTH_PLATFORM_LENGTH
iny
cpy #2
bne change_one_platform_direction

ldx #0
ldy #0
lda stage_pit_platform1_direction
sta tmpfield4

check_one_player_one_platform:

; Move players that are on platforms
;  Note - Player's subpixel is not accounted,
;         we prefer to move a player that is not really grounded
;         than moving the platform through him
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_LEFT, y
sta tmpfield1
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_RIGHT, y
sta tmpfield2
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP, y
sta tmpfield3
lda player_a_y_low, x
pha
lda #$ff
sta player_a_y_low, x
jsr check_on_platform
bne next_check

lda player_a_y, x
clc
adc tmpfield4
sta player_a_y, x

next_check:
pla
sta player_a_y_low, x
inx
cpx #2
bne check_one_player_one_platform

; Move platform in stage's data
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP, y
clc
adc tmpfield4
sta stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP, y

; Prepare next platform
cpy #STAGE_SMOOTH_PLATFORM_LENGTH
beq end_move_platforms
ldy #STAGE_SMOOTH_PLATFORM_LENGTH
ldx #0
lda stage_pit_platform2_direction
sta tmpfield4
jmp check_one_player_one_platform

end_move_platforms:

; Move first platforms' sprites
ldx #0 ; X = sprite's offset from first platform's first sprite
ldy #0 ; Y = platform index
move_one_sprite:

cpx #STAGE_PIT_NB_MOVING_PLATFORM_SPRITES*4/2 ;
bne end_platform_change                       ; Check if we just changed platform
iny                                           ;
end_platform_change:                          ;

lda oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4, x ;
clc                                                   ; Apply movement to the sprite
adc stage_pit_platform1_direction, y                  ;
sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4, x ;

inx ;
inx ; Point to the next sprite
inx ;
inx ;

cpx #STAGE_PIT_NB_MOVING_PLATFORM_SPRITES*4 ; Loop on all platforms' sprites
bne move_one_sprite                         ;

end:
rts
.)
