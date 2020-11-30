#include <stdint.h>

//
// INGAME labels
//

// State of the player's character
//  May take any value from selected character's state machine
static uint8_t* const player_a_state = (uint8_t* const)0x00;
static uint8_t* const player_b_state = (uint8_t* const)0x01;

// $02 - used by gameover_winner
static uint8_t* const player_a_hitstun = (uint8_t* const)0x03;
static uint8_t* const player_b_hitstun = (uint8_t* const)0x04;
static uint8_t* const player_a_x = (uint8_t* const)0x05;
static uint8_t* const player_b_x = (uint8_t* const)0x06;
static uint8_t* const player_a_y = (uint8_t* const)0x07;
static uint8_t* const player_b_y = (uint8_t* const)0x08;
static uint8_t* const player_a_direction = (uint8_t* const)0x09; // 0 - watching left
static uint8_t* const player_b_direction = (uint8_t* const)0x0a; // 1 - watching right
static uint8_t* const player_a_velocity_v = (uint8_t* const)0x0b;
static uint8_t* const player_b_velocity_v = (uint8_t* const)0x0c;
static uint8_t* const player_a_velocity_h = (uint8_t* const)0x0d;
static uint8_t* const player_b_velocity_h = (uint8_t* const)0x0e;
static uint8_t* const player_a_state_field1 = (uint8_t* const)0x0f;
static uint8_t* const player_b_state_field1 = (uint8_t* const)0x10;
static uint8_t* const player_a_state_field2 = (uint8_t* const)0x11;
static uint8_t* const player_b_state_field2 = (uint8_t* const)0x12;
static uint8_t* const player_a_x_screen = (uint8_t* const)0x13;
static uint8_t* const player_b_x_screen = (uint8_t* const)0x14;
static uint8_t* const player_a_y_screen = (uint8_t* const)0x15;
static uint8_t* const player_b_y_screen = (uint8_t* const)0x16;
static uint8_t* const player_a_state_clock = (uint8_t* const)0x17;
static uint8_t* const player_b_state_clock = (uint8_t* const)0x18;
static uint8_t* const player_a_hurtbox_left = (uint8_t* const)0x19;
static uint8_t* const player_b_hurtbox_left = (uint8_t* const)0x1a;
static uint8_t* const player_a_hurtbox_right = (uint8_t* const)0x1b;
static uint8_t* const player_b_hurtbox_right = (uint8_t* const)0x1c;
static uint8_t* const player_a_hurtbox_top = (uint8_t* const)0x1d;
static uint8_t* const player_b_hurtbox_top = (uint8_t* const)0x1e;
static uint8_t* const player_a_hurtbox_bottom = (uint8_t* const)0x1f;
static uint8_t* const player_b_hurtbox_bottom = (uint8_t* const)0x20;
static uint8_t* const player_a_hitbox_left = (uint8_t* const)0x21;
static uint8_t* const player_b_hitbox_left = (uint8_t* const)0x22;
static uint8_t* const player_a_hitbox_right = (uint8_t* const)0x23;
static uint8_t* const player_b_hitbox_right = (uint8_t* const)0x24;
static uint8_t* const player_a_hitbox_top = (uint8_t* const)0x25;
static uint8_t* const player_b_hitbox_top = (uint8_t* const)0x26;
static uint8_t* const player_a_hitbox_bottom = (uint8_t* const)0x27;
static uint8_t* const player_b_hitbox_bottom = (uint8_t* const)0x28;
static uint8_t* const player_a_hitbox_enabled = (uint8_t* const)0x0029; // 0 - hitbox disabled
static uint8_t* const player_b_hitbox_enabled = (uint8_t* const)0x002a; // 1 - hitbox enabled
static uint8_t* const player_a_hitbox_force_v = (uint8_t* const)0x2b;
static uint8_t* const player_b_hitbox_force_v = (uint8_t* const)0x2c;
static uint8_t* const player_a_hitbox_force_h = (uint8_t* const)0x2d;
static uint8_t* const player_b_hitbox_force_h = (uint8_t* const)0x2e;
static uint8_t* const player_a_hitbox_damages = (uint8_t* const)0x2f;
static uint8_t* const player_b_hitbox_damages = (uint8_t* const)0x30;
static uint8_t* const player_a_damages = (uint8_t* const)0x31;
static uint8_t* const player_b_damages = (uint8_t* const)0x32;
static uint8_t* const player_a_x_low = (uint8_t* const)0x33;
static uint8_t* const player_b_x_low = (uint8_t* const)0x34;
static uint8_t* const player_a_y_low = (uint8_t* const)0x35;
static uint8_t* const player_b_y_low = (uint8_t* const)0x36;
static uint8_t* const player_a_velocity_v_low = (uint8_t* const)0x37;
static uint8_t* const player_b_velocity_v_low = (uint8_t* const)0x38;
static uint8_t* const player_a_velocity_h_low = (uint8_t* const)0x39;
static uint8_t* const player_b_velocity_h_low = (uint8_t* const)0x3a;
static uint8_t* const player_a_hitbox_force_v_low = (uint8_t* const)0x3b;
static uint8_t* const player_b_hitbox_force_v_low = (uint8_t* const)0x3c;
static uint8_t* const player_a_hitbox_force_h_low = (uint8_t* const)0x3d;
static uint8_t* const player_b_hitbox_force_h_low = (uint8_t* const)0x3e;
static uint8_t* const player_a_hitbox_base_knock_up_v_high = (uint8_t* const)0x3f;
static uint8_t* const player_b_hitbox_base_knock_up_v_high = (uint8_t* const)0x40;
static uint8_t* const player_a_hitbox_base_knock_up_h_high = (uint8_t* const)0x41;
static uint8_t* const player_b_hitbox_base_knock_up_h_high = (uint8_t* const)0x42;
static uint8_t* const player_a_hitbox_base_knock_up_v_low = (uint8_t* const)0x43;
static uint8_t* const player_b_hitbox_base_knock_up_v_low = (uint8_t* const)0x44;
static uint8_t* const player_a_hitbox_base_knock_up_h_low = (uint8_t* const)0x45;
static uint8_t* const player_b_hitbox_base_knock_up_h_low = (uint8_t* const)0x46;
static uint8_t* const player_a_state_field3 = (uint8_t* const)0x47;
static uint8_t* const player_b_state_field3 = (uint8_t* const)0x48;
static uint8_t* const player_a_num_aerial_jumps = (uint8_t* const)0x49;
static uint8_t* const player_b_num_aerial_jumps = (uint8_t* const)0x4a;
static uint8_t* const player_a_stocks = (uint8_t* const)0x4b;
static uint8_t* const player_b_stocks = (uint8_t* const)0x4c;
static uint8_t* const player_a_gravity = (uint8_t* const)0x4d;
static uint8_t* const player_b_gravity = (uint8_t* const)0x4e;

static uint8_t* const player_number = (uint8_t* const)0x4f; // Extra register to hold a player number, used when register X is inconvenient

static uint8_t* const ai_current_action_lsb = (uint8_t* const)0x50;
static uint8_t* const ai_current_action_msb = (uint8_t* const)0x51;
static uint8_t* const ai_current_action_counter = (uint8_t* const)0x52;
static uint8_t* const ai_current_action_step = (uint8_t* const)0x53;
static uint8_t* const ai_current_action_modifier = (uint8_t* const)0x54;
static uint8_t* const ai_delay = (uint8_t* const)0x55;
static uint8_t* const ai_max_delay = (uint8_t* const)0x56;

static uint8_t* const player_a_hurtbox_left_msb = (uint8_t* const)0x57;
static uint8_t* const player_b_hurtbox_left_msb = (uint8_t* const)0x58;
static uint8_t* const player_a_hurtbox_right_msb = (uint8_t* const)0x59;
static uint8_t* const player_b_hurtbox_right_msb = (uint8_t* const)0x5a;
static uint8_t* const player_a_hurtbox_top_msb = (uint8_t* const)0x5b;
static uint8_t* const player_b_hurtbox_top_msb = (uint8_t* const)0x5c;
static uint8_t* const player_a_hurtbox_bottom_msb = (uint8_t* const)0x5d;
static uint8_t* const player_b_hurtbox_bottom_msb = (uint8_t* const)0x5e;
static uint8_t* const player_a_hitbox_left_msb = (uint8_t* const)0x5f;
static uint8_t* const player_b_hitbox_left_msb = (uint8_t* const)0x60;
static uint8_t* const player_a_hitbox_right_msb = (uint8_t* const)0x61;
static uint8_t* const player_b_hitbox_right_msb = (uint8_t* const)0x62;
static uint8_t* const player_a_hitbox_top_msb = (uint8_t* const)0x63;
static uint8_t* const player_b_hitbox_top_msb = (uint8_t* const)0x64;
static uint8_t* const player_a_hitbox_bottom_msb = (uint8_t* const)0x65;
static uint8_t* const player_b_hitbox_bottom_msb = (uint8_t* const)0x66;

static uint8_t* const player_a_grounded = (uint8_t* const)0x67; // $00 if not grounded, else the offset of grounded platform from stage_data
static uint8_t* const player_b_grounded = (uint8_t* const)0x68;
static uint8_t* const player_a_walled = (uint8_t* const)0x69; // $00 if not touching a wall, else the offset of the platform from stage_data
static uint8_t* const player_b_walled = (uint8_t* const)0x6a;
static uint8_t* const player_a_walled_direction = (uint8_t* const)0x6b; // DIRECTION_LEFT - player is on the left of the wall
static uint8_t* const player_b_walled_direction = (uint8_t* const)0x6c; // DIRECTION_RIGHT - player is on the right of the wall

static uint8_t* const screen_shake_counter = (uint8_t* const)0x70;
static uint8_t* const screen_shake_nextval_x = (uint8_t* const)0x71;
static uint8_t* const screen_shake_nextval_y = (uint8_t* const)0x72;

static uint8_t* const directional_indicator_player_a_counter = (uint8_t* const)0x73;
static uint8_t* const directional_indicator_player_b_counter = (uint8_t* const)0x74;
static uint8_t* const directional_indicator_player_a_direction_x_high = (uint8_t* const)0x75;
static uint8_t* const directional_indicator_player_b_direction_x_high = (uint8_t* const)0x76;
static uint8_t* const directional_indicator_player_a_direction_x_low = (uint8_t* const)0x77;
static uint8_t* const directional_indicator_player_b_direction_x_low = (uint8_t* const)0x78;
static uint8_t* const directional_indicator_player_a_direction_y_high = (uint8_t* const)0x79;
static uint8_t* const directional_indicator_player_b_direction_y_high = (uint8_t* const)0x7a;
static uint8_t* const directional_indicator_player_a_direction_y_low = (uint8_t* const)0x7b;
static uint8_t* const directional_indicator_player_b_direction_y_low = (uint8_t* const)0x7c;
// particles lo position tables
//  | byte 0 | bytes 1 to 7       | byte 8 | bytes 9 to 15      |
//  | unused | player A particles | unused | player B particles |
static uint8_t* const directional_indicator_player_a_position_x_low = (uint8_t* const)0x90; // $90 to $9f - unused $90 and $98
static uint8_t* const directional_indicator_player_a_position_y_low = (uint8_t* const)0xa0; // $a0 to $af - unused $a0 and $a8

static uint8_t* const death_particles_player_a_counter = (uint8_t* const)0x7d;
static uint8_t* const death_particles_player_b_counter = (uint8_t* const)0x7e;

static uint8_t* const slow_down_counter = (uint8_t* const)0x7f;

static uint8_t* const player_a_animation = (uint8_t* const)0x05a0; // $05a0 to $05ab - player a's animation state
static uint8_t* const player_b_animation = (uint8_t* const)0x05ac; // $05ac to $05b7 - player b's animation state
static uint8_t* const player_a_out_of_screen_indicator = (uint8_t* const)0x05b8; // $05b8 to $05c3 - player a's out of screen animation state
static uint8_t* const player_b_out_of_screen_indicator = (uint8_t* const)0x05c4; // $05c4 to $05cf - player b's out of screen animation state

//
// Stage specific labels
//

static uint8_t* const stage_state_begin = (uint8_t* const)0x80;

static uint8_t* const stage_pit_platform1_direction_v = (uint8_t* const)0x80;
static uint8_t* const stage_pit_platform2_direction_v = (uint8_t* const)0x81;
static uint8_t* const stage_pit_platform1_direction_h = (uint8_t* const)0x82;
static uint8_t* const stage_pit_platform2_direction_h = (uint8_t* const)0x83;

static uint8_t* const stage_gem_gem_position_x_low = (uint8_t* const)0x80;
static uint8_t* const stage_gem_gem_position_x_high = (uint8_t* const)0x81;
static uint8_t* const stage_gem_gem_position_y_low = (uint8_t* const)0x82;
static uint8_t* const stage_gem_gem_position_y_high = (uint8_t* const)0x83;
static uint8_t* const stage_gem_gem_velocity_h_low = (uint8_t* const)0x84;
static uint8_t* const stage_gem_gem_velocity_h_high = (uint8_t* const)0x85;
static uint8_t* const stage_gem_gem_velocity_v_low = (uint8_t* const)0x86;
static uint8_t* const stage_gem_gem_velocity_v_high = (uint8_t* const)0x87;
static uint8_t* const stage_gem_gem_cooldown_low = (uint8_t* const)0x88;
static uint8_t* const stage_gem_gem_cooldown_high = (uint8_t* const)0x89;
static uint8_t* const stage_gem_gem_state = (uint8_t* const)0x8a; // one of STAGE_GEM_GEM_STATE_*
static uint8_t* const stage_gem_buffed_player = (uint8_t* const)0x8b;
static uint8_t* const stage_gem_last_opponent_state = (uint8_t* const)0x8c;
static uint8_t* const stage_gem_frame_cnt = (uint8_t* const)0x8d;

//Note - $90 to $af are used by DI particles

// Extra zero-page registers
static uint8_t* const extra_tmpfield1 = (uint8_t* const)0xb0;
static uint8_t* const extra_tmpfield2 = (uint8_t* const)0xb1;
static uint8_t* const extra_tmpfield3 = (uint8_t* const)0xb2;
static uint8_t* const extra_tmpfield4 = (uint8_t* const)0xb3;
static uint8_t* const extra_tmpfield5 = (uint8_t* const)0xb4;
static uint8_t* const extra_tmpfield6 = (uint8_t* const)0xb5;

//
// Network engine labels
//

static uint8_t* const network_current_frame_byte0 = (uint8_t* const)0xb6;
static uint8_t* const network_current_frame_byte1 = (uint8_t* const)0xb7;
static uint8_t* const network_current_frame_byte2 = (uint8_t* const)0xb8;
static uint8_t* const network_current_frame_byte3 = (uint8_t* const)0xb9;

static uint8_t* const network_client_id_byte0 = (uint8_t* const)0xba;
static uint8_t* const network_client_id_byte1 = (uint8_t* const)0xbb;
static uint8_t* const network_client_id_byte2 = (uint8_t* const)0xbc;
static uint8_t* const network_client_id_byte3 = (uint8_t* const)0xbd;

static uint8_t* const network_last_sent_btns = (uint8_t* const)0xbe;
static uint8_t* const network_local_player_number = (uint8_t* const)0xbf;

static uint8_t* const server_current_frame_byte0 = (uint8_t* const)0xeb;
static uint8_t* const server_current_frame_byte1 = (uint8_t* const)0xec;
static uint8_t* const server_current_frame_byte2 = (uint8_t* const)0xed;
static uint8_t* const server_current_frame_byte3 = (uint8_t* const)0xee;
static uint8_t* const network_rollback_mode = (uint8_t* const)0xef; // 0 - normal, 1 - rolling ; Note - also used by game tick to know if a frame will be drawn, may be renamed something more generic like "dummy_frame"

//
// TITLE labels
//

static uint8_t* const title_cheatstate = (uint8_t* const)0x00;
static uint8_t* const title_animation_frame = (uint8_t* const)0x01;
static uint8_t* const title_animation_state = (uint8_t* const)0x02;
static uint8_t* const title_original_music_state = (uint8_t* const)0x03;

//
// MODE_SELECTION labels
//

static uint8_t* const mode_selection_current_option = (uint8_t* const)0x00;

//
// CONFIG labels
//

static uint8_t* const config_selected_option = (uint8_t* const)0x39;
static uint8_t* const config_music_enabled = (uint8_t* const)0x3a;

//
// CHARACTER_SELECTION labels
//

static uint8_t* const character_selection_player_a_selected_option = (uint8_t* const)0x00;
static uint8_t* const character_selection_player_b_selected_option = (uint8_t* const)0x01;
static uint8_t* const character_selection_player_a_async_job_prg_tiles = (uint8_t* const)0x02;
static uint8_t* const character_selection_player_b_async_job_prg_tiles = (uint8_t* const)0x03;
static uint8_t* const character_selection_player_a_async_job_prg_tiles_msb = (uint8_t* const)0x04;
static uint8_t* const character_selection_player_b_async_job_prg_tiles_msb = (uint8_t* const)0x05;
static uint8_t* const character_selection_player_a_async_job_ppu_tiles = (uint8_t* const)0x06;
static uint8_t* const character_selection_player_b_async_job_ppu_tiles = (uint8_t* const)0x07;
static uint8_t* const character_selection_player_a_async_job_ppu_tiles_msb = (uint8_t* const)0x08;
static uint8_t* const character_selection_player_b_async_job_ppu_tiles_msb = (uint8_t* const)0x09;
static uint8_t* const character_selection_player_a_async_job_ppu_write_count = (uint8_t* const)0x0a;
static uint8_t* const character_selection_player_b_async_job_ppu_write_count = (uint8_t* const)0x0b;
static uint8_t* const character_selection_player_a_async_job_active = (uint8_t* const)0x0c;
static uint8_t* const character_selection_player_b_async_job_active = (uint8_t* const)0x0d;
static uint8_t* const character_selection_player_a_animation = (uint8_t* const)0x05a0; // $05a0 to $05ab - player a's animation state
static uint8_t* const character_selection_player_b_animation = (uint8_t* const)0x05ac; // $05ac to $05b7 - player b's animation state

//
// NETPLAY_LAUNCH labels
//

static uint8_t* const netplay_launch_state = (uint8_t* const)0x00;
static uint8_t* const netplay_launch_counter = (uint8_t* const)0x01;
static uint8_t* const netplay_launch_ping_min = (uint8_t* const)0x02;
static uint8_t* const netplay_launch_ping_max = (uint8_t* const)0x03;
static uint8_t* const netplay_launch_server = (uint8_t* const)0x04;
static uint8_t* const netplay_launch_nb_servers = (uint8_t* const)0x05;

//
// DONATION labels
//

static uint8_t* const donation_method = (uint8_t* const)0x00;

//
// Common menus labels
//  Common to TITLE, CONFIG, CHARACTER_SELECTION, STAGE_SELECTION and CREDITS
//

static uint8_t* const menu_common_tick_num = (uint8_t* const)0x10;

static uint8_t* const menu_common_cloud_1_x = (uint8_t* const)0x11;
static uint8_t* const menu_common_cloud_2_x = (uint8_t* const)0x12;
static uint8_t* const menu_common_cloud_3_x = (uint8_t* const)0x13;
static uint8_t* const menu_common_cloud_1_y = (uint8_t* const)0x14;
static uint8_t* const menu_common_cloud_2_y = (uint8_t* const)0x15;
static uint8_t* const menu_common_cloud_3_y = (uint8_t* const)0x16;
static uint8_t* const menu_common_cloud_1_y_msb = (uint8_t* const)0x17;
static uint8_t* const menu_common_cloud_2_y_msb = (uint8_t* const)0x18;
static uint8_t* const menu_common_cloud_3_y_msb = (uint8_t* const)0x19;

static uint8_t* const screen_sprites_y_lsb = (uint8_t* const)0x20; // $20 to $5f
static uint8_t* const screen_sprites_y_msb = (uint8_t* const)0x60; // $60 to $a0

//
// GAMEOVER labels
//

static uint8_t* const gameover_winner = (uint8_t* const)0x02;
static uint8_t* const gameover_balloon0_x = (uint8_t* const)0x50;
static uint8_t* const gameover_balloon1_x = (uint8_t* const)0x51;
static uint8_t* const gameover_balloon2_x = (uint8_t* const)0x52;
static uint8_t* const gameover_balloon3_x = (uint8_t* const)0x53;
static uint8_t* const gameover_balloon4_x = (uint8_t* const)0x54;
static uint8_t* const gameover_balloon5_x = (uint8_t* const)0x55;
static uint8_t* const gameover_balloon0_x_low = (uint8_t* const)0x56;
static uint8_t* const gameover_balloon1_x_low = (uint8_t* const)0x57;
static uint8_t* const gameover_balloon2_x_low = (uint8_t* const)0x58;
static uint8_t* const gameover_balloon3_x_low = (uint8_t* const)0x59;
static uint8_t* const gameover_balloon4_x_low = (uint8_t* const)0x5a;
static uint8_t* const gameover_balloon5_x_low = (uint8_t* const)0x5b;
static uint8_t* const gameover_balloon0_y = (uint8_t* const)0x5c;
static uint8_t* const gameover_balloon1_y = (uint8_t* const)0x5d;
static uint8_t* const gameover_balloon2_y = (uint8_t* const)0x5e;
static uint8_t* const gameover_balloon3_y = (uint8_t* const)0x5f;
static uint8_t* const gameover_balloon4_y = (uint8_t* const)0x60;
static uint8_t* const gameover_balloon5_y = (uint8_t* const)0x61;
static uint8_t* const gameover_balloon0_y_low = (uint8_t* const)0x62;
static uint8_t* const gameover_balloon1_y_low = (uint8_t* const)0x63;
static uint8_t* const gameover_balloon2_y_low = (uint8_t* const)0x64;
static uint8_t* const gameover_balloon3_y_low = (uint8_t* const)0x65;
static uint8_t* const gameover_balloon4_y_low = (uint8_t* const)0x66;
static uint8_t* const gameover_balloon5_y_low = (uint8_t* const)0x67;

static uint8_t* const gameover_balloon0_velocity_h = (uint8_t* const)0x68;
static uint8_t* const gameover_balloon1_velocity_h = (uint8_t* const)0x69;
static uint8_t* const gameover_balloon2_velocity_h = (uint8_t* const)0x6a;
static uint8_t* const gameover_balloon3_velocity_h = (uint8_t* const)0x6b;
static uint8_t* const gameover_balloon4_velocity_h = (uint8_t* const)0x6c;
static uint8_t* const gameover_balloon5_velocity_h = (uint8_t* const)0x6d;

static uint8_t* const gameover_random = (uint8_t* const)0x4e;

//
// Audio engine labels
//

static uint8_t* const audio_music_enabled = (uint8_t* const)0xc0;

static uint8_t* const audio_current_track_lsb = (uint8_t* const)0xc1;
static uint8_t* const audio_current_track_msb = (uint8_t* const)0xc2;

static uint8_t* const audio_square1_sample_num = (uint8_t* const)0xc3;
static uint8_t* const audio_square2_sample_num = (uint8_t* const)0xc4;
static uint8_t* const audio_triangle_sample_num = (uint8_t* const)0xc5;
static uint8_t* const audio_noise_sample_num = (uint8_t* const)0xc6;

static uint8_t* const audio_skip_noise = (uint8_t* const)0xc7; //HACK Setting this value makes the audio engine not touch the noise channel, allowing old sfx (based on hacking noise channel) to play

static uint8_t* const audio_square1_current_opcode = (uint8_t* const)0x0604;
static uint8_t* const audio_square2_current_opcode = (uint8_t* const)0x0605;
static uint8_t* const audio_triangle_current_opcode = (uint8_t* const)0x0606;
static uint8_t* const audio_noise_current_opcode = (uint8_t* const)0x0607;
static uint8_t* const audio_square1_current_opcode_msb = (uint8_t* const)0x0608;
static uint8_t* const audio_square2_current_opcode_msb = (uint8_t* const)0x0609;
static uint8_t* const audio_triangle_current_opcode_msb = (uint8_t* const)0x060a;
static uint8_t* const audio_noise_current_opcode_msb = (uint8_t* const)0x060b;
static uint8_t* const audio_square1_wait_cnt = (uint8_t* const)0x060c;
static uint8_t* const audio_square2_wait_cnt = (uint8_t* const)0x060d;
static uint8_t* const audio_triangle_wait_cnt = (uint8_t* const)0x060e;
static uint8_t* const audio_noise_wait_cnt = (uint8_t* const)0x060f;
static uint8_t* const audio_square1_default_note_duration = (uint8_t* const)0x0610;
static uint8_t* const audio_square2_default_note_duration = (uint8_t* const)0x0611;
static uint8_t* const audio_triangle_default_note_duration = (uint8_t* const)0x0612;
static uint8_t* const audio_square1_apu_envelope_byte = (uint8_t* const)0x0613;
static uint8_t* const audio_square2_apu_envelope_byte = (uint8_t* const)0x0614;
static uint8_t* const audio_square1_apu_timer_low_byte = (uint8_t* const)0x0615;
static uint8_t* const audio_square2_apu_timer_low_byte = (uint8_t* const)0x0616;
static uint8_t* const audio_triangle_apu_timer_low_byte = (uint8_t* const)0x0617;
static uint8_t* const audio_square1_apu_timer_high_byte = (uint8_t* const)0x0618;
static uint8_t* const audio_square2_apu_timer_high_byte = (uint8_t* const)0x0619;
static uint8_t* const audio_triangle_apu_timer_high_byte = (uint8_t* const)0x061a;
static uint8_t* const audio_square1_apu_timer_high_byte_old = (uint8_t* const)0x061b;
static uint8_t* const audio_square2_apu_timer_high_byte_old = (uint8_t* const)0x061c;
static uint8_t* const audio_triangle_apu_timer_high_byte_old = (uint8_t* const)0x061d; // Actually useless for triangle, but allows to easily merge code for pulse/triangle (unused now, triangle timer is handled in a "if triangle" branch) ;TODO remove it once code is stable enough to confidently state that we'll never use it
static uint8_t* const audio_square1_pitch_slide_lsb = (uint8_t* const)0x061e;
static uint8_t* const audio_square2_pitch_slide_lsb = (uint8_t* const)0x061f;
static uint8_t* const audio_triangle_pitch_slide_lsb = (uint8_t* const)0x0620;
static uint8_t* const audio_square1_pitch_slide_msb = (uint8_t* const)0x0621;
static uint8_t* const audio_square2_pitch_slide_msb = (uint8_t* const)0x0622;
static uint8_t* const audio_triangle_pitch_slide_msb = (uint8_t* const)0x0623;

static uint8_t* const audio_noise_apu_envelope_byte = (uint8_t* const)0x0624;
static uint8_t* const audio_noise_apu_period_byte = (uint8_t* const)0x0625; // bit 4 used to silence the channel, so it is Ls.. PPPP with s handled by the engine
static uint8_t* const audio_noise_pitch_slide = (uint8_t* const)0x0626;

//
// Global labels
//

static uint8_t* const controller_a_btns = (uint8_t* const)0xd0;
static uint8_t* const controller_b_btns = (uint8_t* const)0xd1;
static uint8_t* const controller_a_last_frame_btns = (uint8_t* const)0xd2;
static uint8_t* const controller_b_last_frame_btns = (uint8_t* const)0xd3;
static uint8_t* const global_game_state = (uint8_t* const)0xd4;

static uint8_t* const nmi_processing = (uint8_t* const)0xd5;

static uint8_t* const scroll_x = (uint8_t* const)0xd6;
static uint8_t* const scroll_y = (uint8_t* const)0xd7;
static uint8_t* const ppuctrl_val = (uint8_t* const)0xd8;

static uint8_t* const config_initial_stocks = (uint8_t* const)0xd9;
static uint8_t* const config_ai_level = (uint8_t* const)0xda;
static uint8_t* const config_selected_stage = (uint8_t* const)0xdb;
static uint8_t* const config_player_a_character_palette = (uint8_t* const)0xdc;
static uint8_t* const config_player_b_character_palette = (uint8_t* const)0xdd;
static uint8_t* const config_player_a_weapon_palette = (uint8_t* const)0xde;
static uint8_t* const config_player_b_weapon_palette = (uint8_t* const)0xdf;
static uint8_t* const config_player_a_character = (uint8_t* const)0xe0;
static uint8_t* const config_player_b_character = (uint8_t* const)0xe1;
static uint8_t* const config_game_mode = (uint8_t* const)0xe2;
// Note other $ex may be used by network engine

static uint8_t* const tmpfield1 = (uint8_t* const)0xf0;
static uint8_t* const tmpfield2 = (uint8_t* const)0xf1;
static uint8_t* const tmpfield3 = (uint8_t* const)0xf2;
static uint8_t* const tmpfield4 = (uint8_t* const)0xf3;
static uint8_t* const tmpfield5 = (uint8_t* const)0xf4;
static uint8_t* const tmpfield6 = (uint8_t* const)0xf5;
static uint8_t* const tmpfield7 = (uint8_t* const)0xf6;
static uint8_t* const tmpfield8 = (uint8_t* const)0xf7;
static uint8_t* const tmpfield9 = (uint8_t* const)0xf8;
static uint8_t* const tmpfield10 = (uint8_t* const)0xf9;
static uint8_t* const tmpfield11 = (uint8_t* const)0xfa;
static uint8_t* const tmpfield12 = (uint8_t* const)0xfb;
static uint8_t* const tmpfield13 = (uint8_t* const)0xfc;
static uint8_t* const tmpfield14 = (uint8_t* const)0xfd;
static uint8_t* const tmpfield15 = (uint8_t* const)0xfe;
static uint8_t* const tmpfield16 = (uint8_t* const)0xff;


static uint8_t* const stack = (uint8_t* const)0x0100;
static uint8_t* const oam_mirror = (uint8_t* const)0x0200;
static uint8_t* const nametable_buffers = (uint8_t* const)0x0300;
static uint8_t* const stage_data = (uint8_t* const)0x0400;
static uint8_t* const player_a_objects = (uint8_t* const)0x0480; // Objects independent to character's state like floating hitboxes, temporary platforms, etc
static uint8_t* const player_b_objects = (uint8_t* const)0x04c0; //
static uint8_t* const particle_blocks = (uint8_t* const)0x0500;
static uint8_t* const particle_block_0 = (uint8_t* const)0x0500;
static uint8_t* const particle_block_1 = (uint8_t* const)0x0520;
static uint8_t* const previous_global_game_state = (uint8_t* const)0x540;
static uint8_t* const players_palettes = (uint8_t* const)0x0580; // $0580 to $059f - 4 nametable buffers (8 bytes each) containing avatars palettes in normal and alternate mode
//$05a0 to $05cf used by in-game state
//$06xx may be used by audio engine, see "Audio engine labels"
static uint8_t* const virtual_frame_cnt = (uint8_t* const)0x0700;
static uint8_t* const skip_frames_to_50hz = (uint8_t* const)0x0701;
static uint8_t* const network_last_known_remote_input = (uint8_t* const)0x07bf;
static uint8_t* const network_player_local_btns_history = (uint8_t* const)0x07c0; // one byte per frame, circular buffers, 32 entries
static uint8_t* const network_player_remote_btns_history = (uint8_t* const)0x07e0; //
static uint8_t* const netplay_launch_received_msg = (uint8_t* const)0x0702;
