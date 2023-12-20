;
; Sprites tileset
;

+tileset_menu_social_sprites:

; Tileset's size in tiles (zero means 256)
.byt (tileset_menu_social_sprites_end-tileset_menu_social_sprites_tiles)/16

tileset_menu_social_sprites_tiles:
+TILE_MENU_SOCIAL_SPRITES_CORNER = (*-tileset_menu_social_sprites_tiles)/16
.byt %01110000, %11000000, %11000000, %11000000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
+TILE_MENU_SOCIAL_SPRITES_ARROW_VERTICAL = (*-tileset_menu_social_sprites_tiles)/16
.byt %00010000, %00111000, %01111100, %11111110, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
tileset_menu_social_sprites_end:
