GRAPHVIZ_FIGURES := $(shell find Figures/ -name '*.dot' -type f)
PLANTUML_FIGURES := $(shell find Figures/ -name '*.plantuml' -type f)
SVG_FIGURES := $(shell find Figures/ -name '*.svg' -type f)
DRAWIO_FIGURES := $(shell find Figures/ -name '*.drawio' -type f)
CODE_FIGURES := $(shell find Figures/ -name '*.lp' -type f) $(shell find Figures/ -name '*.txt' -type f)

LATEX_SOURCES := $(wildcard *.tex) $(wildcard */*.tex) $(wildcard *.bib)
LATEX_RESOURCES := $(wildcard */*.pdf) $(wildcard */*.eps) $(wildcard */*.jpg) $(wildcard */*.png) $(patsubst %.dot,%.pdf,$(GRAPHVIZ_FIGURES)) $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES)) $(patsubst %.svg,%.pdf,$(SVG_FIGURES)) $(CODE_FIGURES)
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
