.(
	landing_duration:
		.byt {char_name}_anim_landing_dur_pal, {char_name}_anim_landing_dur_ntsc

	velocity_table({char_name_upper}_LANDING_MAX_VELOCITY, land_max_velocity_msb, land_max_velocity_lsb)
	velocity_table(-{char_name_upper}_LANDING_MAX_VELOCITY, land_max_neg_velocity_msb, land_max_neg_velocity_lsb)

	&{char_name}_start_teching:
	.(
		jsr audio_play_tech
		jmp {char_name}_start_landing_common
	.)
	&{char_name}_start_landing:
	.(
		jsr audio_play_land
		; Fallthrough
	.)
	{char_name}_start_landing_common:
	.(
#ifldef {char_name}_global_onground
		jsr {char_name}_global_onground
#endif

		; Set state
		lda #{char_name_upper}_STATE_LANDING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Cap initial velocity
		ldy system_index
		lda player_a_velocity_h, x
		bmi negative_cap
			positive_cap:
			.(
				; Check wether to cap or not
				lda land_max_velocity_msb, y
				cmp player_a_velocity_h, x
				bcc do_cap ; msb(max) < msb(velocity)
				bne ok ; msb(max) > msb(velocity)
					lda player_a_velocity_h_low, x
					cmp land_max_velocity_lsb, y
					bcc ok ; lsb(velocity) < lsb(max)

				do_cap:
					lda land_max_velocity_msb, y
					sta player_a_velocity_h, x
					lda land_max_velocity_lsb, y
					sta player_a_velocity_h_low, x
				ok:
				jmp set_landing_animation
			.)
			negative_cap:
			.(
				; Check wether to cap or not - negative, we have to cap if unsigned CMP is lower than "max"
				lda player_a_velocity_h, x
				cmp land_max_velocity_msb, y
				bcc do_cap ; msb(velocity) < msb(max)
				bne ok ; msb(velocity) > msb(max)
					lda land_max_velocity_lsb, y
					cmp player_a_velocity_h_low, x
					bcc ok ; lsb(max) < lsb(velocity)

				do_cap:
					lda land_max_neg_velocity_msb, y
					sta player_a_velocity_h, x
					lda land_max_neg_velocity_lsb, y
					sta player_a_velocity_h_low, x
				ok:
			.)

		; Fallthrough to set the animation
	.)
	set_landing_animation:
	.(
		; Set the appropriate animation
		lda #<{char_name}_anim_landing
		sta tmpfield13
		lda #>{char_name}_anim_landing
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_landing:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		; Tick clock
		inc player_a_state_clock, x

		; Do not move, velocity tends toward vector (0,0)
		jsr {char_name}_apply_ground_friction

		; After move's time is out, go to standing state
		ldy system_index
		lda player_a_state_clock, x
		cmp landing_duration, y
		bne end
			jmp {char_name}_start_inactive_state
			; No return, jump to subroutine

		end:
		rts
	.)
.)
