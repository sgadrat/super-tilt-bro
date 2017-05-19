init_game_state:
.(
; Clear background of nametable 2
.(
lda #$00
sta $40
sta $41
lda PPUSTATUS
lda #$28
sta PPUADDR
lda #$00
sta PPUADDR
load_background:
lda #$00
sta PPUDATA
inc $40
bne end_inc_vector
inc $41
end_inc_vector:
lda #$04
cmp $41
bne load_background
lda #$00
cmp $40
bne load_background
.)

; Call stage initialization routine
lda config_selected_stage
asl
tax
lda stages_init_routine, x
sta tmpfield1
lda stages_init_routine+1, x
sta tmpfield2
jsr call_pointed_subroutine

; Ensure game state is zero
ldx #$00
lda #$00
zero_game_state:
sta $00, x
inx
cpx #ZERO_PAGE_GLOBAL_FIELDS_BEGIN
bne zero_game_state

; Reset screen shaking
sta screen_shake_counter

; Setup logical game state to the game startup configuration
lda DIRECTION_LEFT
sta player_b_direction

lda DIRECTION_RIGHT
sta player_a_direction

lda HITBOX_DISABLED
sta player_a_hitbox_enabled
sta player_b_hitbox_enabled

ldx #0
position_player_loop:
lda stage_data+STAGE_HEADER_OFFSET_PAY_HIGH, x
sta player_a_y, x
lda stage_data+STAGE_HEADER_OFFSET_PAY_LOW, x
sta player_a_y_low, x
lda stage_data+STAGE_HEADER_OFFSET_PAX_HIGH, x
sta player_a_x, x
lda stage_data+STAGE_HEADER_OFFSET_PAX_LOW, x
sta player_a_x_low, x
inx
cpx #2
bne position_player_loop

lda #DEFAULT_GRAVITY
sta player_a_gravity
sta player_b_gravity
lda config_initial_stocks
sta player_a_stocks
sta player_b_stocks

ldx #$00
jsr start_standing_player
ldx #$01
jsr start_standing_player

; Move sprites according to the initial state
jsr update_sprites

; Change for ingame music
jsr audio_music_power

rts
.)

game_tick:
.(
; Shake screen and do nothing until shaking is over
lda screen_shake_counter
beq no_screen_shake
jsr shake_screen
rts
no_screen_shake:

; Process AI - this override controller B state
lda config_ai_enabled
beq end_ai
jsr ai_tick
end_ai:

; Update game state
jsr update_players

; Update screen
jsr update_sprites

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

update_players:
.(
; Remove processed nametable buffers
jsr reset_nt_buffers

; Decrement hitstun counters
ldx #$00
hitstun_one_player:
lda player_a_hitstun, x
beq hitstun_next_player
dec player_a_hitstun, x
hitstun_next_player:
inx
cpx #$02
bne hitstun_one_player

; Check hitbox collisions
ldx #$00
hitbox_one_player:
jsr check_player_hit
inx
cpx #$02
bne hitbox_one_player

; Update both players
ldx #$00 ; player number
update_one_player:

; Call the state update routine
lda #<sinbad_state_update_routines
sta tmpfield1
lda #>sinbad_state_update_routines
sta tmpfield2
jsr player_state_action

; Call the state input routine if input changed
lda controller_a_btns, x
cmp controller_a_last_frame_btns, x
beq end_input_event
lda #<sinbad_state_input_routines
sta tmpfield1
lda #>sinbad_state_input_routines
sta tmpfield2
jsr player_state_action
end_input_event:

; Call generic update routines
jsr move_player
jsr check_player_position
jsr write_player_damages
jsr player_effects

inx
cpx #$02
bne update_one_player

rts
.)

; Calls a subroutine depending on player's state
;  register X - Player number
;  tmpfield1 - Jump table address (low byte)
;  tmpfield2 - Jump table address (high bute)
player_state_action:
.(
jump_table = tmpfield1

; Convert player state number to vector address (relative to table begining)
lda player_a_state, x       ; Y = state * 2
asl                         ; (as each element is 2 bytes long)
tay                         ;

; Push the state's routine address to the stack
lda (jump_table), y
pha
iny
lda (jump_table), y
pha

; Return to the state's routine, it will itself return to player_state_action's caller
rts
.)

check_player_hit:
.(
current_player = tmpfield10
opponent_player = tmpfield11

; Store current player number
stx current_player

; Check that player's hitbox is enabled
lda player_a_hitbox_enabled, x
bne process_checks
jmp end
process_checks:

; Store current player's hitbox
lda player_a_hitbox_left, x
sta tmpfield1
lda player_a_hitbox_right, x
sta tmpfield2
lda player_a_hitbox_top, x
sta tmpfield3
lda player_a_hitbox_bottom, x
sta tmpfield4

; Switch current player to select the opponent
jsr switch_selected_player

; Store opponent player number
stx opponent_player

; If opponent's hitbox is enabled, check hitbox on hitbox collisions
lda player_a_hitbox_enabled, x
beq check_hitbox_hurtbox

; Store opponent's hitbox
lda player_a_hitbox_left, x
sta tmpfield5
lda player_a_hitbox_right, x
sta tmpfield6
lda player_a_hitbox_top, x
sta tmpfield7
lda player_a_hitbox_bottom, x
sta tmpfield8

; Check collisions between hitbox and hitbox
jsr boxes_overlap
lda tmpfield9
bne check_hitbox_hurtbox

; Play parry sound
jsr audio_play_parry

; Hitboxes collide, set opponent in thrown mode without momentum
lda #HITSTUN_PARRY_NB_FRAMES
sta player_a_hitstun, x
lda #$00
sta player_a_velocity_h, x
sta player_a_velocity_h_low, x
sta player_a_velocity_v, x
sta player_a_velocity_v_low, x
jsr start_thrown_player
lda #SCREENSHAKE_PARRY_INTENSITY
sta screen_shake_nextval_x
sta screen_shake_nextval_y
lda #SCREENSHAKE_PARRY_NB_FRAMES
sta screen_shake_counter
jmp end

check_hitbox_hurtbox:

; Store opponent's hurtbox
lda player_a_hurtbox_left, x
sta tmpfield5
lda player_a_hurtbox_right, x
sta tmpfield6
lda player_a_hurtbox_top, x
sta tmpfield7
lda player_a_hurtbox_bottom, x
sta tmpfield8

; Check collisions between hitbox and hurtbox
jsr boxes_overlap
lda tmpfield9
bne end

lda #<sinbad_state_onhurt_routines ;
sta tmpfield1                      ;
lda #>sinbad_state_onhurt_routines ; Fire on-hurt event
sta tmpfield2                      ;
jsr player_state_action            ;

end:
; Reset register X to the current player
ldx current_player
rts
.)

; Throw the hurted player depending on the hitbox hurting him
;  tmpfield10 - Player number of the striker
;  tmpfield11 - Player number of the stroke
;  register X - Player number of the stroke (equals to tmpfield11)
;
;  Can overwrite any register and any tmpfield except tmpfield10 and tmpfield11.
hurt_player:
.(
current_player = tmpfield10
opponent_player = tmpfield11

; Play hit sound
jsr audio_play_hit

; Apply force vector to the opponent
jsr apply_force_vector

; Apply damages to the opponent
ldx current_player
lda player_a_hitbox_damages, x ; Put hitbox damages in A
ldx opponent_player
clc                     ;
adc player_a_damages, x ;
cmp #200                ;
bcs cap_damages         ; Apply damages, capped to 199
jmp apply_damages:      ;
cap_damages:            ;
lda #199                ;
apply_damages:          ;
sta player_a_damages, x ;

; Set opponent to thrown state
jsr start_thrown_player

; Disable the hitbox to avoid multi-hits
ldx current_player
lda HITBOX_DISABLED
sta player_a_hitbox_enabled, x

rts
.)

; Apply force in current player's hitbox to it's opponent
;
; Overwrites every tmpfields except "current_player" and "opponent_player".
; Overwrites registers A and  X (set to the opponent player's number).
apply_force_vector:
.(
base_h_low = tmpfield6
base_h_high = tmpfield7
base_v_low = tmpfield8
base_v_high = tmpfield9
current_player = tmpfield10
opponent_player = tmpfield11
force_h = tmpfield12
force_v = tmpfield13
force_h_low = tmpfield14
force_v_low = tmpfield15
knockback_h_high = force_h    ; knockback_h reuses force_h memory location
knockback_h_low = force_h_low ; it is only writen after the last read of force_h
knockback_v_high = force_v     ; knockback_v reuses force_v memory location
knockback_v_low = force_v_low  ; it is only writen after the last read of force_v

; Apply force vector to the opponent
ldx current_player
lda player_a_hitbox_force_h, x     ;
sta force_h                        ;
lda player_a_hitbox_force_h_low, x ;
sta force_h_low                    ; Save force vector to a player independent
lda player_a_hitbox_force_v, x     ; location
sta force_v                        ;
lda player_a_hitbox_force_v_low, x ;
sta force_v_low                    ;
lda player_a_hitbox_base_knock_up_h_high, x ;
sta base_h_high                             ;
lda player_a_hitbox_base_knock_up_h_low, x  ;
sta base_h_low                              ; Save base knock up to a player independent
lda player_a_hitbox_base_knock_up_v_high, x ; location
sta base_v_high                             ;
lda player_a_hitbox_base_knock_up_v_low, x  ;
sta base_v_low                              ;
ldx opponent_player
lda player_a_damages, x ;
lsr                     ; Get force multiplier
lsr                     ; "damages / 4"
sta tmpfield3           ;
lda force_h     ;
sta tmpfield2   ;
lda force_h_low ;
sta tmpfield1   ;
jsr multiply    ; Compute horizontal knockback
lda base_h_low  ; "force_h * multiplier + base_h"
clc             ;
adc tmpfield4   ;
sta tmpfield4   ;
lda base_h_high ;
adc tmpfield5   ;
sta player_a_velocity_h, x     ;
lda tmpfield4                  ; Apply horizontal knockback
sta player_a_velocity_h_low, x ;
lda force_v      ;
sta tmpfield2    ;
lda force_v_low  ;
sta tmpfield1    ;
jsr multiply     ; Compute vertical knockback
lda base_v_low   ; "force_v * multiplier + base_v"
clc              ;
adc tmpfield4    ;
lda base_v_high  ;
adc tmpfield5    ;
sta player_a_velocity_v, x     ;
lda tmpfield4                  ; Apply vertical knockback
sta player_a_velocity_v_low, x ;

; Apply hitstun to the opponent
; hitstun duration = high byte of 2 * (abs(velotcity_v) + abs(velocity_h))
lda player_a_velocity_h, x     ;
bpl end_abs_kb_h               ;
lda player_a_velocity_h_low, x ;
eor #%11111111                 ;
clc                            ;
adc #$01                       ; knockback_h = abs(velocity_h)
sta knockback_h_low            ;
lda player_a_velocity_h, x     ;
eor #%11111111                 ;
adc #$00                       ;
end_abs_kb_h:                  ;
sta knockback_h_high           ;

lda player_a_velocity_v, x      ;
bpl end_abs_kb_v                ;
lda player_a_velocity_v_low, x  ;
eor #%11111111                  ;
clc                             ;
adc #$01                        ; knockback_v = abs(velocity_v)
sta knockback_v_low             ;
lda player_a_velocity_v, x      ;
eor #%11111111                  ;
adc #$00                        ;
end_abs_kb_v:                   ;
sta knockback_v_high            ;

lda knockback_h_low  ;
clc                  ;
adc knockback_v_low  ;
sta knockback_h_low  ; knockback_h = knockback_v + knockback_h
lda knockback_h_high ;
adc knockback_v_high ;
sta knockback_h_high ;

asl knockback_h_low     ;
lda knockback_h_high    ; Oponent player hitstun = high byte of 2 * knockback_h
rol                     ;
sta player_a_hitstun, x ;

; Start screenshake of duration = hitstun / 2
lsr
sta screen_shake_counter
lda player_a_velocity_h, x
sta screen_shake_nextval_x
lda player_a_velocity_v, x
sta screen_shake_nextval_y

rts
.)

; Move the player according to it's velocity and collisions with obstacles
;  register X - player number
;
;  When returning player's position is updated, tmpfield1 contains it's old X
;  and tmpfield2 contains it's old Y
move_player:
.(
old_x = tmpfield1 ; Not movable, return value and parameter of check_collision
old_y = tmpfield2 ; Not movable, return value and parameter of check_collision
final_x_low = tmpfield9 ; Not movable, parameter of check_collision
final_x_high = tmpfield3 ; Not movable, parameter of check_collision
final_y_low = tmpfield10 ; Not movable, parameter of check_collision
final_y_high = tmpfield4 ; Not movable, parameter of check_collision
obstacle_left = tmpfield5 ; Not movable, parameter of check_collision
obstacle_top = tmpfield6 ; Not movable, parameter of check_collision
obstacle_right = tmpfield7 ; Not movable, parameter of check_collision
obstacle_bottom = tmpfield8 ; Not movable, parameter of check_collision
action_vector = tmpfield14

; Save old position
lda player_a_x, x
sta old_x
lda player_a_y, x
sta old_y

; Apply velocity to position
lda player_a_velocity_h_low, x
clc
adc player_a_x_low, x
sta final_x_low
lda player_a_velocity_h, x
adc player_a_x, x
sta final_x_high

lda player_a_velocity_v_low, x
clc
adc player_a_y_low, x
sta final_y_low
lda player_a_velocity_v, x
adc player_a_y, x
sta final_y_high

; Check collisions with stage plaforms
ldy #0

check_platform_colision:
txa
pha
ldx stage_data+STAGE_OFFSET_PLATFORMS, y
lda platform_actions_low, x
sta action_vector
lda platform_actions_high, x
sta action_vector+1
pla
tax
jmp (action_vector)

end:
rts

end_platforms:
.(
jmp end
.)

solid_platform_collision:
.(
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_LEFT, y
sta obstacle_left
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_TOP, y
sta obstacle_top
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_RIGHT, y
sta obstacle_right
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_BOTTOM, y
sta obstacle_bottom

jsr check_collision
lda final_x_high
sta player_a_x, x
lda final_y_high
sta player_a_y, x
lda final_x_low
sta player_a_x_low, x
lda final_y_low
sta player_a_y_low, x

tya
clc
adc #STAGE_PLATFORM_LENGTH
tay
jmp check_platform_colision
.)

smooth_platform_collision:
.(
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_LEFT, y
sta obstacle_left
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_TOP, y
sta obstacle_top
lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_RIGHT, y
sta obstacle_right

jsr check_top_collision
lda final_x_high
sta player_a_x, x
lda final_y_high
sta player_a_y, x
lda final_x_low
sta player_a_x_low, x
lda final_y_low
sta player_a_y_low, x

tya
clc
adc #STAGE_SMOOTH_PLATFORM_LENGTH
tay
jmp check_platform_colision
.)

platform_actions_low:
.byt <end_platforms
.byt <solid_platform_collision
.byt <smooth_platform_collision
platform_actions_high:
.byt >end_platforms
.byt >solid_platform_collision
.byt >smooth_platform_collision
.)

; Check the player's position and modify the current state accordingly
;  register X - player number
;  tmpfield1 - player's old X
;  tmpfield2 - player's old Y
;
;  Overwrites tmpfield1 and tmpfield2
check_player_position:
.(
old_x = tmpfield1
old_y = tmpfield2

; Check death
lda player_a_velocity_h, x
bpl check_right_blast
lda old_x           ; Horizontal velocity is negative
cmp player_a_x, x   ; die if "old X < new X"
bcc set_death_state ;
jmp check_vertical_blasts
check_right_blast:
lda player_a_x, x   ; Horizontal velocity is positive
cmp old_x           ; die if "new X < old X"
bcc set_death_state ;
check_vertical_blasts:
lda player_a_velocity_v, x
bpl check_bottom_blast
lda old_y           ; Vertical velocity is negative
cmp player_a_y, x   ; die if "old Y < new Y"
bcc set_death_state ;
jmp end_death_checks
check_bottom_blast:
lda player_a_y, x   ; Vertical velocity is positive
cmp old_y           ; die if "new Y < old Y"
bcc set_death_state ;
end_death_checks:

; Check if on ground
jsr check_on_ground
bne offground

; On ground
lda #$00                         ; Reset aerial jumps counter
sta player_a_num_aerial_jumps, x ;
lda #DEFAULT_GRAVITY    ; Reset gravity modifications
sta player_a_gravity, x ;
lda #<sinbad_state_onground_routines ;
sta tmpfield1                        ;
lda #>sinbad_state_onground_routines ; Fire on-ground event
sta tmpfield2                        ;
jsr player_state_action              ;
jmp end

offground:
lda #<sinbad_state_offground_routines
sta tmpfield1
lda #>sinbad_state_offground_routines
sta tmpfield2
jsr player_state_action
jmp end

set_death_state:
jsr audio_play_death ; Play death sound
lda #$00                         ; Reset aerial jumps counter
sta player_a_num_aerial_jumps, x ;
lda #DEFAULT_GRAVITY     ; Reset gravity
sta player_a_gravity, x  ;
sta player_a_hitstun, x ; Reset hitstun counter
dec player_a_stocks, x ; Decrement stocks counter and check for gameover
bmi gameover           ;
jsr start_respawn_player ; Respawn
jmp end

gameover:
lda #GAME_STATE_GAMEOVER
sta global_game_state
jsr switch_selected_player
txa
sta gameover_winner
jsr change_global_game_state

end:
rts
.)

; Show on screen player's damages
;  register X must contain the player number
write_player_damages:
.(
damages_ppu_position = tmpfield4
stocks_ppu_position = tmpfield7
player_stocks = tmpfield8

; Save X
txa
pha

; Set on-screen text position depending on the player
cpx #$00
beq prepare_player_a
lda #$94
sta damages_ppu_position
lda #$54
sta stocks_ppu_position
jmp end_player_variables
prepare_player_a:
lda #$88
sta damages_ppu_position
lda #$48
sta stocks_ppu_position
end_player_variables:

; Put damages value parameter for number_to_tile_indexes
lda player_a_damages, x
sta tmpfield1
lda player_a_stocks, x
sta player_stocks

; Write the begining of the damage buffer
jsr last_nt_buffer
lda #$01                 ; Continuation byte
sta nametable_buffers, x ;
inx
lda #$23                 ; PPU address MSB
sta nametable_buffers, x ;
inx
lda damages_ppu_position ; PPU address LSB
sta nametable_buffers, x ;
inx
lda #$03                 ; Tiles count
sta nametable_buffers, x ;
inx

; Store the tiles address as destination parameter for number_to_tile_indexes
txa
sta tmpfield2
lda #>nametable_buffers
sta tmpfield3

; Set the next continuation byte to 0
inx
inx
inx
lda #$00
sta nametable_buffers, x

; Populate tiles data for damage buffer
jsr number_to_tile_indexes

; Construct stocks buffers
ldy #$00
jsr last_nt_buffer
stocks_buffer:
lda #$01                 ; Continuation byte
sta nametable_buffers, x ;
inx
lda #$23                 ; PPU address MSB
sta nametable_buffers, x ;
inx
lda stocks_ppu_position  ; PPU address LSB
clc                      ;
adc stocks_positions, y  ;
sta nametable_buffers, x ;
inx
lda #$01                 ; Tiles count
sta nametable_buffers, x ;
inx
cpy player_stocks        ;
bcs empty_stock          ;
lda #$dd                 ;
jmp set_stock_tile       ; Set stock tile depending of the
empty_stock:             ; stock's availability
lda #$00                 ;
set_stock_tile:          ;
sta nametable_buffers, x ;
inx
iny               ;
cpy #$04          ; Loop for each stock to print
bne stocks_buffer ;
lda #$00                 ; Next continuation byte to 0
sta nametable_buffers, x ;

; Restore X
pla
tax

rts

stocks_positions:
.byt 0, 3, 32, 35
.)

; Change palette according to player's state
;  register X must contain the player number
player_effects:
.(
palette_buffer = tmpfield1
;                tmpfield2
palette_buffer_size = tmpfield3
#define PLAYER_EFFECTS_PALLETTE_SIZE 8

lda #<players_palettes ;
sta palette_buffer     ; palette_buffer points on the first players' palette
lda #>players_palettes ;
sta palette_buffer+1   ;

; Add palette offset related to hitstun state
lda player_a_hitstun, x
and #%00000010
beq no_hitstun
lda palette_buffer
clc
adc #PLAYER_EFFECTS_PALLETTE_SIZE
sta palette_buffer
lda palette_buffer+1
adc #0
sta palette_buffer+1
no_hitstun:

; Add palette offset related to player number
cpx #1
bne player_one
lda palette_buffer
clc
adc #PLAYER_EFFECTS_PALLETTE_SIZE*2
sta palette_buffer
lda palette_buffer+1
adc #0
sta palette_buffer+1
player_one:

; Copy pointed palette to a nametable buffer
txa                ;
pha                ; Initialize working values
jsr last_nt_buffer ; X = destination's offset (from nametable_buffers)
ldy #0             ; Y = source's offset (from (palette_buffer) origin)

copy_one_byte:
lda (palette_buffer), y  ; Copy a byte
sta nametable_buffers, x ;

inx                               ;
iny                               ; Prepare next byte
cpy #PLAYER_EFFECTS_PALLETTE_SIZE ;
bne copy_one_byte                 ;

pla ; Restore X
tax ;

rts

players_palettes:
.byt $01, $3f, $11, $03, $08, $1a, $20, $00 ; player A normal
.byt $01, $3f, $11, $03, $37, $3a, $20, $00 ; player A hitstun
.byt $01, $3f, $19, $03, $08, $16, $10, $00 ; player B normal
.byt $01, $3f, $19, $03, $37, $33, $20, $00 ; player B hitstun
.)

update_sprites:
.(
; Pretty names
animation_vector = tmpfield3   ; Not movable - Used as parameter for draw_anim_frame subroutine
first_sprite_index = tmpfield5 ; Not movable - Used as parameter for draw_anim_frame subroutine
last_sprite_index = tmpfield6  ; Not movable - Used as parameter for draw_anim_frame subroutine
frame_first_tick = tmpfield7  ; Not movable - Used as parameter for draw_anim_frame subroutine
animation_direction = tmpfield8 ; Not movable - Used as parameter for draw_anim_frame subroutine

.(
;
; Players animation
;

ldx #$00

player_animation:
ldy #$00
lda #$00
sta frame_first_tick

; Store current player's animation information to a player independent location
jsr store_player_anim_parameters

; New frame (search for the frame on time with clock)
new_frame:
lda (animation_vector), y ; Load frame duration
beq loop_animation ; Frame of duration 0 means end of animation
clc                        ; Compute current frame's clock end
adc frame_first_tick       ;
cmp player_a_anim_clock, x  ;
beq search_next_frame       ; If the current frame ends after the clock time, draw it
bcs draw_current_frame      ;
search_next_frame:
sta frame_first_tick ; Store next frame's clock begin (= current frame's clock end)

; Search the next frame
lda #$01
jsr add_to_anim_vector
skip_sprite:
lda (animation_vector), y ; Check current sprite continuation byte
beq end_skip_frame        ;
sta tmpfield8  ;
lda #$05       ;
sta tmpfield9  ; Set data length in tmpfield9
lda #%00001000 ; hitbox data is 15 bytes long
bit tmpfield8  ; other data are 5 bytes long
beq inc_cursor ; (counting the continuation byte)
lda #15        ;
sta tmpfield9  ;
inc_cursor:
lda tmpfield9          ; Add data length to the animation vector, to point
jsr add_to_anim_vector ; on the next continuation byte
jmp skip_sprite
end_skip_frame:
lda #$01               ; Skip the last continuation byte
jsr add_to_anim_vector ;
jmp new_frame

draw_current_frame:
; Animation location is player's location
lda player_a_x, x
sta tmpfield1
lda player_a_y, x
sta tmpfield2

; Increment animation_vector to skip the frame duration field
lda #$01
jsr add_to_anim_vector

; Set animation's direction
lda player_a_animation_direction, x
sta animation_direction

txa
pha
jsr draw_anim_frame
pla
tax

tick_clock:
inc player_a_anim_clock, x
jmp next_player

loop_animation:
lda #$00
sta player_a_anim_clock, x

next_player:
inx
cpx #$02
bne player_animation

;
; Enhancement sprites
;

jsr particle_draw
;jsr show_hitboxes

rts
.)

store_player_anim_parameters:
.(
cpx #$00
bne select_anim_player_b
lda player_a_animation
sta animation_vector
lda player_a_animation+1
sta animation_vector+1
lda #$00
sta first_sprite_index
lda #$0f
sta last_sprite_index
jmp end
select_anim_player_b:
lda player_b_animation
sta animation_vector
lda player_b_animation+1
sta animation_vector+1
lda #$10
sta first_sprite_index
lda #$1f
sta last_sprite_index
end:
rts
.)

add_to_anim_vector:
.(
clc
adc animation_vector
sta animation_vector
lda #$00
adc animation_vector+1
sta animation_vector+1
rts
.)

.)

; Draw an animation frame on screen
;  tmpfield1 - Position X
;  tmpfield2 - Position Y
;  tmpfield3, tmpfield4 - Vector pointing to the frame to draw
;  tmpfield5 - First sprite index to use
;  tmpfield6 - Last sprite index to use
;  tmpfield7 - Frame's first tick
;  tmpfield8 - Animation's direction (0 normal, 1 flipped)
;  X register - player number
;
; Overwrites tmpfield5, tmpfield7, tmpfield8, tmpfield9, tmpfield10, tmpfield11, tmpfield12 and all registers
draw_anim_frame:
.(
; Pretty names
anim_pos_x = tmpfield1
anim_pos_y = tmpfield2
frame_vector = tmpfield3
sprite_index = tmpfield5
last_sprite_index = tmpfield6
player_number = tmpfield7
animation_direction = tmpfield8
sprite_orig_x = tmpfield9
sprite_orig_y = tmpfield10
continuation_byte = tmpfield11
got_hitbox = tmpfield12
is_first_tick = tmpfield13

.(
; Compute is_first_tick (set to $00 on the first apparition of this frame)
lda player_a_anim_clock, x
sec
sbc tmpfield7
sta is_first_tick

; Initialization
ldy #$00
stx player_number
lda #$00
sta got_hitbox

; Check continuation byte - zero value means end of data
draw_one_sprite:
lda (frame_vector), y
beq clear_unused_sprites
iny

; Check positioning mode from continuation byte
sta continuation_byte
lda #%00000010
bit continuation_byte
beq set_relative
lda #$00
sta sprite_orig_x
sta sprite_orig_y
jmp check_hurtbox
set_relative:
lda anim_pos_x
sta sprite_orig_x
lda anim_pos_y
sta sprite_orig_y

; Check if next data is hurtbox position, hitbox definition or sprite data from continuation byte
check_hurtbox:
lda #%00000100
bit continuation_byte
beq check_hitbox
jsr anim_frame_move_hurtbox
jmp draw_one_sprite

check_hitbox:
lda #%00001000
bit continuation_byte
beq move_sprite
jsr anim_frame_move_hitbox
lda #$01
sta got_hitbox
jmp draw_one_sprite

move_sprite:
jsr anim_frame_move_sprite
jmp draw_one_sprite

; Place unused sprites off screen
clear_unused_sprites:
lda last_sprite_index
cmp sprite_index
bcc clear_unused_hitbox

lda sprite_index ;
asl              ; Set X to the byte offset of the sprite in OAM memory
asl              ;
tax              ;

lda #$fe
sta oam_mirror, x
inx
sta oam_mirror, x
inx
sta oam_mirror, x
inx
sta oam_mirror, x

inc sprite_index
jmp clear_unused_sprites

; Deactivate the hitbox if it was not placed by this frame
clear_unused_hitbox:
lda got_hitbox
cmp #$01
beq end
ldx player_number
sta player_a_hitbox_enabled, x

end:
rts
.)

anim_frame_move_sprite:
.(
; Copy sprite data

attributes_modifier = tmpfield14
sprite_used = tmpfield15 ; 0 - first sprite, 1 - last sprite

; Compute direction dependent information
;  attributes modifier - to flip the animation if needed
;  A - sprite index to use
lda animation_direction
beq default_direction

lda #$40                ; Flip horizontally attributes
sta attributes_modifier ;

lda #%00010000              ;
bit continuation_byte       ;
beq use_last_sprite         ;
lda #0                      ;
jmp set_sprite_used         ; Use the last sprite unless explicitely foreground
use_last_sprite:            ;
lda #1                      ;
set_sprite_used:            ;
sta sprite_used             ;
jmp end_init_direction_data ;

default_direction:
lda #$00                ;
sta attributes_modifier ; Do not flip attributes
sta sprite_used         ; Always use the first sprite

end_init_direction_data:

; X points on sprite data to modify
lda sprite_used
beq use_first_sprite
lda last_sprite_index
jmp sprite_index_set
use_first_sprite:
lda sprite_index
sprite_index_set:
asl
asl
tax

; Y value, must be relative to animation Y position
lda (frame_vector), y
clc
adc sprite_orig_y
sta oam_mirror, x
eor sprite_orig_y ;
bpl continue      ;
lda sprite_orig_y ; Skip the sprite if it wraps the screen from
cmp #%11000000    ; bottom to top
bcs skip          ;
continue:         ;
inx
iny
; Tile number
lda (frame_vector), y
sta oam_mirror, x
inx
iny
; Attributes
;  Add "2 * player_num" to select 3rd and 4th palette for player B
;  Flip horizontally (eor $40) if oriented to the right
lda player_number
asl
clc
adc (frame_vector), y
eor attributes_modifier
sta oam_mirror, x
inx
iny
; X value, must be relative to animation X position
;  Flip symetrically to the vertical axe if needed
lda animation_direction
bne flip_x
lda (frame_vector), y
jmp got_relative_pos
flip_x:
lda (frame_vector), y
eor #%11111111
clc
adc #1
got_relative_pos:
clc
adc sprite_orig_x
sta oam_mirror, x
iny

; Next sprite
lda sprite_used
beq inc_sprite_index
dec last_sprite_index
jmp end_next_sprite
inc_sprite_index:
inc sprite_index
end_next_sprite:
jmp end

; Skip sprite
skip:
lda #$fe          ; Reset OAM sprite's Y position
sta oam_mirror, x ;
iny ;
iny ; Advance to the next frame's sprite
iny ;
iny ;

end:
rts
.)

anim_frame_move_hurtbox:
.(
width = tmpfield14

; Extract relative position
ldx player_number
; Left
lda (frame_vector), y
sta player_a_hurtbox_left, x
iny
; Right
lda (frame_vector), y
sta player_a_hurtbox_right, x
iny
; Top
lda (frame_vector), y
sta player_a_hurtbox_top, x
iny
; Bottom
lda (frame_vector), y
sta player_a_hurtbox_bottom, x
iny

; If the animation is flipped, flip the box
lda animation_direction ; Nothing to do for non-flipped animation
beq apply_offset        ;

lda player_a_hurtbox_right, x ;
sec                           ; Compute box width
sbc player_a_hurtbox_left, x  ;
sta width                     ;

lda player_a_hurtbox_left, x  ;
eor #%11111111                ;
clc                           ; right = -left + 7
adc #8                        ;
sta player_a_hurtbox_right, x ;

sec                          ;
sbc width                    ; left = right - width
sta player_a_hurtbox_left, x ;

; Apply offset to the box
apply_offset:
; Left
lda player_a_hurtbox_left, x
clc
adc sprite_orig_x
sta player_a_hurtbox_left, x
; Right
lda player_a_hurtbox_right, x
clc
adc sprite_orig_x
sta player_a_hurtbox_right, x
; Top
lda player_a_hurtbox_top, x
clc
adc sprite_orig_y
sta player_a_hurtbox_top, x
; Bottom
lda player_a_hurtbox_bottom, x
clc
adc sprite_orig_y
sta player_a_hurtbox_bottom, x

end:
rts
.)

anim_frame_move_hitbox:
.(
width = tmpfield14

ldx player_number
; Enabled
lda is_first_tick
bne end_enabled
lda (frame_vector), y
ora player_a_hitbox_enabled, x
sta player_a_hitbox_enabled, x
end_enabled:
iny
; Damages
lda (frame_vector), y
sta player_a_hitbox_damages, x
iny
; Base_h
lda (frame_vector), y
sta player_a_hitbox_base_knock_up_h_high, x
iny
lda (frame_vector), y
sta player_a_hitbox_base_knock_up_h_low, x
iny
; Base_v
lda (frame_vector), y
sta player_a_hitbox_base_knock_up_v_high, x
iny
lda (frame_vector), y
sta player_a_hitbox_base_knock_up_v_low, x
iny
; Force_h
lda (frame_vector), y
sta player_a_hitbox_force_h, x
iny
lda (frame_vector), y
sta player_a_hitbox_force_h_low, x
iny
; Force_v
lda (frame_vector), y
sta player_a_hitbox_force_v, x
iny
lda (frame_vector), y
sta player_a_hitbox_force_v_low, x
iny
; Left
lda (frame_vector), y
sta player_a_hitbox_left, x
iny
; Right
lda (frame_vector), y
sta player_a_hitbox_right, x
iny
; Top
lda (frame_vector), y
sta player_a_hitbox_top, x
iny
; Top
lda (frame_vector), y
sta player_a_hitbox_bottom, x
iny

; If the player is right facing, flip the box
lda animation_direction ; Nothing to do for left facing players
beq apply_offset        ;

; Flip box position
lda player_a_hitbox_right, x ;
sec                          ; Compute box width
sbc player_a_hitbox_left, x  ;
sta width                    ;

lda player_a_hitbox_left, x  ;
eor #%11111111               ;
clc                          ; right = -left + 7
adc #8                       ;
sta player_a_hitbox_right, x ;

sec                         ;
sbc width                   ; left = right - width
sta player_a_hitbox_left, x ;

; Flip box knockback
lda player_a_hitbox_base_knock_up_h_low, x  ;
eor #%11111111                              ;
clc                                         ;
adc #1                                      ;
sta player_a_hitbox_base_knock_up_h_low, x  ; base_h = -base_h
lda player_a_hitbox_base_knock_up_h_high, x ;
eor #%11111111                              ;
adc #0                                      ;
sta player_a_hitbox_base_knock_up_h_high, x ;

lda player_a_hitbox_force_h_low, x ;
eor #%11111111                     ;
clc                                ;
adc #1                             ;
sta player_a_hitbox_force_h_low, x ; force_h = -force_h
lda player_a_hitbox_force_h, x     ;
eor #%11111111                     ;
adc #0                             ;
sta player_a_hitbox_force_h, x     ;

; Apply offset to the box
apply_offset:
; Left
lda player_a_hitbox_left, x
clc
adc sprite_orig_x
sta player_a_hitbox_left, x
; Right
lda player_a_hitbox_right, x
clc
adc sprite_orig_x
sta player_a_hitbox_right, x
; Top
lda player_a_hitbox_top, x
clc
adc sprite_orig_y
sta player_a_hitbox_top, x
; Top
lda player_a_hitbox_bottom, x
clc
adc sprite_orig_y
sta player_a_hitbox_bottom, x

rts
.)

.)

; Debug subroutine to show hitboxes and hurtboxes
show_hitboxes:
.(
pha
txa
pha
tya
pha

; Player A hurtbox
ldx #$fc
lda player_a_hurtbox_top
sta oam_mirror, x
inx
lda #$0d
sta oam_mirror, x
inx
lda #$03
sta oam_mirror, x
inx
lda player_a_hurtbox_left
sta oam_mirror, x
inx
ldx #$f8
lda player_a_hurtbox_bottom
sec
sbc #$07
sta oam_mirror, x
inx
lda #$0d
sta oam_mirror, x
inx
lda #$03
sta oam_mirror, x
inx
lda player_a_hurtbox_right
sec
sbc #$07
sta oam_mirror, x
inx

; Player B hurtbox
ldx #$f4
lda player_b_hurtbox_top
sta oam_mirror, x
inx
lda #$0d
sta oam_mirror, x
inx
lda #$03
sta oam_mirror, x
inx
lda player_b_hurtbox_left
sta oam_mirror, x
inx
ldx #$f0
lda player_b_hurtbox_bottom
sec
sbc #$07
sta oam_mirror, x
inx
lda #$0d
sta oam_mirror, x
inx
lda #$03
sta oam_mirror, x
inx
lda player_b_hurtbox_right
sec
sbc #$07
sta oam_mirror, x
inx

; Player A hitbox
lda player_a_hitbox_enabled
bne show_player_a_hitbox
lda #$fe  ;
sta $02e8 ;
sta $02e9 ;
sta $02ea ;
sta $02eb ; Hide disabled hitbox
sta $02ec ;
sta $02ed ;
sta $02ee ;
sta $02ef ;
jmp end_player_a_hitbox
show_player_a_hitbox:
ldx #$ec
lda player_a_hitbox_top
sta oam_mirror, x
inx
lda #$0e
sta oam_mirror, x
inx
lda #$03
sta oam_mirror, x
inx
lda player_a_hitbox_left
sta oam_mirror, x
inx
ldx #$e8
lda player_a_hitbox_bottom
sec
sbc #$07
sta oam_mirror, x
inx
lda #$0e
sta oam_mirror, x
inx
lda #$03
sta oam_mirror, x
inx
lda player_a_hitbox_right
sec
sbc #$07
sta oam_mirror, x
inx
end_player_a_hitbox

; Player B hitbox
lda player_b_hitbox_enabled
bne show_player_b_hitbox
lda #$fe  ;
sta $02e0 ;
sta $02e1 ;
sta $02e2 ;
sta $02e3 ; Hide disabled hitbox
sta $02e4 ;
sta $02e5 ;
sta $02e6 ;
sta $02e7 ;
jmp end_player_b_hitbox
show_player_b_hitbox:
ldx #$e4
lda player_b_hitbox_top
sta oam_mirror, x
inx
lda #$0e
sta oam_mirror, x
inx
lda #$03
sta oam_mirror, x
inx
lda player_b_hitbox_left
sta oam_mirror, x
inx
ldx #$e0
lda player_b_hitbox_bottom
sec
sbc #$07
sta oam_mirror, x
inx
lda #$0e
sta oam_mirror, x
inx
lda #$03
sta oam_mirror, x
inx
lda player_b_hitbox_right
sec
sbc #$07
sta oam_mirror, x
inx
end_player_b_hitbox

; Player A hitstun indicator
lda player_a_hitstun
bne show_player_a_hitstun
lda #$fe  ;
sta $02dc ;
sta $02dd ; Hide disabled hitstun
sta $02de ;
sta $02df ;
jmp end_player_a_hitstun
show_player_a_hitstun:
ldx #$dc
lda #$10
sta oam_mirror, x
sta oam_mirror+3, x
lda #$0e
sta oam_mirror+1, x
lda #$03
sta oam_mirror+2, x
end_player_a_hitstun:

; Player B hitstun indicator
lda player_b_hitstun
bne show_player_b_hitstun
lda #$fe  ;
sta $02d8 ;
sta $02d9 ; Hide disabled hitstun
sta $02da ;
sta $02db ;
jmp end_player_b_hitstun
show_player_b_hitstun:
ldx #$d8
lda #$10
sta oam_mirror, x
lda #$20
sta oam_mirror+3, x
lda #$0e
sta oam_mirror+1, x
lda #$03
sta oam_mirror+2, x
end_player_b_hitstun:

pla
tay
pla
tax
pla
rts
.)
