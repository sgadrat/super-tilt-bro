; Start a new animation for the player
;  X - Player number
;  tmpfield13 - Animation's data vector (low byte)
;  tmpfield14 - Animation's data vector (high byte)
; Overwrites register A, register Y, tmpfield11, tmpfield12, tmpfield13, tmpfield14 and tmpfield16
; Outputs - tmpfield11+tmpfield12 is a vector to the player's animation state
set_player_animation:
.(
	animation_state_vector = tmpfield11 ; Not movable - parameter of animation_state_change_animation routine
	animation_state_data = tmpfield13 ; Not movable - parameter of animation_state_change_animation routine
	;tmpfield15 shall not be modified, it is used by check_aerials_input which tends to start states which tend to set animations. May be a good idea to write a safer version of check_aerials_input

	; Chose animation state
	lda animation_state_vectors_lsb, x
	sta animation_state_vector
	lda animation_state_vectors_msb, x
	sta animation_state_vector+1

	; Reset animation
	jsr animation_state_change_animation

	; Set animation's direction
	lda player_a_direction, x
	ldy #ANIMATION_STATE_OFFSET_DIRECTION
	sta (animation_state_vector), y

	rts

	animation_state_vectors_lsb:
		.byt <player_a_animation, <player_b_animation
	animation_state_vectors_msb:
		.byt >player_a_animation, >player_b_animation
.)
