##############################################
## Script to generate data for downsampling ##
##############################################

library(data.table)
library(doParallel)

# I/O
io <- list()
# io$indir_incomplete <- "/Users/ricard/data/CLL/views/minView=2"
# io$indir_complete <- "/Users/ricard/data/CLL/views/minView=all"
# io$outdir <- "/Users/ricard/data/downsample/data"; dir.create(io$outdir)
io$indir_incomplete <- "/hps/nobackup/stegle/users/ricard/CLL/views/minView=2"
io$indir_complete <- "/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
io$outdir <- "/hps/nobackup/stegle/users/ricard/downsample/data"; dir.create(io$outdir)

# Load data
data_incomplete <- list()
data_incomplete[["mRNA"]] <- read.table(paste0(io$indir_incomplete,"/mRNA.txt"), header=T)
data_incomplete[["Methylation"]] <- read.table(paste0(io$indir_incomplete,"/meth.txt"), header=T)
data_incomplete[["Drugs"]] <- read.table(paste0(io$indir_incomplete,"/viab.txt"), header=T)
# data_incomplete[["Mutations"]] <- read.table(paste0(io$indir_incomplete,"/mut.txt"), header=T)

data_complete <- list()
data_complete[["mRNA"]] <- read.table(paste0(io$indir_complete,"/mRNA.txt"), header=T)
data_complete[["Methylation"]] <- read.table(paste0(io$indir_complete,"/meth.txt"), header=T)
data_complete[["Drugs"]] <- read.table(paste0(io$indir_complete,"/viab.txt"), header=T)
# data_complete[["Mutations"]] <- read.table(paste0(io$indir_complete,"/mut.txt"), header=T)

# Prepare parallel running
cores <- 25
registerDoParallel(cores=cores)

# Define downsampling settings
opts <- list()
opts$views <- c("mRNA","Methylation","Drugs")
opts$range_samples <- seq(0,100,5)  # Range of samples to downsample
opts$views_to_drop <- c("mRNA")     # View(s) to be dropped
opts$trials <- 50                   # Number of trials

# Start downsampling
for (n in as.character(opts$range_samples)) {
  print(n)
  invisible(foreach(trial=1:opts$trials) %dopar% {
  # for (trial in 1:opts$trials) {
    
    # Do the downsample
    data_downsampled_incomplete <- data_incomplete
    data_downsampled_incomplete_imputed <- data_incomplete
    data_downsampled_complete <- data_complete
    data_downsampled_complete_imputed <- data_complete
    for (view in opts$views_to_drop) {
      if (n != "0") {
          
        # Select valid samples (only complete, for simplicity)
        valid_samples <- which( apply(data_incomplete[[view]], 1, function(x) mean(is.na(x))) == 0)
        samples_to_drop_incomplete <- sample(valid_samples, size=as.numeric(n))
        # samples_to_drop_incomplete <- sample(1:nrow(data_incomplete[["mRNA"]]), size=as.numeric(n))
        samples_to_drop_complete <- sample(1:nrow(data_complete[["mRNA"]]), size=as.numeric(n))
        
        # Data set 1: incomplete
        data_downsampled_incomplete[[view]][samples_to_drop_incomplete,] <- NA
        
        # Data set 2: incomplete + imputed
        data_downsampled_incomplete_imputed[[view]][samples_to_drop_incomplete,] <- NA
        idx_missing <- apply(data_downsampled_incomplete_imputed[[view]], 1, function(x) mean(is.na(x))) == 1
        tmp <- matrix(rep(colMeans(data_downsampled_incomplete_imputed[[view]], na.rm=T), as.numeric(sum(idx_missing))), nr=as.numeric(sum(idx_missing)), nc=ncol(data_incomplete[[view]]), byrow=T)
        data_downsampled_incomplete_imputed[[view]][idx_missing,] <- tmp
        
        # Data set 3: complete
        data_downsampled_complete[[view]][samples_to_drop_complete,] <- NA
        
        # Data set 4: complete + imputed
        data_downsampled_complete_imputed[[view]][samples_to_drop_complete,] <- NA
        idx_missing <- apply(data_downsampled_complete_imputed[[view]], 1, function(x) mean(is.na(x))) == 1
        tmp <- matrix(rep(colMeans(data_downsampled_complete_imputed[[view]], na.rm=T), as.numeric(sum(idx_missing))), nr=as.numeric(sum(idx_missing)), nc=ncol(data_complete[[view]]), byrow=T)
        data_downsampled_complete_imputed[[view]][idx_missing,] <- tmp
        
      }
    }
    
    # Save
    for (view in opts$views) {
      fwrite(round(data_downsampled_incomplete[[view]],4), paste0(io$outdir,"/",n,"_",trial,"_",view,"_incomplete.txt"), col.names=T, row.names=T, sep=" ", quote=F, na="NA")
      fwrite(round(data_downsampled_incomplete_imputed[[view]],4), paste0(io$outdir,"/",n,"_",trial,"_",view,"_incomplete_imputed.txt"), col.names=T, row.names=T, sep=" ", quote=F, na="NA")
      fwrite(round(data_downsampled_complete[[view]],4), paste0(io$outdir,"/",n,"_",trial,"_",view,"_complete.txt"), col.names=T, row.names=T, sep=" ", quote=F, na="NA")
      fwrite(round(data_downsampled_complete_imputed[[view]],4), paste0(io$outdir,"/",n,"_",trial,"_",view,"_complete_imputed.txt"), col.names=T, row.names=T, sep=" ", quote=F, na="NA")
    }
    
  })
}
