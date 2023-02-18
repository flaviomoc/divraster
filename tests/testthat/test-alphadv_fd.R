test_that("function alphadv_fd works", {

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
  diet <- c("Insect", "Insect", "Nectar", "Nectar", "Fruit", "Fruit", "Fruit", "Verteb", "Verteb", "Verteb")
  traits1 <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
  traits2 <- data.frame(mass, beak.size, tail.length, wing.length, range.size, diet)
  rownames(traits1) <- paste0("sp", 1:10)
  rownames(traits2) <- paste0("sp", 1:10)

  # applying the function
  fd <- alphadv_fd(ref, traits1)
  fd2 <- alphadv_fd(ref, traits2, "gower")

  # testing
  expect_equal(round(fd@ptr$range_min[1], 2), .32)
  expect_equal(round(fd2@ptr$range_min[1], 2), .37)
})
