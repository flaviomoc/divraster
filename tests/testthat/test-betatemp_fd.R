test_that("function betatemp_fd works", {

  # creating data
  set.seed(100)
  ref <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(10, 10, 10)))
  names(ref) <- paste0("sp", 1:10)
  fut <- terra::rast(array(sample(c(rep(1, 400), rep(0, 600))), dim = c(10, 10, 10)))
  names(fut) <- names(ref)

  set.seed(100)
  mass <- runif(10, 10, 800)
  beak.size <- runif(10, .2, 5)
  tail.length <- runif(10, 2, 10)
  wing.length <- runif(10, 15, 60)
  range.size <- runif(10, 10000, 100000)
  traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
  rownames(traits) <- names(ref)

  # applying the function
  beta.fd <- betatemp_fd(ref, fut, traits)

  # testing
  expect_equal(round(beta.fd[[1]]@ptr$range_max, 2), .93)
  expect_equal(round(beta.fd[[2]]@ptr$range_max, 2), .55)
  expect_equal(round(beta.fd[[3]]@ptr$range_max, 2), .88)
})
