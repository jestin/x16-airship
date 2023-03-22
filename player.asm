.ifndef PLAYER_ASM
PLAYER_ASM = 1

.segment "BSS"

; a bitmask of player statuses:
; 0 - unable to move
; 1 - reading text
; 2 - reading dialog
; 3 - collision
; 4 -
; 5 -
; 6 -
; 7 - paused
player_status:		.res 1

player_status_unable_to_move	= %00000001
player_status_reading_text		= %00000010
player_status_reading_dialog	= %00000100
player_status_collision			= %00001000
player_status_inventory_mode	= %00010000
;???????????????????????????	= %00100000
;???????????????????????????	= %01000000
player_status_paused			= %10000000

; Other addresses

player_file:		.res 2
player_file_size:		.res 2

.segment "CODE"

;==================================================
; initialize_player_memory
;
; void initialize_player_memory()
;==================================================
initialize_player_memory:
	stz player_status
	stz player_file
	stz player_file+1
	stz player_file_size
	stz player_file_size+1

	rts

.endif ; PLAYER_ASM
