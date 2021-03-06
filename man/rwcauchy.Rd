% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/sample.R
\name{rwcauchy}
\alias{rwcauchy}
\title{Simulate from a wrapped Cauchy distribution}
\usage{
rwcauchy(n, mu, gamma)
}
\arguments{
\item{n}{Number of replications}

\item{mu}{Location parameter}

\item{gamma}{Scale parameter}
}
\value{
A vector of simulated values
}
\description{
Simulates values from a wrapped Cauchy distribution, \eqn{WC(\mu,\gamma)}. If \eqn{X \sim t(1)} then
\deqn{\gammaX + \mu \text{mod} 2\pi \sim WC(\mu,\gamma}
}
\author{
Christoffer Moesgaard Albertsen
}
\keyword{internal}

