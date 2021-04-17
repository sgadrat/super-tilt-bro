#include "nine/prg_rom/utils.asm"
#include "nine/prg_rom/animations.asm"
#include "nine/prg_rom/collisions.asm"
ninegine_audio_engine_begin:
#include "nine/prg_rom/audio.asm"
ninegine_audio_engine_end:
#include "nine/prg_rom/particle.asm"
#include "nine/prg_rom/particle_handlers.asm"

#echo
#echo audio engine size:
#print ninegine_audio_engine_end-ninegine_audio_engine_begin
