iClustertoMOFA <- function(iCluster.out, data){
  
  nLambda = nrow(iCluster.out$lambda)
  k = ncol(iCluster.out$fit[[1]]$meanZ)
  n = nrow(iCluster.out$fit[[1]]$meanZ)
  m = length(iCluster.out$fit[[1]]$beta)
  d = sapply(iCluster.out$fit[[1]]$beta, nrow)
  bic <- sapply(iCluster.out$fit, function(f) f$BIC)
  bestFitIdx <- which.min(bic)
  bestFit <- iCluster.out$fit[[bestFitIdx]]

# nice names
  colnames(bestFit$meanZ) <- 1:ncol(bestFit$meanZ) 
  for (nm in seq_along(bestFit$beta)) {
    rownames(bestFit$beta[[nm]]) <- colnames(data[[nm]])
    colnames(bestFit$beta[[nm]]) <- 1:ncol(bestFit$meanZ)
  }
  rownames(bestFit$meanZ) <- rownames(data[[1]])
  
  # Z
  Z <- bestFit$meanZ
  Z <- cbind(intercept=1,Z)
  
# Weights
  weightsiClust <- bestFit$beta
  intercept <- bestFit$alpha
  SW <- lapply(seq_along(weightsiClust), function(d) cbind(intercept=intercept[[d]], weightsiClust[[d]])) 
  names(SW) <- names(data)

  # Make MOFA object
  mofa_object <- MOFAtools::createMOFAobject(lapply(data,t))
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