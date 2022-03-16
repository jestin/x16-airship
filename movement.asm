.ifndef MOVEMENT_ASM
MOVEMENT_ASM = 1

;==================================================
; set_active_tile
;
; Based on the player's location on the map,
; set the active tile (tile containing the player
; sprite's 0,0)
;
; void set_active_tile()
;==================================================
set_active_tile:
	; the active tile x is the xloc / 16
	MoveW xloc, active_tile_x		; move xloc to active_tile_x for calculation
	LsrW active_tile_x				; divide by 2, 4 times (divide by 16)
	LsrW active_tile_x
	LsrW active_tile_x
	LsrW active_tile_x

	; the active tile y is the yloc / 16
	MoveW yloc, active_tile_y		; move yloc to active_tile_y for calculation
	LsrW active_tile_y				; divide by 2, 4 times (divide by 16)
	LsrW active_tile_y
	LsrW active_tile_y
	LsrW active_tile_y

	rts

;==================================================
; set_scroll_offset
;
; Based on the player's location on the map,
; set the display's scroll offset values
;
; void set_scroll_offset()
;==================================================
set_scroll_offset:
	; If the player falls outside a box in the center of the screen, force the
	; screen to scroll.  Do NOT scroll if the location is within the box, or
	; within a certain distance from the edge of the map.
	
	; check if xloc is lower than 64 by subtracting 64 from xloc
	MoveW xloc, u0					; use u0 as a scratchpad
	SubW u0, $40
	bcs @check_v_scroll				; if carry is set, it means we are on the
									; left edge of the map, so no H scroll

	; check if xloc is greater than (map_width - 64)
	MoveW map_width, u0				; use u0 as a scratchpad
	lda u0L
	sec
	sbc xloc
	sta u0L
	lda u0H
	sbc xloc+1
	sta u0H
	cmp #0							; if the high byte is non-zero, we know we
	bne @calc_h_scroll				; are at least 256 away from the right edge
	lda u0L
	cmp #$40
	bcc @check_v_scroll				; if the difference are less than 64, we
									; are on the right edge of the map, so no H
									; scroll

	; If we've made it here, it means we are not on the left or right edges of
	; the map.  We may need to H scroll, depending on xplayer.
@calc_h_scroll:
@check_left_edge:

	; check if xplayer is lower than 64
	lda xplayer+1
	cmp #0
	bne @check_right_edge			; if high byte is non-zero, we are
									; definitely larger than 64

	lda #$40						; load 64 and subtract low byte of xplayer
	sec
	sbc xplayer
	bcc @check_right_edge			; if carry is clear, it means we are not on
									; the left edge of the screen, so skip ahead

	sta u0L							; store the result so we can subtract it from xoff

	sec								; subtract the result from xoff (to scroll)
	lda xoff
	sbc u0L
	sta xoff
	lda xoff+1
	sbc #0							; no high byte, so substract 0 to account for borrow
	sta xoff+1

	clc								; add the result to xplayer (to reposition within the box)
	lda xplayer
	adc u0L
	sta xplayer
	lda xplayer+1
	adc #0							; no high byte, so add 0 to account for carry
	sta xplayer+1
	bra @check_v_scroll				; if we H scrolled, we can skip to V scroll

@check_right_edge:
	; check if xplayer is higher than 256 (320-64)
	lda xplayer+1
	cmp #0
	beq @check_v_scroll				; if the high byte is zero, we are under 256

	; the low byte of xplayer is precisely how much we need to scroll right
	clc
	lda xoff
	adc xplayer
	sta xoff
	lda xoff+1
	adc #0							; no high byte, so add 0 to account for carry
	sta xoff+1

	lda #0
	sta xplayer						; to subtract back down to 256, just zero out the low byte


@check_v_scroll:

@return:
	rts

;==================================================
; move
; 
; Move the player character in response to the
; joystick
; 
; void move()
;==================================================
move:
	lda joystick_data
	bit#$8
	beq @up
	bit#$4
	beq @down
	bit#$2
	beq @left
	bit #$1
	beq @right
	bra @update_scroll

@up:
	DecW yplayer
	bra @update_scroll
@down:
	IncW yplayer
	bra @update_scroll
@left:
	DecW xplayer
	bra @update_scroll
@right:
	IncW xplayer
	bra @update_scroll
; @up:
; 	dec yoff
; 	lda yoff
; 	cmp #$ff
; 	bne @update
; 	dec yoff+1
; 	bra @update
; @down:
; 	inc yoff
; 	bne @update
; 	inc yoff+1
; 	bra @update
; @left:
; 	dec xoff
; 	lda xoff
; 	cmp #$ff
; 	bne @update
; 	dec xoff+1
; 	bra @update
; @right:
; 	inc xoff
; 	bne @update
; 	inc xoff+1
	

@update_scroll:
	jsr set_scroll_offset

	; calculate and set the correct vera scroll offsets
	lda xoff+1
	cmp #$08
	bne @updatescrollx
	stz xoff+1
@updatescrollx:
	lda xoff
	sta veral0hscrolllo
	sta veral1hscrolllo
	lda xoff+1
	sta veral0hscrollhi
	sta veral1hscrollhi

	lda yoff+1
	cmp #$04
	bne @updatescrolly
	stz yoff+1

@updatescrolly:
	lda yoff
	sta veral0vscrolllo
	sta veral1vscrolllo
	lda yoff+1
	sta veral0vscrollhi
	sta veral1vscrollhi

@update_sprite:
	lda xplayer
	sprstore 2
	lda xplayer+1
	sprstore 3
	lda yplayer
	sprstore 4
	lda yplayer+1
	sprstore 5
	
@return: 
	rts

.endif ; MOVEMENT_ASM
