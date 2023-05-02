
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

This is a basic example which shows you how to solve a common problem:

``` r
library(divraster)
## basic example code
# load data
data <- load.data()
# taxonomic alpha diversity
spat.alpha(data$ref)
# ses for phylogenetic alpha diversity
spat.rand(data$ref, data$tree, 3, "site") 
# taxonomic spatial beta diversity
spat.beta(data$ref)
# taxonomic temporal beta diversity
temp.beta(data$ref, data$fut)
```

