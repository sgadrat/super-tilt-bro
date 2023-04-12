; Building the project
;  xa tilt.asm -C -o tilt\(E\).nes
;
; Building raw ROMs
;  xa tilt.asm -DNO_INES_HEADER -C -o tilt_prg.bin

; Constants depending on mapper

#define DEFAULT_MAPPER

#ifdef MAPPER_UNROM
#undef DEFAULT_MAPPER
	MAPPER_NUMBER=2
	SUBMAPPER_NUMBER=1
	MAPPER_BATTERY_FLAG=1
	MAPPER_PRG_SIZE=512 ; Size in KB
	MAPPER_CHR_SHIFTS=7 ; Size in shifts (bytes = 64 << shifts)
#endif

#ifdef MAPPER_UNROM512
#undef DEFAULT_MAPPER
	MAPPER_NUMBER=30
	SUBMAPPER_NUMBER=0
	MAPPER_BATTERY_FLAG=1
	MAPPER_PRG_SIZE=512
	MAPPER_CHR_SHIFTS=7
#endif

#ifdef MAPPER_RAINBOW512
#undef DEFAULT_MAPPER
	MAPPER_NUMBER=3872
	SUBMAPPER_NUMBER=0
	MAPPER_BATTERY_FLAG=1
	MAPPER_PRG_SIZE=512
	MAPPER_CHR_SHIFTS=7
#endif

#ifdef DEFAULT_MAPPER
#undef DEFAULT_MAPPER
#define MAPPER_RAINBOW
	MAPPER_NUMBER=682
	SUBMAPPER_NUMBER=0
	MAPPER_BATTERY_FLAG=1
	MAPPER_PRG_SIZE=1024
	MAPPER_CHR_SHIFTS=9	
#endif

; iNES header

#ifndef NO_INES_HEADER
#include "nine/ines_header.asm"
#endif

; No-data declarations

#include "game/constants.asm"
#include "nine/macros.asm"
#include "game/macros.asm"
#include "game/rainbow_lib_macros.asm"
#include "game/animation_extra_declarations.asm"
#include "nine/nes_labels.asm"
#include "game/mem_labels.asm"

; PRG-ROM

#ifndef NO_PRG_ROM

#include "game/banks.built.asm"

#endif
