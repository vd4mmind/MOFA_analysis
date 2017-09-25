# Survival Downsampling:

library(MOFAtools)
library(dplyr)
library(reshape2)
library(pheatmap)
library(survival)
library(gridExtra)
library(ggplot2)
library(magrittr)
library(Hmisc)
library(glmnet)

predictSurvival <- function(model){ 

# get survival data
# load("/Users/ricard/data/CLL/pace/data/patmeta.RData")
load("/hps/nobackup/stegle/users/ricard/CLL/pace/data/patmeta.RData")
survivalData <- as.matrix(patmeta[,c("T5","treatedAfter")])
survivalData <- survivalData[!is.na(survivalData[,1]),]
colnames(survivalData)<-c("time", "status")

# get MOFA factors and data
Z <- getFactors(model, include_intercept = F)
data <- getTrainData(model)

# subset to common patients
commonPats <- intersect(rownames(Z), rownames(survivalData))
Zcommon <- Z[commonPats,]
survivalData <- survivalData[commonPats,]
dataCommmon <- lapply(data, function(dd) dd[,commonPats])

# construct survival object
SurvObject <-Surv(survivalData[,1],survivalData[,2])

#stratified CV to include same proportion of uncensored cases
set.seed(1290)
uncensored <- SurvObject[,"status"]==1
cv_ix <- dismo::kfold(1:length(commonPats), k=5, by=uncensored)

# fit a cox model and predict on left-out fold
CI_acrossRuns <- sapply(unique(cv_ix), function(i){
  
  #fit coxph for reduced
  c =  coxph(SurvObject[cv_ix!=i,]  ~Zcommon[cv_ix!=i,])
  p =  as.matrix(Zcommon[cv_ix==i,]) %*% coef(c)
  CI = apply(-p,2, rcorr.cens, SurvObject[cv_ix==i])[1,]
})

return(c(mean_CI = mean(CI_acrossRuns), sd_CI = sd(CI_acrossRuns),
            n= length(CI_acrossRuns), se_CI = sd(CI_acrossRuns)/sqrt(length(CI_acrossRuns))))
}