GRAPHVIZ_FIGURES := $(wildcard Figures/*/*.dot)
PLANTUML_FIGURES := $(wildcard Figures/*/*.plantuml)
SVG_FIGURES := $(wildcard Figures/*/*.svg)
DRAWIO_FIGURES := $(wildcard Figures/*/*.drawio)

LATEX_SOURCES := $(wildcard *.tex) $(wildcard */*.tex) $(wildcard *.bib)
LATEX_RESOURCES := $(wildcard */*.pdf) $(wildcard */*.eps) $(wildcard */*.jpg) $(wildcard */*.png) $(patsubst %.dot,%.pdf,$(GRAPHVIZ_FIGURES)) $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES)) $(patsubst %.svg,%.pdf,$(SVG_FIGURES))
REMOTE_RESOURCES :=

build: Thesis.pdf

build-graphviz: $(patsubst %.dot,%.pdf,$(GRAPHVIZ_FIGURES))

build-plantuml: $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES))

build-svg: $(patsubst %.svg,%.pdf,$(SVG_FIGURES))

%.pdf: %.tex $(LATEX_SOURCES) $(LATEX_RESOURCES) $(REMOTE_RESOURCES)
	latexmk -pdf

%.pdf: %.dot
	dot -Tpdf -o $@ $^

%.svg: %.plantuml
	plantuml -tsvg $<

%.pdf: %.svg
	inkscape --export-filename=$@ $<

clean:
	latexmk -C

.PHONY: build build-graphviz build-plantuml build-svg clean
