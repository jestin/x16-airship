NAME = AIRSHIP
VERSION = 0.0.1

ASSEMBLER6502 = cl65
INCLUDEDIR = 3rdParty/include/
LIBDIR = 3rdParty/lib/
LIBS = zsound.lib

ASFLAGS = -t cx16 -l $(NAME).list -L $(LIBDIR) --asm-include-dir $(INCLUDEDIR) -C cx16-aligned.cfg

PROG = $(NAME).PRG
LIST = $(NAME).list
ZIPFILE = $(NAME)_$(VERSION).zip
MAIN = main.asm
SOURCES := $(shell find -type f -name '*.asm') $(shell find -type f -name '*.inc')

RESOURCES = CHARSET.BIN \
			CLSN.BIN \
			TITLE.BIN \
			TIPAL.BIN \
			VIMASK.BIN

all: clean bin/$(PROG)

bin/$(PROG): $(SOURCES) bin
	$(ASSEMBLER6502) $(ASFLAGS) -o bin/$(PROG) $(MAIN) $(LIBS)

SUBDIRS = pixryn_isles \
		  sprites \
		  music

subresources:
	-for i in $(SUBDIRS); do \
		echo "make resources in $$i..."; \
		(cd $$i; make all); done

resources: subresources bin $(RESOURCES)
	-for i in $(SUBDIRS); do \
		echo "copying resources from $$i..."; \
		cp $$i/*.BIN bin/ 2> /dev/null || :; done
	cp *.BIN bin 2> /dev/null
	cp sprites/*.BIN bin 2> /dev/null
	cp music/*.ZSM bin 2> /dev/null

CHARSET.BIN: Charset.xcf
	gimp -i -d -f -b '(export-vera "Charset.xcf" "CHARSET.BIN" 0 4 8 8 0 0 0)' -b '(gimp-quit 0)'

CLSN.BIN: airship_collision_tiles.xcf
	gimp -i -d -f -b '(export-vera "airship_collision_tiles.xcf" "CLSN.BIN" 0 1 16 16 0 1 0)' -b '(gimp-quit 0)'

TITLE.BIN: title_screen.xcf
	gimp -i -d -f -b '(make-vera-bitmap "title_screen.xcf" "TITLE.BIN" 1920 1080 4 1 1)' -b '(gimp-quit 0)'

TIPAL.BIN: TITLE.BIN
	cp TITLE.BIN.PAL TIPAL.BIN

VIMASK.BIN: visibility_mask.tmx
	tmx2vera visibility_mask.tmx -l mask VIMASK.BIN

run: all resources
	(cd bin; x16emu -prg $(PROG) -run -scale 2 -ram 2048 -debug -joy1 -abufs 64)

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
	x16emu -sdcard card.img -prg bin/AIRSHIP.PRG -run -scale 2 -ram 2048 -joy1 -abufs 64 -debug

$(ZIPFILE): all resources clean_zip
	(cd bin; zip ../$(ZIPFILE) *)

zip: $(ZIPFILE)

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

clean_zip:
	rm -f $(ZIPFILE)

cleanall: clean clean_resources
	rm -rf bin

bin:
	mkdir ./bin
