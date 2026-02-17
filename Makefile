########################################
# User configuration
########################################

DOC      = test
TEXMF    = texmf
SRC      = .

FONT_FAMILIES = \
  adobe/sourcesanspro \
  public/cm \
  public/amsfonts

BINDIR=bin
TMPDIR=.tmp-bin
TEXLIVE_MIRROR=https://mirror.ctan.org/systems/texlive/tlnet/archive

UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

########################################
# Derived paths
########################################

PKGDIR   = $(TEXMF)/tex/latex/edox
EXTDIR   = $(TEXMF)/tex/latex/external
FONTDST  = $(TEXMF)/fonts

CLS_SRC := $(wildcard $(SRC)/*.cls)
STY_SRC := $(wildcard $(SRC)/*.sty)

CLS_DST := $(patsubst $(SRC)/%.cls,$(PKGDIR)/%.cls,$(CLS_SRC))
STY_DST := $(patsubst $(SRC)/%.sty,$(PKGDIR)/%.sty,$(STY_SRC))

FILES := $(CLS_DST) $(STY_DST)

########################################
# Targets
########################################

.PHONY: all lsr fonts deps clean distclean test bin computermodern

all: lsr fonts  computermodern deps

########################################
# Install local packages
########################################

lsr: $(FILES)
	mktexlsr $(TEXMF)

$(PKGDIR):
	mkdir -p $(PKGDIR)

$(PKGDIR)/%.cls: $(SRC)/%.cls | $(PKGDIR)
	cp $< $@

$(PKGDIR)/%.sty: $(SRC)/%.sty | $(PKGDIR)
	cp $< $@

########################################
# Fonts
########################################

fonts:
	@echo "Copying selected fonts..."
	@ROOT=$$(kpsewhich --var-value=TEXMFDIST)/fonts; \
	for fam in $(FONT_FAMILIES); do \
		for sub in type1 tfm vf enc map; do \
			if [ -d "$$ROOT/$$sub/$$fam" ]; then \
				mkdir -p $(FONTDST)/$$sub/$$(dirname $$fam); \
				cp -r $$ROOT/$$sub/$$fam $(FONTDST)/$$sub/$$(dirname $$fam)/; \
			fi; \
		done; \
	done
	mktexlsr $(TEXMF)
	updmap-user || true

########################################
# Dependency copy
########################################

deps:
	pdftex -fmt=pdflatex  -recorder $(DOC).tex >/dev/null
	@echo "Copying dependencies into local TEXMF..."
	@grep '^INPUT ' $(DOC).fls | cut -d' ' -f2 | \
	grep -E '\.(sty|cls|fd|tfm|pfb|enc|map|def|cfg|ldf|bbx|cbx|lbx|tex|clo|ini)$$' | \
	while read f; do \
		case "$$f" in \
			*/texmf-dist/*) \
				rel=$$(echo $$f | sed 's|.*texmf-dist/||'); \
				mkdir -p $(TEXMF)/$$(dirname $$rel); \
				cp -n "$$f" "$(TEXMF)/$$rel" 2>/dev/null || true; \
			;; \
		esac \
	done
	mktexlsr $(TEXMF)


########################################
# Get binaries
########################################

# Architektur-Mapping
ifeq ($(UNAME_S),Linux)
  ifeq ($(UNAME_M),x86_64)
    TLARCH=x86_64-linux
  endif
endif

ifeq ($(UNAME_S),Darwin)
  TLARCH=universal-darwin
endif

PKGS=texlive.infra.$(TLARCH).tar.xz \
  pdftex.$(TLARCH).tar.xz \
  makeindex.$(TLARCH).tar.xz \
  bibtex.$(TLARCH).tar.xz \
  metafont.$(TLARCH).tar.xz

bin:
	@echo "Architecture: $(TLARCH)"
	rm -rf $(TMPDIR)
	mkdir -p $(TMPDIR)

	@for pkg in $(PKGS); do \
		echo "Downloading $$pkg"; \
		curl -L $(TEXLIVE_MIRROR)/$$pkg -o $(TMPDIR)/$$pkg; \
		tar -xf $(TMPDIR)/$$pkg -C $(TMPDIR); \
	done

	@echo "Extracting binaries..."
	mkdir -p $(BINDIR)
	find $(TMPDIR) -type f -path "*/bin/*" -exec cp {} $(BINDIR)/ \;

	# rm -rf $(TMPDIR)
	@echo "Done. Binaries in ./$(BINDIR)/"


########################################
# Build and clean
########################################

test:
	TEXMFHOME=$(PWD)/$(TEXMF) pdftex -fmt=pdflatex  $(DOC).tex



latex.fmt: $(FILES)
	

clean:
	rm -rf *.aux *.log *.fls *.fdb_latexmk *.pdf *.bcf *.run.xml *.xml *.dvi texsys.cfg $(TMPDIR)

dist-clean:
	rm -rf $(TEXMF) $(BINDIR) $(TMPDIR)

test-fmt:
	TEXMFHOME=$(PWD)/$(TEXMF) pdftex -fmt=latex  $(DOC).tex

build-fmt-old: $(PWD)/$(TEXMF)/tex/latex/base/latex.ltx $(PWD)/$(TEXMF)/fmt/pdflatex.ini
	cp -r $(dirname $(kpsewhich expl3.ltx)) texmf/tex/latex/
	cp -r $(kpsewhich -var-value=TEXMFDIST)/tex/latex/l3backend texmf/tex/latex/
	./bin/pdftex -etex  -ini -jobname=latex -progname=pdflatex -fmt=pdflatex.ini -output-directory=$(TEXMF)/fmt $(PWD)/$(TEXMF)/fmt/latex.ltx

build-fmt: $(PWD)/$(TEXMF)/tex/latex/base/latex.ltx $(PWD)/$(TEXMF)/fmt/latex.ltx $(PWD)/$(TEXMF)/fmt/pdflatex.ini
	mkdir -p $(TEXMF)/fmt
	mkdir -p $(TEXMF)/tex/latex

	touch $(TEXMF)/tex/latex/base/texsys.cfg

	cp -r $(shell dirname $(shell kpsewhich expl3.ltx)) $(TEXMF)/tex/latex/
	cp -r $(shell kpsewhich -var-value=TEXMFDIST)/tex/latex/l3backend $(TEXMF)/tex/latex/
	cp -r $(shell kpsewhich -var-value=TEXMFDIST)/tex/latex/l3kernel $(TEXMF)/tex/latex/

	mktexlsr $(TEXMF)

	TEXINPUTS=$(PWD)/$(TEXMF)/tex/latex TEXMFHOME=$(PWD)/$(TEXMF) ./bin/pdftex -ini -etex \
	  -jobname=pdflatex \
	  -progname=pdflatex \
	  -output-directory=$(TEXMF)/fmt latex.ltx


$(PWD)/$(TEXMF)/tex/latex/base/latex.ltx:
	mkdir -p $(PWD)/$(TEXMF)/fmt
	cp $(shell kpsewhich latex.ltx) $@

$(PWD)/$(TEXMF)/fmt/pdflatex.ini:
	mkdir -p $(PWD)/$(TEXMF)/fmt
	cp $(shell kpsewhich pdflatex.ini) $@


computermodern:
	@echo "Copying Computer Modern fonts..."
	@TEXMFDIST=$$(kpsewhich --var-value=TEXMFDIST); \
	FONTDST=$(TEXMF)/fonts; \
	for sub in tfm type1 enc map; do \
		if [ -d "$$TEXMFDIST/fonts/$$sub/public/cm" ]; then \
			mkdir -p "$$FONTDST/$$sub/public"; \
			cp -r "$$TEXMFDIST/fonts/$$sub/public/cm" "$$FONTDST/$$sub/public/"; \
		fi; \
	done
	mktexlsr $(TEXMF)