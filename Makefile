NAME = AIRSHIP
ASSEMBLER6502 = cl65
ASFLAGS = -t cx16 -l $(NAME).list

PROG = $(NAME).PRG
LIST = $(NAME).list
MAIN = main.asm
SOURCES := $(wildcard *.asm) $(wildcard *.inc)

RESOURCES = CHARSET.BIN \
			CLSN.BIN \
			TITLE.BIN \
			TIPAL.BIN

all: bin/$(PROG)

bin/$(PROG): $(SOURCES) bin
	$(ASSEMBLER6502) $(ASFLAGS) -o bin/$(PROG) $(MAIN)

SUBDIRS = pixryn_isles \
		  sprites

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
	gimp -i -d -f -b '(export-vera "Charset.xcf" "CHARSET.BIN" 0 8 8 8 0 0 0)' -b '(gimp-quit 0)'

CLSN.BIN: airship_collision_tiles.xcf
	gimp -i -d -f -b '(export-vera "airship_collision_tiles.xcf" "CLSN.BIN" 0 1 16 16 0 1 0)' -b '(gimp-quit 0)'

TITLE.BIN: title_screen.xcf
	gimp -i -d -f -b '(make-vera-bitmap "title_screen.xcf" "TITLE.BIN" 1920 1080 4 1 1)' -b '(gimp-quit 0)'


TIPAL.BIN: TITLE.BIN
	cp TITLE.BIN.PAL TIPAL.BIN

run: all resources
	(cd bin; x16emu -prg $(PROG) -run -scale 2 -debug -joy1)

card.img: all resources clean_card
	mkdir card
	dd if=/dev/zero of=card.img bs=1M count=1024; \
	printf 'n\n\n\n\n\nt\nc\nw\n' | fdisk card.img; \
	LOPNAM=`losetup -f`; \
	sudo losetup -o 1048576 $$LOPNAM card.img; \
	sudo mkfs -t vfat $$LOPNAM; \
	sudo losetup -d $$LOPNAM; \
	sudo mount -o rw,loop,offset=$$((2048*512)) card.img card; \
	sudo cp bin/* card; \
	sudo umount card; \
	rm -rf card

card: card.img

run_card:
	x16emu -sdcard card.img -prg bin/AIRSHIP.PRG -run -scale 2 -joy1 -debug

clean:
	rm  -f bin/$(PROG) $(LIST)

clean_subresources:
	-for i in $(SUBDIRS); do \
		echo "clean resources in $$i..."; \
		(cd $$i; make clean); done

clean_resources: clean_subresources
	rm -f $(RESOURCES)

clean_card:
	rm -rf card/
	rm -f card.img

cleanall: clean clean_resources
	rm -rf bin

bin:
	mkdir ./bin
