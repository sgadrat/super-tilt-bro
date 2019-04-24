; Draw particles according to their state
particle_draw:
.(
.(
sprite_offset = tmpfield4

ldx #0 ; X points on the current bytes on the current block
lda #PARTICLE_FIRST_SPRITE*4
sta sprite_offset

process_one_block:
; Skip the current block if deactivated
lda particle_blocks+PARTICLE_BLOCK_OFFSET_PARAM, x
beq skip_block

; Process current block
jsr process_block
jmp next_block

; Completely skip the current block
skip_block:
txa
clc
adc #PARTICLE_BLOCK_SIZE
tax

; Process the next block if not finished
next_block:
lda #PARTICLE_BLOCK_NB_PARTICLES*4 ;
clc                                ; Change the first sprite offset
adc sprite_offset                  ; for the next block
sta sprite_offset                  ;

cpx #PARTICLE_NB_BLOCKS*PARTICLE_BLOCK_SIZE ; Loop while not finished
bne process_one_block                       ;

rts
.)

; Draw particles of the block at particle_blocks,x
process_block:
.(
tile_index = tmpfield1
tile_attr = tmpfield2
particle_counter = tmpfield3
first_sprite_offset = tmpfield4

; Store sprite information on a fixed place
lda particle_blocks+PARTICLE_BLOCK_OFFSET_TILENUM, x
sta tile_index
lda particle_blocks+PARTICLE_BLOCK_OFFSET_TILEATTR, x
sta tile_attr

; Particle drawing loop
ldy first_sprite_offset ; Y points on the current sprite
lda #0
sta particle_counter
next_particle:

; Point on the next particle
inx
inx
inx
inx

; Stop iterating after the last particle
lda particle_counter
cmp #PARTICLE_BLOCK_NB_PARTICLES
beq end
inc particle_counter

; Draw the current particle
lda particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, x
sta oam_mirror, y
lda tile_index
sta oam_mirror+1, y
lda tile_attr
sta oam_mirror+2, y
lda particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, x
sta oam_mirror+3, y

; Point on the next sprite
iny
iny
iny
iny

; Draw next particle
jmp next_particle

end:
rts
.)
.)
