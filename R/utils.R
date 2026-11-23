#' Check object class
#'
#' @param x object
#' @param y class of object
#'

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

#' flatten a data frame with (multiple) list elements
#'
#' @param df data frame
#'
#' @return flat data frame (long format)
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

#' Convert 'flattened' survey to wide format.
#'
#' @param survey flattened survey.
#'
#' @return survey in the wide format.
#' @export
#'
#' @examplesIf FALSE
#' survey = cs_surveys_responses(id = 'ENTER_ID_HERE', output_type = 'original' )
#' survey_wide = survey_response_to_wide(survey)
#'
survey_response_to_wide <- function(survey){
  # Combine the text and response value into the column answer (if they exist)
  answer = rep(NA, nrow(survey))
  if('responses__value.textResponse' %in% names(survey)) answer = survey$responses__value.textResponse
  if('responses__value.responseValue.value' %in% names(survey))   answer[is.na(answer)] = survey$responses__value.responseValue.value[is.na(answer)]
  survey$answer = answer

  questions = survey$responses__question.value |> unique()
  students = survey$respondent.PERSON_ID |> unique()
  answers = lapply(questions, function(q){
    survey_part = survey[survey$responses__question.value == q,]
    survey_part$answer[match(students, survey_part$respondent.PERSON_ID)]
  }) |> data.frame()
  names(answers) = questions
  out = data.frame(respondent.id = students)
  respondent_index = match(students, survey$respondent.PERSON_ID)
  if('respondent.class.CLASS_ID' %in% names(survey)) out$CLASS_ID = survey$respondent.class.CLASS_ID[respondent_index]
  if('respondent.class.EST_ID' %in% names(survey)) out$EST_ID = survey$respondent.class.EST_ID[respondent_index]
  if('respondent.EST_ID' %in% names(survey)) out$EST_ID = survey$respondent.EST_ID[respondent_index]

  if(('EST_ID' %in% names(answers)) & ('EST_ID' %in% names(out))) answers$EST_ID = NULL # (tad o risky)
  out = data.frame(out, answers)
  names(out)[(ncol(out)-ncol(answers)+1):ncol(out)] = names(answers)
  out
}
