.ifndef NPC_PATH_ASM
NPC_PATH_ASM = 1

.include "npc_group.asm"

.segment "BSS"

; This represents a single stop along a path
.struct NpcPathStop

	; the x of this stop
	mapx 		.res 2

	; the y of this stop
	mapy		.res 2

	; format: mmmmssss
	; m - mask of when to update
	; s - steps to take per update
	xspeed		.res 1
	yspeed		.res 1

	; flip 
	; %000000vh
	flip			.res 1

.endstruct

; This represents a movement path for an NPC group
.struct NpcPath

	; the npc group to apply this path to
	npc_group_index		.res 1

	; the number of stops along this path
	num_stops			.res 1

	; the next stop along this path
	next_stop			.res 1

	stops				.res 8 * .sizeof(NpcPathStop)

.endstruct

num_npc_paths:				.res 1

; We obviously will never need more NPC groups than we are allowed NPCs
npc_paths:					.res .sizeof(NpcPath) * MAX_NPCS

.segment "CODE"

;==================================================
; clear_npc_paths
;
; Clears the paths of NPCs and all their data
;
; void clear_npc_paths()
;==================================================
clear_npc_paths:

	; reset the count
	stz num_npc_paths

	rts

;==================================================
; add_npc_path
;
; Adds an NPC path
;
; void add_npc_path(byte npc_group_index: a,
;					out byte npc_path_index: x)
;==================================================
add_npc_path:
	; store the group index for later
	pha

	; calculate the memory location of the new NPC Path
	ldx num_npc_paths				; should be the next npc path index
	jsr calculate_npc_path_address

	; set the location to 0
	lda #0
	ldy #NpcPath::num_stops
	sta (u0),y
	ldy #NpcPath::next_stop
	sta (u0),y
	pla
	ldy #NpcPath::npc_group_index
	sta (u0),y

	inc num_npc_paths

	rts

;==================================================
; add_stop_to_npc_path
;
; Adds a stop to an NPC path
;
; void add_stop_to_npc_path(byte npc_path_index: a,
;							byte xspeed: x,
;							byte yspeed: y,
;							byte mapx: u2,
;							byte mapy: u3,
;							byte flip: u4L)
;==================================================
add_stop_to_npc_path:

	; Push the index so it can be restored at the end of the routine.  This
	; makes it easy to call this routine many times in a row
	pha
	; push X and Y for later
	phx
	phy

	; get the address of the path
	tax
	jsr calculate_npc_path_address

	; get the base address of the stop array
	clc
	lda #NpcPath::stops
	adc u0L
	sta u1L
	lda #0
	adc u0H
	sta u1H

	; u1 now contains the base of the stops address

	; add the size of a stop in a loop to advance u1 to the new stop
	ldy #NpcPath::num_stops
	lda (u0),y
	tax					; x now contains the index of the new stop
@multiply_loop:
	cpx #0
	beq @end_multiply_loop
	
	clc
	lda u1L
	adc #(.sizeof(NpcPathStop))
	sta u1L
	lda u1H
	adc #0
	sta u1H

	dex
	bra @multiply_loop
@end_multiply_loop:

	; u1 now contains the address of the new stop

	lda u2L
	ldy #NpcPathStop::mapx
	sta (u1),y
	lda u2H
	ldy #NpcPathStop::mapx+1
	sta (u1),y
	lda u3L
	ldy #NpcPathStop::mapy
	sta (u1),y
	lda u3H
	ldy #NpcPathStop::mapy+1
	sta (u1),y

	lda u4L
	ldy #NpcPathStop::flip
	sta (u1),y

	pla
	ldy #NpcPathStop::yspeed
	sta (u1),y

	pla
	ldy #NpcPathStop::xspeed
	sta (u1),y

	ldy #NpcPath::num_stops
	lda (u0),y
	inc
	sta (u0),y

	pla
	rts

;==================================================
; update_npc_paths
;
; Updates the npc paths
;
; void update_npc_paths()
;==================================================
update_npc_paths:

	LoadW u1, npc_paths
	ldx #0
@path_loop:
	cpx num_npc_paths
	beq @end_path_loop

	phx		; push counter so we can use X

	; get the next stop
	jsr get_next_stop_in_path

	; u2 now had the address of the next NPC path stop

	; get the xy from the stop
	ldy #NpcPathStop::mapx
	lda (u2),y
	sta u5L
	ldy #NpcPathStop::mapx+1
	lda (u2),y
	sta u5H
	ldy #NpcPathStop::mapy
	lda (u2),y
	sta u6L
	ldy #NpcPathStop::mapy+1
	lda (u2),y
	sta u6H

	; now u5 and u6 hold the stop's x,y

	; get the NPC group for this path
	ldy #NpcPath::npc_group_index
	lda (u1),y
	tax
	jsr calculate_npc_group_address

	; u0 now has the address to the NPC group

	; store the current location of the group in u3 and u4
	ldy #NpcGroup::mapx
	lda (u0),y
	sta u3L
	ldy #NpcGroup::mapx+1
	lda (u0),y
	sta u3H
	ldy #NpcGroup::mapy
	lda (u0),y
	sta u4L
	ldy #NpcGroup::mapy+1
	lda (u0),y
	sta u4H

	; now u3 and u4 hold the group's current x,y

	; calculate the next position of the group and set it 
	ldy #NpcPath::npc_group_index
	lda (u1),y
	tax
	ldy #NpcPathStop::xspeed
	lda (u2),y
	sta u8L
	ldy #NpcPathStop::yspeed
	lda (u2),y
	sta u8H
	jsr calculate_next_npc_position
	pha
	ldy #NpcPathStop::flip					; flip needs to be retrieved after position calculation
	lda (u2),y
	sta u5L

	jsr set_npc_group_map_location_flip

	; check if the stop needs advancing
	pla
	cmp #0
	beq @continue

	jsr advance_to_next_stop


@continue:
	; increment address
	clc
	lda u1L
	adc #(.sizeof(NpcPath))
	sta u1L
	lda u1H
	adc #0
	sta u1H
	plx		; restore loop counter
	inx		; increment loop counter
	jmp @path_loop
@end_path_loop:

	rts

;==================================================
; advance_to_next_stop
;
; void advance_to_next_stop(word npc_path: u1)
;==================================================
advance_to_next_stop:

	ldy #NpcPath::num_stops
	lda (u1),y
	sta u2L						; re-using u2, so it is no longer the stop address
	ldy #NpcPath::next_stop
	lda (u1),y
	inc							; increment the next stop
	cmp u2L
	bcc @set_next_stop
	lda #0
@set_next_stop:
	sta (u1),y					; y should already be #NpcPath::next_stop

	rts

;==================================================
; get_next_stop_in_path
;
; void get_next_stop_in_path(word path: u1,
;							word next_stop: u2)
;==================================================
get_next_stop_in_path:
	clc
	lda #NpcPath::stops
	adc u1L
	sta u2L
	lda #0
	adc u1H
	sta u2H						; u2 now points to the start of the stops array
	ldy #NpcPath::next_stop
	lda (u1),y
	tax

@stop_loop:
	beq @end_stop_loop	

	clc
	lda #(.sizeof(NpcPathStop))
	adc u2L
	sta u2L
	lda #0
	adc u2H
	sta u2H

	dex
	bra @stop_loop
@end_stop_loop:

	rts

;==================================================
; calculate_next_npc_position
;
; void calculate_next_npc_position(
;								word npc_path: u1
;								word npc_path_stop: u2
;								word curx: u3,
;								word cury: u4,
;								word stopx: u5,
;								word stopy: u6,
;								byte xspeed: u8L,
;								byte yspeed: u8H,
;								out word newx: u3,
;								out word newy: u4
;								out advance_stop: a)
;==================================================
calculate_next_npc_position:

	; check the mask to see if we need to update X
	lda u8L
	and #$f0
	lsr
	lsr
	lsr
	lsr
	and tickcount
	bne @moveY

	; determine which direction x needs to move
	CompareW u3, u5
	beq @moveY
	bcc @addX

	; apply the x speed in the speed mask
@subtractX:
	lda u8L
	and #$0f		; only use the low bits of the low nibble
	sta u7L			; use u7 as a scratch pad
	stz u7H
	sec
	lda u3L
	sbc u7L
	sta u3L
	lda u3H
	sbc u7H
	sta u3H
	
	; clamp
	CompareW u3, u5
	bcs @moveY
	MoveW u5, u3
	bra @moveY
	
@addX:
	lda u8L
	and #$0f		; only use the low bits of the low nibble
	sta u7L			; use u7 as a scratch pad
	stz u7H
	clc
	lda u3L
	adc u7L
	sta u3L
	lda u3H
	adc u7H
	sta u3H
	
	; clamp
	CompareW u3, u5
	bcc @moveY
	MoveW u5, u3

@moveY:
	; check the mask to see if we need to update Y
	lda u8H
	and #$f0
	lsr
	lsr
	lsr
	lsr
	and tickcount
	bne @advance_stop

	; determine which direction y needs to move
	CompareW u4, u6
	beq @advance_stop
	bcc @addY

	; apply the y speed in the speed mask
@subtractY:
	lda u8H
	and #$0f		; only use the low nibble
	sta u7L			; use u7 as a scratch pad
	stz u7H
	sec
	lda u4L
	sbc u7L
	sta u4L
	lda u4H
	sbc u7H
	sta u4H
	
	; clamp
	CompareW u4, u6
	bcs @advance_stop
	MoveW u6, u4
	bra @advance_stop
	
@addY:
	lda u8H
	and #$0f		; only use the low nibble
	sta u7L			; use u5 as a scratch pad
	stz u7H
	clc
	lda u4L
	adc u7L
	sta u4L
	lda u4H
	adc u7H
	sta u4H
	
	; clamp
	CompareW u4, u6
	bcc @advance_stop
	MoveW u6, u4

	; Test of the stop has been reached.  If so, set advance stop

@advance_stop:

	CompareW u3, u5
	bne @set_no_advance
	CompareW u4, u6
	bne @set_no_advance

	; advance the stop
	lda #1
	bra @return

@set_no_advance:
	lda #0

@return:
	rts

;==================================================
; calculate_npc_path_address
;
; Calculates the absolute address of a particular
; NPC path given its index.
;
; void calculate_npc_path_address(
;							byte npc_path_index: x,
;							out byte address: u0)
;==================================================
calculate_npc_path_address:

	phx

	; load the base address of the npc path array
	LoadW u0, npc_paths

@multiply_loop:
	cpx #0
	beq @return
	clc
	lda #.sizeof(NpcPath)
	adc u0L
	sta u0L
	lda #0
	adc u0H
	sta u0H
	dex
	bra @multiply_loop

@return:
	plx
	rts

.endif ; NPC_PATH_ASM
