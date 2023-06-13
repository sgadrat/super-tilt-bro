MENU_CREDITS_CREDITS_BANK = CURRENT_BANK_NUMBER

.(
&menu_credits_pages_illustration_lsb:
	.byt <menu_credits_illustration_graphics
	.byt <menu_credits_illustration_music
	.byt <menu_credits_illustration_characters
	.byt <menu_credits_illustration_characters
	.byt <menu_credits_illustration_special_thanks
	.byt <menu_credits_illustration_special_thanks
	.byt <menu_credits_illustration_special_thanks
	.byt <menu_credits_illustration_special_thanks
	.byt <menu_credits_illustration_author
&menu_credits_pages_illustration_msb:
	.byt >menu_credits_illustration_graphics
	.byt >menu_credits_illustration_music
	.byt >menu_credits_illustration_characters
	.byt >menu_credits_illustration_characters
	.byt >menu_credits_illustration_special_thanks
	.byt >menu_credits_illustration_special_thanks
	.byt >menu_credits_illustration_special_thanks
	.byt >menu_credits_illustration_special_thanks
	.byt >menu_credits_illustration_author
&menu_credits_pages_illustration_bank:
	.byt MENU_CREDITS_ILLUSTRATION_GRAPHICS_BANK_NUMBER
	.byt MENU_CREDITS_ILLUSTRATION_MUSIC_BANK_NUMBER
	.byt MENU_CREDITS_ILLUSTRATION_CHARACTERS_BANK_NUMBER
	.byt MENU_CREDITS_ILLUSTRATION_CHARACTERS_BANK_NUMBER
	.byt MENU_CREDITS_ILLUSTRATION_SPECIAL_THANKS_BANK_NUMBER
	.byt MENU_CREDITS_ILLUSTRATION_SPECIAL_THANKS_BANK_NUMBER
	.byt MENU_CREDITS_ILLUSTRATION_SPECIAL_THANKS_BANK_NUMBER
	.byt MENU_CREDITS_ILLUSTRATION_SPECIAL_THANKS_BANK_NUMBER
	.byt MENU_CREDITS_ILLUSTRATION_AUTHOR_BANK_NUMBER
&menu_credits_pages_text_lsb:
	.byt <text_graphics
	.byt <text_musics
	.byt <text_characters1
	.byt <text_characters2
	.byt <text_special_thanks1
	.byt <text_special_thanks2
	.byt <text_special_thanks3
	.byt <text_special_thanks4
	.byt <text_author
&menu_credits_pages_text_msb:
	.byt >text_graphics
	.byt >text_musics
	.byt >text_characters1
	.byt >text_characters2
	.byt >text_special_thanks1
	.byt >text_special_thanks2
	.byt >text_special_thanks3
	.byt >text_special_thanks4
	.byt >text_author
pages_end:

&MENU_CREDITS_NB_PAGES = pages_end-menu_credits_pages_text_msb

text_graphics:
	.byt "   <GRAPHICS>   "
	.byt "                "
	.byt "                "
	.byt "  Casual Cart   "
	.byt "                "
	.byt "  Fawzi Zaidi   "
	.byt "                "
	.byt "      Fei       "
	.byt "                "
	.byt "Margarita Gadrat"
	.byt "                "
	.byt "Martin Le Borgne"
	.byt "                "

text_musics:
	.byt "     <MUSIC>    "
	.byt "                "
	.byt "                "
	.byt "Adventure theme "
	.byt "Sinbad theme    "
	.byt "    #By Kilirane"
	.byt "                "
	.byt "I like jump rope"
	.byt "Perihelium      "
	.byt "    #By Ozzed   "
	.byt "                "
	.byt "Super Tilt Bro. "
	.byt "    #By Tui     "

text_characters1:
	.byt "  <CHARACTERS>  "
	.byt "                "
	.byt "                "
	.byt "      KIKI      "
	.byt "   from Krita   "
	.byt "  By Tyson Tan  "
	.byt "                "
	.byt "     PEPPER     "
	.byt "f. Pepper&Carrot"
	.byt " By David Revoy "
	.byt "                "
	.byt "                "
	.byt "                "

text_characters2:
	.byt "  <CHARACTERS>  "
	.byt "                "
	.byt "                "
	.byt "     SINBAD     "
	.byt "   from Ogre3D  "
	.byt "    By Zi Ye    "
	.byt "                "
	.byt "     VGSAGE     "
	.byt "f. VideoGameSage"
	.byt "  By VGS Staff  "
	.byt "                "
	.byt "                "
	.byt "                "

text_special_thanks1:
	.byt "<SPECIAL THANKS>"
	.byt "                "
	.byt "                "
	.byt "  Antoine Gohin "
	.byt "                "
	.byt "  BacteriaMage  "
	.byt "                "
	.byt "  Benoit Ryder  "
	.byt "                "
	.byt "    Bjorn Nah   "
	.byt "                "
	.byt "     Daria      "
	.byt "   Zhuravleva   "

text_special_thanks2:
	.byt "<SPECIAL THANKS>"
	.byt "                "
	.byt "     Dennis     "
	.byt "  van den Broek "
	.byt "                "
	.byt "       Fei      "
	.byt "                "
	.byt "      Issa      "
	.byt "                "
	.byt "  Keenan Hecht  "
	.byt "                "
	.byt "Margarita Gadrat"
	.byt "                "

text_special_thanks3:
	.byt "<SPECIAL THANKS>"
	.byt "                "
	.byt "    Smiley09    "
	.byt "                "
	.byt "  SuperGameLand "
	.byt "                "
	.byt "      Tui       "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "

text_special_thanks4:
	.byt "<SPECIAL THANKS>"
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "   ", $e0, $e1, $e2, $e0, $e1, $e2, $e3, $e4, $e5, "    "
	.byt "   ", $e6, $e7, $e8, $e6, $e7, $e8, $e9, $ea, $eb, "    "
	.byt "   ", $ec, $ed, $ee, $ef, $f0, $f1, $f2, $f3, $f4, "    "
	.byt "   ", $f5, $f6, $f7, $f8, $f9, $fa, $fb, $fc, $fd, "    "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "

text_author:
	.byt "    <AUTHOR>    "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt " Sylvain Gadrat "
	.byt " (Roger Bidon)  "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
.)
