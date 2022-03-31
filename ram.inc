.ifndef RAM_INC
RAM_INC = 1

; Zero Page

map_width			= $22	; 2 bytes
map_height			= $24	; 2 bytes

; scroll offsets
xoff				= $26	; 2 bytes
yoff				= $28	; 2 bytes

xplayer				= $30	; 2 bytes
yplayer				= $32	; 2 bytes

; index of active tile (0 through w*h-1)
active_tile			= $36	; 2 bytes

; 256 repeating ticks
tickcount			= $38
joystick_data		= $39 ; 3 bytes

; tick function
tick_fn				= $56 ; 2 bytes

; vsync trigger for running the game loop
zp_vsync_trig		= $58


; Other addresses

; the program is loaded at $800

; for 32 16x16 1bpp tiles this takes $800 bytes
collision_tile_data	= $4000

; for the single constructed collision tile to be compared against the player
; this is stored in $20 bytes, but will take $80 to calculate
construct_tile		= $4800

; player collision tile
player_collision_tile = $4880

default_irq			= $9efe


; Banked RAM addresses

; for a 128x64 tile map this takes $2000 bytes
collision_map_data_bank = 0
collision_map_data	= $a000

.endif ; RAM_INC
