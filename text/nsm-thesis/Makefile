.PHONY: all clean zip

all: thesis.pdf

clean:
	rm -f thesis.pdf nsm-thesis.zip

zip: nsm-thesis.zip

thesis.pdf: thesis.tex references.bib
	latexmk -pdf thesis

nsm-thesis.zip: ./Makefile ./nsm-thesis.cls ./figures ./figures/connectivity-50-0-static1.pdf ./figures/coverage-30--0-static1.pdf ./figures/related_work.pdf ./references.bib ./thesis.pdf ./thesis.tex
	zip "$@" $^
