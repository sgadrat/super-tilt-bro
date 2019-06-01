; Game specific animation opcodes
;
;  Each opcodes is associated to a handler by the animation_frame_entry_handlers
;  table.
;  Nine-gine's animation routine takes care of parsing animation and calling
;  appropriate handlers.
;
;  Handlers parameters
;   tmpfield1 - Position X LSB
;   tmpfield2 - Position Y LSB
;   tmpfield3, tmpfield4 - Vector pointing to the frame to draw
;   tmpfield5 - First sprite index to use
;   tmpfield6 - Last sprite index to use
;   tmpfield7 - Animation's direction (0 normal, 1 flipped)
;   tmpfield8 - Position X MSB
;   tmpfield9 - Position Y MSB
;   tmpfield10 - Opcode of the entry
;   tmpfield11, tmpfield12 - vector to the animation_state
;   register Y - Index of the etnry's first byte in the frame vector (payload byte, not opcode)
;
;  Handlers outputs
;   tmpfield5 is updated to stay on the next free sprite
;   tmpfield6 is updated to stay on the last free sprite
;   registerY is advanced to the first byte after the entry
;
;  Handlers may freely modify
;   tmpfield13 to tmpfield16
;   registers A and X
;

animation_frame_entry_handlers_lsb:
.byt <anim_frame_move_sprite, <anim_frame_move_sprite
.byt <anim_frame_move_hitbox, <anim_frame_move_hurtbox
animation_frame_entry_handlers_msb:
.byt >anim_frame_move_sprite, >anim_frame_move_sprite
.byt >anim_frame_move_hitbox, >anim_frame_move_hurtbox

; Hook called when the sprite handler wants to load attributes from its entry
;  Here we add "2 * player_num" to fetched attributes, so
;  player A uses palettes 0 and 1
;  player B uses palettes 2 and 3
#define ANIM_HOOK_SPRITE_ATTRIBUTES .(:\
	lda player_number:\
	asl:\
	clc:\
	adc (frame_vector), y:\
.)

; Hook called when the sprite handler wants to load the tile number from its entry
;  Here we add "96 * player_num" to fetched tile number, so
;  player A uses tiles 0 to 95
;  player B uses tiles 96 to 191
#define ANIM_HOOK_TILE_NUMBER .(:\
	lda player_number:\
	bne player_b:\
\
		; player A, just return tile number:\
		lda (frame_vector), y:\
		jmp end_anim_hook:\
\
	player_b:\
\
		; Player B, return tile number + 96:\
		lda (frame_vector), y:\
		clc:\
		adc #96:\
\
	end_anim_hook:\
.)

anim_frame_move_hurtbox:
.(
	; Pretty names
	anim_pos_x = tmpfield1
    anim_pos_y = tmpfield2
    frame_vector = tmpfield3
    sprite_index = tmpfield5
    last_sprite_index = tmpfield6
    animation_direction = tmpfield7
    anim_pos_x_msb = tmpfield8
    anim_pos_y_msb = tmpfield9
    continuation_byte = tmpfield10

	sign_extension_byte = tmpfield13
	width = tmpfield14

	; Extract relative position
	ldx player_number
	; Left
	lda (frame_vector), y
	sta player_a_hurtbox_left, x
	iny
	; Right
	lda (frame_vector), y
	sta player_a_hurtbox_right, x
	iny
	; Top
	lda (frame_vector), y
	sta player_a_hurtbox_top, x
	iny
	; Bottom
	lda (frame_vector), y
	sta player_a_hurtbox_bottom, x
	iny

	; If the animation is flipped, flip the box
	lda animation_direction ; Nothing to do for non-flipped animation
	beq apply_offset        ;
	lda player_a_hurtbox_right, x ;
	sec                           ; Compute box width
	sbc player_a_hurtbox_left, x  ;
	sta width                     ;

	lda player_a_hurtbox_left, x  ;
	eor #%11111111                ;
	clc                           ; right = -left + 7
	adc #8                        ;
	sta player_a_hurtbox_right, x ;

	sec                          ;
	sbc width                    ; left = right - width
	sta player_a_hurtbox_left, x ;

	; Apply offset to the box
	apply_offset:
	; Left
	lda player_a_hurtbox_left, x
	pha
	SIGN_EXTEND()
	sta sign_extension_byte
	pla
	clc
	adc anim_pos_x
	sta player_a_hurtbox_left, x
	lda sign_extension_byte
	adc anim_pos_x_msb
	sta player_a_hurtbox_left_msb, x
	; Right
	lda player_a_hurtbox_right, x
	pha
	SIGN_EXTEND()
	sta sign_extension_byte
	pla
	clc
	adc anim_pos_x
	sta player_a_hurtbox_right, x
	lda sign_extension_byte
	adc anim_pos_x_msb
	sta player_a_hurtbox_right_msb, x
	; Top
	lda player_a_hurtbox_top, x
	pha
	SIGN_EXTEND()
	sta sign_extension_byte
	pla
	clc
	adc anim_pos_y
	sta player_a_hurtbox_top, x
	lda sign_extension_byte
	adc anim_pos_y_msb
	sta player_a_hurtbox_top_msb, x
	; Bottom
	lda player_a_hurtbox_bottom, x
	pha
	SIGN_EXTEND()
	sta sign_extension_byte
	pla
	clc
	adc anim_pos_y
	sta player_a_hurtbox_bottom, x
	lda sign_extension_byte
	adc anim_pos_y_msb
	sta player_a_hurtbox_bottom_msb, x

	end:
	rts
.)

anim_frame_move_hitbox:
.(
	; Pretty names
	anim_pos_x = tmpfield1
    anim_pos_y = tmpfield2
    frame_vector = tmpfield3
    sprite_index = tmpfield5
    last_sprite_index = tmpfield6
    animation_direction = tmpfield7
    anim_pos_x_msb = tmpfield8
    anim_pos_y_msb = tmpfield9
    continuation_byte = tmpfield10
	anim_state = tmpfield11
	;tmpfield12 is anim_state msb

	sign_extension_byte = tmpfield13
	width = tmpfield14
	hitbox_flag = tmpfield16 ; Not movable - must be the same as in stb_animation_draw

	; Anotate that we encountered an hitbox
	lda #1
	sta hitbox_flag

	ldx player_number
	; Enabled
	tya
	pha
	ldy #ANIMATION_STATE_OFFSET_CLOCK
	lda (anim_state), y
	bne ignore_enabled
		pla
		tay
		lda (frame_vector), y
		ora player_a_hitbox_enabled, x
		sta player_a_hitbox_enabled, x
		jmp end_enabled
	ignore_enabled:
		pla
		tay
	end_enabled:
	iny
	; Damages
	lda (frame_vector), y
	sta player_a_hitbox_damages, x
	iny
	; Base_h
	lda (frame_vector), y
	sta player_a_hitbox_base_knock_up_h_high, x
	iny
	lda (frame_vector), y
	sta player_a_hitbox_base_knock_up_h_low, x
	iny
	; Base_v
	lda (frame_vector), y
	sta player_a_hitbox_base_knock_up_v_high, x
	iny
	lda (frame_vector), y
	sta player_a_hitbox_base_knock_up_v_low, x
	iny
	; Force_h
	lda (frame_vector), y
	sta player_a_hitbox_force_h, x
	iny
	lda (frame_vector), y
	sta player_a_hitbox_force_h_low, x
	iny
	; Force_v
	lda (frame_vector), y
	sta player_a_hitbox_force_v, x
	iny
	lda (frame_vector), y
	sta player_a_hitbox_force_v_low, x
	iny
	; Left
	lda (frame_vector), y
	sta player_a_hitbox_left, x
	iny
	; Right
	lda (frame_vector), y
	sta player_a_hitbox_right, x
	iny
	; Top
	lda (frame_vector), y
	sta player_a_hitbox_top, x
	iny
	; Top
	lda (frame_vector), y
	sta player_a_hitbox_bottom, x
	iny

	; If the player is right facing, flip the box
	lda animation_direction ; Nothing to do for left facing players
	beq apply_offset        ;

	; Flip box position
	lda player_a_hitbox_right, x ;
	sec                          ; Compute box width
	sbc player_a_hitbox_left, x  ;
	sta width                    ;

	lda player_a_hitbox_left, x  ;
	eor #%11111111               ;
	clc                          ; right = -left + 7
	adc #8                       ;
	sta player_a_hitbox_right, x ;

	sec                         ;
	sbc width                   ; left = right - width
	sta player_a_hitbox_left, x ;

	; Flip box knockback
	lda player_a_hitbox_base_knock_up_h_low, x  ;
	eor #%11111111                              ;
	clc                                         ;
	adc #1                                      ;
	sta player_a_hitbox_base_knock_up_h_low, x  ; base_h = -base_h
	lda player_a_hitbox_base_knock_up_h_high, x ;
	eor #%11111111                              ;
	adc #0                                      ;
	sta player_a_hitbox_base_knock_up_h_high, x ;

	lda player_a_hitbox_force_h_low, x ;
	eor #%11111111                     ;
	clc                                ;
	adc #1                             ;
	sta player_a_hitbox_force_h_low, x ; force_h = -force_h
	lda player_a_hitbox_force_h, x     ;
	eor #%11111111                     ;
	adc #0                             ;
	sta player_a_hitbox_force_h, x     ;

	; Apply offset to the box
	apply_offset:
	; Left
	lda player_a_hitbox_left, x
	pha
	SIGN_EXTEND()
	sta sign_extension_byte
	pla
	clc
	adc anim_pos_x
	sta player_a_hitbox_left, x
	lda sign_extension_byte
	adc anim_pos_x_msb
	sta player_a_hitbox_left_msb, x
	; Right
	lda player_a_hitbox_right, x
	pha
	SIGN_EXTEND()
	sta sign_extension_byte
	pla
	clc
	adc anim_pos_x
	sta player_a_hitbox_right, x
	lda sign_extension_byte
	adc anim_pos_x_msb
	sta player_a_hitbox_right_msb, x
	; Top
	lda player_a_hitbox_top, x
	pha
	SIGN_EXTEND()
	sta sign_extension_byte
	pla
	clc
	adc anim_pos_y
	sta player_a_hitbox_top, x
	lda sign_extension_byte
	adc anim_pos_y_msb
	sta player_a_hitbox_top_msb, x
	; Bottom
	lda player_a_hitbox_bottom, x
	pha
	SIGN_EXTEND()
	sta sign_extension_byte
	pla
	clc
	adc anim_pos_y
	sta player_a_hitbox_bottom, x
	lda sign_extension_byte
	adc anim_pos_y_msb
	sta player_a_hitbox_bottom_msb, x

	rts
.)

; Wrapper around animation_draw to handle the absence of hitbox
stb_animation_draw:
.(
	hitbox_flag = tmpfield16 ; Not movable - must be the same as in anim_frame_move_hitbox

	; Reset the flag
	;  after the call to animation_draw, the flag is set if we encountered an hitbox entry
	lda #0
	sta hitbox_flag

	; Call animation_draw and disable hitbox if there is no htibox in the frame
	jsr animation_draw
	lda hitbox_flag
	bne ok
		ldx player_number
		sta player_a_hitbox_enabled, x
	ok:

	rts
.)
