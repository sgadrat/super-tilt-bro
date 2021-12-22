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
