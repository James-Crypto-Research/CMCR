#' Get the latest cryptocurrency listings
#'
#' Returns a ranked list of all active cryptocurrencies with the latest market
#' data. This is the primary market screener endpoint.
#'
#' @param start integer. Rank offset for pagination. Default 1.
#' @param limit integer. Number of results per page (max 5000). Default 100.
#' @param sort character. Sort field. One of \code{"market_cap"}, \code{"name"},
#'   \code{"symbol"}, \code{"price"}, \code{"circulating_supply"},
#'   \code{"total_supply"}, \code{"24h_volume"}, \code{"percent_change_1h"},
#'   \code{"percent_change_24h"}, \code{"percent_change_7d"}. Default
#'   \code{"market_cap"}.
#' @param sort_dir character. \code{"asc"} or \code{"desc"}. Default
#'   \code{"desc"}.
#' @param cryptocurrency_type character. \code{"all"}, \code{"coins"}, or
#'   \code{"tokens"}. Default \code{"all"}.
#' @param quote_currency character. Currency for price conversion. Default
#'   \code{"USD"}.
#' @param market_cap_min numeric. Minimum market cap filter. Default NULL.
#' @param market_cap_max numeric. Maximum market cap filter. Default NULL.
#' @param auto_paginate logical. If TRUE, fetches all pages automatically by
#'   incrementing \code{start}. Default FALSE. Note: may consume many API
#'   credits.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per cryptocurrency. Key columns include
#'   \code{id}, \code{name}, \code{symbol}, \code{cmc_rank},
#'   \code{circulating_supply}, \code{total_supply}, \code{max_supply},
#'   \code{date_added}, \code{quote_USD_price}, \code{quote_USD_volume_24h},
#'   \code{quote_USD_market_cap}, \code{quote_USD_percent_change_1h},
#'   \code{quote_USD_percent_change_24h}, \code{quote_USD_percent_change_7d}.
#'   The \code{tags} column is a list-column of character vectors.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Top 100 by market cap
#'   x <- get_listings()
#'
#'   # Top 500 tokens only
#'   x <- get_listings(limit = 500, cryptocurrency_type = "tokens")
#'
#'   # Full market (all pages)
#'   x <- get_listings(limit = 5000, auto_paginate = TRUE)
#' }
get_listings <- function(start = 1,
                          limit = 100,
                          sort = "market_cap",
                          sort_dir = "desc",
                          cryptocurrency_type = "all",
                          quote_currency = "USD",
                          market_cap_min = NULL,
                          market_cap_max = NULL,
                          auto_paginate = FALSE,
                          api_key = Sys.getenv("CMC_API_KEY")) {
  fetch_page <- function(s) {
    tmp <- list(
      "path"                = "/v1/cryptocurrency/listings/latest",
      "start"               = s,
      "limit"               = limit,
      "sort"                = sort,
      "sort_dir"            = sort_dir,
      "cryptocurrency_type" = cryptocurrency_type,
      "convert"             = quote_currency,
      "market_cap_min"      = market_cap_min,
      "market_cap_max"      = market_cap_max,
      "api_key"             = api_key
    )
    do.call(call_cmc_api, tmp) |>
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

  if ("date_added" %in% names(result)) {
    result$date_added <- as.Date(result$date_added)
  }

  result
}
