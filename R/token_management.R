#' Check token
#'
#' @param x token
#'
#' @return
#' @noRd
check_token <- function(x = NULL ){
  tmp = x
  if (is.null(x)) tmp = Sys.getenv("OME_CS_TOKEN")
  assert_is(tmp, 'character')
  tmp
}

#' Set CS token to the environment.
#'
#' @param token token
#'
#' @export
#'
#' @details
#' Given an CS token to access the CS database, store the token in the local environment. This means you don't need to pass the token to each call to the API. Moreover, you can set once and delete thus not have the token on display in R files.
#'
set_token <- function(token){
  Sys.setenv("OME_CS_TOKEN" = token)
}
