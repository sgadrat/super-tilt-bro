import ftmmanip

def human_readable_track(track):
	serialized = ''
	for pattern_idx in range(len(track['patterns'])):
		pattern = track['patterns'][pattern_idx]
		serialized += 'PATTERN {:02X}\n\n'.format(pattern_idx)
		for row_idx in range(len(pattern['rows'])):
			row = pattern['rows'][row_idx]
			serialized += 'ROW {:02X}'.format(row_idx)
			for channel in row['channels']:
				serialized += ' : '
				if isinstance(channel, str):
					serialized += channel
				else:
					serialized += '{} {} {}'.format(
						channel['note'], channel['instrument'], channel['volume']
					)
					for effect in channel['effects']:
						serialized += ' {}'.format(effect)
					for extra_effect in channel.get('extra_effects', []):
						serialized += ' {}={}'.format(extra_effect['effect'], extra_effect['value'])
			serialized += '\n'
		serialized += '\n'

	return serialized

def human_readable_uctf(uctf, row_count=True, unroll_durations=True):
	def serialize_uctf_line(values, row_idx):
		nonlocal row_count
		if row_count:
			return '{:02X} : {}\n'.format(row_idx, '\t'.join(values))
		else:
			return '{}\n'.format('\t'.join(values))

	serialized = ''

	for channel_idx in range(len(uctf['channels'])):
		serialized += 'CHANNEL {:02X}\n'.format(channel_idx)
		serialized += ', '.join(['{:02X}'.format(x) for x in uctf['channels'][channel_idx]])
		serialized += '\n\n'

	for sample_idx in range(len(uctf['samples'])):
		sample = uctf['samples'][sample_idx]
		serialized += 'SAMPLE {:02X} ({})\n'.format(sample_idx, sample['type'])
		serialized += '# {}\n'.format('\t'.join(ftmmanip.uctf_fields_by_type[sample['type']]))

		original_line_idx = 0
		for line_idx in range(len(sample['lines'])):
			line = sample['lines'][line_idx]
			line_extra_duration = None
			values = []
			for field in ftmmanip.uctf_fields_by_type[sample['type']]:
				values.append(str(line[field]) if line != 'empty_row' and line[field] is not None else '...')
			if line != 'empty_row':
				for field in line:
					if field == 'duration' and unroll_durations:
						assert line[field] >= 1, 'invalid uctf line duration "{}"'.format(line[field])
						line_extra_duration = line[field] - 1
					if field not in ftmmanip.uctf_fields_by_type[sample['type']]:
						values.append('{}={}'.format(field, line[field]))

			serialized += serialize_uctf_line(values, original_line_idx)
			original_line_idx += 1

			if line_extra_duration is not None:
				while line_extra_duration > 0:
					serialized += serialize_uctf_line(['...'] * len(ftmmanip.uctf_fields_by_type[sample['type']]), original_line_idx)
					original_line_idx += 1
					line_extra_duration -= 1
		serialized += '\n'

	return serialized
