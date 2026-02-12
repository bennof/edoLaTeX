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

.PHONY: all lsr fonts deps clean distclean test

all: lsr fonts deps

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
	pdflatex -recorder $(DOC).tex >/dev/null
	@echo "Copying dependencies into local TEXMF..."
	@grep '^INPUT ' $(DOC).fls | cut -d' ' -f2 | \
	grep -E '\.(sty|cls|fd|tfm|pfb|enc|map|def|cfg|ldf|bbx|cbx|lbx)$$' | \
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
# Build and clean
########################################

test:
	TEXMFHOME=$(PWD)/$(TEXMF) pdflatex $(DOC).tex

clean:
	rm -f *.aux *.log *.fls *.fdb_latexmk *.pdf *.bcf *.run.xml

distclean:
	rm -rf $(TEXMF)