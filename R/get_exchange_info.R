get_exchange_info <- function(exchange_id = 2, api_key = Sys.getenv("CMC_API_KEY")){
  tmp <- list("path" = "/v1/exchange/info",
              "id" = exchange_id,
              "api_key" = api_key)
  x <- do.call(call_cmc_api, tmp)
  rep_val <- \(x) ifelse(is.null(x),"NA",x)
  rep_valn <- \(x) ifelse(is.null(x),NA,x)
  rep_vall <- \(x) ifelse(is.null(x),list(NA),x)
  the_return <- tibble::as_tibble(list("id" = x[[1]]$id,
                               "name" = x[[1]]$name,
                               "desc" = rep_val(x[[1]]$description),
                                "launch_date" = rep_val(x[[1]]$date_launched),
                                "weekly_visits" = rep_valn(x[[1]]$weekly_visits),
                                "spot_volume_usd" = rep_valn(x[[1]]$spot_volume_usd),
                                "fiats" = rep_vall(x[1]$fiats)))

  return(the_return)
}
