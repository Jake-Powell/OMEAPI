# Introduction to OMEAPI

``` r
library(OMEAPI)
```

**This article explains how to use the OMEAPI R package to connect to
and pull from DOME.**

------------------------------------------------------------------------

## Authentication

DOME requires you to get your own API token, an alphanumeric string that
you need to send in every request. The cs_use_token() function in the
package can walk you through getting your own key and storing it
locally. Once you store this key, the functions in OMEAPI will always
default to using this key.

``` r
OMEAPI::cs_use_token()
```

Keep this key private. You can pass the key in to each function via the
key parameter, but it’s better to store the key as a environment
variable (OME_CS_TOKEN).

------------------------------------------------------------------------

## Overview of available features

- Query survey information (e.g., cs_surveys() and
  cs_surveys_responses())
- Query school (class, pupil, teacher, parent) information (e.g.,
  cs_schools())
- Query meta-information (e.g., cs_school_types(), cs_person_types(),
  cs_response_value_groups(), cs_response_types(), etc)
