HOCKING-binomial-seg.pdf: HOCKING-binomial-seg.tex refs.bib figure-binomial-loss.pdf
	rm -rf *.aux *.bbl
	pdflatex HOCKING-binomial-seg
	bibtex HOCKING-binomial-seg
	pdflatex HOCKING-binomial-seg
	pdflatex HOCKING-binomial-seg
figure-binomial-loss.pdf: figure-binomial-loss.R
	R --no-save < $<
public.small.RData: public.small.R
	R --no-save < $<
