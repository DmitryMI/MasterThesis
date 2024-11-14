.PHONY: all clean zip

all: thesis.pdf

clean:
	del *.pdf
	del *.lgpl
	del *.log
	del *.pipe
	del *.aux
	del *.bbl
	del *.blg
	del *.fdb_latexmk
	del *.fls
	del *.lof
	del *.lot
	del *.out
	del *.xml
	del *.synctex(busy)
	del *.tdo
	del *.toc

zip: nsm-thesis.zip

thesis.pdf: thesis.tex references.bib
	latexmk -pdf thesis
