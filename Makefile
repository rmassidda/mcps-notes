SOURCES = introduction.md wireless-networks.md cellular-networks.md ad-hoc-networks.md wireless-sensor-networks.md

notes.pdf: $(addprefix chapters/, ${SOURCES})
	pandoc $^ -o $@

notes.md: $(addprefix chapters/, ${SOURCES})
	cat $^ > $@

.PHONY: clean

clean:
	rm notes.pdf notes.md
