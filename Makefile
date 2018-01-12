PREFIX  ?= /usr/local
FMOD     = 755
LASAGNA  = bin/lasagna.pl

install: $(LASAGNA)
	install -m $(FMOD) $(LASAGNA) $(PREFIX)/$(basename $(LASAGNA))

.PHONY: uninstall 
uninstall:
	rm -f $(PREFIX)/$(basename $(LASAGNA))

