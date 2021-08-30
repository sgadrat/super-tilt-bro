MENU_SUPPORT_SCREEN_BANK_NUMBER = CURRENT_BANK_NUMBER

#include "game/data/menu_support/nametable_bg.asm"

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

&palette_support:
; Background
;    0-sky/box,       1-title,         2-active_option, 3-unused
.byt $21,$0f,$00,$20, $21,$0f,$28,$20, $21,$0f,$00,$28, $21,$00,$00,$00
; Sprites
;    0-unused,        1-unused,        2-unused,        3-clouds
.byt $21,$00,$00,$00, $21,$00,$00,$00, $21,$00,$00,$00, $21,$0f,$00,$31

&menu_support_contents:
.asc "Super Tilt Bro. is a    "
.asc "passion project.        "
.asc "                        "
.asc "Your support means a lot"
.asc "Thank you!              "
.asc "                        "
.asc "Be it money or cheering,"
.asc "every bit helps to keep "
.asc "us going.               "
.asc "                        "
.asc "                        "
.asc "                        "
.asc "HTTP  super-tilt-bro.com"
.asc "TWITTER  @SuperTiltBro  "
.asc "DISCORD  discord/qkxHkfx"
.asc "                        "
.asc "  Bitcoin      Paypal   "
.asc "                        "

&menu_support_contents_btc:
.byt " BTC  ", QE,QC,QC,QA,Q6,Q9,QE,Q3,Q8,QE,QC,QC,QA, "XOXO "
.byt "      ", QA,QF,QA,QA,QD,QB,QC,Q5,QA,QA,QF,QA,QA, " XOXO"
.byt "      ", QA,QC,Q8,QA,QB,Q0,QA,QD,QA,QA,QC,Q8,QA, "     "
.byt "REBELZ", QC,QC,QC,Q8,QB,Q9,QB,QB,Q8,QC,QC,QC,Q8, "So   "
.byt "      ", QE,Q6,Q1,QD,Q2,QE,QE,Q0,Q9,QD,QA,QF,Q0, " geek"
.byt "      ", QF,Q4,Q9,QD,Q4,Q9,Q5,Q7,QC,Q8,Q2,QA,Q0, "     "
.byt "      ", Q8,Q7,Q7,QD,Q3,Q7,Q7,Q4,Q1,QD,Q8,Q0,QA, "     "
.byt "      ", Q9,Q9,Q1,QC,Q9,QE,QE,Q5,QC,Q1,Q5,QC,Q2, "     "
.byt "      ", QC,Q8,Q8,Q8,QB,QA,QF,Q3,QE,QC,QB,QF,Q0, "NERD "
.byt "      ", QE,QC,QC,QA,QC,QE,QC,Q4,QA,Q8,QA,Q2,Q8, "4LIFE"
.byt "CYPHER", QA,QF,QA,QA,Q3,QE,Q3,Q9,QE,QE,QE,QA,Q8, "     "
.byt " PUNKS", QA,QC,Q8,QA,Q2,QF,Q9,QB,QC,QC,Q3,Q0,QA, "     "
.byt "      ", QC,QC,QC,Q8,QC,QC,QC,Q0,Q0,Q0,Q8,Q8,Q8, "     "
.byt "                        "
.byt "  BC1QL3U5MZVFXK0JTFTNM "
.byt "  8QSHVVAHTVPNRV6HSJLSN "
.byt "                        "
.byt "                        "

&menu_support_contents_paypal:
.byt "      ", QE,QC,QC,QA,Q2,QA,Q9,QB,Q8,QE,QC,QC,QA, "     "
.byt "      ", QA,QF,QA,QA,Q3,Q2,QB,Q6,Q8,QA,QF,QA,QA, "     "
.byt "      ", QA,QC,Q8,QA,Q7,Q1,Q2,Q1,QA,QA,QC,Q8,QA, "     "
.byt "      ", QC,QC,QC,Q8,Q9,QB,Q8,QB,Q8,QC,QC,QC,Q8, "     "
.byt "      ", QF,QC,Q9,QD,QE,Q6,QF,Q8,QE,Q5,Q4,Q5,Q0, "     "
.byt "      ", QD,Q9,Q8,QD,QA,Q8,Q8,Q6,QC,Q6,Q1,QD,Q8, "     "
.byt "      ", Q2,Q8,Q9,Q9,QE,Q9,Q5,QC,QA,Q9,QC,QF,Q8, "     "
.byt "      ", QA,Q4,Q2,QD,QE,Q0,Q6,QC,QE,Q0,Q4,QD,Q8, "     "
.byt "      ", Q8,Q0,Q4,Q8,QB,Q9,QC,Q9,QE,QC,QB,QD,Q8, "     "
.byt "      ", QE,QC,QC,QA,Q8,Q9,QE,QB,QA,Q8,QE,Q5,Q8, "     "
.byt "      ", QA,QF,QA,QA,QF,QB,Q4,QC,QD,QF,QF,Q9,Q2, "     "
.byt "      ", QA,QC,Q8,QA,QB,Q2,Q8,Q3,Q3,Q5,Q0,Q0,QA, "     "
.byt "      ", QC,QC,QC,Q8,QC,Q0,QC,Q8,Q4,Q8,Q8,QC,Q8, "     "
.byt "                        "
.byt "                        "
.byt " paypal.me/SylvainGadrat"
.byt "                        "
.byt "                        "
.)
