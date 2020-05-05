SOURCES = introduction.md wireless-networks.md cellular-networks.md ad-hoc-networks.md wireless-sensor-networks.md mqtt-protocol.md

mcps-notes.pdf: $(addprefix chapters/, ${SOURCES})
	cd chapters; pandoc ${SOURCES} -o ../$@

mcps-notes.md: $(addprefix chapters/, ${SOURCES})
	cd chapters; cat ${SOURCES} > ../$@

.PHONY: clean

clean:
	rm mcps-notes.pdf mcps-notes.md
