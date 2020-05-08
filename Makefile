GRAPHVIZ_FIGURES := $(wildcard Figures/**/*.dot)
PLANTUML_FIGURES := $(wildcard Figures/**/*.plantuml)

LATEX_SOURCES := $(wildcard *.tex) $(wildcard **/*.tex) $(wildcard *.bib)
LATEX_RESOURCES := $(wildcard **/*.pdf) $(wildcard **/*.eps) $(wildcard **/*.jpg) $(wildcard **/*.png) $(patsubst %.dot,%.pdf,$(GRAPHVIZ_FIGURES)) $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES))
REMOTE_RESOURCES :=

build: Thesis.pdf

build-graphviz: $(patsubst %.dot,%.pdf,$(GRAPHVIZ_FIGURES))

build-plantuml: $(patsubst %.dot,%.pdf,$(PLANTUML_FIGURES))

%.pdf: %.tex $(LATEX_SOURCES) $(LATEX_RESOURCES) $(REMOTE_RESOURCES)
	pdflatex --shell-escape $<

%.pdf: %.dot
	dot -Tpdf -o $@ $^

%.svg: %.plantuml
	plantuml -tsvg $<

%.pdf: %.svg
	inkscape -z -D --file=$< --export-pdf=$@
