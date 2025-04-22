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

#' flattern a data frame with (multiple) list elements
#'
#' @param df data frame
#'
#' @return flatterned data frame
#' @noRd
flatten_df <- function(df){
  carry_on = T
  while(carry_on){
    list_elements = lapply(1:length(df), function(x){is.list(df[[x]])}) |> unlist() |> which()
    list_elements = names(df)[list_elements]
    if(length(list_elements) == 0){break}
    for(element in list_elements){
      df = df |> convert_list_element_to_df(column_to_unnest = element) |>
        tidyr::unnest(tidyselect::all_of(element), names_sep ='__', keep_empty  = T)
    }
  }
  df
}
