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
;					word screen_y: u2,
; 					word sprite_array: u3)
;==================================================
draw_string:

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
	ora #%10000000						; using 8bpp, even for characters
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

	AslW u4							; multiply the value by 64
	AslW u4
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
; show_message
;
; Shows a message address to the user
;
; void show_message(byte message_index: A)
;==================================================
show_message:
	; double the message index and add it to the message lookup address
	asl
	clc
	adc #<map_message_lookup
	sta u1L
	lda #0
	adc #>map_message_lookup
	sta u1H

	; switch to the map message bank
	lda #map_message_data_bank
	sta $00

	; u1 now points to the address of the string.  u0 needs the be the address
	; of the string in order to call draw_string
	lda (u1)
	sta u0L
	ldx #1
	lda u1,x
	sta u0H

	; load the other draw_string parameters
	LoadW u1, 20
	LoadW u2, 220
	LoadW u3, message_sprites
	jsr draw_string					; draw message text

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
