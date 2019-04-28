; Game specific animation opcodes
;
;  Each opcodes is associated to a handler by the animation_frame_entry_handlers
;  table.
;  Nine-gine's animation routine takes care of parsing animation and calling
;  appropriate handlers.
;
;  Handlers parameters
;   tmpfield1 - Position X LSB
;   tmpfield2 - Position Y LSB
;   tmpfield3, tmpfield4 - Vector pointing to the frame to draw
;   tmpfield5 - First sprite index to use
;   tmpfield6 - Last sprite index to use
;   tmpfield7 - Animation's direction (0 normal, 1 flipped)
;   tmpfield8 - Position X MSB
;   tmpfield9 - Position Y MSB
;   tmpfield10 - Opcode of the entry
;   register Y - Index of the etnry's first byte in the frame vector (payload byte, not opcode)
;
;  Handlers outputs
;   tmpfield5 is updated to stay on the next free sprite
;   tmpfield6 is updated to stay on the last free sprite
;   registerY is advanced to the first byte after the entry
;
;  Handlers may freely modify
;   tmpfield11 to tmpfield16
;   registers A and X
;

animation_frame_entry_handlers_lsb:
.byt <anim_frame_move_sprite, <anim_frame_move_sprite
.byt <remove_me1, <remove_me2 ; TODO hack need to be replaced by actual code
animation_frame_entry_handlers_msb:
.byt >anim_frame_move_sprite, >anim_frame_move_sprite
.byt >remove_me1, >remove_me2 ; TODO hack

remove_me1:
.(
	tya
	clc
	adc #$0f-1
	tay
	rts
.)

remove_me2:
.(
	tya
	clc
	adc #$05-1
	tay
	rts
.)
