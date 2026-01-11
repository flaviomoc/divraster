test_that("bin2crop works", {
  skip_if_not_installed("terra")

  crs_ll <- "+proj=longlat +datum=WGS84 +no_defs"

  r_cont <- terra::rast(ncol = 50, nrow = 50, xmin = 0, xmax = 10, ymin = 0, ymax = 10)
  terra::values(r_cont) <- stats::runif(terra::ncell(r_cont), 0, 1)
  names(r_cont) <- "suitability"
  suppressWarnings(terra::crs(r_cont) <- crs_ll)

  r_bin <- terra::rast(r_cont)
  xy <- terra::xyFromCell(r_bin, 1:terra::ncell(r_bin))
  center_dist <- sqrt((xy[, 1] - 5)^2 + (xy[, 2] - 5)^2)
  terra::values(r_bin) <- ifelse(center_dist <= 3, 1, 0)
  names(r_bin) <- "study_area"
  suppressWarnings(terra::crs(r_bin) <- crs_ll)

  result <- bin2crop(r_bin, r_cont)
  expect_s4_class(result, "SpatRaster")
  expect_equal(terra::res(result), terra::res(r_bin))

  v <- terra::values(result)
  expect_true(any(!is.na(v)))
  expect_true(any(is.na(v)))

  clip_poly <- terra::vect("POLYGON ((3 3, 7 3, 7 7, 3 7, 3 3))")
  suppressWarnings(terra::crs(clip_poly) <- crs_ll)

  result2 <- suppressWarnings(bin2crop(r_bin, r_cont, clip = clip_poly))
  expect_s4_class(result2, "SpatRaster")
  expect_true(!identical(terra::ext(result2), terra::ext(r_cont)))

  temp_file <- tempfile(fileext = ".tif")
  out <- suppressWarnings(bin2crop(r_bin, r_cont, filename = temp_file, overwrite = TRUE))
  expect_true(file.exists(temp_file))

  loaded <- suppressWarnings(terra::rast(temp_file))
  expect_s4_class(loaded, "SpatRaster")

  rm(out, loaded)
  gc()
  unlink(temp_file)

  temp_file2 <- tempfile(fileext = ".tif")
  out1 <- suppressWarnings(bin2crop(r_bin, r_cont, filename = temp_file2, overwrite = TRUE))
  rm(out1)
  gc()

  expect_no_error(
    suppressWarnings(bin2crop(r_bin, r_cont, filename = temp_file2, overwrite = TRUE))
  )

  gc()
  unlink(temp_file2)

  expect_error(bin2crop("not a raster", r_cont))
  expect_error(bin2crop(NULL, r_cont))
  expect_error(bin2crop(r_bin, "not a raster"))
  expect_error(bin2crop(r_bin, NULL))
  expect_error(bin2crop(r_bin, r_cont, clip = "not a polygon"))
})
