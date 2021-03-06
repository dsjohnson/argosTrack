% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/Movement_CTCRW.R
\docType{class}
\name{CTCRW-class}
\alias{CTCRW}
\alias{CTCRW-class}
\title{A Reference Class for fitting a Continuous Time Correlated Random Walk model.}
\description{
The reference class implements a Continuous Time Correlated Random Walk (Johnson et al. 2008). The velocity is modelled by an Ornstein Uhlenbeck process in each coordinate (\eqn{c}),
\deqn{\nu_{c,t}-\gamma_c = e^{-\beta_c\Delta_{t}}[\nu_{c,t-\Delta_{t}}-\gamma_c]+\eta_{c,t},}
and the locations are modelled by the integrated velocity,
\deqn{X_{c,t} = X_{c,t-\Delta_{t}}+\nu_{c,t-\Delta_{t}}\left(1-e^{-\beta_c\Delta_t}\right)/\beta_c+\zeta_{c,t}.}
Here, \eqn{\Delta_t} is the length of the time steps and \eqn{\eta_{c,t}}, \eqn{\zeta_{c,t}} are random variables.
\eqn{\eta_{c,t}} follows a Gaussian distribution with mean zero and variance \eqn{V\left(\eta_{c,t}\right) = \sigma_c^2(1-e^{-2\beta_c\Delta_t})/(2\beta_c)}. The \eqn{\eta}'s are independent in time and coordiantes.
\eqn{\zeta_{c,t}} follows a Gaussian distribution with mean zero and variance
\deqn{V\left(\zeta_{c,t}\right)=\frac{\sigma_c^2}{\beta_c^2}\left(\Delta_t-2\left(1-e^{-\beta_c\Delta_t}\right)/\beta_c+\left(1-e^{-2\beta_c\Delta_t}\right)/(2\beta_c)\right).}
The \eqn{\zeta}'s are independent in time and coordiantes.
The model correlates \eqn{\eta_{c,t}} and \eqn{\zeta_{c',t'}} by
\deqn{Cov\left(\eta_{c,t},\zeta_{c,t}\right)= \frac{\sigma_c^2}{2\beta_c^2}\left(1-2e^{-\beta_c\Delta_t}+e^{-2\beta_c\Delta_i}\right).}
For \eqn{c\neq c'} and \eqn{t\neq t'}, \eqn{Cov\left(\eta_{c,t},\zeta_{c',t'}\right)=0}
}
\section{Methods}{

\describe{
\item{\code{getTMBmap(...)}}{Function to return a map list for TMB::MakeADFun.}

\item{\code{initialize(dates, pars = numeric(4), varPars = numeric(2),
  nauticalStates = FALSE, timeunit = "hours")}}{Method to initialize the class. 'dates' is a vector of distinct and increasing POSIXct dates; 'pars' is vector of the movement parameters: \eqn{log(\beta_{lat})}, \eqn{log(\beta_{lon})}, \eqn{\gamma_{lat}}, \eqn{\gamma_{lon}}; 'varPars' is a vector of movement variance parameters: \eqn{log(\sigma_{lat})}, \eqn{log(\sigma_{lon})}; 'nauticalStates' is a logical value indicating whether the states should be modelled in nautical miles, and 'timeunit' is the time unit to use for calculating time steps.}

\item{\code{simulate(x0 = c(0, 0, 0, 0))}}{Function to simulate from the movement model. The initial states (latitudianl velocity, longitudinal velocity, latitudinal/y-coordinate location and longitudinal/x-coordinate location) must be given. The function only returns the locations. If nauticalStates==TRUE, the result is returned in nautical miles.}
}}
\examples{
d <- subadult_ringed_seal
mov <- CTCRW(unique(as.POSIXct(d$date)))
}
\references{
Johnson, D. S., J. M. London, M. A. Lea, and J. W. Durban. (2008) Continuous-time correlated random walk model for animal telemetry data. Ecology 89, 1208-1215.
\cr\cr Albertsen, C. M., Whoriskey, K., Yurkowski, D., Nielsen, A., and Flemming, J. M. (2015) Fast fitting of non-Gaussian state-space models to animal movement data via Template Model Builder. Ecology, 96(10), 2598-2604. doi: 10.1890/14-2101.1
}
\seealso{
\link{Movement}

Other X.Movement.models.: \code{\link{DCRW}},
  \code{\link{DCRW-class}}; \code{\link{DSBHN}},
  \code{\link{DSBHN-class}}; \code{\link{DSBW}},
  \code{\link{DSBW-class}}; \code{\link{IDCRW}},
  \code{\link{IDCRW-class}}; \code{\link{MPCTCRW}},
  \code{\link{MPCTCRW-class}}; \code{\link{Movement}},
  \code{\link{Movement-class}}; \code{\link{OUL}},
  \code{\link{OUL-class}}; \code{\link{OUV}},
  \code{\link{OUV-class}}; \code{\link{RW}},
  \code{\link{RW-class}}
}

