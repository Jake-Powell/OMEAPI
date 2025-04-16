#' Check object class
#'
#' @param x object
#' @param y class of object
#'
#' @return

#' @noRd
assert_is <- function(x,y){
  if (!is.null(x)) {
    if (!inherits(x, y)) {
      stop(deparse(substitute(x)), " must be of class ",
           paste0(y, collapse = ", "), call. = FALSE)
    }
  }
}

#' convert sublist element of data frame to a data frame
#'
#' @param data data
#' @param column_to_unnest column_to_unnest
#'
#' @return
#' @noRd
convert_list_element_to_df <- function(data, column_to_unnest){
  for(i in 1:nrow(data)){
    val = data[[column_to_unnest]][i][[1]]
    if(is.list(val) &length(val) == 0){
      data[[column_to_unnest]][i][[1]] = data.frame()
    }
  }
  data
}

