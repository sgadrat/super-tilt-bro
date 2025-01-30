#!/usr/bin/env python
import math

def speed_table(duration, max_speed):
	result = []
	for tick_num in range(duration + 1):
		# Ignore middle tick
		#  we need both 0% and 100% as they are special values, but that would make one extra tick in the table.
		if tick_num == duration // 2:
			continue

		# Progression in the curve, as a float between 0 and 1
		progression = tick_num / duration

		# Takes the speed on the curve "cos(x) with x in [-pi/2;+pi/2]"
		#  Normalize it for the peak to be at 0
		#  Take sign from curve's slope
		absolute_speed = abs(math.cos((math.pi * progression) - (math.pi / 2)) - 1)
		if progression >= 0.5:
			speed = -absolute_speed
		else:
			speed = absolute_speed

		# Convert speed in target range and store it
		speed_value = round(max_speed * speed)
		result.append(speed_value)
	return result

def put_values(macro, table):
	for (idx, value) in enumerate(table):
		if idx % 5 == 0:
			print('\n\t\t.byt ', end='')
		else:
			print(', ', end='')

		asm_value = f'{"-" if value < 0 else ""}${abs(value):04x}'
		print(f'{macro}({asm_value})', end='')
	print('')

duration = 40
max_speed = 256+128
assert duration * 6 / 5 == int(duration * 6 / 5), "duration is not an exact number of frames in NTSC: {duration} PAL frames == {duration * 6 / 5} NTSC frames"

pal_table = speed_table(duration, max_speed)
ntsc_table = speed_table(int(duration * 6 / 5), max_speed)

print("\tpearl_v_velocity_pal_sign:", end='')
put_values('SUNNY_SIG', pal_table)
print("\tpearl_v_velocity_pal_msb:", end='')
put_values('SUNNY_MSB', pal_table)
print("\tpearl_v_velocity_pal_lsb:", end='')
put_values('SUNNY_LSB', pal_table)
print('\tPEARL_V_VELOCITY_TABLE_LEN_PAL = * - pearl_v_velocity_pal_lsb')
print('')

print("\tpearl_v_velocity_ntsc_sign:", end='')
put_values('SUNNY_NSI', ntsc_table)
print("\tpearl_v_velocity_ntsc_msb:", end='')
put_values('SUNNY_NMS', ntsc_table)
print("\tpearl_v_velocity_ntsc_lsb:", end='')
put_values('SUNNY_NLS', ntsc_table)
print('\tPEARL_V_VELOCITY_TABLE_LEN_NTSC = * - pearl_v_velocity_ntsc_lsb')
