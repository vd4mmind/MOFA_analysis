# devtools::load_all("/Users/ricard/mofa/MOFAtools")
devtools::load_all("/homes/ricard/mofa/MOFAtools")
library(GFA)
library(data.table)
library(purrr)

data("CLL_data")

CLL_data <- lapply(CLL_data,t)
CLL_data_norm <- normalizeData(CLL_data, type="center")

opts <- getDefaultOpts()

ptm <- proc.time()
gfa_model_tmp <- gfa(CLL_data_norm$train, opts, K = 50)
gfa_time <- proc.time() - ptm


# Parse W
D <- sapply(CLL_data_norm$train,ncol)
M <- length(CLL_data)
tmp <- rep(NA,sum(D))
for (m in 1:M) {
	  if (m==1) {
		      tmp[1:D[m]] <- m
  } else {
	      tmp[(cumsum(D)[m-1]+1):cumsum(D)[m]] <- m
    }
}
W <- gfa_model_tmp$W
W <- cbind(W,tmp)
W_split <- lapply( split( W[,1:ncol(W)-1], W[,ncol(W)] ), matrix, ncol=ncol(W)-1)
names(W_split) <- names(CLL_data)

# Parse Alpha
Alpha_split <- split(gfa_model_tmp$Z, row(gfa_model_tmp$Z))
names(Alpha_split) <- names(CLL_data)
  
# Create a MOFA object
gfa_model <- createMOFAobject(map(CLL_data_norm$train,t))
gfa_model@ModelOpts$learnIntercept <- F
gfa_model@TrainData <- map(CLL_data_norm$train,t)
gfa_model@Expectations <- list(
			         "Y"=CLL_data_norm$train,
				   "Z"=gfa_model_tmp$X,
				     "W"=W_split,
				       "Alpha"=Alpha_split
				 )
gfa_model@Dimensions[["K"]] <- ncol(gfa_model_tmp$X)
viewNames(gfa_model) <- names(CLL_data)
sampleNames(gfa_model) <- as.character(1:nrow(CLL_data[[1]]))
factorNames(gfa_model) <- as.character(1:ncol(gfa_model_tmp$X))
gfa_model@Status <- "trained"
gfa_model@ModelOpts$likelihood <- c("gaussian","gaussian","gaussian","gaussian")
names(gfa_model@ModelOpts$likelihood) <- names(CLL_data)
  
# Sort by variance explained
r2 <- rowSums(calculateVarianceExplained(gfa_model)$R2PerFactor)
order_factors <- c(names(r2)[order(r2, decreasing = T)])
gfa_model <- subsetFactors(gfa_model,order_factors)
sampleNames(gfa_model) <- rownames(CLL_data[[1]])
factorNames(gfa_model) <- as.character(1:ncol(gfa_model_tmp$X))
featureNames(gfa_model) <- lapply(CLL_data,colnames)
saveRDS(gfa_model, "/homes/ricard/mofa_rebuttal/gfa_comparison/cll/out/gfa20.rds")

# write.table(data.frame(time=gfa_time), file="/homes/ricard/mofa_rebuttal/gfa_comparison/cll/out/gfatime.txt", col.names=F, row.names=F, quote=F)
