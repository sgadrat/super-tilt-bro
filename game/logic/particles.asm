#define PARTICLE_DEATH_COUNTER_END 11

; Start directional indicator particles for a player
;  X - player number
;
; Uses particle box number 0 for player A or 1 for player B
; Deactivate any particle handler on the same box
;
; Overwrites A, Y, tmpfield1 to tmpfield3
particle_directional_indicator_start:
.(
	; Initialize handler state
	lda #9
	sta directional_indicator_player_a_counter, x
	lda player_a_velocity_v_low, x
	sta directional_indicator_player_a_direction_y_low, x
	lda player_a_velocity_v, x
	sta directional_indicator_player_a_direction_y_high, x
	lda player_a_velocity_h_low, x
	sta directional_indicator_player_a_direction_x_low, x
	lda player_a_velocity_h, x
	sta directional_indicator_player_a_direction_x_high, x

	; Deactivate death particles
	lda #PARTICLE_DEATH_COUNTER_END
	sta death_particles_player_a_counter, x

	; Initialize particles
	txa ;
	asl ;
	asl ;
	asl ; Y points on the particle box of the player
	asl ;
	asl ;
	tay ;

	lda #1                                                ;
	sta particle_blocks+PARTICLE_BLOCK_OFFSET_PARAM, y    ;
	lda #TILE_BLOOD_PARTICLE                              ;
	sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILENUM, y  ; Box header
	txa                                                   ;
	asl                                                   ;
	sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILEATTR, y ;

	lda #<set_particle_position ;
	sta tmpfield1               ;
	lda #>set_particle_position ; Set particles initial position
	sta tmpfield2               ;
	jsr loop_on_particles       ;

	rts

	set_particle_position:
	.(
		particle_counter = tmpfield3

		; Initialize particle position's low component (in particle handler state)
		;  index in the table = player_number * 8 + particle_counter
		txa
		pha
		asl
		asl
		asl
		clc
		adc particle_counter
		tax
		lda #0
		sta directional_indicator_player_a_position_x_low, x
		sta directional_indicator_player_a_position_y_low, x
		pla
		tax

		; Initialize particle position's high components (in the particle block)
		lda player_a_x, x
		sta particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y
		lda player_a_x_screen, x
		sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y
		lda player_a_y, x
		sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y
		lda player_a_y_screen, x
		sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y
		rts
	.)
.)

; Move directional indicator particles of a player
;  X - player number
;
; Overwrites A, Y, tmpfield1 to tmpfield7
particle_directional_indicator_tick:
.(
	; Avoid doing anything if not activated (counter at zero)
	lda directional_indicator_player_a_counter, x
	bne do_something
		rts
	do_something:

	; Decrement counter
	dec directional_indicator_player_a_counter, x

	; Y points on the particle box of the player
	txa
	asl
	asl
	asl
	asl
	asl
	tay

	; Chose what to do depending on the counter
	lda directional_indicator_player_a_counter, x
	beq go_disable_box
		jsr move_particles
		jmp end
	go_disable_box:
		txa
		pha
		jsr deactivate_particle_block
		pla
		tax

	end:
		rts

	move_particles:
	.(
		particle_y_direction_low = tmpfield4
		particle_y_direction_high = tmpfield5
		particle_x_position_low = tmpfield6
		particle_y_position_low = tmpfield7

		lda #<move_one_particle
		sta tmpfield1
		lda #>move_one_particle
		sta tmpfield2
		jsr loop_on_particles

		rts

		move_one_particle:
		.(
			particle_counter = tmpfield3

			txa                                                  ;
			pha                                                  ;
			asl                                                  ;
			asl                                                  ;
			asl                                                  ;
			clc                                                  ;
			adc particle_counter                                 ; Easy access to subpixel components of particle's position
			tax
			lda directional_indicator_player_a_position_x_low, x ;  index in the table = player_number * 8 + particle_counter
			sta particle_x_position_low                          ;
			lda directional_indicator_player_a_position_y_low, x ;
			sta particle_y_position_low                          ;
			pla                                                  ;
			tax                                                  ;

			lda directional_indicator_player_a_direction_x_low, x  ;
			clc                                                    ;
			adc particle_x_position_low                            ;
			sta particle_x_position_low                            ;
			lda directional_indicator_player_a_direction_x_high, x ;
			adc particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y  ;
			sta particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y  ; Apply horizontal velocity
			lda directional_indicator_player_a_direction_x_high, x ;
			SIGN_EXTEND()                                          ;
			adc particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y  ;
			sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y  ;

			lda directional_indicator_player_a_direction_y_low, x  ;
			sta particle_y_direction_low                           ;
			lda directional_indicator_player_a_counter, x          ;
			cmp #6                                                 ;
			bpl separate                                           ;
			lda directional_indicator_player_a_direction_y_high, x ; Modify vertical velocity depending on particle number
			jmp set_y_direction                                    ;
			separate:                                              ;
			lda particle_counter                                   ;
			clc                                                    ;
			adc directional_indicator_player_a_direction_y_high, x ;
			set_y_direction:                                       ;
			sta particle_y_direction_high                          ;

			lda particle_y_direction_low                           ;
			clc                                                    ;
			adc particle_y_position_low                            ;
			sta particle_y_position_low                            ;
			lda particle_y_direction_high                          ;
			adc particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y  ;
			sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y  ; Apply vertical velocity
			lda particle_y_direction_high                          ;
			SIGN_EXTEND()                                          ;
			adc particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y  ;
			sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y  ;

			txa                                                  ;
			pha                                                  ;
			asl                                                  ;
			asl                                                  ;
			asl                                                  ;
			clc                                                  ;
			adc particle_counter                                 ; Store position subpixel components in particle handler state
			tax                                                  ;
			lda particle_x_position_low                          ;
			sta directional_indicator_player_a_position_x_low, x ;
			lda particle_y_position_low                          ;
			sta directional_indicator_player_a_position_y_low, x ;
			pla                                                  ;
			tax                                                  ;
			rts
		.)
	.)
.)

; Start death particles for a player
;  X - player number
;  tmpfield1 - Source X position
;  tmpfield2 - Source Y position
;
; Uses particle box number 0 for player A or 1 for player B
; Deactivate any particle handler on the same box
;
; Overwrites register A, register Y, tmpfield1, tmpfield2, tmpfield3, tmpfield4, tmpfield5 tmpfield6 and tmpfield7
particle_death_start:
.(
	position_x_param = tmpfield1
	position_y_param = tmpfield2
	; tmpfiel3 used by loop on particles
	orientation_x = tmpfield4
	orientation_y = tmpfield5
	position_x_store = tmpfield6
	position_y_store = tmpfield7

	; Initialize handler's state
	lda #0
	sta death_particles_player_a_counter, x

	; Deactivate directional indicator in the same box
	sta directional_indicator_player_a_counter, x

	; Store position to unused space
	lda position_x_param
	sta position_x_store
	lda position_y_param
	sta position_y_store

	; Compute particles orientation
	lda player_a_velocity_h, x
	eor #%11111111
	clc
	adc #$01
	sta orientation_x

	lda player_a_velocity_v, x
	eor #%11111111
	clc
	adc #$01
	sta orientation_y

	; Initialize particles
	txa    ;
	clc    ;
	asl    ;
	asl    ;
	asl    ; Y points on the particle box of the player
	asl    ;
	asl    ;
	tay    ;

	lda #1                                                ;
	sta particle_blocks+PARTICLE_BLOCK_OFFSET_PARAM, y    ;
	lda #TILE_EXPLOSION_1                                 ;
	sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILENUM, y  ; Box header
	txa                                                   ;
	asl                                                   ;
	sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILEATTR, y ;

	lda #<place_one_particle ;
	sta tmpfield1            ;
	lda #>place_one_particle ; Particles position
	sta tmpfield2            ;
	jsr loop_on_particles    ;

	rts

	place_one_particle:
	.(
		particle_counter = tmpfield3 ; Not movable, imposed by loop_on_plarticles
		position_x = position_x_store
		position_y = position_y_store

		lda #0                                                ;
		sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ; Set position MSB to main screen
		sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;

		lda position_x                                        ;
		cmp #248                                              ;
		bcc no_reposition_x                                   ; Set particle's horizontal position
		lda #248                                              ;
		no_reposition_x:                                      ;
		sta particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y ;

		clc               ;
		adc orientation_x ;
		clc               ; Compute next particle's horizontal position
		adc orientation_x ;
		sta position_x    ;

		lda position_y                                        ;
		cmp #232                                              ;
		bcc no_reposition_y                                   ; Set particle's vertical position
		lda #232                                              ;
		no_reposition_y:                                      ;
		sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y ;

		clc               ;
		adc orientation_y ;
		clc               ; Compute next particle's vertical position
		adc orientation_y ;
		sta position_y    ;

		txa                                                   ;
		pha                                                   ;
		lda particle_counter                                  ;
		tax                                                   ;
		dex                                                   ;
		lda particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y ;
		clc                                                   ;
		adc particles_start_position_offset_x, x               ; Apply particle's offset position
		sta particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y ;
		lda particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y ;
		clc                                                   ;
		adc particles_start_position_offset_y, x              ;
		sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y ;
		pla                                                   ;
		tax                                                   ;

		rts

		particles_start_position_offset_x:
		.byt $00, $fc, $fc, $00, $00, $04, $04
		particles_start_position_offset_y:
		.byt $00, $fc, $04, $f8, $08, $fc, $04
	.)
.)

; Update death particles of a player
;  X - player number
;
; Overwrites A, Y, tmpfield1, tmpfield2, tmpfield3 and tmpfield4
particle_death_tick:
.(
	;particle_counter = tmpfield1

	; Do nothing if deactivated
	lda death_particles_player_a_counter, x
	cmp #PARTICLE_DEATH_COUNTER_END
	beq do_nothing

	; Y points on the particle box of the player
	txa
	clc
	asl
	asl
	asl
	asl
	asl
	tay

	; Choose what to do depending on counter
	lda death_particles_player_a_counter, x
	cmp #PARTICLE_DEATH_COUNTER_END-1
	beq go_disable_box

	; Update particles tile to animate the explosion
	lsr
	clc
	adc #TILE_EXPLOSION_1
	sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILENUM, y

	end:
	inc death_particles_player_a_counter, x
	do_nothing:
	rts

	go_disable_box:
	.(
		txa
		pha
		jsr deactivate_particle_block
		pla
		tax
		jmp end
	.)
.)
