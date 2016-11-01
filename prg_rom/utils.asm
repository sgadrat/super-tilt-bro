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

wait_next_frame:
.(
lda #$01
sta nmi_processing
waiting:
lda nmi_processing
bne waiting
rts
.)

; Add a vector to the player's velocity
;  X - player number
;  Stack#0 - Y component of the vector to add (low byte)  ; pop first
;  Stack#1 - Y component of the vector to add (high byte)
;  Stack#2 - X component of the vector to add (low byte)
;  Stack#3 - X component of the vector to add (high byte) ; push first
add_to_player_velocity:
.(
; Save the return address
pla
sta tmpfield1
pla
sta tmpfield2

; Count iterations, one per vector's component
ldy #$00

add_component:

; Add the component to the player's velocity
pla
clc
adc player_a_velocity_v_low, x
sta player_a_velocity_v_low, x
pla
adc player_a_velocity_v, x
sta player_a_velocity_v, x

; Handle next component
inx
inx
iny
cpy #$02
bne add_component
dex
dex
dex
dex

; Restore return addr on stack and return
lda tmpfield2
pha
lda tmpfield1
pha
rts
.)

; Change the player's velocity to be closer to a vector
;  X - player number
;  tmpfield1 - Y component of the vector to merge (low byte)
;  tmpfield2 - X component of the vector to merge (low byte)
;  tmpfield3 - Y component of the vector to merge (high byte)
;  tmpfield4 - X component of the vector to merge (high byte)
;  tmpfield5 - Step size
;
; Overwrites register Y, tmpfield6, tmpfield7, tmpfield8 and tmpfield9
merge_to_player_velocity:
.(
merged_components_lows = tmpfield1
merged_components_highs = tmpfield3
step_size = tmpfield5
player_velocity_low = tmpfield6
player_velocity_high = tmpfield7
current_component_low = tmpfield8
current_component_high = tmpfield9

; Count iterations, one per vector's component
ldy #$00

add_component:
; Avoid to pass through merged velocity
lda player_a_velocity_v_low, x ;
sec                            ;
sbc merged_components_lows, y  ; Get difference between player's velocity
sta tmpfield8                  ; component and merged component
lda player_a_velocity_v, x     ;
sbc merged_components_highs, y ;

bpl check_diff                 ;
eor #%11111111                 ;
sta tmpfield9                  ;
lda tmpfield8                  ;
eor #%11111111                 ; Make the difference absolute
clc                            ;
adc #$01                       ;
sta tmpfield8                  ;
lda #$00                       ;
adc tmpfield9                  ;

check_diff:                    ;
cmp #$00                       ; Go add step_size if the difference is superior
bne add_step_size              ; (or equal) than step_size
lda tmpfield8                  ;
cmp step_size                  ; Note - diference is in register A (high byte)
bcs add_step_size              ; and tmpfield8 (low byte). tmpfield9 is garbage.

lda merged_components_lows, y  ;
sta player_a_velocity_v_low, x ; Rewrite player velocity's component with merged
lda merged_components_highs, y ; and got to next component
sta player_a_velocity_v, x     ;
jmp next_component             ;

; Add or substract step size from velocity component to be closer to
; the merged component
add_step_size:
lda player_a_velocity_v_low, x ;
sta player_velocity_low        ;
lda player_a_velocity_v, x     ;
sta player_velocity_high       ;
lda merged_components_lows, y  ; Compare the merged vector to the current velocity
sta current_component_low      ;
lda merged_components_highs, y ;
sta current_component_high     ;
jsr signed_cmp                 ;
bpl decrement                  ;

lda step_size                  ;
clc                            ;
adc player_a_velocity_v_low, x ;
sta player_a_velocity_v_low, x ; Add step_size to velocity
lda #$00                       ;
adc player_a_velocity_v, x     ;
sta player_a_velocity_v, x     ;
jmp next_component

decrement:
lda player_a_velocity_v_low, x ;
sec                            ;
sbc step_size                  ;
sta player_a_velocity_v_low, x ; Substract step_size from velocity
lda player_a_velocity_v, x     ;
sbc #$00                       ;
sta player_a_velocity_v, x     ;

; Handle next component
next_component:
inx
inx
iny
cpy #$02
bne add_component
dex
dex
dex
dex

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

; Change A to it's absolute unsigned value
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


; Switch current player
;  register X - Current player number
;  Result is stored in register X
switch_selected_player:
.(
cpx #$00
beq select_player_b
dex
jmp end
select_player_b:
inx
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
