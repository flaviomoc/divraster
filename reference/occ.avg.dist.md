# Average pairwise distance between occurrences by species

Compute the mean of all unique pairwise great-circle distances between
occurrence records for each species, using longitude/latitude
coordinates (EPSG:4326). Distances are computed with
[`sf::st_distance()`](https://r-spatial.github.io/sf/reference/geos_measures.html).

## Usage

``` r
occ.avg.dist(df, species_col = "species", lon_col = "lon", lat_col = "lat")
```

## Arguments

- df:

  A data.frame (or tibble) containing species names and coordinates.

- species_col:

  Character scalar. Column name containing species names.

- lon_col:

  Character scalar. Column name containing longitudes (decimal degrees).

- lat_col:

  Character scalar. Column name containing latitudes (decimal degrees).

## Value

A tibble with columns:

- `species`: unique species names.

- `avg_distance_m`: mean pairwise distance (meters).

## Details

For each species, the function:

- Filters out rows with missing species / coordinates.

- Converts lon/lat to an `sf` point object with CRS = 4326.

- Builds a full distance matrix within the species.

- Extracts the upper triangle (unique pairs) and averages distances.

Species with \< 2 valid records return `NA`.
