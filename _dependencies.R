##############################################################################
# Title:        _dependencies.R – packages that the pages need without naming
# Purpose:      Declare to renv the packages that a page loads only through
#               another package, so that the lockfile records them. renv finds
#               a package by reading the code of the site, and a package that
#               no code names stays out of the lockfile and out of the library.
#               Quarto ignores this file.
# Author:       Chris Moreh
# Last updated: 2026-11-17
# Sourced by:   no script; renv reads it when it writes the lockfile
##############################################################################

# tinytable::format_tt(markdown = TRUE) converts the markdown of a cell with
# litedown (the table of the page on repositories).
requireNamespace("litedown", quietly = TRUE)

# brms fits the models of companion/_model-outputs/bayes_housing.R through
# cmdstanr (backend = "cmdstanr"). cmdstanr is not on CRAN: the lockfile
# records the release of the Stan repository, https://stan-dev.r-universe.dev.
requireNamespace("cmdstanr", quietly = TRUE)
