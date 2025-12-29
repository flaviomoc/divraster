# Average pairwise distance between occurrences by species

Compute the mean of all unique pairwise great-circle distances between
occurrence records for each species, using longitude/latitude
coordinates (EPSG:4326). Distances are computed with sf::st_distance().

## Usage

``` r
occ.avg.dist(df, species_col = "species", lon_col = "lon", lat_col = "lat")
```

## Arguments

- df:

  A data.frame (or tibble) containing species names and coordinates.

- species_col:

  Character. Column name containing species names. Default "species".

- lon_col:

  Character. Column name containing longitudes (decimal degrees).
  Default "lon".

- lat_col:

  Character. Column name containing latitudes (decimal degrees). Default
  "lat".

## Value

A data.frame with columns:

- species: unique species names

- avg_distance_m: mean pairwise distance in meters

## Details

For each species, the function:

- Filters out rows with missing species or coordinates

- Converts lon/lat to an sf point object with CRS = 4326

- Builds a full distance matrix within the species

- Extracts the upper triangle (unique pairs) and averages distances

Species with fewer than 2 valid records return NA.

## Examples

``` r
# \donttest{
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:terra’:
#> 
#>     intersect, union
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE

# Create example occurrence data for 3 species
occurrences <- tibble(
  species = c(
    rep("Species_A", 4),
    rep("Species_B", 5),
    rep("Species_C", 2)
  ),
  lon = c(
    # Species A: widespread across Brazil
    -43.2, -47.9, -38.5, -51.2,
    # Species B: clustered in southeast
    -43.9, -44.1, -43.7, -44.3, -43.8,
    # Species C: only 2 points
    -45.0, -46.0
  ),
  lat = c(
    # Species A
    -22.9, -15.8, -12.9, -30.0,
    # Species B
    -19.9, -20.1, -19.8, -20.3, -20.0,
    # Species C
    -23.5, -24.0
  )
)

# Calculate average pairwise distances
result <- occ.avg.dist(occurrences)
result
#>     species avg_distance_m
#> 1 Species_A     1375543.80
#> 2 Species_B       41801.74
#> 3 Species_C      115972.99
# }
```
