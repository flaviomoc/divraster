
# divraster

<!-- badges: start -->
[![CRAN-status](https://www.r-pkg.org/badges/version/divraster)](https://cran.r-project.org/package=divraster)
[![R-CMD-check](https://github.com/flaviomoc/divraster/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/flaviomoc/divraster/actions/workflows/R-CMD-check.yaml)
[![](http://cranlogs.r-pkg.org/badges/grand-total/divraster?color=green)](https://cran.r-project.org/package=divraster)
[![](http://cranlogs.r-pkg.org/badges/divraster?color=green)](https://cran.r-project.org/package=divraster)
<!-- badges: end -->

divraster calculates diversity patterns from raster data for taxonomic, functional, and phylogenetic dimensions. Spatial and temporal beta diversity can be partitioned into replacement and richness differences components. divraster also calculates standardize effect size for functional and phylogenetic alpha diversity and the average traits

## Installation

You can install the development version of divraster from [divraster repository](https://github.com/flaviomoc/divraster) in Github with:

``` r
# install.packages("devtools")
devtools::install_github("flaviomoc/divraster", build_vignettes = TRUE)
```

## Load data

You can use a `divraster` function to load the data with:

``` r
library(divraster)
data <- load.data()
```

## Calculating alpha diversity

To calculate alpha diversity for taxonomic, functional, and phylogenetic dimensions we need the following objects: multilayer SpatRaster, data.frame, and phylo.

``` r
# TD
terra::plot(spat.alpha(data$ref))

# FD
terra::plot(spat.alpha(data$ref, data$traits))

# PD
terra::plot(spat.alpha(data$ref, data$tree))
```

## Calculating temporal beta diversity

To calculate temporal beta diversity and its components (i.e. replacement and richness differences) for taxonomic, functional, and phylogenetic dimensions we need the following objects: 2 multilayer SpatRaster, data.frame, and phylo.

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
