cursed:
rti

nmi:
.(
; Save CPU registers
php
pha
txa
pha
tya
pha

; Do not draw anything if not ready
lda nmi_processing
beq end

; reload PPU OAM (Objects Attributes Memory) with fresh data from cpu memory
lda #$00
sta OAMADDR
lda #$02
sta OAMDMA

; Rewrite nametable based on nt_buffers
jsr process_nt_buffers

; Scroll
lda ppuctrl_val
sta PPUCTRL
lda PPUSTATUS
lda scroll_x
sta PPUSCROLL
lda scroll_y
sta PPUSCROLL

; Inform that NMI is handled
lda #$00
sta nmi_processing

end:

; Restore CPU registers
pla
tay
pla
tax
pla
plp

rti
.)

reset:

sei               ; disable IRQs
ldx #$40
cld               ; disable decimal mode
stx APU_FRAMECNT  ; disable APU frame IRQ
ldx #$FF
txs               ; Set up stack
inx               ; now X = 0
stx PPUCTRL       ; disable NMI
stx ppuctrl_val   ;
stx PPUMASK       ; disable rendering
stx APU_DMC_FLAGS ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
bit PPUSTATUS
bpl vblankwait1

clrmem:
lda #$00
sta $0000, x
sta $0100, x
sta $0300, x
sta $0400, x
sta $0500, x
sta $0600, x
sta $0700, x
lda #$FE
sta oam_mirror, x    ;move all sprites off screen
inx
bne clrmem

; Wait a second vblank
;  PPU may need 2 frames to warm-up
;  We use it to count cycles between frames (strong indicator of PAL versus NTSC)
.(
ldy #0
ldx #0
vblankwait2:
inx
bne ok
iny
ok:
bit PPUSTATUS
bpl vblankwait2

; Y*256+X known values:
;  $05b1 - FCEUX on NTSC mode
;  $06d2 - FCEUX on PAL mode
;  $078b - FCEUX on Dendy mode
cpy #$06
bcs pal
lda #1
sta skip_frames_to_50hz
pal:
.)

jsr audio_init
jsr global_init

lda #INITIAL_GAME_STATE
jsr change_global_game_state

forever:
.(
; Call common routines to all states
jsr wait_next_real_frame ;TODO hack to test audio ngine on NTSC
jsr audio_music_tick
jsr fetch_controllers

; Tick current game state
lda global_game_state
asl
tax
lda game_states_tick, x
sta tmpfield1
lda game_states_tick+1, x
sta tmpfield2
jsr call_pointed_subroutine

jmp forever
.)

#include "nine/prg_rom/utils.asm"
#include "nine/prg_rom/animations.asm"
#include "nine/prg_rom/collisions.asm"
ninegine_audio_engine_begin:
#if 0
;TODO remove old audio engine
#include "nine/prg_rom/audio.asm"
#else
#include "nine/prg_rom/audio2.asm"
#endif
ninegine_audio_engine_end:
#include "nine/prg_rom/particle.asm"
#include "nine/prg_rom/particle_handlers.asm"
