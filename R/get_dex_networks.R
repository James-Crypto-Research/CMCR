#' Get the list of DEX networks supported by CMC
#'
#' Returns a reference table of all blockchain networks available through the
#' CMC v4 DEX API. Use the returned \code{id} values as the
#' \code{network_id} parameter in \code{get_dex_pairs()} and
#' \code{get_dex_ohlcv()}.
#'
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with columns \code{id}, \code{name}, and \code{slug}.
#' @export
#'
#' @examples
#' \dontrun{
#'   networks <- get_dex_networks()
#' }
get_dex_networks <- function(api_key = Sys.getenv("CMC_API_KEY")) {
  tmp <- list(
    "path"    = "/v4/dex/networks/list",
    "api_key" = api_key
  )
  x <- do.call(call_cmc_api, tmp)

  dplyr::bind_rows(x) |>
    tibble::as_tibble() |>
    dplyr::select(dplyr::any_of(c("id", "name", "slug")))
}
