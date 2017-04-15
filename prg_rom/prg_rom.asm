* = $C000 ; $C000 is where the PRG rom is mapped in CPU space, so code position is relative to it

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
cld               ; disable decimal mode
ldx #$40
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

vblankwait2:      ; Second wait for vblank, PPU is ready after this
bit PPUSTATUS
bpl vblankwait2

jsr default_config
jsr audio_init

lda #GAME_STATE_TITLE
sta global_game_state
jsr change_global_game_state

; Setup PPU
lda #%10010000
sta ppuctrl_val
sta PPUCTRL
lda #%00011110
sta PPUMASK

forever:
.(
; Call common routines to all states
jsr wait_next_frame
jsr audio_music_tick
jsr fetch_controllers

; Call routines apropriation for the current game state
lda global_game_state
bne check_title
jsr game_tick ; In game
jmp forever   ;
check_title:
cmp #GAME_STATE_TITLE
bne check_gamover
jsr title_screen_tick ; Title screen
jmp forever           ;
check_gamover:
cmp #GAME_STATE_GAMEOVER
bne check_credits
jsr gameover_screen_tick
jmp forever
check_credits:
cmp #GAME_STATE_CREDITS
bne check_config
jsr credits_screen_tick
jmp forever
check_config:
jsr config_screen_tick
jmp forever
.)

#include "prg_rom/utils.asm"
#include "prg_rom/game.asm"
#include "prg_rom/player_states.asm"
#include "prg_rom/collisions.asm"
#include "prg_rom/audio.asm"
#include "prg_rom/title_screen.asm"
#include "prg_rom/config_screen.asm"
#include "prg_rom/gameover_screen.asm"
#include "prg_rom/credits_screen.asm"
#include "prg_rom/ai.asm"
code_end:
data_begin:
#include "prg_rom/data/data.asm"
data_end:

;
; Credits in the rom
;

credits_begin:
.asc "             credits",$0a
.asc $0a
.asc "             authors",$0a
.asc $0a
.asc "sylvain gadrat",$0a
.asc $0a
.asc "           art sources",$0a
.asc $0a
.asc "bomb party", $0a 
.asc "    by matt hackett of", $0a
.asc "    lost decade games",$0a
.asc "twin dragons",$0a
.asc "    by surt", $0a
.asc "sinbad",$0a
.asc "    by zi ye",$0a
.asc "perihelium",$0a
.asc "    by ozzed"
.asc $0a
.asc "             thanks",$0a
.asc $0a
.asc "benoit ryder",$0a
.byt $00
credits_end:

;
; Print some PRG-ROM space usage information
;

#echo PRG-ROM total space:
#print $10000-$C000
#echo PRG-ROM code size:
#print code_end-$C000
#echo PRG-ROM data size:
#print data_end-data_begin
#echo PRG-ROM credits size:
#print credits_end-credits_begin
#echo PRG-ROM free space:
#print $fffa-*

;
; Fill code bank and set entry points vectors (also from nesmine)
;

#if $fffa-* < 0
#echo *** Error: Code occupies too much space
#else
.dsb $fffa-*, 0     ;aligning
.word nmi           ;entry point for VBlank interrupt  (NMI)
.word reset         ;entry point for program start     (RESET)
.word cursed        ;entry point for masking interrupt (IRQ)
#endif
