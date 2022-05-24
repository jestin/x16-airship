.ifndef X16_INC
X16_INC = 1

; ------------------------------------------------------------ 
; Commodore 64 API
; ------------------------------------------------------------ 

; Channel I/O
SETMSG		= $FF90 ; set verbosity 
READST		= $FFB7 ; return status byte 
SETLFS		= $FFBA ; set LA, FA and SA 
SETNAM		= $FFBD ; set filename 
OPEN		= $FFC0 ; open a channel 
CLOSE		= $FFC3 ; close a channel 
CHKIN		= $FFC6 ; set channel for character input 
CHKOUT		= $FFC9 ; set channel for character output 
CLRCHN		= $FFCC ; restore character I/O to screen/keyboard 
BASIN		= $FFCF ; get character 
BSOUT		= $FFD2 ; write character 
LOAD		= $FFD5 ; load a file into memory 
SAVE		= $FFD8 ; save a file from memory 
CLALL		= $FFE7 ; close all channels

; Commodore Peripheral Bus
TALK		= $FFB4 ; send TALK command 
LISTEN		= $FFB1 ; send LISTEN command 
UNLSN		= $FFAE ; send UNLISTEN command 
UNTLK		= $FFAB ; send UNTALK command 
IECOUT		= $FFA8 ; send byte to serial bus 
IECIN		= $FFA5 ; read byte from serial bus 
SETTMO		= $FFA2 ; set timeout 
TKSA		= $FF96 ; send TALK secondary address 
SECOND		= $FF93 ; send LISTEN secondary address

; Memory
MEMBOT		= $FF9C ; read/write address of start of usable RAM 
MEMTOP		= $FF99 ; read/write address of end of usable RAM

; Time
RDTIM		= $FFDE ; read system clock 
SETTIM		= $FFDB ; write system clock 
UDTIM		= $FFEA ; advance clock

; Other:
STOP		= $FFE1 ; test for STOP key 
GETIN		= $FFE4 ; get character from keyboard 
SCREEN		= $FFED ; get the screen resolution 
PLOT		= $FFF0 ; read/write cursor position 
IOBASE		= $FFF3 ; return start of I/O area

; ------------------------------------------------------------ 
; Commodore 128 API
; ------------------------------------------------------------ 

CLOSE_ALL		= $FF4A ; close all files on a device 
LKUPLA		= $FF8D ; search tables for given LA 
LKUPSA		= $FF8A ; search tables for given SA 
DLCHR		= $FF62 ; activate a text mode font in the video hardware [not yet implemented] 
PFKEY		= $FF65 ; program a function key [not yet implemented] 
FETCH		= $FF74 ; LDA (fetvec),Y from any bank 
STASH		= $FF77 ; STA (stavec),Y to any bank 
CMPARE		= $FF7A ; CMP (cmpvec),Y to any bank 
PRIMM		= $FF7D ; print string following the caller’s code

; ------------------------------------------------------------ 
; Commander X16 API
; ------------------------------------------------------------ 

; Clock
clock_set_date_time		= $FF4D ; set date and time 
clock_get_date_time		= $FF50 ; get date and time

; Mouse
mouse_config			= $FF68 ; configure mouse pointer 
mouse_get				= $FF6B ; get state of mouse

; Joystick
joystick_scan			= $FF53 ; query joysticks 
joystick_get			= $FF56 ; get state of one joystick

; Sprites
sprite_set_image		= $FEF0 ; set the image of a sprite 
sprite_set_position		= $FEF3 ; set the position of a sprite

; Framebuffer
FB_init					= $FEF6 ; enable graphics mode 
FB_get_info				= $FEF9 ; get screen size and color depth 
FB_set_palette			= $FEFC ; set (parts of) the palette 
FB_cursor_position		= $FEFF ; position the direct;access cursor 
FB_cursor_next_line		= $FF02 ; move direct;access cursor to next line 
FB_get_pixel			= $FF05 ; read one pixel, update cursor 
FB_get_pixels			= $FF08 ; copy pixels into RAM, update cursor 
FB_set_pixel			= $FF0B ; set one pixel, update cursor 
FB_set_pixels			= $FF0E ; copy pixels from RAM, update cursor 
FB_set_8_pixels			= $FF11 ; set 8 pixels from bit mask (transparent), update cursor 
FB_set_8_pixels_opaque	= $FF14 ; set 8 pixels from bit mask (opaque), update cursor 
FB_fill_pixels			= $FF17 ; fill pixels with constant color, update cursor 
FB_filter_pixels		= $FF1A ; apply transform to pixels, update cursor 
FB_move_pixels			= $FF1D ; copy horizontally consecutive pixels to a different position

; Graphics
GRAPH_init				= $FF20 ; initialize graphics 
GRAPH_clear				= $FF23 ; clear screen 
GRAPH_set_window		= $FF26 ; set clipping region
GRAPH_set_colors		= $FF29 ; set stroke, fill and background colors 
GRAPH_draw_line			= $FF2C ; draw a line 
GRAPH_draw_rect			= $FF2F ; draw a rectangle (optionally filled) 
GRAPH_move_rect			= $FF32 ; move pixels 
GRAPH_draw_oval			= $FF35 ; draw an oval or circle 
GRAPH_draw_image		= $FF38 ; draw a rectangular image 
GRAPH_set_font			= $FF3B ; set the current font 
GRAPH_get_char_size		= $FF3E ; get size and baseline of a character 
GRAPH_put_char			= $FF41 ; print a character

; Console
CONSOLE_init					= $FEDB ; initialize console mode 
CONSOLE_put_char				= $FEDE ; print character to console 
CONSOLE_put_image				= $FED8 ; draw image as if it was a character
CONSOLE_get_char				= $FEE1 ; get character from console
CONSOLE_set_paging_message		= $FED5 ; set paging message or disable paging

; Other
memory_fill				= $FEE4 ; fill memory region with a byte value 
memory_copy				= $FEE7 ; copy memory region 
memory_crc				= $FEEA ; calculate CRC16 of memory region 
memory_decompress		= $FEED ; decompress LZSA2 block 
entropy_get				= $FECF ; Get 24 random bits
monitor					= $FF44 ; enter machine language monitor 
restore_basic			= $FF47 ; enter BASIC 
screen_set_mode			= $FF5F ; set screen mode 
screen_set_charset		= $FF62 ; activate 8x8 text mode charset

; ------------------------------------------------------------ 
; VRAM Addresses
; ------------------------------------------------------------ 

VRAM_composer		= $F0000
VRAM_hscale			= VRAM_composer+1
VRAM_vscale			= VRAM_composer+2
VRAM_palette		= $F1000
VRAM_layer0			= $F2000
VRAM_layer1			= $F3000
VRAM_sprreg			= $F4000
VRAM_sprattr		= $F5000
VRAM_audio			= $F6000
VRAM_spi			= $F7000
VRAM_uart			= $F8000

VROM_petscii				= $1F000

; ------------------------------------------------------------ 
; IRQs
; ------------------------------------------------------------ 

IRQVec		= $0314
BRKVec		= $0316
NMIVec		= $0318


; ------------------------------------------------------------ 
; Virtual registers
; ------------------------------------------------------------ 
r0			= $02
r0L			= $02
r0H			= $03
r1			= $04
r1L			= $04
r1H			= $05
r2			= $06
r2L			= $06
r2H			= $07
r3			= $08
r3L			= $08
r3H			= $09
r4			= $0a
r4L			= $0a
r4H			= $0b
r5			= $0c
r5L			= $0c
r5H			= $0d
r6			= $0e
r6L			= $0e
r6H			= $0f
r7			= $10
r7L			= $10
r7H			= $11
r8			= $12
r8L			= $12
r8H			= $13
r9			= $14
r9L			= $14
r9H			= $15
r10			= $16
r10L		= $16
r10H		= $17
r11			= $18
r11L		= $18
r11H		= $19
r12			= $1a
r12L		= $1a
r12H		= $1b
r13			= $1c
r13L		= $1c
r13H		= $1d
r14			= $1e
r14L		= $1e
r14H		= $1f
r15			= $20
r15L		= $20
r15H		= $21

; ------------------------------------------------------------ 
; user virtual registers (cannot be used with BASIC or floating point)
; ------------------------------------------------------------ 
 .segment "ZEROPAGE"
 
 u0:		.res 2
 u0L		= u0
 u0H		= u0+1
 u1:		.res 2
 u1L		= u1
 u1H		= u1+1
 u2:		.res 2
 u2L		= u2
 u2H		= u2+1
 u3:		.res 2
 u3L		= u3
 u3H		= u3+1
 u4:		.res 2
 u4L		= u4
 u4H		= u4+1
 u5:		.res 2
 u5L		= u5
 u5H		= u5+1
 u6:		.res 2
 u6L		= u6
 u6H		= u6+1
 u7:		.res 2
 u7L		= u7
 u7H		= u7+1
 u8:		.res 2
 u8L		= u8
 u8H		= u8+1
 u9:		.res 2
 u9L		= u9
 u9H		= u9+1
 u10:		.res 2
 u10L		= u10
 u10H		= u10+1
 u11:		.res 2
 u11L		= u11
 u11H		= u11+1
 u12:		.res 2
 u12L		= u12
 u12H		= u12+1
 u13:		.res 2
 u13L		= u13
 u13H		= u13+1
 u14:		.res 2
 u14L		= u14
 u14H		= u14+1
 u15:		.res 2
 u15L		= u15
 u15H		= u15+1

.endif
