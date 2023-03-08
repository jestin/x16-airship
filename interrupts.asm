.ifndef INTERRUPTS_ASM
INTERRUPTS_ASM = 1

.include "dialog.asm"

.segment "BSS"

; vsync trigger for running the game loop
vsync_trigger:		.res 1
line_trigger:		.res 1
spr_trigger:		.res 1

; indicator for whether raster line interrupt is for the top of the dialog or
; the bottome
start_dialog:		.res 1

.segment "CODE"

;==================================================
; check_vsync
;==================================================
check_vsync:
	lda vsync_trigger
	beq @return

	; VSYNC has occurred, handle

	lda player_status
	bit #%00000100		; showing dialog
	beq :+

	; in dialog mode so set up line interrupt
	lda #<(dialog_top)
	sta verairqlo
	lda veraien
	and #$07
	ora #$3 | ((>dialog_top) << 7)
	sta veraien
	lda #1
	sta start_dialog
:
	inc tickcount

	; Manually push the address of the jmp to the stack to simulate jsr
	; instruction.
	; NOTE:  Due to an ancient 6502 bug, we need to make sure that tick_fn
	; doesn't have $ff in the low byte.  It's a slim chance, but will happen
	; sooner or later.  When it does, just fix by putting in a nop somewhere to
	; bump the address foward.
	lda #>(@jmp_tick_return)
	pha
	lda #<(@jmp_tick_return)
	pha
	jmp (tick_fn)				; jump to whatever the current screen defines
								; as the tick handler
@jmp_tick_return:
	nop

@return:
	stz vsync_trigger
	rts

;==================================================
; check_line
;==================================================
check_line:
	lda line_trigger
	beq @return

	; check if we are at the start of the dialog or end
	lda start_dialog
	beq @end_dialog

	jsr set_vera_dialog_top

	stz start_dialog
	bra @return

@end_dialog:
	jsr set_vera_dialog_bottom

	lda veraien
	and #%11111101		; disable line interrupt
	sta veraien

@return:
	stz line_trigger
	rts

;==================================================
; check_sprite
;==================================================
check_sprite:
	lda spr_trigger
	beq @return

	lda player_status
	ora #%00001000		; set player collision
	sta player_status

@return:
	stz spr_trigger
	rts

.endif ; INTERRUPTS_ASM
