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
	; the active tile x is the (xplayer + xoff) / 16
	clc
	lda xplayer
	adc xoff
	sta u0L
	lda xplayer+1
	adc xoff+1
	sta u0H
	LsrW u0						; divide by 2, 4 times (divide by 16)
	LsrW u0
	LsrW u0
	LsrW u0

	; the active tile y is the (yplayer + yoff) / 16
	clc
	lda yplayer
	adc yoff
	sta u1L
	lda yplayer+1
	adc yoff+1
	sta u1H
	LsrW u1						; divide by 2, 4 times (divide by 16)
	LsrW u1
	LsrW u1
	LsrW u1

	; calculate map width in tiles by shifting map_width left 4 times
	MoveW map_width, u2
	LsrW u2
	LsrW u2
	LsrW u2
	LsrW u2

	; active tile should now be (u1 * u2) + u0
	; NOTE: u0, u1, nor u2 should ever need their high bytes.  We simply aren't
	; allowed tilemaps that large.  However, the result of this calculation
	; almost certainly will require 16 bits.
	lda u1						; load u1 into X, because it is almost
	tax							; certainly lower than u2
	LoadW u1, 0					; zero out u1 to re-use
	clc
@multiply_loop:
	cpx #0
	beq @add_x_tile
	clc
	lda u1L
	adc u2L
	sta u1L
	lda u1H
	adc u2H
	sta u1H
	dex
	bra @multiply_loop

@add_x_tile:
	; at this point u1 contains the result of the multiplication
	clc
	lda u1L
	adc u0L
	sta active_tile
	lda u1H
	adc u0H
	sta active_tile+1

	rts

;==================================================
; set_scroll_offset
;
; Based on the player's location on the screen,
; set the display's scroll offset values
;
; void set_scroll_offset()
;==================================================
set_scroll_offset:
	; If the player falls outside a box in the center of the screen, force the
	; screen to scroll.  Do NOT scroll if the location is within the box, or
	; within a certain distance from the edge of the map.

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


	; check if xoff is already 0 (or less)
	lda xoff+1
	cmp #0
	beq @check_xoff_low
	bra @scroll_left
@check_xoff_low:
	lda xoff
	cmp #0
	beq @check_right_edge

@scroll_left:
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

	; check if the scroll is already at the max
	sec
	lda map_width
	sbc #<(320)						; subtract the screen width from the map width
	sta u0L
	lda map_width+1
	sbc #>(320)						; subtract the screen width from the map width
	sta u0H							; u0 now contains the max H scroll allowed
	
	lda xoff+1						; load xoff high byte for compare
	cmp u0H							; compare to max
	bne @scroll_right				; if not equal, don't bother checking low byte
	lda u0L
	cmp xoff						; if low byte of max is less than xoff low byte
	bcc @check_v_scroll				; don't scroll

@scroll_right:
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
	; check if yplayer is lower than 64
	lda yplayer+1
	cmp #0
	bne @check_bottom_edge			; if high byte is non-zero, we are
									; definitely larger than 64

	lda #$40						; load 64 and subtract low byte of yplayer
	sec
	sbc yplayer
	bcc @check_bottom_edge			; if carry is clear, it means we are not on
									; the left edge of the screen, so skip ahead
	sta u0L							; store the result so we can subtract it from yoff

	; check if yoff is already 0 (or less)
	lda yoff+1
	cmp #0
	beq @check_yoff_low
	bra @scroll_up
@check_yoff_low:
	lda yoff
	cmp #0
	beq @check_bottom_edge

@scroll_up:
	sec								; subtract the result from yoff (to scroll)
	lda yoff
	sbc u0L
	sta yoff
	lda yoff+1
	sbc #0							; no high byte, so substract 0 to account for borrow
	sta yoff+1

	clc								; add the result to yplayer (to reposition within the box)
	lda yplayer
	adc u0L
	sta yplayer
	lda yplayer+1
	adc #0							; no high byte, so add 0 to account for carry
	sta yplayer+1
	bra @return						; if we H scrolled, we can skip to V scroll

@check_bottom_edge:
	; check if yplayer is higher than 176 (240-64)
	sec
	lda yplayer
	sbc #$b0
	bcc @return						; we are lower than 176 if we needed to barrow
	sta u1L

	; check if the scroll is already at the max
	sec
	lda map_height
	sbc #<(240)						; subtract the screen height from the map height
	sta u0L
	lda map_height+1
	sbc #>(240)						; subtract the screen height from the map height
	sta u0H							; u0 now contains the max V scroll allowed

	lda yoff+1						; load yoff high byte for compare
	cmp u0H							; compare to max
	bne @scroll_down				; if not equal, don't bother checking low byte
	lda u0L
	cmp yoff						; if low byte of max is less than yoff low byte
	bcc @return						; don't scroll

@scroll_down:
	; add the result of the subtraction to yoff, as it's how much we need to scroll
	clc
	lda u1L
	adc yoff
	sta yoff
	lda yoff+1
	adc #0							; no high byte, so add 0 to account for carry
	sta yoff+1

	lda #$b0
	sta yplayer						; to subtract back down to 256, just zero out the low byte

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
	bra @update

@up:
	DecW yplayer
	bra @update
@down:
	IncW yplayer
	bra @update
@left:
	DecW xplayer
	bra @update
@right:
	IncW xplayer
	bra @update
	
@update:
@cap_player_x_lower:
	lda xplayer+1
	cmp #$ff
	bne @cap_player_x_higher
	lda #0
	sta xplayer
	sta xplayer+1

@cap_player_x_higher:
	lda xplayer+1
	cmp #0
	beq @cap_player_y_lower
	lda xplayer
	cmp #$30	; 64 - 16
	bcc @cap_player_y_lower
	lda #$30
	sta xplayer

@cap_player_y_lower:
	lda yplayer+1
	cmp #$ff
	bne @cap_player_y_higher
	lda #0
	sta yplayer
	sta yplayer+1

@cap_player_y_higher:
	lda yplayer
	cmp #$e0	; 240 - 16
	bcc @update_scroll
	lda #$e0
	sta yplayer

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
