##############################################
## Script to generate data for downsampling ##
##############################################

# The aim of the downsampling analysis is to test that having an incomplete data set gives you more power than a complete data set removing the missing samples.
# This script generates two data sets:
# (1) Incomplete data set with missing values
# (2) Complete data set with mising values imputed by mean


# I/O
io <- list()
# io$indir <- "/Users/ricard/data/CLL/views/minView=2"
# io$outdir <- "/Users/ricard/data/downsample/data"
io$indir <- "/hps/nobackup/stegle/users/ricard/CLL/views/minView=2"
io$outdir <- "/hps/nobackup/stegle/users/ricard/CLL/out/downsample/data2"

# Load data
data <- list()
data[["mRNA"]] <- read.table(paste0(io$indir,"/mRNA.txt"), header=T)
data[["Methylation"]] <- read.table(paste0(io$indir,"/meth.txt"), header=T)
data[["Drugs"]] <- read.table(paste0(io$indir,"/viab.txt"), header=T)
data[["Mutations"]] <- read.table(paste0(io$indir,"/mut.txt"), header=T)


# Define downsampling settings
opts <- list()
opts$range_samples <- as.character(seq(0,100,5))  # Range of samples to downsample
opts$views_to_drop <- c("mRNA")      # View(s) to be dropped
opts$num_views_to_drop <- 1         # Number of views to drop per sample
opts$trials <- 25                   # Number of trials

# Start downsampling
data_downsampled <- vector("list", length = length(opts$range_samples))
data_downsampled_i <- vector("list", length = length(opts$range_samples))
for (n in opts$range_samples) {
  data_downsampled[[n]] <- list()
  data_downsampled_i[[n]] <- list()
  for (trial in 1:opts$trials) {
    data_downsampled[[n]][[trial]] <- list()
    data_downsampled_i[[n]][[trial]] <- list()
    if (paste0(opts$views_to_drop,collapse="") == "random") {
      views <- sample(c("mRNA","Methylation","Drugs","Mutations"), size = opts$num_views_to_drop)
    } else {
      views <- opts$views_to_drop
    }
    
    # Downsample
    data_downsampled[[n]][[trial]] <- data
    data_downsampled_i[[n]][[trial]] <- data
    if (n != "0") {
      for (view in views) {
        nsamples <- nrow(data[[view]])
        nfeatures <- ncol(data[[view]])
        samples_to_drop <- sample(1:nsamples, size=as.numeric(n))
        
        # Remove samples
        data_downsampled[[n]][[trial]][[view]][samples_to_drop,] <- NA 
        
        # Impute all missing samples by feature-wise mean to generate complete data
        idx_missing <- apply(data_downsampled[[n]][[trial]][[view]], 1, function(x) mean(is.na(x))) == 1
        tmp <- matrix(rep(colMeans(data_downsampled[[n]][[trial]][[view]], na.rm=T), as.numeric(sum(idx_missing))), nr=as.numeric(sum(idx_missing)), nc=nfeatures, byrow=T)
        data_downsampled_i[[n]][[trial]][[view]][idx_missing,] <- tmp
      }
    }
  }
}

# Save data
io$tmp_outdir <- paste0(io$outdir,"/",paste(opts$views_to_drop,collapse="_")); dir.create(io$tmp_outdir, recursive = T)
for (n in opts$range_samples) {
  for (trial in 1:opts$trials) {
    outprefix <- paste0(io$tmp_outdir,"/",n,"_",trial)
    for (view in names(data_downsampled[[n]][[trial]])) {
      outfile <- paste0(outprefix,"_",view,".txt")
      outfile_i <- paste0(outprefix,"_",view,"_imputed.txt")
      write.table(data_downsampled[[n]][[trial]][[view]], outfile, col.names=T, row.names=T, sep=" ", quote=F)
      write.table(data_downsampled[[n]][[trial]][[view]], outfile_i, col.names=T, row.names=T, sep=" ", quote=F)
    }
  }
}

