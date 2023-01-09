.ifndef VRAM_INC
VRAM_INC = 1

; tiles are assumed to be stored at $00000 for animations to work, so don't
; change this
vram_tile_data			= $00000 ; goes to $10000

vram_bitmap				= $10000 ; goes to $19600

vram_l0_map_data		= $10000
vram_l1_map_data		= $14000

; This consists of 12 16x16 8bpp tiles, so $C00 bytes
vram_player_sprites		= $18000

; $C00 are available here (after bitmap is no longer needed)
vram_dialog_map			= $18c00

; the charset is positioned here to be out of the way of a full screen 4bb
; bitmap loaded at $10000, and still be aligned properly to use as a tileset
vram_charset_sprites	= $19800 ; goes to $1a600

; $5400 are available here (32 byte aligned)
vram_npc				= $1a800

vram_palette			= $1fa00

.endif ; VRAM_INC
