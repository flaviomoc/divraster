test_that("function temp.beta works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  bin2 <- terra::rast(system.file("extdata", "fut.tif", package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "divraster"))

  # applying the function
  beta.td <- temp.beta(bin1, bin2)
  beta.fd <- temp.beta(bin1, bin2, traits)
  beta.pd <- temp.beta(bin1, bin2, tree)

  # testing
  expect_equal(round(beta.td[[1]]@ptr$range_min, 2), .2)
  expect_equal(round(beta.td[[2]]@ptr$range_max, 2), .89)
  expect_equal(round(beta.td[[3]]@ptr$range_max, 2), .71)
  expect_equal(round(beta.fd[[1]]@ptr$range_min, 2), .15)
  expect_equal(round(beta.fd[[2]]@ptr$range_max, 2), .6)
  expect_equal(round(beta.fd[[3]]@ptr$range_max, 2), .66)
  expect_equal(round(beta.pd[[1]]@ptr$range_max, 2), .82)
  expect_equal(round(beta.pd[[2]]@ptr$range_max, 2), .71)
  expect_equal(round(beta.pd[[3]]@ptr$range_max, 2), .5)
})
