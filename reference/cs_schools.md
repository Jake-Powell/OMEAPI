# Query school endpoints

A functions to query school-related information from the Cohort Studies
API.

## Usage

``` r
cs_schools(token = NULL, id = NA, include = NA, flatten = F, ...)
```

## Arguments

- token:

  API token

- id:

  school ID in CS database. If NA, all schools are pulled.

- include:

  Character vector or objects to include. Accepted values are: 'class',
  'student', 'teacher'.

- flatten:

  a flag (TRUE/FALSE) for whether we convert to a flat data.frame.

- ...:

  variables passed to
  [`get_query()`](https://jake-powell.github.io/OMEAPI/reference/get_query.md).

## Value

data.frame of pulled information

## Details

Queries /api/Public/schools and /api/Public/schools/{id} endpoints.

Note that schools are structured such that classes are nested within
schools and teachers/students are nested within classes. Therefore, to
include "student" and/or "teacher" we must also have "class" as an
include parameter.

By default the returned data.frame can have nested data.frames (within
student, etc). By switching \`flatten = T\` the returned data frame can
be flattened (converted to long format) to remove this nested structure.

## Examples

``` r
if (FALSE) {
# Setup API token
set_token('ENTER_TOKEN_HERE')

# Query all schools.
schools = cs_schools()

# Query schools with all include options.
schools_with_details = cs_schools(include = c('class', 'student', 'teacher'))

# Query schools with only student include option
# (note that without class this is the same as including no options).
schools_with_details = cs_schools(include = c('student'))

# Query a single school
estab_number = schools$establishmentNumber[1] |> as.numeric()
school = cs_schools(id = estab_number,  include = c('class', 'student', 'teacher'))

# Query a single school where we flattern the student/teacher information.
school_flat = cs_schools(id = estab_number,
  include = c('class', 'student', 'teacher'),
   flatten = T)
}
```
