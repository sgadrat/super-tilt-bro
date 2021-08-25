#if CURRENT_BANK_NUMBER <> MENU_CONFIG_TILESET_BANK_NUMBER
#error spriteset and tileset are expected to be in the same bank
#endif

tileset_menu_config_sprites:

; Tileset's size in tiles (zero means 256)
.byt (tileset_menu_config_sprites_end-tileset_menu_config_sprites_tiles)/16

tileset_menu_config_sprites_tiles:

TILE_MENU_CONFIG_SPRITES_CORNER = (*-tileset_menu_config_sprites_tiles)/16
.byt %01110000, %11000000, %11000000, %11000000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
TILE_MENU_CONFIG_SPRITES_ARROW_HORIZONTAL = (*-tileset_menu_config_sprites_tiles)/16
.byt %00000000, %11100000, %11111100, %11111111, %11111111, %11111100, %11100000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
tileset_menu_config_sprites_end:
