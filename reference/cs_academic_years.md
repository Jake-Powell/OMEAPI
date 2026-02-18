# Query meta-information endpoints

A collection of functions to query "meta-information" from the Cohort
Studies API.

## Usage

``` r
cs_academic_years(token = NULL)

cs_school_years(token = NULL)

cs_response_types(token = NULL)

cs_response_value_groups(token = NULL)

cs_person_types(token = NULL)

cs_cohorts(token = NULL)

cs_school_types(token = NULL)
```

## Arguments

- token:

  API token

## Value

Query result in a data frame.

## Details

Query specific meta-information endpoints of the Cohort Studies
database, in particular:

- cs_academic_years(): queries /api/Public/academic-years endpoint.

- cs_school_years(): queries /api/Public/school-years endpoint.

- cs_response_types(): queries /api/Public/response-types endpoint.

- cs_response_value_groups(): queries /api/Public/response-value-groups
  endpoint.

- cs_person_types(): queries /api/Public/person-types endpoint.

- cs_cohorts(): queries /api/Public/cohorts endpoint.

- cs_school_types(): queries /api/Public/school-types endpoint.

Each function uses
[`get_query()`](https://jake-powell.github.io/OMEAPI/reference/get_query.md)
to query specific endpoints.

## Examples

``` r
if (FALSE) {
# Setup API token
set_token('ENTER_TOKEN_HERE')

# Query each endpoint
academic_years = cs_academic_years()
school_years = cs_school_years()
response_types = cs_response_types()
response_value_groups = cs_response_value_groups()
person_types = cs_person_types()
cohorts = cs_cohorts()
school_types = cs_school_types()
}
```
