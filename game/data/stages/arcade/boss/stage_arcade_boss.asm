.(
+STAGE_ARCADE_BOSS_BANK_NUMBER = CURRENT_BANK_NUMBER

#include "game/data/stages/arcade/boss/layout_space.asm"
#include "game/data/stages/arcade/boss/layout_sky.asm"
#include "game/data/stages/arcade/boss/layout_impact.asm"

.(
cursor = stage_state_begin

&current_layout = cursor : -cursor += 1
&transition = cursor : -cursor += 1
&transition_step = cursor : -cursor += 1
&speed_buff_cnt = cursor : -cursor += 1

&layout_impact_lava_step = cursor : -cursor += 1
&layout_impact_lava_delay = cursor : -cursor += 1

#if cursor - stage_state_begin > $10
#error arcade stage BOSS uses to much memory
#endif

-cursor = local_mode_state_end

&mem_buffer = cursor : -cursor += 32

#if cursor > game_mode_state_end
#print cursor
#print game_mode_state_end
#error arcade stage BOSS uses to much memory
#endif
.)

FIRST_STAR_SPRITE = 32
NB_STAR_SPRITES = 16

NB_LAYOUTS = 3

SPEED_BUFF_COOLDOWN_EASY = 4
SPEED_BUFF_COOLDOWN_HARD = 3

FIRST_TILE_CLOUD = ARCADE_FIRST_TILE+(arcade_btt_sprites_tileset_end-arcade_btt_sprites_tileset_tiles)/16

star_tile:
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_LITTLE_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_LITTLE_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_LITTLE_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_LITTLE_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_LITTLE_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_LITTLE_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR
	.byt ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TINY_STAR

cloud_tile:
	.byt FIRST_TILE_CLOUD+0
	.byt FIRST_TILE_CLOUD+1
	.byt FIRST_TILE_CLOUD+2
	.byt FIRST_TILE_CLOUD+3
	.byt FIRST_TILE_CLOUD+0
	.byt FIRST_TILE_CLOUD+1
	.byt FIRST_TILE_CLOUD+2
	.byt FIRST_TILE_CLOUD+3
	.byt FIRST_TILE_CLOUD+0
	.byt FIRST_TILE_CLOUD+1
	.byt FIRST_TILE_CLOUD+2
	.byt FIRST_TILE_CLOUD+3
	.byt FIRST_TILE_CLOUD+0
	.byt FIRST_TILE_CLOUD+1
	.byt FIRST_TILE_CLOUD+2
	.byt FIRST_TILE_CLOUD+3

+stage_arcade_boss_init:
.(
	; Force boss music
	lda #<music_volcano_info
	sta audio_current_track_lsb
	lda #>music_volcano_info
	sta audio_current_track_msb
	lda #music_volcano_bank
	sta audio_current_track_bank
	TRAMPOLINE(audio_play_music_direct, #0, #CURRENT_BANK_NUMBER)

	; Hide portrait's sprites (we need sprites for stars/clouds)
	ldx #INGAME_PORTRAIT_FIRST_SPRITE*4
	ldy #8
	lda #$fe
	hide_one_portrait_sprite:
		sta oam_mirror+0, x

		inx:inx:inx:inx
		dey
		bne hide_one_portrait_sprite

	; Initialize stage state
	lda #0
	sta current_layout
	sta transition

	lda #SPEED_BUFF_COOLDOWN_EASY
	sta speed_buff_cnt

	; Set the number of boss lives to cover all layouts
	lda #NB_LAYOUTS - 1
	sta player_b_stocks

	; Initialize star sprites
	ldx #NB_STAR_SPRITES-1
	ldy #FIRST_STAR_SPRITE * 4
	init_one_sprite:
		; Load initial position
		lda star_sprites_pos_x, x
		sta oam_mirror+3, y

		lda star_sprites_pos_y, x
		sta oam_mirror+0, y

		lda #%00000000 + 3 ; Above baground + Evil Sinbad's weapon palette
		sta oam_mirror+2, y

		lda star_tile, x
		sta oam_mirror+1, y

		iny:iny:iny:iny
		dex
		bpl init_one_sprite

	; Copy sprite tiles used by the stage
	lda PPUSTATUS
	lda #>(FIRST_TILE_CLOUD*16)
	sta PPUADDR
	lda #<(FIRST_TILE_CLOUD*16)
	sta PPUADDR

	lda #<tileset_cloud_sprites
	sta tmpfield1
	lda #>tileset_cloud_sprites
	sta tmpfield2

	TRAMPOLINE(cpu_to_ppu_copy_tileset, #TILESET_COMMON_FEATURES_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Disable screen restore
	lda #$ff
	sta stage_restore_screen_step
	lda #FADE_LEVEL_NORMAL
	sta stage_fade_level
	sta stage_current_fade_level

	rts

	star_sprites_pos_x:
	.byt 239, 234, 21, 197, 100, 44, 155, 148, 31, 177, 158, 63, 122, 42, 79, 89
	star_sprites_pos_y:
	.byt 111, 217, 193, 152, 83, 18, 46, 48, 112, 150, 221, 253, 65, 18, 195, 1
.)

move_bg_sprites:
.(
	speed_table_h = tmpfield1
	speed_table_v = tmpfield3
	tiles_table = tmpfield5
	invisible_below = tmpfield7

	ldy #NB_STAR_SPRITES-1
	ldx #FIRST_STAR_SPRITE * 4
	move_one_sprite:
		; Modify position
		lda oam_mirror+3, x
		clc
		adc (speed_table_h), y
		sta oam_mirror+3, x

		lda oam_mirror+0, x
		clc
		adc (speed_table_v), y
		sta oam_mirror+0, x

		; Select an invisible sprite if the sprite below its threshold
		.(
			cmp (invisible_below), y
			bcc visible
				invisible:
					lda #ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_FULL_BACKDROP
					jmp ok
				visible:
					lda (tiles_table), y
			ok:
			sta oam_mirror+1, x
		.)

		; Loop
		inx:inx:inx:inx
		dey
		bpl move_one_sprite

	rts
.)

tick_space:
.(
	speed_table_h = tmpfield1
	speed_table_v = tmpfield3
	tiles_table = tmpfield5
	invisible_below = tmpfield7

	; Move star background
	lda #<star_speed_h
	sta speed_table_h
	lda #>star_speed_h
	sta speed_table_h+1

	lda #<star_speed_v
	sta speed_table_v
	lda #>star_speed_v
	sta speed_table_v+1

	lda #<star_tile
	sta tiles_table
	lda #>star_tile
	sta tiles_table+1

	lda #<y_visibility
	sta invisible_below
	lda #>y_visibility
	sta invisible_below+1

	jmp move_bg_sprites

	;rts ; useless, jump to subroutine

	star_speed_h:
	.byt $fa, $fa, $fc, $fc, $fc, $fc, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe
	star_speed_v:
	.byt $fd, $fd, $fe, $fe, $fe, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	y_visibility:
	.byt $7c, $7c, $7c, $7c
	.byt $7c, $7c, $7c, $7c
	.byt $7c, $7c, $7c, $7c
	.byt $7c, $7c, $7c, $7c
.)

init_sky:
.(
	; Initialize cloud sprites
	ldx #NB_STAR_SPRITES-1
	ldy #FIRST_STAR_SPRITE * 4
	init_one_sprite:
		; Load initial position
		lda cloud_sprites_pos_x, x
		sta oam_mirror+3, y

		lda cloud_sprites_pos_y, x
		sta oam_mirror+0, y

		lda #%00000000 + 3 ; Above baground + Evil Sinbad's waypon palette
		sta oam_mirror+2, y

		lda cloud_tile, x
		sta oam_mirror+1, y

		iny:iny:iny:iny
		dex
		bpl init_one_sprite

	rts

	cloud_sprites_pos_x:
	.byt 239, 234, 242, 250,   100, 95, 103, 111,    63,  58,  66,  74,  89, 84, 92, 100
	cloud_sprites_pos_y:
	.byt 111, 119, 119, 119,    83, 91,  91,  91,   244, 252, 252, 252,   1,  9,  9,   9
.)

tick_sky:
.(
	invisible_below = tmpfield7

	; Give the boss extra speed
	dec speed_buff_cnt
	bne no_speed_buff
		jsr player_b_extra_tick
		lda #SPEED_BUFF_COOLDOWN_EASY
		sta speed_buff_cnt
	no_speed_buff:

	lda #<y_visibility
	sta invisible_below
	lda #>y_visibility
	sta invisible_below+1

	jmp sky_move_clouds
	;rts useless, jump to subroutine

	y_visibility:
	.byt $7a, $7a, $7a, $7a
	.byt $7a, $7a, $7a, $7a
	.byt $f0, $f0, $f0, $f0
	.byt $7a, $7a, $7a, $7a
.)

sky_move_clouds:
.(
	speed_table_h = tmpfield1
	speed_table_v = tmpfield3
	tiles_table = tmpfield5
	invisible_below = tmpfield7

	; Move clouds background
	lda #<speed_h
	sta speed_table_h
	lda #>speed_h
	sta speed_table_h+1

	lda #<speed_v
	sta speed_table_v
	lda #>speed_v
	sta speed_table_v+1

	lda #<cloud_tile
	sta tiles_table
	lda #>cloud_tile
	sta tiles_table+1

	jmp move_bg_sprites

	;rts ; useless, jump to subroutine

	speed_h:
	.byt $fc, $fc, $fc, $fc
	.byt $fe, $fe, $fe, $fe
	.byt $fa, $fa, $fa, $fa
	.byt $fe, $fe, $fe, $fe
	speed_v:
	.byt $fe, $fe, $fe, $fe
	.byt $ff, $ff, $ff, $ff
	.byt $fd, $fd, $fd, $fd
	.byt $ff, $ff, $ff, $ff
.)

init_impact:
.(
	lda #0
	sta layout_impact_lava_step
	sta layout_impact_lava_delay
	rts
.)

tick_impact:
.(
	invisible_below = tmpfield7

	; Give the boss extra speed
	dec speed_buff_cnt
	bne no_speed_buff
		jsr player_b_extra_tick
		lda #SPEED_BUFF_COOLDOWN_HARD
		sta speed_buff_cnt
	no_speed_buff:

	; Animate lava
	inc layout_impact_lava_delay
	lda layout_impact_lava_delay
	and #%00000111
	bne skip_lava_step_inc
		inc layout_impact_lava_step
		lda layout_impact_lava_step
		cmp #animated_lava_cycle_length
		bcc lava_step_inc_ok
			lda #0
			sta layout_impact_lava_step
		lava_step_inc_ok:
	skip_lava_step_inc:

	ldx layout_impact_lava_step

	lda animated_lava_cycle_nt_buff_lsb, x
	ldy animated_lava_cycle_nt_buff_msb, x
	jsr push_nt_buffer

	; Move clouds
	lda #<y_visibility
	sta invisible_below
	lda #>y_visibility
	sta invisible_below+1

	jmp sky_move_clouds

	;rts ; useless, jump to subroutine

	y_visibility:
	.byt $aa, $aa, $aa, $aa
	.byt $aa, $aa, $aa, $aa
	.byt $f0, $f0, $f0, $f0
	.byt $aa, $aa, $aa, $aa
.)

.(
	TRANSITION_INACTIVE = 0
	TRANSITION_FADE_OUT = 1

	&transition_init:
	.(
		lda #TRANSITION_FADE_OUT
		sta transition

		lda #0
		sta transition_step

		lda #24
		sta screen_shake_noise_h
		lda #12
		sta screen_shake_noise_v
		lda #0
		sta screen_shake_current_x
		sta screen_shake_current_y
		lda #18 ; 18 is slightly more than the fadeout, ensuring it to have "normal" screenshake
		sta screen_shake_counter

		rts
	.)

	&transition_tick:
	.(
		; Stay in screen-shake mode as long as necessary
		.(
			lda screen_shake_counter
			bne ok
				lda #2 ;HACK 2 is the lowest value that does not end the shaking on next frame, this cause screenshake randomness to be terribly poor
				sta screen_shake_counter
			ok:
		.)

		; Call current state routine
		ldx transition
		lda transion_routines_lsb-1, x
		sta tmpfield1
		lda transion_routines_msb-1, x
		sta tmpfield2
		jmp (tmpfield1)

		;rts ; useless, jump to subroutine

		transion_routines_lsb:
		.byt <fade_out, <copy_nametable, <copy_stage_data, <init_new_layout, <fade_in, <end_transition
		transion_routines_msb:
		.byt >fade_out, >copy_nametable, >copy_stage_data, >init_new_layout, >fade_in, >end_transition

		next_transition_routine:
		.(
			lda #0
			sta transition_step

			inc transition

			rts
		.)

		fade_out:
		.(
			; Keep background moving
			jsr tick_current_layout

			; Change palettes
			lda transition_step
			cmp #0
			beq do_it
			cmp #8
			beq do_it
			cmp #16
			beq do_it
			jmp skip
			do_it:
				asl
				clc
				adc #<step_palettes
				sta tmpfield3
				lda #0
				adc #>step_palettes
				sta tmpfield4

				lda #<nt_palette_header
				sta tmpfield1
				lda #>nt_palette_header
				sta tmpfield2

				jsr construct_nt_buffer
			skip:

			; Change to next step
			inc transition_step
			lda transition_step
			cmp #17
			bne ok
				jsr next_transition_routine
			ok:

			rts

			step_palettes:
			.byt $17,$16,$26,$20, $17,$16,$10,$20, $17,$16,$10,$20, $17,$20,$36,$26
			.byt $27,$26,$20,$20, $27,$26,$10,$20, $27,$26,$10,$20, $27,$20,$20,$36
			.byt $20,$20,$20,$20, $20,$20,$20,$20, $20,$20,$20,$20, $20,$20,$20,$20

			nt_palette_header:
			.byt $3f, $00, $10
		.)

		copy_nametable:
		.(
			; Keep background moving
			jsr tick_current_layout


			zipped_nt_addr = tmpfield1
			unzipped_data_offset = tmpfield3
			unzipped_data_count = tmpfield5
			unzip_dest = tmpfield6

			; Compute useful values
			lda #0
			sta unzipped_data_offset+1
			lda transition_step
			asl
			rol unzipped_data_offset+1
			asl
			rol unzipped_data_offset+1
			asl
			rol unzipped_data_offset+1
			asl
			rol unzipped_data_offset+1
			asl
			rol unzipped_data_offset+1
			sta unzipped_data_offset

			; Construct nametable buffer for current line
			LAST_NT_BUFFER

			lda #1 ; Continuation byte
			sta nametable_buffers, x
			inx

			lda unzipped_data_offset+1 ; PPU address "$2000 + unzipped_data_offset"
			clc
			adc #$20
			sta nametable_buffers, x
			inx
			lda unzipped_data_offset
			sta nametable_buffers, x
			inx

			lda #32 ; Payload length
			sta nametable_buffers, x
			inx

			txa ; Save nt buffer's payload address
			pha

			clc ; Stop byte, 32 bytes further
			adc #32
			tax
			lda #0
			sta nametable_buffers, x
			stx nt_buffers_end

			; Unzip tiles from the nametable
			lda #<mem_buffer
			sta unzip_dest
			lda #>mem_buffer
			sta unzip_dest+1

			lda #32
			sta unzipped_data_count

			ldx current_layout
			lda layout_nametable_addr_lsb, x
			sta zipped_nt_addr
			lda layout_nametable_addr_msb, x
			sta zipped_nt_addr+1

			jsr get_unzipped_bytes

			; Fill nametable buffer's data with tiles from the nametable
			pla
			tax

			ldy #0
			copy_one_byte:
				lda mem_buffer, y
				sta nametable_buffers, x

				iny
				inx
				cpy #32
				bne copy_one_byte

			; Next step
			inc transition_step
			lda transition_step
			cmp #30+2 ; 30 tiles lines + 2*32 bytes of attributes
			bne end
				jsr next_transition_routine

			end:
			rts

			; Catchy name, this is the nametable address of the next layout
			layout_nametable_addr_lsb:
			.byt <stage_arcade_boss_sky_nametable, <stage_arcade_boss_impact_nametable
			layout_nametable_addr_msb:
			.byt >stage_arcade_boss_sky_nametable, >stage_arcade_boss_impact_nametable
		.)

		copy_stage_data:
		.(
			; Keep background moving
			jsr tick_current_layout

			; Flag damage meters as dirty
			lda #$ff ; impossible value in screen damage meter cache, forcing it to redraw
			sta player_a_last_shown_damage
			sta player_b_last_shown_damage
			sta player_a_last_shown_stocks
			sta player_b_last_shown_stocks

			; Copy stage data
			lda #<stage_data
			sta tmpfield1
			lda #>stage_data
			sta tmpfield2

			ldx current_layout
			lda layout_data_addr_lsb, x
			sta tmpfield3
			lda layout_data_addr_msb, x
			sta tmpfield4

			lda #$80
			sta tmpfield5

			jsr fixed_memcpy

			; Next step
			jsr next_transition_routine

			rts

			; Catchy name, this is the data address of the next layout
			layout_data_addr_lsb:
			.byt <stage_arcade_boss_sky_data, <stage_arcade_boss_impact_data
			layout_data_addr_msb:
			.byt >stage_arcade_boss_sky_data, >stage_arcade_boss_impact_data
		.)

		init_new_layout:
		.(
			; Next step (do it now, so we can jump to a subroutine later)
			jsr next_transition_routine

			; Change active layout
			inc current_layout

			; Call new layout init routine
			ldx current_layout
			lda layout_init_routine_lsb-1, x
			sta tmpfield1
			lda layout_init_routine_msb-1, x
			sta tmpfield2
			jmp (tmpfield1)

			;rts ; useless, jump to subroutine

			; Catchy name, this is the init address of the next layout
			layout_init_routine_lsb:
			.byt <init_sky, <init_impact
			layout_init_routine_msb:
			.byt >init_sky, >init_impact
		.)

		fade_in:
		.(
			; Keep background moving
			jsr tick_current_layout

			; Change palettes
			lda transition_step
			cmp #0
			beq do_it
			cmp #8
			beq do_it
			cmp #16
			beq do_it
			jmp skip
			do_it:
				asl
				clc
				adc #<step_palettes
				sta tmpfield3
				lda #0
				adc #>step_palettes
				sta tmpfield4

				lda #<nt_palette_header
				sta tmpfield1
				lda #>nt_palette_header
				sta tmpfield2

				jsr construct_nt_buffer
			skip:

			; Change to next step
			inc transition_step
			lda transition_step
			cmp #17
			bne ok
				jsr next_transition_routine
			ok:

			rts

			step_palettes:
			.byt $27,$36,$20,$20, $27,$36,$10,$20, $27,$36,$10,$20, $27,$20,$20,$36
			.byt $17,$31,$26,$20, $17,$31,$10,$20, $17,$31,$10,$20, $17,$20,$36,$26
			.byt $07,$21,$16,$27, $07,$21,$16,$27, $07,$21,$10,$20, $07,$20,$26,$16

			nt_palette_header:
			.byt $3f, $00, $10
		.)

		end_transition:
		.(
			lda #TRANSITION_INACTIVE
			sta transition

			; Have the boss spawn again instead of normal respawn
			lda #0
			sta player_b_x_screen
			sta player_b_y_screen
			sta player_b_x_low
			lda #$ff
			sta player_b_y_low
			ldx current_layout
			lda boss_spawn_position_x, x
			sta player_b_x
			lda boss_spawn_position_y, x
			sta player_b_y

			ldy config_player_b_character
			lda #PLAYER_STATE_SPAWN
			sta player_b_state
			lda characters_start_routines_table_lsb, y
			sta tmpfield1
			lda characters_start_routines_table_msb, y
			sta tmpfield2

			ldx #1

			TRAMPOLINE(player_state_action, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

			rts

			boss_spawn_position_x:
			.byt $ca, $ca, $ca
			boss_spawn_position_y:
			.byt $70, $70, $70
		.)
	.)
.)

+stage_arcade_boss_tick:
.(
	; Check if it is time to activate transition
	.(
		lda transition
		bne ok
			lda player_b_state
			cmp #PLAYER_STATE_RESPAWN
			bne ok
				; transition is not already running, and boss is in respawn state, start transition
				jsr transition_init
				rts
		ok:
	.)

	; Fallthrough tick_current_layout
.)

tick_current_layout:
.(
	; Perform pending screen repair
	jsr stage_arcade_boss_repair_screen

	; Call current layout tick
	ldx current_layout
	lda tick_routines_lsb, x
	sta tmpfield1
	lda tick_routines_msb, x
	sta tmpfield2
	jmp (tmpfield1)

	;rts ; Useless, none of the above branche return

	tick_routines_lsb:
	.byt <tick_space, <tick_sky, <tick_impact
	tick_routines_msb:
	.byt >tick_space, >tick_sky, >tick_impact
.)

+stage_arcade_boss_freezed_tick:
.(
	; Tick deathplosion animation
	TRAMPOLINE(vfx_deathplosion, #GAMESTATE_GAME_EXTRA_BANK, #CURRENT_BANK_NUMBER)

	; Perform pending screen repair
	jsr stage_arcade_boss_repair_screen

	; Call transition code if we are in a transition
	lda transition
	beq end
		jmp transition_tick

	end:
	rts
.)

player_b_extra_tick:
.(
	; No extra tick when the game is freezed
	.(
		lda screen_shake_counter
		beq ok
			rts
		ok:
	.)

	; No extra tick in slowdown
	;TODO investigate if it is easy to avoid extra tick only on frames skipped by slowdown
	.(
		lda slow_down_counter
		beq ok
			rts
		ok:
	.)

	; Do like "update_players" routine, but just for player B
	.(
		; Decrement hitstun counters
		lda player_b_hitstun
		beq hitstun_ok
			dec player_b_hitstun
		hitstun_ok:

		; Check hitbox collisions
		ldx #$01
		TRAMPOLINE(check_player_hit, #0, #CURRENT_BANK_NUMBER)

		; Call the state update routine
		ldx #$01
		ldy config_player_a_character, x
		lda characters_update_routines_table_lsb, y
		sta tmpfield1
		lda characters_update_routines_table_msb, y
		sta tmpfield2
		TRAMPOLINE(player_state_action, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

		; Call the state input routine if input changed
		;ldx #$01 ; useless, done above (and character update routine is not allowed to alter it)
		lda controller_a_btns, x
		cmp controller_a_last_frame_btns, x
		beq end_input_event
			ldy config_player_a_character, x
			lda characters_input_routines_table_lsb, y
			sta tmpfield1
			lda characters_input_routines_table_msb, y
			sta tmpfield2
			TRAMPOLINE(player_state_action, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)
		end_input_event:

		; Call generic update routines
		txa
		sta player_number
		jsr move_player
		ldy config_player_b_character
		TRAMPOLINE(check_player_position, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)
	.)

	; Tick AI
	.(
		lda config_ai_level
		beq end_ai
		lda network_rollback_mode
		bne end_ai
			TRAMPOLINE(ai_tick, #0, #CURRENT_BANK_NUMBER)
		end_ai:
	.)

	rts
.)

; Sets fadeout level
;  register X - fadeout level
;
; Overwrites registers, tmpfield1 to tmpfield4
+stage_arcade_boss_fadeout:
.(
	; Set ideal fade level
	stx stage_fade_level

	; If not in rollback, apply it immediately
	lda network_rollback_mode
	beq apply_fadeout
		rts

	apply_fadeout:
	;Fallthrough to stage_arcade_boss_fadeout_update
.)

; Rewrite palettes to match fadeout level
;  register X - fadeout level
;
; Overwrites registers, tmpfield1 to tmpfield4
stage_arcade_boss_fadeout_update:
.(
	header = tmpfield1 ; construct_nt_buffer parameter
	payload = tmpfield3 ; construct_nt_buffer parameter

	; Do nothing if there is not enough space in the buffer
	.(
		IF_NT_BUFFERS_FREE_SPACE_LT(#1+3+16+1, ok)
			rts
		ok:
	.)

	; Set actual fade level
	stx stage_current_fade_level

	; Change palette
	lda #<palette_header
	sta header
	lda #>palette_header
	sta header+1

	lda stage_arcade_boss_fadeout_lsb, x
	sta payload
	lda stage_arcade_boss_fadeout_msb, x
	sta payload+1

	jmp construct_nt_buffer

	;rts ; useless, jump to subroutine

	palette_header:
	.byt $3f, $00, $10
.)

; Redraw the stage background (one step per call)
;  network_rollback_mode - set to inhibit any repair operation
;  stage_screen_effect - set to inhibit any repair operation
;  stage_fade_level - Desired fade level
;  stage_current_fade_level - Currently applied fade level
;  stage_restore_screen_step - Attributes restoration step (>= $80 to inhibit attributes restoration)
;
; Overwrites all registers, tmpfield1 to tmpfield4
stage_arcade_boss_repair_screen:
.(
	; Do nothing in rollback mode
	.(
		lda network_rollback_mode
		beq ok
			rts
		ok:
	.)

	; Do nothing if a fullscreen animation is running
	.(
		lda stage_screen_effect
		beq ok
			rts
		ok:
	.)

	; Fix fadeout if needed
	;NOTE does not return if action is taken (to avoid flooding nametable buffers)
	.(
		ldx stage_fade_level
		cpx stage_current_fade_level
		beq ok
			jmp stage_arcade_boss_fadeout_update
			;No return, jump to subroutine
		ok:
	.)

	; Fix attributes if needed
	.(
		; Do noting if there is no restore operation running
		.(
			ldx stage_restore_screen_step
			bpl ok
				rts
			ok:
		.)

		; Do nothing if there lack space for the nametable buffers
		.(
			IF_NT_BUFFERS_FREE_SPACE_LT(#1+3+32+1, ok)
				rts
			ok:
		.)

		; Write NT buffer corresponding to current step
		.(
			;ldx stage_restore_screen_step ; useless, done above
			lda steps_buffers_lsb, x
			ldy steps_buffers_msb, x
			jsr push_nt_buffer
		.)

		; Increment step
		.(
			inc stage_restore_screen_step
			lda stage_restore_screen_step
			cmp #NUM_RESTORE_STEPS
			bne ok
				lda #$ff
				sta stage_restore_screen_step
			ok:
		.)
	.)

	rts

	top_attributes:
	.byt $23, $c0, $20
	.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

	bot_attibutes:
	.byt $23, $e0, $20
	.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byt %00000000, %00000000, %00000000, %01000000, %00010001, %00000000, %00000000, %00000000
	.byt %00000000, %00000000, %00000000, %01000100, %00010001, %00000000, %00000000, %00000000
	.byt %00000000, %00000000, %00000000, %00000100, %00000001, %00000000, %00000000, %00000000

	steps_buffers_lsb:
	.byt <top_attributes, <bot_attibutes
	steps_buffers_msb:
	.byt >top_attributes, >bot_attibutes
	NUM_RESTORE_STEPS = *-steps_buffers_msb
.)
.)
