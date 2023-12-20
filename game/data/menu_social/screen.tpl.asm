+MENU_SOCIAL_SCREEN_BANK_NUMBER = CURRENT_BANK_NUMBER

#include "game/data/menu_social/nametable_bg.asm"

.(
Q0 = 144
Q1 = Q0+1
Q2 = Q0+2
Q3 = Q0+3
Q4 = Q0+4
Q5 = Q0+5
Q6 = Q0+6
Q7 = Q0+7
Q8 = Q0+8
Q9 = Q0+9
QA = Q0+10
QB = Q0+11
QC = Q0+12
QD = Q0+13
QE = Q0+14
QF = Q0+15
SP = $20+128

+palette_social:
; Background
;    0-sky/box,       1-title,         2-active_option, 3-unused
.byt $21,$0f,$00,$20, $21,$0f,$28,$20, $21,$0f,$00,$28, $21,$00,$00,$00
; Sprites
;    0-unused,        1-cursor,        2-unused,        3-clouds
.byt $21,$00,$00,$00, $21,$28,$28,$28, $21,$00,$00,$00, $21,$0f,$00,$31

+menu_social_contents:
!ascii-offset 128 "Super Tilt Bro. is a    "
!ascii-offset 128 "living game.            "
!ascii-offset 128 "                        "
!ascii-offset 128 "The community is here to"
!ascii-offset 128 "help you find a game, to"
!ascii-offset 128 "get news, or simply to  "
!ascii-offset 128 "chat and share.         "
!ascii-offset 128 "                        "
!ascii-offset 128 "We are looking forward  "
!ascii-offset 128 "to meet you!            "
!ascii-offset 128 "                        "
!ascii-offset 128 "                        "
!ascii-offset 128 "        Web site        "
!ascii-offset 128 "        Twitter         "
!ascii-offset 128 "        Discord         "
!ascii-offset 128 "                        "
!ascii-offset 128 "                        "
!ascii-offset 128 "                        "

+menu_social_website_link:
!ascii-offset 128 "                        "
.byt SP,SP,SP,SP,SP,SP, QE,QC,QC,QA,Q2,QA,Q8,QB,Q8,QE,QC,QC,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QF,QA,QA,Q3,Q2,QB,Q4,Q8,QA,QF,QA,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QC,Q8,QA,Q7,Q1,Q6,Q3,QA,QA,QC,Q8,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QC,QC,QC,Q8,Q9,QB,Q8,QB,Q8,QC,QC,QC,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QD,QE,Q9,QC,QC,Q6,QE,Q8,Q7,Q5,Q4,Q5,Q0, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, Q3,Q2,Q4,Q9,Q8,Q9,Q4,Q5,Q7,QE,QC,Q4,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, Q7,Q9,Q0,QC,Q5,QD,QE,QE,QF,QD,Q9,QD,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,Q0,QE,Q8,Q3,Q0,Q4,Q5,QA,QF,QE,Q4,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, Q8,Q8,Q0,QC,QB,QF,QD,Q9,QE,QC,QB,Q8,Q0, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QE,QC,QC,QA,Q8,Q1,Q4,QB,QA,Q8,QB,QD,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QF,QA,QA,QB,Q5,QD,Q5,QF,QE,QB,QB,Q2, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QC,Q8,QA,QA,QB,Q6,QC,Q3,Q3,Q7,Q8,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QC,QC,QC,Q8,Q8,Q0,QC,Q8,Q4,QC,QC,QC,Q8, SP,SP,SP,SP,SP
!ascii-offset 128 "                        "
!ascii-offset 128 "https://                "
!ascii-offset 128 "      super-tilt-bro.com"
!ascii-offset 128 "                        "

+menu_social_twitter_link:
!ascii-offset 128 "                        "
.byt SP,SP,SP,SP,SP,SP, QE,QC,QC,QA,Q2,QB,Q5,QF,Q0,QE,QC,QC,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QF,QA,QA,Q8,QF,Q2,QF,Q8,QA,QF,QA,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QC,Q8,QA,QA,QC,Q1,QD,Q8,QA,QC,Q8,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QC,QC,QC,Q8,QB,QB,QA,QA,Q8,QC,QC,QC,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QF,Q4,Q3,QD,Q4,Q0,QE,Q4,Q8,QE,Q8,QC,Q2, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, Q1,QC,QB,Q9,QF,QA,Q1,Q0,Q5,QE,QA,Q4,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, Q1,QD,QF,Q8,Q0,QE,QA,Q2,Q5,QF,Q5,Q6,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, Q9,Q3,Q1,Q9,Q0,Q7,QF,Q3,Q6,Q4,QA,Q9,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QC,Q8,Q8,Q8,QF,Q2,Q3,Q1,QE,QC,QF,Q8,Q2, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QE,QC,QC,QA,QD,Q8,Q8,Q6,QA,Q8,QF,Q7,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QF,QA,QA,Q7,Q6,Q7,QB,QC,QD,QF,Q7,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QC,Q8,QA,Q6,Q2,Q7,QE,Q7,Q4,Q9,Q8,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QC,QC,QC,Q8,Q8,Q8,QC,Q4,Q8,QC,Q0,Q4,Q8, SP,SP,SP,SP,SP
!ascii-offset 128 "                        "
!ascii-offset 128 "     @SuperTiltBro      "
!ascii-offset 128 "                        "
!ascii-offset 128 "                        "

+menu_social_discord_link:
!ascii-offset 128 "                        "
.byt SP,SP,SP,SP,SP,SP, QE,QC,QC,QA,Q1,Q8,Q0,QF,Q2,QE,QC,QC,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QF,QA,QA,Q9,Q4,Q2,Q5,Q0,QA,QF,QA,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QC,Q8,QA,Q4,Q3,QE,QF,Q0,QA,QC,Q8,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QC,QC,QC,Q8,QA,Q9,Q9,QA,QA,QC,QC,QC,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QD,QB,QF,QD,QB,Q1,QF,Q6,QD,QA,Q0,Q8,Q2, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QB,Q6,QC,Q9,QE,QB,QB,QA,Q0,Q8,QD,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, Q8,QB,QF,Q9,Q3,QF,QC,Q0,QE,QA,Q5,Q4,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, Q9,QE,Q8,QD,Q9,Q3,QD,QA,Q8,QE,Q2,QD,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, Q8,Q8,QC,QC,QA,Q6,Q6,Q2,QE,QC,QF,Q1,Q2, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QE,QC,QC,QA,QE,QA,QB,QC,QA,Q8,QF,Q5,QA, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QF,QA,QA,Q8,Q2,QA,Q0,QE,QD,QF,Q2,Q0, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QA,QC,Q8,QA,QB,Q0,Q1,QD,Q3,Q0,QB,Q1,Q8, SP,SP,SP,SP,SP
.byt SP,SP,SP,SP,SP,SP, QC,QC,QC,Q8,QC,QC,QC,Q4,QC,Q4,Q0,Q4,Q8, SP,SP,SP,SP,SP
!ascii-offset 128 "                        "
!ascii-offset 128 "   discord.gg/qkxHkfx   "
!ascii-offset 128 "                        "
!ascii-offset 128 "                        "
.)
