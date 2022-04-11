.org $A000
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"

.word campfire_sign
.word home_sign
.word tavern_sign

home_sign:			.literal "Welcome home!", $00
campfire_sign:		.literal "Come sit with us", $00
tavern_sign:		.literal "The Bloated Sturge", $00
