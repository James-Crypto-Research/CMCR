#' Get the latest exchange listings
#'
#' Returns a ranked list of all active exchanges with aggregate volume and
#' market pair counts. The exchange-side equivalent of \code{get_listings()}.
#'
#' @param start integer. Pagination offset. Default 1.
#' @param limit integer. Results per page (max 5000). Default 100.
#' @param sort character. Sort field. One of \code{"volume_24h"},
#'   \code{"num_market_pairs"}, \code{"exchange_score"}. Default
#'   \code{"volume_24h"}.
#' @param sort_dir character. \code{"asc"} or \code{"desc"}. Default
#'   \code{"desc"}.
#' @param market_type character. Exchange type filter. One of \code{"all"},
#'   \code{"fees"}, \code{"no_fees"}, \code{"percent"},
#'   \code{"transactional_mining"}. Default \code{"all"}.
#' @param quote_currency character. Currency for volume values. Default
#'   \code{"USD"}.
#' @param auto_paginate logical. If TRUE, fetches all pages automatically.
#'   Default FALSE.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per exchange. Key columns include \code{id},
#'   \code{name}, \code{slug}, \code{num_market_pairs}, \code{visits},
#'   \code{volume_24h}, \code{volume_7d}, \code{volume_30d}, and
#'   \code{last_updated}. The \code{fiats} column is a list-column.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Top 100 exchanges by volume
#'   x <- get_exchange_listings()
#' }
get_exchange_listings <- function(start = 1,
                                   limit = 100,
                                   sort = "volume_24h",
                                   sort_dir = "desc",
                                   market_type = "all",
                                   quote_currency = "USD",
                                   auto_paginate = FALSE,
                                   api_key = Sys.getenv("CMC_API_KEY")) {
  fetch_page <- function(s) {
    tmp <- list(
      "path"        = "/v1/exchange/listings/latest",
      "start"       = s,
      "limit"       = limit,
      "sort"        = sort,
      "sort_dir"    = sort_dir,
      "market_type" = market_type,
      "convert"     = quote_currency,
      "api_key"     = api_key
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

  result
}
