test_that("function spat.rand works", {

  # loading data
  x <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "divraster"))

  # applying the function
  ses.fd <- spat.rand(x, traits, 3, "spat", filename = paste0(tempfile(), ".tif"))
  ses.pd <- spat.rand(x, tree, 3, "spat")
  ses.pd2 <- spat.rand(x, tree, 3, "site")
  bin.crs = x
  terra::crs(bin.crs) <- "epsg:25831"

  # testing
  expect_error(spat.rand(x, traits, aleats = 3))
  expect_error(spat.rand(x, traits, random = "spat"))
  expect_error(spat.rand(bin.crs, traits, 3, "spat"))
  expect_error(spat.rand(x, x, 3, "spat"))
  expect_error(spat.rand(traits, traits, 3, "spat"))
  expect_error(spat.rand(x, traits, 3, "x"))
  expect_error(spat.rand(x[[1]], traits, 3, "spat"))
  expect_true(ses.fd[[4]]@ptr$hasValues)
  expect_true(ses.pd[[4]]@ptr$hasValues)
  expect_true(ses.pd2[[4]]@ptr$hasValues)
  })
