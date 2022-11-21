test_that("function ecogen works", {

  # loading data
  ref <- terra::rast(system.file("extdata", "ref_Mota.tif", package = "DMSD"))
  fut <- terra::rast(system.file("extdata", "fut_Mota.tif", package = "DMSD"))
  area <- read.csv(system.file("extdata", "area_Mota.csv", package = "DMSD"), sep = ";")
  area$area2 <- area$area/1000 # adding new column
  area$arealog <- log(area$area) # adding new column

  # applying the function
  area.ref <- ecogen(ref, area, "one")
  area.fut <- ecogen(fut, area, "one")
  area.delta <- area.fut - area.ref
  area.all <- ecogen(ref, area, "all")

  # testing
  expect_equal(round(area.ref@ptr$range_min, 0), 76292)
  expect_equal(round(area.fut@ptr$range_min, 0), 76867)
  expect_equal(round(area.delta@ptr$range_min, 0), -8043)
  expect_equal(length(area.all), 3)
  expect_equal(round(area.all[[1]]@ptr$range_max, 0), 116848)
  expect_equal(round(area.all[[2]]@ptr$range_max, 0), 117)
  expect_equal(round(area.all[[3]]@ptr$range_max, 0), 12)
})
