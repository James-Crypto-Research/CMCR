#' Get price performance statistics for cryptocurrencies
#'
#' Returns price performance statistics across multiple time periods (1h, 24h,
#' 7d, 30d, 60d, 90d, YTD, 1y, all_time) for one or more cryptocurrencies.
#' Useful for momentum screening and relative performance analysis.
#'
#' Requires a Standard or higher CMC Pro plan.
#'
#' @param symbol character. One or more token symbols, e.g. \code{"BTC"} or
#'   \code{c("BTC", "ETH")}. Required unless \code{id} or \code{slug} is
#'   provided.
#' @param id character. One or more CMC coin IDs. Alternative to
#'   \code{symbol}.
#' @param slug character. One or more coin slugs. Alternative to
#'   \code{symbol}.
#' @param time_period character. One of \code{"all_time"},
#'   \code{"yesterday"}, \code{"24h"}, \code{"7d"}, \code{"30d"},
#'   \code{"90d"}, \code{"365d"}, or \code{"ytd"}. Default \code{"all_time"}.
#'   Controls which performance window is included in the response.
#' @param quote_currency character. Currency for price conversion. Default
#'   \code{"USD"}.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per requested cryptocurrency. Columns include
#'   \code{id}, \code{name}, \code{symbol}, \code{slug}, and nested
#'   performance columns of the form
#'   \code{periods_<period>_quote_USD_*} for open, close, and
#'   percent change values over the requested window.
#' @export
#'
#' @examples
#' \dontrun{
#'   # 30-day performance for BTC and ETH
#'   x <- get_price_performance_stats(c("BTC", "ETH"), time_period = "30d")
#'
#'   # All-time stats for a single coin
#'   x <- get_price_performance_stats("SOL", time_period = "all_time")
#' }
get_price_performance_stats <- function(symbol = NULL,
                                         id = NULL,
                                         slug = NULL,
                                         time_period = "all_time",
                                         quote_currency = "USD",
                                         api_key = Sys.getenv("CMC_API_KEY")) {
  if (is.null(symbol) && is.null(id) && is.null(slug)) {
    stop("One of 'symbol', 'id', or 'slug' must be provided.")
  }

  tmp <- list(
    "path"        = "/v2/cryptocurrency/price-performance-stats/latest",
    "time_period" = time_period,
    "convert"     = quote_currency,
    "api_key"     = api_key
  )
  if (!is.null(symbol)) tmp[["symbol"]] <- collapse_symbols(symbol)
  if (!is.null(id))     tmp[["id"]]     <- collapse_symbols(id)
  if (!is.null(slug))   tmp[["slug"]]   <- collapse_symbols(slug)

  x <- do.call(call_cmc_api, tmp)

  # Response is a named list keyed by symbol; bind rows across all entries
  result <- lapply(x, function(entry) {
    # Each symbol may return multiple matches; take the first
    item <- if (is.data.frame(entry)) entry[1, , drop = FALSE] else entry[[1]]
    jsonlite::flatten(as.data.frame(item, stringsAsFactors = FALSE)) |>
      tibble::as_tibble()
  }) |>
    dplyr::bind_rows() |>
    dplyr::rename_with(~gsub("\\.", "_", .x))

  result
}
