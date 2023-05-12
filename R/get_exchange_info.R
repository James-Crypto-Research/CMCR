get_exchange_info <- function(exchange_id = 2, api_key = Sys.getenv("CMC_API_KEY")){
  tmp <- list("path" = "/v1/exchange/info",
              "id" = exchange_id,
              "api_key" = api_key)
  x <- do.call(call_cmc_api, tmp)


  # We run this script in a loop since it is a paginated endpoint
  # The default is 10k entries. As long as the number of entries
  # returned is 10K we reset the offset and run the query again
  the_return <- NULL
  finished <- FALSE
  start <- 1
  while(!finished){
    tmp <- list("path" = "/v1/exchange/map",
                listing_status = "active,inactive",
                "api_key" = api_key,
                "start" = start)
    x <- do.call(call_cmc_api, tmp)
    # Below assumes we are only pulling USD quotes. This will break if
    # more quotes are used in conversion
    x <- x |>
      jsonlite::flatten() |> #flatten recursive JSON structures
      tibble::as_tibble() |>
      dplyr::select_all(~gsub("\\.","_",.)) #Replace . with _ in col names
    the_return <- the_return |> dplyr::bind_rows(x)
    finished <- nrow(x) < 10000
    if (!finished){
      start <- start + 10000
    }
  }
  # clean up the data a bit
  the_return <- the_return |> dplyr::mutate(
    first_historical_data = lubridate::ymd_hms(first_historical_data),
    last_historical_data = lubridate::ymd_hms(last_historical_data))
  return(the_return)
}
