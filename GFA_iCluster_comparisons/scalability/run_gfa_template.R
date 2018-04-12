suppressMessages(library(argparse))
suppressMessages(library(data.table))
suppressMessages(library(purrr))
suppressMessages(library(GFA))

# Initialize argument parser
p <- ArgumentParser(description='')
p$add_argument('-i','--inFiles', type="character", help='Input files (.txt)', nargs="+")
p$add_argument('-o','--outFile', type="character", help='Output file (.txt)')
p$add_argument('-f','--factors', type="integer", default=25, help='Number of factors')

# Read arguments
args <- p$parse_args(commandArgs(TRUE))

# args <- list()
# args$inFiles <- c(
#   "/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/input/K/5_0.txt", 
#   "/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/input/K/5_1.txt", 
#   "/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/input/K/5_2.txt", 
#   "/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/input/K/5_3.txt", 
#   "/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/input/K/5_4.txt"
# )
# args$outFile <- "/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/output/gfa/K/K_5.txt"
# args$factors <- 10


# Load data
data <- lapply(args$inFiles, function(x) fread(x) %>% as.matrix)

# Set options
opts <- getDefaultOpts()
# opts$iter.max <- 100
ptm <- proc.time()
data <- normalizeData(data, type="center")
gfa_model <- gfa(data$train, opts, K = as.numeric(args$factors))
time <- proc.time() - ptm

df <- data.frame(time=time[[3]])
write.table(df, file=args$outFile, append=T, quote=F, col.names = F, row.names = F)