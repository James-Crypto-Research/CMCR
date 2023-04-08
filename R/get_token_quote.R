#' This function gets the price and volume information of a given token
#'
#' This function takes the name of _one_ token and returns a time series
#' tibble of the price, 24h volume, marketcap, and supply of the token. The
#' data is at a daily level
#'
#' For the moment it only takes one token. But hopefully will fix this in
#' the next release
#'
#' @param token The official token symbol from CMC for the token
#' @param time_start What is the earliest date to retrieve
#' @param time_end What is the latest date to retrieve
#' @param interval The interval to retrieve
#' @param api_key The API key to use
#' @param as_date Should dates be returned instead ot a POSIXct for daily series
#'
#' @return A tibble containing the data
#' @export
#'
#' @examples
get_token_quote <- function(token = "BTC",time_start=NULL,time_end=NULL,
                               interval="daily",
                               api_key = Sys.getenv("CMC_API_KEY"),
                               as_date=TRUE){
  if (length(token) != 1) {
    error("Only one token can be grabbed at a time for the moment")
  }
  if (is.null(time_start)){
    time_start <- Sys.Date() -1
  }
  if (is.null(time_end)){
    time_end <- Sys.Date()
  }
  tmp <- list("path" = "v2/cryptocurrency/quotes/historical",
              "symbol" = token,
              "time_start" = time_start,
              "time_end" = time_end,
              "interval" = interval,
              "api_key" = api_key)
  x <- do.call(call_cmc_api, tmp)
  rm(tmp)
  # Below assumes we are only pulling USD quotes. This will break if
  # more quotes are used in conversion
  tmp <- x |> tibble::as_tibble() |> jsonlite::flatten()
  tmp <- tmp[[1]][[1]] |> jsonlite::flatten()
  # Now clean up the output a bit
  tmp <- tmp|> dplyr::select(timestamp,
                             quote.USD.price,
                             quote.USD.volume_24h,
                             quote.USD.market_cap,
                             quote.USD.circulating_supply,
                             quote.USD.total_supply)
  names(tmp) <- c("timestamp",
                  "price",
                  "volume",
                  "marketcap",
                  "circulating_supply",
                  "total_supply")
  tmp <- tmp |>  dplyr::mutate(token=token,
                               date = lubridate::ymd_hms(timestamp),
                               timestamp = NULL) |> dplyr::relocate(date,token)
  if (as_date & interval == "24h"){
    tmp$date <- as.Date(tmp$date)
  }
  tmp <- tibble::as_tibble(tmp)
  return(tmp)
}
