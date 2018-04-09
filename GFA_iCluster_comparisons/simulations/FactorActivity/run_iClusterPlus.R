
in.folder <- '/g/huber/users/bvelten/tmp/iCluster/SimulatedData/trial0'
library(iClusterPlus)

files <- list.files(in.folder, pattern=".txt$")

# data
simData <- lapply(files, function(fnm){
  dt <- read.table(file.path(in.folder,fnm))
  as.matrix(dt)
  })
simData <- lapply(simData, function(dd) scale(dd, center=TRUE, scale=FALSE))

# view index
mvec <- sapply(files, function(fnm){
	  split <- strsplit(fnm,"_")[[1]]
  	substr(split[[2]],1,nchar(split[[2]])-4)
	})

# number of facotrs
kvec <- sapply(files, function(fnm){
	split <- strsplit(fnm,"_")[[1]]
	split[1]
	})

# set names
names(simData) <- paste("k",kvec,"_","m",mvec, sep="")

# fit iCluster model
SLURM_idx <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))
k <- unique(kvec)[SLURM_idx]

tuned.out <- tune.iClusterPlus(cpus =12, dt1=simData[[paste("k",k,"_","m",0, sep="")]],
                               dt2=simData[[paste("k",k,"_","m",1, sep="")]],
                               dt3=simData[[paste("k",k,"_","m",2, sep="")]],
                               type=c("gaussian","gaussian","gaussian"),
                               K=as.numeric(k), n.lambda=185, scale.lambda=c(1,1,1),maxiter=20)
#save result
save(tuned.out, file=paste("iclustertuned.out",k,".RData", sep=""))


