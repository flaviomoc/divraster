
# divraster

<!-- badges: start -->

[![R-CMD-check](https://github.com/flaviomoc/DMSD/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/flaviomoc/DMSD/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

divraster calculates diversity patterns from raster data for taxonomic, functional, and phylogenetic dimensions. Spatial and temporal beta diversity can be partitioned into replacement and richness differences components. divraster also calculates standardize effect size for functional and phylogenetic alpha diversity and the average traits.

## Installation

You can install the development version of divraster from [divraster repository](https://github.com/flaviomoc/divraster) in Github with:

``` r
require(devtools)
devtools::load_all()
devtools::install_github("flaviomoc/divraster")
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
# temporal beta for functional
temp.beta(data$ref, data$fut, data$traits)
# average traits for reference scenario
spat.trait(data$ref, data$traits)
```
