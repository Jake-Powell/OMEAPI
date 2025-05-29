
<!-- README.md is generated from README.Rmd. Please edit that file -->

# OMEAPI <a href="https://jake-powell.github.io/OMEAPI/"><img src="man/figures/logo.png" align="right" height="139" alt="OMEAPI website" /></a><!-- badges: start -->

<!-- badges: end -->

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
set with `set_token()`.

``` r
library(OMEAPI)

# Get all surveys
surveys = cs_surveys()

# load responses for a particular survey.
survey_response = cs_surveys_responses(id = surveys$id[1] |> as.numeric())
```
