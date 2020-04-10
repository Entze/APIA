LATEX_SOURCES := $(wildcard *.tex) $(wildcard **/*.tex)
LATEX_RESOURCES := $(wildcard **/*.pdf) $(wildcard **/*.eps) $(wildcard **/*.jpg) $(wildcard **/*.png)
REMOTE_RESOURCES :=

build: Thesis.pdf

%.pdf: %.tex $(LATEX_SOURCES) $(LATEX_RESOURCES) $(REMOTE_RESOURCES)
	pdflatex --shell-escape $<
