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
;==================================================
; inventory_dialog
;
; Shows a message in the center of the screen as a
; dialog box
;
; void inventory_dialog ()
;==================================================
inventory_dialog:
	
	rts

;==================================================
; clear_inventory_dialog
;
; Clears the dialog message tile map
;
; void clear_inventory_dialog()
;==================================================
clear_inventory_dialog:

	rts

.endif ; INVENTORY_ASM
