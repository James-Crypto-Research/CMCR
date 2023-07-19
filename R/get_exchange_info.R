#' Retrieve the information about a given exchange
#'
#' this function extracts the description, start data, number of weekly visits
#' and what fiats it accepts. The last two are at the point in time when the
#' function is called and are not historic.
#'
#'
#' @param exchange_id The exchange ID as returned by the get_exchange_map function
#' @param api_key The api key. If not provided it will check if it is an
#' environmental variable.
#'
#' @return A row tibble contianing the information. This allows for the use of
#' map_dfr function to iterate over many exchanges
#' @export
#'
#' @examples
#'
get_exchange_info <- function(exchange_id = 2, api_key = Sys.getenv("CMC_API_KEY")){
  tmp <- list("path" = "/v1/exchange/info",
              "id" = exchange_id,
              "api_key" = api_key)
  x <- do.call(call_cmc_api, tmp)
  rep_val <- \(x) ifelse(is.null(x),"NA",x)
  rep_valn <- \(x) ifelse(is.null(x),NA,x)
  if (length(x[[1]]$fiats) >0) {
    fiats <- list(x[[1]]$fiats)
  } else {
    fiats <- list(NA)
  }
  the_return <- tibble::as_tibble(list("id" = x[[1]]$id,
                               "name" = x[[1]]$name,
                               "desc" = rep_val(x[[1]]$description),
                                "launch_date" = rep_val(x[[1]]$date_launched),
                                "weekly_visits" = rep_valn(x[[1]]$weekly_visits),
                                "spot_volume_usd" = rep_valn(x[[1]]$spot_volume_usd),
                                "fiats" = fiats))

  return(the_return)
}
