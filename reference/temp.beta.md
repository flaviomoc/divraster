# Temporal beta diversity calculation for raster

Calculates temporal beta diversity for taxonomic (TD), functional (FD),
and phylogenetic (PD) dimensions. Adapted from
[`beta`](https://rdrr.io/pkg/BAT/man/beta.html)

## Usage

``` r
temp.beta(bin1, bin2, tree, filename = "", cores = 1, ...)
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

- filename:

  Character. Save results if a name is provided.

- cores:

  A positive integer. If cores \> 1, a 'parallel' package cluster with
  that many cores is created and used.

- ...:

  Additional arguments to be passed passed down from a calling function.

## Value

A SpatRaster with beta results (total, replacement, richness difference,
and ratio).

## Details

The TD beta diversity partitioning framework we used was developed by
Podani and Schmera (2011) and Carvalho et al. (2012) and expanded to PD
and FD by Cardoso et al. (2014).

## References

Cardoso, P. et al. 2014. Partitioning taxon, phylogenetic and functional
beta diversity into replacement and richness difference components. -
Journal of Biogeography 41: 749–761.

Carvalho, J. C. et al. 2012. Determining the relative roles of species
replacement and species richness differences in generating
beta-diversity patterns. - Global Ecology and Biogeography 21: 760–771.

Podani, J. and Schmera, D. 2011. A new conceptual and methodological
framework for exploring and explaining pattern in presence - absence
data. - Oikos 120: 1625–1638.

Hidasi-Neto, J. et al. 2019. Climate change will drive mammal species
loss and biotic homogenization in the Cerrado Biodiversity Hotspot. -
Perspectives in Ecology and Conservation 17: 57–63.

## Examples

``` r
# \donttest{
library(terra)
bin1 <- terra::rast(system.file("extdata", "ref.tif",
package = "divraster"))
bin2 <- terra::rast(system.file("extdata", "fut.tif",
package = "divraster"))
traits <- read.csv(system.file("extdata", "traits.csv",
package = "divraster"), row.names = 1)
tree <- ape::read.tree(system.file("extdata", "tree.tre",
package = "divraster"))
temp.beta(bin1, bin2)
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> class       : SpatRaster 
#> size        : 8, 8, 4  (nrow, ncol, nlyr)
#> resolution  : 0.125, 0.125  (x, y)
#> extent      : 0, 1, 0, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source(s)   : memory
#> names       : Btotal_TD,  Brepl_TD,  Brich_TD, Bratio_TD 
#> min values  :       0.2, 0.0000000, 0.0000000,         0 
#> max values  :       1.0, 0.8888889, 0.7142857,         1 
temp.beta(bin1, bin2, traits)
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> class       : SpatRaster 
#> size        : 8, 8, 4  (nrow, ncol, nlyr)
#> resolution  : 0.125, 0.125  (x, y)
#> extent      : 0, 1, 0, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source(s)   : memory
#> names       : Btotal_FD,  Brepl_FD,    Brich_FD, Bratio_FD 
#> min values  : 0.1522544, 0.0000000, 0.003222951, 0.0000000 
#> max values  : 0.8309776, 0.5852812, 0.830977572, 0.9905423 
temp.beta(bin1, bin2, tree)
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> Warning: number of items to replace is not a multiple of replacement length
#> class       : SpatRaster 
#> size        : 8, 8, 4  (nrow, ncol, nlyr)
#> resolution  : 0.125, 0.125  (x, y)
#> extent      : 0, 1, 0, 1  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source(s)   : memory
#> names       : Btotal_PD,  Brepl_PD,    Brich_PD, Bratio_PD 
#> min values  : 0.1525273, 0.0000000, 0.004401637, 0.0000000 
#> max values  : 0.8223597, 0.7143422, 0.496646645, 0.9937685 
# }
```
