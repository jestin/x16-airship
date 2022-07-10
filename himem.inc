.ifndef HIMEM_INC
HIMEM_INC = 1

.segment "DATA"

; Banked RAM addresses
hi_mem = $a000

; for a 128x64 tile map this takes $2000 bytes
collision_map_data_bank = 1

; for a 128x64 tile map this takes $2000 bytes
interaction_map_data_bank = 2

; animation tile restore values ($100 bytes per tile)
animation_tile_restore_data_bank = 3

; npc tile restore values ($100 bytes per tile)
npc_tile_restore_data_bank = 4

; map messages
map_message_data_bank = 5

; overworld map cache
overworld_l0_map_bank_1 = 6
overworld_l0_map_bank_2 = 7
overworld_l1_map_bank_1 = 8
overworld_l1_map_bank_2 = 9

; music banks
overworld_music_bank = 10
music_bank_0 = 10
music_bank_1 = 11
music_bank_2 = 12

; NPCs
npc_tile_bank = 13

.endif ; HIMEM_INC
