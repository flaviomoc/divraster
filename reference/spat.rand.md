# Standardized Effect Size (SES) for raster

Calculates the standardized effect size for functional and phylogenetic
alpha diversity. See
[`bootspat_str`](https://hemingnm.github.io/SESraster/reference/bootspat_str.html)
and
[`bootspat_naive`](https://hemingnm.github.io/SESraster/reference/bootspat_naive.html)

## Usage

``` r
spat.rand(
  x,
  tree,
  aleats,
  random = c("site", "species", "both", "spat"),
  cores = 1,
  filename = "",
  ...
)
```

## Arguments

- x:

  SpatRaster. A SpatRaster containing presence-absence data (0 or 1) for
  a set of species.

- tree:

  It can be a 'data.frame' with species traits or a 'phylo' with a
  rooted phylogenetic tree. Species names in 'tree' and 'x' must match!

- aleats:

  positive integer. A positive integer indicating how many times the
  calculation should be repeated.

- random:

  character. A character indicating the type of randomization. The
  currently available randomization methods are "spat", "site",
  "species" or "both" (site and species).

- cores:

  positive integer. If cores \> 1, a 'parallel' package cluster with
  that many cores is created and used.

- filename:

  character. Output filename.

- ...:

  additional arguments to be passed passed down from a calling function.

## Value

SpatRaster with Mean, SD, Observed, and SES.

## Examples

``` r
# \donttest{
x <- terra::rast(system.file("extdata", "ref.tif",
package = "divraster"))
traits <- read.csv(system.file("extdata", "traits.csv",
package = "divraster"), row.names = 1)
tree <- ape::read.tree(system.file("extdata", "tree.tre",
package = "divraster"))
spat.rand(x, tree, 3, "site")
#> class       : SpatRaster 
#> size        : 8, 8, 4  (nrow, ncol, nlyr)
#> resolution  : 0.125, 0.125  (x, y)
#> extent      : 0, 1, 0, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source(s)   : memory
#> names       :  Mean_PD,      SD_PD, Observed_PD,     SES_PD 
#> min values  : 3.815058, 0.08169004,    3.359948, -16.856756 
#> max values  : 9.867378, 0.98140262,   10.571964,   5.955834 
spat.rand(x, traits, 3, "site")
#> class       : SpatRaster 
#> size        : 8, 8, 4  (nrow, ncol, nlyr)
#> resolution  : 0.125, 0.125  (x, y)
#> extent      : 0, 1, 0, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source(s)   : memory
#> names       :   Mean_FD,      SD_FD, Observed_FD,    SES_FD 
#> min values  : 0.2992551, 0.02017932,   0.3492543, -11.42736 
#> max values  : 1.3001187, 0.22713700,   1.2493508,  11.18722 
# }
```
