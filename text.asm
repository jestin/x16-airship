.ifndef TEXT_INC
TEXT_INC = 1

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
;					word screen_y: u2)
;==================================================
draw_string:

@loop:
	lda (u0)
	; check for null termination, and return if found
	cmp #0
	beq @return

	jsr char_to_sprite_address

@set_sprite:

	ldx next_char_sprite
	jsr set_character_sprite

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

@return:
	rts

;==================================================
; set_character_sprite
; 
; Sets a sprite that is to be used for characters
;
; void set_character_sprite(byte sprite_index: x,
;							word data_address: u3,
;							word screen_x: u1,
;							word screen_y: u2)
;==================================================
set_character_sprite:
	lda u3L
	sprstore 0
	lda u3H
	ora #%10000000
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
;					out word sprite_address: u3)
;==================================================
char_to_sprite_address:

	; subtract $20 from the petscii code to determine the correct character to draw
	sec
	sbc #$20
	sta u3L							; store in u3, as a word
	stz u3H

	; based on the correct chracter, calculate the vram offset

	AslW u3							; multiply the value by 64
	AslW u3
	AslW u3
	AslW u3
	AslW u3
	AslW u3

	; add vram_charset_sprites
	clc
	lda u3L
	adc #<vram_charset_sprites
	sta u3L
	lda u3H
	adc #>vram_charset_sprites
	sta u3H
	lda #0

	; because vram_charset_sprites is 3 bytes, we need to decide to set the carry
	lda #^vram_charset_sprites
	cmp #0
	beq @shift_right					; don't modify carry from last operation

	; if we are here, it means that vram_charset_sprites is above $ffff, so set the carry
	sec

@shift_right:
	; shift right 5 times, accounting for the inital carry bit
	ror u3H
	ror u3L
	ror u3H
	ror u3L
	ror u3H
	ror u3L
	ror u3H
	ror u3L
	ror u3H
	ror u3L

@return:
	rts

.endif ; TEXT_INC
