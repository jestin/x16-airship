VGM2ZSM = vgm2zsm

RESOURCES = PIOVW.ZSM \
			PICAVE.ZSM

all: resources

resources: $(RESOURCES)

PIOVW.ZSM: Pixryn_Overworld.vgm
	$(VGM2ZSM) Pixryn_Overworld.vgm PIOVW.ZSM

PICAVE.ZSM: Pixryn_Cave.vgm
	$(VGM2ZSM) Pixryn_Cave.vgm PICAVE.ZSM

clean:
	rm -f $(RESOURCES)
