#' Get historical OHLCV data for a DEX trading pair
#'
#' Returns historical OHLCV bars for a specific on-chain trading pair. Use
#' \code{get_dex_pairs()} to find valid \code{pair_address} and
#' \code{network_id} values.
#'
#' @param pair_address character. The on-chain contract address of the trading
#'   pair (hex string). Obtain from \code{get_dex_pairs()}.
#' @param network_id integer. The blockchain network ID. Obtain from
#'   \code{get_dex_networks()}.
#' @param time_start date, POSIXct, or ISO 8601 string. Start of the interval.
#'   Default 7 days ago.
#' @param time_end date, POSIXct, or ISO 8601 string. End of the interval.
#'   Default today.
#' @param interval character. Bar frequency. One of \code{"1m"}, \code{"5m"},
#'   \code{"15m"}, \code{"30m"}, \code{"1h"}, \code{"4h"}, \code{"daily"},
#'   \code{"weekly"}. Default \code{"daily"}.
#' @param quote_currency character. Currency for OHLCV values. Default
#'   \code{"USD"}.
#' @param as_date logical. If TRUE and \code{interval} is \code{"daily"}, the
#'   \code{time_open} column is returned as a \code{Date}. Default TRUE.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per OHLCV bar. Columns: \code{time_open},
#'   \code{pair_address}, \code{network_id}, \code{open}, \code{high},
#'   \code{low}, \code{close}, \code{volume}.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Daily bars for a Uniswap v3 WETH/USDC pair on Ethereum
#'   x <- get_dex_ohlcv(
#'     pair_address = "0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640",
#'     network_id   = 1
#'   )
#' }
get_dex_ohlcv <- function(pair_address,
                           network_id,
                           time_start = Sys.Date() - 7,
                           time_end   = Sys.Date(),
                           interval   = "daily",
                           quote_currency = "USD",
                           as_date    = TRUE,
                           api_key    = Sys.getenv("CMC_API_KEY")) {
  tmp <- list(
    "path"         = "/v4/dex/pairs/ohlcv/historical",
    "pair_address" = pair_address,
    "network_id"   = network_id,
    "time_start"   = time_start,
    "time_end"     = time_end,
    "interval"     = interval,
    "convert"      = quote_currency,
    "api_key"      = api_key
  )

  x <- do.call(call_cmc_api, tmp)

  result <- x |>
    jsonlite::flatten() |>
    tibble::as_tibble() |>
    dplyr::rename_with(~gsub("\\.", "_", .x))

  # Strip quote currency prefix from OHLCV columns
  qpfx <- paste0("quote_", quote_currency, "_")
  result <- result |>
    dplyr::rename_with(~sub(qpfx, "", .x), dplyr::starts_with(qpfx))

  result$pair_address <- pair_address
  result$network_id   <- network_id

  if ("time_open" %in% names(result)) {
    result$time_open <- as.POSIXct(result$time_open,
                                   format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
    if (as_date && interval == "daily") {
      result$time_open <- as.Date(result$time_open)
    }
  }

  result |> dplyr::relocate(time_open, pair_address, network_id)
}
