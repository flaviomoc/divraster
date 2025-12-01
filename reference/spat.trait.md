# Average trait calculation for raster

Compute average for each trait.

## Usage

``` r
spat.trait(x, trait, cores = 1, filename = "", ...)
```

## Arguments

- x:

  A SpatRaster with presence-absence data (0 or 1) for a set of species.

- trait:

  A 'data.frame' with species traits. Rownames must have species names
  that match with 'x'!

- cores:

  A positive integer. If cores \> 1, a 'parallel' package cluster with
  that many cores is created and used.

- filename:

  Character. Save results if a name is provided.

- ...:

  Additional arguments to be passed passed down from a calling function.

## Value

SpatRaster with average traits.

## Examples

``` r
# \donttest{
library(terra)
bin1 <- terra::rast(system.file("extdata", "ref.tif",
package = "divraster"))
traits <- read.csv(system.file("extdata", "traits.csv",
package = "divraster"), row.names = 1)
spat.trait(bin1, traits)
#> class       : SpatRaster 
#> size        : 8, 8, 2  (nrow, ncol, nlyr)
#> resolution  : 0.125, 0.125  (x, y)
#> extent      : 0, 1, 0, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source(s)   : memory
#> names       : beak.size, wing.length 
#> min values  :  1.312311,    30.54550 
#> max values  :  3.310816,    45.84854 
# }
```
