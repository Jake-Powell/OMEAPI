#' Check token
#'
#' @param x token
#'
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

#' Helper to get and save OME API token
#'
#' Provides instructions on how to obtain and store an API token for the
#' OME API. Users must complete this step before using any functionality
#' that requires authentication. Obtaining a token requires contacting
#' the OME team via email.
#'
#' @usage cl_use_token()
#'
#' @details
#' After requesting access, you will receive an API token by email.
#' Once received, the token should be stored in your \file{.Renviron}
#' file under the name \env{OME_CS_TOKEN} and R must be restarted for
#' the change to take effect.
#'
#'
#' @examples
#' \dontrun{
#' # Display instructions to set up an OME API token
#' cl_use_token()
#' }
cs_use_token <- function()
{
  cli::cli_h2("To get and save an OME API key, follow these steps:")
  cli::cli_ol()
  cli::cli_li("For information to obtain an API key please contact mathsobservatory@nottingham.ac.uk.")
  cli::cli_li("Open and edit your .Renviron file (e.g., run {.run usethis::edit_r_environ()})")
  cli::cli_li("Add the following text to your .Renviron file, inserting your own API key value:")
  cli::cli_code("     OME_CS_TOKEN='youractualkeynotthisstring'")
  cli::cli_li("Restart R")
  cli::cli_end()
}

