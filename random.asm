.ifndef RANDOM_ASM
RANDOM_ASM = 1

.segment "CODE"

;==================================================
; get_random_byte
; Gathers entropy from the machine and combines
; it into a single pseudo-random byte.
; byte: a get_random_byte()
;==================================================
get_random_byte:
	jsr entropy_get
	stx u15H
	eor u15H
	tya
	eor u15H

	rts

;==================================================
; get_random_byte_less_than
; Gathers entropy from the machine and combines
; it into a single pseudo-random byte.
; byte: a get_random_byte_less_than(byte max: A)
;==================================================
get_random_byte_less_than:
	sta u0L
	; loop until the random is lower than the max
:	jsr get_random_byte
	cmp u0L
	bcs :-

	rts

;==================================================
; get_random_nibble
; Gathers entropy from the machine and combines
; it into a single pseudo-random nibble ($0X).
; byte: a get_random_byte()
;==================================================
get_random_nibble:
	jsr get_random_byte
	lsr
	lsr
	lsr
	lsr

	rts

;==================================================
; get_random_word
; Gathers entropy from the machine and combines
; it into a single pseudo-random word
; byte: u0 get_random_word()
;==================================================
get_random_word:
	jsr get_random_byte
	sta u0L
	jsr get_random_byte
	sta u0H

	rts

.endif ; RANDOM_ASM
