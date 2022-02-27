NAME = AIRSHIP
ASSEMBLER6502 = cl65
ASFLAGS = -t cx16 -l $(NAME).list

PROG = $(NAME).PRG
LIST = $(NAME).list
MAIN = main.asm
SOURCES = $(MAIN) \
		  x16.inc \
		  vera.inc
RESOURCES = L0MAP.BIN \
			L1MAP.BIN

all: $(PROG)

$(PROG): $(SOURCES)
	$(ASSEMBLER6502) $(ASFLAGS) -o $(PROG) $(MAIN)

resources: $(RESOURCES)

L0MAP.BIN: airship_game_map.tmx
	tmx2vera airship_game_map.tmx L0MAP.BIN -l terrain

L1MAP.BIN: airship_game_map.tmx
	tmx2vera airship_game_map.tmx L1MAP.BIN -l things

run: all resources
	x16emu -prg $(PROG) -run -scale 2 -debug -joy1

clean:
	rm  -f $(PROG) $(LIST)

clean_resources:
	rm  -f $(RESOURCES)

cleanall: clean clean_resources
