
#' General function for querying API endpoints
#'
#' @param url_path API endpoint.
#' @param filter Additional query parameters.
#' @param token API bearer token.
#' @param verbose Show pagination progress.
#' @param pageSize Maximum number of records per page.
#' @param n Total number of records to retrieve. 0 retrieves all.
#'
#' @return Data frame of pulled information.
#' @export
get_query <- function(url_path, filter = '', token = '',
                      verbose = FALSE, pageSize = 1000, n = 0) {

  if (length(pageSize) != 1L || is.na(pageSize) ||
      !is.numeric(pageSize) || !is.finite(pageSize) ||
      pageSize < 1 || pageSize != floor(pageSize)) {
    stop("pageSize must be a positive integer.")
  }

  if (length(n) != 1L || is.na(n) ||
      !is.numeric(n) || !is.finite(n) ||
      n < 0 || n != floor(n)) {
    stop("n must be a non-negative integer.")
  }

  page = 1
  records_pulled = 0
  data_all = list()

  sym = if (grepl("\\?", url_path)) "&" else "?"

  if (verbose) {
    cli::cli_progress_bar(
      name = "Pulling from API...",
      total = if (n > 0) n else NA
    )
    on.exit(cli::cli_progress_done(), add = TRUE)
  }

  repeat {

    # Request only the remaining records if n is specified
    current_pageSize = if (n == 0) {
      pageSize
    } else {
      min(pageSize, n - records_pulled)
    }

    url_use = paste0(
      url_path, sym,
      "pageNumber=", page,
      "&pageSize=", current_pageSize,
      filter
    )

    req = httr2::request(url_use) |>
      httr2::req_user_agent("OMEAPI") |>
      httr2::req_auth_bearer_token(token = token) |>
      httr2::req_perform()

    body = req$body |>
      rawToChar() |>
      jsonlite::fromJSON(
        simplifyDataFrame = TRUE,
        flatten = TRUE
      )

    if ("list" %in% names(body)) {
      data = as.data.frame(body$list)
    } else {
      for (i in seq_along(body)) {
        if (is.list(body[[i]]) && length(body[[i]]) == 0) {
          body[[i]] = NA
        }
      }
      data = as.data.frame(body)
    }

    # Ensure we never return more than n records
    if (n > 0 && nrow(data) > n - records_pulled) {
      data = utils::head(data, n - records_pulled)
    }

    data_all[[page]] = data
    records_pulled = records_pulled + nrow(data)

    if (verbose) {
      if (n > 0) {
        cli::cli_progress_update(set = records_pulled)
      } else {
        cli::cli_progress_update(
          set = page,
          total = if ("totalPages" %in% names(body)) {
            body$totalPages
          } else {
            NA
          }
        )
      }
    }

    # Stop if requested number of records has been reached
    if (n > 0 && records_pulled >= n) break

    # Stop if API has no more pages
    if (!"hasNextPage" %in% names(body)) break
    if (!isTRUE(body$hasNextPage)) break

    # Avoid infinite pagination on empty responses
    if (nrow(data) == 0) break

    page = page + 1
  }

  if (length(data_all) == 0) return(data.frame())

  dplyr::bind_rows(data_all)
}


#' Get base url
#' @noRd
cs_url <- function(){
  return("https://mathscohortstudies-prod-backend.azurewebsites.net/api/Public/")
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
#' @param id survey ID in DOME. If NA, all surveys are pulled.
#' @param name survey name in DOME.
#' @param output_type output_type
#' @param verbose verbose
#' @param cohortId verbose
#' @param respondentIds verbose
#' @param teacherIds verbose
#' @param schoolIds verbose
#' @param classIds verbose
#' @param ... verbose
#'
#' @return data.frame of pulled information
#' @export
#'
cs_surveys <- function(token = NULL, id = NA, cohortId = NA){

  url_use = paste0(cs_url(), 'surveys')
  if(!is.na(id)){
    url_use = paste0(url_use, '/', id)

  }
  if(!is.na(cohortId)){
    url_use = paste0(url_use, '/?cohortId=', cohortId)

  }

  get_query(url_use, token = check_token(token))

}

#' @rdname cs_surveys
#' @export
cs_surveys_responses <- function(token = NULL,
                                 id = NA,
                                 name = NA,
                                 respondentIds = '',
                                 teacherIds = '',
                                 schoolIds = '',
                                 classIds = '',
                                 output_type = 'wide',
                                 verbose = F, ...){
  if(is.na(id) & is.na(name)) stop('Require id or name!')
  if(is.na(id)){
    all_surveys = cs_surveys()
    id = all_surveys$id[match(name |> tolower(), all_surveys$name |> tolower())] |> as.numeric()
    if(is.na(id)) stop('`name` does not correspond to a survey in DOME!')
  }
  if(is.na(id)) stop('`id` not found in surveys list!')
  assert_is(id, 'numeric')

  url_use = paste0(cs_url(), 'surveys/',id,'/responses')
  url_use = paste0(url_use, '?respondentIds=', paste0(respondentIds, collapse = ','))
  url_use = paste0(url_use, '&teacherIds=', paste0(teacherIds, collapse = ','))
  url_use = paste0(url_use, '&schoolIds=', paste0(schoolIds, collapse = ','))
  url_use = paste0(url_use, '&classIds=', paste0(classIds, collapse = ','))


  raw = get_query(url_use, token = check_token(token), verbose = verbose,...)
  if(output_type == 'original') return(raw)

  if(!'responses' %in% names(raw)){
    warning('Selected survey has no responses!')
    return(raw)
  }

  if(verbose) cli::cli_alert_info('Converting to long format')
  cleaned = raw |> convert_list_element_to_df(column_to_unnest = 'responses') |>
    tidyr::unnest(tidyselect::all_of('responses'), names_sep ='__', keep_empty  = T)
  if(output_type == 'long') return(cleaned)

  if(verbose) cli::cli_alert_info('Converting to wide format')

  cleaned |> survey_response_to_wide()


}

#' Query parents endpoints
#'
#' @description
#' A functions to query parents from the Cohort Studies API.
#'
#' @inheritParams get_query
#' @param id parent ID
#' @param flatten a flag (TRUE/FALSE) for whether we convert to a flat data.frame.
#' @param ... variables passed to \code{\link[=get_query]{get_query()}}.
#' @return data.frame of pulled information
#' @export
#'
#' @details
#' Queries /api/Public/parents and /api/Public/parents/\{id\} endpoints.
#'
#'
#' By default the returned data.frame can have nested data.frames (within student, etc). By switching `flatten = T` the returned data frame can be flattened (converted to long format) to remove this nested structure.
#'
#' @examplesIf FALSE
#' # Setup API token
#' set_token('ENTER_TOKEN_HERE')
#'
#' # Query all schools.
#' schools = cs_parents()
#'
#'
cs_parents <- function(token = NULL, id = NA, flatten = F, ...){

  url_use = paste0(cs_url(), 'parents')
  if(!is.na(id)){
    url_use = paste0(url_use, '/', id)
  }


  out = get_query(url_use, token = check_token(token),filter = '', ...)

  if(!flatten){
    return(out)
  }
  out |> flatten_df()

}
