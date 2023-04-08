#' Call Coinmarketcap API
#'
#'  This is the core function connecting to Coinmarketcap. Since all (most?) API
#'  calls have the same seven parameters it does some error checking
#'  and adds defaults all the
#'
#' @param path The path to pass to the API URL
#' @param ... a \emph{named} list of parameters to pass to the endpoint
#'
#' @return a parsed list from the JSON structure
#'
#' @examples
#' \dontrun{
#' # Need a valid API to run
#' x <- call_glassnode_api()
#' }
#' @noRd
call_cmc_api <- function(path, ...) {
  tmp <- list(...)
  params <- do.call(make_params, tmp)
  tmp_url <- httr::modify_url("https://pro-api.coinmarketcap.com/", query=params,path = path)
  resp <- httr::GET(url = tmp_url)
  if (httr::http_error(resp)) {
    msg <- glue::glue(
      "Coinmarketcap API request failed ({httr::status_code(resp)})","\n", tmp_url
    )
    stop(
      msg
    )
  }
  parsed <- httr::content(resp, "text", encoding = "UTF-8") |>
    jsonlite::fromJSON()
  if (parsed[[1]]$error_code != 0){
    error(glue::glue("Error: ",tmp[[1]]$error_message))
  }

  return(parsed$data)
}



