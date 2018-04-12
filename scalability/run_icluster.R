library(iClusterPlus)

impute <- function(d, margin=1) {
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

run_iCluster <- function(Y,nfac){
	M_temp <- length(Y)
	norm <- lapply(Y, function(dd) scale(dd, center=TRUE, scale=FALSE))
	norm <- lapply(Y,impute)
	if(M_temp==3){
	tune.iClusterPlus(cpus =1, dt1=norm[[1]],
                               dt2=norm[[2]],
                               dt3=norm[[3]],
                               type=c("gaussian","gaussian","gaussian"),
                               K=as.numeric(nfac))
	} else {
		tune.iClusterPlus(cpus =1, dt1=norm[[1]],
                               type=c("gaussian"),
                               K=as.numeric(nfac))
	}
}

#slurmidx <- 1
slurmidx <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))-1
idx <- slurmidx %% 37+1
trial <- slurmidx %/% 37 +1

indir = '/g/huber/users/bvelten/tmp/MOFA/runtime/withNAs/data'
outdir = '/g/huber/users/bvelten/tmp/MOFA/runtime/withNAs/out_iCluster'
if(!dir.exists(outdir)) dir.create(outdir)
for(letter in c("K","M","N","D"))
    if(!dir.exists(file.path(outdir, letter))) dir.create(file.path(outdir, letter))

# Default values
M = 3
K=10

if(idx<11){
  # Varying K
  k = c(5, 10, 15, 20, 25, 30, 35, 40, 45, 50)[idx]
  inFiles = file.path(indir, "K", paste0(paste(k, 0:(M-1), sep="_"),".txt"))
  Y = lapply(inFiles, function(fnm) as.matrix(read.table(fnm)))
  tmp <- Sys.time()
  run_iCluster(Y,k)
  tmp <- difftime(Sys.time(),tmp, units="secs")
  outFile = file.path(outdir, "K", paste0(paste("K",k, trial, sep="_"),".txt"))
  write.table(tmp,file=outFile, row.names=F, col.names=F)
} else if(idx<20) {
  # Varying D
  d = c(1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000)[idx-10]
  inFiles = file.path(indir, "D", paste0(paste(d, 0:(M-1), sep="_"),".txt"))
  Y = lapply(inFiles, function(fnm) as.matrix(read.table(fnm)))
  tmp <- Sys.time()
  run_iCluster(Y,K)
  tmp <- difftime(Sys.time(),tmp, units="secs")
  outFile = file.path(outdir, "D", paste0(paste("D",d, trial, sep="_"),".txt"))
  write.table(tmp,file=outFile, row.names=F, col.names=F)
} else if (idx<28){
  m = c(1, 3, 5, 7, 9, 11, 13, 15)[idx-19]
  if(m<=4){
  inFiles = file.path(indir, "M", paste0(paste(m, 0:(m-1), sep="_"),".txt"))
  Y = lapply(inFiles, function(fnm) as.matrix(read.table(fnm)))
  tmp <- Sys.time()
  run_iCluster(Y,K)
  tmp <- difftime(Sys.time(),tmp, units="secs")
  outFile = file.path(outdir, "M", paste0(paste("M",m, trial, sep="_"),".txt"))
  write.table(tmp,file=outFile, row.names=F, col.names=F)
}
}else if(idx<38){
  # Varying N
  n = c(50, 100, 150, 200, 250, 300, 350, 400, 450, 500)[idx-27]
  inFiles = file.path(indir, "N", paste0(paste(n, 0:(M-1), sep="_"),".txt"))
  Y = lapply(inFiles, function(fnm) as.matrix(read.table(fnm)))
  tmp <- Sys.time()
  run_iCluster(Y,K)
  tmp <- difftime(Sys.time(),tmp, units="secs")
  outFile = file.path(outdir, "N", paste0(paste("N",n, trial, sep="_"),".txt"))
  write.table(tmp,file=outFile, row.names=F, col.names=F)
} else stop("Error: Index too high")   
