; State of the player's character
;  $00 - Standing on ground
;  $01 - Running
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
player_a_max_velocity = $000f
player_b_max_velocity = $0010

tmpfield1 = $00f0
tmpfield2 = $00f1
tmpfield3 = $00f2
tmpfield4 = $00f3

sprite_0_x = $0203
sprite_0_y = $0200
sprite_1_x = $0207
sprite_1_y = $0204
sprite_2_x = $020b
sprite_2_y = $0208
sprite_3_x = $020f
sprite_3_y = $020c
