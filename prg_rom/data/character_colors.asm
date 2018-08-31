; Main palette for character
character_palettes:
.byt $08, $1a, $20 ; border=dark-brown skin=green        pants=white
.byt $08, $16, $10 ; border=dark-brown skin=red          pants=light-grey
.byt $01, $31, $33 ; border=dark-blue  skin=light-blue   pants=light-purple
.byt $08, $18, $29 ; border=dark-brown skin=brown        pants=light-green
.byt $08, $0d, $07 ; border=dark-red   skin=black        pants=red
.byt $08, $28, $20 ; border=dark-brown skin=yellow       pants=white
.byt $04, $24, $38 ; border=dark-pink  skin=pink         pants=light-yellow

; Alternate palette to use to reflect special state
character_palettes_alternate:
.byt $37, $3a, $20
.byt $37, $33, $20
.byt $31, $20, $20
.byt $37, $38, $3a
.byt $37, $10, $36
.byt $37, $20, $20
.byt $33, $33, $20

; Character palette name
character_names:
.byt $42, $3b, $02, $4c, $48, $37, $3f, $02 ; le vrai
.byt $02, $3a, $3b, $43, $45, $44, $02, $02 ; demon
.byt $02, $02, $4f, $3b, $4a, $3f, $02, $02 ; yeti
.byt $02, $02, $3b, $42, $3c, $3b, $02, $02 ; elfe
.byt $02, $4c, $3f, $42, $37, $3f, $44, $02 ; vilain
.byt $02, $49, $4b, $46, $3b, $48, $02, $02 ; super
.byt $02, $49, $37, $41, $4b, $48, $37, $02 ; sakura

; Main palettes for weapon
weapon_palettes:
.byt $08, $10, $37 ; border=dark-brown blade=light-grey  handle=light-yellow
.byt $08, $28, $37 ; border=dark-brown blade=yellow      handle=light-yellow
.byt $01, $31, $33 ; border=dark-blue  blade=light-blue  handle=light-purple
.byt $08, $18, $29 ; border=dark-brown blade=brown       handle=light-green
.byt $0d, $0d, $00 ; border=black      blade=black       handle=dark-grey
.byt $04, $24, $37 ; border=dark-pink  blade=pink        handle=light-yellow
.byt $08, $16, $37 ; border=dark-brown blade=red         handle=light-green

; Weapon palette name
weapon_names:
.byt $02, $02, $3d, $48, $45, $49, $02, $02 ; gros
.byt $02, $02, $38, $3b, $37, $4b, $02, $02 ; beau
.byt $3d, $42, $37, $39, $3f, $37, $42, $02 ; glacial
.byt $02, $02, $3b, $39, $45, $02, $02, $02 ; eco
.byt $02, $43, $37, $4b, $3a, $3f, $4a, $02 ; maudit
.byt $02, $43, $3f, $3d, $44, $45, $44, $02 ; mignon
.byt $43, $3b, $39, $3e, $37, $44, $4a, $02 ; mechant
