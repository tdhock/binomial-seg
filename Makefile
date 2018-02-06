HOCKING-constrained-binomial-seg.pdf: HOCKING-constrained-binomial-seg.tex refs.bib
	rm -rf *.aux *.bbl
	pdflatex HOCKING-constrained-binomial-seg
	bibtex HOCKING-constrained-binomial-seg
	pdflatex HOCKING-constrained-binomial-seg
	pdflatex HOCKING-constrained-binomial-seg
HOCKING-binomial-seg.pdf: HOCKING-binomial-seg.tex refs.bib figure-binomial-loss.pdf figure-public-small.pdf
	rm -rf *.aux *.bbl
	pdflatex HOCKING-binomial-seg
	bibtex HOCKING-binomial-seg
	pdflatex HOCKING-binomial-seg
	pdflatex HOCKING-binomial-seg
figure-binomial-loss.pdf: figure-binomial-loss.R
	R --no-save < $<
public.small.RData: public.small.R
	R --no-save < $<
figure-public-small.pdf: figure-public-small.R public.small.RData
	R --no-save < $<
ichange_classes.RData: ichange_classes.R ichange_classes.txt
	R --no-save < $<
