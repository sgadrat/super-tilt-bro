init_title_screen:
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
lda palette_title, x
sta PPUDATA
inx
cpx #$20
bne copy_palette

; Copy background from PRG-rom to PPU nametable
lda #<nametable_title
sta tmpfield1
lda #>nametable_title
sta tmpfield2
jsr draw_zipped_nametable

; Reinit cheat code state
lda #0
sta title_cheatstate

; Change music for the main theme
jsr audio_music_weak

; Initialize common menus effects
jsr init_menu

rts
.)

title_screen_tick:
.(
; Play common menus effects
jsr tick_menu

; Check for cheat code (controller A only)
ldx title_cheatstate
lda controller_a_btns
cmp controller_a_last_frame_btns
beq press_any_key
cmp cheatcode, x
beq update_cheatcode
jmp press_any_key

update_cheatcode:
cpx #19
beq cheat_succeed
inx
txa
sta title_cheatstate
jmp end

cheat_succeed:
lda #GAME_STATE_CREDITS
sta global_game_state
jsr change_global_game_state

; If all buttons of any controller are released on this frame, got to the next screen
press_any_key:
lda controller_a_btns
bne check_controller_b
cmp controller_a_last_frame_btns
bne next_screen
check_controller_b:
lda controller_b_btns
bne end
cmp controller_b_last_frame_btns
bne next_screen
jmp end

next_screen:
lda #GAME_STATE_CONFIG
sta global_game_state
jsr change_global_game_state

end:
rts

cheatcode:
.byt CONTROLLER_BTN_UP, 0, CONTROLLER_BTN_UP, 0, CONTROLLER_BTN_DOWN, 0, CONTROLLER_BTN_DOWN, 0
.byt CONTROLLER_BTN_LEFT, 0, CONTROLLER_BTN_RIGHT, 0, CONTROLLER_BTN_LEFT, 0, CONTROLLER_BTN_RIGHT, 0
.byt CONTROLLER_BTN_B, 0, CONTROLLER_BTN_A, 0
.)
