;
; INGAME labels
;

; State of the player's character
;  May take any value from PLAYER_STATE_XXX constants
player_a_state = $00
player_b_state = $01

; $02 - used by gameover_winner
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
player_a_animation_direction = $47
player_b_animation_direction = $48
player_a_num_aerial_jumps = $49
player_b_num_aerial_jumps = $4a
player_a_stocks = $4b
player_b_stocks = $4c
player_a_gravity = $4d
player_b_gravity = $4e

ai_current_action_lsb = $50
ai_current_action_msb = $51
ai_current_action_counter = $52
ai_current_action_step = $53
ai_current_action_modifier = $54
ai_delay = $55
ai_max_delay = $56

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

death_particles_player_a_counter = $7d
death_particles_player_b_counter = $7e

slow_down_counter = $7f

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

;
; TITLE labels
;

title_cheatstate = $00

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

audio_square1_sample_counter = $d0  ;
audio_square2_sample_counter = $d1  ; Counter in the sample - index of a note
audio_triangle_sample_counter = $d2 ;

audio_square1_note_counter = $d3  ;
audio_square2_note_counter = $d4  ; Counter in the note - time left before next note
audio_triangle_note_counter = $d5 ;

audio_channel_mode = $d6 ; Square or triangle

audio_square1_track = $d7  ;
audio_square2_track = $d9  ; Adress of the current track for each channel
audio_triangle_track = $db ;

audio_duty = $dd
audio_music_enabled = $de

audio_square1_track_counter = $0600  ;
audio_square2_track_counter = $0601  ; Counter in the track - index of a sample
audio_triangle_track_counter = $0602 ;

;
; Global labels
;

controller_a_btns = $e0
controller_b_btns = $e1
controller_a_last_frame_btns = $e2
controller_b_last_frame_btns = $e3
global_game_state = $e4

nmi_processing = $e5

scroll_x = $e6
scroll_y = $e7
ppuctrl_val = $e8

config_initial_stocks = $e9
config_ai_level = $ea
config_selected_stage = $eb
config_player_a_character_palette = $ec
config_player_b_character_palette = $ed
config_player_a_weapon_palette = $ee
config_player_b_weapon_palette = $ef

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


stack = $0100
oam_mirror = $0200
nametable_buffers = $0300
stage_data = $0400
particle_blocks = $0500
particle_block_0 = $0500
particle_block_1 = $0520
previous_global_game_state = $540
players_palettes = $0580
;$06xx may be used by audio engine, see "Audio engine labels"
virtual_frame_cnt = $0700
skip_frames_to_50hz = $0701
