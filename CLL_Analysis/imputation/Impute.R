library(impute)
library(softImpute)
library(mice)
library(imputeR)

ImputeComparison <- function(mofa_object, gfa_object, fullDataList,GFA_to_MOFA_feautres, FeatureMeans=NULL){
  
  #Get data and check missing values
  data <- mofa_object@TrainData
  NMissing <- sapply(data, function(view) sum(is.na(view)))
  pMissing <- sapply(data, function(view) sum(is.na(view))/prod(dim(view)))
  pMissing <- round(pMissing,2)
  names(pMissing)<-names(data)
  FullCasesMissing <- sapply(data, function(view) sum(apply(view,2, function(r) all(is.na(r)))))
  names(FullCasesMissing)<-names(data)
  
  message(sprintf("%s has %i missing values (%g percent missing) and %i full cases missing \n", 
                  names(data),NMissing,pMissing*100, FullCasesMissing))
  
  data2impute <- do.call(rbind, data)
  NMissingTotal<-sum(NMissing)
  pMissingTotal<-NMissingTotal/prod(dim(data2impute))
  
  
  #get true data
  fullDataList <- lapply(fullDataList,t)
  truedata <- do.call(rbind,fullDataList)
  
  # get values to make predictions on with known truth
  IdxMissing<-which(is.na(data2impute) &!is.na(truedata), arr.ind = T)
  
  #Stop if no missing values
  if(sum(NMissing)==0) {
    message(sprintf("No missing values in any view"))
    return(NULL)
  }

  
  #Impute missing values using different method
  ### MOFA-based
  imp_MOFA<-imputeMissing(mofa_object)
  if(!is.null(FeatureMeans)) 
    for(viewnm in names(imp_MOFA)) imp_MOFA@ImputedData[[viewnm]]<-t(t(imp_MOFA@ImputedData[[viewnm]])+FeatureMeans[[viewnm]])
  imp_MOFA<-do.call(rbind, imp_MOFA@ImputedData)
  
  ##Use GFA
  imp_GFA <- GFA::reconstruction(gfa_object)
  imp_GFA <- t(imp_GFA[,GFA_to_MOFA_feautres])
  stopifnot(all(rownames(imp_MOFA) == rownames(imp_GFA)))
  
  ##Use GFA - point
  imp_GFA_point <- gfa_object$X %*% t(gfa_object$W)
  imp_GFA_point <- t(imp_GFA_point[,GFA_to_MOFA_feautres])
  stopifnot(all(rownames(imp_MOFA) == rownames(imp_GFA_point)))
  ### kNN
  # Nearest-neighbor imputation
  # Made for gene expression data: Finds nearest neighbors in row space
  # and replaces missing values by averaging over those
  # does not work well if one view is masked completely 
  # as then replaced by average of vlaues from completly different views
  # here used on samples instead
  # Olga  Troyanskaya,  Michael  Cantor,  Gavin  Sherlock,  Pat  Brown,  Trevor  Hastie,  Robert  Tibshi-
  #   rani, David Botstein and Russ B. Altman, Missing value estimation methods for DNA microarrays
  # BIOINFORMATICS Vol. 17 no. 6, 2001 Pages 520-525
  imp_kNN_featurewise<-try(impute.knn((data2impute))$data)
  if(class(imp_kNN_featurewise)=="try-error") imp_kNN_featurewise <-matrix(NA, ncol=ncol(data2impute), nrow=nrow(data2impute))
  imp_kNN_samplewise<-try(t(impute.knn(t(data2impute), colmax=1)$data))
  if(class(imp_kNN_samplewise)=="try-error") imp_kNN_samplewise <- matrix(NA, ncol=ncol(data2impute), nrow=nrow(data2impute))
  # 
  # ## SOFTIMPUTE
  # Impute missing values for a matrix via nuclear-norm regularization by fitting a low-rank matrix approximation to a matrix with missing values via nuclear-norm regularization
  # Mazumder,  R.,  Hastie,  T.  &  Tibshirani,  R.  Spectral  regularization  algorithms  for 
  # learning large incomplete matrices. 
  # J. Mach. Learn. Res.11, 2287–2322 (2010)
  fit.softimpute<-softImpute(data2impute)
  imp_softimpute<-softImpute::complete(data2impute,fit.softimpute)
  
  ##Impute by Mean
  ImputeByMean <- function(x) {x[is.na(x)] <- mean(x, na.rm=TRUE); return(x)}
  imp_mean <- t(apply(data2impute,1,ImputeByMean))
  
  #Randomly sample a value from a different sample
  guess <- function(x) {x[is.na(x)] <- sample(x[!is.na(x)],1); return(x)}
  imp_guess <- t(apply(data2impute,1,guess))
  
  
  ListImputedData<-list(MOFA = imp_MOFA,
                        imp_GFA = imp_GFA,
                        imp_GFA_point =imp_GFA_point,
                        SoftImpute = imp_softimpute,
                        Guess = imp_guess,
                        imp_kNN_featurewise = imp_kNN_featurewise,
                        imp_kNN_samplewise = imp_kNN_samplewise,
                        Mean = imp_mean
  )
  
  
  #Calculate MSE on missing values
  MSE<- sapply(ListImputedData, function(impdata){
    sum((impdata[IdxMissing]-truedata[IdxMissing])^2)/nrow(IdxMissing)
  })
  names(MSE)<-names(ListImputedData)
  
  #Calculate NRMSE on missing values
  NRMSE<- sapply(ListImputedData, function(impdata){
    sqrt(sum((impdata[IdxMissing]-truedata[IdxMissing])^2)/nrow(IdxMissing))/diff(range(truedata[IdxMissing]))
  })
  names(NRMSE)<-names(ListImputedData)
  
  #Calculate correlation
  cor<-sapply(ListImputedData, function(impdata){
    cor(impdata[IdxMissing],truedata[IdxMissing])
  })
  names(cor)<-names(ListImputedData)
  
  MSEdf<-data.frame(method=names(MSE), MSE=MSE, cor=cor,NRMSE=NRMSE,
                    pNA=t(pMissing),
                    FullCasesMissing=t(FullCasesMissing),
                    NMissingTotal=NMissingTotal,
                    pMissingTotal=pMissingTotal)
  
  return(list(MSEdf= MSEdf, ListImputedData=ListImputedData))
}
