;
; Crashing
;

.(
	{char_name}_crashing_duration:
		.byt {char_name}_anim_crash_dur_pal, {char_name}_anim_crash_dur_ntsc

	&{char_name}_start_crashing:
	.(
		; Set state
		lda #{char_name_upper}_STATE_CRASHING
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda {char_name}_crashing_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<{char_name}_anim_crash
		sta tmpfield13
		lda #>{char_name}_anim_crash
		sta tmpfield14
		jsr set_player_animation

		; Play crash sound
		jmp audio_play_crash

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_crashing:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		; After move's time is out, go to standing state
		dec player_a_state_clock, x
        bne tick
            jmp {char_name}_start_inactive_state
            ; No return, jump to subroutine
        tick:

		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		ldy system_index
		lda {char_name}_ground_friction_strength_strong, y
		sta tmpfield5
		jmp merge_to_player_velocity

		;rts ; useless, jump to subroutine
	.)
.)
