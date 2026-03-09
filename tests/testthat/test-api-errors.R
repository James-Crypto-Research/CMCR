# Tests that verify functions fail gracefully with a bad API key,
# rather than crashing with an uninformative error.

test_that("get_listings errors informatively with a bad API key", {
  expect_error(
    get_listings(api_key = "invalid-key"),
    regexp = "401|CMC API error|request failed"
  )
})

test_that("get_currency_map errors informatively with a bad API key", {
  expect_error(
    suppressWarnings(get_currency_map(api_key = "invalid-key")),
    regexp = "401|CMC API error|request failed"
  )
})

test_that("get_ohlcv errors on multi-symbol input", {
  expect_error(
    get_ohlcv(c("BTC", "ETH"), api_key = "invalid-key"),
    regexp = "single token"
  )
})

test_that("get_price_performance_stats errors with no identifier", {
  expect_error(
    get_price_performance_stats(),
    regexp = "symbol.*id.*slug"
  )
})
