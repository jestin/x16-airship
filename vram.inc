.ifndef VRAM_INC
VRAM_INC = 1

vram_tile_data			= $00000
vram_bitmap				= $00000
vram_l0_map_data		= $10000
vram_l1_map_data		= $14000

; This consists of 12 16x16 8bpp tiles, so $C00 bytes
vram_player_sprites		= $18000

vram_charset_sprites	= $18c00

vram_palette			= $1fa00

.endif ; VRAM_INC
