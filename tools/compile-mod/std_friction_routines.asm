#iflused {char_name}_apply_air_friction
{char_name}_apply_air_friction:
.(
	; merge_to_player_velocity parameter names
	merged_v_low = tmpfield1
	merged_v_high = tmpfield3
	merged_h_low = tmpfield2
	merged_h_high = tmpfield4
	merge_step = tmpfield5

	; Apply air friction
	lda player_a_velocity_v_low, x
	sta merged_v_low
	lda player_a_velocity_v, x
	sta merged_v_high
	lda #$00
	sta merged_h_low
	sta merged_h_high
	ldy system_index
	lda {char_name}_air_friction_strength, y
	sta merge_step
	jmp merge_to_player_velocity
	;rts; useless, jump to a subroutine
.)
#endif

#iflused {char_name}_apply_ground_friction
{char_name}_apply_ground_friction:
.(
	; merge_to_player_velocity parameter names
	merged_v_low = tmpfield1
	merged_v_high = tmpfield3
	merged_h_low = tmpfield2
	merged_h_high = tmpfield4
	merge_step = tmpfield5

	; Apply ground friction
	lda #$00
	sta merged_h_high
	sta merged_v_high
	sta merged_h_low
	sta merged_v_low
	ldy system_index
	lda {char_name}_ground_friction_strength, y
	sta tmpfield5
	jmp merge_to_player_velocity
	;rts ; useless, jump to subroutine
.)
#endif
