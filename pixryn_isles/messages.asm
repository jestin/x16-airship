.org $A000
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"

.word campfire_sign
.word home_sign
.word tavern_sign
.word fell_down_cave
.word found_a_trapdoor

home_sign:			.literal "Welcome home!", $00
campfire_sign:		.literal "Come sit with us", $00
tavern_sign:		.literal "The Bloated Sturge", $00
fell_down_cave:		.literal "You fell down a hole into a cave!", $00
found_a_trapdoor:	.literal "You found a trapdoor!", $00
