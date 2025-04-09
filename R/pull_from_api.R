#' Pull from OME database
#'
#' @param url_path the API endpoint
#' @param filter Addition objects to pass via include. (not currently in use)
#' @param KEY API token
#'
#' @return data frame of pulled information
#' @export
get_query <- function(url_path, filter='', KEY = ''){
  # url_use = paste0(url_path, '?page=',page, filter)
  url_use = url_path
  req = httr2::request(url_use) |>
    httr2::req_user_agent("OMEAPI") |>
    httr2::req_auth_bearer_token(token = KEY) |>
    httr2::req_perform()

  body = req$body |> rawToChar() |> jsonlite::prettify() |> jsonlite::fromJSON(simplifyDataFrame = T,flatten = T)
  data = body
  if(!is.data.frame(body)) data =  body$data |> as.data.frame()

  data
}
