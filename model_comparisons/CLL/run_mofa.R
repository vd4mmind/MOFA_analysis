devtools::load_all("/Users/ricard/mofa/MOFAtools")
# devtools::load_all("/homes/ricard/mofa/MOFAtools")
library(data.table)
library(purrr)

# Load data
data("CLL_data")
CLL_data <- lapply(CLL_data,t)

# create MOFA object
mofa_model <- createMOFAobject(lapply(CLL_data,t))

# Define I/O options
DirOptions <- list("dataDir" = tempdir(), "outFile" = tempfile())

# Define data options
DataOptions <- getDefaultDataOpts()

# Define training options
TrainOptions <- getDefaultTrainOpts()
TrainOptions$maxiter <- 3000
TrainOptions$tolerance <- 0.01
TrainOptions$learnFactors <- TRUE
TrainOptions$DropFactorThreshold <- 0.02

# Define model options
ModelOptions <- getDefaultModelOpts(mofa_model)
ModelOptions$sparsity <- T
ModelOptions$numFactors <- 25

# Prepare MOFA
mofa_model <- prepareMOFA(mofa_model, DataOptions = DataOptions, DirOptions = DirOptions,
	ModelOptions = ModelOptions, TrainOptions = TrainOptions)

mofa_model <- runMOFA(mofa_model, DirOptions, mofaPath="/Users/ricard/anaconda2/bin/mofa")
