.ifndef COLLISION_ASM
COLLISION_ASM = 1

;==================================================
; check_collisions
;
; This should be called after movement is
; calculated, but before it is applied. It will
; indicate whether the calculation should be
; applied.
; 0 - don't apply
; 1 - apply
;
; void check_collisions(out apply: A)
;==================================================
check_collisions:

	lda #1
	rts

.endif ; COLLISION_ASM
