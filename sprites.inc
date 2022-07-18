.ifndef SPRITES_INC
SPRITES_INC = 1

char_sprite_begin = 0
char_sprite_end = 64

; the player sprite should be right in the middle of the available sprite range
; so it can be positioned both in front and behind other sprites in the rendering
; order
player_sprite = 96

.endif ; SPRITES_INC
