test_that("function area.calc works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif",
                                  package = "divraster"))

  # applying the function
  area <- area.calc(bin1)
  area2 <- area.calc(bin1, bin1[[1]])
  area3 <- area.calc(bin1, bin1[[1]], bin1[[2]])

  # testing
  expect_error(area.calc(x = "not a raster"), "Input 'x' must be a SpatRaster object.")
  expect_error(area.calc(x = bin1, y = "not a raster"), "Input 'y' must be a SpatRaster object.")
  expect_error(area.calc(x = bin1, y = bin1), "Input 'y' must be a SpatRaster with a single layer.")
  expect_true(class(area) == "data.frame", "TRUE")
  expect_equal(area[1,1], "A")
  expect_equal(round(area[1,2], 0), 6154)
  expect_equal(names(area)[2], "Area")
  expect_equal(names(area2)[3], "Overlap_Area_Y")
  expect_equal(dim(area2)[1], 10)
  expect_equal(dim(area2)[2], 3)
  expect_equal(dim(area3)[1], 10)
  expect_equal(dim(area3)[2], 5)
  expect_equal(round(area3[3,5], 0), 1731)
  expect_equal(names(area3)[4], "Overlap_Area_Z")
  expect_equal(names(area3)[5], "Overlap_Area_All")
})
