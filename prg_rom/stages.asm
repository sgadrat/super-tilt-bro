stage_generic_init:
.(
stage_table_index = tmpfield15

; Point stage_table_index to the byte offset of selected stage entry in vector tables
lda config_selected_stage
asl
sta stage_table_index

; Point PPU to Background palette 0 (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
lda PPUSTATUS
lda #$3f
sta PPUADDR
lda #$00
sta PPUADDR

; Write palette_data in actual ppu palettes
ldx #$00
copy_palette:
lda palette_data, x
sta PPUDATA
inx
cpx #$20
bne copy_palette

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
