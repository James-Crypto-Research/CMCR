#' Get the global metrics for the universe of assets
#'
#' @param time_start The start of the interval to grab (defaults to today)
#' @param time_end The end of the interval to grab (defaults to today)
#' @param interval The frequency to grab (defaults to daily)
#' @param api_key The API key. If not provided it looks in environmental variables
#' @param as_date logical. Convert returned time stamps to dates?
#'
#' @return Returns a tibble with the information
#' @export
#'
#' @examples
#' x <- get_global_metrics()
get_global_metrics <- function(time_start=NULL,time_end=NULL,
                          interval="daily",
                          api_key = Sys.getenv("CMC_API_KEY"),
                          as_date=TRUE){
  if (is.null(time_start)){
    time_start <- Sys.Date() -1
  }
  if (is.null(time_end)){
    time_end <- Sys.Date()
  }
  tmp <- list("time_start" = time_start,
              "time_end" = time_end,
              "interval" = interval,
              "api_key" = api_key)
  params <- do.call(make_params, tmp)
  x <- call_cmc_api(
    path = glue::glue("/v1/global-metrics/quotes/historical"), params
  )
  # Below assumes we are only pulling USD quotes. This will break if
  # more quotes are used in conversion
  x <- x$data$quotes |> tibble::as_tibble() |>
    jsonlite::flatten() |>
    dplyr::mutate(date=as.POSIXct(timestamp,origin="1970-01-01 00:00:00",
                                  tz="UTC"))
  if (as_date & interval == "24h"){
    x$date <- as.Date(x$date)
  }
  # Now clean up the output a bit
  x <- x |> dplyr::select(date,btc_dominance,eth_dominance,
                   active_cryptocurrencies,active_exchanges,active_market_pairs,
                   quote.USD.total_market_cap,quote.USD.total_volume_24h,
                   quote.USD.total_volume_24h_reported,
                   quote.USD.altcoin_market_cap,quote.USD.altcoin_volume_24h,
                   quote.USD.altcoin_volume_24h_reported)
  names(x) <- c("date","btc_dominance","eth_dominance",
                "active_cryptocurrencies", "active_exchanges",
                "active_market_pairs", "total_market_cap", "total_volume_24h",
                "total_volume_24h_reported", "altcoin_market_cap",
                "altcoin_volume_24h", "altcoin_volume_24h_reported")

  return(x)
}
