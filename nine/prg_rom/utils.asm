fetch_controllers:
.(
; Fetch controllers state
lda #$01
sta CONTROLLER_A
lda #$00
sta CONTROLLER_A

; x will contain the controller number to fetch (0 or 1)
ldx #$00

fetch_one_controller:

; Save previous state of the controller
lda controller_a_btns, x
sta controller_a_last_frame_btns, x

; Reset the controller's byte
lda #$00
sta controller_a_btns, x

; Fetch the controller's byte button by button
ldy #$08
next_btn:
lda CONTROLLER_A, x
lsr
rol controller_a_btns, x
dey
bne next_btn

; Next controller
inx
cpx #$02
bne fetch_one_controller

rts
.)

; Wait the next 50Hz frame, returns once NMI is complete
;  May skip frames to ensure a 50Hz average
wait_next_frame:
.(
jsr wait_next_real_frame

; On 60Hz systems, wait an extra frame every 6 frames to slow down
lda skip_frames_to_50hz
beq end

dec virtual_frame_cnt
bpl end
lda #5
sta virtual_frame_cnt

jsr wait_next_real_frame

end:
rts
.)

; Wait the next frame, returns once NMI is complete
wait_next_real_frame:
.(
lda #$01
sta nmi_processing
waiting:
lda nmi_processing
bne waiting
rts
.)

; Perform multibyte signed comparison
;  tmpfield6 - a (low)
;  tmpfield7 - a (high)
;  tmpfield8 - b (low)
;  tmpfield9 - b (high)
;
; Output - N flag set if "a < b", unset otherwise
;          C flag set if "(unsigned)a < (unsigned)b", unset otherwise
; Overwrites register A
signed_cmp:
.(
; Trick from http://www.6502.org/tutorials/compare_beyond.html
a_low = tmpfield6
a_high = tmpfield7
b_low = tmpfield8
b_high = tmpfield9

lda a_low
cmp b_low
lda a_high
sbc b_high
bvc end
eor #%10000000
end:
rts
.)

; Change A to its absolute unsigned value
absolute_a:
.(
cmp #$00
bpl end
eor #%11111111
clc
adc #$01

end:
rts
.)

; Multiply tmpfield1 by tmpfield2 in tmpfield3
;  tmpfield1 - multiplicand (low byte)
;  tmpfield2 - multiplicand (high byte)
;  tmpfield3 - multiplier
;  Result stored in tmpfield4 (low byte) and tmpfield5 (high byte)
;
;  Overwrites register A, tmpfield4 and tmpfield5
multiply:
.(
multiplicand_low = tmpfield1
multiplicand_high = tmpfield2
multiplier = tmpfield3
result_low = tmpfield4
result_high = tmpfield5

; Save X, we do not want it to be altered by this subroutine
txa
pha

; Set multiplier to X to be used as a loop count
lda multiplier
tax

; Initialize result's value
lda #$00
sta result_low
sta result_high

additions_loop:
; Check if we finished
cpx #$00
beq end

; Add multiplicand to the result
lda result_low
clc
adc multiplicand_low
sta result_low
lda result_high
adc multiplicand_high
sta result_high

; Iterate until we looped "multiplier" times
dex
jmp additions_loop

end:
; Restore X
pla
tax

rts
.)

; Set register X to the offset of the continuation byte of the first empty
; nametable buffer
;
; Overwrites register A
last_nt_buffer:
.(
ldx #$00

handle_buff:

; Check continuation byte
lda nametable_buffers, x
beq end

; Point to the tiles counter
inx
inx
inx

; Add tile counts to X (effectively points on the last tile)
txa
clc
adc nametable_buffers, x
tax

; Next
inx
jmp handle_buff

end:
rts
.)

; Empty the list of nametable buffers
reset_nt_buffers:
.(
lda #$00
sta nametable_buffers
rts
.)

; Copy nametable buffers to PPU nametable
; A nametable buffer has the following pattern:
;   continuation (1 byte), address (2 bytes), number of tiles (1 byte), tiles (N bytes)
;   continuation - 1 there is a buffer, 0 work done
;   address - address where to write in PPU address space (big endian)
;   number of tiles - Number of tiles in this buffer
;   tiles - One byte per tile, representing the tile number
;
; Overwrites register X and tmpfield1
process_nt_buffers:
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
rts
.)

; Produce a list of three tile indexes representing a number
;  tmpfield1 - Number to represent
;  tmpfield2 - Destination address LSB
;  tmpfield3 - Destionation address MSB
;
;  Overwrites timfield1, timpfield2, tmpfield3, tmpfield4, tmpfield5, tmpfield6
;  and all registers.
number_to_tile_indexes:
.(
number = tmpfield1
destination = tmpfield2
coefficient = tmpfield4
digit_value = tmpfield5
next_multiple = tmpfield6

; Start with a coefficient of 100 to find hundred's digit
lda #100
sta coefficient

find_one_digit:

; Reset internal counters
lda #$00
sta digit_value
lda coefficient
sta next_multiple

try_digit_value:

; Check if next multiple value is greater than the number
lda number
cmp next_multiple
bcs next_digit_value

; Next multiple value is greater than the number, we found this digit
lda TILENUM_NT_CHAR_0 ; Store the corresponding tile number at destination
clc                   ;
adc digit_value       ;
ldy #$00              ;
sta (destination), y  ;

                      ; Keep only the modulo in number
lda next_multiple     ; -.
sec                   ;  | Remove one time coefficient to next_multiple, so
sbc coefficient       ;  | next_multiple equals to "digit_value * coefficient"
sta next_multiple     ; -*
lda number            ; -.
sec                   ;  | "number = number - (digit_value * coefficient)"
sbc next_multiple     ;  | That's actually the modulo of "number / coefficient"
sta number            ; -*

lda coefficient        ; Set next coefficient
cmp #100               ;  100 -> 10
bne test_coeff_10      ;   10 ->  1
lda #10                ;    1 -> we found the last digit
sta coefficient        ;
jmp coefficent_changed ;
test_coeff_10:         ;
cmp #10                ;
bne end                ;
lda #1                 ;
sta coefficient        ;
jmp coefficent_changed ;
coefficent_changed:    ;

inc destination         ; Update destination address
bne destination_updated ;
inc destination+1       ;
destination_updated:    ;

jmp find_one_digit

; Next multiple value is lower or equal to the number,
; increase digit value, update next_multiple and recheck
next_digit_value:
inc digit_value
lda next_multiple
clc
adc coefficient
sta next_multiple
jmp try_digit_value

end:
rts
.)

; Indicate that the input modification on this frame has not been consumed
keep_input_dirty:
.(
lda controller_a_last_frame_btns, x
sta controller_a_btns, x
rts
.)

; A routine doing nothing, it can be used as dummy entry in jump tables
dummy_routine:
.(
rts
.)

; Change the game's state
;  register A - new game state
;
; WARNING - This routine never returns. It changes the state then restarts the main loop.
change_global_game_state:
.(
; Save previous game state and set the global_game_state variable
tax
lda global_game_state
sta previous_global_game_state
txa
sta global_game_state

; Disable rendering
lda #$00
sta PPUCTRL
sta PPUMASK
sta ppuctrl_val

; Clear not processed drawings
jsr reset_nt_buffers

; Reset scrolling
lda #$00
sta scroll_x
sta scroll_y

; Reset particle handlers
jsr particle_handlers_reinit

; Move all sprites offscreen
ldx #$00
clr_sprites:
lda #$FE
sta oam_mirror, x    ;move all sprites off screen
inx
bne clr_sprites

; Call the appropriate initialization routine
lda global_game_state
asl
tax
lda game_states_init, x
sta tmpfield1
lda game_states_init+1, x
sta tmpfield2
jsr call_pointed_subroutine

; Enable rendering
lda #%10010000  ;
sta ppuctrl_val ; Reactivate NMI
sta PPUCTRL     ;
jsr wait_next_frame ; Avoid re-enabling mid-frame
lda #%00011110 ; Enable sprites and background rendering
sta PPUMASK    ;

; Clear stack
ldx #$ff
txs

; Go straight to the main loop
jmp forever
.)

; Copy a compressed nametable to PPU
;  tmpfield1 - compressed nametable address (low)
;  tmpfield2 - compressed nametable address (high)
;
; Overwrites all registers, tmpfield1 and tmpfield2
draw_zipped_nametable:
.(
compressed_nametable = tmpfield1

lda PPUSTATUS
lda #$20
sta PPUADDR
lda #$00
sta PPUADDR
ldy #$00

load_background:
lda (compressed_nametable), y
beq opcode

; Standard byte, just write it to PPUDATA
sta PPUDATA
jsr next_byte
jmp load_background

; Got the opcode
opcode:
jsr next_byte                 ;
lda (compressed_nametable), y ; Load parameter in a, if it is zero it means that
beq end                       ; the nametable is over

tax                ;
lda #$00           ;
write_one_byte:    ; Write 0 the number of times specified by parameter
sta PPUDATA        ;
dex                ;
bne write_one_byte ;

jsr next_byte       ; Continue reading the table
jmp load_background ;

end:
rts

next_byte:
.(
inc compressed_nametable
bne end_inc_vector
inc compressed_nametable+1
end_inc_vector:
rts
.)
.)

; Allows to inderectly call a pointed subroutine normally with jsr
;  tmpfield1,tmpfield2 - subroutine to call
call_pointed_subroutine:
.(
jmp (tmpfield1)
.)

; Copy a palette from a palettes table to the ppu
;  register X - PPU address LSB (MSB is fixed to $3f)
;  tmpfield1 - palette number in the table
;  tmpfield2, tmpfield3 - table's address
;
;  Overwrites registers
copy_palette_to_ppu:
.(
palette_index = tmpfield1
palette_table = tmpfield2

lda PPUSTATUS
lda #$3f
sta PPUADDR
txa
sta PPUADDR

lda palette_index
asl
;clc ; useless, asl shall not overflow
adc palette_index
tay
ldx #3
copy_one_color:
lda (palette_table), y
sta PPUDATA
iny
dex
bne copy_one_color
rts
.)

shake_screen:
.(
; Change scrolling possition a little
lda screen_shake_nextval_x
eor #%11111111
clc
adc #1
sta screen_shake_nextval_x
sta scroll_x
lda screen_shake_nextval_y
eor #%11111111
clc
adc #1
sta screen_shake_nextval_y
sta scroll_y

; Adapt screen number to Y scrolling
;  Litle negative values are set at the end of screen 2
lda scroll_y
cmp #240
bcs set_screen_two
lda #%10010000
jmp set_screen
set_screen_two:
clc
adc #240
sta scroll_y
lda #%10010010
set_screen:
sta ppuctrl_val

; Decrement screen shake counter
dec screen_shake_counter
bne end

; Shaking is over, reset the scrolling
lda #$00
sta scroll_y
sta scroll_x
lda #%10010000
sta ppuctrl_val

end:
rts
.)
