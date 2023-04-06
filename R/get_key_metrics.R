get_key_metrics <- function(api_key = Sys.getenv("CMC_API_KEY")){
  tmp <- call_cmc_api("/v1/key/info",api_key) |> fromJSON()
  if (tmp[[1]]$error_code != 0){
    error(glue::glue("Error: ",tmp[[1]]$error_message))
  }
  spent <- x[[2]][[2]] |> tibble::as_tibble() |>
              tidyr::unnest_longer(everything()) |>
              dplyr::rename_with(~gsub("current_","",.x))
  limits <- x[[2]][[1]] |> tibble::as_tibble() |>
              dplyr::select(credit_limit_daily,
                            credit_limit_monthly,
                            rate_limit_minute) |>
              dplyr::rename(day = "credit_limit_daily",
                            month="credit_limit_monthly",
                            minute="rate_limit_minute") |>
              dplyr::relocate(minute)
  output <- bind_rows(limits,spent)
  output$type <- c("limit","used","remaining")
  return(output)
}
