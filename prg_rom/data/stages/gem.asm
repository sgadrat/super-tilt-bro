;
; Standard stage data
;

stage_gem_data:
	STAGE_HEADER($5000, $a800, $a000, $a000, $7800, $7800) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_gem_platforms:
	PLATFORM($31, $c7, $a1, $ff) ; left, right, top, bot
	SMOOTH_PLATFORM($21, $4f, $83) ; left, right, top
	SMOOTH_PLATFORM($b1, $df, $73) ; left, right, top
END_OF_STAGE

;
; Gem explosion animation
;

gem_explosion_last_frame_index:
	.byt 8
gem_explosion_frames_addr_lsb:
	.byt <gem_explosion_frame_1
	.byt <gem_explosion_frame_2
	.byt <gem_explosion_frame_3
	.byt <gem_explosion_frame_4
	.byt <gem_explosion_frame_5
	.byt <gem_explosion_frame_6
	.byt <gem_explosion_frame_7
	.byt <gem_explosion_frame_8
	.byt <gem_explosion_frame_last
gem_explosion_frames_addr_msb:
	.byt >gem_explosion_frame_1
	.byt >gem_explosion_frame_2
	.byt >gem_explosion_frame_3
	.byt >gem_explosion_frame_4
	.byt >gem_explosion_frame_5
	.byt >gem_explosion_frame_6
	.byt >gem_explosion_frame_7
	.byt >gem_explosion_frame_8
	.byt >gem_explosion_frame_last

gem_explosion_frame_1:
	ANIM_SPRITE($00, TILE_EXPLOSION_1, $00, $00) ; Y, tile, attr, X
	ANIM_FRAME_END

gem_explosion_frame_2:
	ANIM_SPRITE($00, TILE_EXPLOSION_2, $00, $00) ; Y, tile, attr, X
	ANIM_FRAME_END

gem_explosion_frame_3:
	ANIM_SPRITE($00, TILE_EXPLOSION_3, $00, $00) ; Y, tile, attr, X
	ANIM_SPRITE($fc, TILE_EXPLOSION_1, $00, $fc)
	ANIM_SPRITE($04, TILE_EXPLOSION_1, $00, $02)
	ANIM_FRAME_END

gem_explosion_frame_4:
	ANIM_SPRITE($00, TILE_EXPLOSION_4, $00, $00) ; Y, tile, attr, X
	ANIM_SPRITE($fb, TILE_EXPLOSION_2, $00, $fb)
	ANIM_SPRITE($05, TILE_EXPLOSION_2, $00, $03)
	ANIM_SPRITE($f8, TILE_EXPLOSION_1, $00, $f9)
	ANIM_SPRITE($02, TILE_EXPLOSION_1, $00, $02)
	ANIM_FRAME_END

gem_explosion_frame_5:
	ANIM_SPRITE($00, TILE_EXPLOSION_5, $00, $00) ; Y, tile, attr, X
	ANIM_SPRITE($fa, TILE_EXPLOSION_3, $00, $f9)
	ANIM_SPRITE($06, TILE_EXPLOSION_3, $00, $03)
	ANIM_SPRITE($f6, TILE_EXPLOSION_2, $00, $f9)
	ANIM_SPRITE($02, TILE_EXPLOSION_2, $00, $03)
	ANIM_FRAME_END

gem_explosion_frame_6:
	ANIM_SPRITE($f9, TILE_EXPLOSION_4, $00, $f8) ; Y, tile, attr, X
	ANIM_SPRITE($07, TILE_EXPLOSION_4, $00, $04)
	ANIM_SPRITE($f4, TILE_EXPLOSION_3, $00, $f8)
	ANIM_SPRITE($03, TILE_EXPLOSION_3, $00, $05)
	ANIM_FRAME_END

gem_explosion_frame_7:
	ANIM_SPRITE($f8, TILE_EXPLOSION_5, $00, $f6) ; Y, tile, attr, X
	ANIM_SPRITE($08, TILE_EXPLOSION_5, $00, $05)
	ANIM_SPRITE($f1, TILE_EXPLOSION_4, $00, $f7)
	ANIM_SPRITE($04, TILE_EXPLOSION_4, $00, $07)
	ANIM_FRAME_END

gem_explosion_frame_8:
	ANIM_SPRITE($f1, TILE_EXPLOSION_5, $00, $f7) ; Y, tile, attr, X
	ANIM_SPRITE($04, TILE_EXPLOSION_5, $00, $07)
	ANIM_FRAME_END

gem_explosion_frame_last:
	ANIM_FRAME_END

;
; Buff animation
;
; Must have exactly 8 frames (hardcoded animation loop in stage's logic)
;

gem_buff_last_frame_index:
	.byt 7
gem_buff_frames_addr_lsb:
	.byt <gem_buff_frame_8
	.byt <gem_buff_frame_7
	.byt <gem_buff_frame_6
	.byt <gem_buff_frame_5
	.byt <gem_buff_frame_4
	.byt <gem_buff_frame_3
	.byt <gem_buff_frame_2
	.byt <gem_buff_frame_1
gem_buff_frames_addr_msb:
	.byt >gem_buff_frame_8
	.byt >gem_buff_frame_7
	.byt >gem_buff_frame_6
	.byt >gem_buff_frame_5
	.byt >gem_buff_frame_4
	.byt >gem_buff_frame_3
	.byt >gem_buff_frame_2
	.byt >gem_buff_frame_1

gem_buff_frame_1:
	ANIM_SPRITE($08, TILE_POWER_FLAMES_TINY_1, $01, $f9) ; Y, tile, attr, X
	ANIM_SPRITE($08, TILE_POWER_FLAMES_TINY_1, $41, $07)
	ANIM_FRAME_END

gem_buff_frame_2:
	ANIM_SPRITE($08, TILE_POWER_FLAMES_TINY_2, $01, $f9) ; Y, tile, attr, X
	ANIM_SPRITE($08, TILE_POWER_FLAMES_TINY_2, $41, $07)
	ANIM_FRAME_END

gem_buff_frame_3:
	ANIM_SPRITE($08, TILE_POWER_FLAMES_LITTLE_1, $01, $f9) ; Y, tile, attr, X
	ANIM_SPRITE($08, TILE_POWER_FLAMES_LITTLE_1, $41, $07)
	ANIM_FRAME_END

gem_buff_frame_4:
	ANIM_SPRITE($08, TILE_POWER_FLAMES_LITTLE_2, $01, $f9) ; Y, tile, attr, X
	ANIM_SPRITE($08, TILE_POWER_FLAMES_LITTLE_2, $41, $07)
	ANIM_FRAME_END

gem_buff_frame_5:
	ANIM_SPRITE($08, TILE_POWER_FLAMES_MEDIUM_1, $01, $f9) ; Y, tile, attr, X
	ANIM_SPRITE($08, TILE_POWER_FLAMES_MEDIUM_1, $41, $07)
	ANIM_FRAME_END

gem_buff_frame_6:
	ANIM_SPRITE($08, TILE_POWER_FLAMES_MEDIUM_2, $01, $f9) ; Y, tile, attr, X
	ANIM_SPRITE($08, TILE_POWER_FLAMES_MEDIUM_2, $41, $07)
	ANIM_FRAME_END

gem_buff_frame_7:
	ANIM_SPRITE($08, TILE_POWER_FLAMES_LARGE_1, $01, $f9) ; Y, tile, attr, X
	ANIM_SPRITE($08, TILE_POWER_FLAMES_LARGE_1, $41, $07)
	ANIM_FRAME_END

gem_buff_frame_8:
	ANIM_SPRITE($08, TILE_POWER_FLAMES_LARGE_2, $01, $f9) ; Y, tile, attr, X
	ANIM_SPRITE($08, TILE_POWER_FLAMES_LARGE_2, $41, $07)
	ANIM_FRAME_END
