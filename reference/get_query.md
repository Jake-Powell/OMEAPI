# General function for querying API endpoints

General function for querying API endpoints

## Usage

``` r
get_query(url_path, filter = "", token = "", verbose = F)
```

## Arguments

- url_path:

  API endpoint

- filter:

  Addition objects to pass via include.

- token:

  API token

- verbose:

  Flag (TRUE/FALSE) for console printing (used when there is
  pagination).

## Value

data frame of pulled information

## Details

This function queries an API endpoint given by \`url_path\`. If the
endpoint takes arguements these can be passed via the \`filter\` input
which concatenates the endpoint with the value supplied by \`filter.\` A
bearer token is passed using the token input.

Note that this function assumes the API has pagination (adds
"?pageNumber=") and will loop over all available pages and rbind the
result into a single data frame.
