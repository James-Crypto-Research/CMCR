#' Get the latest price quotes for one or more cryptocurrencies
#'
#' Returns a point-in-time price snapshot for one or more tokens. This is the
#' most credit-efficient way to retrieve current prices for a watchlist.
#' Complements the historical \code{get_token_quote()}.
#'
#' @param symbol character vector. One or more CMC token symbols, e.g.
#'   \code{c("BTC", "ETH")}. Either \code{symbol} or \code{id} must be
#'   provided.
#' @param id integer vector. CMC cryptocurrency IDs as an alternative to
#'   \code{symbol}. Only one of \code{symbol} or \code{id} should be provided.
#' @param quote_currency character. Currency for price conversion. Default
#'   \code{"USD"}.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per requested symbol. Key columns include
#'   \code{id}, \code{name}, \code{symbol}, \code{slug}, \code{cmc_rank},
#'   \code{circulating_supply}, \code{total_supply}, \code{max_supply},
#'   and price/volume columns prefixed with \code{quote_USD_}.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Single token
#'   x <- get_quotes_latest("BTC")
#'
#'   # Multiple tokens
#'   x <- get_quotes_latest(c("BTC", "ETH", "SOL"))
#' }
get_quotes_latest <- function(symbol = NULL,
                               id = NULL,
                               quote_currency = "USD",
                               api_key = Sys.getenv("CMC_API_KEY")) {
  if (is.null(symbol) && is.null(id)) {
    stop("One of 'symbol' or 'id' must be provided")
  }
  if (!is.null(symbol) && !is.null(id)) {
    stop("Provide only one of 'symbol' or 'id', not both")
  }

  tmp <- list(
    "path"    = "/v2/cryptocurrency/quotes/latest",
    "convert" = quote_currency,
    "api_key" = api_key
  )
  if (!is.null(symbol)) tmp[["symbol"]] <- collapse_symbols(symbol)
  if (!is.null(id))     tmp[["id"]]     <- collapse_symbols(as.character(id))

  x <- do.call(call_cmc_api, tmp)

  # x is a named list keyed by symbol/id; each value may be a list of matches.
  # Extract the first match for each key and bind into a tibble.
  result <- dplyr::bind_rows(lapply(x, function(item) {
    if (is.data.frame(item)) {
      item[1, ]
    } else if (is.list(item) && length(item) > 0) {
      as.data.frame(item[[1]])
    } else {
      NULL
    }
  })) |>
    jsonlite::flatten() |>
    tibble::as_tibble() |>
    dplyr::rename_with(~gsub("\\.", "_", .x))

  result
}
