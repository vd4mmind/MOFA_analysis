###############################################################
## Script to generate data for robustness under downsampling ##
###############################################################

library(data.table)

# I/O
io <- list()
# io$indir <- "/Users/ricard/data/CLL/views/minView=2"
# io$outdir <- "/Users/ricard/data/downsample/data"
io$indir <- "/hps/nobackup/stegle/users/ricard/CLL/views/minView=2"
io$outdir <- "/hps/nobackup/stegle/users/ricard/robustness/data"; dir.create(io$outdir)

# Load data
data <- list()
data[["mRNA"]] <- read.table(paste0(io$indir,"/mRNA.txt"), header=T)
data[["Methylation"]] <- read.table(paste0(io$indir,"/meth.txt"), header=T)
data[["Drugs"]] <- read.table(paste0(io$indir,"/viab.txt"), header=T)
data[["Mutations"]] <- read.table(paste0(io$indir,"/mut.txt"), header=T)


# Define downsampling settings
opts <- list()
opts$range_samples <- as.character(seq(76,100,1))  # Range of samples to downsample
# opts$range_samples <- "15"  # Range of samples to downsample
opts$trials <- 25                                # Number of trials

# Start downsampling
nsamples <- nrow(data[["mRNA"]])
data_downsampled <- vector("list", length = length(opts$range_samples))
for (n in opts$range_samples) {
  data_downsampled[[n]] <- list()
  for (trial in 1:opts$trials) {
    print(paste0(n,":",trial))
    
    # Select samples to keep
    samples_to_keep <- sample(1:nsamples, size=nsamples-as.numeric(n))
    
    data_downsampled[[n]][[trial]] <- data
    for (view in names(data_downsampled[[n]][[trial]])) {
      
      # Remove samples
      data_downsampled[[n]][[trial]][[view]] <- data_downsampled[[n]][[trial]][[view]][samples_to_keep,]
      
      # Save
      outfile <- paste0(io$outdir,"/",n,"_",trial,"_",view,".txt")
      # write.table(data_downsampled[[n]][[trial]][[view]], outfile, col.names=T, row.names=T, sep=" ", quote=F)
      fwrite(round(data_downsampled[[n]][[trial]][[view]],3), outfile, col.names=T, row.names=T, sep=" ", quote=F, na="NA")
    }
  }
}
