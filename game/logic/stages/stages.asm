stage_generic_init:
.(
stage_table_index = tmpfield15

; Point stage_table_index to the byte offset of selected stage entry in vector tables
lda config_selected_stage
asl
sta stage_table_index

; Write palette_data in actual ppu palettes
bit PPUSTATUS     ;
lda #$80          ; Wait the begining of a VBI before
wait_vbi:         ; writing data to PPU's palettes
    bit PPUSTATUS ;
    beq wait_vbi  ;

lda PPUSTATUS ;
lda #$3f      ; Point PPU to Background palette 0
sta PPUADDR   ; (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
lda #$00      ;
sta PPUADDR   ;

ldx #$00            ;
copy_palette:       ;
lda palette_data, x ;
sta PPUDATA         ; Write palette_data in actual ppu palettes
inx                 ;
cpx #$20            ;
bne copy_palette    ;

; Copy background from PRG-rom to PPU nametable
ldx stage_table_index
lda stages_nametable, x
sta tmpfield1
lda stages_nametable+1, x
sta tmpfield2
jsr draw_zipped_nametable

; Copy stage data to its fixed location
ldx stage_table_index
lda stages_data, x
sta tmpfield1
lda stages_data+1, x
sta tmpfield2

ldx #0
ldy #0
copy_header_loop:
lda (tmpfield1), y
sta stage_data, x
inx
iny
cpy #STAGE_OFFSET_PLATFORMS
bne copy_header_loop

copy_platforms_loop:
lda (tmpfield1), y
sta stage_data, x
beq copy_data_end
iny
inx
lda (tmpfield1), y
sta stage_data, x
iny
inx
lda (tmpfield1), y
sta stage_data, x
iny
inx
lda (tmpfield1), y
sta stage_data, x
iny
inx
lda (tmpfield1), y
sta stage_data, x
iny
inx
jmp copy_platforms_loop
copy_data_end:

rts
.)

; Call a subroutine for each platforms of the current stage
;  tmpfield1, tmpfield2 - subroutine to call
;
; For each call, the platform can be accessed at address
; "stage_data+STAGE_OFFSET_PLATFORMS, y"
;
; Called subroutine can stop the iteration by setting Y to $ff, else
; it must not modify the Y register.
;
; Called subroutine must not modify tmpfield1 nor tmpfield2.
stage_iterate_platforms:
.(
ldy #0

check_current_platform:
lda stage_data+STAGE_OFFSET_PLATFORMS, y
beq end

jsr call_pointed_subroutine
cpy #$ff
beq end

lda stage_data+STAGE_OFFSET_PLATFORMS, y
cmp #$01
beq skip_solid_platform

tya
clc
adc #STAGE_SMOOTH_PLATFORM_LENGTH
tay
jmp check_current_platform

skip_solid_platform:
tya
clc
adc #STAGE_PLATFORM_LENGTH
tay
jmp check_current_platform

end:
rts
.)

#include "game/logic/stages/pit.asm"
#include "game/logic/stages/gem.asm"
