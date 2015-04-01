#include <TMB.hpp>

using namespace density;



/** \brief Multivariate t distribution with user supplied scale matrix

Class to evaluate the negative log density of a multivariate t distributed variable with general scale matrix Sigma and location vector 0 and df degrees of freedom.
*/
template <class Type>
class MVT_tt: public MVNORM_t<Type>
{
  Type df;
  bool useNorm;

public:
  MVT_tt()
    : MVNORM_t<Type>()
  {
    useNorm = false;
  };
  MVT_tt(Type df_)
    : MVNORM_t<Type>()
  {
    df = df_;
    useNorm = false;
  }
  MVT_tt(matrix<Type> Sigma_, Type df_)
    : MVNORM_t<Type>(Sigma_)
  {
    df = df_;
    useNorm = false;
  }
  MVT_tt(matrix<Type> Sigma_, Type df_, bool useNorm_)
    : MVNORM_t<Type>(Sigma_)
  {
    df = df_;
    useNorm = useNorm_;
  }

  void setdf(Type df_){
    df = df_;
  }

  /** \brief Evaluate the negative log density */
  Type operator()(vector<Type> x){
    Type p = x.size();
    //Lange et al. 1989 http://www.jstor.org/stable/2290063
    Type tdens = -lgamma(Type(0.5)*(df+p))+lgamma(Type(0.5)*df)+p*Type(0.5)*log(df)+p*lgamma(Type(0.5))-Type(0.5)*this->logdetQ + Type(0.5)*(df+p)*log(Type(1.0)+this->Quadform(x)/df);
    Type ndens = -Type(.5)*this->logdetQ + Type(.5)*this->Quadform(x) + p*Type(log(sqrt(2.0*M_PI)));

    if(useNorm) return ndens; else return tdens;
  }
};



template<class Type>
Type objective_function<Type>::operator() ()
{

  DATA_VECTOR(lon);
  DATA_VECTOR(lat);
  DATA_VECTOR(dt);
  DATA_FACTOR(qual); //Integers
  DATA_VECTOR(include);
  DATA_SCALAR(minDf);
  DATA_INTEGER(modelCode);
  PARAMETER_VECTOR(logbeta); //Length 2 (first lat then lon)
  PARAMETER_VECTOR(logSdState);
  PARAMETER_VECTOR(logSdObs); //length 2
  //DATA_MATRIX(logCorrection); //Dim 2 x number of quality classes (first should be log(1)
  PARAMETER_MATRIX(logCorrection);
  PARAMETER_VECTOR(gamma); //Length 2 (first lat then lon)
  
  PARAMETER_MATRIX(mu); // Dim 2 x lon.size()
  PARAMETER_MATRIX(vel); // Dim 2 x lon.size()

  PARAMETER_VECTOR(df);  //Length as number of quality classes

  // Number of data points to include
  PARAMETER(numdata);

  vector<Type> beta = exp(logbeta);
  vector<Type> varState = exp(Type(2.0)*logSdState);
  matrix<Type> varObs(logCorrection.rows(),logCorrection.cols()+1);
  matrix<Type> correction = logCorrection.array().exp().matrix();
  for(int i = 0; i < varObs.rows(); ++i){
    varObs(i,0) = exp(2.0*(logSdObs(i)));
    for(int j = 1; j < varObs.cols(); ++j){
      varObs(i,j) = exp(2.0*(logSdObs(i)+logCorrection(i,j-1)));
    }
  }

  matrix<Type> sdObs = varObs.array().sqrt().matrix();

  Type nll = 0.0;

  MVNORM_t<Type> nll_dist;//(df(0));
  vector<MVT_tt<Type> > nll_dist_obs(varObs.cols());

  matrix<Type> cov(4,4);
  vector<Type> state(4);
  matrix<Type> covObs(2,2);
  vector<Type> obs(2);

  //Set up covariance matrix for observations
  for(int i = 0; i < nll_dist_obs.size(); ++i){
    covObs.setZero();
    covObs(0,0) = varObs(0,i);
    covObs(1,1) = varObs(1,i);
    covObs(1,0) = 0.0; 
    covObs(0,1) = covObs(1,0);
    //ModelCode: 0: t; 1: norm
    nll_dist_obs(i) = MVT_tt<Type>(covObs,exp(df(i))+minDf,modelCode);

  }


  int c = 0;
  
  

  //
  int stateNum = 0; 

  Type test = 0.0;
  
  for(int i = 0; i < dt.size(); ++i){

    if(dt(i) > 0 && i > 0){stateNum += 1;}
    if(stateNum == 0){//Distribution for first state
      /*
      state.setZero();
      state(0) = mu(0,0)-lat(0);
      state(1) = vel(0,1);
      state(2) = mu(1,0)-lon(0);
      state(3) = vel(1,1);

      cov.setZero();
      cov(0,0) = 0.1;
      cov(1,1) = 0.1;
      cov(2,2) = 0.1;
      cov(3,3) = 0.1;

      nll_dist.setSigma(cov);
      nll += nll_dist(state);
      */
    }else if(dt(i)>0){ //Only at first time step
      //First states

      //Set up state vector
      state.setZero();
      c = 0;
      state(0) = mu(c,stateNum)-(mu(c,stateNum-1)+vel(c,stateNum-1)*(1.0-exp(-beta(c)*dt(i))/beta(c)));
      state(1) = vel(c,stateNum) - (gamma(c)+exp(-beta(c)*dt(i))*(vel(c,stateNum-1)-gamma(c)));    

      c = 1;
      state(2) = mu(c,stateNum)-(mu(c,stateNum-1)+vel(c,stateNum-1)*(1.0-exp(-beta(c)*dt(i))/beta(c)));
      state(3) = vel(c,stateNum) - (gamma(c)+exp(-beta(c)*dt(i))*(vel(c,stateNum-1)-gamma(c)));    
 
      //Set up covariance matrix
      cov.setZero();

      c = 0;
      cov(0,0) = varState(c)/pow(beta(c),2)*(dt(i)-2.0*(1.0-exp(-beta(c)*dt(i)))/beta(c)+(1.0-exp(-2*beta(c)*dt(i)))/(2.0*beta(c)));
      cov(1,1) = varState(c)*(1.0-exp(-2.0*beta(c)*dt(i)))/(2*beta(c));
      cov(1,0) = varState(c)*(1.0-2.0*exp(-beta(c)*dt(i))+exp(-2.0*beta(c)*dt(i)))/(2.0*pow(beta(c),2));
      cov(0,1) = cov(1,0);
      
      c = 1;
      cov(2,2) = varState(c)/pow(beta(c),2)*(dt(i)-2.0*(1.0-exp(-beta(c)*dt(i)))/beta(c)+(1.0-exp(-2*beta(c)*dt(i)))/(2.0*beta(c)));
      cov(3,3) = varState(c)*(1.0-exp(-2.0*beta(c)*dt(i)))/(2*beta(c));
      cov(2,3) = varState(c)*(1.0-2.0*exp(-beta(c)*dt(i))+exp(-2.0*beta(c)*dt(i)))/(2.0*pow(beta(c),2));
      cov(3,2) = cov(2,3);


	
      nll_dist.setSigma(cov);
      nll += nll_dist(state);

    }else{ //Or nothing else happens
    }

    //Then observations
    //Set up observation vector 
    obs.setZero();
    obs(0) = lat(i)-mu(0,stateNum);
    obs(1) = lon(i)-mu(1,stateNum);
    
    //Set up covariance matrix
    /*covObs.setZero();
    covObs(0,0) = varObs(0,qual(i));
    covObs(1,1) = varObs(1,qual(i));
    covObs(1,0) = 0.0; 
    covObs(0,1) = covObs(1,0);
    

    nll_dist_obs.setSigma(covObs);
    */
    //if(include(i)==1){
    Type keep = CppAD::CondExpLt(Type(i), numdata, Type(1), Type(0));
    nll += nll_dist_obs(qual(i))(obs)*include(i)*keep;
    test += CppAD::CondExpEq(Type(i),numdata,obs,Type(0));
	//}
  }
  vector<Type> dfs = exp(df)+minDf;
  ADREPORT(correction);
  ADREPORT(sdObs);
  ADREPORT(dfs);
  ADREPORT(test);
  return nll;
  
}