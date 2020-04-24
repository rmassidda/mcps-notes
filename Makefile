SOURCES = introduction.md

notes: $(SOURCES)
	pandoc $(SOURCES) -o mcps-notes.pdf
