NAME = SPRITES

ASSEMBLER6502 = cl65
ASFLAGS =

RESOURCES = AURORA.BIN \
			LUNA.BIN \
			CONNOR.BIN \
			GEORGE.BIN \
			ELLIOT.BIN

MESSAGES = $(PREFIX)MSG.BIN

all: resources

AURORA.BIN: Aurora_Sprites.xcf
	gimp -i -d -f -b '(export-vera "Aurora_Sprites.xcf" "AURORA.BIN" 0 8 16 16 0 1 0)' -b '(gimp-quit 0)'

LUNA.BIN: Luna_Sprites.xcf
	gimp -i -d -f -b '(export-vera "Luna_Sprites.xcf" "LUNA.BIN" 0 8 16 16 0 1 0)' -b '(gimp-quit 0)'

CONNOR.BIN: Connor_Sprites.xcf
	gimp -i -d -f -b '(export-vera "Connor_Sprites.xcf" "CONNOR.BIN" 0 8 16 16 0 1 0)' -b '(gimp-quit 0)'

GEORGE.BIN: George_Sprites.xcf
	gimp -i -d -f -b '(export-vera "George_Sprites.xcf" "GEORGE.BIN" 0 8 16 16 0 1 0)' -b '(gimp-quit 0)'

ELLIOT.BIN: Elliot_Sprites.xcf
	gimp -i -d -f -b '(export-vera "Elliot_Sprites.xcf" "ELLIOT.BIN" 0 8 16 16 0 1 0)' -b '(gimp-quit 0)'

resources: $(RESOURCES)

clean:
	rm -f $(RESOURCES)

list:
	echo $(RESOURCES)
