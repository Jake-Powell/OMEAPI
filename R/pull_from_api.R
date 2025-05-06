#' General function for querying API endpoints
#'
#' @param url_path API endpoint
#' @param filter Addition objects to pass via include.
#' @param token API token
#' @param verbose Flag (TRUE/FALSE) for console printing (used when there is pagination).
#'
#' @return data frame of pulled information
#' @export
#'
#' @details
#' This function queries an API endpoint given by `url_path`. If the endpoint takes arguements these can be passed via the `filter` input which concatenates the endpoint with the value supplied by `filter.` A bearer token is passed using the token input.
#'
#' Note that this function assumes the API has pagination (adds "?pageNumber=") and will loop over all available pages and rbind the result into a single data frame.
#'
#'
#'
get_query <- function(url_path, filter='', token = '', verbose = F){
  carry_on = T ; page = 1
  data_all = list()

  # If verbose = true we need to find out the total number of pages and create a cli
  if(verbose) cli::cli_progress_bar(name = 'Pulling from API...')
  while(carry_on){
    url_use = paste0(url_path, '?pageNumber=',page, filter)

    req = httr2::request(url_use) |>
      httr2::req_user_agent("OMEAPI") |>
      httr2::req_auth_bearer_token(token = token) |>
      httr2::req_perform()

    body = req$body |> rawToChar() |> jsonlite::prettify() |> jsonlite::fromJSON(simplifyDataFrame = T,flatten = T)
    if('list' %in% names(body)){
      data = body$list |> as.data.frame()
    }else{
      # added to stop list() from causing an error using as.data.frame().
      for(i in 1:length(body)){
        if(body[[i]] |> is.list() & length(body[[i]]) == 0){
          body[[i]] = NA
        }
      }
      data = body |> as.data.frame()
    }
    data_all[[page]] =  data

    if(!'hasNextPage' %in% names(body)) break

    if(!exists('total_pages')) total_pages = body$totalPages

    # if(verbose) cli::cli_alert_info(paste0('Pulling page ', page,'/',total_pages))
    if(verbose) cli::cli_progress_update(set = page,total = total_pages)

    if(!body$hasNextPage){
      carry_on = F
    }else{
      page = page + 1
    }
  }
  if(verbose) cli::cli_progress_done()

  data = do.call(rbind, data_all)
  data
}

#' Get base url
#' @noRd
cs_url <- function(){
  return("https://mathscohortstudies-uat-backend.azurewebsites.net/api/Public/")
}

#' Query meta-information endpoints
#'
#' @description
#' A collection of functions to query "meta-information" from the Cohort Studies API.
#'
#' @inheritParams get_query
#'
#' @return Query result in a data frame.
#' @export
#'
#' @details
#' Query specific meta-information endpoints of the Cohort Studies database, in particular:
#'
#' \itemize{
#' \item cs_academic_years(): queries /api/Public/academic-years endpoint.
#' \item cs_school_years(): queries /api/Public/school-years endpoint.
#' \item cs_response_types(): queries /api/Public/response-types endpoint.
#' \item cs_response_value_groups(): queries /api/Public/response-value-groups endpoint.
#' \item cs_person_types(): queries /api/Public/person-types endpoint.
#' \item cs_cohorts(): queries /api/Public/cohorts endpoint.
#' \item cs_school_types(): queries /api/Public/school-types endpoint.
#' }
#'
#' Each function uses \code{\link[=get_query]{get_query()}}  to query specific endpoints.
#'
#' @examplesIf FALSE
#' # Setup API token
#' set_token('ENTER_TOKEN_HERE')
#'
#' # Query each endpoint
#' academic_years = cs_academic_years()
#' school_years = cs_school_years()
#' response_types = cs_response_types()
#' response_value_groups = cs_response_value_groups()
#' person_types = cs_person_types()
#' cohorts = cs_cohorts()
#' school_types = cs_school_types()
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


#' Query school endpoints
#'
#' @description
#' A functions to query school-related information from the Cohort Studies API.
#'
#' @inheritParams get_query
#' @param include Character vector or objects to include. Accepted values are: 'class', 'student', 'teacher'.
#' @param id school ID in CS database. If NA, all schools are pulled.
#' @param flatten a flag (TRUE/FALSE) for whether we convert to a flat data.frame.
#' @param ... variables passed to \code{\link[=get_query]{get_query()}}.
#' @return data.frame of pulled information
#' @export
#'
#' @details
#' Queries /api/Public/schools and /api/Public/schools/\{id\} endpoints.
#'
#' Note that schools are structured such that classes are nested within schools and teachers/students are nested within classes. Therefore, to include "student" and/or "teacher" we must also have "class" as an include parameter.
#'
#' By default the returned data.frame can have nested data.frames (within student, etc). By switching `flatten = T` the returned data frame can be flattened (converted to long format) to remove this nested structure.
#'
#' @examplesIf FALSE
#' # Setup API token
#' set_token('ENTER_TOKEN_HERE')
#'
#' # Query all schools.
#' schools = cs_schools()
#'
#' # Query schools with all include options.
#' schools_with_details = cs_schools(include = c('class', 'student', 'teacher'))
#'
#' # Query schools with only student include option
#' # (note that without class this is the same as including no options).
#' schools_with_details = cs_schools(include = c('student'))
#'
#' # Query a single school
#' estab_number = schools$establishmentNumber[1] |> as.numeric()
#' school = cs_schools(id = estab_number,  include = c('class', 'student', 'teacher'))
#'
#' # Query a single school where we flattern the student/teacher information.
#' school_flat = cs_schools(id = estab_number,
#'   include = c('class', 'student', 'teacher'),
#'    flatten = T)
#'
cs_schools <- function(token = NULL, id = NA, include = NA, flatten = F, ...){

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

  out = get_query(url_use, token = check_token(token),filter = filter, ...)

  if(!flatten){
    return(out)
  }
  out |> flatten_df()

}


#' Query survey endpoints
#'
#' @param token token
#' @param id survey ID in CS database. If NA, all surveys are pulled.
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
cs_surveys_responses <- function(token = NULL, id = NA, output_type = 'clean', ...){
  if(is.na(id)) stop('Require id!')
  assert_is(id, 'numeric')

  url_use = paste0(cs_url(), 'surveys/',id,'/responses')

  raw = get_query(url_use, token = check_token(token),...)
  if(output_type == 'raw') return(raw)

  if(!'responses' %in% names(raw)){
    warning('Selected survey has no responses!')
    return(raw)
  }

  raw |> convert_list_element_to_df(column_to_unnest = 'responses') |>
    tidyr::unnest(tidyselect::all_of('responses'), names_sep ='__', keep_empty  = T)


}
