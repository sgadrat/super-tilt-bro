init_menu:
.(
	; Initialize tick counter
	lda #0
	sta menu_common_tick_num

	; Initialize clouds positions
	lda #16
	sta menu_common_cloud_1_x
	lda #119
	sta menu_common_cloud_1_y
	lda #180
	sta menu_common_cloud_2_x
	lda #16
	sta menu_common_cloud_2_y
	lda #100
	sta menu_common_cloud_3_x
	lda #187
	sta menu_common_cloud_3_y
	lda #0
	sta menu_common_cloud_1_y_msb
	sta menu_common_cloud_2_y_msb
	sta menu_common_cloud_3_y_msb

	; Fallthrough
.)
re_init_menu:
.(
	; Copy initial cloud sprites to oam mirror
	ldx #MENU_COMMON_NB_CLOUDS * MENU_COMMON_NB_SPRITE_PER_CLOUD * MENU_COMMON_OAM_SPRITE_SIZE
	copy_one_byte:
		dex
		lda cloud_sprites, x
		sta oam_mirror + MENU_COMMON_FIRST_CLOUD_SPRITE * MENU_COMMON_OAM_SPRITE_SIZE, x
		cpx #0
		bne copy_one_byte

	; Show clouds on screen
	jsr menu_position_clouds

	rts

#define CLOUD_SPRITE .byt 0, TILE_CLOUD_1, $63, 0, 0, TILE_CLOUD_2, $63, 0, 0, TILE_CLOUD_3, $63, 0, 0, TILE_CLOUD_4, $63, 0, 0, TILE_CLOUD_5, $63, 0
	cloud_sprites:
	CLOUD_SPRITE
	CLOUD_SPRITE
	CLOUD_SPRITE
.)

; Set the CHR-RAM contents as expected by menus
;
; Overwrites register A, registerY, tmpfield1, tmpfield2, tmpfield3
;
; Shall only be called while PPU rendering is turned off
set_menu_chr:
.(
	tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tiles
	;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tiles

	lda #<tileset_menus
	sta tileset_addr
	lda #>tileset_menus
	sta tileset_addr+1

	SWITCH_BANK(#TILESET_MENUS_BANK_NUMBER)

	jsr cpu_to_ppu_copy_tileset_background

	jmp copy_common_tileset
	;rts ; useless, jump to subroutine
.)

tick_menu:
.(
	tick_moving_clouds:
	.(
		stop_oam_index = tmpfield1

		; Compute where to stop incrementing
		inc menu_common_tick_num ; menu_common_tick_num += 1

		lda #%00000001            ;
		bit menu_common_tick_num  ; Skip one out of two frames
		beq end                   ;

		lda menu_common_tick_num ;
		lsr                      ; Get a two bits frame counter in A
		and #%00000011           ;
		sta tmpfield1            ;

		; Increment clouds X position
		ldx #0
		move_one_cloud:
		cpx tmpfield1
		beq end
		inc menu_common_cloud_1_x, x
		jsr menu_position_cloud
		inx
		jmp move_one_cloud

		end:
		; Fallthrough
	.)

	rts
.)

; Position all cloud sprites on screen
menu_position_clouds:
.(
	ldx #MENU_COMMON_NB_CLOUDS - 1
	position_one_cloud:
		jsr menu_position_cloud
		dex
		bpl position_one_cloud
	rts
.)

; Position a cloud's sprites
;  register X - cloud index
menu_position_cloud:
.(
	cloud_x = tmpfield3
	cloud_y = tmpfield4

	; Save cloud's coordinate at a fixed position
	lda menu_common_cloud_1_x, x
	sta cloud_x
	lda menu_common_cloud_1_y, x
	sta cloud_y

	; Hide cloud not on the main screen
	lda menu_common_cloud_1_y_msb, x
	beq do_not_hide
		lda #$fe
		sta cloud_y
	do_not_hide:

	; Compute cloud's first sprite address
	txa ; Save X
	pha ;

#if MENU_COMMON_NB_SPRITE_PER_CLOUD <> 5
#error Following code expects 5 sprites per cloud
#endif
	sta tmpfield2 ;
	asl           ; X = X * NB_SPRITE_PER_CLOUD
	asl           ;   = index of the first sprite, starting from first cloud's first sprite
	adc tmpfield2 ;

	asl ;
	asl ; X = X * OAM_SPRITE_SIZE
	tax ;   = offset of the first byte, starting from first cloud's first byte

	; Place cloud's sprites
	ldy #0
	place_one_sprite:
	lda cloud_y
	cmp #$fe               ;
	beq skip_y_offset      ;
	clc                    ; Do not accidentally unhide hidden clouds
	adc sprite_offset_y, y ;
	skip_y_offset:         ;
	sta oam_mirror + MENU_COMMON_FIRST_CLOUD_SPRITE * MENU_COMMON_OAM_SPRITE_SIZE, x
	inx
	inx
	inx
	lda cloud_x
	clc
	adc sprite_offset_x, y
	sta oam_mirror + MENU_COMMON_FIRST_CLOUD_SPRITE * MENU_COMMON_OAM_SPRITE_SIZE, x
	inx

	iny
	cpy #MENU_COMMON_NB_SPRITE_PER_CLOUD
	bne place_one_sprite

	; Restore X
	pla
	tax

	rts

	; Offset of sprites relative to cloud's position
	sprite_offset_x:
	.byt 16, 8, 16, 8, 0
	sprite_offset_y:
	.byt  0, 0,  8, 8, 8
.)
