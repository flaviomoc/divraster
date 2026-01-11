skip_if_not_installed("terra")

test_that("area.calc.flex returns expected columns (no zonal)", {
  r <- terra::rast(ncol = 30, nrow = 30, xmin = 0, xmax = 10, ymin = 0, ymax = 10)
  terra::values(r) <- sample(1:3, terra::ncell(r), replace = TRUE)

  suppressWarnings(terra::crs(r) <- "EPSG:4326")
  names(r) <- "baseline"   # <-- IMPORTANT: not terra::names()

  out <- area.calc.flex(r, unit = "km")

  expect_s3_class(out, "data.frame")
  expect_true(all(c("layer", "area_id", "category", "area_km") %in% names(out)))
  expect_false("population" %in% names(out))
})

test_that("area.calc.flex returns id_col when zonal_polys is provided", {
  r <- terra::rast(ncol = 30, nrow = 30, xmin = 0, xmax = 10, ymin = 0, ymax = 10)
  terra::values(r) <- sample(1:3, terra::ncell(r), replace = TRUE)

  suppressWarnings(terra::crs(r) <- "EPSG:4326")
  names(r) <- "baseline"

  p1 <- terra::vect("POLYGON ((0 0, 5 0, 5 10, 0 10, 0 0))")
  p2 <- terra::vect("POLYGON ((5 0, 10 0, 10 10, 5 10, 5 0))")
  zones <- rbind(p1, p2)

  suppressWarnings(terra::crs(zones) <- terra::crs(r))
  zones$region_id <- c("A", "B")

  out <- area.calc.flex(r, zonal_polys = zones, id_col = "region_id", unit = "km")

  expect_true(all(c("layer", "region_id", "area_id", "category", "area_km") %in% names(out)))
  expect_false("population" %in% names(out))
})

test_that("area.calc.flex returns overlay area rows when r2_raster is provided", {
  r <- terra::rast(ncol = 30, nrow = 30, xmin = 0, xmax = 10, ymin = 0, ymax = 10)
  terra::values(r) <- sample(1:3, terra::ncell(r), replace = TRUE)

  suppressWarnings(terra::crs(r) <- "EPSG:4326")
  names(r) <- "baseline"

  overlay <- terra::rast(r)
  terra::values(overlay) <- sample(0:1, terra::ncell(overlay), replace = TRUE)

  out <- area.calc.flex(r, r2_raster = overlay, unit = "km")

  expect_true(any(out$area_id == "Overlay Area"))
  expect_true(any(out$area_id == "Total Area"))
})
