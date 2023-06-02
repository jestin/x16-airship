.ifndef INVENTORY_ASM
INVENTORY_ASM = 1

.segment "BSS"

; These represents the various upgrades the ship has
ship_items:		.res 1

; This represents the items that the player retains throughout the game
player_items:	.res 1

.segment "CODE"

;==================================================
; initialize_inventory_memory
;
; void initialize_inventory_memory()
;==================================================
initialize_inventory_memory:

	stz ship_items
	stz player_items

	rts
.endif ; INVENTORY_ASM
