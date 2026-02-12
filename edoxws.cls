% edoxws.cls — Worksheet class for the EDOX system
% Derived from scrartcl
%
% Purpose:
%   This class is intended for standalone worksheets, tests,
%   and exams. It provides a minimal document structure and
%   loads the shared EDOX base functionality.
%
%   The class itself should remain lightweight:
%   - no exercise logic
%   - no worksheet environments
%   - no grading logic
%   These belong to the edoxbase / edoxexercise / edoxworksheet packages.
%
%   Layout decisions specific to worksheets (titles, headers,
%   name fields, point displays) should also be implemented in
%   packages rather than directly in this class.
%
% copyright (c) 2025 Benjamin Benno Falkner
% SPDX-License-Identifier: MIT

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{edoxws}[2025/09/28 EDOX worksheet class]

% ------------------------------------------------------------
% Pass all options transparently to scrartcl
%
% This allows users to write, for example:
%   \documentclass[12pt,twoside]{edoxws}
% and have the options forwarded to scrartcl.
% ------------------------------------------------------------
\PassOptionsToClass{a4paper,11pt,oneside}{scrartcl}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrartcl}}
\ProcessOptions\relax

% ------------------------------------------------------------
% Load base class (KOMA-Script article)
% ------------------------------------------------------------
\LoadClass{scrartcl}

% ------------------------------------------------------------
% Load shared EDOX functionality
%
% edoxbase is expected to provide:
%   - common macros
%   - exercise infrastructure
%   - worksheet/test/exam environments
% ------------------------------------------------------------
\RequirePackage{edoxbase}

% ------------------------------------------------------------
% Header behaviour
%
% Use section marks for running headers.
% This affects only page headers, not document structure.
% ------------------------------------------------------------
\automark{section}