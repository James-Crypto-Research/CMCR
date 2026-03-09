#' Get the latest market pairs for a cryptocurrency
#'
#' Returns all active trading pairs for a token across all exchanges, with
#' price and volume data. Useful for liquidity analysis and price discrepancy
#' detection.
#'
#' @param symbol character. A single CMC token symbol, e.g. \code{"BTC"}.
#' @param start integer. Pagination offset. Default 1.
#' @param limit integer. Results per page (max 200). Default 100.
#' @param quote_currency character. Currency for price and volume values.
#'   Default \code{"USD"}.
#' @param category character. Market type filter. One of \code{"all"},
#'   \code{"spot"}, \code{"derivatives"}, \code{"otc"}, \code{"futures"},
#'   \code{"perpetual"}. Default \code{"all"}.
#' @param auto_paginate logical. If TRUE, fetches all pages automatically.
#'   Default FALSE.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per market pair. Key columns include
#'   \code{exchange_id}, \code{exchange_name}, \code{pair}, \code{category},
#'   \code{price}, \code{volume_24h}, and \code{last_updated}.
#' @export
#'
#' @examples
#' \dontrun{
#'   # All spot pairs for Bitcoin
#'   x <- get_market_pairs("BTC", category = "spot")
#' }
get_market_pairs <- function(symbol,
                              start = 1,
                              limit = 100,
                              quote_currency = "USD",
                              category = "all",
                              auto_paginate = FALSE,
                              api_key = Sys.getenv("CMC_API_KEY")) {
  fetch_page <- function(s) {
    tmp <- list(
      "path"     = "/v1/cryptocurrency/market-pairs/latest",
      "symbol"   = symbol,
      "start"    = s,
      "limit"    = limit,
      "convert"  = quote_currency,
      "category" = category,
      "api_key"  = api_key
    )
    x <- do.call(call_cmc_api, tmp)
    x$market_pairs |>
      jsonlite::flatten() |>
      tibble::as_tibble() |>
      dplyr::rename_with(~gsub("\\.", "_", .x))
  }

  result <- fetch_page(start)

  if (auto_paginate) {
    current_start <- start
    while (nrow(result) > 0) {
      current_start <- current_start + limit
      page <- fetch_page(current_start)
      result <- dplyr::bind_rows(result, page)
      if (nrow(page) < limit) break
    }
  }

  result
}
