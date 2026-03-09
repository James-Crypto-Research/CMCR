#' Convert an amount from one currency to another
#'
#' Converts an amount from a source currency to a target currency using the
#' latest or a historical CMC price.
#'
#' @param amount numeric. The amount to convert.
#' @param symbol character. The source currency symbol, e.g. \code{"BTC"}.
#' @param quote_currency character. The target currency symbol. Default
#'   \code{"USD"}.
#' @param time date, POSIXct, or ISO 8601 string. Historical price point to use
#'   for conversion. If NULL (default), uses the latest price.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A single-row tibble with columns \code{id}, \code{name},
#'   \code{symbol}, \code{amount}, \code{last_updated}, \code{price}, and
#'   \code{quote_currency}.
#' @export
#'
#' @examples
#' \dontrun{
#'   # How many USD is 1.5 BTC worth right now?
#'   get_price_conversion(1.5, "BTC")
#'
#'   # Historical conversion
#'   get_price_conversion(1, "ETH", time = "2023-01-01")
#' }
get_price_conversion <- function(amount,
                                  symbol,
                                  quote_currency = "USD",
                                  time = NULL,
                                  api_key = Sys.getenv("CMC_API_KEY")) {
  tmp <- list(
    "path"    = "/v1/tools/price-conversion",
    "amount"  = amount,
    "symbol"  = symbol,
    "convert" = quote_currency,
    "api_key" = api_key
  )
  if (!is.null(time)) {
    tmp[["time"]] <- sanitize_date(time)
  }

  x <- do.call(call_cmc_api, tmp)

  quote_data <- x$quote[[quote_currency]]

  tibble::as_tibble(list(
    id             = x$id,
    name           = x$name,
    symbol         = x$symbol,
    amount         = x$amount,
    last_updated   = as.POSIXct(quote_data$last_updated,
                                format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC"),
    price          = quote_data$price,
    quote_currency = quote_currency
  ))
}
