NAME = SPRITES

ASSEMBLER6502 = cl65
ASFLAGS =

RESOURCES = AURORA.BIN \
			LUNA.BIN \
			CONNOR.BIN \
			GEORGE.BIN \
			ELLIOT.BIN \
			OLLIE.BIN \
			TESTNPC.BIN \
			SHIP.BIN \
			BALLOON.BIN \
			PROPELLER.BIN

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

OLLIE.BIN: Ollie_Sprites.xcf
	gimp -i -d -f -b '(export-vera "Ollie_Sprites.xcf" "OLLIE.BIN" 0 8 16 16 0 1 0)' -b '(gimp-quit 0)'

TESTNPC.BIN: testnpc.xcf
	gimp -i -d -f -b '(export-vera "testnpc.xcf" "TESTNPC.BIN" 0 8 16 16 0 1 0)' -b '(gimp-quit 0)'

SHIP.BIN: simple_ship.xcf
	gimp -i -d -f -b '(export-vera "simple_ship.xcf" "SHIP.BIN" 0 8 64 16 0 1 0)' -b '(gimp-quit 0)'

BALLOON.BIN: balloon.xcf
	gimp -i -d -f -b '(export-vera "balloon.xcf" "BALLOON.BIN" 0 8 64 32 0 1 0)' -b '(gimp-quit 0)'

PROPELLER.BIN: propeller.xcf
	gimp -i -d -f -b '(export-vera "propeller.xcf" "PROPELLER.BIN" 0 8 8 8 0 1 0)' -b '(gimp-quit 0)'

resources: $(RESOURCES)

clean:
	rm -f $(RESOURCES)

list:
	echo $(RESOURCES)
