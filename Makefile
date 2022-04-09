NAME = AIRSHIP
ASSEMBLER6502 = cl65
ASFLAGS = -t cx16 -l $(NAME).list

PROG = $(NAME).PRG
LIST = $(NAME).list
MAIN = main.asm
SOURCES := $(wildcard *.asm) $(wildcard *.inc)

all: bin/$(PROG)

bin/$(PROG): $(SOURCES) bin
	$(ASSEMBLER6502) $(ASFLAGS) -o bin/$(PROG) $(MAIN)

SUBDIRS = pixryn_isles

subresources:
	-for i in $(SUBDIRS); do \
		echo "make resources in $$i..."; \
		(cd $$i; make all); done

resources: subresources bin
	-for i in $(SUBDIRS); do \
		echo "copying resources from $$i..."; \
		cp $$i/*.BIN bin/; done
	cp *.BIN bin
	cp sprites/*.BIN bin

run: all resources
	(cd bin; x16emu -prg $(PROG) -run -scale 2 -debug -joy1)

clean:
	rm  -f bin/$(PROG) $(LIST)

clean_resources:
	-for i in $(SUBDIRS); do \
		echo "clean resources in $$i..."; \
		(cd $$i; make clean); done

cleanall: clean clean_resources
	rm -rf bin

bin:
	mkdir ./bin
