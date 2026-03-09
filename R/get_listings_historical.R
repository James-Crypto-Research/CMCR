#' Get a historical snapshot of cryptocurrency listings
#'
#' Returns a ranked snapshot of all active cryptocurrencies and their market
#' data at a specific point in time. Useful for reconstructing historical
#' rankings and market-cap league tables.
#'
#' Requires a Hobbyist or higher CMC Pro plan.
#'
#' @param date date, POSIXct, or ISO 8601 string. The historical date for the
#'   snapshot. Required.
#' @param start integer. Rank offset for pagination. Default 1.
#' @param limit integer. Number of results per page (max 5000). Default 100.
#' @param sort character. Sort field. One of \code{"cmc_rank"},
#'   \code{"name"}, \code{"symbol"}, \code{"market_cap"}, \code{"price"},
#'   \code{"circulating_supply"}, \code{"total_supply"},
#'   \code{"percent_change_24h"}. Default \code{"cmc_rank"}.
#' @param sort_dir character. \code{"asc"} or \code{"desc"}. Default
#'   \code{"desc"}.
#' @param cryptocurrency_type character. \code{"all"}, \code{"coins"}, or
#'   \code{"tokens"}. Default \code{"all"}.
#' @param quote_currency character. Currency for price conversion. Default
#'   \code{"USD"}.
#' @param auto_paginate logical. If TRUE, fetches all pages automatically.
#'   Default FALSE.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per cryptocurrency at the requested date.
#'   Columns mirror \code{get_listings()}: \code{id}, \code{name},
#'   \code{symbol}, \code{cmc_rank}, supply columns, and
#'   \code{quote_USD_*} price columns.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Top 100 by rank on 1 Jan 2022
#'   x <- get_listings_historical("2022-01-01")
#'
#'   # All coins on a date (auto-paginate)
#'   x <- get_listings_historical("2021-01-01", limit = 5000,
#'                                 auto_paginate = TRUE)
#' }
get_listings_historical <- function(date,
                                     start = 1,
                                     limit = 100,
                                     sort = "cmc_rank",
                                     sort_dir = "desc",
                                     cryptocurrency_type = "all",
                                     quote_currency = "USD",
                                     auto_paginate = FALSE,
                                     api_key = Sys.getenv("CMC_API_KEY")) {
  date_unix <- sanitize_date(date)

  fetch_page <- function(s) {
    tmp <- list(
      "path"                = "/v1/cryptocurrency/listings/historical",
      "date"                = date_unix,
      "start"               = s,
      "limit"               = limit,
      "sort"                = sort,
      "sort_dir"            = sort_dir,
      "cryptocurrency_type" = cryptocurrency_type,
      "convert"             = quote_currency,
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
