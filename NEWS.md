# CMCR 0.2.0

## New endpoints
- `get_listings()` — latest cryptocurrency listings with pagination
- `get_quotes_latest()` — real-time quotes for one or more symbols
- `get_crypto_info()` — metadata for one or more cryptocurrencies
- `get_fiat_map()` — fiat currency reference data
- `get_ohlcv()` — historical OHLCV bars
- `get_market_pairs()` — active trading pairs for a cryptocurrency
- `get_price_conversion()` — convert an amount between currencies
- `get_global_metrics()` — historical global market metrics
- `get_global_metrics_latest()` — latest global market metrics
- `get_exchange_map()` — CMC exchange ID map
- `get_exchange_info()` — exchange metadata
- `get_exchange_listings()` — ranked exchange listings
- `get_fear_greed()` — fear and greed index (latest and historical)
- `get_dex_networks()` — DEX network list (v4 API)
- `get_dex_pairs()` — DEX spot pairs (v4 API)
- `get_dex_ohlcv()` — DEX historical OHLCV (v4 API)
- `get_categories()` — cryptocurrency category list
- `get_category()` — coins within a specific category
- `get_listings_historical()` — historical ranked listings snapshot
- `get_price_performance_stats()` — multi-period price performance statistics

## Improvements
- All functions return tidy tibbles with `snake_case` column names
- Consistent `api_key` argument across all functions (reads from `CMC_API_KEY` env var)
- `auto_paginate` support for paginated endpoints
- `as_date` support for daily time-series endpoints
- `quote_currency` argument replaces `convert` to avoid conflict with base R

## Bug fixes
- Fixed `call_cmc_api()` error detection to use `parsed$status$error_code`
- Fixed `error()` → `stop()` in `get_token_quote()`
- Fixed missing leading `/` in `get_token_quote()` API path

# CMCR 0.1.0

- Initial release with `get_currency_map()`, `get_key_metrics()`, and `get_token_quote()`
