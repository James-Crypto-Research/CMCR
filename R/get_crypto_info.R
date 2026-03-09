#' Get static metadata for one or more cryptocurrencies
#'
#' Returns static metadata including description, logo URL, website, social
#' links, contract addresses, tags, and category. Useful for data enrichment
#' and display layers.
#'
#' @param symbol character vector. One or more CMC token symbols, e.g.
#'   \code{c("BTC", "ETH")}. Either \code{symbol} or \code{id} must be
#'   provided. The API accepts up to 100 symbols per call; larger vectors are
#'   split automatically into batches of 100.
#' @param id integer vector. CMC cryptocurrency IDs as an alternative to
#'   \code{symbol}. Only one of \code{symbol} or \code{id} should be provided.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per token. Columns include \code{id},
#'   \code{name}, \code{symbol}, \code{slug}, \code{category},
#'   \code{description}, \code{logo}, \code{date_added}, \code{website},
#'   \code{whitepaper}, \code{twitter}, \code{reddit}. The \code{tags} and
#'   \code{contract_address} columns are list-columns.
#' @export
#'
#' @examples
#' \dontrun{
#'   x <- get_crypto_info("BTC")
#'   x <- get_crypto_info(c("BTC", "ETH", "SOL"))
#' }
get_crypto_info <- function(symbol = NULL,
                             id = NULL,
                             api_key = Sys.getenv("CMC_API_KEY")) {
  if (is.null(symbol) && is.null(id)) {
    stop("One of 'symbol' or 'id' must be provided")
  }
  if (!is.null(symbol) && !is.null(id)) {
    stop("Provide only one of 'symbol' or 'id', not both")
  }

  # Split into batches of 100 (API limit)
  items <- if (!is.null(symbol)) symbol else as.character(id)
  batches <- split(items, ceiling(seq_along(items) / 100))

  fetch_batch <- function(batch) {
    tmp <- list(
      "path"    = "/v1/cryptocurrency/info",
      "api_key" = api_key
    )
    if (!is.null(symbol)) {
      tmp[["symbol"]] <- collapse_symbols(batch)
    } else {
      tmp[["id"]] <- collapse_symbols(batch)
    }
    x <- do.call(call_cmc_api, tmp)

    dplyr::bind_rows(lapply(x, function(coin) {
      tibble::as_tibble(list(
        id               = coin$id,
        name             = coin$name,
        symbol           = coin$symbol,
        slug             = coin$slug,
        category         = coin$category %||% NA_character_,
        description      = coin$description %||% NA_character_,
        logo             = coin$logo %||% NA_character_,
        date_added       = as.Date(coin$date_added),
        website          = (coin$urls$website %||% NA_character_)[[1]],
        whitepaper       = (coin$urls$technical_doc %||% NA_character_)[[1]],
        twitter          = (coin$urls$twitter %||% NA_character_)[[1]],
        reddit           = (coin$urls$reddit %||% NA_character_)[[1]],
        tags             = list(unlist(coin$tags)),
        contract_address = list(coin$contract_address)
      ))
    }))
  }

  dplyr::bind_rows(lapply(batches, fetch_batch))
}

# Null-coalescing operator (internal)
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x
