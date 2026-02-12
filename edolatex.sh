#!/usr/bin/env sh

# --------------------------------------------------
# edox — compile LaTeX document using local TEXMF
# --------------------------------------------------

TEXMF="$(pwd)/texmf"

# Dokumentname: entweder Argument oder test.tex
DOC="${1:-test.tex}"

# Prüfen, ob Datei existiert
if [ ! -f "$DOC" ]; then
  echo "File not found: $DOC"
  exit 1
fi

# Lokalen TEXMF-Tree verwenden
TEXMFHOME="$TEXMF" pdflatex "$DOC"