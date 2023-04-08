get_key_metrics <- function(api_key = Sys.getenv("CMC_API_KEY")){
  tmp <- call_cmc_api("/v1/key/info",api_key)
  spent <- tmp$usage |> tibble::as_tibble() |>
              tidyr::unnest_longer(everything()) |>
              dplyr::rename_with(~gsub("current_","",.x))
  limits <- tmp$plan |> tibble::as_tibble() |>
              dplyr::select(credit_limit_monthly,
                            rate_limit_minute) |>
              dplyr::rename(month="credit_limit_monthly",
                            minute="rate_limit_minute") |>
              dplyr::relocate(minute)
  output <- dplyr::bind_rows(limits,spent)
  output$type <- c("limit","used","remaining")
  output$day[3] <- NA # Make ramaining per day as NA
  return(output)
}
