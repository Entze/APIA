GRAPHVIZ_FIGURES := $(wildcard Figures/*.dot)

LATEX_SOURCES := $(wildcard *.tex) $(wildcard **/*.tex)
LATEX_RESOURCES := $(wildcard **/*.pdf) $(wildcard **/*.eps) $(wildcard **/*.jpg) $(wildcard **/*.png) $(patsubst %.dot,%.pdf,$(GRAPHVIZ_FIGURES))
REMOTE_RESOURCES :=

build: Thesis.pdf

%.pdf: %.tex $(LATEX_SOURCES) $(LATEX_RESOURCES) $(REMOTE_RESOURCES)
	pdflatex --shell-escape $<

%.pdf: %.dot
	neato -Tpdf -o $@ $^
