
# divraster

<!-- badges: start -->
<!-- badges: end -->

It calculates diversity patterns from rasterized data for taxonomic, functional, and phylogenetic dimensions. Beta diversity can be partitioned into replacement and richness differences components. It also calculates standardize effect size for functional and phylogenetic alpha diversity.

## Installation

You can install the development version of divraster from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
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
```

