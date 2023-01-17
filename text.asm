.ifndef TEXT_INC
TEXT_INC = 1

.segment "BSS"

; Store an array of sprites used for message text
message_sprites:		.res 64

next_char_sprite:		.res 1

.segment "CODE"

;==================================================
; inc_next_char_sprite
; 
; Increments the next character sprite index,
; rolling over if necessary
;
; void inc_next_char_sprite()
;==================================================
inc_next_char_sprite:
	lda next_char_sprite
	inc
	cmp #char_sprite_end
	bcc @store
	lda #char_sprite_begin
@store:
	sta next_char_sprite

	rts

;==================================================
; draw_string
;
; Draws a string of text using sprites at the
; specified location on the screen.
;
; void draw_string(word string_address: u0,
;					word screen_x: u1,
;					word screen_y: u2,
; 					word sprite_array: u3)
;==================================================
draw_string:
	phx

@loop:
	lda (u0)
	; check for null termination, and end the loop if found
	cmp #0
	beq @end_loop

	jsr char_to_sprite_address

@set_sprite:

	ldx next_char_sprite
	jsr set_character_sprite

	; store the array index for the character into an array so we can
	; manipulate it later
	lda next_char_sprite
	sta (u3)
	IncW u3

	; increment the next character sprite index
	jsr inc_next_char_sprite

	; increment the character address
	IncW u0

	; increment the x value
	clc
	lda u1L
	adc #8							; assume 8-pixel wide characters
	sta u1L
	lda u1H
	adc #0
	sta u1H

	bra @loop
@end_loop:

	; write a $80 to the end of the sprite array, since there shouldn't be any
	; sprites with that index
	lda #$80
	sta (u3)

@return:
	plx
	rts

;==================================================
; set_character_sprite
; 
; Sets a sprite that is to be used for characters
;
; void set_character_sprite(byte sprite_index: x,
;							word data_address: u4,
;							word screen_x: u1,
;							word screen_y: u2)
;==================================================
set_character_sprite:
	lda u4L
	sprstore 0
	lda u4H
	and #%01111111						; using 4bpp
	sprstore 1
	lda u1L
	sprstore 2
	lda u1H
	sprstore 3
	lda u2L
	sprstore 4
	lda u2H
	sprstore 5
	lda #%00001100						; above both layers
	sprstore 6
	lda #0
	sprstore 7							; 8x8

	rts

;==================================================
; char_to_sprite_address
;
; Calculate the sprite's data address based on the
; character.
;
; void char_to_sprite_address(
;					byte char: A,
;					out word sprite_address: u4)
;==================================================
char_to_sprite_address:

	; subtract $20 from the petscii code to determine the correct character to draw
	sec
	sbc #$20
	sta u4L							; store in u4, as a word
	stz u4H

	; based on the correct chracter, calculate the vram offset

	AslW u4							; multiply the value by 32
	AslW u4
	AslW u4
	AslW u4
	AslW u4

	; add vram_charset_sprites
	clc
	lda u4L
	adc #<vram_charset_sprites
	sta u4L
	lda u4H
	adc #>vram_charset_sprites
	sta u4H
	lda #0

	; because vram_charset_sprites is 3 bytes, we need to decide to set the carry
	lda #^vram_charset_sprites
	cmp #0
	beq @shift_right					; don't modify carry from last operation

	; if we are here, it means that vram_charset_sprites is above $ffff, so set the carry
	sec

@shift_right:
	; shift right 5 times, accounting for the inital carry bit
	ror u4H
	ror u4L
	ror u4H
	ror u4L
	ror u4H
	ror u4L
	ror u4H
	ror u4L
	ror u4H
	ror u4L

@return:
	rts

;==================================================
; load_message
;
; Loads a message from the message bank into a
; string pointer
;
; void load_message(byte message_index: A
;						out word string_address: u0)
;==================================================
load_message:
	pha

	; move A to a word in case it rolls over when doubled
	sta u1L
	lda #0
	sta u1H
	AslW u1

	; double the message index and add it to the message lookup address
	clc
	lda u1L
	adc #<hi_mem
	sta u1L
	lda u1H
	adc #>hi_mem
	sta u1H

	; switch to the map message bank
	lda #map_message_data_bank
	sta $00

	; u1 now points to the address of the string.  u0 needs the be the address
	; of the string in order to call draw_string
	lda (u1L)
	sta u0L
	ldy #1
	lda (u1),y
	sta u0H

	; u0 now contains a pointer to the string

	pla
	rts

;==================================================
; captured_message
;
; Shows a message that needs to be cleared by the
; user
;
; void captured_message(byte message: A)
;==================================================
captured_message:
	jsr load_message

	; load the other draw_string parameters
	LoadW u1, 20
	LoadW u2, 220
	LoadW u3, message_sprites
	jsr draw_string			; draw message text

	lda player_status		; set the player status to restrained and reading
	ora #%00000011
	sta player_status

	rts

;==================================================
; message_dialog
;
; Shows a message in the center of the screen as a
; dialog box
;
; void message_dialog (byte message: A,
;						byte messages_per_screen: X,
;						byte screens: Y)
;==================================================
message_dialog:
	pha
	phx

	; clear dialog map
	lda #0
	sta veractl
	lda #<(vram_dialog_map >> 16) | $10
	sta verahi
	lda #<(vram_dialog_map >> 8)
	sta veramid
	lda #<(vram_dialog_map)
	sta veralo

	ldy #$a
@clear_loop:
	ldx #128
@page_loop:
	lda #0
	sta veradat
	stz veradat				; no offset, flips, or high bit
	dex
	bne @page_loop
	dey
	bne @clear_loop

	; the text is now cleared

	plx
	pla
	sta u3L

@line_loop:
	; decrement X first so that the first line will be 0 not 1
	dex

	LoadW u2, vram_dialog_map

	lda #0
	sta veractl

	; we assume that no line will ever increment the hi vram address
	lda #<(vram_dialog_map >> 16) | $20
	sta verahi

	clc
	stx u1L
	stz u1H
	AslW u1
	AslW u1
	AslW u1
	AslW u1
	AslW u1
	AslW u1
	AslW u1
	lda u1L
	adc u2L
	sta veralo
	lda u1H
	adc u2H
	sta veramid

	txa						; add X to A for the correct message
	clc
	adc u3L
	jsr load_message

	ldy #0
@char_loop:
	lda (u0),y
	beq @end_char_loop
	sec
	sbc #$20
	sta veradat
	iny
	bra @char_loop
@end_char_loop:

	cpx #0
	bne @line_loop
@end_line_loop:

	lda player_status		; set the player status to restrained and reading a dialog
	ora #%00000111
	sta player_status

	rts

;==================================================
; clear_text_sprites
;
; Shows a message address to the user
;
; void clear_text_sprites(word sprite_array: u0)
;==================================================
clear_text_sprites:

	; disable message sprites
@disable_sprite_loop:
	lda (u0)
	cmp #$80
	bcs @end_disable_sprite_loop
	tax
	lda #0
	sprstore 6
	IncW u0
	bra @disable_sprite_loop
@end_disable_sprite_loop:

	rts

.endif ; TEXT_INC
