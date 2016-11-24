;
; INGAME labels
;

; State of the player's character
;  May take any value from PLAYER_STATE_XXX constants
player_a_state = $00
player_b_state = $01

; $02 free
player_a_hitstun = $03
player_b_hitstun = $04
player_a_x = $05
player_b_x = $06
player_a_y = $07
player_b_y = $08
player_a_direction = $0009 ; 0 - watching left
player_b_direction = $000a ; 1 - watching right
player_a_velocity_v = $0b
player_b_velocity_v = $0c
player_a_velocity_h = $0d
player_b_velocity_h = $0e
player_a_state_field1 = $0f
player_b_state_field1 = $10
player_a_state_field2 = $11
player_b_state_field2 = $12
player_a_animation = $13
player_b_animation = $15
player_a_anim_clock = $17
player_b_anim_clock = $18
player_a_hurtbox_left = $19
player_b_hurtbox_left = $1a
player_a_hurtbox_right = $1b
player_b_hurtbox_right = $1c
player_a_hurtbox_top = $1d
player_b_hurtbox_top = $1e
player_a_hurtbox_bottom = $1f
player_b_hurtbox_bottom = $20
player_a_hitbox_left = $21
player_b_hitbox_left = $22
player_a_hitbox_right = $23
player_b_hitbox_right = $24
player_a_hitbox_top = $25
player_b_hitbox_top = $26
player_a_hitbox_bottom = $27
player_b_hitbox_bottom = $28
player_a_hitbox_enabled = $0029 ; 0 - hitbox disabled
player_b_hitbox_enabled = $002a ; 1 - hitbox enabled
player_a_hitbox_force_v = $2b
player_b_hitbox_force_v = $2c
player_a_hitbox_force_h = $2d
player_b_hitbox_force_h = $2e
player_a_hitbox_damages = $2f
player_b_hitbox_damages = $30
player_a_damages = $31
player_b_damages = $32
player_a_x_low = $33
player_b_x_low = $34
player_a_y_low = $35
player_b_y_low = $36
player_a_velocity_v_low = $37
player_b_velocity_v_low = $38
player_a_velocity_h_low = $39
player_b_velocity_h_low = $3a
player_a_hitbox_force_v_low = $3b
player_b_hitbox_force_v_low = $3c
player_a_hitbox_force_h_low = $3d
player_b_hitbox_force_h_low = $3e
player_a_hitbox_base_knock_up_v_high = $3f
player_b_hitbox_base_knock_up_v_high = $40
player_a_hitbox_base_knock_up_h_high = $41
player_b_hitbox_base_knock_up_h_high = $42
player_a_hitbox_base_knock_up_v_low = $43
player_b_hitbox_base_knock_up_v_low = $44
player_a_hitbox_base_knock_up_h_low = $45
player_b_hitbox_base_knock_up_h_low = $46
; $47 free
; $48 free
player_a_num_aerial_jumps = $49
player_b_num_aerial_jumps = $4a
player_a_stocks = $4b
player_b_stocks = $4c

screen_shake_counter = $70
screen_shake_nextval = $71

;
; TITLE labels
;

title_cheatstate = $00

;
; GAMEOVER labels
;

gameover_winner = $00

;
; Audio engine labels
;

audio_square1_counter = $d0
audio_square1_note_counter = $d1
audio_square2_counter = $d2
audio_square2_note_counter = $d3
audio_triangle_counter = $d4
audio_triangle_note_counter = $d5

audio_channel_mode = $d6

audio_square1_track = $d7
audio_square2_track = $d9
audio_triangle_track = $db

audio_duty = $dd

;
; Global labels
;

controller_a_btns = $e0
controller_b_btns = $e1
controller_a_last_frame_btns = $e2
controller_b_last_frame_btns = $e3
global_game_state = $e4

; State of the NMI processing
;  $00 - NMI processed
;  $01 - Waiting for the next NMI to be processed
nmi_processing = $e5

scroll_x = $e6
scroll_y = $e7
ppuctrl_val = $e8

tmpfield1 = $f0
tmpfield2 = $f1
tmpfield3 = $f2
tmpfield4 = $f3
tmpfield5 = $f4
tmpfield6 = $f5
tmpfield7 = $f6
tmpfield8 = $f7
tmpfield9 = $f8
tmpfield10 = $f9
tmpfield11 = $fa
tmpfield12 = $fb
tmpfield13 = $fc
tmpfield14 = $fd
tmpfield15 = $fe

oam_mirror = $0200
nametable_buffers = $0300
