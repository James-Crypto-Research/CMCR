#' Get historical OHLCV data for a cryptocurrency
#'
#' Returns historical open/high/low/close/volume bars for a single token. This
#' is the primary input for technical analysis and backtesting workflows.
#'
#' @param symbol character. A single CMC token symbol, e.g. \code{"BTC"}.
#' @param time_start date, POSIXct, or ISO 8601 string. Start of the interval.
#'   Defaults to yesterday.
#' @param time_end date, POSIXct, or ISO 8601 string. End of the interval.
#'   Defaults to today.
#' @param interval character. Bar frequency. One of \code{"hourly"},
#'   \code{"daily"}, \code{"weekly"}, \code{"monthly"}, \code{"1h"},
#'   \code{"2h"}, \code{"4h"}, \code{"6h"}, \code{"12h"}, \code{"24h"},
#'   \code{"7d"}, \code{"30d"}, \code{"90d"}, \code{"365d"}.
#'   Default \code{"daily"}.
#' @param count integer. Number of intervals to return. Mutually exclusive with
#'   \code{time_start} and \code{time_end}.
#' @param quote_currency character. Currency for OHLCV values. Default
#'   \code{"USD"}.
#' @param as_date logical. If TRUE and \code{interval} is \code{"daily"} or
#'   \code{"24h"}, the \code{time_open} column is returned as a \code{Date}.
#'   Default TRUE.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per OHLCV bar. Columns: \code{time_open},
#'   \code{time_close}, \code{time_high}, \code{time_low}, \code{symbol},
#'   \code{open}, \code{high}, \code{low}, \code{close}, \code{volume},
#'   \code{market_cap}.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Last 30 days daily for Bitcoin
#'   x <- get_ohlcv("BTC", time_start = Sys.Date() - 30)
#'
#'   # Last 24 hourly bars
#'   x <- get_ohlcv("ETH", count = 24, interval = "1h")
#' }
get_ohlcv <- function(symbol,
                       time_start = NULL,
                       time_end = NULL,
                       interval = "daily",
                       count = NULL,
                       quote_currency = "USD",
                       as_date = TRUE,
                       api_key = Sys.getenv("CMC_API_KEY")) {
  if (length(symbol) != 1) {
    stop("'symbol' must be a single token. Use purrr::map_dfr() to fetch multiple tokens.")
  }
  if (!is.null(count) && (!is.null(time_start) || !is.null(time_end))) {
    stop("'count' and 'time_start'/'time_end' are mutually exclusive.")
  }

  if (is.null(time_start) && is.null(count)) time_start <- Sys.Date() - 1
  if (is.null(time_end) && is.null(count))   time_end   <- Sys.Date()

  tmp <- list(
    "path"     = "/v1/cryptocurrency/ohlcv/historical",
    "symbol"   = symbol,
    "interval" = interval,
    "convert"  = quote_currency,
    "api_key"  = api_key
  )
  if (!is.null(time_start)) tmp[["time_start"]] <- time_start
  if (!is.null(time_end))   tmp[["time_end"]]   <- time_end
  if (!is.null(count))      tmp[["count"]]      <- count

  x <- do.call(call_cmc_api, tmp)

  quotes <- x$quotes |>
    jsonlite::flatten() |>
    tibble::as_tibble() |>
    dplyr::rename_with(~gsub("\\.", "_", .x))

  # Rename quote currency columns to plain names
  qpfx <- paste0("quote_", quote_currency, "_")
  quotes <- quotes |>
    dplyr::rename_with(~sub(qpfx, "", .x), dplyr::starts_with(qpfx))

  quotes$symbol <- symbol

  time_cols <- c("time_open", "time_close", "time_high", "time_low")
  for (col in time_cols) {
    if (col %in% names(quotes)) {
      quotes[[col]] <- as.POSIXct(quotes[[col]], format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
    }
  }

  if (as_date && interval %in% c("daily", "24h") && "time_open" %in% names(quotes)) {
    quotes$time_open <- as.Date(quotes$time_open)
  }

  quotes |> dplyr::relocate(time_open, symbol)
}
