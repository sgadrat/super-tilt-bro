#!/usr/bin/env python
import debugtools
import json
import sys

music_path = sys.argv[1]
with open(music_path, 'r') as music_file:
	music = json.load(music_file)

row_count = len(sys.argv) < 3 or sys.argv[2] == 'count'

print(debugtools.human_readable_uctf(music['uctf'], row_count=row_count))
