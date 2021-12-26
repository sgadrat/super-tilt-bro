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

def human_readable_uctf(uctf):
	serialized = ''
	for channel_idx in range(len(uctf['channels'])):
		serialized += 'CHANNEL {:02X}\n'.format(channel_idx)
		serialized += ', '.join(['{:02X}'.format(x) for x in uctf['channels'][channel_idx]])
		serialized += '\n\n'

	for sample_idx in range(len(uctf['samples'])):
		sample = uctf['samples'][sample_idx]
		serialized += 'SAMPLE {:02X} ({})\n'.format(sample_idx, sample['type'])
		serialized += '# {}\n'.format('\t'.join(ftmmanip.uctf_fields_by_type[sample['type']]))
		for line_idx in range(len(sample['lines'])):
			line = sample['lines'][line_idx]
			values = []
			for field in ftmmanip.uctf_fields_by_type[sample['type']]:
				values.append(str(line[field]) if line[field] is not None else '...')
			serialized += '{:02X} : {}\n'.format(line_idx, '\t'.join(values))
		serialized += '\n'

	return serialized
