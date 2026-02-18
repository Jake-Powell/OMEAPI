# Query survey endpoints

Query survey endpoints

## Usage

``` r
cs_surveys(token = NULL, id = NA)

cs_surveys_responses(
  token = NULL,
  id = NA,
  respondentIds = "",
  teacherIds = "",
  schoolIds = "",
  classIds = "",
  output_type = "wide",
  verbose = F
)
```

## Arguments

- token:

  token

- id:

  survey ID in CS database. If NA, all surveys are pulled.

- respondentIds:

  verbose

- teacherIds:

  verbose

- schoolIds:

  verbose

- classIds:

  verbose

- output_type:

  output_type

- verbose:

  verbose

## Value

data.frame of pulled information
