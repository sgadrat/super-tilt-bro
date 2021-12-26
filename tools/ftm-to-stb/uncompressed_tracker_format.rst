Uncompressed Tracker Format (UCTF) is a simple, json-compatible format meant as an intermediary between tracker data and engine opcodes. It shares the idea of line with notes, but does not handle instruments nor non supported effects, each line shall have a complete description of expected engine's state. The code to convert UCTF to the engine's internal format should be generic, so supporting a new tracker only takes converting its format to UCTF.

Any non-standard field is allowed and should be ignored. This can be used to store original info before uncompressing it. Some may be included if it become supported by STB audio engine.

Structure::

	{
		"channels": [
			CHANNEL,
			CHANNEL,
			...
		],
		"samples": [
			SAMPLE,
			SAMPLE,
			...
		]
	}

CHANNEL::

	{
		"sample_refs": [
			uint,
			uint,
			...
		]
	}

SAMPLE::

	{
		"type": SAMPLE-TYPE,
		"lines": [
			LINE,
			LINE,
			...
		]
	}

SAMPLE-TYPE::

	enum-string: "2a03-pulse" | "2a03-triangle" | "2a03-noise" | "vrc6-pulse" | "vrc6-saw"

LINE::

	2A03_PULSE_LINE | 2A03_TRIANGLE_LINE | 2A03_NOISE_LINE | VRC6_PULSE_LINE | VRC6_SAW_LINE | "empty_row"

2A03_PULSE_LINE::

	{
		"note": NOTE_NAME,
		"frequency_adjustement": int12 [-2047;+2047],
		"volume": uint4,
		"duty": uint2,
		"pitch_slide": int16,
	}

2A03_TRIANGLE_LINE::

	{
		"note": NOTE_NAME,
		"frequency_adjustement": int12 [-2047;+2047],
		"pitch_slide": int16,
	}

2A03_NOISE_LINE::

	{
		"freq": NOISE_NOTE_NAME,
		"frequency_adjustement": int5 [-15;+15],
		"volume": uint4,
		"periodic": uint1,
		"pitch_slide": int5 [-15;+15],
	}

Example::

	{
		"channels": [
			{
				"sample_refs": [
					0,
					0,
					0,
				]
			},
		],
		"samples": [
			{
				"type": "2a03-pulse",
				"lines": [
					{"note": "B-2", "volume": 8, "duty": 0, "pitch_slide": 0},
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",

					{"note": "E-3", "volume": null, "duty": null, "pitch_slide": null},
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",

					{"note": null, "volume": 9, "duty": null, "pitch_slide": null},
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",

					{"note": "A-3", "volume": null, "duty": null, "pitch_slide": null},
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",

					{"note": null, "volume": 10, "duty": null, "pitch_slide": null},
					"empty_row",
					"empty_row",
					"empty_row",
					"empty_row",
				],
			},
		]
	}
