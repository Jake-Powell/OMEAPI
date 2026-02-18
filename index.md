# OMEAPI

OMEAPI package is used to query the maths cohort studies database and
create basic analysis and graphs from the extracted information. The
functions within the package cover all endpoints of the cohort studies
API. The use of the package requires an API token to use. For
information to obtain an API key please contact
<mathsobservatory@nottingham.ac.uk>.

# Installation

``` r
remotes::install_github("Jake-Powell/OMEAPI")
```

------------------------------------------------------------------------

# Example

For the example below to work you will need an API token which you can
set with
[`set_token()`](https://jake-powell.github.io/OMEAPI/reference/set_token.md).

``` r
library(OMEAPI)

# Get all surveys
surveys = cs_surveys()

# load responses for a particular survey.
survey_response = cs_surveys_responses(id = surveys$id[1] |> as.numeric())
```
