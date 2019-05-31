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
	txa

#if ANIMATION_STATE_LENGTH <> 12
#error code expects an animation state's length of 12 bytes
#endif
	asl            ;
	asl            ;
	sta tmpfield16 ;
	asl            ; A = X * ANIMATION_STATE_LENGTH (== offset of the player's animation state)
	clc            ;
	adc tmpfield16 ;

	clc
	adc #<player_a_animation
	sta animation_state_vector
	lda #0
	adc #>player_a_animation
	sta animation_state_vector+1

	; Reset animation
	jsr animation_state_change_animation

	; Set animation's direction
	lda player_a_direction, x
	ldy #ANIMATION_STATE_OFFSET_DIRECTION
	sta (animation_state_vector), y

	rts
.)
