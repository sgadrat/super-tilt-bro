; Deactivate all particle handlers
particle_handlers_reinit:
.(
	; Deactivate particle blocks
	lda #<deactivate_particle_block
	sta tmpfield1
	lda #>deactivate_particle_block
	sta tmpfield2
	jsr loop_on_particle_boxes

	rts
.)

; Call a subroutine for each block
;  tmpfield1, tmpfield2 - adress of the subroutine to call
;
;  For each call, Y is the offset of the block's first byte from particle_blocks
loop_on_particle_boxes:
.(
	action = tmpfield1

	ldy #0
	loop:
	tya
	pha
	jsr call_pointed_subroutine
	pla
	clc
	adc #PARTICLE_BLOCK_SIZE
	tay
	cmp #PARTICLE_NB_BLOCKS * PARTICLE_BLOCK_SIZE
	bne loop

	rts
.)

; Call a subroutine for each particle in a block
;  tmpfield1, tmpfield2 - adress of the subroutine to call
;  Y - offset of the block's first byte from particle_blocks
;
; Overwrites A, Y, tmpfield3
;
; For each call, Y is the offset of the particle's first byte and
; tmpfield3 is the particle number (from 1)
loop_on_particles:
.(
	;action = tmpfield1
	particle_counter = tmpfield3

	lda #0                           ;
	sta particle_counter             ;
	next_particle:                   ;
	lda particle_counter             ; Loop on each particle position
	cmp #PARTICLE_BLOCK_NB_PARTICLES ;
	beq end                          ;
	inc particle_counter             ;

	iny ;
	iny ; Y points on the current particle
	iny ;
	iny ;

	jsr call_pointed_subroutine

	jmp next_particle
	end:
	rts
.)

; Deactivate the particle block begining at "particle_blocks, y"
;  Overwrite all registers, tmpfield1, tmpfield2, tmpfield3 and tmpfield4
deactivate_particle_block:
.(
	lda #0
	sta particle_blocks+PARTICLE_BLOCK_OFFSET_PARAM, y

	jsr hide_particles

	rts
.)

; Hide sprites of all particles in the block begining at "particle_blocks, y"
;  Overwrite all registers, tmpfield1, tmpfield2, tmpfield3 and tmpfield4
hide_particles:
.(
	sprite_offset = tmpfield4

	; Make sprite_offset point to the sprite before block's first sprite in oam_mirror
	cpy #0
	bne second_block
		lda #(PARTICLE_FIRST_SPRITE-1)*4
		jmp set_sprite_offset
	second_block:
		lda #(PARTICLE_FIRST_SPRITE-1+PARTICLE_BLOCK_NB_PARTICLES)*4
	set_sprite_offset:
	sta sprite_offset

	; Move block's particles out of screen
	;  Note - It could be simplified by iterating directly on OAM sprites instead off calling loop_on_particle
	lda #<hide_one_particle
	sta tmpfield1
	lda #>hide_one_particle
	sta tmpfield2
	jsr loop_on_particles
	rts

	hide_one_particle:
	.(
		lda sprite_offset
		clc
		adc #4
		sta sprite_offset
		tax

		lda #$fe          ; Move the particle out of screen
		sta oam_mirror, x ;
		rts
	.)
.)
