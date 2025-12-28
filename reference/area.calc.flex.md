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
  add_cols = NULL,
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

- add_cols:

  An optional character vector of additional column names from
  'zonal_polys'.

- omit_zero:

  A logical value. If TRUE (default), results for category = 0 are
  removed.

- unit:

  A string specifying the area unit ("km", "m", or "ha").

## Value

A data frame with the area for each category.

## Examples

``` r
if (FALSE) { # \dontrun{
library(terra)

# Create land cover raster
# 1 = Forest, 2 = Grassland, 3 = Agriculture
land_cover <- rast(ncol = 30, nrow = 30,
                   xmin = -50, xmax = -49,
                   ymin = -15, ymax = -14,
                   crs = "EPSG:4326")
values(land_cover) <- sample(1:3, ncell(land_cover), replace = TRUE)

# Basic: Calculate area for each category
area_result <- area.calc.flex(land_cover, unit = "km")

# With zones: Calculate area by region
region1 <- vect("POLYGON ((-50 -15, -49.5 -15, -49.5 -14, -50 -14, -50 -15))",
                crs = "EPSG:4326")
region2 <- vect("POLYGON ((-49.5 -15, -49 -15, -49 -14, -49.5 -14, -49.5 -15))",
                crs = "EPSG:4326")
regions <- rbind(region1, region2)
regions$region_id <- c("A", "B")

area_zonal <- area.calc.flex(land_cover,
                             zonal_polys = regions,
                             id_col = "region_id",
                             unit = "km")

# With overlay: Calculate area within protected areas
protected <- rast(land_cover)
values(protected) <- sample(0:1, ncell(protected), replace = TRUE)

area_overlay <- area.calc.flex(land_cover,
                               r2_raster = protected,
                               unit = "km")
} # }
```
