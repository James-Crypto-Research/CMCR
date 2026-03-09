#' Get cryptocurrency categories
#'
#' Returns information about all coin categories available on CoinMarketCap.
#' Categories group coins by theme or sector (e.g. DeFi, Layer 1, Gaming).
#' Use \code{get_category()} to fetch the coins within a specific category.
#'
#' @param start integer. Offset for pagination. Default 1.
#' @param limit integer. Number of results per page (max 5000). Default 100.
#' @param symbol character. Optional. Filter to categories that contain the
#'   given symbol(s). Accepts a character vector; multiple values are
#'   collapsed to a comma-separated string.
#' @param id character. Optional. Filter to categories that contain the given
#'   CMC coin ID(s). Accepts a character vector.
#' @param slug character. Optional. Filter to categories that contain the given
#'   coin slug(s). Accepts a character vector.
#' @param auto_paginate logical. If TRUE, fetches all pages automatically.
#'   Default FALSE.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per category. Key columns include \code{id},
#'   \code{name}, \code{title}, \code{description}, \code{num_tokens},
#'   \code{avg_price_change}, \code{market_cap}, \code{market_cap_change},
#'   \code{volume}, \code{volume_change}, \code{last_updated}.
#' @export
#'
#' @examples
#' \dontrun{
#'   # All categories
#'   x <- get_categories()
#'
#'   # Categories containing BTC
#'   x <- get_categories(symbol = "BTC")
#' }
get_categories <- function(start = 1,
                            limit = 100,
                            symbol = NULL,
                            id = NULL,
                            slug = NULL,
                            auto_paginate = FALSE,
                            api_key = Sys.getenv("CMC_API_KEY")) {
  fetch_page <- function(s) {
    tmp <- list(
      "path"    = "/v1/cryptocurrency/categories",
      "start"   = s,
      "limit"   = limit,
      "api_key" = api_key
    )
    if (!is.null(symbol)) tmp[["symbol"]] <- collapse_symbols(symbol)
    if (!is.null(id))     tmp[["id"]]     <- collapse_symbols(id)
    if (!is.null(slug))   tmp[["slug"]]   <- collapse_symbols(slug)

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

  if ("last_updated" %in% names(result)) {
    result$last_updated <- as.POSIXct(result$last_updated,
                                       format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
  }

  result
}


#' Get coins within a cryptocurrency category
#'
#' Returns the list of coins that belong to a specific CoinMarketCap category.
#' Use \code{get_categories()} to discover available category IDs.
#'
#' @param id character. The category ID (from \code{get_categories()}).
#'   Required.
#' @param start integer. Offset for pagination within the category coin list.
#'   Default 1.
#' @param limit integer. Number of coins to return (max 1000). Default 100.
#' @param quote_currency character. Currency for price conversion. Default
#'   \code{"USD"}.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per coin in the category. Columns follow the
#'   same structure as \code{get_listings()}: \code{id}, \code{name},
#'   \code{symbol}, \code{cmc_rank}, market data, and
#'   \code{quote_USD_*} price columns.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Find the DeFi category ID first
#'   cats <- get_categories()
#'   defi_id <- cats$id[cats$name == "DeFi"]
#'
#'   # Fetch coins in that category
#'   x <- get_category(defi_id)
#' }
get_category <- function(id,
                          start = 1,
                          limit = 100,
                          quote_currency = "USD",
                          api_key = Sys.getenv("CMC_API_KEY")) {
  tmp <- list(
    "path"    = "/v1/cryptocurrency/category",
    "id"      = id,
    "start"   = start,
    "limit"   = limit,
    "convert" = quote_currency,
    "api_key" = api_key
  )

  x <- do.call(call_cmc_api, tmp)

  coins <- x$coins |>
    jsonlite::flatten() |>
    tibble::as_tibble() |>
    dplyr::rename_with(~gsub("\\.", "_", .x))

  coins
}
