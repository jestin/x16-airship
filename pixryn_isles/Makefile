NAME = PIXRYN
PREFIX = PI

RESOURCES = $(PREFIX)L0MAP.BIN \
			$(PREFIX)L1MAP.BIN \
			$(PREFIX)CLSNMAP.BIN \
			$(PREFIX)TAVL0.BIN \
			$(PREFIX)TAVL1.BIN \
			$(PREFIX)TAVCLSN.BIN \
			$(PREFIX)INT.BIN \
			$(PREFIX)TAVINT.BIN

all: resources

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


resources: $(RESOURCES)

clean:
	rm -f $(RESOURCES)

list:
	echo $(RESOURCES)
