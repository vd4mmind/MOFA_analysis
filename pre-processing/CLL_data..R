views <- c("meth.txt", "mRNA.txt", "viab.txt", "mut.txt")
data.dir <- "~/Documents/MOFA/CLL_MOFA_data/views/minView=2/"

CLL_data <- lapply(views, function(fnm) t(read.table(file.path(data.dir, fnm))))
names(CLL_data) <- c("Methylation", "mRNA", "Drugs", "Mutations")
sapply(CLL_data, dim)

save(CLL_data, file="CLL_data.RData")

CLL_covariates <- read.table(file.path(data.dir, "covariates.txt"))
save(CLL_covariates, file="CLL_covariates.RData")
