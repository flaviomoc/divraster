test_that("function betatemp_fd_sp works", {

  # creating data
  set.seed(100)

  ref <- terra::rast(array(sample(c(rep(1, 750), rep(0, 250))), dim = c(20, 20, 10)))
  names(ref) <- paste0("sp", 1:10)
  ref

  fut <- terra::rast(array(sample(c(rep(1, 500), rep(0, 500))), dim = c(20, 20, 10)))
  names(fut) <- names(ref)
  fut

  set.seed(100)
  mass <- runif(10, 10, 800)
  beak.size <- runif(10, .2, 5)
  tail.length <- runif(10, 2, 10)
  traits <- as.data.frame(cbind(mass, beak.size, tail.length))
  rownames(traits) <- names(ref)
  traits

  # applying the function
  beta.fd <- betatemp_fd_sp(ref, fut, traits)

  # testing
  expect_equal(round(beta.fd@ptr$range_max[1], 2), .49)
  expect_equal(round(beta.fd@ptr$range_max[2], 2), .60)
  expect_equal(round(beta.fd@ptr$range_max[3], 2), .68)
})
