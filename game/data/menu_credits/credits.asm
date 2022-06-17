MENU_CREDITS_CREDITS_BANK = CURRENT_BANK_NUMBER

.(
&menu_credits_pages_illustration_lsb:
	.byt <menu_credits_illustration_graphics,       <menu_credits_illustration_music,          <menu_credits_illustration_characters
	.byt <menu_credits_illustration_special_thanks, <menu_credits_illustration_special_thanks, <menu_credits_illustration_author
&menu_credits_pages_illustration_msb:
	.byt >menu_credits_illustration_graphics,       >menu_credits_illustration_music,          >menu_credits_illustration_characters
	.byt >menu_credits_illustration_special_thanks, >menu_credits_illustration_special_thanks, >menu_credits_illustration_author
&menu_credits_pages_illustration_bank:
	.byt MENU_CREDITS_ILLUSTRATION_GRAPHICS_BANK_NUMBER,       MENU_CREDITS_ILLUSTRATION_MUSIC_BANK_NUMBER,          MENU_CREDITS_ILLUSTRATION_CHARACTERS_BANK_NUMBER
	.byt MENU_CREDITS_ILLUSTRATION_SPECIAL_THANKS_BANK_NUMBER, MENU_CREDITS_ILLUSTRATION_SPECIAL_THANKS_BANK_NUMBER, MENU_CREDITS_ILLUSTRATION_AUTHOR_BANK_NUMBER
&menu_credits_pages_text_lsb:
	.byt <text_graphics,        <text_musics,          <text_characters
	.byt <text_special_thanks1, <text_special_thanks2, <text_author
&menu_credits_pages_text_msb:
	.byt >text_graphics,        >text_musics,          >text_characters
	.byt >text_special_thanks1, >text_special_thanks2, >text_author
pages_end:

&MENU_CREDITS_NB_PAGES = pages_end-menu_credits_pages_text_msb

text_graphics:
	.byt "   <GRAPHICS>   "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "      Fei       "
	.byt "                "
	.byt "Margarita Gadrat"
	.byt "                "
	.byt "Martin Le Borgne"
	.byt "                "
	.byt "                "
	.byt "                "
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

text_characters:
	.byt "  <CHARACTERS>  "
	.byt "                "
	.byt "      KIKI      "
	.byt "   from Krita   "
	.byt "  By Tyson Tan  "
	.byt "                "
	.byt "     PEPPER     "
	.byt "f. Pepper&Carrot"
	.byt " By David Revoy "
	.byt "                "
	.byt "     SINBAD     "
	.byt "   from Ogre3D  "
	.byt "    By Zi Ye    "

text_special_thanks1:
	.byt "<SPECIAL THANKS>"
	.byt "                "
	.byt "  Antoine Gohin "
	.byt "                "
	.byt "  BacteriaMage  "
	.byt "                "
	.byt "  Benoit Ryder  "
	.byt "                "
	.byt "    Bjorn Nah   "
	.byt "                "
	.byt "       Fei      "
	.byt "                "
	.byt "                "

text_special_thanks2:
	.byt "<SPECIAL THANKS>"
	.byt "                "
	.byt "     Dennis     "
	.byt "  van den Broek "
	.byt "                "
	.byt "  Keenan Hecht  "
	.byt "                "
	.byt "Margarita Gadrat"
	.byt "                "
	.byt "  supergameland "
	.byt "                "
	.byt "      Tui       "
	.byt "                "

text_author:
	.byt "    <AUTHOR>    "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "  Sylvain Gadrat"
	.byt "  (Roger Bidon) "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
	.byt "                "
.)
