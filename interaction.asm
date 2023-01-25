.ifndef INTERACTION_ASM
INTERACTION_ASM = 1

.segment "BSS"

interaction_id:		.res 1

.segment "CODE"

;==================================================
; check_interactions
;
; void check_interactions(out byte interaction_id)
;==================================================
check_interactions:

	; switch to the collsion map bank of RAM
	lda #interaction_map_data_bank
	sta $00

	clc
	lda #<(hi_mem)
	adc player_tile
	sta u0L
	lda #>(hi_mem)
	adc player_tile+1
	sta u0H

	; u0 now holds the address of the relevant tile on the interaction map

	lda (u0)
	sta interaction_id

	; now u0L holds the value, itself rather than the address

@return:
	rts

.endif ; INTERACTION_ASM
