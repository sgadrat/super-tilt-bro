#define OAM_BALLOONS 4*32

init_gameover_screen:
.(
; Point PPU to Background palette 0 (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
lda PPUSTATUS
lda #$3f
sta PPUADDR
lda #$00
sta PPUADDR

; Write palette_data in actual ppu palettes
ldx #$00
copy_palette:
lda palette_gameover, x
sta PPUDATA
inx
cpx #$20
bne copy_palette

; Copy background from PRG-rom to PPU nametable
lda #<nametable_gameover
sta tmpfield1
lda #>nametable_gameover
sta tmpfield2
jsr draw_zipped_nametable

; Initialize sprites palettes regarding configuration
lda #<character_palettes
sta tmpfield2
lda #>character_palettes
sta tmpfield3

ldx #$11
lda config_player_a_character_palette
sta tmpfield1
jsr copy_palette_to_ppu

ldx #$19
lda config_player_b_character_palette
sta tmpfield1
jsr copy_palette_to_ppu

; Write winner's name
lda PPUSTATUS
lda #$20
sta PPUADDR
lda #$9a
sta PPUADDR
ldx gameover_winner
ldy #0
winner_name_writing:
lda player_names, x
sta PPUDATA
inx
inx
iny
cpy #3
bne winner_name_writing

; Players state using "ingame" state variable to show winning animation
ldx gameover_winner        ;
jsr switch_selected_player ; Set winner player num in X
txa                        ; and looser player num in Y
tay                        ;
ldx gameover_winner        ;

lda #$71          ;
sta player_a_y, x ;
lda #$76          ;
sta player_a_y, y ; Place characters
lda #$64          ;
sta player_a_x, x ;
lda #$3c          ;
sta player_a_x, y ;

lda #<anim_sinbad_victory           ;
sta tmpfield1                       ;
lda #>anim_sinbad_victory           ; Set winner's animation
sta tmpfield2                       ;
jsr set_player_animation            ;
lda #0                              ;
sta player_a_animation_direction, x ;

tya                                 ;
tax                                 ;
lda #<anim_sinbad_defeat            ;
sta tmpfield1                       ; Set looser's animation
lda #>anim_sinbad_defeat            ;
sta tmpfield2                       ;
jsr set_player_animation            ;
lda #0                              ;
sta player_a_animation_direction, x ;

jsr update_sprites ; First animation frame

; Initialize balloon sprites
ldx #0
initialize_a_balloon:
lda #TILE_BALLOON
sta oam_mirror+OAM_BALLOONS+1, x
lda #TILE_BALLOON_TAIL
sta oam_mirror+OAM_BALLOONS+5, x
lda #$23
sta oam_mirror+OAM_BALLOONS+2, x
sta oam_mirror+OAM_BALLOONS+6, x
txa
clc
adc #8
tax
cpx #8*6
bne initialize_a_balloon

ldx #0
position_a_balloon:

; Position higher than #$80
jsr gameover_random_byte
lsr
sta gameover_balloon0_y, x

; Laterally near the podium
jsr gameover_random_byte
lsr
clc
adc #$20
sta gameover_balloon0_x, x
inx
cpx #6
bne position_a_balloon

; Change for music for gameover theme
jsr audio_music_gameover

rts

player_names:
.byt $45, $4a
.byt $44, $4d
.byt $3b, $45
.)

gameover_screen_tick:
.(
.(
; If start button is released from any controller, go to next screen
ldx #0
check_one_controller:
lda controller_a_last_frame_btns, x
sta tmpfield1
lda controller_a_btns, x
sta tmpfield2
lda #CONTROLLER_BTN_START
bit tmpfield1
beq next_controller
bit tmpfield2
bne next_controller
jmp next_screen
next_controller:
inx
cpx #2
bne check_one_controller
jmp update_animations

next_screen:
lda #GAME_STATE_TITLE
jsr change_global_game_state

update_animations:
jsr update_sprites
jsr update_balloons
rts
.)

update_balloons:
.(
ldx #0
ldy #0
update_one_balloon:

; Update Y
jsr gameover_random_byte
and #%00000011
clc
adc #$80
clc
adc gameover_balloon0_y_low, x
sta gameover_balloon0_y_low, x
lda #$ff
adc gameover_balloon0_y, x
sta gameover_balloon0_y, x
cmp #$80
bmi end_y
lda #$80
sta gameover_balloon0_y, x
end_y:

; Update horizontal velocity
jsr gameover_random_byte
and #%00000111
clc
adc gameover_balloon0_velocity_h, x
sta gameover_balloon0_velocity_h, x

; Update X
lda gameover_balloon0_velocity_h, x
clc
adc gameover_balloon0_x_low, x
sta gameover_balloon0_x_low, x
lda gameover_balloon0_velocity_h, x
bpl positive
lda #$ff
jmp high_byte_set
positive:
lda #$00
high_byte_set:
adc gameover_balloon0_x, x
sta gameover_balloon0_x, x

; Move balloon's sprite
lda gameover_balloon0_y, x
sta oam_mirror+OAM_BALLOONS, y
clc
adc #8
sta oam_mirror+OAM_BALLOONS+4, y

lda gameover_balloon0_x, x
sta oam_mirror+OAM_BALLOONS+3, y
sta oam_mirror+OAM_BALLOONS+7, y

lda gameover_balloon0_y, x
cmp #$40
bcs background
lda #$03
sta oam_mirror+OAM_BALLOONS+2, y
sta oam_mirror+OAM_BALLOONS+6, y
jmp end_sprite_layer
background:
lda #$23
sta oam_mirror+OAM_BALLOONS+2, y
sta oam_mirror+OAM_BALLOONS+6, y
end_sprite_layer:

; Loop
tya
clc
adc #8
tay
inx
cpx #6
bne update_one_balloon

rts
.)
.)

gameover_random_byte:
.(
lda gameover_random
rol
rol
rol
rol
adc gameover_random
adc #1
sta gameover_random

rts
.)
