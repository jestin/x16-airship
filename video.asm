.ifndef VIDEO_ASM
VIDEO_ASM = 1

;==================================================
; set_dcvideo
;==================================================
set_dcvideo:
	pha

	lda veradcvideo
	and #%00001111
	sta u0L
	pla
	and #%11110000
	ora u0L
	sta veradcvideo
	
	rts

.endif ; VIDEO_ASM
