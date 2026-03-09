# CMCR — Claude Development Guide

## Package Overview

CMCR is an R package that wraps the [CoinMarketCap (CMC) Pro API](https://pro.coinmarketcap.com/api/v1). It provides tidy, tibble-based access to cryptocurrency market data.

## Architecture

### Core pattern
All public functions follow the same pattern:
1. Build a named `list()` with `"path"` and API parameters
2. Call `do.call(call_cmc_api, tmp)` to execute the request
3. Flatten/reshape the JSON response into a tibble

### Key infrastructure files
| File | Purpose |
|------|---------|
| `R/call_cmc_api.R` | Core HTTP function — all API calls go through here. Error check uses `parsed$status$error_code`. |
| `R/utils.R` | `make_params()` injects the API key + sanitises dates; `sanitize_date()` converts to Unix timestamps; `collapse_symbols()` joins character vectors with commas |

### Implemented endpoints

| File | Function | Endpoint | Plan tier |
|------|----------|----------|-----------|
| `R/get_key_metrics.R` | `get_key_metrics()` | `/v1/key/info` | Basic |
| `R/get_currency_map.R` | `get_currency_map()` | `/v1/cryptocurrency/map` | Basic |
| `R/get_fiat_map.R` | `get_fiat_map()` | `/v1/fiat/map` | Basic |
| `R/get_listings.R` | `get_listings()` | `/v1/cryptocurrency/listings/latest` | Basic |
| `R/get_quotes_latest.R` | `get_quotes_latest()` | `/v2/cryptocurrency/quotes/latest` | Basic |
| `R/get_token_quote.R` | `get_token_quote()` | `/v2/cryptocurrency/quotes/historical` | Basic |
| `R/get_crypto_info.R` | `get_crypto_info()` | `/v1/cryptocurrency/info` | Basic |
| `R/get_ohlcv.R` | `get_ohlcv()` | `/v1/cryptocurrency/ohlcv/historical` | Startup+ |
| `R/get_market_pairs.R` | `get_market_pairs()` | `/v1/cryptocurrency/market-pairs/latest` | Startup+ |
| `R/get_price_conversion.R` | `get_price_conversion()` | `/v1/tools/price-conversion` | Basic |
| `R/get_global_metrics.R` | `get_global_metrics()` | `/v1/global-metrics/quotes/historical` | Basic |
| `R/get_global_metrics_latest.R` | `get_global_metrics_latest()` | `/v1/global-metrics/quotes/latest` | Basic |
| `R/get_exchange_map.R` | `get_exchange_map()` | `/v1/exchange/map` | Basic |
| `R/get_exchange_info.R` | `get_exchange_info()` | `/v1/exchange/info` | Basic |
| `R/get_exchange_listings.R` | `get_exchange_listings()` | `/v1/exchange/listings/latest` | Startup+ |
| `R/get_fear_greed.R` | `get_fear_greed()` | `/v3/fear-and-greed/latest` + `/historical` | Standard+ |
| `R/get_dex_networks.R` | `get_dex_networks()` | `/v4/dex/networks/list` | Paid |
| `R/get_dex_pairs.R` | `get_dex_pairs()` | `/v4/dex/spot-pairs/latest` | Paid |
| `R/get_dex_ohlcv.R` | `get_dex_ohlcv()` | `/v4/dex/pairs/ohlcv/historical` | Paid |
| `R/get_categories.R` | `get_categories()` | `/v1/cryptocurrency/categories` | Basic |
| `R/get_categories.R` | `get_category()` | `/v1/cryptocurrency/category` | Basic |
| `R/get_listings_historical.R` | `get_listings_historical()` | `/v1/cryptocurrency/listings/historical` | Hobbyist+ |
| `R/get_price_performance_stats.R` | `get_price_performance_stats()` | `/v2/cryptocurrency/price-performance-stats/latest` | Standard+ |

## API Key

The API key is read from the `CMC_API_KEY` environment variable via `Sys.getenv("CMC_API_KEY")`. All public functions accept an explicit `api_key` argument to override it.

```r
Sys.setenv(CMC_API_KEY = "your-key-here")
```

The key is injected into every request by `make_params()` as `CMC_PRO_API_KEY` (the query parameter name required by the CoinMarketCap API).

## Dependencies

- `httr` — HTTP requests
- `jsonlite` — JSON parsing and flattening
- `tibble` — tidy output
- `dplyr` — data manipulation
- `tidyr` — reshaping
- `lubridate` — date/time handling
- `glue` — string interpolation
- `plyr` — `plyr::compact()` used in `make_params()`

## Conventions

### API parameters
- **Quote currency**: use `quote_currency = "USD"` as the R argument; pass it to the API as `"convert" = quote_currency` in the params list. Never name the R argument `convert` (conflicts with base R).
- **Multi-symbol inputs**: use `collapse_symbols(x)` from `utils.R` to join character vectors into a comma-separated string before adding to the params list.
- **Date parameters** (`time_start`, `time_end`): accept `Date`, `POSIXct`, `POSIXlt`, or ISO 8601 strings. `make_params()` automatically calls `sanitize_date()` to convert these to Unix timestamps. Use `sanitize_date()` explicitly for non-standard date param names (e.g. `time` in `get_price_conversion()`).

### Output
- **All functions return a tibble.**
- **Column names** use `snake_case`. Apply `dplyr::rename_with(~gsub("\\.", "_", .x))` after `jsonlite::flatten()` to convert dot-separated JSON paths to underscores (e.g. `quote.USD.price` → `quote_USD_price`).
- **Internal helpers** are marked `@noRd` and not exported. Public functions have `@export` and full roxygen2 docs.

### Pagination
- Paginated functions accept `auto_paginate = FALSE`. When `TRUE`, loop incrementing `start` by `limit` until a page returns fewer rows than `limit`.
- Legacy map functions (`get_currency_map`, `get_exchange_map`) use a fixed 10k batch size.

### Time series
- Time-series functions accept `as_date = TRUE`. When `TRUE` and `interval` is `"daily"` or `"24h"`, convert the date column from `POSIXct` to `Date`.

### API versioning
- `call_cmc_api()` builds the URL as `https://pro-api.coinmarketcap.com/` + `path`. The `path` argument carries the version prefix, so `/v3/...` and `/v4/...` paths work without any changes to the core function.

## Known Issues / TODOs

- `get_token_quote()` only supports a single token at a time (noted in the docstring).
- `NAMESPACE` uses `exportPattern("^[[:alpha:]]+")` — consider switching to explicit `@export` tags controlled by roxygen2 (`devtools::document()`).
- `get_crypto_info()` defines a `%||%` null-coalescing operator inline — move to `utils.R` if needed elsewhere.

## Verification

```r
# Regenerate NAMESPACE and man/ from roxygen2 tags
devtools::document()

# Run R CMD check
devtools::check()

# Load for interactive testing
devtools::load_all()
```
