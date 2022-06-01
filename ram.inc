.ifndef RAM_INC
RAM_INC = 1

.segment "DATA"

map_width:		.res 2
map_height:		.res 2

; scroll offsets
xoff:		.res 2
yoff:		.res 2

xplayer:		.res 2
yplayer:		.res 2

playerdir:		.res 1

; index (0 through w*h-1) of active tile (where player upper left is)
active_tile:		.res 2

; index (0 through w*h-1) of active tile (where player center is)
player_tile:		.res 2

; 256 repeating ticks
tickcount:		.res 1
joystick_data:		.res 3
joystick_changed_data:		.res 3

anim_tiles_count:		.res 1
next_char_sprite:		.res 1

; a bitmask of player statuses:
; 0 - unable to move
; 1 - reading text
; 2 -
; 3 -
; 4 -
; 5 -
; 6 -
; 7 -
player_status:		.res 1

map_id:		.res 1

; interaction function
interaction_fn:		.res 2

; tick function
tick_fn:		.res 2

; vsync trigger for running the game loop
zp_vsync_trig:		.res 1


; Other addresses

; the program is loaded at $800

; for 32 16x16 1bpp tiles this takes $800 bytes
collision_tile_data:		.res $800

; for the single constructed collision tile to be compared against the player
; this is stored in $20 bytes, but will take $80 to calculate
construct_tile:		.res $80

; player collision tile
player_collision_tile:		.res 32

; Store an array of indexes of the (base) animated tiles.  The max allowed is
; 32 animated tiles, since the that is the most we can hold in the animation
; tile restore bank (32 tiles x 256 bytes per tile = 8K)
anim_tiles:			.res 64 ; 64 bytes (32 2-byte tile indexes)

; Store an array of sprites used for message text
message_sprites:		.res 64

player_file:		.res 2
player_file_size:		.res 2

default_irq:		.res 2


; Banked RAM addresses
bank_window = $a000

; for a 128x64 tile map this takes $2000 bytes
collision_map_data_bank = 1
collision_map_data	= $a000

; for a 128x64 tile map this takes $2000 bytes
interaction_map_data_bank = 2
interaction_map_data	= $a000

; animation tile restore values ($100 bytes per tile)
animation_tile_restore_data_bank = 3
animation_tile_restore = $a000

; map messages
map_message_data_bank = 4
map_message_lookup = $a000

; overworld map cache
overworld_l0_map_bank_1 = 5
overworld_l0_map_bank_2 = 6
overworld_l1_map_bank_1 = 7
overworld_l1_map_bank_2 = 8

; music banks
overworld_music_bank = 9
music_data = $a000

.endif ; RAM_INC
