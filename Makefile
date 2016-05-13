all:
	pdflatex thesis.tex
#	bibtex thesis
	pdflatex thesis.tex
	pdflatex thesis.tex
	
clean:
	rm -rf *.aux *.bbl *.blg *.log *.pdf
