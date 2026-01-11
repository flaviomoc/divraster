test_that("spat.beta works and validates inputs", {
  skip_if_not_installed("terra")
  skip_if_not_installed("ape")

  # ---- load extdata ----
  bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  bin2 <- terra::rast(system.file("extdata", "fut.tif", package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "divraster"))

  # ---- main functionality (TD / FD / PD) ----
  beta.td <- spat.beta(bin2)
  beta.fd <- spat.beta(bin1, traits)
  beta.pd <- spat.beta(bin1, tree)

  expect_true(inherits(beta.td, "SpatRaster"))
  expect_true(inherits(beta.fd, "SpatRaster"))
  expect_true(inherits(beta.pd, "SpatRaster"))

  # “correctness” regression checks (keep what you already had)
  expect_equal(round(terra::minmax(beta.td[[1]])[2], 2), .92)
  expect_equal(round(terra::minmax(beta.td[[2]])[2], 2), .73)
  expect_equal(round(terra::minmax(beta.td[[3]])[2], 2), .61)
  expect_equal(round(terra::minmax(beta.pd[[1]])[2], 2), .73)
  expect_equal(round(terra::minmax(beta.pd[[2]])[2], 2), .51)
  expect_equal(round(terra::minmax(beta.pd[[3]])[2], 2), .48)

  # ---- NA handling ----
  bin.na2 <- bin1
  bin.na2[1:8, ] <- NA
  expect_true(is.nan(terra::minmax(spat.beta(bin.na2)[[1]])[2]))

  # ---- input validation ----
  expect_error(spat.beta(traits))
  expect_error(spat.beta(bin1[[1]]))
  expect_error(spat.beta(x = traits))
  expect_error(spat.beta(x = bin1, tree = bin1))

  # ---- CRS edge-case: only test if EPSG CRS assignment works here ----
  can_set_epsg <- !inherits(
    try({
      tmp <- bin1
      suppressWarnings(terra::crs(tmp) <- "EPSG:25831")
      terra::crs(tmp) != "" && !is.na(terra::crs(tmp))
    }, silent = TRUE),
    "try-error"
  )

  if (isTRUE(can_set_epsg)) {
    bin.crs <- bin1
    suppressWarnings(terra::crs(bin.crs) <- "EPSG:25831")
    expect_no_error(spat.beta(bin.crs))
  }
})
