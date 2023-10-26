NAME = AKOKO
PREFIX = AM

ASSEMBLER6502 = cl65
ASFLAGS =

RESOURCES = $(PREFIX)TILES.BIN \
			$(PREFIX)L0MAP.BIN \
			$(PREFIX)L1MAP.BIN \
			$(PREFIX)CLSNMAP.BIN \
			$(PREFIX)INT.BIN \
			$(PREFIX)PAL.BIN

MESSAGES = $(PREFIX)MSG.BIN

MISC_ARTIFACTS = $(PREFIX)TILES.BIN.PAL

all: resources messages

$(PREFIX)TILES.BIN: Akoko_Tiles.xcf
	gimp -i -d -f -b '(export-vera "Akoko_Tiles.xcf" "$(PREFIX)TILES.BIN" 0 0 8 16 16 0 1 1)' -b '(gimp-quit 0)'

$(PREFIX)PAL.BIN: $(PREFIX)TILES.BIN
	cp $(PREFIX)TILES.BIN.PAL $(PREFIX)PAL.BIN

$(PREFIX)L0MAP.BIN: akoko_overworld.tmx
	tmx2vera akoko_overworld.tmx $(PREFIX)L0MAP.BIN -l terrain -d

$(PREFIX)L1MAP.BIN: akoko_overworld.tmx
	tmx2vera akoko_overworld.tmx $(PREFIX)L1MAP.BIN -l things -d

$(PREFIX)CLSNMAP.BIN: akoko_overworld.tmx
	tmx2vera -c akoko_overworld.tmx $(PREFIX)CLSNMAP.BIN -l collision

$(PREFIX)INT.BIN: akoko_overworld.tmx
	tmx2vera -c akoko_overworld.tmx $(PREFIX)INT.BIN -l interaction

$(PREFIX)MSG.BIN: messages.asm
	$(ASSEMBLER6502) $(ASFLAGS) -o temp.bin messages.asm -l $(PREFIX)MSG.list
	# cheap hack because I can't figure out how to remove a header from cl65 output
	tail -c +13 temp.bin > $(PREFIX)MSG.BIN
	rm temp.bin


resources: $(RESOURCES)

messages: $(MESSAGES)

clean:
	rm -f $(RESOURCES) $(MESSAGES) $(MISC_ARTIFACTS)

list:
	echo $(RESOURCES) $(MESSAGES)
