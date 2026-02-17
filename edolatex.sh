#!/usr/bin/env sh

# --------------------------------------------------
# edox — compile LaTeX document using local TEXMF tree
# --------------------------------------------------

echo "EdoLaTeX 2026"

# Use EDOLATEXMF if set, otherwise default to ./texmf
EDOLATEXMF="${EDOLATEXMF:-$(pwd)/texmf}"

# Export paths so kpathsea finds files only in the local tree
export TEXMFHOME="$EDOLATEXMF"
export TEXINPUTS="$EDOLATEXMF/tex//:"
export TEXFORMATS="$EDOLATEXMF/fmt//:"
export ENCFONTS="$EDOLATEXMF/fonts/enc//:"
export TFMFONTS="$EDOLATEXMF/fonts/tfm//:"
export TEXFONTMAPS="$EDOLATEXMF/fonts/map//:"
export T1FONTS="$EDOLATEXMF/fonts/type1//:"

# Document name: argument or default test.tex
DOC="${1:-test.tex}"

# Check if file exists
if [ ! -f "$DOC" ]; then
  echo "File not found: $DOC"
  exit 1
fi

# Compile
pdflatex "$DOC"