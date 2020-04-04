LATEX_SOURCES := $(wildcard *.tex) $(wildcard **/*.tex)
LATEX_RESOURCES := $(wildcard **/*.pdf) $(wildcard **/*.eps) $(wildcard **/*.jpg) $(wildcard **/*.png)
REMOTE_RESOURCES := Figures/Miami.pdf

build: Thesis.pdf

%.pdf: %.tex $(LATEX_SOURCES) $(LATEX_RESOURCES) $(REMOTE_RESOURCES)
	pdflatex --shell-escape $<

Figures/Miami.pdf:
	-mkdir Figures/
	wget https://miamioh.edu/_files/images/ucm/resources/logo/M_186K.pdf -O $@
