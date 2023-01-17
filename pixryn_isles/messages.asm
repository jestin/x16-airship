; This file is built by an assembler, but not actually built into the
; application.  Instead, it will be loaded up as data by the main program.

; These are dummy values, only here to keep the assembler from complaining
.org $A000
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "RODATA"

.word campfire_sign
.word home_sign
.word tavern_sign
.word fell_down_cave
.word found_a_trapdoor
.word wipe_feet
.word cave_entrance_sign
.word deliveries_ahead
.word nothing_here
.word lock_clicks
.word locked_door
.word wheres_grandma
.word dirigible_shop_sign
.word welcome_1
.word welcome_2
.word welcome_3
.word welcome_4
.word welcome_5
.word welcome_6
.word welcome_7
.word welcome_8

campfire_sign:					.literal "Come sit with us", $00
home_sign:						.literal "Welcome home!", $00
tavern_sign:					.literal "The Bloated Sturge", $00
fell_down_cave:					.literal "You fell down a hole into a cave!", $00
found_a_trapdoor:				.literal "You found a trapdoor!", $00
wipe_feet:						.literal "Please wipe your feet", $00
cave_entrance_sign:				.literal "Watch for falling objects and people", $00
deliveries_ahead:				.literal "All deliveries ahead", $00
nothing_here:					.literal "Nothing to see here", $00
lock_clicks:					.literal "A lock clicks behind you", $00
locked_door:					.literal "The door is locked", $00
wheres_grandma:					.literal "Have you seen Grandma?", $00
dirigible_shop_sign:			.literal "Dagnol's New and Used Dirigibles", $00

; dialogs

welcome_1:						.literal "   Welcome to the Pixryn", $00
welcome_2:						.literal " Islands! This archipelago", $00
welcome_3:						.literal "is home to some of the best", $00
welcome_4:						.literal " airship mechanics in the", $00
welcome_5:						.literal " world.  The residents of", $00
welcome_6:						.literal "  Pixryn rely on airship", $00
welcome_7:						.literal "travel to live and work in", $00
welcome_8:						.literal "the sunny island paradise!", $00
