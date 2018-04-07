iClustertoMOFA <- function(iCluster.out, data){
  
  k = ncol(iCluster.out$meanZ)+1
  n = nrow(iCluster.out$meanZ)
  m = length(iCluster.out$beta)
  d = sapply(iCluster.out$beta, nrow)
  
  # nice names
  colnames(iCluster.out$meanZ) <- 1:ncol(iCluster.out$meanZ) 
  for (nm in seq_along(iCluster.out$beta)) {
    rownames(iCluster.out$beta[[nm]]) <- colnames(data[[nm]])
    colnames(iCluster.out$beta[[nm]]) <- 1:ncol(iCluster.out$meanZ)
  }
  rownames(iCluster.out$meanZ) <- rownames(data[[1]])
  
  # Z
  Z <- iCluster.out$meanZ
  Z <- cbind(intercept=1,Z)
  
  # Weights
  weightsiClust <- iCluster.out$beta
  intercept <- iCluster.out$alpha
  SW <- lapply(seq_along(weightsiClust), function(d) cbind(intercept=intercept[[d]], weightsiClust[[d]])) 
  names(SW) <- names(data)
  
  # Make MOFA object
  mofa_object <- createMOFAobject(lapply(data,t))
  mofa_object@Dimensions <- list(K=k, M=m, N=n, D=d)
  mofa_object@Status <- "trained"
  mofa_object@Expectations$Z <- Z
  for(i in seq_along(SW)) {
    mofa_object@Expectations$W[[i]] <- SW[[i]]
    mofa_object@Expectations$Y[[i]] <- data[[i]]
  }
  names(mofa_object@Expectations$W) <- names(SW)
  names(mofa_object@Expectations$Y) <- names(SW)
  
  mofa_object@ModelOpts$learnIntercept <- TRUE
  
  return(mofa_object)
}



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