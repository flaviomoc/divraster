# Summarise raster values by polygons

Extracts values from a `SpatRaster` for each polygon in a `SpatVector`
and returns a data frame that combines polygon identifiers with
user-defined summary statistics of the raster values.

## Usage

``` r
rast.by.polys(
  x,
  polygons,
  id_col = NULL,
  fun = function(v, ...) mean(v, na.rm = TRUE),
  na.rm = TRUE
)
```

## Arguments

- x:

  A `SpatRaster` object containing one or more layers.

- polygons:

  A `SpatVector` with polygon geometries used to summarise raster
  values.

- id_col:

  Optional character string giving the name of a column in `polygons` to
  be used as an identifier (for example, `"PA_ID"`). If `NULL`
  (default), all non-geometry attributes from `polygons` are joined to
  the summary table.

- fun:

  A function applied to the vector of raster values extracted for each
  polygon. The function must return a named vector. It should accept
  `...` so that arguments such as `na.rm = TRUE` can be passed through.
  The default is `function(v, ...) mean(v, na.rm = TRUE)`.

- na.rm:

  Logical; if `TRUE`, missing values are removed before applying `fun`.
  Passed to `fun` via `...`.

## Value

A `data.frame` with one row per polygon. If `id_col` is not `NULL`, the
first column is the specified identifier; otherwise, all attribute
columns from `polygons` are included. Additional columns contain the
summary statistics returned by `fun` for each raster layer.

## Details

This function is a convenience wrapper around
[`terra::extract()`](https://rspatial.github.io/terra/reference/extract.html),
combining extraction, summarisation and binding of polygon attributes
into a single step. It supports multilayer rasters; in that case the
summary statistics are returned for each layer.

## Examples

``` r
if (FALSE) { # \dontrun{
library(terra)

# Example SpatRaster and SpatVector
r <- rast(system.file("ex/elev.tif", package = "terra"))
v <- as.polygons(r > 500, dissolve = TRUE)
v$PA_ID <- paste0("PA_", seq_len(nrow(v)))

# Mean elevation per polygon
pa_stats <- summarize_raster_by_polygons(
  x        = r,
  polygons = v,
  id_col   = "PA_ID"
)

# Multiple statistics per polygon
pa_stats_multi <- summarize_raster_by_polygons(
  x        = r,
  polygons = v,
  id_col   = "PA_ID",
  fun      = function(v, ...) c(
    mean = mean(v, ...),
    min  = min(v, ...),
    max  = max(v, ...)
  ),
  na.rm    = TRUE
)
} # }
```
