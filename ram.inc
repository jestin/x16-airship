.ifndef RAM_INC
RAM_INC = 1

; for 16 16x16 1bpp tiles this takes $400 bytes
collision_tile_data	= $0400

; the program is loaded at $800

; for a 128x64 tile map this takes $2000 bytes
collision_map_data	= $2000

.endif ; RAM_INC

