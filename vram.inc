.ifndef VRAM_INC
VRAM_INC = 1

vram_tile_data			= $00000
vram_bitmap				= $00000
vram_l0_map_data		= $12c00
vram_l1_map_data		= $16c00

; This consists of 12 16x16 8bpp tiles, so $C00 bytes
vram_player_sprites		= $1ac00

vram_charset_sprites	= $1b800

vram_palette			= $1fa00

.endif ; VRAM_INC
