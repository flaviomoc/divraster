# Spatial beta diversity for raster

Calculates spatial beta diversity for taxonomic (TD), functional (FD),
and phylogenetic (PD) dimensions. See
[`raster.beta`](https://rdrr.io/pkg/BAT/man/raster.beta.html).

## Usage

``` r
spat.beta(x, tree, filename = "", func = "jaccard", abund = FALSE, ...)
```

## Arguments

- x:

  A SpatRaster with presence-absence data (0 or 1) for a set of species.
  (This maps to `layers` in
  [`BAT::raster.beta`](https://rdrr.io/pkg/BAT/man/raster.beta.html)).

- tree:

  It can be a 'data.frame' with species traits or a 'phylo' with a
  rooted phylogenetic tree. Species names in 'tree' and 'x' must match!

- filename:

  Character. Save results if a name is provided.

- func:

  Character. Distance function for beta diversity calculation. Defaults
  to "jaccard". Passed to
  [`BAT::beta`](https://rdrr.io/pkg/BAT/man/beta.html).

- abund:

  Logical. Whether to use abundance data (TRUE) or presence-absence
  (FALSE). Defaults to FALSE. Passed to
  [`BAT::beta`](https://rdrr.io/pkg/BAT/man/beta.html).

- ...:

  Additional arguments to be passed to internal functions within
  [`BAT::raster.beta`](https://rdrr.io/pkg/BAT/man/raster.beta.html)
  (e.g., [`BAT::beta`](https://rdrr.io/pkg/BAT/man/beta.html)). Note:
  [`BAT::raster.beta`](https://rdrr.io/pkg/BAT/man/raster.beta.html)
  does not accept a 'neighbour' argument.

## Value

A SpatRaster with beta results (total, replacement, richness difference,
and ratio).

## Examples

``` r
# \donttest{
library(terra)
bin1 <- terra::rast(system.file("extdata", "fut.tif",
package = "divraster"))
traits <- read.csv(system.file("extdata", "traits.csv",
package = "divraster"), row.names = 1)
tree <- ape::read.tree(system.file("extdata", "tree.tre",
package = "divraster"))
spat.beta(bin1)
#> class       : SpatRaster 
#> size        : 8, 8, 6  (nrow, ncol, nlyr)
#> resolution  : 1, 1  (x, y)
#> extent      : 0, 8, 0, 8  (xmin, xmax, ymin, ymax)
#> coord. ref. :  
#> source(s)   : memory
#> names       :    Btotal,     Brepl,    Brich,      Bgain,      Bloss,    Bratio 
#> min values  : 0.4821429, 0.1111111, 0.075000, 0.05555556, 0.05729167, 0.1582734 
#> max values  : 0.9178571, 0.7285714, 0.609375, 0.67559524, 0.51736111, 0.8978930 
spat.beta(bin1, traits)
#> class       : SpatRaster 
#> size        : 8, 8, 6  (nrow, ncol, nlyr)
#> resolution  : 1, 1  (x, y)
#> extent      : 0, 8, 0, 8  (xmin, xmax, ymin, ymax)
#> coord. ref. :  
#> source(s)   : memory
#> names       :    Btotal,      Brepl,    Brich,      Bgain,      Bloss,     Bratio 
#> min values  : 0.3237529, 0.03470649, 0.123868, 0.03757175, 0.01735324, 0.04212794 
#> max values  : 0.8238354, 0.43752776, 0.789129, 0.80648220, 0.48381412, 0.74179377 
spat.beta(bin1, tree)
#> class       : SpatRaster 
#> size        : 8, 8, 6  (nrow, ncol, nlyr)
#> resolution  : 1, 1  (x, y)
#> extent      : 0, 8, 0, 8  (xmin, xmax, ymin, ymax)
#> coord. ref. :  
#> source(s)   : memory
#> names       :    Btotal,      Brepl,     Brich,      Bgain,      Bloss,    Bratio 
#> min values  : 0.2652022, 0.05756414, 0.1011549, 0.02878207, 0.04156621, 0.1642921 
#> max values  : 0.5976476, 0.45291494, 0.3969972, 0.45768560, 0.34008882, 0.7897035 
# }
```
