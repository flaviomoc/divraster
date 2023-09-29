test_that("function spat.alpha works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif",
                                  package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv",
                                 package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre",
                                     package = "divraster"))
  bin.crs <- bin1
  terra::crs(bin.crs) <- "epsg:25831"
  bin1.na <- bin1
  bin1.na[, 1:7] <- NA

  # applying the function
  alpha.td <- spat.alpha(bin1, filename = paste0(tempfile(), ".tif"))
  alpha.fd <- spat.alpha(bin1, traits)
  alpha.pd <- spat.alpha(bin1, tree)

  # testing
  expect_true(terra::hasValues(spat.alpha(bin1.na)))
  expect_error(spat.alpha(bin.crs))
  expect_error(spat.alpha(bin1[[1]]))
  expect_error(spat.alpha(bin = traits))
  expect_true(class(bin1) == "SpatRaster", "TRUE")
  expect_true(class(tree) == "phylo", "TRUE")
  expect_equal(dim(traits), c(10, 2))
  expect_equal(terra::minmax(alpha.td)[1], 2)
})
