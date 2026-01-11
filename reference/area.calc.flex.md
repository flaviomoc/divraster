# Flexible Area Calculation for Raster

This function calculates the area of integer categories in a primary
raster (r1). It can optionally compute an overlay area with a second
layer (r2) and/or perform calculations within distinct zones defined by
a polygon SpatVector.

## Usage

``` r
area.calc.flex(
  r1,
  r2_raster = NULL,
  r2_vector = NULL,
  threshold = NULL,
  zonal_polys = NULL,
  id_col = NULL,
  omit_zero = TRUE,
  unit = "km"
)
```

## Arguments

- r1:

  The primary SpatRaster with integer categories.

- r2_raster:

  An optional SpatRaster for overlay analysis.

- r2_vector:

  An optional SpatVector for overlay analysis.

- threshold:

  A numeric value required to binarize 'r2_raster' if it's continuous.

- zonal_polys:

  An optional SpatVector for zonal analysis.

- id_col:

  A string specifying the column in 'zonal_polys'.

- omit_zero:

  A logical value. If TRUE (default), results for category = 0 are
  removed.

- unit:

  A string specifying the area unit ("km", "m", or "ha").

## Value

A data frame with the area for each category.

## Examples

``` r
# \donttest{
library(terra)

# 1) Primary raster (integer categories)
land_cover <- rast(ncol = 30, nrow = 30,
                   xmin = -50, xmax = -49,
                   ymin = -15, ymax = -14)
values(land_cover) <- sample(1:3, ncell(land_cover), replace = TRUE)
crs(land_cover) <- "+proj=longlat +datum=WGS84 +no_defs"

# Basic: total area by category
area.calc.flex(land_cover, unit = "km")
#>   layer    area_id category  area_km
#> 1 lyr.1 Total Area        1 4015.385
#> 2 lyr.1 Total Area        2 4161.027
#> 3 lyr.1 Total Area        3 3750.448

# 2) Zonal polygons (two regions)
region1 <- vect("POLYGON ((-50 -15, -49.5 -15, -49.5 -14, -50 -14, -50 -15))")
region2 <- vect("POLYGON ((-49.5 -15, -49 -15, -49 -14, -49.5 -14, -49.5 -15))")
regions <- rbind(region1, region2)
crs(regions) <- crs(land_cover)
regions$region_id <- c("A", "B")

area.calc.flex(
  land_cover,
  zonal_polys = regions,
  id_col = "region_id",
  unit = "km"
)
#>   layer region_id    area_id category  area_km
#> 1 lyr.1         A Total Area        1 2014.267
#> 2 lyr.1         A Total Area        2 2146.679
#> 3 lyr.1         A Total Area        3 1802.484
#> 4 lyr.1         B Total Area        1 2001.118
#> 5 lyr.1         B Total Area        2 2014.348
#> 6 lyr.1         B Total Area        3 1947.963

# 3) Overlay raster (binary mask)
protected <- rast(land_cover)
values(protected) <- sample(0:1, ncell(protected), replace = TRUE)

area.calc.flex(
  land_cover,
  r2_raster = protected,
  unit = "km"
)
#>   layer      area_id category  area_km
#> 1 lyr.1   Total Area        1 4015.385
#> 2 lyr.1   Total Area        2 4161.027
#> 3 lyr.1   Total Area        3 3750.448
#> 4 lyr.1 Overlay Area        1 1881.803
#> 5 lyr.1 Overlay Area        2 2027.681
#> 6 lyr.1 Overlay Area        3 2041.098
# }
```
