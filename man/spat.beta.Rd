% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/beta_spatial.R
\name{spat.beta}
\alias{spat.beta}
\title{Spatial beta diversity for raster}
\usage{
spat.beta(x, tree, filename = "", func = "jaccard", abund = FALSE, ...)
}
\arguments{
\item{x}{A SpatRaster with presence-absence data (0 or 1) for a
set of species. (This maps to \code{layers} in \code{BAT::raster.beta}).}

\item{tree}{It can be a 'data.frame' with species traits or a
'phylo' with a rooted phylogenetic tree. Species names in 'tree'
and 'x' must match!}

\item{filename}{Character. Save results if a name is provided.}

\item{func}{Character. Distance function for beta diversity calculation.
Defaults to "jaccard". Passed to \code{BAT::beta}.}

\item{abund}{Logical. Whether to use abundance data (TRUE) or presence-absence (FALSE).
Defaults to FALSE. Passed to \code{BAT::beta}.}

\item{...}{Additional arguments to be passed to internal functions
within \code{BAT::raster.beta} (e.g., \code{BAT::beta}).
Note: \code{BAT::raster.beta} does not accept a 'neighbour' argument.}
}
\value{
A SpatRaster with beta results (total, replacement,
richness difference, and ratio).
}
\description{
Calculates spatial beta diversity for
taxonomic (TD), functional (FD), and phylogenetic (PD)
dimensions. See \code{\link[BAT]{raster.beta}}.
}
\examples{
\donttest{
library(terra)
bin1 <- terra::rast(system.file("extdata", "fut.tif",
package = "divraster"))
traits <- read.csv(system.file("extdata", "traits.csv",
package = "divraster"), row.names = 1)
tree <- ape::read.tree(system.file("extdata", "tree.tre",
package = "divraster"))
spat.beta(bin1)
spat.beta(bin1, traits)
spat.beta(bin1, tree)
}
}
