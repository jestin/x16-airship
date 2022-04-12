NAME = AIRSHIP
ASSEMBLER6502 = cl65
ASFLAGS = -t cx16 -l $(NAME).list

PROG = $(NAME).PRG
LIST = $(NAME).list
MAIN = main.asm
SOURCES := $(wildcard *.asm) $(wildcard *.inc)

RESOURCES = CHARSET.BIN \
			CLSN.BIN \
			INTERIOR.BIN

all: bin/$(PROG)

bin/$(PROG): $(SOURCES) bin
	$(ASSEMBLER6502) $(ASFLAGS) -o bin/$(PROG) $(MAIN)

SUBDIRS = pixryn_isles

subresources:
	-for i in $(SUBDIRS); do \
		echo "make resources in $$i..."; \
		(cd $$i; make all); done

resources: subresources bin $(RESOURCES)
	-for i in $(SUBDIRS); do \
		echo "copying resources from $$i..."; \
		cp $$i/*.BIN bin/; done
	cp *.BIN bin
	cp sprites/*.BIN bin

CHARSET.BIN: Charset.xcf
	gimp -i -b '(export-vera "Charset.xcf" "CHARSET.BIN" 0 8 8 8 0 1 0)' -b '(gimp-quit 0)'

CLSN.BIN: airship_collision_tiles.xcf
	gimp -i -b '(export-vera "airship_collision_tiles.xcf" "CLSN.BIN" 0 1 16 16 0 1 0)' -b '(gimp-quit 0)'

INTERIOR.BIN: interior_tiles.xcf
	gimp -i -b '(export-vera "interior_tiles.xcf" "INTERIOR.BIN" 0 8 16 16 0 1 0)' -b '(gimp-quit 0)'

run: all resources
	(cd bin; x16emu -prg $(PROG) -run -scale 2 -debug -joy1)

clean:
	rm  -f bin/$(PROG) $(LIST)

clean_subresources:
	-for i in $(SUBDIRS); do \
		echo "clean resources in $$i..."; \
		(cd $$i; make clean); done

clean_resources: clean_subresources
	rm -f $(RESOURCES)

cleanall: clean clean_resources
	rm -rf bin

bin:
	mkdir ./bin
