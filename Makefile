PREFIX = lib
PACKAGE = errata
DTX.sty.base = errata
EXAMPLE.base = erratatest
EXAMPLE.deps := strkeyformatter.sty

BUILD_DIR = build

.builddir:
	(test -d '$(BUILD_DIR)' || (test -n '$(BUILD_DIR)') && (mkdir -p $(BUILD_DIR))) ; true

all: .builddir package doc

include $(PREFIX)/Makefile.vars
export TEXINPUTS := $(TEXINPUTS)./build:
include $(PREFIX)/Makefile.in

manual: .builddir $(DTX.pdf)
erratatest: .builddir $(DTX.pdf)  $(EXAMPLE.pdf)
	@echo "EXAMPLE.deps:" $(EXAMPLE.deps)

tboxtest: .builddir $(DTX.pdf) tboxtest.tex
	latexmk  -pdflatex='pdflatex -synctex=1 -file-line-error -shell-escape' -pdf tboxtest

CLEAN_FINAL_EXT = pdf ps dvi
CLEAN_TMP_EXT = aux listing ind tcbtemp pyg hd idx fls ilg gls glo
CLEAN_BUILD_EXT = log out fdb_latexmk synctex.gz

CLEAN_EXT = $(CLEAN_FINAL_EXT) $(CLEAN_TMP_EXT) $(CLEAN_BUILD_EXT)

CLEAN_BUILT=*out.pyg* *.sty *-errata.tex erratastyles.tex erratapgfkeysextra.tex
CLEAN_PREFIX=errata

#distclean: 	clean
#	rm -f *.aux *.ind *.gls *.ps *.dvi *.toc *.xml *.omdoc *.thm
#	rm -Rf auto

.PHONY: setcleanman setcleantest cleantest cleanman setcleantboxtest
setcleanman:
	$(eval CLEAN_PREFIX := errata)
setcleanmanbuild:
	$(eval CLEAN_PREFIX := build/errata)
setcleantest:
	$(eval CLEAN_PREFIX := erratatest)
setcleantestbuild:
	$(eval CLEAN_PREFIX := build/erratatest)
docleanext%:
	rm -f $(addprefix $(CLEAN_PREFIX).,$(CLEAN_EXT))
docleantex:
	rm -f build/*.tex
cleanbuilt:
	rm -f $(CLEAN_BUILT)

cleanman: setcleanman docleanext1 setcleanmanbuild docleanext2 docleantex
cleantest: setcleantest docleanext3 setcleantestbuild docleanext4
cleanall: cleanman cleantest
distclean: cleanall cleanbuilt

#clean: setcleanman docleanext1


setcleantboxtest:
	$(eval CLEAN_PREFIX := tboxtest)

cleantboxtest: setcleantboxtest docleanext5

help:
	@echo "Available commands:"
	@echo "  doc         Create docs (manual and erratatest)"
	@echo "  manual      Compile the errata.pdf manual"
	@echo "  erratatest  Compile the erratatest.pdf"
	@echo "  clean       Basic cleanup"
	@echo "  cleanall    Clean all files"
