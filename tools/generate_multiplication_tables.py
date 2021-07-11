#!/usr/bin/env python3
import sys
from stblib.utils import intasm32, uintasm8

multiplier = 5 / 6
table_name = 'pal_to_ntsc_velocity'

ofile = sys.stdout

# Small tables, inspired by the top answer here: https://stackoverflow.com/questions/51411251/fast-signed-16-bit-divide-by-7-for-6502
for byte in ['high', 'low']:
	ofile.write('{}_{}_byte:'.format(table_name, byte))
	for table_index in range(256):
		expanded_value = table_index * 256
		computed_value = expanded_value * multiplier
		stored_value = uintasm8(int(computed_value / 256)) if byte == 'high' else uintasm8(int(computed_value) % 0x100)

		if table_index % 16 == 0:
			ofile.write('\n/* {:02x} */ .byt'.format(table_index))
		else:
			ofile.write(',')
		ofile.write(' {}'.format(stored_value))
	ofile.write('\n')

for byte in ['high', 'low']:
	ofile.write('{}_neg_{}_byte:'.format(table_name, byte))
	for table_index in range(256):
		expanded_value = -(0x100 - table_index) * 256
		computed_value = expanded_value * multiplier
		stored_value = intasm32(int(computed_value))[5:7] if byte == 'high' else intasm32(int(computed_value))[7:]
		stored_value = '$'+stored_value

		if table_index % 16 == 0:
			ofile.write('\n/* {:02x} */ .byt'.format(table_index))
		else:
			ofile.write(',')
		ofile.write(' {}'.format(stored_value))
	ofile.write('\n')

# Write routines and macros to do the operation
ofile.write(f'''
#if 0
; Multiply an unsigned 16 bit integer by {multiplier}
{table_name}_positive:
.(
	orig_lsb = tmpfield1
	orig_msb = tmpfield2
	result_lsb = tmpfield3
	result_msb = tmpfield4

	ldy orig_lsb
	lda pal_to_ntsc_velocity_high_byte, y

	ldy orig_msb
	clc
	adc pal_to_ntsc_velocity_low_byte, y
	sta result_lsb
	lda pal_to_ntsc_velocity_high_byte, y
	adc #0
	sta result_msb

	rts
.)

; Multiply a negative 16 bit integer by {multiplier}
{table_name}_negative:
.(
	orig_lsb = tmpfield1
	orig_msb = tmpfield2
	result_lsb = tmpfield3
	result_msb = tmpfield4

	ldy orig_lsb
	lda pal_to_ntsc_velocity_high_byte, y

	ldy orig_msb
	clc
	adc pal_to_ntsc_neg_velocity_low_byte, y
	sta result_lsb
	lda pal_to_ntsc_neg_velocity_high_byte, y
	adc #0
	sta result_msb

	rts
.)
#endif

; Multiply an unsigned 16 bit integer by {multiplier}
;  Overwrites register Y, and register A
#define {table_name.upper()}_POSITIVE(orig_lsb,orig_msb,result_lsb,result_msb) \\
.( :\\
	ldy orig_lsb :\\
	lda {table_name}_high_byte, y :\\
	:\\
	ldy orig_msb :\\
	clc :\\
	adc {table_name}_low_byte, y :\\
	sta result_lsb :\\
	lda {table_name}_high_byte, y :\\
	adc #0 :\\
	sta result_msb :\\
.)

; Multiply a negative 16 bit integer by {multiplier}
;  Overwrites register Y, and register A
#define {table_name.upper()}_NEGATIVE(orig_lsb,orig_msb,result_lsb,result_msb) \\
.( :\\
	ldy orig_lsb :\\
	lda {table_name}_high_byte, y :\\
	:\\
	ldy orig_msb :\\
	clc :\\
	adc {table_name}_neg_low_byte, y :\\
	sta result_lsb :\\
	lda {table_name}_neg_high_byte, y :\\
	adc #0 :\\
	sta result_msb :\\
.)
''')
