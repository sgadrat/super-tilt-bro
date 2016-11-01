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

; reload PPU OAM (Objects Attributes Memory) with fresh data from cpu memory
lda #$00
sta OAMADDR
lda #$02
sta OAMDMA

; Copy nametable buffers to PPU nametable
; A nametable buffer has the following pattern:
;   continuation (1 byte), address (2 bytes), number of tiles (1 byte), tiles (N bytes)
;   continuation - 1 there is a buffer, 0 work done
;   address - address where to write in PPU address space (big endian)
;   number of tiles - Number of tiles in this buffer
;   tiles - One byte per tile, representing the tile number
.(
ldx #$00
handle_nt_buffer:

lda nametable_buffers, x ; Check continuation byte
beq end_buffers          ;
inx                      ;

lda PPUSTATUS            ; Set PPU destination address
lda nametable_buffers, x ;
sta PPUADDR              ;
inx                      ;
lda nametable_buffers, x ;
sta PPUADDR              ;
inx                      ;

lda nametable_buffers, x ; Save tiles counter to tmpfield1
sta tmpfield1            ;
inx                      ;

write_one_tile:
lda tmpfield1            ; Check if there is still a tile to write
beq handle_nt_buffer     ;

lda nametable_buffers, x ; Write current tile to PPU
sta PPUDATA              ;

dec tmpfield1            ; Next tile
inx                      ;
jmp write_one_tile       ;

end_buffers:
.)

; no scroll
lda #$00
sta PPUSCROLL
sta PPUSCROLL

; Inform that NMI is handled
lda #$00
sta nmi_processing

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

; Point PPU to Background palette 0 (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
lda PPUSTATUS
lda #$3f
sta PPUADDR
lda #$00
sta PPUADDR

; Write palette_data in actual ppu palettes
ldx $00
copy_palette:
lda palette_data, x
sta PPUDATA
inx
cpx #$20
bne copy_palette

; Copy background from PRG-rom to PPU nametable
lda #<nametable
sta $40
lda #>nametable
sta $41
lda PPUSTATUS
lda #$20
sta PPUADDR
lda #$00
sta PPUADDR
ldy #$00
load_background:
lda ($40), y
sta PPUDATA
inc $40
bne end_inc_vector
inc $41
end_inc_vector:
lda #<nametable_end
cmp $40
bne load_background
lda #>nametable_end
cmp $41
bne load_background

jsr init_game_state
jsr update_sprites

; Setup PPU
lda #%10010000
sta PPUCTRL
lda #%00011110
sta PPUMASK

forever:

jsr wait_next_frame
jsr fetch_controllers
jsr update_players
jsr update_sprites

jmp forever

#include "prg_rom/utils.asm"
#include "prg_rom/game.asm"
#include "prg_rom/player_states.asm"
#include "prg_rom/collisions.asm"
code_end:
data_begin:
#include "prg_rom/data/data.asm"
data_end:

;
; Credits in the rom
;

credits_begin:
.asc "Credits:",$0a
.asc "Authors:",$0a
.asc "    Sylvain Gadrat",$0a
.asc "Art sources:",$0a
.asc "    www.opengameart.org/content/bomb-party from Matt Hackett of Lost Decade Games",$0a
.asc "    www.opengameart.org/content/twin-dragons from Surt",$0a
.asc "    Sinbad from Zi Ye",$0a
.asc "Thanks:",$0a
.asc "    Benoît Ryder for dev-tools and gameplay feedbacks",$0a
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
