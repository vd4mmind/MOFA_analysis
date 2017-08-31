# contains useful function for survival predicition

#lasso cox regression and C index calculation
LassoHarrellsC <- function(response.survival, design, cv_ix,ncv=10, nfolds=3, nfolds.Hc=NULL){

  if(is.null(cv_ix) & !is.null(nfolds.Hc)){
    stopifnot(!is.null(nfolds.Hc)) 
    #stratified CV to include same proportion of uncensored cases
    uncensored<-response.survival[,"status"]==1
    cv_ix <- kfold(1:nrow(response.survival), k=nfolds.Hc, by=uncensored)
  } else if(!is.null(cv_ix)){
    if(!is.null(nfolds.Hc)) { if(nfolds.Hc!=length(unique(cv_ix))) warning("Over-writing nfolds.Hc to correspond to given cv_ix")}
    nfolds.Hc<-length(unique(cv_ix))
  }
  else stop("Either nfolcs.Hc or cv_ix need to be specified")
  
  Hc<-data.frame()
  coeffs<-data.frame()
  for(i in unique(cv_ix)){
    if(ncol(design)>1){
      cvr.out<-cvr.glmnet(design[cv_ix!=i,],response.survival[cv_ix!=i,], family="cox", nfolds=nfolds, ncv=ncv)
      lambda.min <- cvr.out$lambda[which.min(cvr.out$cvm)]
      c <- glmnet(design[cv_ix!=i,],response.survival[cv_ix!=i,], family="cox", lambda=cvr.out$lambda)
      coeffs<-rbind(coeffs,as.vector(coef(c, lambda.min)))
      p <- predict.coxnet(c, design[cv_ix==i,], s= lambda.min)
      stopifnot(!is.nan(rcorr.cens(-p,Surv(response.survival[cv_ix==i,]))[1]))
    } else {
      warning("ncol =1, use standard cox model")
      df<-data.frame(s=Surv(response.survival)[cv_ix!=i,], x=design[cv_ix!=i,])
      cox.fit<-coxph(s~x, df)
      p<-predict(cox.fit, newdata=data.frame(x=design[cv_ix==i,]))
    }
    citmp<-rcorr.cens(-p,Surv(response.survival[cv_ix==i,]))[1]
    names(citmp)<-NULL
    Hc <- rbind(Hc, data.frame(CI=citmp, cv_idx=i))
  }
  if(ncol(design)>1) colnames(coeffs)<-colnames(design) else coeffs<-"NULL"
  
  return(list(Hc=Hc, coeffs=coeffs))
}



#from gm
#eb ridge cox regression and C index calculation
ecoxph <- function(X, surv, tol=1e-3, max.iter=50){
  if(class(X)=="data.frame" | class(X)=="numeric")
    X = as.matrix(X)
  beta0 = rep(0,ncol(X))
  beta1 = rep(1,ncol(X))
  sigma2 = 1
  iter = 1
  while(max(abs(beta1-beta0))>tol& iter < max.iter){
    fit = coxph(surv ~ ridge(X, theta=1/sigma2, scale=FALSE))
    sigma2 = (1 + sum((fit$coefficients-mean(fit$coefficients))^2))/(ncol(X))   
    beta0 = beta1
    beta1 = fit$coefficients
    #cat(beta1,"\n")
    #cat(sigma,"\n")
    iter = iter+1
  }
  fit$sigma2 = sigma2
  names(fit$coefficients) = colnames(X)
  return(fit)
}
