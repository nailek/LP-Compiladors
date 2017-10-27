RM = rm -f

ALLOBJS = *.o

ALLDRIVOBS = *.exe *.prova

all: dist-clean mountains

allNew: clear all

mountains:
	clear && clear
	antlr -gt mountains.g
	dlg -ci parser.dlg scan.c
	g++ -w -o mountains mountains.c scan.c err.c -I/home/nailek/Documents/Q9/LP/pccts/h

clear: clean dist-clean

clean:
	$(RM) $(ALLOBJS) mountains.c scan.c err.c parser.dlg tokens.h mode.h

dist-clean: clean
	$(RM) $(ALLDRIVOBS)
	$(RM) mountains
