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

; Begin transition between screens
jsr pre_transition

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
bne check_title
jsr init_game_state
jmp end_initialization
check_title:
cmp #GAME_STATE_TITLE
bne check_gameover
jsr init_title_screen
jmp end_initialization
check_gameover:
cmp #GAME_STATE_GAMEOVER
bne check_credits
jsr init_gameover_screen
jmp end_initialization
check_credits:
cmp #GAME_STATE_CREDITS
bne check_config
jsr init_credits_screen
jmp end_initialization
check_config:
cmp #GAME_STATE_CONFIG
bne check_stage_selection
jsr init_config_screen
jmp end_initialization
check_stage_selection:
cmp #GAME_STATE_STAGE_SELECTION
bne check_character_selection
jsr init_stage_selection_screen
jmp end_initialization
check_character_selection:
jsr init_character_selection_screen
end_initialization:

; Do transition between screens (and reactivate rendering)
jsr post_transition

; Clear stack
ldx #$ff
txs

; Go straight to the main loop
jmp forever

; Compute the current transition id (previous game state << 4 + new game state)
get_transition_id:
.(
lda previous_global_game_state
asl
asl
asl
asl
adc global_game_state
rts
.)

; Get the direction of the transition between the previous game state and the new one
;  Return 0, 1 or 2 in in register A
;   0 - No transition
;   1 - Scrolling down
;   2 - Scrolling up
;
; Overwrites register X, tmpfield1
find_transition_direction:
.(
transition_id = tmpfield1

; Compute transition id
jsr get_transition_id
sta transition_id

; Find the transition in transition to direction table
ldx #0
check_one_transition:
lda state_transition, x
cmp transition_id
beq found_transition
inx
cpx #8
bne check_one_transition

; Not found, return 0
lda #0
jmp end

; Found, return value from table
found_transition:
lda state_transition_orientation, x

end:
rts

#define STATE_TRANSITION(previous,new) previous * 16 + new
state_transition:
.byt STATE_TRANSITION(GAME_STATE_TITLE, GAME_STATE_CONFIG)
.byt STATE_TRANSITION(GAME_STATE_CONFIG, GAME_STATE_TITLE)
.byt STATE_TRANSITION(GAME_STATE_TITLE, GAME_STATE_CREDITS)
.byt STATE_TRANSITION(GAME_STATE_CREDITS, GAME_STATE_TITLE)
.byt STATE_TRANSITION(GAME_STATE_CONFIG, GAME_STATE_CHARACTER_SELECTION)
.byt STATE_TRANSITION(GAME_STATE_CHARACTER_SELECTION, GAME_STATE_CONFIG)
.byt STATE_TRANSITION(GAME_STATE_CHARACTER_SELECTION, GAME_STATE_STAGE_SELECTION)
.byt STATE_TRANSITION(GAME_STATE_STAGE_SELECTION, GAME_STATE_CHARACTER_SELECTION)
state_transition_orientation:
.byt 1
.byt 2
.byt 1
.byt 2
.byt 1
.byt 2
.byt 1
.byt 2
.)

; Called before initialization routine, for transition effects
pre_transition:
.(
; Avoid working if there is no transition
jsr find_transition_direction
cmp #0
beq end

lda #0
sta tmpfield3
sta tmpfield4
jsr scroll_transition

lda #%10010010
sta ppuctrl_val
lda #0
sta scroll_y

end:
rts
.)

; Called after initialization routine, for transition effects
post_transition:
.(
lda #2
sta tmpfield3
lda #1
sta tmpfield4
jsr scroll_transition

lda #%10010000
sta ppuctrl_val
lda #0
sta scroll_y

rts
.)

; Transition by scrolling between two screen, keeping menus clouds
;  tmpfield3 - origin screen 0 for top nametable, 2 for bottom one
;  tmpfield4 - sprites are from starting or destination screen (0 - starting screen ; 1 - destination screen)
scroll_transition:
.(
screen_sprites_offset_lsb = tmpfield1
screen_sprites_offset_msb = tmpfield2
origin_nametable = tmpfield3
offset_sprites = tmpfield4

; Compute values dependent of the direction
jsr find_transition_direction
beq skip_scrolling
cmp #1
bne set_up_values

lda origin_nametable ;
ora #%10010000       ; Reactivate NMI, place scrolling on origin nametable
sta ppuctrl_val      ;
lda #240
sta screen_sprites_offset_lsb
lda #0
sta screen_sprites_offset_msb
lda #$fd
pha      ; cloud_scroll_lsb
lda #$ff
pha      ; cloud_scroll_msb
lda #10
pha      ; scroll_step
lda #0
pha      ; scroll_begin
lda #240
pha      ; scroll_end
jmp end_set_values

set_up_values:
lda origin_nametable ;
eor #%00000010       ; Reactivate NMI, place scrolling on destination nametable
ora #%10010000       ;
sta ppuctrl_val      ;
lda #$10
sta screen_sprites_offset_lsb
lda #$ff
sta screen_sprites_offset_msb
lda #$3
pha      ; cloud_scroll_lsb
lda #$0
pha      ; cloud_scroll_msb
lda #$f6
pha      ; scroll_step
lda #240
pha      ; scroll_begin
lda #0
pha      ; scroll_end
jmp end_set_values

skip_scrolling:
lda #%10010010  ;
sta ppuctrl_val ; Reactivate NMI
sta PPUCTRL     ;
jsr sleep_frame  ; Avoid re-enabling mid-frame
lda #%00011110 ; Enable sprites and background rendering
sta PPUMASK    ;
jmp end

end_set_values:

; Avoid to offset sprites when starting from drawn screen
lda offset_sprites
bne do_not_touch_offsets
lda #0
sta screen_sprites_offset_lsb
sta screen_sprites_offset_msb
do_not_touch_offsets:

; Save sprites y positions as 2 bytes values (to be able to go offscreen)
ldx #0 ; OAM offset
ldy #0 ; Sprite index
save_one_sprite:

lda oam_mirror, x             ;
clc                           ;
adc screen_sprites_offset_lsb ;
sta screen_sprites_y_lsb, y   ; Store sprite's two bytes y position
lda screen_sprites_offset_msb ;
adc #0                        ;
sta screen_sprites_y_msb, y   ;

lda #$fe          ; Hide sprite
sta oam_mirror, x ; (even cloud sprites, they already blink due to disabling rendering anyway)

iny                 ;
inx                 ;
inx                 ; Next sprite
inx                 ;
inx                 ;
bne save_one_sprite ;

; Enable rendering
lda ppuctrl_val
sta PPUCTRL
tsx            ;
lda stack+2, x ; set scrolling to scroll_begin
cmp #240       ;
bne set_scroll ;
lda #239       ;
set_scroll     ;
sta scroll_y   ;
jsr sleep_frame  ; Avoid re-enabling mid-frame
lda #%00011110 ; Enable sprites and background rendering
sta PPUMASK    ;

; Scroll to the next screen
tsx
lda stack+2, x ; scroll_begin

scroll_frame:
sta scroll_y

cmp #240       ;
bne no_correct ;
lda #239       ; Avoid scrolling of 240 which is more "before 0" than "after 239"
sta scroll_y   ;
lda #240       ;
no_correct:    ;

clc
tsx
adc stack+3, x ; scroll_step

pha
jsr sleep_frame
jsr move_sprites
pla

tsx
cmp stack+1, x ; scroll_end
bne scroll_frame

clean:
pla ; scroll_end
pla ; scroll_begin
pla ; scroll_step
pla ; cloud_scroll_msb
pla ; cloud_scroll_lsb

end:
rts
.)

move_sprites:
.(
screen_sprites_end = tmpfield1
scroll_y_msb = tmpfield2

; Choose if clouds need to be updated
jsr get_transition_id
cmp #STATE_TRANSITION(GAME_STATE_TITLE, GAME_STATE_CONFIG)
beq update_clouds
cmp #STATE_TRANSITION(GAME_STATE_CONFIG, GAME_STATE_TITLE)
beq update_clouds
cmp #STATE_TRANSITION(GAME_STATE_CONFIG, GAME_STATE_CHARACTER_SELECTION)
beq update_clouds
cmp #STATE_TRANSITION(GAME_STATE_CHARACTER_SELECTION, GAME_STATE_CONFIG)
beq update_clouds

; Clouds do not need to be updated
lda #64                ; All sprites are from the destination screen
sta screen_sprites_end ;

jmp update_screen_sprites

; Clouds need to be updated
update_clouds:
tsx                              ;
ldy #MENU_COMMON_NB_CLOUDS-1     ;
vertical_one_cloud:              ;
lda menu_common_cloud_1_y, y     ;
clc                              ;
adc stack + 2 + 1 + 5, x         ; Update clouds Y position
sta menu_common_cloud_1_y, y     ; based on cloud_scroll_lsb and cloud_scroll_msb from our caller
lda menu_common_cloud_1_y_msb, y ;
adc stack + 2 + 1 + 4, x         ;
sta menu_common_cloud_1_y_msb, y ;
dey                              ;
bpl vertical_one_cloud           ;

jsr tick_menu ; Update horizontal clouds position
jsr menu_position_clouds ; Force refresh of cloud sprites

lda #64 - MENU_COMMON_NB_CLOUDS * MENU_COMMON_NB_SPRITE_PER_CLOUD ; Only sprites before clouds are from destination screen
sta screen_sprites_end                                            ;

; Move destination screen sprites
update_screen_sprites:

tsx                      ;
lda stack + 2 + 1 + 3, x ;
bpl positive             ;
lda #0                   ;
jmp set_scroll_y_msb     ; Compute MSB of a 16-bit "-1 * scroll_y"
positive:                ;
lda #$ff                 ;
set_scroll_y_msb:        ;
sta scroll_y_msb         ;

ldy #0 ; Current sprite index
move_one_screen_sprite:

tsx                         ;
lda stack + 2 + 1 + 3, x    ;
eor #%11111111              ;
clc                         ;
adc #1                      ;
clc                         ; Scroll 16-bit sprite's position
adc screen_sprites_y_lsb, y ;
sta screen_sprites_y_lsb, y ;
lda screen_sprites_y_msb, y ;
adc scroll_y_msb            ;
sta screen_sprites_y_msb, y ;

cmp #0                      ;
bne hide_sprite             ;
                            ;
lda screen_sprites_y_lsb, y ; Compute updated position of the OAM sprite
jmp update_oam              ;
                            ;
hide_sprite:                ;
lda #$fe                    ;

update_oam:       ;
pha               ;
tya               ;
asl               ; Update OAM sprite
asl               ;
tax               ;
pla               ;
sta oam_mirror, x ;

iny                        ; Next sprite
cpy screen_sprites_end     ;
bne move_one_screen_sprite ;

end:
rts
.)

sleep_frame:
.(
jsr wait_next_frame
jsr audio_music_tick
rts
.)
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
