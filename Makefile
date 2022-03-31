NAME = AIRSHIP
ASSEMBLER6502 = cl65
ASFLAGS = -t cx16 -l $(NAME).list

PROG = $(NAME).PRG
LIST = $(NAME).list
MAIN = main.asm
SOURCES := $(wildcard *.asm) $(wildcard *.inc)

#RESOURCES = L0MAP.BIN \
#			L1MAP.BIN \
#			CLSNMAP.BIN

RESOURCES = PITILES.BIN \
			PIL0MAP.BIN \
			PIL1MAP.BIN \
			PICLSNMAP.BIN \
			TAVL0.BIN \
			TAVL1.BIN \
			TAVCLSN.BIN \
			PIINT.BIN \
			PITAVINT.BIN

all: $(PROG)

$(PROG): $(SOURCES)
	$(ASSEMBLER6502) $(ASFLAGS) -o $(PROG) $(MAIN)

resources: $(RESOURCES)

PITILES.BIN: pixryn_isles/PITILES.BIN
	cp pixryn_isles/PITILES.BIN .

PIL0MAP.BIN: pixryn_isles/Pixryn_Isles.tmx
	tmx2vera pixryn_isles/Pixryn_Isles.tmx PIL0MAP.BIN -l terrain

PIL1MAP.BIN: pixryn_isles/Pixryn_Isles.tmx
	tmx2vera pixryn_isles/Pixryn_Isles.tmx PIL1MAP.BIN -l things

PICLSNMAP.BIN: pixryn_isles/Pixryn_Isles.tmx
	tmx2vera -c pixryn_isles/Pixryn_Isles.tmx PICLSNMAP.BIN -l collision

PIINT.BIN: pixryn_isles/Pixryn_Isles.tmx
	tmx2vera -c pixryn_isles/Pixryn_Isles.tmx PIINT.BIN -l interaction

TAVL0.BIN: pixryn_isles/tavern.tmx
	tmx2vera pixryn_isles/tavern.tmx TAVL0.BIN -l terrain

TAVL1.BIN: pixryn_isles/tavern.tmx
	tmx2vera pixryn_isles/tavern.tmx TAVL1.BIN -l things

TAVCLSN.BIN: pixryn_isles/tavern.tmx
	tmx2vera -c pixryn_isles/tavern.tmx TAVCLSN.BIN -l collision

PITAVINT.BIN: pixryn_isles/tavern.tmx
	tmx2vera -c pixryn_isles/tavern.tmx PITAVINT.BIN -l interaction

#L0MAP.BIN: airship_game_map.tmx
#	tmx2vera airship_game_map.tmx L0MAP.BIN -l terrain
#
#L1MAP.BIN: airship_game_map.tmx
#	tmx2vera airship_game_map.tmx L1MAP.BIN -l things
#
#CLSNMAP.BIN: airship_game_map.tmx
#	tmx2vera -c airship_game_map.tmx CLSNMAP.BIN -l collision

run: all resources
	x16emu -prg $(PROG) -run -scale 2 -debug -joy1

clean:
	rm  -f $(PROG) $(LIST)

clean_resources:
	rm  -f $(RESOURCES)

cleanall: clean clean_resources
