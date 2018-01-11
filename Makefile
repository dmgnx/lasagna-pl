PREFIX  ?= /usr/local/bin
FMOD     = 755
LASAGNA  = bin/lasagna.pl

install: $(LASAGNA)
	install -m $(FMOD) $(LASAGNA) $(PREFIX)/$(basename $(notdir $(LASAGNA)))

.PHONY: uninstall 
uninstall:
	rm -f $(PREFIX)/$(basename $(notdir $(LASAGNA)))

