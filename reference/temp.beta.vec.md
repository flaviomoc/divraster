# Temporal beta diversity calculation for vector

Temporal beta diversity calculation for vector

## Usage

``` r
temp.beta.vec(x, nspp, spp, tree, resu, ...)
```

## Arguments

- x:

  A numeric vector with presence-absence data (0 or 1) for a set of
  species.

- nspp:

  Numeric. Number of species.

- spp:

  Character. Species name.

- tree:

  It can be a data frame with species traits or a phylogenetic tree.

- resu:

  Numeric. A vector to store results.

- ...:

  Additional arguments to be passed passed down from a calling function.

## Value

A vector with beta results (total, replacement, richness difference, and
ratio).
