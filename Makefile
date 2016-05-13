all:
	pdflatex thesis.tex -shell-escape
#	bibtex thesis
	pdflatex thesis.tex
#	pdflatex thesis.tex
	
clean:
	rm -rf *.aux *.bbl *.blg *.log *.pdf
