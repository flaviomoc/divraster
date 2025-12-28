library(testthat)
library(terra)

# ==============================================================================
# Test 1: Basic area calculation
# ==============================================================================

test_that("calculates area for raster categories", {
  # Create simple categorical raster
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(1, 2, 3), length.out = ncell(r))

  result <- area.calc.flex(r, unit = "km")

  expect_s3_class(result, "data.frame")
  expect_true("category" %in% names(result))
  expect_true("area_km" %in% names(result))
  expect_true(nrow(result) > 0)
})

# ==============================================================================
# Test 2: Area calculation with zones
# ==============================================================================

test_that("calculates area by zones", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(1, 2), length.out = ncell(r))

  # Create polygon zones
  p1 <- vect("POLYGON ((0 0, 5 0, 5 10, 0 10, 0 0))", crs = "EPSG:4326")
  p2 <- vect("POLYGON ((5 0, 10 0, 10 10, 5 10, 5 0))", crs = "EPSG:4326")
  polys <- rbind(p1, p2)
  polys$zone_id <- c("A", "B")

  result <- area.calc.flex(r, zonal_polys = polys, id_col = "zone_id", unit = "km")

  expect_s3_class(result, "data.frame")
  expect_true("zone_id" %in% names(result))
  expect_true(all(c("A", "B") %in% result$zone_id))
})

# ==============================================================================
# Test 3: Different area units
# ==============================================================================

test_that("works with different area units", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(1, ncell(r))

  result_km <- area.calc.flex(r, unit = "km")
  result_m <- area.calc.flex(r, unit = "m")
  result_ha <- area.calc.flex(r, unit = "ha")

  expect_true("area_km" %in% names(result_km))
  expect_true("area_m" %in% names(result_m))
  expect_true("area_ha" %in% names(result_ha))
})

# ==============================================================================
# Test 4: Error handling
# ==============================================================================

test_that("errors when zonal_polys without id_col", {
  r <- rast(ncol = 10, nrow = 10)
  values(r) <- rep(1, ncell(r))

  p <- vect("POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))", crs = "EPSG:4326")
  p$zone <- "A"

  expect_error(
    area.calc.flex(r, zonal_polys = p),
    "id_col.*required"
  )
})

test_that("errors on invalid unit", {
  r <- rast(ncol = 10, nrow = 10)
  values(r) <- rep(1, ncell(r))

  expect_error(
    area.calc.flex(r, unit = "invalid"),
    "must be one of"
  )
})
