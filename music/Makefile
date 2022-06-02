VGM2ZSM = vgm2zsm

RESOURCES = PIOVW.ZSM \
			PICAVE.ZSM \
			TITLE.ZSM

all: resources

resources: $(RESOURCES)

TITLE.ZSM: Take_to_the_Skies.vgm
	$(VGM2ZSM) Take_to_the_Skies.vgm TITLE.ZSM

PIOVW.ZSM: Pixryn_Overworld.vgm
	$(VGM2ZSM) Pixryn_Overworld.vgm PIOVW.ZSM

PICAVE.ZSM: Pixryn_Cave.vgm
	$(VGM2ZSM) Pixryn_Cave.vgm PICAVE.ZSM

clean:
	rm -f $(RESOURCES)
