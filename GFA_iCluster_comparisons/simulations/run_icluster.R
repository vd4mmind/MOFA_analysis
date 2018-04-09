
# this script can be run in parallel using run_icluster.sh

# devtools::load_all("/Users/ricard/mofa/MOFAtools")
devtools::load_all("/homes/ricard/mofa/MOFAtools")
suppressMessages(library(argparse))
suppressMessages(library(data.table))
suppressMessages(library(purrr))
library(iClusterPlus)
library(doParallel)

# Initialize argument parser
p <- ArgumentParser(description='')
p$add_argument('-i','--inFiles',                 type="character",  help='Input files (.txt)', nargs="+")
p$add_argument('-o','--outFile',                 type="character",  help='Output file (.txt)')
p$add_argument('-v','--views',                 	 type="character",  help='View names', nargs="+")
p$add_argument('-l','--likelihoods',             type="character",  help='Likelihood types', nargs="+")
p$add_argument('-k','--factors',                 type="integer",    help='Maximum number of factors')
p$add_argument('-c','--cores',                   type="integer",    help='Number of cores for parallel computation')


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


# Read arguments
args <- p$parse_args(commandArgs(TRUE))

# args <- list()
# args$inFiles <- c(
# 	"/Users/ricard/data/MOFA_revision/simulations/joint/data/trial0_0.txt",
# 	"/Users/ricard/data/MOFA_revision/simulations/joint/data/trial0_1.txt",
# 	"/Users/ricard/data/MOFA_revision/simulations/joint/data/trial0_2.txt"
# 	)
# args$outFile = "/Users/ricard/data/MOFA_revision/simulations/joint/results/icluster_simulation_nongaussian_0.RData"
# args$views <- c("gaussian","bernoulli","poisson")
# args$likelihoods <- c("gaussian","binomial","poisson")
# args$factors <- 5
# args$cores <- 1

# QC
stopifnot(length(args$views)==3)
stopifnot(length(args$likelihoods)==3)
stopifnot(length(args$inFiles)==3)
stopifnot(all(args$likelihoods%in%c("binomial","gaussian","poisson")))

# Load data
data <- lapply(args$inFiles, function(x) read.table(x, header=FALSE, sep=" ") %>% as.matrix)
names(data) <- args$views

# Impute missing values
for (i in 1:length(args$views)) {
	if (args$likelihoods[[i]] == "gaussian") {
		data[[i]] <- impute(data[[i]],margin=2)
	} else {
		data[[i]] <- round(impute(data[[i]],margin=2))
	}
}

# Remove features with no variance
for (i in 1:length(args$views)) {
	variableFeatures <- apply(data[[i]],2,var)>0
	data[[i]] <- data[[i]][,variableFeatures]
}

# Center the gaussian data
data[["gaussian"]] <- scale(data[["gaussian"]], center = TRUE)

# iCluster model selection with grid search 
doParallel::registerDoParallel(cores=args$cores)
tuned.out <- tune.iClusterPlus(
  cpus = args$cores, 
  dt1=data[[1]], dt2=data[[2]], dt3=data[[3]],
  type=c(args$likelihoods[1],args$likelihoods[2],args$likelihoods[3]), K=args$factors,
  eps=1.0e-3, maxiter=10)

# save(tuned.out, file=paste("cv.fit.k",k,".Rdata",sep=""))
save(tuned.out, file=args$outFile)


