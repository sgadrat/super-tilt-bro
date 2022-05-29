; Call a subroutine for each element of the current stage
;  tmpfield1, tmpfield2 - subroutine to call
;  register Y - offset of the first element from "stage_data"
;
;  Overwrites register A and register Y.
;
; For each call
;  - the element can be accessed at address "stage_data, y",
;  - register A contains the element type.
;
; Called subroutine can stop the iteration by setting Y to $ff, else
; it must not modify the Y register.
;
; Called subroutine must not modify tmpfield1 nor tmpfield2.
#define STAGE_ITERATE_ELEMENTS() \
.(:\
	check_current_element::\
		lda stage_data, y:\
		beq end_iterate_elements:\
:\
		; Call element handler:\
		jsr call_pointed_subroutine:\
		cpy #$ff:\
		beq end:\
:\
		; Update offset to next element:\
		tya:\
		;clc ; useless, cpy cleared cary flag:\
		adc #STAGE_ELEMENT_SIZE:\
		tay:\
:\
		; Handle next element:\
		jmp check_current_element:\
:\
	end_iterate_elements:\
.)

; Call a subroutine for each element of the current stage plus player handled elements
;  tmpfield1, tmpfield2 - subroutine to call
;
;  Overwrites register A and register Y.
;
; For each call, the element can be accessed at address
; "stage_data, y"
;
; Called subroutine can stop the iteration by setting Y to $ff, else
; it must not modify the Y register.
;
; Called subroutine must not modify tmpfield1 nor tmpfield2.
stage_iterate_all_elements:
.(
	ldy #STAGE_OFFSET_ELEMENTS
	STAGE_ITERATE_ELEMENTS()
	cpy #$ff
	beq end

#if player_a_objects < stage_data
#error following code assumes player_a_objects to be after stage data for less than 255 bytes
#endif
#if player_a_objects-stage_data > 255
#error following code assumes player_a_objects to be after stage data for less than 255 bytes
#endif
	ldy #player_a_objects-stage_data
	STAGE_ITERATE_ELEMENTS()
	cpy #$ff
	beq end

#if player_b_objects < stage_data
#error following code assumes player_a_objects to be after stage data for less than 255 bytes
#endif
#if player_b_objects-stage_data > 255
#error following code assumes player_a_objects to be after stage data for less than 255 bytes
#endif
	ldy #player_b_objects-stage_data
	STAGE_ITERATE_ELEMENTS()
	cpy #$ff ; TODO investigate - if no code checks Z flag after calling this routine, then this instruction is unecessary
	;beq end ; useless - fallthrough

	end:
	rts
.)
