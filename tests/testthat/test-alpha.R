test_that("function spat.alpha works", {

  # creating data
  library(terra)
  set.seed(100)
  bin1 <- terra::rast(ncol = 5, nrow = 5, nlyr = 10)
  values(bin1) <- round(runif(ncell(bin1) * nlyr(bin1)))
  names(bin1) <- paste0("sp", 1:10)

  set.seed(100)
  mass <- runif(10, 10, 800)
  beak.size <- runif(10, .2, 5)
  tail.length <- runif(10, 2, 10)
  wing.length <- runif(10, 15, 60)
  range.size <- runif(10, 10000, 100000)
  traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
  rownames(traits) <- names(bin1)

  set.seed(100)
  tree <- ape::rtree(n = 10, tip.label = paste0("sp", 1:10))

  # applying the function
  alpha.td <- spat.alpha(bin1)
  alpha.fd <- spat.alpha(bin1, traits)
  alpha.pd <- spat.alpha(bin1, tree)

  # testing
  expect_equal(alpha.td@pnt$range_min, 3)
  expect_equal(round(alpha.fd@pnt$range_min, 2), .77)
  expect_equal(round(alpha.pd@pnt$range_min, 2), 5.2)
})
