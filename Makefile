export NODE_OPTIONS := --unhandled-rejections=strict
UID := $(shell id -u)
GID := $(shell id -g)

GRAPHVIZ_FIGURES := $(shell find Figures/ -name '*.dot' -type f)
PLANTUML_FIGURES := $(shell find Figures/ -name '*.plantuml' -type f)
SVG_FIGURES := $(shell find Figures/ -name '*.svg' -type f)
DRAWIO_FIGURES := $(shell find Figures/ -name '*.drawio' -type f)
MERMAID_FIGURES := $(shell find Figures/ -name '*.mmd' -type f)
CODE_FIGURES := $(shell find Figures/ -name '*.lp' -type f) $(shell find Figures/ -name '*.txt' -type f)
CLINGO_FIGURES := $(shell find Figures/ -name '*.clingo.sh' -type f)

GRAPHVIZ_FILTERS := dot neato twopi circo fdp sfdp patchwork osage

LATEX_SOURCES := $(wildcard *.tex) $(wildcard */*.tex) $(wildcard *.bib)
LATEX_RESOURCES := $(wildcard */*.pdf) $(wildcard */*.eps) $(wildcard */*.jpg) $(wildcard */*.png) $(foreach GRAPHVIZ_FILTER,$(GRAPHVIZ_FILTERS),$(patsubst %.dot,%-$(GRAPHVIZ_FILTER).pdf,$(GRAPHVIZ_FIGURES))) $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES)) $(patsubst %.mmd,%.pdf,$(MERMAID_FIGURES)) $(patsubst %.svg,%.pdf,$(SVG_FIGURES)) $(CODE_FIGURES) $(patsubst %.clingo.sh,%.clingo.txt,$(CLINGO_FIGURES)) $(patsubst %.drawio,%.pdf,$(DRAWIO_FIGURES))
REMOTE_RESOURCES :=

build: Thesis.pdf

build-graphviz: $(patsubst %.dot,%.pdf,$(GRAPHVIZ_FIGURES))

build-plantuml: $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES))

build-svg: $(patsubst %.svg,%.pdf,$(SVG_FIGURES))

build-drawio: $(patsubst %.drawio,%.pdf,$(DRAWIO_FIGURES))

build-clingo: $(patsubst %.clingo.sh,%.clingo.txt,$(CLINGO_FIGURES))

%.pdf: %.tex $(LATEX_SOURCES) $(LATEX_RESOURCES) $(REMOTE_RESOURCES)
	latexmk -pdf

%-dot.pdf %-dot.svg %-dot.png: %.dot
	dot -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%-neato.pdf %-neato.svg %-neato.png: %.dot
	neato -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%-twopi.pdf %-twopi.svg %-twopi.png: %.dot
	twopi -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%-circo.pdf %-circo.svg %-circo.png: %.dot
	circo -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%-fdp.pdf %-fdp.svg %-fdp.png: %.dot
	fdp -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%-sfdp.pdf %-sfdp.svg %-sfdp.png: %.dot
	sfdp -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%-patchwork.pdf %-patchwork.svg %-patchwork.png: %.dot
	patchwork -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%-osage.pdf %-osage.svg %-osage.png: %.dot
	osage -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.svg: %.plantuml
	plantuml -tsvg $<

%.svg %.png %.pdf: %.mmd
	yarn run mmdc -i $< -o $@

%.pdf %.svg %.png: %.drawio
	docker run -it -v "$(shell pwd)/$(@D):/pwd" -w /pwd rlespinasse/drawio-export --fileext $(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') --folder export
	docker run -it -v "$(shell pwd)/$(@D):/pwd" -w /pwd alpine ./organize-drawio-exports.sh
	docker run -it -v "$(shell pwd):/pwd" -w /pwd alpine find -user root -exec chown $(UID):$(GID) '{}' \;

%.pdf: %.svg
	inkscape --export-filename=$@ $<

%.clingo.out.txt: %.clingo.sh
	-mkdir -p $(@D)
	cd $(@D) && (cat $(notdir $<) | bash > $(notdir $@)); test $$? -le 32

%.clingo.txt: %.clingo.sh %.clingo.out.txt
	-mkdir -p $(@D)
	echo -n '$$ ' > $@
	cat $^ >> $@

clean-latex:
	latexmk -C

clean-other:
	find Figures/ -name '*.clingo.txt' -exec rm '{}' \;
	find Figures/ -name '*.clingo.out.txt' -exec rm '{}' \;
	$(foreach GRAPHVIZ_FILTER,$(GRAPHVIZ_FILTERS),$(foreach EXT,pdf svg png,$(shell find Figures/ -name '*-$(GRAPHVIZ_FILTER).$(EXT)' -exec rm '{}' \;)))
	find Figures/ -name '*.pdf' -exec rm '{}' \;
	find Figures/ -name '*.svg' -exec rm '{}' \;
	find Figures/ -name '*.png' -exec rm '{}' \;

clean: clean-latex clean-other

.PHONY: build build-graphviz build-plantuml build-svg build-clingo clean clean-latex clean-other
.SECONDARY:
.PRECIOUS: %.clingo.txt
