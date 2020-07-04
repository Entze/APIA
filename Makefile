GRAPHVIZ_FIGURES := $(shell find Figures/ -name '*.dot' -type f)
PLANTUML_FIGURES := $(shell find Figures/ -name '*.plantuml' -type f)
SVG_FIGURES := $(shell find Figures/ -name '*.svg' -type f)
DRAWIO_FIGURES := $(shell find Figures/ -name '*.drawio' -type f)
CODE_FIGURES := $(shell find Figures/ -name '*.lp' -type f) $(shell find Figures/ -name '*.txt' -type f)
CLINGO_FIGURES := $(shell find Figures/ -name '*.clingo.sh' -type f)

LATEX_SOURCES := $(wildcard *.tex) $(wildcard */*.tex) $(wildcard *.bib)
LATEX_RESOURCES := $(wildcard */*.pdf) $(wildcard */*.eps) $(wildcard */*.jpg) $(wildcard */*.png) $(patsubst %.dot,%.pdf,$(GRAPHVIZ_FIGURES)) $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES)) $(patsubst %.svg,%.pdf,$(SVG_FIGURES)) $(CODE_FIGURES) $(patsubst %.clingo.sh,%.clingo.txt,$(CLINGO_FIGURES))
REMOTE_RESOURCES :=

build: Thesis.pdf

build-graphviz: $(patsubst %.dot,%.pdf,$(GRAPHVIZ_FIGURES))

build-plantuml: $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES))

build-svg: $(patsubst %.svg,%.pdf,$(SVG_FIGURES))

%.pdf: %.tex $(LATEX_SOURCES) $(LATEX_RESOURCES) $(REMOTE_RESOURCES)
	latexmk -pdf

%.pdf %.svg %.png: %.dot
	dot -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.svg: %.plantuml
	plantuml -tsvg $<

%.pdf: %.svg
	inkscape --export-filename=$@ $<

%.clingo.out.txt: %.clingo.sh
	-mkdir -p $(@D)
	-cd $(@D) && (cat $(notdir $<) | bash > $(notdir $@))

%.clingo.txt: %.clingo.sh %.clingo.out.txt
	-mkdir -p $(@D)
	echo -n '$$ ' > $@
	cat $^ >> $@

clean:
	latexmk -C
	-rm -- $(shell find -name '*.clingo.txt') $(shell find -name '*.clingo.out.txt')

.PHONY: build build-graphviz build-plantuml build-svg clean
.SECONDARY:
.PRECIOUS: %.clingo.txt
