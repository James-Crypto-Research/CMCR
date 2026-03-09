#' Get the latest DEX spot pairs
#'
#' Returns a list of decentralised exchange trading pairs with price, volume,
#' and liquidity data. Use \code{get_dex_networks()} to find valid
#' \code{network_id} values.
#'
#' @param network_id integer. Filter by blockchain network ID. Default NULL
#'   (all networks).
#' @param dex_id integer. Filter by a specific DEX ID. Default NULL.
#' @param start integer. Pagination offset. Default 1.
#' @param limit integer. Results per page (max 200). Default 100.
#' @param sort character. Sort field. Default \code{"volume_24h"}.
#' @param quote_currency character. Currency for price/volume values. Default
#'   \code{"USD"}.
#' @param auto_paginate logical. If TRUE, fetches all pages automatically.
#'   Default FALSE.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with one row per trading pair. Key columns include
#'   \code{pair_address}, \code{base_symbol}, \code{quote_symbol},
#'   \code{dex_name}, \code{network_name}, \code{price_usd},
#'   \code{volume_24h}, \code{liquidity_usd}, and \code{tx_count_24h}.
#'   \code{pair_address} is an on-chain contract address (hex string), not a
#'   CMC integer ID.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Top pairs on Ethereum (network_id = 1)
#'   networks <- get_dex_networks()
#'   x <- get_dex_pairs(network_id = 1)
#' }
get_dex_pairs <- function(network_id = NULL,
                           dex_id = NULL,
                           start = 1,
                           limit = 100,
                           sort = "volume_24h",
                           quote_currency = "USD",
                           auto_paginate = FALSE,
                           api_key = Sys.getenv("CMC_API_KEY")) {
  fetch_page <- function(s) {
    tmp <- list(
      "path"    = "/v4/dex/spot-pairs/latest",
      "start"   = s,
      "limit"   = limit,
      "sort"    = sort,
      "convert" = quote_currency,
      "api_key" = api_key
    )
    if (!is.null(network_id)) tmp[["network_id"]] <- network_id
    if (!is.null(dex_id))     tmp[["dex_id"]]     <- dex_id

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
