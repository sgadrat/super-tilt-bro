def tokenize(line):
	res = []
	whitespaces = [' ', '\t']

	current_token = ''
	string_state = 'out'
	for c in line:
		if c in whitespaces:
			if string_state == 'in':
				current_token += c
			elif current_token != '':
				res.append(current_token)
				current_token = ''
				string_state = 'out'
		elif c == '"':
			if string_state == 'out':
				string_state = 'in'
			elif string_state == 'in':
				string_state = 'one_quote'
			elif string_state == 'one_quote':
				current_token += '"'
				string_state = 'in'
		else:
			current_token += c

	if current_token != '' or string_state == 'one_quote':
		res.append(current_token)

	return res

def to_dict(ftmtxt_file):
	"""
	Usage example:

	with open('/path/to/ftm.txt', 'r') as f:
		json.dump(ftmtxt.to_dict(f))
	"""

	# Default (empty) structure fields
	#   General info is split between "info", "params" and "comments" sections. It matches binary ftm format.
	ftm = {
		'info': {
			'title': '',
			'author': '',
			'copyright': '',
		},
		'comments': '',
		'params': {
			'machine': 0,
			'framerate': 0,
			'expansion': 0,
			'vibrato': 0,
			'split': 0,
		},
		'macros': {
			'2a03': {
				'volume': {},
				'arpeggio': {},
				'pitch': {},
				'hi-pitch': {},
				'duty': {},
			},
			'vrc6': {
				'volume': {},
				'arpeggio': {},
				'pitch': {},
				'hi-pitch': {},
				'pulse-width': {},
			},
		},
		'instruments': {
		},
		'tracks': [
		]
	}

	for line in ftmtxt_file:
		line = line.rstrip('\r\n')
		if line == '' or line[0] == '#':
			continue

		line = tokenize(line)
		command = line[0]
		params = line[1:]

		#print('tokens:{} command:{} params:{}'.format(line, command, params))

		if command == 'TITLE':
			assert len(params) == 1
			ftm['info']['title'] = params[0]
		elif command == 'AUTHOR':
			assert len(params) == 1
			ftm['info']['author'] = params[0]
		elif command == 'COPYRIGHT':
			assert len(params) == 1
			ftm['info']['copyright'] = params[0]
		elif command == 'COMMENT':
			assert len(params) == 1
			ftm['comments'] += '{}\n'.format(params[0])
		elif command == 'MACHINE':
			assert len(params) == 1
			ftm['params']['machine'] = int(params[0])
		elif command == 'FRAMERATE':
			assert len(params) == 1
			ftm['params']['framerate'] = int(params[0])
		elif command == 'EXPANSION':
			assert len(params) == 1
			ftm['params']['expansion'] = int(params[0])
		elif command == 'VIBRATO':
			assert len(params) == 1
			ftm['params']['vibrato'] = int(params[0])
		elif command == 'SPLIT':
			assert len(params) == 1
			ftm['params']['split'] = int(params[0])
		elif command == 'MACRO':
			assert len(params) >= 7, "macro format 'MACRO type index loop release setting : sequence'"
			macro_types = ['volume', 'arpeggio', 'pitch', 'hi-pitch', 'duty']
			macro_type = macro_types[int(params[0])]
			macro_collection = ftm['macros']['2a03'][macro_type]
			macro_collection[int(params[1])] = {
				'loop': int(params[2]),
				'release': int(params[3]),
				'setting': int(params[4]),
				'sequence': [int(x) for x in params[6:]]
			}
		elif command == 'MACROVRC6':
			assert len(params) >= 7, "macro format 'MACROVRC6 type index loop release setting : sequence'"
			macro_types = ['volume', 'arpeggio', 'pitch', 'hi-pitch', 'pulse-width']
			macro_type = macro_types[int(params[0])]
			macro_collection = ftm['macros']['vrc6'][macro_type]
			macro_collection[int(params[1])] = {
				'loop': int(params[2]),
				'release': int(params[3]),
				'setting': int(params[4]),
				'sequence': [int(x) for x in params[6:]]
			}
		elif command == 'INST2A03':
			assert len(params) == 7, "format '{} index seq_vol seq_arp seq_pit seq_hpi seq_dut name'".format(command)
			ftm['instruments'][int(params[0])] = {
				'type': '2a03',
				'seq_vol': int(params[1]),
				'seq_arp': int(params[2]),
				'seq_pit': int(params[3]),
				'seq_hpi': int(params[4]),
				'seq_dut': int(params[5]),
				'name': params[6]
			}
		elif command == 'INSTVRC6':
			assert len(params) == 7, "format '{} index seq_vol seq_arp seq_pit seq_hpi seq_wid name'".format(command)
			ftm['instruments'][int(params[0])] = {
				'type': 'vrc6',
				'seq_vol': int(params[1]),
				'seq_arp': int(params[2]),
				'seq_pit': int(params[3]),
				'seq_hpi': int(params[4]),
				'seq_wid': int(params[5]),
				'name': params[6]
			}
		elif command == 'TRACK':
			assert len(params) == 4, "format 'TRACK pattern speed tempo name'"
			ftm['tracks'].append({
				'pattern': int(params[0]),
				'speed': int(params[1]),
				'tempo': int(params[2]),
				'name': params[3],
				'channels_effects': [], # TODO fill with "1" for each channels (according to expansion chip present) as this is the documented default
				'orders': [],
				'patterns': []
			})
		elif command == 'COLUMNS':
			assert len(params) > 1 and params[0] == ':', "format 'COLUMNS : columns'"
			ftm['tracks'][-1]['channels_effects'] = [int(x) for x in params[1:]]
		elif command == 'ORDER':
			assert len(params) > 2 and params[1] == ':', "format 'ORDER frame : list'"
			assert int(params[0], 16) == len(ftm['tracks'][-1]['orders']), "unsuported out of order ORDERs"
			ftm['tracks'][-1]['orders'].append([int(x, 16) for x in params[2:]])
		elif command == 'PATTERN':
			assert len(params) == 1, "format 'PATTERN pattern'"
			assert int(params[0], 16) == len(ftm['tracks'][-1]['patterns']), "unsuported out of order PATTERNs"
			ftm['tracks'][-1]['patterns'].append({
				'rows': []
			})
		elif command == 'ROW':
			assert len(params) > 2, "format 'ROW row : c0 : c1 : c2 ...'"
			assert int(params[0], 16) == len(ftm['tracks'][-1]['patterns'][-1]['rows'])

			# Split params per channel
			chans = []
			current_chan = []
			for param in params[2:]:
				if param == ':':
					chans.append(current_chan)
					current_chan = []
				else:
					current_chan.append(param)
			chans.append(current_chan)

			# Fill row with channels info
			row = {'channels': []}
			for chan in chans:
				assert len(chan) >= 3, "row channel format: 'note instrument volume [effects}'"
				row['channels'].append({
					'note': chan[0],
					'instrument': chan[1],
					'volume': chan[2],
					'effects': [x for x in chan[3:]]
				})

			# Store row
			ftm['tracks'][-1]['patterns'][-1]['rows'].append(row)
		else:
			print('warning: unknown ftm command {}'.format(command))

	return ftm
