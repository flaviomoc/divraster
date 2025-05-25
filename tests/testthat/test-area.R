test_that("function area.calc works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif",
                                  package = "divraster"))

  # applying the function
  area <- area.calc(bin1)

  # testing
  expect_true(class(area) == "data.frame", "TRUE")
  expect_equal(area[1,1], "A")
  expect_equal(round(area[1,2], 0), 6154)
  expect_equal(names(area)[2], "Area")
})
