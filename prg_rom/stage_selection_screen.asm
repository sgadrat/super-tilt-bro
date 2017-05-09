init_stage_selection_screen:
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
lda palette_stage_selection, x
sta PPUDATA
inx
cpx #$20
bne copy_palette

; Copy background from PRG-rom to PPU nametable
lda #<nametable_stage_selection
sta tmpfield1
lda #>nametable_stage_selection
sta tmpfield2
jsr draw_zipped_nametable

; Place sprites
ldx #$00
copy_one_byte:
lda sprites, x
sta oam_mirror, x
inx
bne copy_one_byte

; Show initial selection
lda #%10101010
sta tmpfield1
jsr stage_selection_screen_modify_selected

rts

#define STAGE_SELECT_SPRITE(y,tile,attr,x) .byt y, tile, attr, x
sprites:
; Up left
STAGE_SELECT_SPRITE($38, TILE_MINI_STAGE_FLATLAND_0, $00, $30)
STAGE_SELECT_SPRITE($38, TILE_MINI_STAGE_FLATLAND_0, $00, $38)
STAGE_SELECT_SPRITE($38, TILE_MINI_STAGE_FLATLAND_0, $00, $40)
STAGE_SELECT_SPRITE($38, TILE_MINI_STAGE_FLATLAND_0, $00, $48)

STAGE_SELECT_SPRITE($40, TILE_MINI_STAGE_FLATLAND_0, $00, $30)
STAGE_SELECT_SPRITE($40, TILE_MINI_STAGE_FLATLAND_1, $00, $38)
STAGE_SELECT_SPRITE($40, TILE_MINI_STAGE_FLATLAND_0, $00, $40)
STAGE_SELECT_SPRITE($40, TILE_MINI_STAGE_FLATLAND_0, $00, $48)

STAGE_SELECT_SPRITE($48, TILE_MINI_STAGE_FLATLAND_2, $00, $30)
STAGE_SELECT_SPRITE($48, TILE_MINI_STAGE_FLATLAND_3, $00, $38)
STAGE_SELECT_SPRITE($48, TILE_MINI_STAGE_FLATLAND_4, $00, $40)
STAGE_SELECT_SPRITE($48, TILE_MINI_STAGE_FLATLAND_2, $40, $48)

STAGE_SELECT_SPRITE($50, TILE_MINI_STAGE_FLATLAND_5, $00, $30)
STAGE_SELECT_SPRITE($50, TILE_MINI_STAGE_FLATLAND_6, $00, $38)
STAGE_SELECT_SPRITE($50, TILE_MINI_STAGE_FLATLAND_6, $00, $40)
STAGE_SELECT_SPRITE($50, TILE_MINI_STAGE_FLATLAND_5, $40, $48)
; Up right
STAGE_SELECT_SPRITE($38, TILE_MINI_STAGE_PIT_0, $00, $B0)
STAGE_SELECT_SPRITE($38, TILE_MINI_STAGE_PIT_0, $00, $B8)
STAGE_SELECT_SPRITE($38, TILE_MINI_STAGE_PIT_0, $00, $C0)
STAGE_SELECT_SPRITE($38, TILE_MINI_STAGE_PIT_0, $00, $C8)
                       
STAGE_SELECT_SPRITE($40, TILE_MINI_STAGE_PIT_0, $00, $B0)
STAGE_SELECT_SPRITE($40, TILE_MINI_STAGE_PIT_1, $00, $B8)
STAGE_SELECT_SPRITE($40, TILE_MINI_STAGE_PIT_1, $40, $C0)
STAGE_SELECT_SPRITE($40, TILE_MINI_STAGE_PIT_0, $00, $C8)
                       
STAGE_SELECT_SPRITE($48, TILE_MINI_STAGE_PIT_2, $00, $B0)
STAGE_SELECT_SPRITE($48, TILE_MINI_STAGE_PIT_3, $00, $B8)
STAGE_SELECT_SPRITE($48, TILE_MINI_STAGE_PIT_3, $40, $C0)
STAGE_SELECT_SPRITE($48, TILE_MINI_STAGE_PIT_2, $40, $C8)
                       
STAGE_SELECT_SPRITE($50, TILE_MINI_STAGE_PIT_4, $00, $B0)
STAGE_SELECT_SPRITE($50, TILE_MINI_STAGE_PIT_5, $00, $B8)
STAGE_SELECT_SPRITE($50, TILE_MINI_STAGE_PIT_5, $40, $C0)
STAGE_SELECT_SPRITE($50, TILE_MINI_STAGE_PIT_4, $40, $C8)
; Down left
STAGE_SELECT_SPRITE($98, TILE_MINI_STAGE_SKYRIDE_0, $00, $30)
STAGE_SELECT_SPRITE($98, TILE_MINI_STAGE_SKYRIDE_0, $00, $38)
STAGE_SELECT_SPRITE($98, TILE_MINI_STAGE_SKYRIDE_0, $00, $40)
STAGE_SELECT_SPRITE($98, TILE_MINI_STAGE_SKYRIDE_0, $00, $48)

STAGE_SELECT_SPRITE($a0, TILE_MINI_STAGE_SKYRIDE_0, $00, $30)
STAGE_SELECT_SPRITE($a0, TILE_MINI_STAGE_SKYRIDE_1, $00, $38)
STAGE_SELECT_SPRITE($a0, TILE_MINI_STAGE_SKYRIDE_1, $40, $40)
STAGE_SELECT_SPRITE($a0, TILE_MINI_STAGE_SKYRIDE_0, $00, $48)

STAGE_SELECT_SPRITE($a8, TILE_MINI_STAGE_SKYRIDE_2, $00, $30)
STAGE_SELECT_SPRITE($a8, TILE_MINI_STAGE_SKYRIDE_2, $40, $38)
STAGE_SELECT_SPRITE($a8, TILE_MINI_STAGE_SKYRIDE_3, $00, $40)
STAGE_SELECT_SPRITE($a8, TILE_MINI_STAGE_SKYRIDE_2, $40, $48)

STAGE_SELECT_SPRITE($B0, TILE_MINI_STAGE_SKYRIDE_4, $00, $30)
STAGE_SELECT_SPRITE($B0, TILE_MINI_STAGE_SKYRIDE_5, $00, $38)
STAGE_SELECT_SPRITE($B0, TILE_MINI_STAGE_SKYRIDE_6, $00, $40)
STAGE_SELECT_SPRITE($B0, TILE_MINI_STAGE_SKYRIDE_4, $40, $48)
; Down right
STAGE_SELECT_SPRITE($98, TILE_MINI_STAGE_LOCKED_0, $00, $B0)
STAGE_SELECT_SPRITE($98, TILE_MINI_STAGE_LOCKED_1, $00, $B8)
STAGE_SELECT_SPRITE($98, TILE_MINI_STAGE_LOCKED_1, $40, $C0)
STAGE_SELECT_SPRITE($98, TILE_MINI_STAGE_LOCKED_0, $40, $C8)
                                                      
STAGE_SELECT_SPRITE($a0, TILE_MINI_STAGE_LOCKED_2, $00, $B0)
STAGE_SELECT_SPRITE($a0, TILE_MINI_STAGE_LOCKED_3, $00, $B8)
STAGE_SELECT_SPRITE($a0, TILE_MINI_STAGE_LOCKED_3, $40, $C0)
STAGE_SELECT_SPRITE($a0, TILE_MINI_STAGE_LOCKED_2, $40, $C8)
                                                      
STAGE_SELECT_SPRITE($a8, TILE_MINI_STAGE_LOCKED_4, $00, $B0)
STAGE_SELECT_SPRITE($a8, TILE_MINI_STAGE_LOCKED_5, $00, $B8)
STAGE_SELECT_SPRITE($a8, TILE_MINI_STAGE_LOCKED_5, $40, $C0)
STAGE_SELECT_SPRITE($a8, TILE_MINI_STAGE_LOCKED_4, $40, $C8)
                                                      
STAGE_SELECT_SPRITE($B0, TILE_MINI_STAGE_LOCKED_6, $00, $B0)
STAGE_SELECT_SPRITE($B0, TILE_MINI_STAGE_LOCKED_7, $00, $B8)
STAGE_SELECT_SPRITE($B0, TILE_MINI_STAGE_LOCKED_7, $40, $C0)
STAGE_SELECT_SPRITE($B0, TILE_MINI_STAGE_LOCKED_6, $40, $C8)
.)

stage_selection_screen_tick:
.(
; Clear already written buffers
jsr reset_nt_buffers

; Check if a button is released and trigger correct action
ldx #0
check_one_controller:

lda controller_a_btns, x
bne next_controller

ldy #0
btn_search_loop:
lda buttons_numbering, y
cmp controller_a_last_frame_btns, x
beq jump_from_table
iny
cpy #5
bne btn_search_loop

next_controller:
inx
cpx #2
bne check_one_controller
jmp end

jump_from_table:
tya
asl
tay
lda buttons_actions, y
sta tmpfield1
lda buttons_actions+1, y
sta tmpfield2
jmp (tmpfield1)

end:
rts

; Go to the next screen
next_screen:
.(
; Do nothing if the selected stage does not exists
lda config_selected_stage
cmp #3
bcs end

; Start the game
lda #GAME_STATE_INGAME
sta global_game_state
jsr change_global_game_state
; jmp end ; not needed, change_global_game_state does not return
.)

go_right:
.(
; Do nothing if already on the right of the screen
lda config_selected_stage
cmp #$01
beq end
cmp #$03
beq end

; Grey currently selected stage
lda #%00000000
sta tmpfield1
jsr stage_selection_screen_modify_selected

; Change selected stage
inc config_selected_stage

; Highlight currently selected stage
lda #%10101010
sta tmpfield1
jsr stage_selection_screen_modify_selected

jmp end
.)

go_left:
.(
; Do nothing if already on the left of the screen
lda config_selected_stage
cmp #$00
beq end
cmp #$02
beq end

; Grey currently selected stage
lda #%00000000
sta tmpfield1
jsr stage_selection_screen_modify_selected

; Change selected stage
dec config_selected_stage

; Highlight currently selected stage
lda #%10101010
sta tmpfield1
jsr stage_selection_screen_modify_selected

jmp end
.)

go_up:
.(
; Do nothing if already on the top of the screen
lda config_selected_stage
cmp #$00
beq end
cmp #$01
beq end

; Grey currently selected stage
lda #%00000000
sta tmpfield1
jsr stage_selection_screen_modify_selected

; Change selected stage
dec config_selected_stage
dec config_selected_stage

; Highlight currently selected stage
lda #%10101010
sta tmpfield1
jsr stage_selection_screen_modify_selected

jmp end
.)

go_down:
.(
; Do nothing if already on the bottom of the screen
lda config_selected_stage
cmp #$02
beq end
cmp #$03
beq end

; Grey currently selected stage
lda #%00000000
sta tmpfield1
jsr stage_selection_screen_modify_selected

; Change selected stage
inc config_selected_stage
inc config_selected_stage

; Highlight currently selected stage
lda #%10101010
sta tmpfield1
jsr stage_selection_screen_modify_selected

jmp end
.)

buttons_numbering:
.byt CONTROLLER_BTN_RIGHT, CONTROLLER_BTN_LEFT, CONTROLLER_BTN_DOWN, CONTROLLER_BTN_UP, CONTROLLER_BTN_START
buttons_actions:
.word go_right,            go_left,             go_down,             go_up,             next_screen,
.)

; Modify highlighting of the selected level
;  tmpfield1 - %10101010 if to be activated, else %00000000
stage_selection_screen_modify_selected:
.(
;
; Minitature's sprites
;

; Point X to the atttribute bytes of the first sprite
lda config_selected_stage
asl
asl
asl
asl
asl
asl
; clc ; not needed, previous asl should not overflow
adc #2
tax

; Change the palette of each sprites
ldy #16 ; Number of sprites to modify
change_one:
lda #$01          ;
eor oam_mirror, x ; Change the current byte
sta oam_mirror, x ;
inx ;
inx ; point X to the next sprite's attributes byte
inx ;
inx ;
dey            ; Loop on all related sprites
bne change_one ;

;
; Frame's background
;

; Initialize working data
jsr last_nt_buffer ; Set X after the last nametable buffer
ldy config_selected_stage ;
lda frame_adresses_lsb, y ; Set tmpfield2 to the lsb of the attribute's line
sta tmpfield2             ;
ldy #3 ; Set Y to the number of lines to affect

; Write a nametable buffer for a line of the current frame
set_line_attributes:
lda #$01
sta nametable_buffers, x
inx
lda #$23
sta nametable_buffers, x
inx
lda tmpfield2
sta nametable_buffers, x
inx
lda #4
sta nametable_buffers, x
inx
lda tmpfield1
sta nametable_buffers, x
inx
sta nametable_buffers, x
inx
sta nametable_buffers, x
inx
sta nametable_buffers, x
inx

; Prepare next line
lda #8        ;
clc           ; Point tmpfield2 to the next line
adc tmpfield2 ;
sta tmpfield2 ;
dey                     ; Loop until the number of lines is good
bne set_line_attributes ;

; Set the nametable buffer guarding byte
lda #$00
sta nametable_buffers, x

rts

frame_adresses_lsb:
.byt $c8
.byt $cc
.byt $e0
.byt $e4
.)
