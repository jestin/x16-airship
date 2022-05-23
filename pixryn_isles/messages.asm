.org $A000
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"

.word campfire_sign
.word home_sign
.word tavern_sign
.word fell_down_cave
.word found_a_trapdoor
.word wipe_feet
.word cave_entrance_sign
.word deliveries_ahead
.word nothing_here

campfire_sign:			.literal "Come sit with us", $00
home_sign:				.literal "Welcome home!", $00
tavern_sign:			.literal "The Bloated Sturge", $00
fell_down_cave:			.literal "You fell down a hole into a cave!", $00
found_a_trapdoor:		.literal "You found a trapdoor!", $00
wipe_feet:				.literal "Please wipe your feet", $00
cave_entrance_sign:		.literal "Watch for falling objects and people", $00
deliveries_ahead:		.literal "All deliveries ahead", $00
nothing_here:			.literal "Nothing to see here", $00
