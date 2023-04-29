test_that("function spat.alpha works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "DMSD"))
  bin2 <- terra::rast(system.file("extdata", "fut.tif", package = "DMSD"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "DMSD"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "DMSD"))

  # applying the function
  alpha.td <- spat.alpha(bin1)
  alpha.fd <- spat.alpha(bin1, traits)
  alpha.pd <- spat.alpha(bin1, tree)

  # testing
  expect_equal(alpha.td@ptr$range_min, 2)
  expect_equal(round(alpha.fd@ptr$range_min, 2), .24)
  expect_equal(round(alpha.pd@ptr$range_min, 2), 3.1)
})
