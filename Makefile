export NODE_OPTIONS := --unhandled-rejections=strict
UID := $(shell id -u)
GID := $(shell id -g)

INKSCAPE_VERSION := $(shell inkscape --version 2> /dev/null | perl -ne 'if (/Inkscape (\d+)/) { print $$1 . "\n" }')

GRAPHVIZ_FIGURES := $(shell find Figures/ -name '*.dot' -type f)
PLANTUML_FIGURES := $(shell find Figures/ -name '*.plantuml' -type f)
SVG_FIGURES := $(shell find Figures/ -name '*.svg' -type f)
DRAWIO_FIGURES := $(shell find Figures/ -name '*.drawio' -type f)
MERMAID_FIGURES := $(shell find Figures/ -name '*.mmd' -type f)
CODE_FIGURES := $(shell find Figures/ -name '*.lp' -type f) $(shell find Figures/ -name '*.txt' -type f)
CODE_SNIPPET_FIGURES := $(shell find Figures/ -name '*.snippet.sh' -type f)

GRAPHVIZ_FILTERS := dot neato twopi circo fdp sfdp patchwork osage

LATEX_SOURCES := $(shell find . -mindepth 2 -type f '(' -name '*.tex' -or -name '*.bib' ')' | sed 's|^\./||g')
LATEX_RESOURCES := $(wildcard */*.pdf) $(wildcard */*.eps) $(wildcard */*.jpg) $(wildcard */*.png) $(foreach GRAPHVIZ_FILTER,$(GRAPHVIZ_FILTERS),$(patsubst %.dot,%.$(GRAPHVIZ_FILTER).pdf,$(GRAPHVIZ_FIGURES))) $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES)) $(patsubst %.mmd,%.pdf,$(MERMAID_FIGURES)) $(patsubst %.svg,%.pdf,$(SVG_FIGURES)) $(CODE_FIGURES) $(patsubst %.snippet.sh,%.snippet.txt,$(CODE_SNIPPET_FIGURES)) $(patsubst %.drawio,%.pdf,$(DRAWIO_FIGURES))
REMOTE_RESOURCES :=

build: Thesis.pdf

build-figures: build-graphviz build-plantuml build-svg build-drawio build-mermaid build-code-snippet

build-graphviz: $(foreach GRAPHVIZ_FILTER,$(GRAPHVIZ_FILTERS),$(patsubst %.dot,%-$(GRAPHVIZ_FILTER).pdf,$(GRAPHVIZ_FIGURES)))

build-plantuml: $(patsubst %.plantuml,%.pdf,$(PLANTUML_FIGURES))

build-svg: $(patsubst %.svg,%.pdf,$(SVG_FIGURES))

build-drawio: $(patsubst %.drawio,%.pdf,$(DRAWIO_FIGURES))

build-mermaid: $(patsubst %.mmd,%.pdf,$(MERMAID_FIGURES))

build-code-snippet: $(patsubst %.snippet.sh,%.snippet.txt,$(CODE_SNIPPET_FIGURES))

.env:
	echo -n > $@
	echo "UID=$(UID)" >> $@
	echo "GID=$(GID)" >> $@
	echo -n "TZ=" >> $@
	timedatectl | grep 'Time zone' | sed -E 's/ *Time zone: (.*) \(.*\)/\1/' >> $@

%.pdf: %.tex $(LATEX_SOURCES) $(LATEX_RESOURCES) $(REMOTE_RESOURCES)
	latexmk -pdf $<

%.dot.pdf %.dot.svg %.dot.png: %.dot
	dot -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.neato.pdf %.neato.svg %.neato.png: %.dot
	neato -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.twopi.pdf %.twopi.svg %.twopi.png: %.dot
	twopi -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.circo.pdf %.circo.svg %.circo.png: %.dot
	circo -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.fdp.pdf %.fdp.svg %.fdp.png: %.dot
	fdp -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.sfdp.pdf %.sfdp.svg %.sfdp.png: %.dot
	sfdp -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.patchwork.pdf %.patchwork.svg %.patchwork.png: %.dot
	patchwork -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.osage.pdf %.osage.svg %.osage.png: %.dot
	osage -T$(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') -o $@ $^

%.svg: %.plantuml
	plantuml -tsvg $<

%.svg %.png %.pdf: %.mmd
	yarn run mmdc -i $< -o $@

%.pdf %.svg %.png: %.drawio
	docker run --rm -v "$(shell pwd)/$<:/pwd/$<" -v "$(shell pwd)/$(@D)/export:/pwd/$(@D)/export" -w /pwd rlespinasse/drawio-export:3.4.0 --fileext $(shell echo '$@' | perl -ne 'if (/.*\.([^.]+?)$$/) { print $$1 . "\n" }') --folder export
	docker run --rm -v "$(shell pwd):/pwd" alpine find /pwd -user root -exec chown $(UID):$(GID) '{}' \;
	./organize-drawio-exports.sh

%.pdf: %.svg
ifeq ($(INKSCAPE_VERSION), 1)
	inkscape --export-filename=$@ $<
endif
ifeq ($(INKSCAPE_VERSION), 0)
	inkscape --without-gui --export-pdf=$@ $<
endif

%.pdf: %.figure.R
	./$<

%.pdf: %.figure.py
	./$<

%.snippet.out.txt: %.snippet.sh
	-mkdir -p $(@D)
	cd $(@D) && (./$(notdir $<) > $(notdir $@)); test $$? -le 32

%.snippet.txt: %.snippet.sh %.snippet.out.txt
	-mkdir -p $(@D)
	echo -n '$$ ' > $@
	head -n 1 $< | perl -pe 's/^#!.*$$\\n//g' >> $@
	cat $^ | tail -n +2  >> $@

clean-latex:
	latexmk -C

clean-code-snippet:
	find Figures/ -name '*.snippet.txt' -exec rm '{}' \;
	find Figures/ -name '*.snippet.out.txt' -exec rm '{}' \;

clean-graphviz:
	$(foreach GRAPHVIZ_FILTER,$(GRAPHVIZ_FILTERS),$(foreach EXT,pdf svg png,$(shell find Figures/ -name '*.$(GRAPHVIZ_FILTER).$(EXT)' -exec rm '{}' \;)))

clean-pdf:
	find Figures/ -name '*.pdf' -exec rm '{}' \;

clean-image:
	find Figures/ -name '*.svg' -exec rm '{}' \;
	find Figures/ -name '*.png' -exec rm '{}' \;

clean-figures: clean-code-snippet clean-graphviz clean-pdf clean-image
clean: clean-latex clean-figures

.PHONY: build build-graphviz build-plantuml build-svg build-code-snippet clean clean-figures clean-latex clean-code-snippet clean-graphviz clean-pdf clean-image
.SECONDARY:
.PRECIOUS: %.snippet.txt
