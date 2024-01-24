+ARCADE_MODE_EXTRA_BANK_NUMBER = CURRENT_BANK_NUMBER

#include "game/logic/game_states/arcade_mode/counter.asm"
#include "game/logic/game_states/arcade_mode/arcade_mode.built.asm"
#include "game/logic/game_states/arcade_mode/ingame_hooks.asm"

.(
+ENCOUNTER_FIGHT = 0
+ENCOUNTER_RUN = 1
+ENCOUNTER_TARGETS = 2
+ENCOUNTER_CUTSCENE = 3
+ENCOUNTER_GAMEOVER = 4

+ENCOUNTER_ENTRY_SIZE = 9

#define ARCADE_FIGHT(character,difficulty,skin,stage,silvers,silverf,golds,goldf) \
	.byt ENCOUNTER_FIGHT, character, difficulty, skin, stage, silverf, silvers, goldf, golds
#define ARCADE_RUN(stage,silvers,silverf,golds,goldf) \
	.byt ENCOUNTER_RUN, stage, silverf, silvers, goldf, golds, 0, 0, 0
#define ARCADE_TARGETS(stage,silvers,silverf,golds,goldf) \
	.byt ENCOUNTER_TARGETS, stage, silverf, silvers, goldf, golds, 0, 0, 0
#define ARCADE_CUTSCENE(info,bank) \
	.byt ENCOUNTER_CUTSCENE, <info, >info, <bank, 0, 0, 0, 0, 0

+arcade_encounters:
	ARCADE_CUTSCENE(cutscene_sinbad_story_bird_msg, cutscene_sinbad_story_bird_msg_bank)
	ARCADE_RUN(stage_arcade_run01_index, 6,0, 4,30)
	ARCADE_CUTSCENE(cutscene_sinbad_story_sinbad_encounter, cutscene_sinbad_story_sinbad_encounter_bank)
	ARCADE_FIGHT(0, 1, 0, stage_arcade_fight_port_index, 15,0, 6,0)
	ARCADE_TARGETS(stage_arcade_btt01_index, 21,0, 12,0)
	ARCADE_CUTSCENE(cutscene_sinbad_story_kiki_encounter, cutscene_sinbad_story_kiki_encounter_bank)
	ARCADE_FIGHT(1, 2, 0, stage_arcade_fight_town_index, 30,0, 15,0)
	ARCADE_RUN(stage_arcade_run02_index, 14,0, 7,0)
	ARCADE_CUTSCENE(cutscene_sinbad_story_pepper_encounter, cutscene_sinbad_story_pepper_encounter_bank)
	ARCADE_FIGHT(2, 3, 0, stage_arcade_fight_wall_index, 30,0, 10,0)
	ARCADE_TARGETS(stage_arcade_btt02_index, 20,0, 12,0)
	ARCADE_CUTSCENE(cutscene_sinbad_story_meteor, cutscene_sinbad_story_meteor_bank)
	ARCADE_FIGHT(0, 4, 1, stage_arcade_boss_index, 90,0, 45,0)
	ARCADE_CUTSCENE(cutscene_sinbad_story_ending, cutscene_sinbad_story_ending_bank)

+arcade_n_encounters = (* - arcade_encounters) / ENCOUNTER_ENTRY_SIZE
.)
