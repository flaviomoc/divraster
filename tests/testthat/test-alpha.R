test_that("function spat.alpha works", {
  skip_if_not_installed(c("terra", "ape"))

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "divraster"))

  # CRS test raster (suppress warnings)
  bin.crs <- bin1
  suppressWarnings(terra::crs(bin.crs) <- "EPSG:25831")

  bin1.na <- bin1
  bin1.na[, 1:7] <- NA

  # applying the function (suppress writeRaster warning)
  alpha.td <- suppressWarnings(
    spat.alpha(bin1)
  )
  alpha.fd <- spat.alpha(bin1, traits)
  alpha.pd <- spat.alpha(bin1, tree)

  # testing
  expect_true(terra::hasValues(spat.alpha(bin1.na)))

  # CRS mismatch: only if CRS was actually set
  if (terra::crs(bin.crs) != terra::crs(bin1) && !is.na(terra::crs(bin.crs))) {
    expect_error(spat.alpha(bin.crs))
  }

  expect_error(spat.alpha(bin1[[1]]))
  expect_error(spat.alpha(bin = traits))

  expect_s4_class(bin1, "SpatRaster")
  expect_s3_class(tree, "phylo")
  expect_equal(dim(traits), c(10, 2))
  expect_equal(terra::minmax(alpha.td)[1], 2)
})
