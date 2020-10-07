#!/usr/bin/env python
import listing

def on_file(line_num, filepath):
	print('{: 7d} +{}'.format(line_num, filepath))

def on_listing(line_num, parsed):
	print('{: 7d} | {: 5d} - {} - {:04x} - {} - {}'.format(line_num, parsed['line'], parsed['segment'], parsed['address'], parsed['data_repr'], parsed['code']))

print('LST_LINE| LINE  - S - ADDR - DATA                     - CODE')
print('=======================================================================================')
listing.parse_file('/tmp/dbg.txt', on_file=on_file, on_listing=on_listing)
