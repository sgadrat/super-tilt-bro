;
; Screen between fights implementation
;

init_arcade_mode:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#ARCADE_MODE_EXTRA_BANK_NUMBER)
	jmp init_arcade_mode_extra

	;rts ; useless, jump to subroutine
.)

arcade_mode_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#ARCADE_MODE_EXTRA_BANK_NUMBER)
	jmp arcade_mode_tick_extra

	;rts ; useless, jump to subroutine
.)

;
; Game mode implementation
;

game_mode_arcade_init:
.(
	SWITCH_BANK(#ARCADE_MODE_EXTRA_BANK_NUMBER)
	jmp game_mode_arcade_init_hook
	;rts
.)

game_mode_arcade_pre_update:
.(
	SWITCH_BANK(#ARCADE_MODE_EXTRA_BANK_NUMBER)
	jmp game_mode_arcade_pre_update_hook
	;rts
.)

game_mode_arcade_gameover:
.(
	SWITCH_BANK(#ARCADE_MODE_EXTRA_BANK_NUMBER)
	jmp game_mode_arcade_gameover_hook
	;rts
.)

;
; Fixed bank utilities
;

arcade_copy_targets:
.(
	stage_header_addr = tmpfield1
	;stage_header_addr_msb = tmpfield2

	copy_one_target:
		lda (stage_header_addr), y
		sta arcade_mode_targets_x, x
		iny
		lda (stage_header_addr), y
		sta arcade_mode_targets_y, x
		iny

		dex
		bpl copy_one_target

	rts
.)

; Copy the exit rectangle to "box_overlap" rectangle 1
;  Note - it actually copy any flat rectangle pointed, it may be generalized
arcade_copy_exit_rectangle:
.(
	exit_left_pixel = tmpfield1 ; Rectangle 1 pixel components
	exit_left_screen = tmpfield9 ; Rectangle 1 screen components
	player_left_pixel = tmpfield5 ; Rectangle 2 pixel components

	stage_header_addr = player_left_pixel ; Must be synchronized with the caller

	ldy #0
	ldx #0
	copy_one_component:
		lda (stage_header_addr), y
		sta exit_left_pixel, x
		iny
		lda (stage_header_addr), y
		sta exit_left_screen, x
		iny

		inx
		cpx #4
		bne copy_one_component

	rts
.)
