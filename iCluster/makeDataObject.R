
#constructing RData object to use for iCluster

data.dir <- "~/Documents/MOFA/CLL_MOFA_data/views/minView=all/"
files <- list.files(data.dir)
data <- lapply(files, function(fnm) read.table(file.path(data.dir,fnm)))
sapply(data, dim)
names(data) <- sub(".txt", "",files)
save(data, file="~/Documents/MOFA/CLL_MOFA_data/Analysis/clustering/dataCLL.RData")