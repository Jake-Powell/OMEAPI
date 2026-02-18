# Introduction to OMEAPI

``` r
library(OMEAPI)
```

**This article explains how to use the OMEAPI R package to connect to
and pull from the OME database.**

------------------------------------------------------------------------

## Authentication

OME requires you to get have an API token, an alphanumeric string that
you need to send in every request. You will need to contact the OME data
manager for create a token for you.

Keep this token private. You can pass the token in to each function via
the token parameter, but it’s better to store the token either as a
environment variable (OME_CS_TOKEN).

``` r
OMEAPI::set_token('TOKEN_VALUE_HERE')
```

Once set you no longer need to pass the token to individual functions.
This wil persist until the session is ended.

------------------------------------------------------------------------

## Overview of available features

Query survey information (e.g., cs_surveys() and cs_surveys_responses())
Query school (class, pupil, teacher, parent) information (e.g.,
cs_schools()) Query meta-information (e.g., cs_school_types(),
cs_person_types(), cs_response_value_groups(), cs_response_types(), etc)
