test_that("package loads cleanly", {
  expect_true(isNamespaceLoaded("CMCR"))
})

test_that("all expected functions are exported", {
  exported <- getNamespaceExports("CMCR")
  expected <- c(
    "get_categories",
    "get_category",
    "get_crypto_info",
    "get_currency_map",
    "get_dex_networks",
    "get_dex_ohlcv",
    "get_dex_pairs",
    "get_exchange_info",
    "get_exchange_listings",
    "get_exchange_map",
    "get_fear_greed",
    "get_fiat_map",
    "get_global_metrics",
    "get_global_metrics_latest",
    "get_key_metrics",
    "get_listings",
    "get_listings_historical",
    "get_market_pairs",
    "get_ohlcv",
    "get_price_conversion",
    "get_price_performance_stats",
    "get_quotes_latest",
    "get_token_quote"
  )
  expect_true(all(expected %in% exported))
})
