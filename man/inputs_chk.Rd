% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/inputs_chk.R
\name{inputs_chk}
\alias{inputs_chk}
\title{Check if objects are valid}
\usage{
inputs_chk(bin1, bin2, tree)
}
\arguments{
\item{bin1}{A SpatRaster with presence-absence data (0 or 1)
for a set of species.}

\item{bin2}{A SpatRaster with presence-absence data (0 or 1)
for a set of species. Species names in 'bin2' and 'bin1' must
match!}

\item{tree}{It can be a 'data.frame' with species traits or a
'phylo' with a rooted phylogenetic tree. Species names in 'tree',
'bin1', and 'bin2' must match!}
}
\value{
Either a success message or an error.
}
\description{
Check if objects are valid
}
