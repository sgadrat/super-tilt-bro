init_support_btc_screen:
.(
	lda #<menu_support_contents_btc
	sta tmpfield1
	lda #>menu_support_contents_btc
	sta tmpfield2

	jmp init_support_qr_screen
	;rts ; useless, jump to subroutine
.)

init_support_paypal_screen:
.(
	lda #<menu_support_contents_paypal
	sta tmpfield1
	lda #>menu_support_contents_paypal
	sta tmpfield2
	
	;jmp init_support_qr_screen ; fallthrough
.)

init_support_qr_screen:
.(
	; Redraw box contents
	SWITCH_BANK(#MENU_SUPPORT_SCREEN_BANK_NUMBER)
	jsr support_screen_draw_contents
	
	; Fix attributes from speech screen
	lda #<clear_selection
	ldy #>clear_selection
	jsr push_nt_buffer

	; Initialize common menus effects
	jmp re_init_menu

	;rts ; useless, jump to subroutine

	clear_selection:
		.byt $23, $f1, $06, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.)

support_qr_screen_tick:
.(
	jsr reset_nt_buffers

	; Play common menus effects
	jsr tick_menu

	; If all buttons of any controller are released on this frame, got to the next screen
	lda controller_a_btns
	bne check_controller_b
	cmp controller_a_last_frame_btns
	bne next_screen
	check_controller_b:
	lda controller_b_btns
	bne end
	cmp controller_b_last_frame_btns
	bne next_screen
	jmp end

	next_screen:
	lda #GAME_STATE_DONATION
	jsr change_global_game_state

	end:
	rts
.)
