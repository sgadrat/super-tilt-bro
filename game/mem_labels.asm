;
; C code labels
;

#include "game/c_labels.asm"

;
; INGAME labels
;

; State of the player's character
;  May take any value from selected character's state machine
player_a_state = $00
player_b_state = $01

player_a_hitstun = $02
player_b_hitstun = $03
player_a_x = $04
player_b_x = $05
player_a_y = $06
player_b_y = $07
player_a_direction = $08 ; 0 - watching left
player_b_direction = $09 ; 1 - watching right
player_a_velocity_v = $0a
player_b_velocity_v = $0b
player_a_velocity_h = $0c
player_b_velocity_h = $0d
player_a_x_screen = $0e
player_b_x_screen = $0f
player_a_y_screen = $10
player_b_y_screen = $11
player_a_state_clock = $12
player_b_state_clock = $13

player_a_hurtbox_left = $14
player_b_hurtbox_left = $15
player_a_hurtbox_right = $16
player_b_hurtbox_right = $17
player_a_hurtbox_top = $18
player_b_hurtbox_top = $19
player_a_hurtbox_bottom = $1a
player_b_hurtbox_bottom = $1b
player_a_hurtbox_left_msb = $1c
player_b_hurtbox_left_msb = $1d
player_a_hurtbox_right_msb = $1e
player_b_hurtbox_right_msb = $1f
player_a_hurtbox_top_msb = $20
player_b_hurtbox_top_msb = $21
player_a_hurtbox_bottom_msb = $22
player_b_hurtbox_bottom_msb = $23

player_a_hitbox_enabled = $24 ; 0 - hitbox disabled, 1 - direct hitbox, 2 - custom hitbox
player_b_hitbox_enabled = $25 ;
player_a_hitbox_left = $26
player_b_hitbox_left = $27
player_a_hitbox_right = $28
player_b_hitbox_right = $29
player_a_hitbox_top = $2a
player_b_hitbox_top = $2b
player_a_hitbox_bottom = $2c
player_b_hitbox_bottom = $2d
player_a_hitbox_left_msb = $2e
player_b_hitbox_left_msb = $2f
player_a_hitbox_right_msb = $30
player_b_hitbox_right_msb = $31
player_a_hitbox_top_msb = $32
player_b_hitbox_top_msb = $33
player_a_hitbox_bottom_msb = $34
player_b_hitbox_bottom_msb = $35
player_a_hitbox_force_v = $36
player_b_hitbox_force_v = $37
player_a_hitbox_force_h = $38
player_b_hitbox_force_h = $39
player_a_hitbox_damages = $3a
player_b_hitbox_damages = $3b
player_a_hitbox_force_v_low = $3c
player_b_hitbox_force_v_low = $3d
player_a_hitbox_force_h_low = $3e
player_b_hitbox_force_h_low = $3f
player_a_hitbox_base_knock_up_v_high = $40
player_b_hitbox_base_knock_up_v_high = $41
player_a_hitbox_base_knock_up_h_high = $42
player_b_hitbox_base_knock_up_h_high = $43
player_a_hitbox_base_knock_up_v_low = $44
player_b_hitbox_base_knock_up_v_low = $45
player_a_hitbox_base_knock_up_h_low = $46
player_b_hitbox_base_knock_up_h_low = $47

player_a_custom_hitbox_routine_lsb = player_a_hitbox_base_knock_up_v_low ; $44
player_b_custom_hitbox_routine_lsb = player_b_hitbox_base_knock_up_v_low ; $45
player_a_custom_hitbox_routine_msb = player_a_hitbox_base_knock_up_v_high ; $40
player_b_custom_hitbox_routine_msb = player_b_hitbox_base_knock_up_v_high ; $41
player_a_custom_hitbox_directional1_lsb = player_a_hitbox_base_knock_up_h_low ; $46
player_b_custom_hitbox_directional1_lsb = player_b_hitbox_base_knock_up_h_low ; $47
player_a_custom_hitbox_directional1_msb = player_a_hitbox_base_knock_up_h_high ; $42
player_b_custom_hitbox_directional1_msb = player_b_hitbox_base_knock_up_h_high ; $43
player_a_custom_hitbox_directional2_lsb = player_a_hitbox_force_h_low ; $3e
player_b_custom_hitbox_directional2_lsb = player_b_hitbox_force_h_low ; $3f
player_a_custom_hitbox_directional2_msb = player_a_hitbox_force_h ; $3e
player_b_custom_hitbox_directional2_msb = player_b_hitbox_force_h ; $3f
player_a_custom_hitbox_value1 = player_a_hitbox_force_v_low ; $3c
player_b_custom_hitbox_value1 = player_b_hitbox_force_v_low ; $3d
player_a_custom_hitbox_value2 = player_a_hitbox_force_v ; $3c
player_b_custom_hitbox_value2 = player_b_hitbox_force_v ; $3d
player_a_custom_hitbox_value3 = player_a_hitbox_damages ; $3a
player_b_custom_hitbox_value3 = player_b_hitbox_damages ; $3b

player_a_damages = $48
player_b_damages = $49
player_a_x_low = $4a
player_b_x_low = $4b
player_a_y_low = $4c
player_b_y_low = $4d
player_a_velocity_v_low = $4e
player_b_velocity_v_low = $4f
player_a_velocity_h_low = $50
player_b_velocity_h_low = $51
player_a_num_aerial_jumps = $52
player_b_num_aerial_jumps = $53
player_a_stocks = $54
player_b_stocks = $55
player_a_special_jumps = $56 ; F... ...W - W = wall jump OK, F = footstool OK
player_b_special_jumps = $57
player_a_state_field1 = $58
player_b_state_field1 = $59
player_a_state_field2 = $5a
player_b_state_field2 = $5b
player_a_state_field3 = $5c
player_b_state_field3 = $5d
player_a_gravity_lsb = $5e
player_b_gravity_lsb = $5f
player_a_gravity_msb = $60
player_b_gravity_msb = $61

player_a_grounded = $62 ; $00 if not grounded, else the offset of grounded platform from stage_data
player_b_grounded = $63
player_a_walled = $64 ; $00 if not touching a wall, else the offset of the platform from stage_data
player_b_walled = $65
player_a_walled_direction = $66 ; DIRECTION_LEFT - player is on the left of the wall
player_b_walled_direction = $67 ; DIRECTION_RIGHT - player is on the right of the wall
player_a_ceiled = $68 ; $00 if not touching a ceiling, else the offset of the platform from stage_data
player_b_ceiled = $69

player_a_last_shown_damage = $6a
player_b_last_shown_damage = $6b
player_a_last_shown_stocks = $6c
player_b_last_shown_stocks = $6d

stage_fade_level = $6e
stage_screen_effect = $6f ; 0 - The screen is clean from effects, any other - There are effects at play (inc when starting an effect, dec on end)

screen_shake_counter = $70
screen_shake_current_x = $71
screen_shake_current_y = $72

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

stage_state_begin = $80 ; $80 to $8f

; particles lo position tables
;  | byte 0 | bytes 1 to 7       | byte 8 | bytes 9 to 15      |
;  | unused | player A particles | unused | player B particles |
directional_indicator_player_a_position_x_low = $90 ; $90 to $9f - unused $90 and $98
directional_indicator_player_a_position_y_low = $a0 ; $a0 to $af - unused $a0 and $a8

;NOTE constant ZERO_PAGE_GLOBAL_FIELDS_BEGIN shall point here ($b0)

;$b0 to $bf used by network engine
;$c0 to $c9 used by audio engine
;$d0 to $ff used by global labels, constants and registers ($e5 and $e6 are still free)

; Stages common variables
stage_restore_screen_step = $0560 ; Set to zero to start asynchrone restoration of the screen by stage's logic
stage_current_fade_level = $0561

; Deathplosion
deathplosion_step = $0562
deathplosion_pos = $0563
deathplosion_origin = $0564

; Temporary velocity
player_a_temporary_velocity_h_low = $0565
player_b_temporary_velocity_h_low = $0566
player_a_temporary_velocity_h = $0567
player_b_temporary_velocity_h = $0568
player_a_temporary_velocity_v_low = $0569
player_b_temporary_velocity_v_low = $056a
player_a_temporary_velocity_v = $056b
player_b_temporary_velocity_v = $056c

; Player extra state
player_a_state_extra1 = $056d
player_b_state_extra1 = $056e
player_a_state_extra2 = $056f
player_b_state_extra2 = $0570
player_a_state_extra3 = $0571
player_b_state_extra3 = $0572
player_a_state_extra4 = $0573
player_b_state_extra4 = $0574
player_a_state_extra5 = $0575
player_b_state_extra5 = $0576
player_a_state_extra6 = $0577
player_b_state_extra6 = $0578
player_a_state_extra7 = $0579
player_b_state_extra7 = $057a
player_a_state_extra8 = $057b
player_b_state_extra8 = $057c
player_a_state_extra9 = $057d
player_b_state_extra9 = $057e
last_player_state_extra = player_b_state_extra9

;$057f unused

players_palettes = $0580 ; $0580 to $059f - 4 nametable buffers (8 bytes each) containing avatars palettes in normal and alternate mode
player_a_animation = $05a0 ; $05a0 to $05ac - player a's animation state
player_b_animation = $05ad ; $05ad to $05b9 - player b's animation state
player_a_out_of_screen_indicator = $05ba ; $05ba to $05c6 - player a's out of screen animation state
player_b_out_of_screen_indicator = $05c7 ; $05c7 to $05d3 - player b's out of screen animation state

ai_current_action_lsb = $05d4
ai_current_action_msb = $05d5
ai_current_action_counter = $05d6
ai_current_action_step = $05d7
ai_current_action_modifier = $05d8
ai_delay = $05d9
ai_max_delay = $05da

game_winner = $05db ; Set to winner's player number after the game is finished

game_mode_state_begin = $05dc

local_mode_paused = game_mode_state_begin ; $05dc
local_mode_state_end = local_mode_paused+1

; Arcade mode stuff not expected to be preseved by the encounter
arcade_mode_stage_type = $05dd

arcade_mode_targets_x = $05de ; $05de to $05e7
arcade_mode_targets_y = $05e8 ; $05e8 to $05f1
arcade_mode_target_break_animation = $05f2 ; $05f2 to $05fe
arcade_mode_target_break_animation_timer = $05ff

arcade_mode_run_teleport_animation = $05f2 ; $05f2 to $05fe
arcade_mode_run_teleport_timer = $05ff

player_a_projectile_1_flags = $0600
player_b_projectile_1_flags = $0601
player_a_projectile_1_hitbox_left = $602
player_b_projectile_1_hitbox_left = $603
player_a_projectile_1_hitbox_right = $604
player_b_projectile_1_hitbox_right = $605
player_a_projectile_1_hitbox_top = $606
player_b_projectile_1_hitbox_top = $607
player_a_projectile_1_hitbox_bottom = $608
player_b_projectile_1_hitbox_bottom = $609
player_a_projectile_1_hitbox_left_msb = $60a
player_b_projectile_1_hitbox_left_msb = $60b
player_a_projectile_1_hitbox_right_msb = $60c
player_b_projectile_1_hitbox_right_msb = $60d
player_a_projectile_1_hitbox_top_msb = $60e
player_b_projectile_1_hitbox_top_msb = $60f
player_a_projectile_1_hitbox_bottom_msb = $610
player_b_projectile_1_hitbox_bottom_msb = $611

;$0612-$0623 unused (reserved for projectile 2)
;$0614-$0635 unused (reserved for projectile 3)

;$0636-$067f unused

game_mode_state_end = $067f ; Inclusive (game mode can safely write here)

;
; Stage specific labels
;

stages_magma_frame_cnt = $8f

stage_pit_platform1_direction_v = $80
stage_pit_platform2_direction_v = $81
stage_pit_platform1_direction_h = $82
stage_pit_platform2_direction_h = $83

stage_thehunt_gem_position_x_low = $80
stage_thehunt_gem_position_x_high = $81
stage_thehunt_gem_position_y_low = $82
stage_thehunt_gem_position_y_high = $83
stage_thehunt_gem_velocity_h_low = $84
stage_thehunt_gem_velocity_h_high = $85
stage_thehunt_gem_velocity_v_low = $86
stage_thehunt_gem_velocity_v_high = $87
stage_thehunt_gem_cooldown_low = $88
stage_thehunt_gem_cooldown_high = $89
stage_thehunt_gem_state = $8a ; one of STAGE_GEM_GEM_STATE_*
stage_thehunt_buffed_player = $8b
stage_thehunt_last_opponent_state = $8c
stage_thehunt_frame_cnt = stages_magma_frame_cnt

;Note - $90 to $af are used by DI particles

;
; Network engine labels
;

server_current_frame_byte0 = $b0
server_current_frame_byte1 = $b1
server_current_frame_byte2 = $b2
server_current_frame_byte3 = $b3
network_rollback_mode = $b4 ; 0 - normal, 1 - rolling ; Note - also used by game tick to know if a frame will be drawn, may be renamed something more generic like "dummy_frame"

network_current_frame_byte0 = $b5
network_current_frame_byte1 = $b6
network_current_frame_byte2 = $b7
network_current_frame_byte3 = $b8

network_client_id_byte0 = $b9
network_client_id_byte1 = $ba
network_client_id_byte2 = $bb
network_client_id_byte3 = $bc

network_last_sent_btns = $bd
network_local_player_number = $be
network_frame_diff = $bf

;
; Network login labels
;

; Note - It uses FPGA RAM to avoid being overiten by other game states
;        2KB of FPGA RAM are permanently mapped to $4800-$4fff,
;        $4800-$49ff are used for tx/rx buffers.
;        After that this is unused stuff (except by this little chunk of memory.)

network_login = $4c00 ; $4c00-$4c0f
network_password = $4c10 ; $4c10-$4c1f
network_logged = $4c20
network_ranked = $4c21
;$4c22-$4c2f unused
network_game_password = $4c30 ; $4c30-$4c3f

;
; TITLE labels
;

title_cheatstate = $00
title_animation_frame = $01
title_animation_state = $02
title_original_music_state = $03
title_wait_time = $04

title_buffer = $0580

;
; MODE_SELECTION labels
;

mode_selection_mem_buffer = $0580

;
; CREDITS labels
;

credits_current_page = last_c_label+1 ; $39
credits_page_dirty = credits_current_page+1 ; $3a
credits_last_illustration_lsb = credits_page_dirty+1 ; $3b
credits_last_illustration_msb = credits_last_illustration_lsb+1 ; $3c
credits_last_illustration_bank = credits_last_illustration_msb+1 ; $3d

credits_mem_buffer = $0580 ; $0580 to $05bf (64 bytes)
credits_cursor_anim = $05c0 ; $05c0 to $05cc
;$05cd to $05ff - unused
credits_bubble_anim_1 = $060d ; to $0619
credits_bubble_anim_2 = $061a ; to $0626
credits_bubble_anim_3 = $0627 ; to $0633
credits_bubble_anim_4 = $0634 ; to $0640
credits_bubble_anims = credits_bubble_anim_1

;
; ONLINE_MODE_SELECTION labels
;

online_mode_selection_current_option = last_c_label+1 ; $39
online_mode_ship_dest_x = online_mode_selection_current_option+1 ; $3a
online_mode_ship_dest_y = online_mode_ship_dest_x+1 ; $3b
online_mode_frame_count = online_mode_ship_dest_y+1 ; $3c
online_mode_rnd = online_mode_frame_count+1 ; $3d-$40
online_mode_satellite_state = online_mode_rnd+4 ; $41-$49

online_mode_selection_mem_buffer = $0580 ; $0580 to $05bf (64 bytes)
online_mode_selection_cursor_anim = $05c0 ; $05c0 to $05cc
online_mode_selection_ship_anim = $05cd ; $05cd to $05d9
online_mode_selection_monster_anim = $05da ; $05da to $05e6
online_mode_selection_satellite_anim = $05e7 ; $05e7 to $05e3

; Update screen
;  Technically ONLINE_MODE_SELECTION state, but can overide any online screen's field

update_screen_txtx = last_c_label+1 ; $39
update_screen_txty = update_screen_txtx+1 ; $3a
update_screen_scroll_state = update_screen_txty+1 ; $3b
update_screen_log_position = update_screen_scroll_state+1 ; 3d
update_screen_erase_sector_result = update_screen_log_position+1 ; $3e
update_screen_program_page_result_flags = update_screen_erase_sector_result+1 ; $3f
update_screen_program_page_result_count = update_screen_program_page_result_flags+1 ; $40

;
; WIFI_SETTINGS labels
;

wifi_settings_zp_mem = last_c_label+1
wifi_settings_mem = $0580

;
; CONFIG labels
;

config_selected_option = last_c_label+1 ; $39
config_music_enabled = config_selected_option+1 ; $3a
config_screen_cursor_state = config_music_enabled+1 ; $3b-$3c

config_screen_cursor_anim = $0580

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
character_selection_player_a_cursor_anim = $05c0 ; $05c0 to $05cc
character_selection_player_b_cursor_anim = $05cd ; $05cd to $05d9
character_selection_player_a_char_anim = $05da ; $05da to $05e6
character_selection_player_b_char_anim = $05e7 ; $05e7 to $05f3
;$05f4-$05ff unused
character_selection_player_a_builder_anim = $0600 ; $0600 to $060c
character_selection_player_b_builder_anim = $060d ; $060d to $0619

;
; STAGE_SELECTION labels
;

stage_selection_cursor_anim = last_c_label+1
stage_selection_bg_task = stage_selection_cursor_anim+13

stage_selection_mem_buffer = $0580 ; $0580 to $05bf (4*16 bytes)

;
; NETPLAY_LAUNCH labels
;

netplay_launch_cursor_anim = last_c_label+1 ; $39-$45
netplay_launch_bg_task = netplay_launch_cursor_anim+13 ; $46-$47
netplay_launch_fg_task = netplay_launch_bg_task+2 ; $48-$49
netplay_launch_server = netplay_launch_fg_task+2 ; $4a
netplay_launch_nb_servers = netplay_launch_server+1 ; $4b
netplay_launch_local_ping_count = netplay_launch_nb_servers+1 ; $4c
netplay_launch_local_ping_values = netplay_launch_local_ping_count+1 ; $4d-$4f
netplay_launch_local_ping_quality = netplay_launch_local_ping_values+3 ; $50
netplay_launch_rival_ping_count = netplay_launch_local_ping_quality+1 ; $51
netplay_launch_rival_ping_values = netplay_launch_rival_ping_count+1 ; $52-$54
netplay_launch_rival_ping_quality = netplay_launch_rival_ping_values+3 ; $55
netplay_launch_countdown = netplay_launch_rival_ping_quality+1 ; $56
netplay_launch_original_music_state = netplay_launch_countdown+1 ; $57
netplay_launch_rival_system = netplay_launch_original_music_state+1 ; $58

netplay_launch_bg_mem_buffer = $0580 ; $0580 to $???? (current biggest usage, 3+16 bytes, map illustration draw)

;
; ARCADE_MODE labels
;

arcade_mode_last_game_winner = last_c_label+1 ; $39

arcade_mode_bg_mem_buffer = $0580 ; $0580 to $05a3 (max text size 32 + nt buffer header) ;TODO rename to "arcade_mode_mem_buffer", it got more uses than just nt buffers
arcade_mode_encounter = $05a4 ; $05a4 to $05ac (ENCOUNTER_ENTRY_SIZE)

arcade_mode_congratz_medals_x_subpixel = $05a4 ; $05a4 to $05b3 (room for 16 medals)
arcade_mode_congratz_medals_y_subpixel = $05b4 ; $05b4 to $05c3 (room for 16 medals)
arcade_mode_congratz_medals_h_velocity = $05c4 ; $05c4 to $05d3
arcade_mode_congratz_medals_v_velocity = $05d4 ; $05d4 to $05e3

cutscene_anims = $0580 ; $0580 to $05b3 - 4 animation states
cutscene_anims_enabled = $05b4 ; $05b4 to $05b7 - 4 bytes
cutscene_anims_velocity_h_pixel = $05b8 ; to $05bb
cutscene_anims_velocity_h_subpixel = $05bc ; to $05bf
cutscene_anims_velocity_v_pixel = $05c0 ; to $05c3
cutscene_anims_velocity_v_subpixel = $05c4 ; to $05c7
cutscene_anims_pos_x_subpixel = $05c8 ; to $05cb
cutscene_anims_pos_y_subpixel = $05cc ; to $05cf
cutscene_anims_bank = $05d0 ; to $05d3
cutscene_anims_player = $05d4 ; to $05d7
cutscene_autoscroll_h = $05d8
cutscene_autoscroll_v = $05d9
cutscene_frame_count = $05da
cutscene_frames_skippable = $05db
cutscene_sprite0_hit = $05dc
cutscene_sprite0_scroll = $05dd
cutscene_flags = $05de ; Freely usable by cutscene script, opcodes won't overwrite it

;
; JUKEBOX labels
;

jukebox_zp_mem = last_c_label+1 ; $39
jukebox_mem = $0580

;
; SOCIAL labels
;

social_link = $00
social_draw_step = $01
social_draw_line_addr_lsb = $02
social_draw_line_addr_msb = $03
social_link_state = $04 ; 0 - showing links page, 1 showing a link

social_mem_buffer = $0560 ; max usage - 4 bytes
social_cursor_anim = $580

;
; Common menus labels
;  Common to TITLE, CONFIG, MODE_SELECTION and CREDITS
;  Note that if other screens use this range, it must be repaired when comming back
;

menu_common_cloud_1_x = $50
menu_common_cloud_2_x = $51
menu_common_cloud_3_x = $52
menu_common_cloud_4_x = $53
menu_common_cloud_5_x = $54

menu_common_cloud_1_y = $55
menu_common_cloud_2_y = $56
menu_common_cloud_3_y = $57
menu_common_cloud_4_y = $58
menu_common_cloud_5_y = $59

menu_common_cloud_1_y_msb = $5a
menu_common_cloud_2_y_msb = $5b
menu_common_cloud_3_y_msb = $5c
menu_common_cloud_4_y_msb = $5d
menu_common_cloud_5_y_msb = $5e

menu_common_cloud_1_x_subpixel = $5f
menu_common_cloud_2_x_subpixel = $60
menu_common_cloud_3_x_subpixel = $61
menu_common_cloud_4_x_subpixel = $62
menu_common_cloud_5_x_subpixel = $63

screen_sprites_y_lsb = $0400 ; $0400 to $043f
screen_sprites_y_msb = $0440 ; $0440 to $047f

;
; GAMEOVER labels
;

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

gameover_random = $4d
gameover_gamepads_ready_a = $4e
gameover_gamepads_ready_b = $4f

gameover_winner = game_winner

;
; Audio engine labels
;

audio_music_enabled = $c0

audio_current_track_lsb = $c1
audio_current_track_msb = $c2
audio_current_track_bank = $c3

audio_square1_sample_num = $c4
audio_square2_sample_num = $c5
audio_triangle_sample_num = $c6
audio_noise_sample_num = $c7

audio_vframe_cnt = $c8 ;TODO merge it with the vframe counter for wait_next_frame
audio_50hz = $c9 ; 0 - 60 Hz, 1 - 50 Hz

audio_square1_current_opcode = $0684
audio_square2_current_opcode = $0685
audio_triangle_current_opcode = $0686
audio_noise_current_opcode = $0687
audio_square1_current_opcode_msb = $0688
audio_square2_current_opcode_msb = $0689
audio_triangle_current_opcode_msb = $068a
audio_noise_current_opcode_msb = $068b
audio_square1_wait_cnt = $068c
audio_square2_wait_cnt = $068d
audio_triangle_wait_cnt = $068e
audio_noise_wait_cnt = $068f
audio_square1_default_note_duration = $0690
audio_square2_default_note_duration = $0691
audio_triangle_default_note_duration = $0692
audio_square1_apu_envelope_byte = $0693
audio_square2_apu_envelope_byte = $0694
audio_square1_apu_timer_low_byte = $0695
audio_square2_apu_timer_low_byte = $0696
audio_triangle_apu_timer_low_byte = $0697
audio_square1_apu_timer_high_byte = $0698
audio_square2_apu_timer_high_byte = $0699
audio_triangle_apu_timer_high_byte = $069a
audio_square1_apu_timer_high_byte_old = $069b
audio_square2_apu_timer_high_byte_old = $069c
audio_triangle_apu_timer_high_byte_old = $069d ; Actually useless for triangle, but allows to easily merge code for pulse/triangle (unused now, triangle timer is handled in a "if triangle" branch) ;TODO remove it once code is stable enough to confidently state that we'll never use it
audio_square1_pitch_slide_lsb = $069e
audio_square2_pitch_slide_lsb = $069f
audio_triangle_pitch_slide_lsb = $06a0
audio_square1_pitch_slide_msb = $06a1
audio_square2_pitch_slide_msb = $06a2
audio_triangle_pitch_slide_msb = $06a3

audio_noise_apu_envelope_byte = $06a4
audio_noise_apu_period_byte = $06a5 ; bit 4 used to silence the channel, so it is Ls.. PPPP with s handled by the engine
audio_noise_pitch_slide = $06a6

audio_fx_noise_pitch_slide = $06a7
audio_fx_noise_wait_cnt = $06a8
audio_fx_noise_current_opcode = $06a9
audio_fx_noise_current_opcode_msb = $06aa
audio_fx_noise_current_opcode_bank = $06ab
audio_fx_noise_apu_envelope_byte = $06ac
audio_fx_noise_apu_period_byte = $06ad

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

current_bank = $e3
nt_buffer_timer = $e4

;
; Zero-page constants
;

pal_emulation_counter = $e7 ; $ff - disabled, set to 5 to enable
system_index = $e8 ; 0 - PAL, 1 - NTSC

;
; Zero-page registers
;

; Extra register to hold a player number, used when register X is inconvenient
player_number = $e9

; Uncomonly used register, for when we really want to avoid possible conflicts with tmpfields
extra_tmpfield1 = $ea
extra_tmpfield2 = $eb
extra_tmpfield3 = $ec
extra_tmpfield4 = $ed
extra_tmpfield5 = $ee
extra_tmpfield6 = $ef

; Standard zeropage registers
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

;
; Non-zeropage memory
;

stack = $0100
oam_mirror = $0200
nametable_buffers = $0300

stage_data = $0400
player_a_objects = $0480 ; Objects independent to character's state like floating hitboxes, temporary platforms, etc
player_b_objects = $04c0 ;

sha_w = $0400 ; $0400 to $04ff - One page, completely garbaged by sha256_sum routine
sha_msg = $0440 ; $0440 to $047f - Overlaps sha_w, will be overwriten by computations
sha_h = $0700 ; $0700 to $071f - 32 bytes hash result
sha_working_variables = $0720 ; $0720 to $073f
sha_length_lsb = $0740
sha_length_msb = $0741

particle_blocks = $0500
particle_block_0 = $0500
particle_block_1 = $0520

previous_global_game_state = $0540

config_requested_stage = $0541
config_requested_player_a_character = $0542
config_requested_player_b_character = $0543
config_requested_player_a_palette = $0544
config_requested_player_b_palette = $0545
config_ingame_track = $0546
config_player_a_present = $0547 ; 0 - player is absent, and should not impact the screen, 1 - player is there as usual
config_player_b_present = $0548 ; 0 - player is absent, and should not impact the screen, 1 - player is there as usual

;unused $0549-$054c

; Arcade mode stuff expected to be preseved by the encounter
arcade_mode_medals = $054d ; $054d to $054f
arcade_mode_saved_counter_frames = $0550
arcade_mode_saved_counter_seconds = $0551
arcade_mode_saved_counter_minutes = $0552
arcade_mode_current_encounter = $0553
arcade_mode_player_damages = $0554
arcade_mode_counter_frames = $0555
arcade_mode_counter_seconds = $0556
arcade_mode_counter_minutes = $0557
arcade_mode_nb_credits_used = $0558

; Menu state variable that must persist between screens
menu_state_mode_selection_current_option = $0559

; Nine-gine variables
nt_buffers_begin = $055a
nt_buffers_end = $055b

screen_shake_noise_h = $055c
screen_shake_noise_v = $055d
screen_shake_speed_h = $055e
screen_shake_speed_v = $055f

;$0560 to $05ff may be used by game states
;$0600 to $067f may be used by game states

;$0680 to $06ff may be used by audio engine, see "Audio engine labels"

network_last_known_remote_input = $07bf
network_player_local_btns_history = $07c0 ; one byte per frame, circular buffers, 32 entries
network_player_remote_btns_history = $07e0 ;
