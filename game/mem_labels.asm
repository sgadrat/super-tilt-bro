;
; C code labels
;

c_stack_end = $07ff
_sp0 = $00
_sp1 = $01
_fp0 = $02
_fp1 = $03
_r0 = $04
_r1 = $05
_r2 = $06
_r3 = $07
_r4 = $08
_r5 = $09
_r6 = $0a
_r7 = $0b
_s0 = $0c
_s1 = $0d
_s2 = $0e
_s3 = $0f
_s4 = $10
_s5 = $11
_s6 = $12
_s7 = $13
_e0 = $14
_e1 = $15
_e2 = $16
_e3 = $17
_e4 = $18
_e5 = $19
_e6 = $1a
_e7 = $1b
_e8 = $1c
_e9 = $1d
_e10 = $1e
_e11 = $1f
_e12 = $20
_e13 = $21
_e14 = $22
_e15 = $23
_e16 = $24
_e17 = $25
_e18 = $26
_e19 = $27
_e20 = $28
_e21 = $29
_e22 = $2a
_e23 = $2b
_e24 = $2c
_e25 = $2d
_e26 = $2e
_e27 = $2f
_e28 = $30
_e29 = $31
_e30 = $32
_e31 = $33
_tmp0 = $34
_tmp1 = $35
_sa = $36
_sx = $37
_sy = $38
last_c_label = _sy

;
; INGAME labels
;

; State of the player's character
;  May take any value from selected character's state machine
player_a_state = $00
player_b_state = $01

; $02 - used by gameover_winner
player_a_hitstun = $03
player_b_hitstun = $04
player_a_x = $05
player_b_x = $06
player_a_y = $07
player_b_y = $08
player_a_direction = $09 ; 0 - watching left
player_b_direction = $0a ; 1 - watching right
player_a_velocity_v = $0b
player_b_velocity_v = $0c
player_a_velocity_h = $0d
player_b_velocity_h = $0e
player_a_state_field1 = $0f
player_b_state_field1 = $10
player_a_state_field2 = $11
player_b_state_field2 = $12
player_a_x_screen = $13
player_b_x_screen = $14
player_a_y_screen = $15
player_b_y_screen = $16
player_a_state_clock = $17
player_b_state_clock = $18
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
player_a_state_field3 = $47
player_b_state_field3 = $48
player_a_num_aerial_jumps = $49
player_b_num_aerial_jumps = $4a
player_a_stocks = $4b
player_b_stocks = $4c
player_a_gravity = $4d
player_b_gravity = $4e

;TODO put is with other registers, it is used by multiple states (and animation code)
player_number = $4f ; Extra register to hold a player number, used when register X is inconvenient

ai_current_action_lsb = $50
ai_current_action_msb = $51
ai_current_action_counter = $52
ai_current_action_step = $53
ai_current_action_modifier = $54
ai_delay = $55
ai_max_delay = $56

player_a_hurtbox_left_msb = $57
player_b_hurtbox_left_msb = $58
player_a_hurtbox_right_msb = $59
player_b_hurtbox_right_msb = $5a
player_a_hurtbox_top_msb = $5b
player_b_hurtbox_top_msb = $5c
player_a_hurtbox_bottom_msb = $5d
player_b_hurtbox_bottom_msb = $5e
player_a_hitbox_left_msb = $5f
player_b_hitbox_left_msb = $60
player_a_hitbox_right_msb = $61
player_b_hitbox_right_msb = $62
player_a_hitbox_top_msb = $63
player_b_hitbox_top_msb = $64
player_a_hitbox_bottom_msb = $65
player_b_hitbox_bottom_msb = $66

player_a_grounded = $67 ; $00 if not grounded, else the offset of grounded platform from stage_data
player_b_grounded = $68
player_a_walled = $69 ; $00 if not touching a wall, else the offset of the platform from stage_data
player_b_walled = $6a
player_a_walled_direction = $6b ; DIRECTION_LEFT - player is on the left of the wall
player_b_walled_direction = $6c ; DIRECTION_RIGHT - player is on the right of the wall

screen_shake_counter = $70
screen_shake_nextval_x = $71
screen_shake_nextval_y = $72

directional_indicator_player_a_counter = $73
directional_indicator_player_b_counter = $74
directional_indicator_player_a_direction_x_high = $75
directional_indicator_player_b_direction_x_high = $76
directional_indicator_player_a_direction_x_low = $77
directional_indicator_player_b_direction_x_low = $78
directional_indicator_player_a_direction_y_high = $79
directional_indicator_player_b_direction_y_high = $7a
directional_indicator_player_a_direction_y_low = $7b
directional_indicator_player_b_direction_y_low = $7c
; particles lo position tables
;  | byte 0 | bytes 1 to 7       | byte 8 | bytes 9 to 15      |
;  | unused | player A particles | unused | player B particles |
directional_indicator_player_a_position_x_low = $90 ; $90 to $9f - unused $90 and $98
directional_indicator_player_a_position_y_low = $a0 ; $a0 to $af - unused $a0 and $a8

death_particles_player_a_counter = $7d
death_particles_player_b_counter = $7e

slow_down_counter = $7f

players_palettes = $0580 ; $0580 to $059f - 4 nametable buffers (8 bytes each) containing avatars palettes in normal and alternate mode
player_a_animation = $05a0 ; $05a0 to $05ab - player a's animation state
player_b_animation = $05ac ; $05ac to $05b7 - player b's animation state
player_a_out_of_screen_indicator = $05b8 ; $05b8 to $05c3 - player a's out of screen animation state
player_b_out_of_screen_indicator = $05c4 ; $05c4 to $05cf - player b's out of screen animation state

;
; Stage specific labels
;

stage_state_begin = $80

stage_pit_platform1_direction_v = $80
stage_pit_platform2_direction_v = $81
stage_pit_platform1_direction_h = $82
stage_pit_platform2_direction_h = $83

stage_gem_gem_position_x_low = $80
stage_gem_gem_position_x_high = $81
stage_gem_gem_position_y_low = $82
stage_gem_gem_position_y_high = $83
stage_gem_gem_velocity_h_low = $84
stage_gem_gem_velocity_h_high = $85
stage_gem_gem_velocity_v_low = $86
stage_gem_gem_velocity_v_high = $87
stage_gem_gem_cooldown_low = $88
stage_gem_gem_cooldown_high = $89
stage_gem_gem_state = $8a ; one of STAGE_GEM_GEM_STATE_*
stage_gem_buffed_player = $8b
stage_gem_last_opponent_state = $8c
stage_gem_frame_cnt = $8d

;Note - $90 to $af are used by DI particles

; Extra zero-page registers
extra_tmpfield1 = $b0
extra_tmpfield2 = $b1
extra_tmpfield3 = $b2
extra_tmpfield4 = $b3
extra_tmpfield5 = $b4
extra_tmpfield6 = $b5

;
; Network engine labels
;

network_current_frame_byte0 = $b6
network_current_frame_byte1 = $b7
network_current_frame_byte2 = $b8
network_current_frame_byte3 = $b9

network_client_id_byte0 = $ba
network_client_id_byte1 = $bb
network_client_id_byte2 = $bc
network_client_id_byte3 = $bd

network_last_sent_btns = $be
network_local_player_number = $bf

server_current_frame_byte0 = $eb
server_current_frame_byte1 = $ec
server_current_frame_byte2 = $ed
server_current_frame_byte3 = $ee
network_rollback_mode = $ef ; 0 - normal, 1 - rolling ; Note - also used by game tick to know if a frame will be drawn, may be renamed something more generic like "dummy_frame"

;
; Network login labels
;

; TODO for now expects RAINBOW's WRAM at $6000, should fit in normal NES RAM + RAINBOW files

network_login = $6000 ; $6000-$600f
network_password = $6010 ; $6010-$601f
network_logged = $6020
network_ranked = $6021

;
; TITLE labels
;

title_cheatstate = $00
title_animation_frame = $01
title_animation_state = $02
title_original_music_state = $03

;
; MODE_SELECTION labels
;

mode_selection_current_option = $00

;
; ONLINE_MODE_SELECTION labels
;

online_mode_selection_current_option = last_c_label+1
online_mode_ship_dest_x = online_mode_selection_current_option+1
online_mode_ship_dest_y = online_mode_ship_dest_x+1
online_mode_frame_count = online_mode_ship_dest_y+1
online_mode_rnd = online_mode_frame_count+1

online_mode_selection_mem_buffer = $0580 ; $0580 to $05bf (64 bytes)
online_mode_selection_cursor_anim = $05c0 ; $05c0 to $05cb
online_mode_selection_ship_anim = $05cc ; $05cc to $05d7

;
; CONFIG labels
;

config_selected_option = last_c_label+1
config_music_enabled = last_c_label+2

;
; CHARACTER_SELECTION labels
;

character_selection_player_a_bg_task = last_c_label+1 ; $39-$3f
character_selection_player_b_bg_task = character_selection_player_a_bg_task+7 ; $40-$46
character_selection_player_a_ready = character_selection_player_b_bg_task+7 ; $47
character_selection_player_b_ready = character_selection_player_a_ready+1 ; $48
character_selection_player_a_rnd = character_selection_player_b_ready+1 ; $49
character_selection_player_b_rnd = character_selection_player_a_rnd+1 ; $4a
character_selection_control_scheme = character_selection_player_b_rnd+1 ; $4b
character_selection_fix_screen_bg_task = character_selection_control_scheme+1 ; $4c

character_selection_mem_buffer = $0580 ; $0580 to $05bf (4 tiles of 16 bytes each)
character_selection_player_a_cursor_anim = $05c0 ; $05c0 to $05cb
character_selection_player_b_cursor_anim = $05cc ; $05cc to $05d7
character_selection_player_a_char_anim = $05d8 ; $05d8 to $05e3
character_selection_player_b_char_anim = $05e4 ; $05e4 to $05ef
;$05f0-$05ff unused
character_selection_player_a_builder_anim = $0680 ; $0680 to $068b
character_selection_player_b_builder_anim = $068c ; $068c to $0697

;
; STAGE_SELECTION labels
;

stage_selection_cursor_anim = last_c_label+1
stage_selection_bg_task = stage_selection_cursor_anim+12

stage_selection_mem_buffer = $0580 ; $0580 to $05bf (4*16 bytes)

;
; NETPLAY_LAUNCH labels
;

netplay_launch_state = $00
netplay_launch_counter = $01
netplay_launch_ping_min = $02
netplay_launch_ping_max = $03
netplay_launch_server = $04
netplay_launch_nb_servers = $05

;
; DONATION labels
;

donation_method = $00

;
; Common menus labels
;  Common to TITLE, CONFIG, CHARACTER_SELECTION, STAGE_SELECTION and CREDITS
;

menu_common_tick_num = $50

menu_common_cloud_1_x = $51
menu_common_cloud_2_x = $52
menu_common_cloud_3_x = $53
menu_common_cloud_1_y = $54
menu_common_cloud_2_y = $55
menu_common_cloud_3_y = $56
menu_common_cloud_1_y_msb = $57
menu_common_cloud_2_y_msb = $58
menu_common_cloud_3_y_msb = $59

screen_sprites_y_lsb = $0400 ; $0400 to $043f
screen_sprites_y_msb = $0440 ; $0440 to $047f

;
; GAMEOVER labels
;

gameover_winner = $02
gameover_balloon0_x = $50
gameover_balloon1_x = $51
gameover_balloon2_x = $52
gameover_balloon3_x = $53
gameover_balloon4_x = $54
gameover_balloon5_x = $55
gameover_balloon0_x_low = $56
gameover_balloon1_x_low = $57
gameover_balloon2_x_low = $58
gameover_balloon3_x_low = $59
gameover_balloon4_x_low = $5a
gameover_balloon5_x_low = $5b
gameover_balloon0_y = $5c
gameover_balloon1_y = $5d
gameover_balloon2_y = $5e
gameover_balloon3_y = $5f
gameover_balloon4_y = $60
gameover_balloon5_y = $61
gameover_balloon0_y_low = $62
gameover_balloon1_y_low = $63
gameover_balloon2_y_low = $64
gameover_balloon3_y_low = $65
gameover_balloon4_y_low = $66
gameover_balloon5_y_low = $67

gameover_balloon0_velocity_h = $68
gameover_balloon1_velocity_h = $69
gameover_balloon2_velocity_h = $6a
gameover_balloon3_velocity_h = $6b
gameover_balloon4_velocity_h = $6c
gameover_balloon5_velocity_h = $6d

gameover_random = $4e

;
; Audio engine labels
;

audio_music_enabled = $c0

audio_current_track_lsb = $c1
audio_current_track_msb = $c2

audio_square1_sample_num = $c3
audio_square2_sample_num = $c4
audio_triangle_sample_num = $c5
audio_noise_sample_num = $c6

audio_skip_noise = $c7 ;HACK Setting this value makes the audio engine not touch the noise channel, allowing old sfx (based on hacking noise channel) to play

audio_square1_current_opcode = $0604
audio_square2_current_opcode = $0605
audio_triangle_current_opcode = $0606
audio_noise_current_opcode = $0607
audio_square1_current_opcode_msb = $0608
audio_square2_current_opcode_msb = $0609
audio_triangle_current_opcode_msb = $060a
audio_noise_current_opcode_msb = $060b
audio_square1_wait_cnt = $060c
audio_square2_wait_cnt = $060d
audio_triangle_wait_cnt = $060e
audio_noise_wait_cnt = $060f
audio_square1_default_note_duration = $0610
audio_square2_default_note_duration = $0611
audio_triangle_default_note_duration = $0612
audio_square1_apu_envelope_byte = $0613
audio_square2_apu_envelope_byte = $0614
audio_square1_apu_timer_low_byte = $0615
audio_square2_apu_timer_low_byte = $0616
audio_triangle_apu_timer_low_byte = $0617
audio_square1_apu_timer_high_byte = $0618
audio_square2_apu_timer_high_byte = $0619
audio_triangle_apu_timer_high_byte = $061a
audio_square1_apu_timer_high_byte_old = $061b
audio_square2_apu_timer_high_byte_old = $061c
audio_triangle_apu_timer_high_byte_old = $061d ; Actually useless for triangle, but allows to easily merge code for pulse/triangle (unused now, triangle timer is handled in a "if triangle" branch) ;TODO remove it once code is stable enough to confidently state that we'll never use it
audio_square1_pitch_slide_lsb = $061e
audio_square2_pitch_slide_lsb = $061f
audio_triangle_pitch_slide_lsb = $0620
audio_square1_pitch_slide_msb = $0621
audio_square2_pitch_slide_msb = $0622
audio_triangle_pitch_slide_msb = $0623

audio_noise_apu_envelope_byte = $0624
audio_noise_apu_period_byte = $0625 ; bit 4 used to silence the channel, so it is Ls.. PPPP with s handled by the engine
audio_noise_pitch_slide = $0626

;
; Global labels
;

controller_a_btns = $d0
controller_b_btns = $d1
controller_a_last_frame_btns = $d2
controller_b_last_frame_btns = $d3
global_game_state = $d4

nmi_processing = $d5

scroll_x = $d6
scroll_y = $d7
ppuctrl_val = $d8

config_initial_stocks = $d9
config_ai_level = $da
config_selected_stage = $db
config_player_a_character_palette = $dc
config_player_b_character_palette = $dd
config_player_a_weapon_palette = $de
config_player_b_weapon_palette = $df
config_player_a_character = $e0
config_player_b_character = $e1
config_game_mode = $e2
; Note other $ex may be used by network engine

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
tmpfield16 = $ff


stack = $0100
oam_mirror = $0200
nametable_buffers = $0300

stage_data = $0400
player_a_objects = $0480 ; Objects independent to character's state like floating hitboxes, temporary platforms, etc
player_b_objects = $04c0 ;

particle_blocks = $0500
particle_block_0 = $0500
particle_block_1 = $0520

previous_global_game_state = $0540
config_requested_stage = $0541
config_requested_player_a_character = $0542
config_requested_player_b_character = $0543
config_requested_player_a_palette = $0544
config_requested_player_b_palette = $0545
;$0580 to $05ff may be used by game states

;$06xx may be used by audio engine, see "Audio engine labels"

virtual_frame_cnt = $0700
skip_frames_to_50hz = $0701
network_last_known_remote_input = $07bf
network_player_local_btns_history = $07c0 ; one byte per frame, circular buffers, 32 entries
network_player_remote_btns_history = $07e0 ;
netplay_launch_received_msg = $0702
