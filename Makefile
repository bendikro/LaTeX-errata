PACKAGE = errata
all: errata.pdf

errata.sty: errata.dtx errata.ins
	pdflatex errata.ins

errata.pdf: errata.dtx errata.sty
	pdflatex errata.dtx
