; State of the player's character
;  May take any value from PLAYER_STATE_XXX constants
player_a_state = $0000
player_b_state = $0001

controller_a_btns = $0002
controller_b_btns = $0003

; State of the NMI processing
;  $00 - NMI processed
;  $01 - Waiting for the next NMI to be processed
nmi_processing = $0004

player_a_x = $0005
player_b_x = $0006
player_a_y = $0007
player_b_y = $0008
player_a_direction = $0009 ; 0 - watching left
player_b_direction = $000a ; 1 - watching right
player_a_velocity_v = $000b
player_b_velocity_v = $000c
player_a_velocity_h = $000d
player_b_velocity_h = $000e
player_a_state_field1 = $000f
player_b_state_field1 = $0010
player_a_state_field2 = $0011
player_b_state_field2 = $0012
player_a_animation = $0013
player_b_animation = $0015
player_a_anim_clock = $0017
player_b_anim_clock = $0018
player_a_hurtbox_left = $0019
player_b_hurtbox_left = $001a
player_a_hurtbox_right = $001b
player_b_hurtbox_right = $001c
player_a_hurtbox_top = $001d
player_b_hurtbox_top = $001e
player_a_hurtbox_bottom = $001f
player_b_hurtbox_bottom = $0020
player_a_hitbox_left = $0021
player_b_hitbox_left = $0022
player_a_hitbox_right = $0023
player_b_hitbox_right = $0024
player_a_hitbox_top = $0025
player_b_hitbox_top = $0026
player_a_hitbox_bottom = $0027
player_b_hitbox_bottom = $0028
player_a_hitbox_enabled = $0029 ; 0 - hitbox disabled
player_b_hitbox_enabled = $002a ; 1 - hitbox enabled
player_a_hitbox_force_v = $002b
player_b_hitbox_force_v = $002c
player_a_hitbox_force_h = $002d
player_b_hitbox_force_h = $002e
player_a_hitbox_damages = $002f
player_b_hitbox_damages = $0030
player_a_damages = $0031
player_b_damages = $0032
player_a_x_low = $0033
player_b_x_low = $0034
player_a_y_low = $0035
player_b_y_low = $0036
player_a_velocity_v_low = $0037
player_b_velocity_v_low = $0038
player_a_velocity_h_low = $0039
player_b_velocity_h_low = $003a
player_a_hitbox_force_v_low = $003b
player_b_hitbox_force_v_low = $003c
player_a_hitbox_force_h_low = $003d
player_b_hitbox_force_h_low = $003e
player_a_hitbox_base_knock_up_v_high = $003f
player_b_hitbox_base_knock_up_v_high = $0040
player_a_hitbox_base_knock_up_h_high = $0041
player_b_hitbox_base_knock_up_h_high = $0042
player_a_hitbox_base_knock_up_v_low = $0043
player_b_hitbox_base_knock_up_v_low = $0044
player_a_hitbox_base_knock_up_h_low = $0045
player_b_hitbox_base_knock_up_h_low = $0046
controller_a_last_frame_btns = $0047
controller_b_last_frame_btns = $0048

tmpfield1 = $00f0
tmpfield2 = $00f1
tmpfield3 = $00f2
tmpfield4 = $00f3
tmpfield5 = $00f4
tmpfield6 = $00f5
tmpfield7 = $00f6
tmpfield8 = $00f7
tmpfield9 = $00f8
tmpfield10 = $00f9
tmpfield11 = $00fa
tmpfield12 = $00fb
tmpfield13 = $00fc
tmpfield14 = $00fd
tmpfield15 = $00fe

oam_mirror = $0200
nametable_buffers = $0300
