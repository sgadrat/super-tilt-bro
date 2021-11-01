;
; Run-length compression for zeros
;  ZIPNT_ZEROS(n) - output n zeros (0 < n < 256)
;  ZIPZ - output one zero
;  ZIPNT_END - end of compressed sequence
;

#define ZIPNT_ZEROS(n) $00, n
#define ZIPZ $00, $01
#define ZIPNT_END $00, $00

; VECTOR(lbl) - Place data representing label's address in little endian
;#define VECTOR(lbl) .byt <lbl, >lbl
#define VECTOR(lbl) .word lbl

;
; New audio engine macros
;TODO comment it properly
;

; Music header
;  Format
;   2 bytes - vector to 2a03 pulse channel 1's track
;   2 bytes - vector to 2a03 pulse channel 1's track
;   2 bytes - vector to 2a03 triangle channel's track
;   2 bytes - vector to 2a03 noise channel's track
;   1 byte - Music tempo (0 - 60 Hz, 1 - 50 Hz)
MUSIC_HEADER_PULSE1_TRACK_OFFSET = 0
MUSIC_HEADER_PULSE2_TRACK_OFFSET = 2
MUSIC_HEADER_TRIANGLE_TRACK_OFFSET = 4
MUSIC_HEADER_NOISE_TRACK_OFFSET = 6
MUSIC_HEADER_TEMPO = 8

; Commons

#define MUSIC_END .byt $00, $00
#define SAMPLE_END .byt $00

; 2a03 pulse

AUDIO_OP_CHAN_PARAMS = 1
AUDIO_OP_CHAN_VOLUME_LOW = 2
AUDIO_OP_CHAN_VOLUME_HIGH = 3
AUDIO_OP_PLAY_TIMED_FREQ = 4
AUDIO_OP_PLAY_NOTE = 5
AUDIO_OP_WAIT = 6
AUDIO_OP_LONG_WAIT = 7
AUDIO_OP_HALT = 8
AUDIO_OP_PITCH_SLIDE = 9
AUDIO_OP_CHAN_DUTY = 10
AUDIO_OP_PLAY_TIMED_NOTE = 11
AUDIO_OP_META_NOTE_SLIDE_UP = 12
AUDIO_OP_META_NOTE_SLIDE_DOWN = 13
AUDIO_OP_META_WAIT_SLIDE_UP = 14
AUDIO_OP_META_WAIT_SLIDE_DOWN = 15

AUDIO_OP_NOISE_SET_VOLUME = 1
AUDIO_OP_NOISE_SET_PERIODIC = 2
AUDIO_OP_NOISE_PLAY_TIMED_FREQ = 3
AUDIO_OP_NOISE_WAIT = 4
AUDIO_OP_NOISE_LONG_WAIT = 5
AUDIO_OP_NOISE_HALT = 6
AUDIO_OP_NOISE_PITCH_SLIDE_UP = 7
AUDIO_OP_NOISE_PITCH_SLIDE_DOWN = 8
AUDIO_OP_NOISE_EFFECT_END = 9

#define CHAN_PARAMS(default_dur,duty,loop,const,volume,sweep_enabled,sweep_period,sweep_negate,sweep_shift) .byt \
(AUDIO_OP_CHAN_PARAMS << 3) + default_dur, \
(duty << 6) + (loop << 5) + (const << 4) + volume, \
(sweep_enabled << 7) + (sweep_period << 4) + (sweep_negate << 3) + sweep_shift

#define CHAN_VOLUME_LOW(volume) .byt (AUDIO_OP_CHAN_VOLUME_LOW << 3) + volume

#define CHAN_VOLUME_HIGH(volume_minus_eight) .byt (AUDIO_OP_CHAN_VOLUME_HIGH << 3) + volume_minus_eight

#define CHAN_DUTY(duty) .byt (AUDIO_OP_CHAN_DUTY << 3) + (duty << 1)

#define PLAY_TIMED_FREQ(freq,duration) .byt \
(AUDIO_OP_PLAY_TIMED_FREQ << 3) + (freq >> 8), \
<freq, \
duration

#define PLAY_NOTE(dir,shift,note_idx) .byt \
(AUDIO_OP_PLAY_NOTE << 3) + (dir << 2) + shift, \
note_idx

#define PLAY_TIMED_NOTE(dur_minus_one,note_idx) .byt \
(AUDIO_OP_PLAY_TIMED_NOTE << 3) + (dur_minus_one >> 1), \
((dur_minus_one & %00000001) << 7) + note_idx

#define WAIT(dur_minus_one) .byt (AUDIO_OP_WAIT << 3) + dur_minus_one

#define LONG_WAIT(duration) .byt (AUDIO_OP_LONG_WAIT << 3), duration

#define HALT(dur_minus_one) .byt (AUDIO_OP_HALT << 3) + dur_minus_one

#define PITCH_SLIDE(step) .byt \
(AUDIO_OP_PITCH_SLIDE << 3) + ((step >> 8) & %00000100), \
<step

#define AUDIO_PULSE_META_NOTE(note_idx,duration) .byt \
(AUDIO_OP_META_NOTE_SLIDE_DOWN << 3) + %00000000, \
note_idx, \
duration

#define AUDIO_PULSE_META_NOTE_DUT(note_idx,duration,duty) .byt \
(AUDIO_OP_META_NOTE_SLIDE_DOWN << 3) + %00000001, \
note_idx, \
duration, \
(duty << 6)

#define AUDIO_PULSE_META_NOTE_VOL(note_idx,duration,volume) .byt \
(AUDIO_OP_META_NOTE_SLIDE_DOWN << 3) + %00000100, \
note_idx, \
duration, \
volume

#define AUDIO_PULSE_META_NOTE_DUT_VOL(note_idx,duration,duty,volume) .byt \
(AUDIO_OP_META_NOTE_SLIDE_DOWN << 3) + %00000101, \
note_idx, \
duration, \
(duty << 6) + volume

#define AUDIO_PULSE_META_NOTE_USLIDE(note_idx,duration,slide) .byt \
(AUDIO_OP_META_NOTE_SLIDE_UP << 3) + %00000010, \
note_idx, \
duration, \
(slide & $ff)

#define AUDIO_PULSE_META_NOTE_DUT_USLIDE(note_idx,duration,duty,slide) .byt \
(AUDIO_OP_META_NOTE_SLIDE_UP << 3) + %00000011, \
note_idx, \
duration, \
(duty << 6), \
(slide & $ff)

#define AUDIO_PULSE_META_NOTE_VOL_USLIDE(note_idx,duration,volume,slide) .byt \
(AUDIO_OP_META_NOTE_SLIDE_UP << 3) + %00000110, \
note_idx, \
duration, \
volume, \
(slide & $ff)

#define AUDIO_PULSE_META_NOTE_DUT_VOL_USLIDE(note_idx,duration,duty,volume,slide) .byt \
(AUDIO_OP_META_NOTE_SLIDE_UP << 3) + %00000111, \
note_idx, \
duration, \
(duty << 6) + volume, \
(slide & $ff)

#define AUDIO_PULSE_META_NOTE_DSLIDE(note_idx,duration,slide) .byt \
(AUDIO_OP_META_NOTE_SLIDE_DOWN << 3) + %00000010, \
note_idx, \
duration, \
(slide & $ff)

#define AUDIO_PULSE_META_NOTE_DUT_DSLIDE(note_idx,duration,duty,slide) .byt \
(AUDIO_OP_META_NOTE_SLIDE_DOWN << 3) + %00000011, \
note_idx, \
duration, \
(duty << 6), \
(slide & $ff)

#define AUDIO_PULSE_META_NOTE_VOL_DSLIDE(note_idx,duration,volume,slide) .byt \
(AUDIO_OP_META_NOTE_SLIDE_DOWN << 3) + %00000110, \
note_idx, \
duration, \
volume, \
(slide & $ff)

#define AUDIO_PULSE_META_NOTE_DUT_VOL_DSLIDE(note_idx,duration,duty,volume,slide) .byt \
(AUDIO_OP_META_NOTE_SLIDE_DOWN << 3) + %00000111, \
note_idx, \
duration, \
(duty << 6) + volume, \
(slide & $ff)

#define AUDIO_PULSE_META_WAIT(duration) .byt \
(AUDIO_OP_META_WAIT_SLIDE_DOWN << 3) + %00000000, \
duration

#define AUDIO_PULSE_META_WAIT_DUT(duration,duty) .byt \
(AUDIO_OP_META_WAIT_SLIDE_DOWN << 3) + %00000001, \
duration, \
(duty << 6)

#define AUDIO_PULSE_META_WAIT_VOL(duration,volume) .byt \
(AUDIO_OP_META_WAIT_SLIDE_DOWN << 3) + %00000100, \
duration, \
volume

#define AUDIO_PULSE_META_WAIT_DUT_VOL(duration,duty,volume) .byt \
(AUDIO_OP_META_WAIT_SLIDE_DOWN << 3) + %00000101, \
duration, \
(duty << 6) + volume

#define AUDIO_PULSE_META_WAIT_USLIDE(duration,slide) .byt \
(AUDIO_OP_META_WAIT_SLIDE_UP << 3) + %00000010, \
duration, \
(slide & $ff)

#define AUDIO_PULSE_META_WAIT_DUT_USLIDE(duration,duty,slide) .byt \
(AUDIO_OP_META_WAIT_SLIDE_UP << 3) + %00000011, \
duration, \
(duty << 6), \
(slide & $ff)

#define AUDIO_PULSE_META_WAIT_VOL_USLIDE(duration,volume,slide) .byt \
(AUDIO_OP_META_WAIT_SLIDE_UP << 3) + %00000110, \
duration, \
volume, \
(slide & $ff)

#define AUDIO_PULSE_META_WAIT_DUT_VOL_USLIDE(duration,duty,volume,slide) .byt \
(AUDIO_OP_META_WAIT_SLIDE_UP << 3) + %00000111, \
duration, \
(duty << 6) + volume, \
(slide & $ff)

#define AUDIO_PULSE_META_WAIT_DSLIDE(duration,slide) .byt \
(AUDIO_OP_META_WAIT_SLIDE_DOWN << 3) + %00000010, \
duration, \
(slide & $ff)

#define AUDIO_PULSE_META_WAIT_DUT_DSLIDE(duration,duty,slide) .byt \
(AUDIO_OP_META_WAIT_SLIDE_DOWN << 3) + %00000011, \
duration, \
(duty << 6), \
(slide & $ff)

#define AUDIO_PULSE_META_WAIT_VOL_DSLIDE(duration,volume,slide) .byt \
(AUDIO_OP_META_WAIT_SLIDE_DOWN << 3) + %00000110, \
duration, \
volume, \
(slide & $ff)

#define AUDIO_PULSE_META_WAIT_DUT_VOL_DSLIDE(duration,duty,volume,slide) .byt \
(AUDIO_OP_META_WAIT_SLIDE_DOWN << 3) + %00000111, \
duration, \
(duty << 6) + volume, \
(slide & $ff)

#define AUDIO_NOISE_SET_VOLUME(volume) .byt \
(AUDIO_OP_NOISE_SET_VOLUME << 4) + volume

#define AUDIO_NOISE_SET_PERIODIC(flag) .byt \
(AUDIO_OP_NOISE_SET_PERIODIC << 4) + flag

#define AUDIO_NOISE_PLAY_TIMED_FREQ(freq, duration) .byt \
(AUDIO_OP_NOISE_PLAY_TIMED_FREQ << 4) + freq, \
duration

#define AUDIO_NOISE_WAIT(dur_minus_one) .byt \
(AUDIO_OP_NOISE_WAIT << 4) + dur_minus_one

#define AUDIO_NOISE_LONG_WAIT(duration) .byt \
(AUDIO_OP_NOISE_LONG_WAIT << 4), \
duration

#define AUDIO_NOISE_HALT(dur_minus_one) .byt \
(AUDIO_OP_NOISE_HALT << 4) + dur_minus_one

#define AUDIO_NOISE_PITCH_SLIDE_UP(slide) .byt \
(AUDIO_OP_NOISE_PITCH_SLIDE_UP << 4) + slide

#define AUDIO_NOISE_PITCH_SLIDE_DOWN(slide) .byt \
(AUDIO_OP_NOISE_PITCH_SLIDE_DOWN << 4) + slide

#define AUDIO_NOISE_EFFECT_END .byt \
(AUDIO_OP_NOISE_EFFECT_END << 4)

;
; Animation data representation
;  ANIM_FRAME_BEGIN(duration) - animation frame header
;  ANIM_DEFAULT_HEADER - game-defined fixed length header data
;  ANIM_SPRITE_FOREGROUND_COUNT(n) - number of foreground sprites in the frame
;  ANIM_SPRITE_NORMAL_COUNT(n) - number of normal sprites in the frame
;  ANIM_ANIMATION_END - animation footer
;  ANIM_SPRITE(y,tile,attr,x) - sprite description
;
; Example:
;  animation_data:
;  ; Frame 1
;  ANIM_FRAME_BEGIN(32)
;  ANIM_DEFAULT_HEADER
;  ANIM_SPRITE_FOREGROUND_COUNT(1)
;    ANIM_SPRITE($f9, TILE_PARTY_HAT, $01, $00) ; Y, tile, attr, X
;  ANIM_SPRITE_NORMAL_COUNT(2)
;    ANIM_SPRITE($00, TILE_OPEN_ARMS_SINBAD_HEAD, $00, $00)
;    ANIM_SPRITE($08, TILE_OPEN_ARMS_SINBAD_BODY, $00, $00)
;  ; Frame 2
;  ANIM_FRAME_BEGIN(32)
;  ANIM_DEFAULT_HEADER
;  ANIM_SPRITE_FOREGROUND_COUNT(1)
;    ANIM_SPRITE($f9, TILE_PARTY_HAT, $01, $ff) ; Y, tile, attr, X
;  ANIM_SPRITE_NORMAL_COUNT(2)
;    ANIM_SPRITE($00, TILE_OPEN_ARMS_SINBAD_HEAD, $40, $00)
;    ANIM_SPRITE($08, TILE_OPEN_ARMS_SINBAD_BODY, $40, $00)
;  ; End of animation
;  ANIM_ANIMATION_END
;

#define ANIM_FRAME_BEGIN(duration) .byt duration
#define ANIM_ANIMATION_END .byt $00
#define ANIM_SPRITE_FOREGROUND_COUNT(n) .byt n
#define ANIM_SPRITE_NORMAL_COUNT(n) .byt n
#define ANIM_SPRITE(y,tile,attr,x) .byt y, tile, attr, x

;
; Transition between gamestates
;  STATE_TRANSITION(previous,new) - ID of the transition from state "previous" and state "new"
;
; Context
;  change_global_gamestate refers to the state transition table to know if a
;  special routine should be called before running the new state. Such a routine
;  can create a visual effect to smooth the transition.
;
;  Each transition has an ID, constructed from both IDs of the previous and the
;  new state. The state transition table associate transition IDs to routines.
;
; Example
;  state_transition_id:
;  .byt STATE_TRANSITION(GAME_STATE_TITLE, GAME_STATE_INGAME)
;  .byt STATE_TRANSITION(GAME_STATE_INGAME, GAME_STATE_TITLE)
;  .byt 0

;  state_transition_pretransition_lsb:
;  .byt <pre_transition_title_to_game
;  .byt <pre_transition_game_to_title
;  state_transition_pretransition_msb:
;  .byt >pre_transition_title_to_game
;  .byt >pre_transition_game_to_title

;  state_transition_posttransition_lsb:
;  .byt <post_transition_title_to_game
;  .byt <post_transition_game_to_title
;  state_transition_posttransition_msb:
;  .byt >post_transition_title_to_game
;  .byt >post_transition_game_to_title
;

#define STATE_TRANSITION(previous,new) previous * 16 + new

;
; Utility macros
;

; Perform multibyte signed comparison
;
; Output - N flag set if "a < b", unset otherwise
;          C flag set if "(unsigned)a < (unsigned)b", unset otherwise
; Overwrites register A
;
; See also the routine with the same name (lowercase)
#define SIGNED_CMP(a_low,a_high,b_low,b_high) .(:\
	lda a_low:\
	cmp b_low:\
	lda a_high:\
	sbc b_high:\
	bvc end_signed_cmp:\
	eor #%10000000:\
	end_signed_cmp:\
.)

; Switch current player
;  register X - Current player number
;  Result is stored in register X
;
; See also the routine with the same name (lowercase)
#define SWITCH_SELECTED_PLAYER .(:\
	dex:\
	bpl end_switch_selected_player:\
		ldx #1:\
	end_switch_selected_player:\
.)

; Set register A to the sign extension of recently loaded value (based on N flag)
#define SIGN_EXTEND() .(:\
	bmi set_relative_msb_neg:\
		lda #0:\
		jmp end_sign_extend:\
	set_relative_msb_neg:\
		lda #$ff:\
	end_sign_extend:\
.)

; Usefull to pass a comma in a macro argument
#define COMMA ,

; Should be equivalent to the switch_bank routine
#ifdef MAPPER_RAINBOW
#define SWITCH_BANK(n) .(:\
    lda n:\
    sta RAINBOW_PRG_BANKING_1:\
.)
#else
#ifdef MAPPER_UNROM
#define SWITCH_BANK(n) .(:\
	lda n:\
	jsr switch_bank:\
.)
#else
#define SWITCH_BANK(n) .(:\
    lda n:\
    sta $c000:\
.)
#endif
#endif
