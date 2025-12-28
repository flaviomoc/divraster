library(testthat)
library(terra)

# ==============================================================================
# Test 1: Basic area calculation
# ==============================================================================

test_that("calculates area for raster categories", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(1, 2, 3), length.out = ncell(r))

  result <- suppressMessages(area.calc.flex(r, unit = "km"))

  expect_s3_class(result, "data.frame")
  expect_true("category" %in% names(result))
  expect_true("area_km" %in% names(result))
  expect_true(nrow(result) > 0)
})

# ==============================================================================
# Test 2: Binary overlay (r2_raster)
# ==============================================================================

test_that("calculates overlay area with binary raster", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(1, 2), length.out = ncell(r))

  # Binary overlay (0/1)
  overlay <- rast(r)
  values(overlay) <- rep(c(0, 1), length.out = ncell(overlay))

  result <- suppressMessages(area.calc.flex(r, r2_raster = overlay, unit = "km"))

  expect_s3_class(result, "data.frame")
  expect_true("area_id" %in% names(result))
  expect_true(any(result$area_id == "Overlay Area"))
})

# ==============================================================================
# Test 3: Continuous overlay with threshold
# ==============================================================================

test_that("binarizes continuous raster with threshold", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(1, 2), length.out = ncell(r))

  # Continuous overlay (0-1)
  overlay <- rast(r)
  values(overlay) <- runif(ncell(overlay), 0, 1)

  result <- suppressMessages(area.calc.flex(r, r2_raster = overlay,
                                            threshold = 0.5, unit = "km"))

  expect_s3_class(result, "data.frame")
  expect_true(any(result$area_id == "Overlay Area"))
})

test_that("errors when threshold missing for continuous raster", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(1, ncell(r))

  # Continuous overlay without threshold
  overlay <- rast(r)
  values(overlay) <- runif(ncell(overlay), 0, 1)

  expect_error(
    suppressMessages(area.calc.flex(r, r2_raster = overlay, unit = "km")),
    "threshold.*required"
  )
})

# ==============================================================================
# Test 4: Vector overlay (r2_vector)
# ==============================================================================

test_that("calculates overlay area with vector", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(1, 2), length.out = ncell(r))

  # Vector overlay
  overlay_poly <- vect("POLYGON ((2 2, 8 2, 8 8, 2 8, 2 2))", crs = "EPSG:4326")

  result <- suppressMessages(area.calc.flex(r, r2_vector = overlay_poly, unit = "km"))

  expect_s3_class(result, "data.frame")
  expect_true(any(result$area_id == "Overlay Area"))
})

# ==============================================================================
# Test 5: Error when both r2_raster and r2_vector provided
# ==============================================================================

test_that("errors when both r2_raster and r2_vector provided", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(1, ncell(r))

  overlay_r <- rast(r)
  values(overlay_r) <- rep(1, ncell(overlay_r))
  overlay_v <- vect("POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))", crs = "EPSG:4326")

  expect_error(
    area.calc.flex(r, r2_raster = overlay_r, r2_vector = overlay_v),
    "Only one of"
  )
})

# ==============================================================================
# Test 6: Zonal with additional columns (add_cols)
# ==============================================================================

test_that("includes additional columns from polygons", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(1, 2), length.out = ncell(r))

  p1 <- vect("POLYGON ((0 0, 5 0, 5 10, 0 10, 0 0))", crs = "EPSG:4326")
  p2 <- vect("POLYGON ((5 0, 10 0, 10 10, 5 10, 5 0))", crs = "EPSG:4326")
  polys <- rbind(p1, p2)
  polys$zone_id <- c("A", "B")
  polys$population <- c(1000, 2000)
  polys$area_type <- c("urban", "rural")

  result <- suppressMessages(area.calc.flex(r, zonal_polys = polys,
                                            id_col = "zone_id",
                                            add_cols = c("population", "area_type"),
                                            unit = "km"))

  expect_true("population" %in% names(result))
  expect_true("area_type" %in% names(result))
  expect_equal(unique(result$population), c(1000, 2000))
})

# ==============================================================================
# Test 7: Zonal with overlay
# ==============================================================================

test_that("calculates zonal area with overlay", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(1, 2), length.out = ncell(r))

  # Overlay
  overlay <- rast(r)
  values(overlay) <- rep(c(0, 1), length.out = ncell(overlay))

  # Zones
  p1 <- vect("POLYGON ((0 0, 5 0, 5 10, 0 10, 0 0))", crs = "EPSG:4326")
  p2 <- vect("POLYGON ((5 0, 10 0, 10 10, 5 10, 5 0))", crs = "EPSG:4326")
  polys <- rbind(p1, p2)
  polys$zone_id <- c("A", "B")

  result <- suppressMessages(area.calc.flex(r, r2_raster = overlay,
                                            zonal_polys = polys,
                                            id_col = "zone_id",
                                            unit = "km"))

  expect_true(any(result$area_id == "Total Area"))
  expect_true(any(result$area_id == "Overlay Area"))
  expect_true(all(c("A", "B") %in% result$zone_id))
})

# ==============================================================================
# Test 8: omit_zero parameter
# ==============================================================================

test_that("omit_zero parameter works", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(0, 1, 2), length.out = ncell(r))

  # With omit_zero = TRUE (default)
  result_omit <- suppressMessages(area.calc.flex(r, omit_zero = TRUE, unit = "km"))
  expect_false(0 %in% result_omit$category)

  # With omit_zero = FALSE
  result_keep <- suppressMessages(area.calc.flex(r, omit_zero = FALSE, unit = "km"))
  expect_true(0 %in% result_keep$category)
})

# ==============================================================================
# Test 9: Multilayer raster
# ==============================================================================

test_that("processes multilayer raster", {
  r1 <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
             ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r1) <- rep(c(1, 2), length.out = ncell(r1))

  r2 <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
             ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r2) <- rep(c(2, 3), length.out = ncell(r2))

  # Create multilayer
  multi <- c(r1, r2)
  names(multi) <- c("layer1", "layer2")

  result <- suppressMessages(area.calc.flex(multi, unit = "km"))

  expect_true("layer" %in% names(result))
  expect_true(all(c("layer1", "layer2") %in% result$layer))
})

# ==============================================================================
# Test 10: Grid alignment (different resolution overlay)
# ==============================================================================

test_that("aligns overlay grid when mismatched", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(c(1, 2), length.out = ncell(r))

  # Different resolution overlay
  overlay <- rast(ncol = 20, nrow = 20, xmin = 0, xmax = 10,
                  ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(overlay) <- rep(c(0, 1), length.out = ncell(overlay))

  # Should trigger alignment message and work
  expect_message(
    result <- area.calc.flex(r, r2_raster = overlay, unit = "km"),
    "Aligning overlay"
  )

  expect_s3_class(result, "data.frame")
})

# ==============================================================================
# Test 11: Different area units
# ==============================================================================

test_that("works with different area units", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(1, ncell(r))

  result_km <- suppressMessages(area.calc.flex(r, unit = "km"))
  result_m <- suppressMessages(area.calc.flex(r, unit = "m"))
  result_ha <- suppressMessages(area.calc.flex(r, unit = "ha"))

  expect_true("area_km" %in% names(result_km))
  expect_true("area_m" %in% names(result_m))
  expect_true("area_ha" %in% names(result_ha))
})

# ==============================================================================
# Test 12: Error handling
# ==============================================================================

test_that("errors when zonal_polys without id_col", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(1, ncell(r))

  p <- vect("POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))", crs = "EPSG:4326")
  p$zone <- "A"

  expect_error(
    area.calc.flex(r, zonal_polys = p),
    "id_col.*required"
  )
})

test_that("errors on invalid unit", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- rep(1, ncell(r))

  expect_error(
    area.calc.flex(r, unit = "invalid"),
    "must be one of"
  )
})
