#' A Reference Class for fitting an Ornstein-Uhlenbeck Location model.
#'
#' The reference class implements an Ornstein-Uhlenbeck Location (Blackwell 2016). The locations follow an Ornstein-Uhlenbeck process
#' \deqn{X_t - \gamma = e^{B\Delta_t}[X_{t-\Delta_t} - \gamma] + \eta_{t}}
#' where \eqn{\eta_t} is a bivariate normal with zero mean and covariance \eqn{\pmatrx{\sigma_1^2 & 0 \cr 0 & \sigma_2^2}}.
#'
#' 
#' @seealso \code{\link{Movement}}. A generalization of \code{\link{DCRW}}, \code{\link{RW}}, and \code{\link{CTCRW}} (except only the location is modelled here)
#'
#' @family "Movement models"
#' 
#' @references
#' Blackwell, P. G., Niu, M., Lambert, M. S. and LaPoint, S. D. (2016), Exact Bayesian inference for animal movement in continuous time. Methods Ecol Evol, 7: 184-195. doi:10.1111/2041-210X.12460
#'
#' @examples
#' d <- subadult_ringed_seal
#' mov <- argosTrack:::OUL(unique(as.POSIXct(d$date)))
#' 
#' @keywords internal
OUL <- setRefClass("OUL",
                  contains = "Movement",
                  methods = list(
                      initialize = function(dates,
                                            pars = c(1,0,0,1,0,0),
                                            varPars = numeric(2),
                                            nauticalStates = FALSE,
                                            timeunit = "hours"
                                            ){
                          "Method to initialize the class. 'dates' is a vector of distinct and increasing POSIXct dates; 'pars' is vector of the movement parameters: \\eqn{B_{1,1}}, \\eqn{B_{2,1}}, \\eqn{B_{1,2}}, \\eqn{B_{2,2}}, \\eqn{\\gamma_{lat}}, \\eqn{\\gamma_{lon}}; 'varPars' is a vector of movement variance parameters: \\eqn{log(\\sigma_{lat})}, \\eqn{log(\\sigma_{lat})}; 'nauticalStates' is a logical value indicating whether the states should be modelled in nautical miles, and 'timeunit' is the time unit to use for calculating time steps."
###############
## Do checks ##
###############
                          if(!is.POSIXct(dates))
                              stop("dates must be a POSIXct object.")
                          dt0 <- as.numeric(difftime(tail(dates,-1),
                                                     head(dates,-1),
                                                     units = timeunit))
                          if(any(dt0 <= 0))
                              stop("Time steps must be positive.")
                          if(!(length(pars)==6 && is.numvec(pars)))
                              stop("pars must be a numeric vector of length 6.")
                          if(!(length(varPars)==2 && is.numvec(varPars)))
                              stop("varPars must be a numeric vector of length 2.")
                          if(!(length(nauticalStates)==1 && is.logical(nauticalStates)))
                              stop("nauticalStates must be logical.")
                          if(!(length(timeunit == 1 &&
                                      timeunit %in% c("auto", "secs", "mins", 
                                                      "hours", "days", "weeks"))))
                              stop("timeunit must be one of: 'auto', 'secs', 'mins', 'hours', 'days', 'weeks'.")

################
## initFields ##
################
                          
                          initFields(model = "Ornstein-Uhlenbeck Location (OUL)",
                                     dates = dates,
                                     parameters = pars,
                                     varianceParameters = varPars,
                                     mu = matrix(0,2,length(dates)),
                                     vel = matrix(0,0,0),
                                     sdmu = matrix(NA,2,length(dates)),
                                     sdvel = matrix(0,0,0),
                                     nauticalStates = nauticalStates,
                                     vcov = diag(Inf,0),
                                     timeunit = timeunit,
                                     data = list(),
                                     options = list(moveModelCode = 7, parnames = c("B_{1,1}","B_{2,1}","B_{1,2}","B_{2,2}","mu_1","mu_2"))
                                     )


                      },
                      simulate = function(x0 = c(0,0)){
                          "Function to simulate from the movement model. The initial states (latitudinal/y-coordinate location and longitudinal/x-coordinate location) must be given. If nauticalStates==TRUE, the result is returned in nautical miles."
                          dt <- c(1,as.numeric(difftime(tail(.self$dates,-1),
                                                        head(.self$dates,-1),
                                                        units = .self$timeunit)))
                          B <- matrix(.self$parameters[1:4],2,2)
                          sigma2 <- exp(2 * .self$varianceParameters)
                          mupar <- .self$parameters[5:6]
                          var <- function(dt){
                              meb <- as.matrix(Matrix::expm(B*dt))
                              diag(sigma2) - meb %*% diag(sigma2) %*% t(meb)
                          }
                          
                          state <- function(Xm,dt){
                              meb <- as.matrix(Matrix::expm(B*dt))
                              mupar + as.vector(meb %*% (Xm - mupar))
                          }
                          
                          X <- matrix(NA,2,length(.self$dates))
                          X[,1] <- x0
                          for(i in 2:length(.self$dates)){
                              mu0 <- state(X[,i-1],dt[i])
                              X[,i] <- rmvnorm(1,
                                               mu = mu0,
                                               sigma = var(dt[i]))
                          }
                          return(X)
                      },
                      getTMBmap = function(...){
                          "Function to create map list for TMB::MakeADFun. If equaldrift=TRUE, \\eqn{\\gamma_1} and \\eqn{\\gamma_2} are estimated as equal. If fixdrift=TRUE, \\eqn{\\gamma_1} and \\eqn{\\gamma_2} are fixed at the current value."
                          
                          map <- callSuper(...)
                          args <- list(...)
                          mpar <- 1:6
                          doit <- FALSE

                          if("symdecay" %in% names(args))
                              if(args$symdecay){
                                  mpar[2:3] <- 2;
                                  doit <- TRUE
                              }
                          if("diagdecay" %in% names(args))
                              if(args$diagdecay){
                                  mpar[2:3] <- NA;
                                  doit <- TRUE
                              }
                          if("equaldecay" %in% names(args))  ## gamma             
                              if(args$equaldecay){
                                  mpar[c(1,4)] <- 1;
                                  doit <- TRUE
                              }
                          if("equaldrift" %in% names(args)) ## mu
                              if(args$equaldrift){
                                  mpar[5:6] <- 5;
                                  doit <- TRUE
                              }
                          if("fixdrift" %in% names(args)) ## mu
                              if(args$fixdrift){
                                  mpar[5:6] <- NA;
                                  doit <- TRUE
                              }

                          ## Always equal decay
                          ##mpar[1:2] <- 1;
                          doit <- TRUE

                          if(doit)
                              map$movePars <- factor(mpar)

                          return(map)
                          
                      }

                  
                  )
                  )
