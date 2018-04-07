# devtools::load_all("/Users/ricard/mofa/MOFAtools")
devtools::load_all("/homes/ricard/mofa/MOFAtools")
library(GFA)
library(data.table)
library(purrr)



# Define I/O
io <- list()
# io$indir <- "/Users/ricard/data/MOFA/simulations/data/iCluster"
# io$outdir <- "/Users/ricard/data/MOFA/simulations/results/iCluster"
io$indir <- "/hps/nobackup/stegle/users/ricard/MOFA/simulations/data/iCluster"
io$outdir <- "/hps/nobackup/stegle/users/ricard/MOFA/simulations/results/iCluster"

opts <- list()
opts$K <- 25

# Load data
# data.files <- c(paste0(io$indir,"/10_0.txt"),paste0(io$indir,"/10_1.txt"),paste0(io$indir,"/10_2.txt"))
# data.files <- c(paste0(io$indir,"/15_0.txt"),paste0(io$indir,"/15_1.txt"),paste0(io$indir,"/15_2.txt"))
data.files <- c(paste0(io$indir,"/20_0.txt"),paste0(io$indir,"/20_1.txt"),paste0(io$indir,"/20_2.txt"))
data <- lapply(data.files, function(x) fread(x) %>% as.matrix)
names(data) <- c("view_1","view_2","view_3")

# normalise data
data_norm <- normalizeData(data, type="center")

# run GFA
gfa_opts <- getDefaultOpts()
# gfa_opts$iter.max <- 10
gfa_model <- gfa(data_norm$train, gfa_opts, K = opts$K)


# Convert GFAobject to MOFAobject


# Parse W
D <- sapply(data_norm$train,ncol)
M <- length(data)
tmp <- rep(NA,sum(D))
for (m in 1:M) {
	  if (m==1) {
		      tmp[1:D[m]] <- m
  } else {
	      tmp[(cumsum(D)[m-1]+1):cumsum(D)[m]] <- m
    }
}
W <- gfa_model$W
W <- cbind(W,tmp)
W_split <- lapply( split( W[,1:ncol(W)-1], W[,ncol(W)] ), matrix, ncol=ncol(W)-1)
names(W_split) <- names(data)

# Parse Alpha
Alpha_split <- split(gfa_model$Z, row(gfa_model$Z))
names(Alpha_split) <- names(data)
  
# Create a MOFA object
gfa_mofamodel <- createMOFAobject(map(data_norm$train,t))
gfa_mofamodel@ModelOpts$learnIntercept <- F
gfa_mofamodel@TrainData <- map(data_norm$train,t)
gfa_mofamodel@Expectations <- list("Y"=data_norm$train, "Z"=gfa_model$X, "W"=W_split, "Alpha"=Alpha_split)
gfa_mofamodel@Dimensions[["K"]] <- ncol(gfa_model$X)
viewNames(gfa_mofamodel) <- names(data)
sampleNames(gfa_mofamodel) <- as.character(1:nrow(data[[1]]))
factorNames(gfa_mofamodel) <- as.character(1:ncol(gfa_model$X))
gfa_mofamodel@Status <- "trained"
gfa_mofamodel@ModelOpts$likelihood <- c("gaussian","gaussian","gaussian")
names(gfa_mofamodel@ModelOpts$likelihood) <- names(data)
  
# Sort by variance explained
r2 <- rowSums(calculateVarianceExplained(gfa_mofamodel)$R2PerFactor)
order_factors <- c(names(r2)[order(r2, decreasing = T)])
gfa_mofamodel <- subsetFactors(gfa_mofamodel,order_factors)
# sampleNames(gfa_mofamodel) <- rownames(data[[1]])
# factorNames(gfa_mofamodel) <- as.character(1:ncol(gfa_model$X))
# featureNames(gfa_mofamodel) <- lapply(data,colnames)

# saveRDS(gfa_mofamodel, paste0(io$outdir,"/gfa/gfa_ktrue10_kstart25.rds"))
# saveRDS(gfa_mofamodel, paste0(io$outdir,"/gfa/gfa_ktrue15_kstart25.rds"))
saveRDS(gfa_mofamodel, paste0(io$outdir,"/gfa/gfa_ktrue20_kstart20.rds"))
	