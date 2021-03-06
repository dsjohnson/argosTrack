% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/Movement.R
\docType{class}
\name{Movement-class}
\alias{Movement}
\alias{Movement-class}
\title{An abstract Reference Class for fitting a Movement model.}
\description{
Reference class implementing common functions for movement models.
}
\section{Methods}{

\describe{
\item{\code{addToLatPlot(arglist = list())}}{Function to add estimated movement latitudes to a plot. arglist is a list of base graphics arguments to be used for movement estimates.}

\item{\code{addToLatPlotSd(arglist = list(col = "grey", border = NA, lwd = 3, lty = 2))}}{Function to add standard errors of estimated movement latitudes to a plot. arglist is a list of base graphics arguments to be used.}

\item{\code{addToLonPlot(arglist = list())}}{Function to add estimated movement longitudes to a plot. arglist is a list of base graphics arguments to be used for movement estimates.}

\item{\code{addToLonPlotSd(arglist = list(col = "grey", border = NA, lwd = 3, lty = 2))}}{Function to add standard errors of estimated movement longitudes to a plot. arglist is a list of base graphics arguments to be used.}

\item{\code{addToMapPlot(arglist = list())}}{Function to add estimated movement coordinates to a plot. arglist is a list of base graphics arguments to be used.}

\item{\code{getRange(sd = FALSE)}}{Returns the range of estimated coordinates. If sd = TRUE, the range includes standard errors of the movement estimates.}

\item{\code{getTMBdata()}}{Function to return a data list for TMB::MakeADFun}

\item{\code{getTMBmap(...)}}{Function to return a map list for TMB::MakeADFun.}

\item{\code{getTMBparameters()}}{Function to return a parameter list for TMB::MakeADFun}

\item{\code{updateFromFit(parList, hessian, sdParList = NULL)}}{Function to save the result from nlminb.}
}}
\note{
This reference class should not be used as it does not implement a model. The class is only intended to be a superclass for actual implementations of movement models. A movement model implementation must include an initialization method, a simulation method and (preferably) a getTMBmap method.
}
\seealso{
Used in \code{\link{Animal}}. Currently the following movement models are implemented: \code{\link{CTCRW}}, \code{\link{DCRW}}, \code{\link{DSBHN}}, \code{\link{DSBW}}, \code{\link{RW}}.

Other X.Movement.models.: \code{\link{CTCRW}},
  \code{\link{CTCRW-class}}; \code{\link{DCRW}},
  \code{\link{DCRW-class}}; \code{\link{DSBHN}},
  \code{\link{DSBHN-class}}; \code{\link{DSBW}},
  \code{\link{DSBW-class}}; \code{\link{IDCRW}},
  \code{\link{IDCRW-class}}; \code{\link{MPCTCRW}},
  \code{\link{MPCTCRW-class}}; \code{\link{OUL}},
  \code{\link{OUL-class}}; \code{\link{OUV}},
  \code{\link{OUV-class}}; \code{\link{RW}},
  \code{\link{RW-class}}
}

