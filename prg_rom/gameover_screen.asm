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

lda #<anim_sinbad_victory ;
sta tmpfield1             ;
lda #>anim_sinbad_victory ; Set winner's animation
sta tmpfield2             ;
jsr set_player_animation  ;

tya                      ;
tax                      ;
lda #<anim_sinbad_defeat ;
sta tmpfield1            ; Set looser's animation
lda #>anim_sinbad_defeat ;
sta tmpfield2            ;
jsr set_player_animation ;

jsr update_sprites ; First animation frame

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
sta global_game_state
jsr change_global_game_state

update_animations:
jsr update_sprites
rts
.)
