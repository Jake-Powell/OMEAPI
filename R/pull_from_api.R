#' Pull from OME database
#'
#' @param url_path the API endpoint
#' @param filter Addition objects to pass via include. (not currently in use)
#' @param token API token
#' @param verbose Flag (TRUE/FALSE) for console printing.
#'
#' @return data frame of pulled information
#' @export
get_query <- function(url_path, filter='', token = '', verbose = F){
  carry_on = T ; page = 1
  data_all = list()
  while(carry_on){
    if(verbose) cli::cli_alert_info(paste0('Pulling page ', page))
    url_use = paste0(url_path, '?pageNumber=',page, filter)

    req = httr2::request(url_use) |>
      httr2::req_user_agent("OMEAPI") |>
      httr2::req_auth_bearer_token(token = token) |>
      httr2::req_perform()

    body = req$body |> rawToChar() |> jsonlite::prettify() |> jsonlite::fromJSON(simplifyDataFrame = T,flatten = T)
    if('list' %in% names(body)){
      data = body$list |> as.data.frame()
    }else{
      data = body |> as.data.frame()
    }
    data_all[[page]] =  data

    if(!'hasNextPage' %in% names(body)) break
    if(!body$hasNextPage){
      carry_on = F
    }else{
      page = page + 1
    }
  }
  data = do.call(rbind, data_all)
  data
}

#' Get base url
#' @noRd
cs_url <- function(){
  return("https://mathscohortstudies-uat-backend.azurewebsites.net/api/Public/")
}

#' Get CS meta information
#'
#' @param token API token
#'
#' @return academic years database
#' @export
cs_academic_years <- function(token = NULL){
 cs_endpoint(token, endpoint = 'academic-years')
}


#' @rdname cs_academic_years
#' @export
cs_school_years <- function(token = NULL){
  cs_endpoint(token, endpoint = 'school-years')
}

#' @rdname cs_academic_years
#' @export
cs_response_types <- function(token = NULL){
  cs_endpoint(token, endpoint = 'response-types')
}

#' @rdname cs_academic_years
#' @export
cs_response_value_groups <- function(token = NULL){
  cs_endpoint(token, endpoint = 'response-value-groups')
}

#' @rdname cs_academic_years
#' @export
cs_person_types <- function(token = NULL){
  cs_endpoint(token, endpoint = 'person-types')
}

#' @rdname cs_academic_years
#' @export
cs_cohorts <- function(token = NULL){
  cs_endpoint(token, endpoint = 'cohorts')
}

#' @rdname cs_academic_years
#' @export
cs_school_types <- function(token = NULL){
  cs_endpoint(token, endpoint = 'school-types')
}

#' Pull from meta endpoints
#'
#' @param token token
#' @param endpoint endpoint
#'
#' @noRd
cs_endpoint <- function(token = NULL, endpoint = ''){
  if(!endpoint %in% c('academic-years', 'school-years', 'response-types', 'response-value-groups', 'person-types', 'school-types', 'cohorts', 'surveys')){
    stop('Invalid endpoint')
  }
  url_use = paste0(cs_url(), endpoint)
  get_query(url_use, token = check_token(token))
}


#' Pull from CS API - schools/school endpoint
#'
#' @param token token
#' @param include Related objects to include. Valid values are: 'class', 'student', 'teacher'. Comma separated list of objects to include.
#' @param id school ID in CS database. If NA, all schools are pulled.
#'
#' @return data.frame of pulled information
#' @export
#'
#' @examples
cs_schools <- function(token = NULL, id = NA, include =NA){

  if(any(!include %in% c('class', 'teacher', 'student', NA))) stop('Invalid `include` values!')

  url_use = paste0(cs_url(), 'schools')
  if(!is.na(id)){
    url_use = paste0(url_use, '/', id)

  }
  if(!is.na(include[1])){
    filter = paste0('&include=',paste0(include, collapse = '%2C%20'))
  }else{
    filter =''
  }

  out = get_query(url_use, token = check_token(token),filter = filter)

}


#' Pull from CS API - surveys / surveys\{id\} / survey\{id\}/response endpoints
#'
#' @param token token
#' @param id survey ID in CS database. If NA, all schools are pulled.
#' @param output_type output_type
#'
#' @return data.frame of pulled information
#' @export
#'
#' @examples
cs_surveys <- function(token = NULL, id = NA){

  url_use = paste0(cs_url(), 'surveys')
  if(!is.na(id)){
    url_use = paste0(url_use, '/', id)

  }

  get_query(url_use, token = check_token(token))

}

#' @rdname cs_surveys
#' @export
cs_surveys_responses <- function(token = NULL, id = NA, output_type = 'clean'){
  if(is.na(id)) stop('Require id!')
  assert_is(id, 'numeric')

  url_use = paste0(cs_url(), 'surveys/',id,'/responses')

  raw = get_query(url_use, token = check_token(token))
  if(output_type == 'raw') return(raw)

  raw |> convert_list_element_to_df(column_to_unnest = 'responses') |>
    tidyr::unnest(responses, names_sep ='__', keep_empty  = T)


}
