.ifndef INITIALIZATION_ASM
INITIALIZATION_ASM = 1

;==================================================
; initialize_memory()
;
; void initialize_memory()
;==================================================
initialize_memory:
	jsr initialize_joystick_memory
	jsr initialize_npc_group_memory
	jsr initialize_npc_memory
	jsr initialize_player_memory
	jsr initialize_map_memory
	jsr initialize_palette_memory
	jsr initialize_collision_memory
	jsr initialize_animation_memory
	jsr initialize_text_memory
	jsr initialize_npc_path_memory
	jsr initialize_movement_memory
	jsr initialize_interaction_memory
	jsr initialize_inventory_memory

	rts

.endif ; INITIALIZATION_ASM
