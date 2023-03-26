#' Return the map of all currencies in CMC
#'
#' This function returns the CMC ID Map for all the currencies. Specifically
#' it returns the metadata related to them (activity when called, start date
#'  end data and platform). Returns both active and inactive coins
#'
#'
#' @param api_key The API key. If not provided it looks in environmental variables
#'
#' @return Returns a tibble with the information
#' @export
#'
#' @examples
#' x <- get_currency_map()
get_currency_map <- function(api_key = Sys.getenv("CMC_API_KEY")){
  # We run this script in a loop since it is a paginated endpoint
  # The default is 10k entries. As long as the number of entries
  # returned is 10K we reset the offset and run the query again
  the_return <- NULL
  finished <- FALSE
  start <- 1
  while(!finished){
    tmp <- list(listing_status = "active,inactive",
                "api_key" = api_key,
                "start" = start)
    params <- do.call(make_params, tmp)
    x <- call_cmc_api(
      path = glue::glue("/v1/cryptocurrency/map"), params
    )
    # Below assumes we are only pulling USD quotes. This will break if
    # more quotes are used in conversion
    x <- x$data |>
      jsonlite::flatten() |> #flatten recursive JSON structures
      tibble::as_tibble() |>
      select_all(~gsub("\\.","_",.)) #Replace . with _ in col names
    the_return <- the_return |> dplyr::bind_rows(x)
    finished <- nrow(x) < 10000
    if (!finished){
      start <- start + 10000
    }
  }
  return(the_return)
}
