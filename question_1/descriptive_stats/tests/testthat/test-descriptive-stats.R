test_that("calc_mean calculates correct results", {
  expect_equal(calc_mean(c(1, 2, 3)), 2)
  expect_equal(calc_mean(c(1, NA, 3)), 2)
})

test_that("calc_median calculates correct results", {
  expect_equal(calc_median(c(1, 2, 3, 4)), 2.5)
  expect_equal(calc_median(c(1, NA, 3)), 2)
})

test_that("calc_mode handles modes ties and no mode", {
  expect_equal(calc_mode(c(1, 2, 2, 3)), 2)
  expect_equal(calc_mode(c(1, 1, 2, 2)), c(1, 2))
  
  expect_message(
    no_mode <- calc_mode(c(1, 2, 3)),
    "No mode found"
  )
  expect_true(is.na(no_mode))
})

test_that("quartile functions calculate correct results", {
  expect_equal(calc_q1(c(1, 2, 3, 4, 5)), 2)
  expect_equal(calc_q3(c(1, 2, 3, 4, 5)), 4)
  expect_equal(calc_iqr(c(1, 2, 3, 4, 5)), 2)
  
  expect_equal(calc_q1(c(1, NA, 3, 4)), 2)
  expect_equal(calc_q3(c(1, NA, 3, 4)), 3.5)
  expect_equal(calc_iqr(c(1, NA, 3, 4)), 1.5)
})

test_that("all functions reject invalid input", {
  functions <- list(
    calc_mean, calc_median, calc_mode,
    calc_q1, calc_q3, calc_iqr
  )
  
  for (stat_function in functions) {
    expect_error(stat_function(numeric(0)), "cannot be empty")
    expect_error(stat_function(c(NA_real_, NA_real_)), "only missing")
    expect_error(stat_function(5), "at least two")
    expect_error(stat_function(c("a", "b")), "numeric vector")
  }
})