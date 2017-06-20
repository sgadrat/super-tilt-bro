; Main palette for character
character_palettes:
.byt $08, $1a, $20 ; border=brown skin=green pants=white
.byt $08, $16, $10 ; border=brown skin=red   pants=light-grey

; Alternate palette to use to reflect special state
character_palettes_alternate:
.byt $37, $3a, $20
.byt $37, $33, $20

; Character palette name
character_names:
.byt $39, $42, $37, $49, $49, $3f, $39, $02 ; classic
.byt $3e, $3b, $42, $42, $38, $45, $48, $44 ; hellborn

; Main palettes for weapon
weapon_palettes:
.byt $08, $10, $37 ; border=brown blade=light-grey handle=light-yellow
.byt $08, $28, $37 ; border=brown blade=yellow     handle=light-yellow

; Weapon palette name
weapon_names:
.byt $39, $42, $37, $49, $49, $3f, $39, $02 ; classic
.byt $02, $3d, $45, $42, $3a, $3b, $44, $02 ; golden
