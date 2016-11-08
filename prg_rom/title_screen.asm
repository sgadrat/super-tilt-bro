init_title_screen:
.(
; Ensure that the global game state is "title" from now on
lda #GAME_STATE_TITLE
sta global_game_state

; Ensure there is no drawing to be processed
jsr reset_nt_buffers

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
sta $40
lda #>nametable_title
sta $41
lda PPUSTATUS
lda #$20
sta PPUADDR
lda #$00
sta PPUADDR
ldy #$00
load_background:
lda ($40), y
sta PPUDATA
inc $40
bne end_inc_vector
inc $41
end_inc_vector:
lda #<nametable_title_end
cmp $40
bne load_background
lda #>nametable_title_end
cmp $41
bne load_background

; Move all sprites offscreen
ldx #$00
clr_sprites:
lda #$FE
sta oam_mirror, x    ;move all sprites off screen
inx
bne clr_sprites

rts
.)

title_screen_tick:
.(
; If any button of anny controller is pressed, got to the next screen
lda controller_a_btns
cmp controller_a_last_frame_btns
bne next_screen
lda controller_b_btns
cmp controller_b_last_frame_btns
bne next_screen
jmp end

next_screen:
lda #GAME_STATE_INGAME
sta global_game_state
jsr change_global_game_state

end:
rts
.)
