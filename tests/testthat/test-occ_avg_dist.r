library(testthat)
library(sf)
library(dplyr)

# ==============================================================================
# Test 1: Basic functionality
# ==============================================================================

test_that("calculates distances for multiple species", {
  occurrences <- data.frame(
    species = c("A", "A", "B", "B", "B"),
    lon = c(-40, -41, -42, -43, -44),
    lat = c(-20, -21, -22, -23, -24)
  )

  result <- occ.avg.dist(occurrences)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true(all(!is.na(result$avg_distance_m)))
})

# ==============================================================================
# Test 2: Handles single point (returns NA)
# ==============================================================================

test_that("returns NA for species with one point", {
  occurrences <- data.frame(
    species = c("A", "B", "B"),
    lon = c(-40, -41, -42),
    lat = c(-20, -21, -22)
  )

  result <- occ.avg.dist(occurrences)

  # Species A has 1 point = NA
  expect_true(is.na(result$avg_distance_m[result$species == "A"]))
  # Species B has 2 points = distance
  expect_true(!is.na(result$avg_distance_m[result$species == "B"]))
})

# ==============================================================================
# Test 3: Custom column names work
# ==============================================================================

test_that("works with custom column names", {
  occurrences <- data.frame(
    taxon = c("A", "A"),
    longitude = c(-40, -41),
    latitude = c(-20, -21)
  )

  result <- occ.avg.dist(occurrences,
                         species_col = "taxon",
                         lon_col = "longitude",
                         lat_col = "latitude")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
})

# ==============================================================================
# Test 4: Errors on missing columns
# ==============================================================================

test_that("errors when columns missing", {
  occurrences <- data.frame(
    wrong = c("A", "B"),
    lon = c(-40, -41),
    lat = c(-20, -21)
  )

  expect_error(occ.avg.dist(occurrences))
})
