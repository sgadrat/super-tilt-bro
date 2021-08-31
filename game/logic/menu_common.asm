.(

#define X(n) n
#define Y(n) (n&$ff), (n>>8)
clouds_initial_position:
	.byt X(180), Y(16)
	.byt X(16), Y(119)
	.byt X(100), Y(187)
	.byt X(30), Y(308)
	.byt X(150), Y(390)
#undef X
#undef Y

menu_common_clouds_speed:
	.byt $60, $80, $20, $80, $60

&init_menu:
.(
	; Initialize clouds positions
	ldx #0
	ldy #0
	position_one_cloud:
		lda #0
		sta menu_common_cloud_1_x_subpixel, x

		lda clouds_initial_position, y
		sta menu_common_cloud_1_x, x
		iny

		lda clouds_initial_position, y
		sta menu_common_cloud_1_y, x
		iny

		lda clouds_initial_position, y
		sta menu_common_cloud_1_y_msb, x
		iny

		inx
		cpx #MENU_COMMON_NB_CLOUDS
		bne position_one_cloud

	; Fallthrough
.)
&re_init_menu:
.(
	memcpy_dest = tmpfield1
	memcpy_source = tmpfield3
	memcpy_size = tmpfield5

	; Copy initial cloud sprites to oam mirror
	lda #<(oam_mirror + MENU_COMMON_FIRST_CLOUD_SPRITE * MENU_COMMON_OAM_SPRITE_SIZE)
	sta memcpy_dest
	lda #>(oam_mirror + MENU_COMMON_FIRST_CLOUD_SPRITE * MENU_COMMON_OAM_SPRITE_SIZE)
	sta memcpy_dest+1
	lda #MENU_COMMON_NB_SPRITE_PER_CLOUD * MENU_COMMON_OAM_SPRITE_SIZE
	sta memcpy_size

	ldx #MENU_COMMON_NB_CLOUDS
	copy_one_cloud:
	.(
		lda #<cloud_sprite
		sta memcpy_source
		lda #>cloud_sprite
		sta memcpy_source+1

		jsr fixed_memcpy

		lda memcpy_dest
		clc
		adc #MENU_COMMON_NB_SPRITE_PER_CLOUD * MENU_COMMON_OAM_SPRITE_SIZE
		sta memcpy_dest
		bcc ok
			inc memcpy_dest+1
		ok:

		dex
		bne copy_one_cloud
	.)

	; Show clouds on screen
	jmp menu_position_clouds

	;rts ; Useless, jump to subroutine

	cloud_sprite:
		.byt 0, TILE_CLOUD_1, $63, 0
		.byt 0, TILE_CLOUD_2, $63, 0
		.byt 0, TILE_CLOUD_3, $63, 0
		.byt 0, TILE_CLOUD_4, $63, 0
		.byt 0, TILE_CLOUD_5, $63, 0
.)

; Set the CHR-RAM contents as expected by menus
;
; Overwrites register A, registerY, tmpfield1, tmpfield2, tmpfield3
;
; Shall only be called while PPU rendering is turned off
&set_menu_chr:
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

&tick_menu:
.(
	tick_moving_clouds:
	.(
		; Move clouds
		ldx #MENU_COMMON_NB_CLOUDS-1
		move_one_cloud:
			; Compute position
			lda menu_common_cloud_1_x_subpixel, x
			clc
			adc menu_common_clouds_speed, x
			sta menu_common_cloud_1_x_subpixel, x
			bcc ok
				inc menu_common_cloud_1_x, x
			ok:

			; Place sprites
			jsr menu_position_cloud

			; Loop
			dex
			bpl move_one_cloud
	.)

	rts
.)

; Position all cloud sprites on screen
&menu_position_clouds:
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
		cmp #$fe
		beq skip_y_offset ; Do not accidentally unhide hidden clouds
			clc
			adc sprite_offset_y, y
		skip_y_offset:
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
.)
