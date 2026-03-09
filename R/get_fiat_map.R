#' Get the CMC fiat currency map
#'
#' Returns a reference table of all fiat currencies supported by CMC. Useful
#' for discovering valid values for the \code{quote_currency} parameter across
#' other functions.
#'
#' @param include_metals logical. If TRUE, precious metals (XAU, XAG, etc.) are
#'   included. Default FALSE.
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with columns \code{id}, \code{name}, \code{sign}, and
#'   \code{symbol}.
#' @export
#'
#' @examples
#' \dontrun{
#'   x <- get_fiat_map()
#'   x <- get_fiat_map(include_metals = TRUE)
#' }
get_fiat_map <- function(include_metals = FALSE,
                          api_key = Sys.getenv("CMC_API_KEY")) {
  tmp <- list(
    "path"           = "/v1/fiat/map",
    "include_metals" = tolower(as.character(include_metals)),
    "api_key"        = api_key
  )
  x <- do.call(call_cmc_api, tmp)

  dplyr::bind_rows(x) |>
    tibble::as_tibble() |>
    dplyr::select(dplyr::any_of(c("id", "name", "sign", "symbol")))
}
