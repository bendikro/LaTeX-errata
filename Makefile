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
	@(test -d '$(BUILD_DIR)' || (test -n '$(BUILD_DIR)') && (mkdir -p $(BUILD_DIR))) ; true

all  : ##Build package and doc
all: .builddir package manual

package  : ##Build the package files

DTX.sty.base=$(PACKAGE)
DTX.deps=$(PACKAGE).sty errata2pgfkeysextra.sty errata2strkeyformatter.sty errata2linecounter.sty errata2styles.sty

include $(MKPREFIX)/Makefile.vars.mk
export TEXINPUTS := $(TEXINPUTS)./build:
include $(MKPREFIX)/Makefile.in

ifeq ($(VERBOSE),true)
PDFLATEX_OPTIONS=
endif

manual : ##Build PDF manual
manual: .builddir $(DTX.pdf)

test   : ##Build errata2test.pdf
test: custompdf
	make custompdf CUSTOM=$(ERRATA2TEST)

errata_table_lineno   : ##Build errata_table_lineno.pdf
errata_table_lineno:
	make custompdf CUSTOM=$(ERRATA2_TABLE_LINENO)

custompdf   : ##Build custom PDF
custompdf: .builddir $(DTX.pdf)  $(CUSTOM.pdf)


##################
# Clean targets

CLEAN_TMP_EXT = .aux .listing .ind .tcbtemp .pyg .hd .idx .fls .ilg .gls .glo .toc -errata.tex
CLEAN_BUILD_EXT = .log .out .fdb_latexmk .synctex.gz
CLEAN_FINAL_EXT=.pdf .ps .dvi
CLEAN_EXTRA_EXT=$(CLEAN_FINAL_EXT)
CLEAN_EXT = $(CLEAN_EXTRA_EXT) $(CLEAN_TMP_EXT) $(CLEAN_BUILD_EXT)

CLEAN_BUILT_SRC=*out.pyg* $(DTX.deps)
CLEAN_PREFIX=


generate_clean_files%:
	$(eval CLEAN_FILES=$(foreach NEWCLEANPREFIX,$(CLEANPREFIXES),$(addprefix $(NEWCLEANPREFIX)$(CLEANWILDCARD),$(CLEAN_EXT))))

# To be able to call this multiple times, use different names
cleanfiles%:
	@echo "Cleaning files: $(CLEAN_FILES)"
#	@for fname in $(CLEAN_FILES) ; do \
#        echo " - $$fname" ; \
#    done
	rm -f $(CLEAN_FILES)

cleanbuiltsrc: # Cleans the build sources files
cleanbuiltsrc: CLEAN_FILES=$(CLEAN_BUILT_SRC)
cleanbuiltsrc: cleanfiles1

.PHONY: cleanbuildfiles
cleanbuildfiles: # Cleans files produced when building
cleanbuildfiles: CLEANWILDCARD=*
cleanbuildfiles: CLEANPREFIXES=build/ ""
cleanbuildfiles: generate_clean_files1 cleanfiles2

.PHONY: cleanmanual
cleanmanual: ##Clean files for errata2 manual
cleanmanual: CLEANPREFIXES=$(PACKAGE)
cleanmanual: generate_clean_files2 cleanfiles3
	rm -rf _minted-$(PACKAGE)

.PHONY: cleantest
cleantest: ##Clean errata2test files
cleantest: CLEANPREFIXES=$(ERRATA2TEST)
cleantest: generate_clean_files3 cleanfiles4
	rm -rf _minted-$(ERRATA2TEST)

.PHONY: clean
clean: ##Clean
clean: CLEAN_EXTRA_EXT=
clean: cleanmanual cleantest cleanbuildfiles

.PHONY: cleanall
cleanall: ##Clean files including generated source files
cleanall: CLEAN_EXTRA_EXT=$(CLEAN_FINAL_EXT)
cleanall: clean cleanbuiltsrc
	rm -rf ./build/


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
