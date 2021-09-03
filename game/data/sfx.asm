SFX_BANK = CURRENT_BANK_NUMBER

sfx_crash:
.(
	AUDIO_NOISE_PLAY_TIMED_FREQ(11,4)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,4)
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_PLAY_TIMED_FREQ(11,4)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,4)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_WAIT(3)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_WAIT(3)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_WAIT(3)
	AUDIO_NOISE_EFFECT_END
.)

sfx_death:
.(
	AUDIO_NOISE_SET_PERIODIC(1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(13,2)
	AUDIO_NOISE_SET_VOLUME(14)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(13)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(11)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(1)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_EFFECT_END
.)

sfx_hit:
.(
	AUDIO_NOISE_PLAY_TIMED_FREQ(8,2)
	AUDIO_NOISE_SET_VOLUME(14)
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,2)
	AUDIO_NOISE_SET_VOLUME(13)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_PLAY_TIMED_FREQ(6,2)
	AUDIO_NOISE_SET_VOLUME(11)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_PLAY_TIMED_FREQ(5,2)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(1)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_EFFECT_END
.)

sfx_parry:
.(
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,1)
	AUDIO_NOISE_SET_VOLUME(14)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(13)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(11)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(1)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_EFFECT_END
.)

sfx_shield_hit:
.(
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,1)
	AUDIO_NOISE_SET_VOLUME(14)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(13)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_EFFECT_END
.)

sfx_shield_break:
.(
	AUDIO_NOISE_PLAY_TIMED_FREQ(11,2)
	AUDIO_NOISE_SET_VOLUME(14)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(13)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(11)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(1)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_EFFECT_END
.)

sfx_title_screen_text:
.(
	AUDIO_NOISE_PLAY_TIMED_FREQ(1,2)
	AUDIO_NOISE_SET_VOLUME(14)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(13)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(11)
	AUDIO_NOISE_PLAY_TIMED_FREQ(2,2)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_SET_PERIODIC(1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(3,2)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_PLAY_TIMED_FREQ(4,1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(5,1)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_PLAY_TIMED_FREQ(6,1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,1)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_PLAY_TIMED_FREQ(8,2)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(1)
	AUDIO_NOISE_WAIT(1)
	AUDIO_NOISE_SET_VOLUME(0)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_EFFECT_END
.)

sfx_interface_click:
.(
	AUDIO_NOISE_PLAY_TIMED_FREQ(2,3)
	AUDIO_NOISE_SET_VOLUME(12)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_EFFECT_END
.)

sfx_fast_fall:
.(
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_PLAY_TIMED_FREQ(8,1)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,1)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_PLAY_TIMED_FREQ(6,1)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_PLAY_TIMED_FREQ(5,1)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_PLAY_TIMED_FREQ(6,1)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,1)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_PLAY_TIMED_FREQ(8,1)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_PLAY_TIMED_FREQ(9,1)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_PLAY_TIMED_FREQ(10,1)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_PLAY_TIMED_FREQ(11,1)
	AUDIO_NOISE_SET_VOLUME(1)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_EFFECT_END
.)

sfx_land:
.(
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_PLAY_TIMED_FREQ(10,1)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,1)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_SET_PERIODIC(1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(5,1)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_PLAY_TIMED_FREQ(8,1)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_EFFECT_END
.)

sfx_tech:
.(
	AUDIO_NOISE_SET_VOLUME(15)
	AUDIO_NOISE_PLAY_TIMED_FREQ(8,1)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_EFFECT_END
.)

sfx_jump:
.(
	AUDIO_NOISE_SET_VOLUME(8)
	AUDIO_NOISE_SET_PERIODIC(1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(10,1)
	AUDIO_NOISE_SET_VOLUME(9)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(10)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_SET_PERIODIC(0)
	AUDIO_NOISE_PLAY_TIMED_FREQ(9,1)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_PLAY_TIMED_FREQ(8,1)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(6,1)
	AUDIO_NOISE_SET_VOLUME(1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(5,1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(4,1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(3,1)
	AUDIO_NOISE_EFFECT_END
.)

sfx_aerial_jump:
.(
	AUDIO_NOISE_SET_VOLUME(7)
	AUDIO_NOISE_PLAY_TIMED_FREQ(9,1)
	AUDIO_NOISE_SET_VOLUME(6)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(5)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(4)
	AUDIO_NOISE_WAIT(0)
	AUDIO_NOISE_SET_VOLUME(3)
	AUDIO_NOISE_PLAY_TIMED_FREQ(8,1)
	AUDIO_NOISE_SET_VOLUME(2)
	AUDIO_NOISE_PLAY_TIMED_FREQ(7,1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(6,1)
	AUDIO_NOISE_SET_VOLUME(1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(5,1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(4,1)
	AUDIO_NOISE_PLAY_TIMED_FREQ(3,1)
	AUDIO_NOISE_EFFECT_END
.)
