#!/usr/bin/env sh

# --------------------------------------------------
# edox — compile LaTeX document using local TEXMF
# --------------------------------------------------

echo "EdoLaTeX 2026"
TEXMF="$(pwd)/texmf" export TEXMF
TEXINPUTS=$(pwd)/texmf/tex/edo export TEXINPUTS
TEXFORMAT=$(pwd)/texmf/tex/edo export TEXFORMAT
ENCFONTS=$(pwd)/texmf/fonts/enc export ENCFONTS
TFMFONTS=$(pwd)/texmf/fonts/tfm export TFMFONTS
TEXFONTMAPS=$(pwd)/texmf/fonts/map export TEXFONTMAPS
T1FONTS=$(pwd)/texmf/fonts/type1 export T1FONTS




# Dokumentname: entweder Argument oder test.tex
DOC="${1:-test.tex}"

# Prüfen, ob Datei existiert
if [ ! -f "$DOC" ]; then
  echo "File not found: $DOC"
  exit 1
fi

# Lokalen TEXMF-Tree verwenden
TEXMFHOME="$TEXMF" pdflatex "$DOC"