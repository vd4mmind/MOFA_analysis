# devtools::load_all("/Users/ricard/mofa/MOFAtools")
devtools::load_all("/homes/ricard/mofa/MOFAtools")
suppressMessages(library(argparse))
suppressMessages(library(data.table))
suppressMessages(library(purrr))
suppressMessages(library(GFA))

# Initialize argument parser
p <- ArgumentParser(description='')
p$add_argument('-i','--inFiles',                 type="character",  help='Input files (.txt)', nargs="+")
p$add_argument('-o','--outFile',                 type="character",  help='Output file (.txt)')
p$add_argument('-maskAtRandom','--maskAtRandom', type="double",     help='Fraction of drug response values to mask at random', default=0)
p$add_argument('-maskSamples','--maskSamples',   type="integer",    help='Number of samples to mask the drug response', default=0)
p$add_argument('-k','--factors',                 type="integer",    help='Number of factors')
p$add_argument('-t','--trial',                   type="integer",    help='Trial number', default=1)

# Read arguments
args <- p$parse_args(commandArgs(TRUE))

# Load data
# data <- lapply(args$inFiles, function(x) read.table(x, header=T, sep=" ") %>% as.matrix)
# names(data) <- c("mut","viab","mRNA","meth")

# mask data at random
if (args$maskAtRandom>0) {
  print("Loading masked data from a trained MOFA model...")
  # mofa <- loadModel(paste0("/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/atRandom/mofa/k10/",args$maskAtRandom,"_drug_",args$trial,".hdf5"))
  mofa <- loadModel(paste0("/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/atRandom/mofa/grid/",args$maskAtRandom,"_",args$factors,"_",args$trial,".hdf5"))
  data_norm <- lapply(getTrainData(mofa),t)
  # print(sprintf("Masking %.2f fraction of values at random",args$maskAtRandom))
  # ND <- length(data[["viab"]])
  # mask_idx <- sample(1:ND, size=ND*args$maskAtRandom)
  # data[["viab"]][mask_idx] <- NA
}

# mask full cases
if (args$maskSamples>0) {
  print("Loading masked data from a trained MOFA model...")
  # mofa <- loadModel(paste0("/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/fullCases/mofa/k10/N",args$maskSamples,"_drug_",args$trial,".hdf5"))
  mofa <- loadModel(paste0("/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/fullCases/mofa/grid/",args$maskSamples,"_",args$factors,"_",args$trial,".hdf5"))
  data_norm <- lapply(getTrainData(mofa),t)
  # Load masked data from MOFA model
  # print(sprintf("Masking %d full samples ",args$maskSamples))
  # N <- nrow(data[["viab"]])
  # mask_idx <- sample(1:N, size=args$maskSamples)
  # data[["viab"]][mask_idx,] <- NA
}


# normalise data
# data_norm <- normalizeData(data, type="center")

# run GFA
gfa_opts <- getDefaultOpts()
# gfa_opts$iter.max <- 10
gfa_model <- gfa(data_norm, gfa_opts, K = args$factors)

# Remove unnecessary data
# gfa_model$posterior <- NULL
# gfa_model$groups <- NULL
# gfa_model$r <- NULL
# gfa_model$tau <- NULL
# gfa_model$beta <- NULL
saveRDS(gfa_model,args$outFile)

stop()

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
gfa_mofamodel@ModelOpts$likelihood <- c("gaussian","gaussian","gaussian","gaussian")
names(gfa_mofamodel@ModelOpts$likelihood) <- names(data)
  
# Sort by variance explained
r2 <- rowSums(calculateVarianceExplained(gfa_mofamodel)$R2PerFactor)
order_factors <- c(names(r2)[order(r2, decreasing = T)])
gfa_mofamodel <- subsetFactors(gfa_mofamodel,order_factors)
sampleNames(gfa_mofamodel) <- rownames(data[[1]])
factorNames(gfa_mofamodel) <- as.character(1:ncol(gfa_model$X))
featureNames(gfa_mofamodel) <- lapply(data,colnames)

# Subset factors that explain a minimum of variance
# min.var <- 0.001
# r2 <- calculateVarianceExplained(gfa_mofamodel)$R2PerFactor
# keep_factors <- rowSums(r2>min.var)>0
# gfa_mofamodel <- subsetFactors(gfa_mofamodel, keep_factors)

# Save model
saveRDS(gfa_mofamodel,paste0(args$outFile,".mofaobject"))
	