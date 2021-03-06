% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/simTrack.R
\docType{methods}
\name{simTrack,Animal-method}
\alias{simTrack,Animal-method}
\title{Simulate from an Animal state-space model}
\usage{
\S4method{simTrack}{Animal}(object, n = 1, newObject = TRUE, ...)
}
\arguments{
\item{object}{Animal reference class describing the state-space model to simulate from}

\item{n}{Number of replications}

\item{newObject}{Should a new Animal object be added to the returned matrix?}

\item{...}{Not used}
}
\value{
A (2 + newObject) x n matrix where the first row (X) contains lists with a matrix of simulated movement tracks, the second row (Y) contains lists with a matrix of simulated observations, and the third row (Animal - if present) contains lists with a new Animal object based on the simulated values.
}
\description{
Simulate from an Animal state-space model
}
\author{
Christoffer Moesgaard Albertsen
}
\seealso{
\code{\link{simTrack}}, \code{\link{simTrack,Measurement-method}}, \code{\link{simTrack,Movement-method}}
}

