##############################################################################
## Script to generate data for imputation of particular samples or features ##
##############################################################################

library(data.table)

# I/O
io <- list()
io$indir_incomplete <- "/Users/ricard/data/CLL/views/minView=2"
io$indir_complete <- "/Users/ricard/data/CLL/views/minView=all"
io$outdir <- "/Users/ricard/mofa_cll/imputation/examples/data"; dir.create(io$outdir)
# io$indir_incomplete <- "/hps/nobackup/stegle/users/ricard/CLL/views/minView=2"
# io$indir_complete <- "/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
# io$outdir <- "/hps/nobackup/stegle/users/ricard/downsample/data"; dir.create(io$outdir)

# Load data
data <- list()
# data[["mRNA"]] <- read.table(paste0(io$indir_incomplete,"/mRNA.txt"), header=T)
# data[["Methylation"]] <- read.table(paste0(io$indir_incomplete,"/meth.txt"), header=T)
data[["Drugs"]] <- read.table(paste0(io$indir_incomplete,"/viab.txt"), header=T)
# data[["Mutations"]] <- read.table(paste0(io$indir_incomplete,"/mut.txt"), header=T)

# Define options
opts <- list()

# Samples to mask
opts$samples_tomask <- c("H050","H235","H170","H236","H135","H042","H164","H012","H252","H211")

# Features to mask
# opts$features_tomask <- "all"
opts$features_tomask <- c(
  "D_078_1", "D_078_2", "D_078_3", "D_078_4", "D_078_5",
  "D_020_1", "D_020_2", "D_020_3", "D_020_4", "D_020_5",
  "D_017_1", "D_017_2", "D_017_3", "D_017_4", "D_017_5",
  "D_050_1", "D_050_2", "D_050_3", "D_050_4", "D_050_5",
  "D_077_1", "D_077_2", "D_077_3", "D_077_4", "D_077_5"
  )

# Mask the data
if (paste0(opts$features_tomask,collapse="")=="all") {
  print("Masking all features")
  data[["Drugs"]][opts$samples_tomask,] <- NA
} else {
  print("Masking individual features")
  stopifnot(all(opts$feature_to_mask%in%colnames(data[["Drugs"]])))
  data[["Drugs"]][opts$samples_tomask,opts$features_tomask] <- NA
}

# Save
if (paste0(opts$features_tomask,collapse="")=="all") {
  fwrite(data[["Drugs"]], paste0(io$outdir,"/drug_masked_all.txt"), col.names=T, row.names=T, sep=" ", quote=F, na="NA")
} else {
  fwrite(data[["Drugs"]], paste0(io$outdir,"/drug_masked.txt"), col.names=T, row.names=T, sep=" ", quote=F, na="NA")
}
