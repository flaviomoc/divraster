# Check if objects are valid

Check if objects are valid

## Usage

``` r
inputs_chk(bin1, bin2, tree)
```

## Arguments

- bin1:

  A SpatRaster with presence-absence data (0 or 1) for a set of species.

- bin2:

  A SpatRaster with presence-absence data (0 or 1) for a set of species.
  Species names in 'bin2' and 'bin1' must match!

- tree:

  It can be a 'data.frame' with species traits or a 'phylo' with a
  rooted phylogenetic tree. Species names in 'tree', 'bin1', and 'bin2'
  must match!

## Value

Either a success message or an error.
