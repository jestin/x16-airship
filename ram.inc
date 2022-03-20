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

xloc				= $34	; 2 bytes
yloc				= $36	; 2 bytes

; index of active tile (0 through w*h-1)
active_tile			= $38	; 2 bytes

; 256 repeating ticks
tickcount			= $40
joystick_data		= $41 ; 3 bytes

; vsync trigger for running the game loop
zp_vsync_trig		= $58




; Other addresses

; for 16 16x16 1bpp tiles this takes $400 bytes
collision_tile_data	= $0400

; the program is loaded at $800

; for a 128x64 tile map this takes $2000 bytes
collision_map_data	= $2000

default_irq			= $8000

.endif ; RAM_INC
