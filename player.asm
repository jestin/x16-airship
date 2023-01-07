.ifndef PLAYER_ASM
PLAYER_ASM = 1

.segment "BSS"

; a bitmask of player statuses:
; 0 - unable to move
; 1 - reading text
; 2 - show dialog
; 3 -
; 4 -
; 5 -
; 6 -
; 7 -
player_status:		.res 1

; Other addresses

player_file:		.res 2
player_file_size:		.res 2

.segment "CODE"

.endif ; PLAYER_ASM
