library(testthat)
library(terra)

# ==============================================================================
# Test 1: Basic functionality
# ==============================================================================

test_that("summarizes raster values by polygons", {
  # Create simple raster
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- 1:ncell(r)

  # Create 2 polygons with attributes
  p1 <- vect("POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))", crs = "EPSG:4326")
  p2 <- vect("POLYGON ((5 5, 10 5, 10 10, 5 10, 5 5))", crs = "EPSG:4326")
  polys <- rbind(p1, p2)
  polys$id <- 1:2  # Add attribute

  result <- rast.by.polys(r, polys)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true(ncol(result) > 0)
})

# ==============================================================================
# Test 2: Uses ID column when specified
# ==============================================================================

test_that("uses specified ID column", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- runif(ncell(r), 0, 100)

  p1 <- vect("POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))", crs = "EPSG:4326")
  p2 <- vect("POLYGON ((5 5, 10 5, 10 10, 5 10, 5 5))", crs = "EPSG:4326")
  polys <- rbind(p1, p2)
  polys$poly_id <- c("A", "B")
  polys$extra_col <- c(1, 2)

  result <- rast.by.polys(r, polys, id_col = "poly_id")

  expect_true("poly_id" %in% names(result))
  expect_false("extra_col" %in% names(result))
  expect_equal(result$poly_id, c("A", "B"))
})

# ==============================================================================
# Test 3: Custom summary function works
# ==============================================================================

test_that("applies custom summary function", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- 1:ncell(r)

  p <- vect("POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0))", crs = "EPSG:4326")
  p$poly_id <- "A"  # Add attribute

  # Simple custom function
  custom_fun <- function(v, ...) max(v, ...)

  result <- rast.by.polys(r, p, fun = custom_fun, na.rm = TRUE)

  # Should have polygon attributes and at least one summary column
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true(ncol(result) >= 2)  # At least poly_id + one summary column
})

# ==============================================================================
# Test 4: Error handling
# ==============================================================================

test_that("errors on invalid inputs", {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- 1:ncell(r)
  p <- vect("POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))", crs = "EPSG:4326")
  p$id <- 1

  # Not a SpatRaster
  expect_error(rast.by.polys("not a raster", p))

  # Not a SpatVector
  expect_error(rast.by.polys(r, "not a vector"))

  # ID column doesn't exist
  expect_error(rast.by.polys(r, p, id_col = "nonexistent"))
})
