;;;;;;;;;;;;;;;;;;;;;;;;;
; Extra animation fields
;;;;;;;;;;;;;;;;;;;;;;;;;

#define ANIM_DIRECT_HITBOX(enabled,damages,base_h,base_v,force_h,force_v,left,right,top,bottom) .byt $01, left, right, <base_h, >base_h, <force_h, >force_h, top, bottom, <base_v, >base_v, <force_v, >force_v, damages, enabled
#define ANIM_CUSTOM_HITBOX(enabled,left,right,top,bottom,routine) .byt $01, left, right, 0, 0, , >routine, top, bottom, 0, 0, 0, <routine, 0, enabled
#define ANIM_NULL_HITBOX .byt $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

#define ANIM_HURTBOX(left,right,top,bottom) .byt left, right, top, bottom
#define ANIM_NULL_HURTBOX .byt $00, $00, $00, $00

#define ANIM_DEFAULT_HEADER ANIM_NULL_HURTBOX : ANIM_NULL_HITBOX

ANIMATION_FRAME_HURTBOX_BEGIN = 1
ANIMATION_FRAME_SPRITES_BEGIN = ANIMATION_FRAME_HURTBOX_BEGIN + 4 + 15

;;;;;;;;;;;;;;;;;;;;;;;;;
; Animation hooks
;;;;;;;;;;;;;;;;;;;;;;;;;

; Hook called when the sprite handler wants to load attributes from its entry
;  Here we add "2 * player_num" to fetched attributes, so
;  player A uses palettes 0 and 1
;  player B uses palettes 2 and 3
#define ANIM_HOOK_SPRITE_ATTRIBUTES .(:\
	lda player_number:\
	asl:\
	clc:\
	adc (frame_vector), y:\
.)

; Hook called when the sprite handler wants to load the tile number from its entry
;  Here we add "96 * player_num" to fetched tile number, so
;  player A uses tiles 0 to 95
;  player B uses tiles 96 to 191
#define ANIM_HOOK_TILE_NUMBER .(:\
	lda player_number:\
	bne player_b:\
\
		; player A, just return tile number:\
		lda (frame_vector), y:\
		jmp end_anim_hook:\
\
	player_b:\
\
		; Player B, return tile number + 96:\
		;  If the original tile number is >= 96, it is not a char specific tile, do not do the addition:\
		lda (frame_vector), y:\
		cmp #CHARACTERS_NUM_TILES_PER_CHAR:\
		bcs end_anim_hook:\
			clc:\
			adc #CHARACTERS_NUM_TILES_PER_CHAR:\
\
	end_anim_hook:\
.)
