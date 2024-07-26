This file has commands I did to set up arxiv submission.

``` bash
mkdir arxiv
cp flusion-manuscript.tex arxiv
cp flusion-supplement.tex arxiv
cp flusion.bib arxiv
cp ../artifacts/figures/*.pdf arxiv

# did some manual editing of tex files to fix figure paths

cd arxiv
pdflatex flusion-manuscript.tex
biber flusion-manuscript
pdflatex flusion-manuscript.tex

pdflatex flusion-supplement.tex
biber flusion-supplement
pdflatex flusion-supplement.tex

rm flusion-manuscript.pdf
rm flusion-supplement.pdf

mkdir arxiv-submission
cp *.pdf arxiv-submission
cp *.bbl arxiv-submission
cp *.tex arxiv-submission

cd arxiv-submission
tar -cvvf ax.tar *
```
