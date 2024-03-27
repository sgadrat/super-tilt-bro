game_mode_server_init = dummy_routine

game_mode_server_pre_update:
.(
	; Return without skipping the frame
	clc
	rts
.)
