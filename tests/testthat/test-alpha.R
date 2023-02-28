test_that("function alpha works", {

  # creating data
  set.seed(100)
  ref <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(10, 10, 10)))
  names(ref) <- paste0("sp", 1:10)

  set.seed(100)
  mass <- runif(10, 10, 800)
  beak.size <- runif(10, .2, 5)
  tail.length <- runif(10, 2, 10)
  wing.length <- runif(10, 15, 60)
  range.size <- runif(10, 10000, 100000)
  traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
  rownames(traits) <- names(ref)

  set.seed(100)
  tree <- ape::rtree(n = 10, tip.label = paste0("sp", 1:10))

  # applying the function
  alpha.td <- alpha(ref)
  alpha.td
  alpha.fd <- alpha(ref, traits)
  alpha.fd
  alpha.pd <- alpha(ref, tree)
  alpha.pd

  # testing
  expect_equal(alpha.td@ptr$range_min, 4)
  expect_equal(round(alpha.fd@ptr$range_min, 2), .90)
  expect_equal(round(alpha.pd@ptr$range_min, 2), 5.74)
})
