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
; unused $47
; unused $48
player_a_num_aerial_jumps = $49
player_b_num_aerial_jumps = $4a
player_a_stocks = $4b
player_b_stocks = $4c
player_a_gravity = $4d
player_b_gravity = $4e

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
network_last_received_btns = $bf

network_rollback_mode = $e2 ; 0 - normal, 1 - rolling
server_current_frame_byte0 = $e3
server_current_frame_byte1 = $e4
server_current_frame_byte2 = $e5
server_current_frame_byte3 = $e6

;
; TITLE labels
;

title_cheatstate = $00
title_animation_frame = $01
title_animation_state = $02
title_original_music_state = $03

;
; CONFIG labels
;

config_selected_option = $00
config_music_enabled = $01

;
; CHARACTER_SELECTION labels
;

character_selection_player_a_selected_option = $00
character_selection_player_b_selected_option = $01
character_selection_player_a_async_job_prg_tiles = $02
character_selection_player_b_async_job_prg_tiles = $03
character_selection_player_a_async_job_prg_tiles_msb = $04
character_selection_player_b_async_job_prg_tiles_msb = $05
character_selection_player_a_async_job_ppu_tiles = $06
character_selection_player_b_async_job_ppu_tiles = $07
character_selection_player_a_async_job_ppu_tiles_msb = $08
character_selection_player_b_async_job_ppu_tiles_msb = $09
character_selection_player_a_async_job_ppu_write_count = $0a
character_selection_player_b_async_job_ppu_write_count = $0b
character_selection_player_a_async_job_active = $0c
character_selection_player_b_async_job_active = $0d
character_selection_player_a_animation = $05a0 ; $05a0 to $05ab - player a's animation state
character_selection_player_b_animation = $05ac ; $05ac to $05b7 - player b's animation state

;
; Common menus labels
;  Common to TITLE, CONFIG, CHARACTER_SELECTION, STAGE_SELECTION and CREDITS
;

menu_common_tick_num = $10

menu_common_cloud_1_x = $11
menu_common_cloud_2_x = $12
menu_common_cloud_3_x = $13
menu_common_cloud_1_y = $14
menu_common_cloud_2_y = $15
menu_common_cloud_3_y = $16
menu_common_cloud_1_y_msb = $17
menu_common_cloud_2_y_msb = $18
menu_common_cloud_3_y_msb = $19

screen_sprites_y_lsb = $20 ; $20 to $5f
screen_sprites_y_msb = $60 ; $60 to $a0

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

audio_square1_sample_counter = $c0  ;
audio_square2_sample_counter = $c1  ; Counter in the sample - index of a note
audio_triangle_sample_counter = $c2 ;

audio_square1_note_counter = $c3  ;
audio_square2_note_counter = $c4  ; Counter in the note - time left before next note
audio_triangle_note_counter = $c5 ;

audio_channel_mode = $c6 ; Square or triangle

audio_square1_track = $c7  ;
audio_square2_track = $c9  ; Adress of the current track for each channel
audio_triangle_track = $cb ;

audio_duty = $cd
audio_music_enabled = $ce

audio_square1_track_counter = $0600  ;
audio_square2_track_counter = $0601  ; Counter in the track - index of a sample
audio_triangle_track_counter = $0602 ;

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
previous_global_game_state = $540
players_palettes = $0580 ; $0580 to $059f - 4 nametable buffers (8 bytes each) containing avatars palettes in normal and alternate mode
;$05a0 to $05cf used by in-game state
;$06xx may be used by audio engine, see "Audio engine labels"
virtual_frame_cnt = $0700
skip_frames_to_50hz = $0701
network_btns_history = $07e0 ; one byte per frame, circular buffer, 32 entries
