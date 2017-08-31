library(impute)
library(softImpute)
library(mice)
library(imputeR)

ImputeBenchmark<-function(model, fullDataList, FeatureMeans=NULL){
  
  #Get data and check missing values
  data <- model@TrainData
  NMissing <- sapply(data, function(view) sum(is.na(view)))
  pMissing <- sapply(data, function(view) sum(is.na(view))/prod(dim(view)))
  pMissing <- round(pMissing,2)
  names(pMissing)<-names(data)
  FullCasesMissing <- sapply(data, function(view) sum(apply(view,2, function(r) all(is.na(r)))))
  names(FullCasesMissing)<-names(data)
  
  message(sprintf("%s has %i missing values (%g percent missing) and %i full cases missing \n", 
                  names(data),NMissing,pMissing*100, FullCasesMissing))
  
  data2impute<-do.call(rbind, data)
  NMissingTotal<-sum(NMissing)
  pMissingTotal<-NMissingTotal/prod(dim(data2impute))
  
  
  #get true data
  fullDataList <- lapply(fullDataList,t)
  truedata<-do.call(rbind,fullDataList)
  
  # get values to make predictions on with known truth
  IdxMissing<-which(is.na(data2impute) &!is.na(truedata), arr.ind = T)
  
  #Stop if no missing values
  if(sum(NMissing)==0) {
    message(sprintf("No missing values in any view"))
    return(NULL)
  }

  
  #Impute missing values using different method
  ### MOFA-based
  imp_MOFA<-imputeMissing(model)
  if(!is.null(FeatureMeans)) 
    for(viewnm in names(imp_MOFA)) imp_MOFA@ImputedData[[viewnm]]<-t(t(imp_MOFA@ImputedData[[viewnm]])+FeatureMeans[[viewnm]])
  imp_MOFA<-do.call(rbind, imp_MOFA@ImputedData)
  
  ##Use GFA package
  # NOTW WORKING WITH MISSING VALUES
  # library(CCAGFA)
  # opts = getDefaultOpts()
  # opts$verbose = T
  # dataNoNA<-lapply(data, function (dat) dat[apply(dat,1, function(r) !any(is.na(r))),])
  # commonPats<-Reduce(intersect, lapply(dataNoNA, rownames))
  # dataNoNA<-lapply(dataNoNA, function(dat) dat[commonPats,])
  # gfa_fit<-GFA(dataNoNA, 50, opts)
  
  
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
  ### kNN 
  # "Data Mining with R, learning with case studies" by Luis Torgo, CRC Press 2010
  # library(DMwR)
  # imp_kNN<-knnImputation(data2impute)

  # ## SOFTIMPUTE
  # Impute missing values for a matrix via nuclear-norm regularization by fitting a low-rank matrix approximation to a matrix with missing values via nuclear-norm regularization
  # Mazumder,  R.,  Hastie,  T.  &  Tibshirani,  R.  Spectral  regularization  algorithms  for 
  # learning large incomplete matrices. 
  # J. Mach. Learn. Res.11, 2287–2322 (2010)
  fit.softimpute<-softImpute(data2impute)
  imp_softimpute<-softImpute::complete(data2impute,fit.softimpute)
  
  # # ## MICE
  # # Generates Multivariate Imputations by Chained Equations. Each column is computed from the other columns using predictive mean matching (default for numeric data) or other methods.
  # fit.mice<-mice(data2impute)
  # imp_mice<-mice::complete(fit.mice)
  
  
  ##Impute by Mean
  ImputeByMean <- function(x) {x[is.na(x)] <- mean(x, na.rm=TRUE); return(x)}
  imp_mean <- t(apply(data2impute,1,ImputeByMean))
  
  # ##Impute by Lasso
  # out.lasso<-imputeR::impute(data2impute, lmFun = "lassoR")
  # imp_lasso<-out.lasso$imp
  # 
  # ##Impute by Ridge
  # out.ridge<-imputeR::impute(data2impute, lmFun = "ridgeR")
  # imp_ridge<-out.ridge$imp
  # 
  # ##Impute by pcr
  # out.pcr<-imputeR::impute(data2impute, lmFun = "pcrR")
  # imp_pcr<-out.pcr$imp
  
  #Randomly sample a value from a different sample
  guess <- function(x) {x[is.na(x)] <- sample(x[!is.na(x)],1); return(x)}
  imp_guess <- t(apply(data2impute,1,guess))
  
  
  ListImputedData<-list(MOFA = imp_MOFA,
                        # kNN = imp_kNN,
                        SoftImpute = imp_softimpute,
                        # mice = imp_mice,
                        # Lasso= imp_lasso,
                        # Ridge = imp_ridge,
                        # PCR = imp_pcr,
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

# 
# ################
# # Single view version
# ###############
# 


ImputeBenchmarkOneView<-function(model, viewnm, truedata){

  #Get data and check missing values
  data <- model@TrainData
  
  data2impute <- data[[viewnm]]
  NMissing<-sum(is.na(data2impute))
  pMissing <- NMissing/prod(dim(data2impute))
  NSamplesMissing <- sum(apply(data2impute,1, function(r) all(is.na(r))))
  IdxMissing<-which(is.na(data2impute), arr.ind = T)
  message(sprintf("Data has %i missing values, %f percent missing", NMissing, pMissing*100 ))

  #Stop if no missing values
  if(NMissing==0) {
    message(sprintf("No missing values in view %s", viewnm))
    return(NULL)
  }

  #Impute missing values using different method

  ### MOFA-based
  imp_MOFA<-imputeMissing(model, viewnms=viewnm)@ImputedData[[viewnm]]

  ### kNN for gene expression by gene-neighbors
  # Nearest-neighbor imputation
  # Olga  Troyanskaya,  Michael  Cantor,  Gavin  Sherlock,  Pat  Brown,  Trevor  Hastie,  Robert  Tibshi-
  #   rani, David Botstein and Russ B. Altman, Missing value estimation methods for DNA microarrays
  # BIOINFORMATICS Vol. 17 no. 6, 2001 Pages 520-525
  imp_kNN_samplewise<-(impute.knn((data2impute))$data)
  imp_kNN_featurewise<-t(impute.knn(t(data2impute))$data)
  
  ### kNN 
  # "Data Mining with R, learning with case studies" by Luis Torgo, CRC Press 2010
  #Requires at least 10 feautres with no missing values at all?
  # library(DMwR)
  # imp_kNN<-knnImputation(data2impute)
  
  # ## SOFTIMPUTE
  # Impute missing values for a matrix via nuclear-norm regularization by fitting a low-rank matrix approximation to a matrix with missing values via nuclear-norm regularization
  # Mazumder,  R.,  Hastie,  T.  &  Tibshirani,  R.  Spectral  regularization  algorithms  for 
  # learning large incomplete matrices. 
  # J. Mach. Learn. Res.11, 2287–2322 (2010)
  fit.softimpute<-softImpute(data2impute)
  imp_softimpute<-softImpute::complete(data2impute,fit.softimpute)
  
  # # ## MICE
  # # Generates Multivariate Imputations by Chained Equations. Each column is computed from the other columns using predictive mean matching (default for numeric data) or other methods.
  # fit.mice<-mice(data2impute)
  # imp_mice<-mice::complete(fit.mice)
  
  
  ##Impute by Mean
  ImputeByMean <- function(x) {x[is.na(x)] <- mean(x, na.rm=TRUE); return(x)}
  imp_mean<-apply(data2impute,2,ImputeByMean)
  
  # ##Impute by Lasso
  # out.lasso<-imputeR::impute(data2impute, lmFun = "lassoR")
  # imp_lasso<-out.lasso$imp
  # 
  # ##Impute by Ridge
  # out.ridge<-imputeR::impute(data2impute, lmFun = "ridgeR")
  # imp_ridge<-out.ridge$imp
  # 
  # ##Impute by pcr
  # out.pcr<-imputeR::impute(data2impute, lmFun = "pcrR")
  # imp_pcr<-out.pcr$imp
  
  #Randomly sample a value from a different sample
  guess <- function(x) {x[is.na(x)] <- sample(x[!is.na(x)],1); return(x)}
  imp_guess<-apply(data2impute,2,guess)
  
  
  ListImputedData<-list(MOFA = imp_MOFA,
                        # kNN = imp_kNN,
                        SoftImpute = imp_softimpute,
                        # mice = imp_mice,
                        # Lasso= imp_lasso,
                        # Ridge = imp_ridge,
                        # PCR = imp_pcr,
                        Guess = imp_guess,
                        imp_kNN_samplewise = imp_kNN_samplewise,
                        imp_kNN_featurewise = imp_kNN_featurewise,
                        Mean = imp_mean
  )
  #Calculate MSE on missing values
  MSE<- sapply(ListImputedData, function(impdata){
    sum(((impdata[IdxMissing]-truedata[IdxMissing])^2))/NMissing
  })
  
  #Calculate NRMSE on missing values
  NRMSE<- sapply(ListImputedData, function(impdata){
    sqrt(sum((impdata[IdxMissing]-truedata[IdxMissing])^2)/NMissing)/diff(range(truedata[IdxMissing]))
  })
  names(NRMSE)<-names(ListImputedData)
  
  #Calculate correlation
  cor<-sapply(ListImputedData, function(impdata){
    cor(impdata[IdxMissing],truedata[IdxMissing])
  })

  MSEdf<-data.frame(method=names(MSE), MSE=MSE, NRMSE=NRMSE, cor=cor, percNA=pMissing,
                    NSamplesMissing=NSamplesMissing, NMissing=NMissing,
                    fracNMissing=NSamplesMissing/nrow(data2impute))

  return(list(MSEdf= MSEdf, ListImputedData=ListImputedData))
}