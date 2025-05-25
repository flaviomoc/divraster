test_that("function differ.rast works", {

  # loading data
  rich1 <- terra::rast(system.file("extdata", "rich_ref.tif", package = "divraster"))
  rich2 <- terra::rast(system.file("extdata", "rich_fut.tif", package = "divraster"))

  # applying the function
  abs_diff_rast <- differ.rast(rich1, rich2, perc = FALSE)
  perc_diff_rast <- differ.rast(rich1, rich2, perc = TRUE)

  # testing
  expect_true(terra::hasValues(abs_diff_rast))
  expect_true(terra::hasValues(perc_diff_rast))
  expect_equal(terra::minmax(abs_diff_rast)[1], -5)
  expect_equal(terra::minmax(abs_diff_rast)[2], 5)
  expect_equal(round(terra::minmax(perc_diff_rast)[1], 2), -71.43)
  expect_equal(round(terra::minmax(perc_diff_rast)[2], 2), 200)
})
