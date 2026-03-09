#' Get the latest global cryptocurrency market metrics
#'
#' Returns a snapshot of the current global market state: total market cap,
#' 24h volume, BTC and ETH dominance, and active counts. Complements the
#' historical \code{get_global_metrics()}.
#'
#' @param quote_currency character. Currency for market cap and volume values.
#'   Default \code{"USD"}.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A single-row tibble with columns \code{btc_dominance},
#'   \code{eth_dominance}, \code{active_cryptocurrencies},
#'   \code{active_exchanges}, \code{active_market_pairs},
#'   \code{total_market_cap}, \code{total_volume_24h},
#'   \code{altcoin_market_cap}, \code{altcoin_volume_24h}, and
#'   \code{last_updated}.
#' @export
#'
#' @examples
#' \dontrun{
#'   x <- get_global_metrics_latest()
#' }
get_global_metrics_latest <- function(quote_currency = "USD",
                                       api_key = Sys.getenv("CMC_API_KEY")) {
  tmp <- list(
    "path"    = "/v1/global-metrics/quotes/latest",
    "convert" = quote_currency,
    "api_key" = api_key
  )
  x <- do.call(call_cmc_api, tmp)

  tibble::as_tibble(list(
    btc_dominance           = x$btc_dominance,
    eth_dominance           = x$eth_dominance,
    active_cryptocurrencies = x$active_cryptocurrencies,
    active_exchanges        = x$active_exchanges,
    active_market_pairs     = x$active_market_pairs,
    total_market_cap        = x$quote[[quote_currency]]$total_market_cap,
    total_volume_24h        = x$quote[[quote_currency]]$total_volume_24h,
    altcoin_market_cap      = x$quote[[quote_currency]]$altcoin_market_cap,
    altcoin_volume_24h      = x$quote[[quote_currency]]$altcoin_volume_24h,
    last_updated            = as.POSIXct(x$quote[[quote_currency]]$last_updated,
                                         format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
  ))
}
