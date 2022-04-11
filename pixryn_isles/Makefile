NAME = PIXRYN
PREFIX = PI

ASSEMBLER6502 = cl65
ASFLAGS =

RESOURCES = $(PREFIX)L0MAP.BIN \
			$(PREFIX)L1MAP.BIN \
			$(PREFIX)CLSNMAP.BIN \
			$(PREFIX)TAVL0.BIN \
			$(PREFIX)TAVL1.BIN \
			$(PREFIX)TAVCLSN.BIN \
			$(PREFIX)INT.BIN \
			$(PREFIX)TAVINT.BIN

MESSAGES = $(PREFIX)MSG.BIN

all: resources messages

$(PREFIX)L0MAP.BIN: Pixryn_Isles.tmx
	tmx2vera Pixryn_Isles.tmx $(PREFIX)L0MAP.BIN -l terrain

$(PREFIX)L1MAP.BIN: Pixryn_Isles.tmx
	tmx2vera Pixryn_Isles.tmx $(PREFIX)L1MAP.BIN -l things

$(PREFIX)CLSNMAP.BIN: Pixryn_Isles.tmx
	tmx2vera -c Pixryn_Isles.tmx $(PREFIX)CLSNMAP.BIN -l collision

$(PREFIX)INT.BIN: Pixryn_Isles.tmx
	tmx2vera -c Pixryn_Isles.tmx $(PREFIX)INT.BIN -l interaction

$(PREFIX)TAVL0.BIN: tavern.tmx
	tmx2vera tavern.tmx $(PREFIX)TAVL0.BIN -l terrain

$(PREFIX)TAVL1.BIN: tavern.tmx
	tmx2vera tavern.tmx $(PREFIX)TAVL1.BIN -l things

$(PREFIX)TAVCLSN.BIN: tavern.tmx
	tmx2vera -c tavern.tmx $(PREFIX)TAVCLSN.BIN -l collision

$(PREFIX)TAVINT.BIN: tavern.tmx
	tmx2vera -c tavern.tmx $(PREFIX)TAVINT.BIN -l interaction

$(PREFIX)MSG.BIN: messages.asm
	$(ASSEMBLER6502) $(ASFLAGS) -o temp.bin messages.asm -l $(PREFIX)MSG.list
	# cheap hack because I can't figure out how to remove a header from cl65 output
	tail -c +13 temp.bin > $(PREFIX)MSG.BIN
	rm temp.bin


resources: $(RESOURCES)

messages: $(MESSAGES)

clean:
	rm -f $(RESOURCES) $(MESSAGES)

list:
	echo $(RESOURCES) $(MESSAGES)
