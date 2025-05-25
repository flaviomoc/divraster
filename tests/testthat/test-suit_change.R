test_that("function suit.change works", {

  # loading data
  r1 <- terra::rast(system.file("extdata", "ref.tif",
                                  package = "divraster"))
  r2 <- terra::rast(system.file("extdata", "fut.tif",
                                  package = "divraster"))

  # applying the function
  change_map <- suit.change(r1, r2)

  # testing
  expect_true(terra::hasValues(change_map))
  expect_true(terra::hasValues(suit.change(r1, r2)[[1]]))
  expect_error(suit.change(r1))
  expect_equal(terra::minmax(change_map)[1], 1)
  expect_equal(terra::minmax(change_map)[2], 4)
})
