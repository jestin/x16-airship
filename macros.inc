.ifndef MACROS_INC
MACROS = 1

.macro LoadB dest, value
	lda #value
	sta dest
.endmacro

.macro LoadW dest, value
	lda #<(value)
	sta dest
	lda #>(value)
	sta dest+1
.endmacro

.macro LoadWBE dest, value
	lda #>(value)
	sta dest
	lda #<(value)
	sta dest+1
.endmacro

.macro MoveB source, dest
	lda source
	sta dest
.endmacro

.macro MoveW source, dest
	MoveB source+0, dest+0
	MoveB source+1, dest+1
.endmacro

.macro AddW dest, value
	lda dest
	clc
	adc #<(value)
	sta dest
	lda dest+1
	adc #>(value)
	sta dest+1
.endmacro

.macro SubW dest, value
	lda dest
	sec
	sbc #<(value)
	sta dest
	lda dest+1
	sbc #>(value)
	sta dest+1
.endmacro

.macro write_char
	sta veradat
	lda zp_color_addr 		;foreground/background color
	sta veradat
.endmacro

.macro IncW dest
	clc						; clear the carry bit
	lda dest				; increment the low order byte such that it sets c
	adc #1
	sta dest
	lda dest+1				; add 0 without clearing the carry bit
	adc #0					; if c is set, it will increment the high order byte
	sta dest+1
.endmacro

.macro DecW dest
	sec						; set the carry bit (unset the barrow bit)
	lda dest				; decrement the low order byte such that it sets barrow
	sbc #1
	sta dest
	lda dest+1				; add 0 without clearing the carry bit
	sbc #0					; if c is set, it will decrement the high order byte
	sta dest+1
.endmacro

.macro LsrW dest
	clc
	lsr dest+1
	ror dest
.endmacro

.macro AslW dest
	clc
	asl dest
	rol dest+1
.endmacro

.endif ; MACROS_INC
