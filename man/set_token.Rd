% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/token_management.R
\name{set_token}
\alias{set_token}
\title{Set CS token to the environment.}
\usage{
set_token(token)
}
\arguments{
\item{token}{token}
}
\description{
Set CS token to the environment.
}
\details{
Given an CS token to access the CS database, store the token in the local environment. This means you don't need to pass the token to each call to the API. Moreover, you can set once and delete thus not have the token on display in R files.
}
