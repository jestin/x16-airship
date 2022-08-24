NAME = PIXRYN
PREFIX = PI

ASSEMBLER6502 = cl65
ASFLAGS =

RESOURCES = $(PREFIX)TILES.BIN \
			$(PREFIX)L0MAP.BIN \
			$(PREFIX)L1MAP.BIN \
			$(PREFIX)CLSNMAP.BIN \
			$(PREFIX)INT.BIN \
			$(PREFIX)TAVL0.BIN \
			$(PREFIX)TAVL1.BIN \
			$(PREFIX)TAVCLSN.BIN \
			$(PREFIX)TAVINT.BIN \
			$(PREFIX)HOMEL0.BIN \
			$(PREFIX)HOMEL1.BIN \
			$(PREFIX)HOMECLSN.BIN \
			$(PREFIX)HOMEINT.BIN \
			$(PREFIX)CABINL0.BIN \
			$(PREFIX)CABINL1.BIN \
			$(PREFIX)CABINCLSN.BIN \
			$(PREFIX)CABININT.BIN \
			$(PREFIX)SHIPSHOPL0.BIN \
			$(PREFIX)SHIPSHOPL1.BIN \
			$(PREFIX)SHIPSHOPCLSN.BIN \
			$(PREFIX)SHIPSHOPINT.BIN \
			$(PREFIX)CAVEL0.BIN \
			$(PREFIX)CAVEL1.BIN \
			$(PREFIX)CAVECLSN.BIN \
			$(PREFIX)CAVEINT.BIN \
			$(PREFIX)PAL.BIN

MESSAGES = $(PREFIX)MSG.BIN

MISC_ARTIFACTS = $(PREFIX)TILES.BIN.PAL

all: resources messages

$(PREFIX)TILES.BIN: Pixryn_Tiles.xcf
	gimp -i -d -f -b '(export-vera "Pixryn_Tiles.xcf" "$(PREFIX)TILES.BIN" 0 8 16 16 0 1 1)' -b '(gimp-quit 0)'

$(PREFIX)PAL.BIN: $(PREFIX)TILES.BIN
	cp $(PREFIX)TILES.BIN.PAL $(PREFIX)PAL.BIN

$(PREFIX)L0MAP.BIN: Pixryn_Isles.tmx
	tmx2vera Pixryn_Isles.tmx $(PREFIX)L0MAP.BIN -l terrain -d

$(PREFIX)L1MAP.BIN: Pixryn_Isles.tmx
	tmx2vera Pixryn_Isles.tmx $(PREFIX)L1MAP.BIN -l things -d

$(PREFIX)CLSNMAP.BIN: Pixryn_Isles.tmx
	tmx2vera -c Pixryn_Isles.tmx $(PREFIX)CLSNMAP.BIN -l collision

$(PREFIX)INT.BIN: Pixryn_Isles.tmx
	tmx2vera -c Pixryn_Isles.tmx $(PREFIX)INT.BIN -l interaction

$(PREFIX)TAVL0.BIN: tavern.tmx
	tmx2vera tavern.tmx $(PREFIX)TAVL0.BIN -l terrain -d

$(PREFIX)TAVL1.BIN: tavern.tmx
	tmx2vera tavern.tmx $(PREFIX)TAVL1.BIN -l things -d

$(PREFIX)TAVCLSN.BIN: tavern.tmx
	tmx2vera -c tavern.tmx $(PREFIX)TAVCLSN.BIN -l collision

$(PREFIX)TAVINT.BIN: tavern.tmx
	tmx2vera -c tavern.tmx $(PREFIX)TAVINT.BIN -l interaction

$(PREFIX)HOMEL0.BIN: home.tmx
	tmx2vera home.tmx $(PREFIX)HOMEL0.BIN -l terrain -d

$(PREFIX)HOMEL1.BIN: home.tmx
	tmx2vera home.tmx $(PREFIX)HOMEL1.BIN -l things -d

$(PREFIX)HOMECLSN.BIN: home.tmx
	tmx2vera -c home.tmx $(PREFIX)HOMECLSN.BIN -l collision

$(PREFIX)HOMEINT.BIN: home.tmx
	tmx2vera -c home.tmx $(PREFIX)HOMEINT.BIN -l interaction

$(PREFIX)CABINL0.BIN: cabin.tmx
	tmx2vera cabin.tmx $(PREFIX)CABINL0.BIN -l terrain -d

$(PREFIX)CABINL1.BIN: cabin.tmx
	tmx2vera cabin.tmx $(PREFIX)CABINL1.BIN -l things -d

$(PREFIX)CABINCLSN.BIN: cabin.tmx
	tmx2vera -c cabin.tmx $(PREFIX)CABINCLSN.BIN -l collision

$(PREFIX)CABININT.BIN: cabin.tmx
	tmx2vera -c cabin.tmx $(PREFIX)CABININT.BIN -l interaction

$(PREFIX)SHIPSHOPL0.BIN: dirigible_shop.tmx
	tmx2vera dirigible_shop.tmx -l terrain $(PREFIX)SHIPSHOPL0.BIN -d

$(PREFIX)SHIPSHOPL1.BIN: dirigible_shop.tmx
	tmx2vera dirigible_shop.tmx -l things $(PREFIX)SHIPSHOPL1.BIN -d

$(PREFIX)SHIPSHOPCLSN.BIN: dirigible_shop.tmx
	tmx2vera -c dirigible_shop.tmx -l collision $(PREFIX)SHIPSHOPCLSN.BIN -d

$(PREFIX)SHIPSHOPINT.BIN: dirigible_shop.tmx
	tmx2vera -c dirigible_shop.tmx -l interaction $(PREFIX)SHIPSHOPINT.BIN -d

$(PREFIX)CAVEL0.BIN: cave.tmx
	tmx2vera cave.tmx $(PREFIX)CAVEL0.BIN -l terrain -d

$(PREFIX)CAVEL1.BIN: cave.tmx
	tmx2vera cave.tmx $(PREFIX)CAVEL1.BIN -l things -d

$(PREFIX)CAVECLSN.BIN: cave.tmx
	tmx2vera -c cave.tmx $(PREFIX)CAVECLSN.BIN -l collision

$(PREFIX)CAVEINT.BIN: cave.tmx
	tmx2vera -c cave.tmx $(PREFIX)CAVEINT.BIN -l interaction

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
