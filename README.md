
# divraster

<!-- badges: start -->
[![CRAN-status](https://www.r-pkg.org/badges/version/divraster)](https://cran.r-project.org/package=divraster)
[![R-CMD-check](https://github.com/flaviomoc/divraster/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/flaviomoc/divraster/actions/workflows/R-CMD-check.yaml)
[![](http://cranlogs.r-pkg.org/badges/grand-total/divraster?color=green)](https://cran.r-project.org/package=divraster)
[![](http://cranlogs.r-pkg.org/badges/divraster?color=green)](https://cran.r-project.org/package=divraster)
<!-- badges: end -->

Alpha and beta calculations using rasters for taxonomic (TD), functional (FD), and phylogenetic (PD) dimensions. Spatial and temporal beta diversity can be partitioned into replacement and richness difference components. Functions to calculate standardized effect size for functional and phylogenetic alpha diversity and the average traits are available.

## Installation

To install the package, run the following code:

``` r
install.packages("divraster")
```

The development version of `divraster` can be installed from Github:

``` r
# install.packages(devtools)
devtools::install_github("flaviomoc/divraster", build_vignettes = TRUE)
```

## Load data

You can use a `divraster` function to load the data:

``` r
library(divraster)
data <- load.data()
```

## Calculating alpha diversity

To calculate alpha diversity for TD, FD, and PD we need the following objects: a multilayer SpatRaster, data.frame, and phylo.

``` r
# TD
terra::plot(spat.alpha(data$ref))

# FD
terra::plot(spat.alpha(data$ref, data$traits))

# PD
terra::plot(spat.alpha(data$ref, data$tree))
```

## Calculating temporal beta diversity

To calculate temporal beta diversity and its components (i.e. replacement and richness differences) for TD, FD, and PD we need the following objects: two multilayer SpatRaster (e.g. reference and future climate scenarios), data.frame, and phylo.

``` r
# TD
terra::plot(temp.beta(data$ref, data$fut))

# FD
terra::plot(temp.beta(data$ref, data$fut, data$traits))

# PD
terra::plot(temp.beta(data$ref, data$fut, data$tree))
```

## Other examples

A vignette with other examples can be found loading:

``` r
browseVignettes("divraster")
```
