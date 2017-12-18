MKPREFIX=lib
PACKAGE=errata2
BUILD_DIR=build

ERRATA2TEST=errata2test
ERRATA2_TABLE_LINENO=errata_table_lineno

#%# CUSTOM : Custom document to build to pdf. Default: errata2test
CUSTOM?=$(ERRATA2TEST)

#%# VERBOSE : Verbose output from pdflatex (true/false). Default: true
VERBOSE?=true

.DEFAULT_GOAL := help

.builddir: # Target to ensure ./build dir is created
	(test -d '$(BUILD_DIR)' || (test -n '$(BUILD_DIR)') && (mkdir -p $(BUILD_DIR))) ; true

all  : ##Build package and doc
all: .builddir package doc

package  : ##Build package
doc      : ##Build doc


DTX.sty.base=$(PACKAGE)
DTX.deps=$(PACKAGE).sty errata2strkeyformatter.sty errata2linecounter.sty errata2styles.sty

include $(MKPREFIX)/Makefile.vars.mk
export TEXINPUTS := $(TEXINPUTS)./build:
include $(MKPREFIX)/Makefile.in

ifeq ($(VERBOSE),true)
PDFLATEX_OPTIONS=
endif

manual : ##Build PDF manual
manual: .builddir $(DTX.pdf)

errata2test   : ##Build errata2test.pdf
errata2test: custompdf
	make custompdf CUSTOM=$(ERRATA2TEST)

errata_table_lineno   : ##Build errata_table_lineno.pdf
errata_table_lineno:
	make custompdf CUSTOM=$(ERRATA2_TABLE_LINENO)

custompdf   : ##Build erratatest.pdf
custompdf: .builddir $(DTX.pdf)  $(CUSTOM.pdf)
	@echo "CUSTOM.deps:" $(CUSTOM.deps)


tboxtest: .builddir $(DTX.pdf) tboxtest.tex
	latexmk  -pdflatex='pdflatex -synctex=1 -file-line-error -shell-escape' -pdf tboxtest

CLEAN_FINAL_EXT = pdf ps dvi
CLEAN_TMP_EXT = aux listing ind tcbtemp pyg hd idx fls ilg gls glo log toc
CLEAN_BUILD_EXT = log out fdb_latexmk synctex.gz

CLEAN_EXT = $(CLEAN_FINAL_EXT) $(CLEAN_TMP_EXT) $(CLEAN_BUILD_EXT)

CLEAN_BUILT_SRC=*out.pyg* *.sty *-errata.tex errata2styles.tex errata2pgfkeysextra.sty
CLEAN_PREFIX=errata


.PHONY: setcleanmanual setcleantest cleantest cleanman setcleantboxtest

setcleanmanual:
	$(eval CLEAN_PREFIX := $(PACKAGE))

setcleanmanualbuild:
	$(eval CLEAN_PREFIX := build/$(PACKAGE))

setcleantest:
	$(eval CLEAN_PREFIX := $(ERRATA2TEST))

setcleantestbuild:
	$(eval CLEAN_PREFIX := build/$(ERRATA2TEST))

docleanext%:
	@echo "Target cleanext!!!!"
	rm -f $(addprefix $(CLEAN_PREFIX).,$(CLEAN_EXT))

docleantex:
	rm -f build/*.tex

cleanbuiltsrc: # Cleans the build sources files
	@echo "Target cleanext"
	rm -f $(CLEAN_BUILT_SRC)

cleanmanual: setcleanmanual docleanext1 setcleanmanualbuild docleanext2 docleantex
cleantest: setcleantest docleanext3 setcleantestbuild docleanext4

clean  : ##Clean
clean: cleanmanual cleantest

cleanall  : ##Clean files including generated source files
cleanall: clean cleanbuiltsrc
	rm -f $(addprefix *.,$(CLEAN_TMP_EXT)) *-errata.tex

cleandist : ##Clean everything
cleandist: clean cleanbuiltsrc
	rm -f *.aux *.ind *.gls *.ps *.dvi *.toc *.xml *.omdoc *.thm *.pdf
	rm -Rf auto

setcleantboxtest:
	$(eval CLEAN_PREFIX := tboxtest)

cleantboxtest: setcleantboxtest docleanext5

.PHONY: help
help            : ##Show this help
	@echo "-----------------------------------------------------------------"
	@echo "  Available make targets"
	@echo "-----------------------------------------------------------------"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -rn "s/(\S+)\s+:+?\s##(.*)/\1 \"\2\"/p" | xargs printf " %-20s    : %5s\n"
	@echo
	@echo "  Available environment configurations to set with 'make [VARIABLE=value] <target>'"
	@echo "-----------------------------------------------------------------"
	@fgrep -h "#%#" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -rn "s/#%#\s+(\S+)\s+:+?\s+(.*)/\1 \"\2\"/p" | xargs printf " %-20s    : %5s\n"
	@echo
	@echo "Example:\n make VERBOSE=true"
	@echo
	@echo "Build custom document (customexample.tex):\n make custompdf CUSTOM=customexample"
	@echo
