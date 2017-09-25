##############################################
## Script to generate data for downsampling ##
##############################################

# I/O
io <- list()
# io$indir <- "/Users/ricard/data/CLL/views/minView=2"
# io$outdir <- "/Users/ricard/data/CLL/out/downsample/data"
io$indir <- "/hps/nobackup/stegle/users/ricard/CLL/views/minView=2"
io$outdir <- "/hps/nobackup/stegle/users/ricard/downsample/data2"

# Load data
data <- list()
data[["mRNA"]] <- read.table(paste0(io$indir,"/mRNA.txt"), header=T)
data[["Methylation"]] <- read.table(paste0(io$indir,"/meth.txt"), header=T)
data[["Drugs"]] <- read.table(paste0(io$indir,"/viab.txt"), header=T)
data[["Mutations"]] <- read.table(paste0(io$indir,"/mut.txt"), header=T)

# Define downsampling settings
opts <- list()
opts$range_samples <- seq(5,100,5)  # Range of samples to downsample
opts$view_to_drop <- c("mRNA")      # View(s) to be dropped
# opts$num_views_to_drop <- 1       # Number of views to drop per sample (only if opts$view_to_drop == "random")
opts$trials <- 50                   # Number of trials

# Start downsampling
nsamples <- nrow(data[["mRNA"]])
data_downsampled <- vector("list", length = length(opts$range_samples))
for (n in opts$range_samples) {
  print(n)
  data_downsampled[[n]] <- list()
  for (trial in 1:opts$trials) {
    data_downsampled[[n]][[trial]] <- list()
    if (paste0(opts$view_to_drop,collapse="") == "random") {
      views <- sample(c("mRNA","Methylation","Drugs","Mutations"), size = opts$num_views_to_drop)
    } else {
      views <- opts$view_to_drop
    }
    
    # Select samples to drop
    valid_samples <- lapply(views, function(m) which( apply(data[[m]], 1, function(x) mean(is.na(x))) == 0) ); names(valid_samples) <- views
    
    # Drop
    data_downsampled[[n]][[trial]] <- data
    for (view in views) {
      samples_to_drop <- sample(valid_samples[[view]], size=n)
      data_downsampled[[n]][[trial]][[view]][samples_to_drop,] <- NA 
    }
    
  }
}
  
# Save data
io$tmp_outdir <- paste0(io$outdir,"/",paste(opts$view_to_drop,collapse="_")); dir.create(io$tmp_outdir, recursive = T)
for (n in opts$range_samples) {
  for (trial in 1:opts$trials) {
    outprefix <- paste0(io$tmp_outdir,"/",n,"_",trial)
    for (view in names(data_downsampled[[n]][[trial]])) {
      outfile <- paste0(outprefix,"_",view,".txt")
      write.table(data_downsampled[[n]][[trial]][[view]], outfile, col.names=T, row.names=T, sep=" ", quote=F)
    }
  }
}

