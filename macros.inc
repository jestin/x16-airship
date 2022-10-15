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
	.local @Skip
	inc dest
	bne @Skip
	inc dest+1
@Skip:
.endmacro

.macro DecW dest
	.local @Skip
	lda dest
	bne @Skip
	dec dest+1
@Skip:
	dec dest
.endmacro

.macro LsrW dest
	lsr dest+1
	ror dest
.endmacro

.macro AslW dest
	asl dest
	rol dest+1
.endmacro

.macro CompareW w0, w1
	lda w0+1
	cmp w1+1
	bne :+
	lda w0
	cmp w1
:
.endmacro

.endif ; MACROS_INC
