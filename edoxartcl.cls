% edoxartcl.cls — Article class for the EDOX system
% Derived from scrartcl
%
% Purpose:
%   This class provides an article-style document suitable for
%   worksheets, collections of exercises, or educational texts.
%
%   It loads the shared EDOX base package and defines how exercises
%   are numbered in article-style documents.
%
% copyright (c) 2025 Benjamin Benno Falkner
% SPDX-License-Identifier: MIT

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{edoxartcl}[2025/09/28 EDOX article class]

% ------------------------------------------------------------
% Pass all options transparently to scrartcl
%
% This allows users to write, for example:
%   \documentclass[12pt,twoside]{edoxartcl}
% and have the options applied to scrartcl.
% ------------------------------------------------------------
\PassOptionsToClass{a4paper,11pt,oneside}{scrartcl}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrartcl}}
\ProcessOptions\relax

% ------------------------------------------------------------
% Load the KOMA-Script article base class
% ------------------------------------------------------------
\LoadClass{scrartcl}

% ------------------------------------------------------------
% Load shared EDOX functionality
%
% edoxbase is expected to provide:
%   - shared macros
%   - exercise environments
%   - worksheet/exam infrastructure
% ------------------------------------------------------------
\RequirePackage{edoxbase}

% ------------------------------------------------------------
% Header behaviour
%
% Use section marks for running headers (KOMA feature).
% This affects only page headers, not document structure.
% ------------------------------------------------------------
\automark{section}

% ------------------------------------------------------------
% Exercise numbering policy for article documents
%
% Exercises are numbered within each subsection:
%
%   subsection.exercise
%
% Example:
%   2.3.1  (Exercise 1 in subsection 2.3)
%
% Subexercises reset for each exercise.
% ------------------------------------------------------------
\newcounter{exercise}[subsection]
\newcounter{subexercise}[exercise]

\renewcommand*\theexercise{\thesubsection.\arabic{exercise}}