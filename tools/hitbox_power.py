#!/usr/bin/env python
import argparse
import copy
import math

implied_deduction_method = 'simulate'

# Parse command line
def origin_to_start_position(origin):
	known_origins = {
		'flatland': {'x': 0x8000, 'y': 0x8000},
		'thehunt': {'x': 0x8000, 'y': 0xa0000},
		'skyride': {'x': 0x8000, 'y': 0xa8000},
		'thepit': {'x': 0x1800, 'y': 0x80000},
	}
	if origin in known_origins:
		return known_origins[origin]
	coords = origin.split('x')
	return {'x': int(coords[0]) << 8, 'y': int(coords[1]) << 8}

parser = argparse.ArgumentParser(description='Compute effect of hitbox knockback properties.')
parser.add_argument('--damage', type=int, default=0, help='damage of the player taking th hit (default: 0)')
parser.add_argument('--origin', default='flatland', help='position of the player when receiving the hit, stage name or "XxY" (default: flatland)')
parser.add_argument('base_h', type=int, help='base horizontal knockback')
parser.add_argument('base_v', type=int, help='base vertical knockback')
parser.add_argument('force_h', type=int, help='scaling horizontal knockback')
parser.add_argument('force_v', type=int, help='scaling vertical knockback')
args = parser.parse_args()

damage = args.damage
base_h = args.base_h
base_v = args.base_v
force_h = args.force_h
force_v = args.force_v
start_pos = origin_to_start_position(args.origin)

# Compute indirect values (as computed by the engine)
SCREEN_SAKE_MAX_DURATION = 0x10
force_multiplier = damage // 4
knockback_h = force_h * force_multiplier + base_h
knockback_v = force_v * force_multiplier + base_v
knockback_total = abs(knockback_v) + abs(knockback_h)
hitstun_duration = ((2 * knockback_total) >> 8) + (knockback_total >> 8)
screen_shake_duration = min(hitstun_duration // 2, SCREEN_SAKE_MAX_DURATION)
screen_shake_noise_h = abs(knockback_h // 0x100) * 4
screen_shake_noise_v = abs(knockback_v // 0x100) * 4
screen_shake_start_pos_x = knockback_h // 0x100 * 4
screen_shake_start_pos_y = knockback_v // 0x100 * 2

# Compute implied values (not explicitely computed, just consequences)
if implied_deduction_method == 'compute':
	# Elegant, but would require to apply basic balistic knowledge to take the effect of gravity and friction in account
	hitstun_distance_h = knockback_h * hitstun_duration
	hitstun_distance_v = knockback_v * hitstun_duration
	hitstun_distance = math.sqrt(hitstun_distance_h ** 2 + hitstun_distance_v ** 2)
	hitstun_end_pos = {'x': start_pos['x'] + hitstun_distance_h, 'y': start_pos['y'] + hitstun_distance_v}
	hitstun_trajectory = [copy.copy(start_pos), copy.copy(hitstun_end_pos)]
else:
	# Dumb, and efficient

	def simulate_throw_trajectory(origin, knockback, gravity, frame_count):
		def merge_velocity(reference, merged, step_size):
			return {
				'x': min(merged['x'], reference['x'] + step_size) if reference['x'] < merged['x'] else max(merged['x'], reference['x'] - step_size),
				'y': min(merged['y'], reference['y'] + step_size) if reference['y'] < merged['y'] else max(merged['y'], reference['y'] - step_size)
			}

		result = [copy.copy(origin)]
		velocity = copy.copy(knockback)
		while frame_count > 0:
			frame_count -= 1

			# Apply gravity (we could also add air friction and directional influence if we wanted to compute without hitstun)
			velocity = merge_velocity(velocity, {'x': velocity['x'], 'y': gravity}, 0x60)

			result.append({
				'x': result[-1]['x'] + velocity['x'],
				'y': result[-1]['y'] + velocity['y']
			})

		return result

	hitstun_trajectory = simulate_throw_trajectory(
		origin = start_pos,
		knockback = {'x': knockback_h, 'y': knockback_v},
		gravity = 0x0200, # DEFAULT_GRAVITY
		frame_count = hitstun_duration
	)
	hitstun_end_pos = hitstun_trajectory[-1]
	hitstun_distance_h = hitstun_end_pos['x'] - start_pos['x']
	hitstun_distance_v = hitstun_end_pos['y'] - start_pos['y']
	hitstun_distance = math.sqrt(hitstun_distance_h ** 2 + hitstun_distance_v ** 2)

# Display raw
def pix(subpixels):
	"Convert a number of subpixels to a number of pixels, ready to be displayed"
	return '{:.2f} pixels'.format(subpixels / 0x100)

print('horizontal knockback ......................... {}/frame'.format(pix(knockback_h)))
print('vertical knockback ........................... {}/frame'.format(pix(knockback_v)))
print('hitstun duration ............................. {} frames'.format(hitstun_duration))
print('screenshake duration ......................... {} frames'.format(screen_shake_duration))
print('screenshake noise ............................ ({}, {}) pixels'.format(screen_shake_noise_h, screen_shake_noise_v))
print('screenshake start position ................... ({}, {}) pixels'.format(screen_shake_start_pos_x, screen_shake_start_pos_y))
print('horizontal distance traveled under hitstun ... {}'.format(pix(hitstun_distance_h)))
print('vertical distance traveled under hitstun ..... {}'.format(pix(hitstun_distance_v)))
print('distance traveled under hitstun .............. {}'.format(pix(hitstun_distance)))

# Display graphical
display_character_ratio = 0.4 # Ratio width/height of characters used for ascii art
screen_width = 256 // 6
screen_height = int((240 * display_character_ratio) // 6)
screen_start_pos = {'x': int(((start_pos['x'] >> 8) * screen_width) / 256), 'y': int(((start_pos['y'] >> 8) * screen_height) / 240)}
screen_hitstun_end_pos = {'x': int(((hitstun_end_pos['x'] >> 8) * screen_width) / 256), 'y': int(((hitstun_end_pos['y'] >> 8) * screen_height) / 240)}
screen_hitstun_trajectory = []
for step in hitstun_trajectory:
	screen_hitstun_trajectory.append({
		'x': int(((step['x'] >> 8) * screen_width) / 256),
		'y': int(((step['y'] >> 8) * screen_height) / 240)
	})

print('.{}.'.format('-' * screen_width))
for y in range(screen_height):
	print('|', end='')
	for x in range(screen_width):
		current_pos = {'x': x, 'y': y}
		if current_pos == screen_hitstun_end_pos:
			print('x', end='')
		elif current_pos == screen_start_pos:
			print('o', end='')
		elif current_pos in screen_hitstun_trajectory:
			print('-', end='')
		else:
			print(' ', end='')
	print('|')
print("'{}'".format('-' * screen_width))
