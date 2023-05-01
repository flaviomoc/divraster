test_that("function spat.beta works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "DMSD"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "DMSD"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "DMSD"))

  # applying the function
  beta.td <- spat.beta(bin1)
  beta.fd <- spat.beta(bin1, traits)
  beta.pd <- spat.beta(bin1, tree)

  # testing
  expect_equal(round(beta.td[[1]]@ptr$range_max, 2), .87)
  expect_equal(round(beta.td[[2]]@ptr$range_max, 2), .72)
  expect_equal(round(beta.td[[3]]@ptr$range_max, 2), .51)
  expect_equal(round(beta.fd[[1]]@ptr$range_max, 2), .81)
  expect_equal(round(beta.fd[[2]]@ptr$range_max, 2), .42)
  expect_equal(round(beta.fd[[3]]@ptr$range_max, 2), .64)
  expect_equal(round(beta.pd[[1]]@ptr$range_max, 2), .71)
  expect_equal(round(beta.pd[[2]]@ptr$range_max, 2), .53)
  expect_equal(round(beta.pd[[3]]@ptr$range_max, 2), .46)
})
