squareman_start_thrown:
.(
	; Set the appropriate animation
	lda #<squareman_anim_idle
	sta tmpfield13
	lda #>squareman_anim_idle
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda PLAYER_STATE_THROWN
	sta player_a_state, x
	rts
.)

squareman_tick_thrown:
.(
	rts
.)


squareman_start_respawn:
.(
	; Set the appropriate animation
	lda #<squareman_anim_idle
	sta tmpfield13
	lda #>squareman_anim_idle
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda PLAYER_STATE_RESPAWN
	sta player_a_state, x
	rts
.)

squareman_tick_respawn:
.(
	rts
.)


squareman_start_innexistant:
.(
	; Set the appropriate animation
	lda #<squareman_anim_idle
	sta tmpfield13
	lda #>squareman_anim_idle
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda PLAYER_STATE_INNEXISTANT
	sta player_a_state, x
	rts
.)

squareman_tick_innexistant:
.(
	rts
.)


squareman_start_spawn:
.(
	; Set the appropriate animation
	lda #<squareman_anim_idle
	sta tmpfield13
	lda #>squareman_anim_idle
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda PLAYER_STATE_SPAWN
	sta player_a_state, x
	rts
.)

squareman_tick_spawn:
.(
	rts
.)
