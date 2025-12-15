# Calculate SpatRaster Layer Areas and Overlap Areas

Calculates the total area for each layer (e.g., species) within a
`SpatRaster` object. Optionally, it can also compute the overlapping
areas between the primary `SpatRaster` (`x`) and one or two additional
single-layer `SpatRaster` objects (`y` and `z`). Results are returned as
a `data.frame` and can optionally be saved to a CSV file.

## Usage

``` r
area.calc(x, y = NULL, z = NULL, filename = "", unit = "km", cellsize = NULL)
```

## Arguments

- x:

  A `SpatRaster` object for which the area of each layer will be
  calculated. This `SpatRaster` can have one or multiple layers.

- y:

  An optional `SpatRaster` object with a **single layer**. If provided,
  the overlapping area between each layer in `x` and this `y` raster
  will be calculated. It should have the same extent and resolution as
  `x`.

- z:

  An optional `SpatRaster` object with a **single layer**. If provided,
  the overlapping area between each layer in `x` and this `z` raster, as
  well as the three-way overlap (`x`, `y`, and `z`), will be calculated.
  Requires `y` to also be provided. It should have the same extent and
  resolution as `x`.

- filename:

  Character string. If provided (e.g., "results.csv"), the resulting
  data frame will be saved to a CSV file with this name. If not
  provided, results are returned only to the R session.

- unit:

  Character string specifying the unit of measurement for area
  calculations. Defaults to "km" (kilometers). Other options include
  "ha" (hectares), "m" (meters), etc.

- cellsize:

  Numeric. An optional value specifying the cell size (area of a single
  cell) to be used for calculations. If `NULL` (default), the function
  will automatically determine the cell size from the input raster `x`.

## Value

A `data.frame` with the following columns:

- **Layer**: Name of each layer from the input `SpatRaster x`.

- **Area**: The calculated area for each layer in `x` (e.g., total
  species range area).

- **Overlap_Area_Y** (optional): If `y` is provided, the area where the
  `x` layer and `y` raster both have a value of 1 (overlap).

- **Overlap_Area_Z** (optional): If `z` is provided, the area where the
  `x` layer and `z` raster both have a value of 1 (overlap).

- **Overlap_Area_All** (optional): If both `y` and `z` are provided, the
  area where the `x` layer, `y` raster, and `z` raster all have a value
  of 1 (triple overlap).

Areas are reported in the specified `unit`.

## Examples

``` r
# \donttest{
library(terra)
#> terra 1.8.86

# Load example rasters for demonstration
# Ensure these files are present in your package's inst/extdata folder
bin_rast <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))

# Example 1: Calculate area for 'bin_rast' only
area_only <- area.calc(bin_rast)
area_only
#>    Layer     Area
#> 1      A 6153.736
#> 2      B 6346.040
#> 3      C 4615.302
#> 4      D 5961.431
#> 5      E 6153.736
#> 6      F 5384.519
#> 7      G 5384.519
#> 8      H 5192.214
#> 9      I 6346.040
#> 10     J 6153.736
# }
```
