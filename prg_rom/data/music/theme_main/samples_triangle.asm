;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Intro triangle
;  silenced, long notes in intro give
;  a strange feeling at game game start
;  and a bad transition from menu's music
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_intro:
; C3, 80 frames (including final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(29)
AUDIO_SILENCE(19)
; F2, 40 frames (including final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(9)
; G2, 40 frames (including final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(9)

; C3, 80 frames (including final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(29)
AUDIO_SILENCE(19)
; F2, 40 frames (including final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(9)
; G2, 40 frames (including final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(9)

; C3, 80 frames (including final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(29)
AUDIO_SILENCE(19)
; F2, 40 frames (including final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(9)
; G2, 40 frames (including final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(9)

; C3, 80 frames - 1 frame (no final silence)
AUDIO_SILENCE(29)
AUDIO_SILENCE(29)
AUDIO_SILENCE(18)

SAMPLE_END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ftm file - $02a0 triangle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_helicopter:
TIMED_O3_F(0)
TIMED_O3_C(0)
;TIMED_O2_G(0) ; Removed to have 5 frames per quarter note (pal timing)
TIMED_O2_E(0)
TIMED_O2_D(0)
TIMED_O1_B(0)

TIMED_O3_F(0)
TIMED_O3_C(0)
;TIMED_O2_G(0) ; Removed to have 5 frames per quarter note (pal timing)
TIMED_O2_E(0)
TIMED_O2_D(0)
TIMED_O1_B(0)

TIMED_O3_F(0)
TIMED_O3_C(0)
;TIMED_O2_G(0) ; Removed to have 5 frames per quarter note (pal timing)
TIMED_O2_E(0)
TIMED_O2_D(0)
TIMED_O1_B(0)

TIMED_O3_F(0)
TIMED_O3_C(0)
;TIMED_O2_G(0) ; Removed to have 5 frames per quarter note (pal timing)
TIMED_O2_E(0)
TIMED_O2_D(0)
;TIMED_O1_B(0) ; Removed to take acount of SAMPLE_END taking one tick

; Repeated 16 times in the file (4 times in the sample)

SAMPLE_END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ftm file - $0300 triangle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_bass_c3_x4:

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_C(8)

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_C(8)

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_C(8)

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_C(7)

SAMPLE_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ftm file - $0360 triangle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_bass_f2_x2:

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_F(8)

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_F(7)

SAMPLE_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ftm file - $0390 triangle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_bass_g2_x2:

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_G(8)

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_G(7)

SAMPLE_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ftm file - $0000 triangle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_bass_a2_x4:

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_A(8)

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_A(8)

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_A(8)

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)
TIMED_O2_A(7)

SAMPLE_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ftm file - $0600 triangle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_bass2_f2_x4:

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O2_F(8)

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O2_F(8)

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O2_F(8)

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O2_F(7)

SAMPLE_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ftm file - $0660 triangle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_bass2_g2_x4:

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O2_G(8)

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O2_G(8)

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O2_G(8)

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O2_G(7)

SAMPLE_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ftm file - $0b40 triangle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_bass2_c3_x4:

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O3_C(8)

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O3_C(8)

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O3_C(8)

AUDIO_SILENCE(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
;TIMED_O1_F(0) ; removed for pal timing
TIMED_O1_E(0)
TIMED_O1_D(0)
AUDIO_SILENCE(0)
TIMED_O3_C(7)

SAMPLE_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ftm file - $1680 triangle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

theme_main_triangle_epilog:

TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)

TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(HALF_NOTE-1-1)
AUDIO_SILENCE(0)

; ftm file - $16e1

TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1-1)
AUDIO_SILENCE(0)

TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1-1)
AUDIO_SILENCE(0)

TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1-1)
AUDIO_SILENCE(0)

; ftm file - $17a1

TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(FULL_NOTE-1-1)
AUDIO_SILENCE(0)

TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(FULL_NOTE-1-1)
TIMED_O3_A(0)
TIMED_O3_D(0)
TIMED_O2_B(0)
TIMED_O2_G(0)
TIMED_O2_E(0)
;TIMED_O2_C(0) ; removed for pal timing
TIMED_O1_B(0)
TIMED_O1_A(0)
TIMED_O1_G(0)
TIMED_O1_F(0)
AUDIO_SILENCE(1)

TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(HALF_NOTE-1-1)
AUDIO_SILENCE(0)

; ftm file $1861

TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1-1)
AUDIO_SILENCE(0)

TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1-1)
AUDIO_SILENCE(0)

TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1)
TIMED_O2_G(FULL_NOTE-1-1)
AUDIO_SILENCE(0)

; ftm file $1921

TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(FULL_NOTE-1-1)
AUDIO_SILENCE(0)

; Making arangements for looping gracefully,
; this part intentionally differs from the original

TIMED_O3_C(FULL_NOTE-1)
TIMED_O3_C(FULL_NOTE-1-1)
AUDIO_SILENCE(0)

AUDIO_SILENCE(FULL_NOTE-1)
AUDIO_SILENCE(HALF_NOTE-1-1)

; ftm file - $19a5

SAMPLE_END
