test_that("collapse_symbols joins a vector with commas", {
  expect_equal(CMCR:::collapse_symbols(c("BTC", "ETH", "SOL")), "BTC,ETH,SOL")
  expect_equal(CMCR:::collapse_symbols("BTC"), "BTC")
})

test_that("sanitize_date converts ISO string to numeric unix timestamp", {
  result <- CMCR:::sanitize_date("2020-01-01")
  expect_type(result, "double")
  expect_gt(result, 0)
})

test_that("sanitize_date converts Date objects", {
  result <- CMCR:::sanitize_date(as.Date("2020-01-01"))
  expect_type(result, "double")
  expect_gt(result, 0)
})

test_that("sanitize_date converts POSIXct objects", {
  t <- as.POSIXct("2020-01-01 00:00:00", tz = "UTC")
  result <- CMCR:::sanitize_date(t)
  expect_type(result, "double")
})

test_that("sanitize_date errors on non-date input", {
  expect_error(CMCR:::sanitize_date(42))
})
