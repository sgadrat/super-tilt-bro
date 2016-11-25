default_config:
.(
lda #MAX_STOCKS
sta config_initial_stocks
rts
.)

init_config_screen:
.(
.(
; Ensure that the global game state is "config" from now on
lda #GAME_STATE_CONFIG
sta global_game_state

; Reset scrolling
lda #$00
sta scroll_x
sta scroll_y

; Move all sprites offscreen
ldx #$00
clr_sprites:
lda #$FE
sta oam_mirror, x    ;move all sprites off screen
inx
bne clr_sprites

; Point PPU to Background palette 0 (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
lda PPUSTATUS
lda #$3f
sta PPUADDR
lda #$00
sta PPUADDR

; Write palette_data in actual ppu palettes
ldx #$00
copy_palette:
lda palette_config, x
sta PPUDATA
inx
cpx #$20
bne copy_palette

; Clear background
lda #$00
sta $40
sta $41
lda PPUSTATUS
lda #$20
sta PPUADDR
lda #$00
sta PPUADDR
load_background:
lda #$00
sta PPUDATA
inc $40
bne end_inc_vector
inc $41
end_inc_vector:
lda #$04
cmp $41
bne load_background
lda #$00
cmp $40
bne load_background

; Pimp nametable attributes
lda PPUSTATUS
lda #$23
sta PPUADDR
lda #$cd
sta PPUADDR
lda #%01010000
sta PPUDATA
sta PPUDATA
ldx #6
lda #%00000000
attributes_byte:
sta PPUDATA
dex
bne attributes_byte
lda #%01010000
sta PPUDATA
sta PPUDATA

; Draw configuration boxes
ppu_addr = tmpfield1
lda #$c4
sta ppu_addr
lda #$20
sta ppu_addr+1

draw_one_box:
lda PPUSTATUS  ;
lda ppu_addr+1 ;
sta PPUADDR    ; Load PPUADDR with box position
lda ppu_addr   ;
sta PPUADDR    ;

lda #$f4    ; Left border
sta PPUDATA ;

lda #$02                 ;
ldx #13                  ;
fill_left_background:    ; Label's background
sta PPUDATA              ;
dex                      ;
bne fill_left_background ;

lda #$f6    ;
sta PPUDATA ; Label/value separator
lda #$01    ;
sta PPUDATA ;

lda #$02                  ;
ldx #7                    ;
fill_right_background:    ; Value's background
sta PPUDATA               ;
dex                       ;
bne fill_right_background ;

lda #$f5    ; Right border
sta PPUDATA ;

lda ppu_addr   ;
clc            ;
adc #$80       ;
sta ppu_addr   ; Position the next box
lda ppu_addr+1 ;
adc #$00       ;
sta ppu_addr+1 ;

lda ppu_addr     ;
cmp #$44         ; Loop
beq draw_one_box ;

; Write labels
ldx #0
labels_loop:
lda screen_labels, x
sta nametable_buffers, x
inx
cpx #36
bne labels_loop

; Place sprites
ldx #0
sprite_loop:
lda sprites, x
sta oam_mirror, x
inx
cpx #16
bne sprite_loop

; Init local options values from global state
lda audio_music_enabled
sta config_music_enabled

; Adapt to configuration's state
jsr config_update_screen

rts

sprites:
.byt $2f, $3f, $00, $a0
.byt $2f, $3f, $40, $d0
.byt $4f, $3f, $00, $a0
.byt $4f, $3f, $40, $d0
.)

screen_labels:
music_label:
.byt $01, $20, $c7, $05, $43, $4b, $49, $3f, $39
stocks_label:
.byt $01, $21, $47, $06, $49, $4a, $45, $39, $41, $49
start_label:
.byt $01, $22, $8a, $0c, $46, $48, $3b, $49, $49, $02, $02, $49, $4a, $37, $48, $4a
.byt $00
.)

config_screen_tick:
.(
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
cpy #7
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

; Go to the next screen
next_screen:
.(
lda #GAME_STATE_INGAME
sta global_game_state
jsr change_global_game_state
; jmp end ; not needed, change_global_game_state does not return
.)

next_value:
.(
lda config_selected_option
asl
tax
lda next_value_handlers, x
sta tmpfield1
lda next_value_handlers+1, x
sta tmpfield2
jmp (tmpfield1)
jmp end
.)

previous_value:
.(
lda config_selected_option
asl
tax
lda previous_value_handlers, x
sta tmpfield1
lda previous_value_handlers+1, x
sta tmpfield2
jmp (tmpfield1)
jmp end
.)

next_option:
.(
lda config_selected_option
beq set_one
lda #0
jmp store_value
set_one:
lda #1
store_value:
sta config_selected_option

jmp end
.)

previous_option:
.(
jmp next_option
jmp end
.)

music_next_value:
.(
lda config_music_enabled
eor #%00000001
sta config_music_enabled

beq mute
jsr audio_unmute_music
jmp end
mute:
jsr audio_mute_music
jmp end
.)

stocks_next_value:
.(
inc config_initial_stocks
lda config_initial_stocks
cmp #MAX_STOCKS+1
bne end
lda #0
sta config_initial_stocks
jmp end
.)

music_previous_value:
.(
jmp music_next_value
;jmp end ; Not needed, handled by music_next_value
.)

stocks_previous_value:
.(
dec config_initial_stocks
lda config_initial_stocks
cmp #$ff
bne end
lda #MAX_STOCKS
sta config_initial_stocks
;jmp end ; Not needed, we are here
.)

end:
jsr config_update_screen
rts

buttons_numbering:
.byt CONTROLLER_BTN_RIGHT, CONTROLLER_BTN_LEFT, CONTROLLER_BTN_DOWN, CONTROLLER_BTN_UP, CONTROLLER_BTN_START, CONTROLLER_BTN_B, CONTROLLER_BTN_A
buttons_actions:
.word next_value,          previous_value,      next_option,         previous_option,   next_screen,          previous_value,   next_value

next_value_handlers:
.word music_next_value, stocks_next_value

previous_value_handlers:
.word music_previous_value, stocks_previous_value
.)
.)

config_update_screen:
.(
option_num = tmpfield15

.(
lda #0
sta option_num
values:
jsr config_highligh_option
jsr config_draw_value
inc option_num
lda option_num
cmp #2
bne values

rts
.)

config_highligh_option:
.(
;
; Modify nametable attributes to color selected field
;

jsr last_nt_buffer
lda option_num
asl
asl
tay

; Nametable buffer header
loop_header:
lda options_buffer_headers, y
sta nametable_buffers, x
inx
lda options_buffer_headers+1, y
sta nametable_buffers, x
inx
lda options_buffer_headers+2, y
sta nametable_buffers, x
inx
lda options_buffer_headers+3, y
sta nametable_buffers, x
inx

; Determine attribute
lda config_selected_option
cmp option_num
beq enabled
lda #%00000000
jmp got_attribute
enabled:
lda #%10100000
got_attribute:

; Nametable buffer payload
sta nametable_buffers, x
inx
sta nametable_buffers, x
inx
sta nametable_buffers, x
inx
sta nametable_buffers, x
inx

; Close nametable buffer
lda #$00
sta nametable_buffers, x

;
; Modify sprites attributes to color arrows of selected attribute
;

; Set X to point on attribute byte of the first sprite related to this option
lda option_num
asl
asl
asl
adc #2
tax

ldy #0

; Change palette number of option's sprites according to its selected state
set_option_sprites_attributes:
lda option_num
cmp config_selected_option
beq selected

lda oam_mirror, x
and #%11111110
sta oam_mirror, x
jmp next_sprite

selected:
lda oam_mirror, x
ora #%00000001
sta oam_mirror, x

next_sprite:
inx
inx
inx
inx
iny
cpy #2
bne set_option_sprites_attributes

rts

options_buffer_headers:
.byt $01, $23, $c9, $04
.byt $01, $23, $d1, $04
.)

config_draw_value:
.(
; Jump to the good label regarding option_num
lda option_num
asl
tax
lda values_handlers, x
sta tmpfield2
lda values_handlers+1, x
sta tmpfield3
jmp (tmpfield2)

draw_music:
.(
; Store good buffer's address int tmpfield1
lda config_music_enabled
beq music_disabled

lda #<buffer_on
sta tmpfield1
lda #>buffer_on
sta tmpfield2
jmp send_buffer

music_disabled:
lda #<buffer_off
sta tmpfield1
lda #>buffer_off
sta tmpfield2

; Copy stored buffer
send_buffer:
jsr last_nt_buffer
ldy #0
loop_value:
lda (tmpfield1), y
sta nametable_buffers, x
iny
inx
cpy #8
bne loop_value

jmp end
.)

draw_stocks:
.(
; Set Y to the begining of the good buffer from buffer_one
lda config_initial_stocks
asl
asl
asl
adc config_initial_stocks
adc config_initial_stocks
tay

; Store "buffer end" Y value in tmpfield1
tya
clc
adc #10
sta tmpfield1

; Send buffer
jsr last_nt_buffer
loop_value:
lda buffer_one, y
sta nametable_buffers, x
iny
inx
cpy tmpfield1
bne loop_value

;jmp end ; Not needed
.)

end:
rts

values_handlers:
.word draw_music, draw_stocks

buffer_on:
.byt $01, $20, $d5, $03, $45, $44, $02, $00
buffer_off:
.byt $01, $20, $d5, $03, $45, $3c, $3c, $00

buffer_one:
.byt $01, $21, $55, $05, $45, $44, $3b, $02, $02, $00
buffer_two:
.byt $01, $21, $55, $05, $4a, $4d, $45, $02, $02, $00
buffer_three:
.byt $01, $21, $55, $05, $4a, $3e, $48, $3b, $3b, $00
buffer_four:
.byt $01, $21, $55, $05, $3c, $45, $4b, $48, $02, $00
buffer_five:
.byt $01, $21, $55, $05, $3c, $3f, $4c, $3b, $02, $00
.)
.)
