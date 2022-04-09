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

; index (0 through w*h-1) of active tile (where player upper left is)
active_tile			= $36	; 2 bytes

; index (0 through w*h-1) of active tile (where player center is)
player_tile			= $38	; 2 bytes

; 256 repeating ticks
tickcount				= $40
joystick_data			= $41 ; 3 bytes
joystick_changed_data	= $44 ; 3 bytes

anim_tiles_count		= $47
next_char_sprite		= $48

; a bitmask of player statuses:
; 0 - unable to move
; 1 - reading text
; 2 -
; 3 -
; 4 -
; 5 -
; 6 -
; 7 -
player_status			= $49

; interaction function
interaction_fn		= $54 ; 2 bytes

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

; Store an array of indexes of the (base) animated tiles.  The max allowed is
; 32 animated tiles, since the that is the most we can hold in the animation
; tile restore bank (32 tiles x 256 bytes per tile = 8K)
anim_tiles			= $4900 ; 64 bytes (32 2-byte tile indexes)

; Store an array of sprites used for message text
message_sprites		= $4940 ; 64 bytes

default_irq			= $9efe


; Banked RAM addresses

; for a 128x64 tile map this takes $2000 bytes
collision_map_data_bank = 1
collision_map_data	= $a000

; for a 128x64 tile map this takes $2000 bytes
interaction_map_data_bank = 2
interaction_map_data	= $a000

; animation tile restore values ($100 bytes per tile)
animation_tile_restore_data_bank = 3
animation_tile_restore = $a000


.endif ; RAM_INC
