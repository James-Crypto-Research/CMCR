#' Get the CMC Fear & Greed Index
#'
#' Returns the CMC Fear & Greed Index, either the latest value or a historical
#' time series.
#'
#' @param historical logical. If FALSE (default), returns only the current
#'   index value. If TRUE, returns a historical time series.
#' @param time_start date, POSIXct, or ISO 8601 string. Start of the historical
#'   range. Only used when \code{historical = TRUE}.
#' @param time_end date, POSIXct, or ISO 8601 string. End of the historical
#'   range. Only used when \code{historical = TRUE}.
#' @param limit integer. Number of historical data points to return. Only used
#'   when \code{historical = TRUE}. Default NULL (API default applies).
#' @param api_key character. CMC Pro API key. Defaults to the
#'   \code{CMC_API_KEY} environment variable.
#'
#' @return A tibble with columns \code{value} (integer, 0--100),
#'   \code{value_classification} (character: \code{"Extreme Fear"},
#'   \code{"Fear"}, \code{"Neutral"}, \code{"Greed"}, \code{"Extreme Greed"}),
#'   and \code{update_time} (POSIXct). Historical calls also include a
#'   \code{date} column.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Current index
#'   x <- get_fear_greed()
#'
#'   # Historical series
#'   x <- get_fear_greed(historical = TRUE, time_start = "2024-01-01")
#' }
get_fear_greed <- function(historical = FALSE,
                            time_start = NULL,
                            time_end = NULL,
                            limit = NULL,
                            api_key = Sys.getenv("CMC_API_KEY")) {
  if (historical) {
    tmp <- list(
      "path"    = "/v3/fear-and-greed/historical",
      "api_key" = api_key
    )
    if (!is.null(time_start)) tmp[["time_start"]] <- time_start
    if (!is.null(time_end))   tmp[["time_end"]]   <- time_end
    if (!is.null(limit))      tmp[["limit"]]      <- limit

    x <- do.call(call_cmc_api, tmp)

    dplyr::bind_rows(lapply(x, function(item) {
      tibble::as_tibble(list(
        date                 = as.Date(item$timestamp),
        value                = as.integer(item$value),
        value_classification = item$value_classification,
        update_time          = as.POSIXct(item$update_time,
                                          format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      ))
    }))
  } else {
    tmp <- list(
      "path"    = "/v3/fear-and-greed/latest",
      "api_key" = api_key
    )
    x <- do.call(call_cmc_api, tmp)

    tibble::as_tibble(list(
      value                = as.integer(x$value),
      value_classification = x$value_classification,
      update_time          = as.POSIXct(x$update_time,
                                        format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
    ))
  }
}
