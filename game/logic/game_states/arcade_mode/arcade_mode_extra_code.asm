ARCADE_MODE_EXTRA_BANK_NUMBER = CURRENT_BANK_NUMBER

#include "game/logic/game_states/arcade_mode/counter.asm"
#include "game/logic/game_states/arcade_mode/arcade_mode.built.asm"
#include "game/logic/game_states/arcade_mode/ingame_hooks.asm"

.(
&ENCOUNTER_FIGHT = 0
&ENCOUNTER_RUN = 1
&ENCOUNTER_TARGETS = 2
&ENCOUNTER_CUTSCENE = 3

ENCOUNTER_ENTRY_SIZE = 5

#define ARCADE_FIGHT(character, difficulty, skin, stage) \
	.byt ENCOUNTER_FIGHT, character, difficulty, skin, stage
#define ARCADE_RUN(stage) \
	.byt ENCOUNTER_RUN, stage, 0, 0, 0
#define ARCADE_TARGETS(stage) \
	.byt ENCOUNTER_TARGETS, stage, 0, 0, 0
#define ARCADE_CUTSCENE(info, bank) \
	.byt ENCOUNTER_CUTSCENE, <info, >info, <bank, 0

&arcade_encounters:
	;FIXME do not commit
	ARCADE_CUTSCENE(cutscene_sinbad_story_bird_msg, cutscene_sinbad_story_bird_msg_bank)
	ARCADE_CUTSCENE(cutscene_sinbad_story_sinbad_encounter, cutscene_sinbad_story_sinbad_encounter_bank)
	ARCADE_CUTSCENE(cutscene_sinbad_story_kiki_encounter, cutscene_sinbad_story_kiki_encounter_bank)
	ARCADE_CUTSCENE(cutscene_sinbad_story_pepper_encounter, cutscene_sinbad_story_pepper_encounter_bank)
	ARCADE_CUTSCENE(cutscene_sinbad_story_meteor, cutscene_sinbad_story_meteor_bank)

	ARCADE_CUTSCENE(cutscene_sinbad_story_bird_msg, cutscene_sinbad_story_bird_msg_bank)
	ARCADE_RUN(stage_arcade_run01_index)
	ARCADE_CUTSCENE(cutscene_sinbad_story_sinbad_encounter, cutscene_sinbad_story_sinbad_encounter_bank)
	ARCADE_FIGHT(0, 1, 0, stage_flatland_index)
	ARCADE_TARGETS(stage_arcade_btt01_index)
	ARCADE_CUTSCENE(cutscene_sinbad_story_kiki_encounter, cutscene_sinbad_story_kiki_encounter_bank)
	ARCADE_FIGHT(1, 2, 0, stage_pit_index)
	ARCADE_RUN(stage_arcade_run02_index)
	ARCADE_CUTSCENE(cutscene_sinbad_story_pepper_encounter, cutscene_sinbad_story_pepper_encounter_bank)
	ARCADE_FIGHT(2, 3, 0, stage_skyride_index)
	ARCADE_TARGETS(stage_arcade_btt02_index)
	ARCADE_CUTSCENE(cutscene_sinbad_story_meteor, cutscene_sinbad_story_meteor_bank)
	ARCADE_FIGHT(0, 4, 1, stage_arcade_boss_index)

&arcade_n_encounters = (* - arcade_encounters) / ENCOUNTER_ENTRY_SIZE
.)
