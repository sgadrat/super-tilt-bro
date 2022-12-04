velocity_table({char_name_upper}_AERIAL_SPEED, {char_name}_aerial_speed_msb, {char_name}_aerial_speed_lsb)
velocity_table(-{char_name_upper}_AERIAL_SPEED, {char_name}_aerial_neg_speed_msb, {char_name}_aerial_neg_speed_lsb)
acceleration_table({char_name_upper}_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH, {char_name}_aerial_directional_influence_strength)
acceleration_table({char_name_upper}_AIR_FRICTION_STRENGTH, {char_name}_air_friction_strength)
velocity_table({char_name_upper}_FASTFALL_SPEED, {char_name}_fastfall_speed_msb, {char_name}_fastfall_speed_lsb)
acceleration_table({char_name_upper}_GROUND_FRICTION_STRENGTH, {char_name}_ground_friction_strength)
acceleration_table({char_name_upper}_GROUND_FRICTION_STRENGTH/3, {char_name}_ground_friction_strength_weak)
#if {char_name_upper}_GROUND_FRICTION_STRENGTH*3 <= $ff
acceleration_table({char_name_upper}_GROUND_FRICTION_STRENGTH*3, {char_name}_ground_friction_strength_strong)
#else
acceleration_table($ff, {char_name}_ground_friction_strength_strong)
#endif
velocity_table({char_name_upper}_TECH_SPEED, {char_name}_tech_speed_msb, {char_name}_tech_speed_lsb)
velocity_table(-{char_name_upper}_TECH_SPEED, {char_name}_tech_speed_neg_msb, {char_name}_tech_speed_neg_lsb)
velocity_table(-{char_name_upper}_JUMP_POWER, {char_name}_jump_velocity_msb, {char_name}_jump_velocity_lsb)
velocity_table(-{char_name_upper}_JUMP_SHORT_HOP_POWER, {char_name}_jump_short_hop_velocity_msb, {char_name}_jump_short_hop_velocity_lsb)

{char_name}_jumpsquat_duration:
	.byt {char_name_upper}_JUMP_SQUAT_DURATION_PAL
	.byt {char_name_upper}_JUMP_SQUAT_DURATION_NTSC

{char_name}_short_hop_time:
	.byt {char_name_upper}_JUMP_SQUAT_DURATION_PAL + {char_name_upper}_JUMP_SHORT_HOP_EXTRA_TIME_PAL
	.byt {char_name_upper}_JUMP_SQUAT_DURATION_NTSC + {char_name_upper}_JUMP_SHORT_HOP_EXTRA_TIME_NTSC
