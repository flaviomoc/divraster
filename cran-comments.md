## R CMD check results

0 errors | 0 warnings | 0 notes

## Maintainer comments
Main changes are listed below and in the NEWS file:

* This is a new release.

* The description was updated, and now it no longer starts with "This package", the package name, title, or anything similar.

* Package names, software names, and API without single quotes in titles and descriptions were checked.

* References describing the methods have been added to the description file: Cardoso et al. 2022 <https://CRAN.R-project.org/package=BAT> and Heming et al. 2023 <https://CRAN.R-project.org/package=SESraster>

* \dontrun{} was either removed or replaced with \donttest{}

* The description of the functions has been improved.

* Vignette was remodeled to better exemplify the `divraster` functionalities.

* Tests and citation have been updated.

## New features in v1.2.3

- Added `area.calc.flex()`: flexible area calculation with zonal/overlay support
- Added `occ.avg.dist()`: average pairwise occurrence distances
- Added `rast.by.polys()`: raster summaries by polygons
- Added `bin2crop()`: crop continuous rasters by binary footprint
- Updated vignette with new examples
