
# devtools::load_all("/Users/ricard/mofa/MOFAtools")
devtools::load_all("/homes/ricard/mofa/MOFAtools")
library(data.table)
library(purrr)
library(iClusterPlus)
library(doParallel)

# User-defined functions
impute <- function(d, margin) {
  if (margin == 1)
    means <- rowMeans(d, na.rm=T)
  else if (margin == 2)
    means <- colMeans(d, na.rm=T)
  else
    stop("Margin has to be either 1 (rows) or 2 (cols)")
  
  if (any(is.na(means))) {
    stop('Insufficient data for mean imputation!')
  }
  
  for (i in 1:length(means)) {
    if (margin == 1)
      d[i,is.na(d[i,])] <- means[i]
    else if (margin == 2)
      d[is.na(d[,i]), i] <- means[i]
  }
  return (d)
}

# Load data
data("CLL_data")
CLL_data <- lapply(CLL_data,t)


# Impute missing data
CLL_data[["Drugs"]] <- impute(CLL_data[["Drugs"]], margin = 2)
CLL_data[["mRNA"]] <- impute(CLL_data[["mRNA"]], margin = 2)
CLL_data[["Methylation"]] <- impute(CLL_data[["Methylation"]], margin = 2)
CLL_data[["Mutations"]] <- round(impute(CLL_data[["Mutations"]], margin = 2))

# Center the data
CLL_data[["Drugs"]] <- scale(CLL_data[["Drugs"]], center = TRUE)
CLL_data[["mRNA"]] <- scale(CLL_data[["mRNA"]], center = TRUE)
CLL_data[["Methylation"]] <- scale(CLL_data[["Methylation"]], center = TRUE)

# Options
# Krange = 1:20
Krange = 1:20
ncpus = 10

# iCluster model selection with grid search 
doParallel::registerDoParallel(cores=ncpus)
tuned.out <- list()
for (k in Krange) {
  print(k)
  tuned.out[[k]] <- tune.iClusterPlus(
    cpus = ncpus, 
    dt1=CLL_data[["Drugs"]], dt2=CLL_data[["mRNA"]], dt3=CLL_data[["Methylation"]], dt4=CLL_data[["Mutations"]],
    type=c("gaussian","gaussian","gaussian","binomial"), K=k)
}
save(tuned.out,"/homes/ricard/mofa_rebuttal/gfa_comparison/cll/out/iCluster_CLL10.Rdata")
