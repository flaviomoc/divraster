
# divraster

<!-- badges: start -->
[![R-CMD-check](https://github.com/flaviomoc/DMSD/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/flaviomoc/DMSD/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

It calculates diversity patterns from rasterized data for taxonomic, functional, and phylogenetic dimensions. Beta diversity can be partitioned into replacement and richness differences components. It also calculates standardize effect size for functional and phylogenetic alpha diversity.

## Installation

You can install the development version of divraster from [GitHub](https://github.com/) with:

``` r
require(devtools)
devtools::load_all()
devtools::install_github("flaviomoc/divraster")
```

## SESraster dependency

The divraster function for calculating Standardized Effect Sizes (SES) uses the package SESraster as a dependency, which can be installed with:

``` r
devtools::install_github("HemingNM/SESraster")
```

## Example

This is a demonstration of how to solve a standard example:

``` r
library(divraster)
## basic example code
# load data
data <- load.data()
# taxonomic alpha
spat.alpha(data$ref)
# phylogenetic alpha
spat.alpha(data$ref, data$tree)
# standardize effect size for phylogenetic alpha
spat.rand(data$ref, data$tree, 3, "site") 
# spatial beta for taxonomic
spat.beta(data$ref)
# temporal beta for taxonomic
temp.beta(data$ref, data$fut)
# temporal beta for phylogenetic
temp.beta(data$ref, data$fut, data$tree)
```
