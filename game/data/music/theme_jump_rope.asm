#define MUSIC_JUMP_ROPE_WITH_NOISE 1

music_jump_rope_info:
.word music_jump_rope_track_pulse1
.word music_jump_rope_track_pulse2
.word music_jump_rope_track_triangle
.word music_jump_rope_track_noise

#if MUSIC_JUMP_ROPE_WITH_NOISE
#else
music_jump_rope_sample_noise_halt:
AUDIO_NOISE_HALT(7)
SAMPLE_END

music_jump_rope_track_noise:
.word music_jump_rope_sample_noise_halt
MUSIC_END
#endif

music_jump_rope_track_pulse1:
.word music_jump_rope_sample_64
.word music_jump_rope_sample_63
.word music_jump_rope_sample_65
.word music_jump_rope_sample_63
.word music_jump_rope_sample_66
.word music_jump_rope_sample_10
.word music_jump_rope_sample_9
.word music_jump_rope_sample_11
.word music_jump_rope_sample_9
.word music_jump_rope_sample_12
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_14
.word music_jump_rope_sample_15
.word music_jump_rope_sample_9
.word music_jump_rope_sample_16
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_12
.word music_jump_rope_sample_9
.word music_jump_rope_sample_12
.word music_jump_rope_sample_9
.word music_jump_rope_sample_17
.word music_jump_rope_sample_9
.word music_jump_rope_sample_18
.word music_jump_rope_sample_9
.word music_jump_rope_sample_19
.word music_jump_rope_sample_9
.word music_jump_rope_sample_19
.word music_jump_rope_sample_9
.word music_jump_rope_sample_20
.word music_jump_rope_sample_21
.word music_jump_rope_sample_9
.word music_jump_rope_sample_11
.word music_jump_rope_sample_9
.word music_jump_rope_sample_12
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_22
.word music_jump_rope_sample_9
.word music_jump_rope_sample_16
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_23
.word music_jump_rope_sample_25
.word music_jump_rope_sample_9
.word music_jump_rope_sample_17
.word music_jump_rope_sample_9
.word music_jump_rope_sample_18
.word music_jump_rope_sample_9
.word music_jump_rope_sample_19
.word music_jump_rope_sample_9
.word music_jump_rope_sample_26
.word music_jump_rope_sample_24
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_14
.word music_jump_rope_sample_3
.word music_jump_rope_sample_24
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_13
.word music_jump_rope_sample_9
.word music_jump_rope_sample_27
.word music_jump_rope_sample_9
.word music_jump_rope_sample_27
.word music_jump_rope_sample_9
.word music_jump_rope_sample_27
.word music_jump_rope_sample_9
.word music_jump_rope_sample_27
.word music_jump_rope_sample_9
.word music_jump_rope_sample_20
.word music_jump_rope_sample_0
MUSIC_END

music_jump_rope_track_pulse2:
.word music_jump_rope_sample_68
.word music_jump_rope_sample_67
.word music_jump_rope_sample_69
.word music_jump_rope_sample_67
.word music_jump_rope_sample_70
.word music_jump_rope_sample_76
.word music_jump_rope_sample_75
.word music_jump_rope_sample_77
.word music_jump_rope_sample_71
.word music_jump_rope_sample_67
.word music_jump_rope_sample_78
.word music_jump_rope_sample_75
.word music_jump_rope_sample_61
.word music_jump_rope_sample_54
.word music_jump_rope_sample_3
.word music_jump_rope_sample_56
.word music_jump_rope_sample_79
.word music_jump_rope_sample_80
.word music_jump_rope_sample_72
.word music_jump_rope_sample_73
.word music_jump_rope_sample_72
.word music_jump_rope_sample_74
.word music_jump_rope_sample_50
.word music_jump_rope_sample_55
.word music_jump_rope_sample_71
.word music_jump_rope_sample_67
.word music_jump_rope_sample_78
.word music_jump_rope_sample_75
.word music_jump_rope_sample_61
.word music_jump_rope_sample_57
.word music_jump_rope_sample_56
.word music_jump_rope_sample_79
.word music_jump_rope_sample_81
.word music_jump_rope_sample_51
.word music_jump_rope_sample_72
.word music_jump_rope_sample_73
.word music_jump_rope_sample_72
.word music_jump_rope_sample_74
.word music_jump_rope_sample_61
.word music_jump_rope_sample_58
.word music_jump_rope_sample_62
.word music_jump_rope_sample_59
.word music_jump_rope_sample_58
.word music_jump_rope_sample_60
.word music_jump_rope_sample_0
MUSIC_END

music_jump_rope_track_triangle:
.word music_jump_rope_sample_29
.word music_jump_rope_sample_28
.word music_jump_rope_sample_30
.word music_jump_rope_sample_28
.word music_jump_rope_sample_31
.word music_jump_rope_sample_32
.word music_jump_rope_sample_28
.word music_jump_rope_sample_33
.word music_jump_rope_sample_52
.word music_jump_rope_sample_30
.word music_jump_rope_sample_28
.word music_jump_rope_sample_53
.word music_jump_rope_sample_30
.word music_jump_rope_sample_28
.word music_jump_rope_sample_34
.word music_jump_rope_sample_35
.word music_jump_rope_sample_28
.word music_jump_rope_sample_30
.word music_jump_rope_sample_28
.word music_jump_rope_sample_36
.word music_jump_rope_sample_4
.word music_jump_rope_sample_37
.word music_jump_rope_sample_28
.word music_jump_rope_sample_38
.word music_jump_rope_sample_28
.word music_jump_rope_sample_28
.word music_jump_rope_sample_39
.word music_jump_rope_sample_5
.word music_jump_rope_sample_37
.word music_jump_rope_sample_28
.word music_jump_rope_sample_38
.word music_jump_rope_sample_28
.word music_jump_rope_sample_28
.word music_jump_rope_sample_30
.word music_jump_rope_sample_38
.word music_jump_rope_sample_30
.word music_jump_rope_sample_34
.word music_jump_rope_sample_1
MUSIC_END

#if MUSIC_JUMP_ROPE_WITH_NOISE
music_jump_rope_track_noise:
.word music_jump_rope_sample_2
.word music_jump_rope_sample_46
.word music_jump_rope_sample_40
.word music_jump_rope_sample_47
.word music_jump_rope_sample_40
.word music_jump_rope_sample_47
.word music_jump_rope_sample_40
.word music_jump_rope_sample_47
.word music_jump_rope_sample_40
.word music_jump_rope_sample_48
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_6
.word music_jump_rope_sample_42
.word music_jump_rope_sample_40
.word music_jump_rope_sample_43
.word music_jump_rope_sample_40
.word music_jump_rope_sample_44
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_6
.word music_jump_rope_sample_42
.word music_jump_rope_sample_40
.word music_jump_rope_sample_43
.word music_jump_rope_sample_40
.word music_jump_rope_sample_44
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_6
.word music_jump_rope_sample_42
.word music_jump_rope_sample_40
.word music_jump_rope_sample_43
.word music_jump_rope_sample_40
.word music_jump_rope_sample_44
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_49
.word music_jump_rope_sample_40
.word music_jump_rope_sample_48
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_6
.word music_jump_rope_sample_42
.word music_jump_rope_sample_40
.word music_jump_rope_sample_43
.word music_jump_rope_sample_40
.word music_jump_rope_sample_44
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_6
.word music_jump_rope_sample_42
.word music_jump_rope_sample_40
.word music_jump_rope_sample_43
.word music_jump_rope_sample_40
.word music_jump_rope_sample_44
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_7
.word music_jump_rope_sample_8
.word music_jump_rope_sample_42
.word music_jump_rope_sample_40
.word music_jump_rope_sample_43
.word music_jump_rope_sample_40
.word music_jump_rope_sample_44
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_49
.word music_jump_rope_sample_40
.word music_jump_rope_sample_48
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_6
.word music_jump_rope_sample_42
.word music_jump_rope_sample_40
.word music_jump_rope_sample_43
.word music_jump_rope_sample_40
.word music_jump_rope_sample_44
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_6
.word music_jump_rope_sample_42
.word music_jump_rope_sample_40
.word music_jump_rope_sample_43
.word music_jump_rope_sample_40
.word music_jump_rope_sample_44
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_6
.word music_jump_rope_sample_42
.word music_jump_rope_sample_40
.word music_jump_rope_sample_43
.word music_jump_rope_sample_40
.word music_jump_rope_sample_44
.word music_jump_rope_sample_40
.word music_jump_rope_sample_45
.word music_jump_rope_sample_40
.word music_jump_rope_sample_49
.word music_jump_rope_sample_40
.word music_jump_rope_sample_48
.word music_jump_rope_sample_40
.word music_jump_rope_sample_41
MUSIC_END
#endif


music_jump_rope_sample_0:
.(
	WAIT(4)
	AUDIO_PULSE_META_WAIT_VOL(251,0)
	SAMPLE_END
.)

music_jump_rope_sample_1:
.(
	LONG_WAIT(255)
	WAIT(0)
	SAMPLE_END
.)

#if MUSIC_JUMP_ROPE_WITH_NOISE
music_jump_rope_sample_2:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_SET_PERIODIC(0)
	AUDIO_NOISE_PLAY_TIMED_FREQ(0,255)
	AUDIO_NOISE_WAIT(0)
	SAMPLE_END
.)
#endif

music_jump_rope_sample_3:
.(
	WAIT(2)
	SAMPLE_END
.)

music_jump_rope_sample_4:
.(
	WAIT(0)
	HALT(5)
	PLAY_TIMED_NOTE(11,29)
	PLAY_TIMED_NOTE(5,41)
	HALT(5)
	PLAY_TIMED_NOTE(11,31)
	PLAY_TIMED_NOTE(5,43)
	HALT(5)
	PLAY_TIMED_NOTE(11,31)
	PLAY_TIMED_NOTE(5,43)
	SAMPLE_END
.)

music_jump_rope_sample_5:
.(
	WAIT(2)
	PLAY_TIMED_NOTE(5,48)
	SAMPLE_END
.)

#if MUSIC_JUMP_ROPE_WITH_NOISE
music_jump_rope_sample_6:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_LONG_WAIT(39)
	SAMPLE_END
.)

music_jump_rope_sample_7:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_LONG_WAIT(32)
	SAMPLE_END
.)

music_jump_rope_sample_8:
.(
	AUDIO_NOISE_WAIT(6)
	SAMPLE_END
.)
#endif

music_jump_rope_sample_9:
.(
	CHAN_VOLUME_HIGH(6)
	WAIT(0)
	CHAN_VOLUME_HIGH(4)
	WAIT(0)
	CHAN_VOLUME_HIGH(2)
	WAIT(0)
	CHAN_VOLUME_HIGH(1)
	WAIT(0)
	CHAN_VOLUME_LOW(7)
	WAIT(0)
	CHAN_VOLUME_LOW(5)
	WAIT(0)
	CHAN_VOLUME_LOW(4)
	WAIT(0)
	CHAN_VOLUME_LOW(2)
	WAIT(0)
	CHAN_VOLUME_LOW(0)
	WAIT(2)
	SAMPLE_END
.)

music_jump_rope_sample_10:
.(
	LONG_WAIT(13)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,50)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,48)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,43)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	WAIT(5)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,48)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	AUDIO_PULSE_META_WAIT_VOL(24,8)
	AUDIO_PULSE_META_WAIT_VOL(24,0)
	CHAN_VOLUME_HIGH(0)
	WAIT(5)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,24)
	SAMPLE_END
.)

music_jump_rope_sample_11:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,48)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	AUDIO_PULSE_META_WAIT_VOL(12,8)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,29)
	SAMPLE_END
.)

music_jump_rope_sample_12:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,29)
	SAMPLE_END
.)

music_jump_rope_sample_13:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,48)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,24)
	SAMPLE_END
.)

music_jump_rope_sample_14:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,48)
	CHAN_VOLUME_LOW(0)
	WAIT(2)
	SAMPLE_END
.)

music_jump_rope_sample_15:
.(
	WAIT(2)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(176,18)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,31)
	SAMPLE_END
.)

music_jump_rope_sample_16:
.(
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,19)
	CHAN_VOLUME_HIGH(6)
	WAIT(0)
	CHAN_VOLUME_HIGH(4)
	WAIT(0)
	CHAN_VOLUME_HIGH(2)
	WAIT(0)
	CHAN_VOLUME_HIGH(1)
	WAIT(0)
	CHAN_VOLUME_LOW(7)
	WAIT(0)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,55)
	PLAY_TIMED_NOTE(5,48)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,24)
	SAMPLE_END
.)

music_jump_rope_sample_17:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,31)
	SAMPLE_END
.)

music_jump_rope_sample_18:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,50)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,31)
	SAMPLE_END
.)

music_jump_rope_sample_19:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,24)
	SAMPLE_END
.)

music_jump_rope_sample_20:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(0,48)
	SAMPLE_END
.)

music_jump_rope_sample_21:
.(
	WAIT(4)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,24)
	SAMPLE_END
.)

music_jump_rope_sample_22:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,48)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(176,18)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,31)
	SAMPLE_END
.)

music_jump_rope_sample_23:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,29)
	CHAN_VOLUME_HIGH(6)
	WAIT(0)
	CHAN_VOLUME_HIGH(4)
	WAIT(0)
	CHAN_VOLUME_HIGH(2)
	WAIT(0)
	CHAN_VOLUME_HIGH(1)
	WAIT(0)
	SAMPLE_END
.)

music_jump_rope_sample_24:
.(
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,24)
	SAMPLE_END
.)

music_jump_rope_sample_25:
.(
	CHAN_VOLUME_LOW(7)
	WAIT(0)
	CHAN_VOLUME_LOW(5)
	WAIT(0)
	CHAN_VOLUME_LOW(4)
	WAIT(0)
	CHAN_VOLUME_LOW(2)
	WAIT(0)
	CHAN_VOLUME_LOW(0)
	WAIT(2)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,29)
	SAMPLE_END
.)

music_jump_rope_sample_26:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	SAMPLE_END
.)

music_jump_rope_sample_27:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,43)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(7)
	PLAY_TIMED_NOTE(0,19)
	SAMPLE_END
.)

music_jump_rope_sample_28:
.(
	PLAY_TIMED_NOTE(11,36)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	PLAY_TIMED_NOTE(11,36)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	SAMPLE_END
.)

music_jump_rope_sample_29:
.(
	PLAY_TIMED_NOTE(10,36)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	PLAY_TIMED_NOTE(11,36)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	PLAY_TIMED_NOTE(11,38)
	PLAY_TIMED_NOTE(5,50)
	HALT(5)
	PLAY_TIMED_NOTE(11,38)
	PLAY_TIMED_NOTE(5,50)
	HALT(5)
	SAMPLE_END
.)

music_jump_rope_sample_30:
.(
	PLAY_TIMED_NOTE(11,31)
	PLAY_TIMED_NOTE(5,43)
	HALT(5)
	PLAY_TIMED_NOTE(11,31)
	PLAY_TIMED_NOTE(5,43)
	HALT(5)
	SAMPLE_END
.)

music_jump_rope_sample_31:
.(
	PLAY_TIMED_NOTE(11,38)
	PLAY_TIMED_NOTE(4,50)
	SAMPLE_END
.)

music_jump_rope_sample_32:
.(
	WAIT(0)
	HALT(5)
	PLAY_TIMED_NOTE(11,38)
	PLAY_TIMED_NOTE(5,50)
	HALT(5)
	PLAY_TIMED_NOTE(11,36)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	PLAY_TIMED_NOTE(11,31)
	PLAY_TIMED_NOTE(5,43)
	HALT(5)
	PLAY_TIMED_NOTE(11,36)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	PLAY_TIMED_NOTE(11,36)
	HALT(7)
	WAIT(3)
	SAMPLE_END
.)

music_jump_rope_sample_33:
.(
	PLAY_TIMED_NOTE(11,29)
	PLAY_TIMED_NOTE(5,41)
	HALT(5)
	PLAY_TIMED_NOTE(11,29)
	PLAY_TIMED_NOTE(5,41)
	HALT(5)
	PLAY_TIMED_NOTE(11,36)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	PLAY_TIMED_NOTE(8,36)
	SAMPLE_END
.)

music_jump_rope_sample_34:
.(
	PLAY_TIMED_NOTE(0,36)
	SAMPLE_END
.)

music_jump_rope_sample_35:
.(
	LONG_WAIT(11)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	PLAY_TIMED_NOTE(11,36)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	PLAY_TIMED_NOTE(11,29)
	PLAY_TIMED_NOTE(5,41)
	HALT(5)
	PLAY_TIMED_NOTE(11,29)
	PLAY_TIMED_NOTE(5,41)
	HALT(5)
	SAMPLE_END
.)

music_jump_rope_sample_36:
.(
	PLAY_TIMED_NOTE(11,29)
	PLAY_TIMED_NOTE(4,41)
	SAMPLE_END
.)

music_jump_rope_sample_37:
.(
	HALT(5)
	SAMPLE_END
.)

music_jump_rope_sample_38:
.(
	SAMPLE_END
.)

music_jump_rope_sample_39:
.(
	PLAY_TIMED_NOTE(11,36)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	PLAY_TIMED_NOTE(8,36)
	SAMPLE_END
.)

#if MUSIC_JUMP_ROPE_WITH_NOISE
music_jump_rope_sample_40:
.(
	AUDIO_NOISE_SET_VOLUME(14)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_WAIT(0)
	SAMPLE_END
.)

music_jump_rope_sample_41:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_LONG_WAIT(248)
	SAMPLE_END
.)

music_jump_rope_sample_42:
.(
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_WAIT(0)
	SAMPLE_END
.)

music_jump_rope_sample_43:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_WAIT(2)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_PLAY_TIMED_FREQ(15,1)
	SAMPLE_END
.)

music_jump_rope_sample_44:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_WAIT(2)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_WAIT(0)
	SAMPLE_END
.)

music_jump_rope_sample_45:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_WAIT(14)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_PLAY_TIMED_FREQ(2,1)
	SAMPLE_END
.)

music_jump_rope_sample_46:
.(
	AUDIO_NOISE_LONG_WAIT(31)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_PLAY_TIMED_FREQ(2,1)
	SAMPLE_END
.)

music_jump_rope_sample_47:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_WAIT(14)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_WAIT(0)
	SAMPLE_END
.)

music_jump_rope_sample_48:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_WAIT(2)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(14)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(14)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_PLAY_TIMED_FREQ(15,1)
	SAMPLE_END
.)

music_jump_rope_sample_49:
.(
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_LONG_WAIT(39)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_WAIT(0)
	SAMPLE_END
.)
#endif

music_jump_rope_sample_50:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(0,52)
	SAMPLE_END
.)

music_jump_rope_sample_51:
.(
	WAIT(0)
	SAMPLE_END
.)

music_jump_rope_sample_52:
.(
	WAIT(2)
	PLAY_TIMED_NOTE(5,48)
	HALT(5)
	SAMPLE_END
.)

music_jump_rope_sample_53:
.(
	PLAY_TIMED_NOTE(11,29)
	PLAY_TIMED_NOTE(5,41)
	HALT(5)
	PLAY_TIMED_NOTE(11,29)
	PLAY_TIMED_NOTE(5,41)
	HALT(5)
	SAMPLE_END
.)

music_jump_rope_sample_54:
.(
	CHAN_VOLUME_LOW(0)
	WAIT(2)
	SAMPLE_END
.)

music_jump_rope_sample_55:
.(
	WAIT(4)
	SAMPLE_END
.)

music_jump_rope_sample_56:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,50)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,50)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,52)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,48)
	SAMPLE_END
.)

music_jump_rope_sample_57:
.(
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	SAMPLE_END
.)

music_jump_rope_sample_58:
.(
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,55)
	PLAY_TIMED_NOTE(5,57)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,52)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,52)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,52)
	SAMPLE_END
.)

music_jump_rope_sample_59:
.(
	WAIT(2)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,52)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,52)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(157,18)
	SAMPLE_END
.)

music_jump_rope_sample_60:
.(
	PLAY_TIMED_NOTE(5,60)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,62)
	PLAY_TIMED_NOTE(5,60)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,62)
	PLAY_TIMED_NOTE(5,59)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,60)
	PLAY_TIMED_NOTE(5,59)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,60)
	PLAY_TIMED_NOTE(0,52)
	SAMPLE_END
.)

music_jump_rope_sample_61:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,52)
	SAMPLE_END
.)

music_jump_rope_sample_62:
.(
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,52)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(2)
	SAMPLE_END
.)

music_jump_rope_sample_63:
.(
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	WAIT(5)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	WAIT(5)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	SAMPLE_END
.)

music_jump_rope_sample_64:
.(
	AUDIO_PULSE_META_NOTE_DUT_VOL(48,5,0,8)
	SAMPLE_END
.)

music_jump_rope_sample_65:
.(
	CHAN_VOLUME_HIGH(0)
	WAIT(5)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(176,30)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	WAIT(5)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(198,30)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	WAIT(5)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(264,48)
	PLAY_TIMED_NOTE(5,48)
	SAMPLE_END
.)

music_jump_rope_sample_66:
.(
	CHAN_VOLUME_HIGH(0)
	WAIT(5)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(176,17)
	SAMPLE_END
.)

music_jump_rope_sample_67:
.(
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,57)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	SAMPLE_END
.)

music_jump_rope_sample_68:
.(
	AUDIO_PULSE_META_NOTE_DUT_VOL(52,5,0,8)
	SAMPLE_END
.)

music_jump_rope_sample_69:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,52)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(148,24)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(157,24)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,52)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(11,50)
	PLAY_TIMED_NOTE(11,48)
	PLAY_TIMED_FREQ(209,24)
	PLAY_TIMED_NOTE(5,52)
	SAMPLE_END
.)

music_jump_rope_sample_70:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,52)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(148,17)
	SAMPLE_END
.)

music_jump_rope_sample_71:
.(
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,48)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,52)
	SAMPLE_END
.)

music_jump_rope_sample_72:
.(
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,57)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,59)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,60)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	SAMPLE_END
.)

music_jump_rope_sample_73:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,59)
	SAMPLE_END
.)

music_jump_rope_sample_74:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,60)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,55)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	SAMPLE_END
.)

music_jump_rope_sample_75:
.(
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,52)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,48)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	SAMPLE_END
.)

music_jump_rope_sample_76:
.(
	WAIT(6)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,55)
	SAMPLE_END
.)

music_jump_rope_sample_77:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,50)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_FREQ(157,24)
	AUDIO_PULSE_META_WAIT_VOL(24,0)
	CHAN_VOLUME_HIGH(0)
	WAIT(5)
	SAMPLE_END
.)

music_jump_rope_sample_78:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,57)
	SAMPLE_END
.)

music_jump_rope_sample_79:
.(
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,52)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,57)
	CHAN_VOLUME_LOW(0)
	WAIT(5)
	SAMPLE_END
.)

music_jump_rope_sample_80:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(5,53)
	SAMPLE_END
.)

music_jump_rope_sample_81:
.(
	CHAN_VOLUME_HIGH(0)
	PLAY_TIMED_NOTE(4,53)
	SAMPLE_END
.)

#echo
#echo music_jump_rope_size:
#print *-music_jump_rope_info
