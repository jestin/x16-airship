; This file is built by an assembler, but not actually built into the
; application.  Instead, it will be loaded up as data by the main program.

; These are dummy values, only here to keep the assembler from complaining
.org $A000
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "RODATA"

.word campfire_sign

campfire_sign:					.literal "Come sit with us", $00
