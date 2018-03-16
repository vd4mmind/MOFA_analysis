library(ggplot2)
library(dplyr)
library(magrittr)
library(reshape2)
library(plyr)
library(cowplot)


### MOFA ###
outdir <- "~/Documents/MOFA/GFAcomparison/runtime_NA_0.05/out_mofa/"

# in D
Dfiles <- list.files(file.path(outdir,"D"))
times <-  sapply(Dfiles, function(df) as.numeric(read.table(file.path(outdir,"D", df))[nrow(read.table(file.path(outdir,"D", df))),]))
d <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_d <- data.frame(d=d, time=times, trial=trial)
gg_d <- ggplot(df_d, aes(x=d, y=time)) + geom_smooth(method='loess') + geom_point()
rm(times)

# in N
files <- list.files(file.path(outdir,"N"))
times <-  sapply(files, function(df) as.numeric(read.table(file.path(outdir,"N", df))[nrow(read.table(file.path(outdir,"N", df))),]))
n <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_n <- data.frame(n=n, time=times, trial=trial)
gg_n <- ggplot(df_n, aes(x=n, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

# in k
files <- list.files(file.path(outdir,"K"))
times <-  sapply(files, function(df) as.numeric(read.table(file.path(outdir,"K", df))[nrow(read.table(file.path(outdir,"K", df))),]))
k <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_k <- data.frame(k=k, time=times, trial=trial)
gg_k <- ggplot(df_k, aes(x=k, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

# in M
files <- list.files(file.path(outdir,"M"))
times <-  sapply(files, function(df) as.numeric(read.table(file.path(outdir,"M", df))[nrow(read.table(file.path(outdir,"M", df))),]))
m <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_m <- data.frame(m=m, time=times, trial=trial)
gg_m <- ggplot(df_m, aes(x=m, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

gg_mofa <- plot_grid(gg_d,gg_n, gg_k)


### GFA ###

outdir <- "~/Documents/MOFA/GFAcomparison/runtime_NA_0.05/out_gfa/"
# in D
Dfiles <- list.files(file.path(outdir,"D"))
times <-  sapply(Dfiles, function(df) as.numeric(read.table(file.path(outdir,"D", df))))
d <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_d_gfa <- data.frame(d=d, time=times, trial=trial)
gg_d <- ggplot(df_d_gfa, aes(x=d, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

# in N
files <- list.files(file.path(outdir,"N"))
times <-  sapply(files, function(df) as.numeric(read.table(file.path(outdir,"N", df))))
n <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_n_gfa <- data.frame(n=n, time=times, trial=trial)
gg_n <- ggplot(df_n_gfa, aes(x=n, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

# in K
files <- list.files(file.path(outdir,"K"))
times <-  sapply(files, function(df) as.numeric(read.table(file.path(outdir,"K", df))))
k <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_k_gfa <- data.frame(k=k, time=times, trial=trial)
gg_k <- ggplot(df_k_gfa, aes(x=k, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

# in M
files <- list.files(file.path(outdir,"M"))
times <-  sapply(files, function(df) as.numeric(read.table(file.path(outdir,"M", df))))
m <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_m_gfa <- data.frame(m=m, time=times, trial=trial)
gg_m <- ggplot(df_m_gfa, aes(x=m, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

gg_gfa <- plot_grid(gg_d,gg_n, gg_m,gg_k)

### iCluster ###

outdir <- "~/Documents/MOFA/GFAcomparison/runtime_NA_0.05/out_iCluster/"
# in D
Dfiles <- list.files(file.path(outdir,"D"))
times <-  sapply(Dfiles, function(df) as.numeric(read.table(file.path(outdir,"D", df))))
d <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_d_iCl <- data.frame(d=d, time=times, trial=trial)
gg_d <- ggplot(df_d_iCl, aes(x=d, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

# in N
files <- list.files(file.path(outdir,"N"))
times <-  sapply(files, function(df) as.numeric(read.table(file.path(outdir,"N", df))))
n <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_n_iCl <- data.frame(n=n, time=times, trial=trial)
gg_n <- ggplot(df_n_iCl, aes(x=n, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

# in K
files <- list.files(file.path(outdir,"K"))
times <-  sapply(files, function(df) as.numeric(read.table(file.path(outdir,"K", df))))
k <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_k_iCl <- data.frame(k=k, time=times, trial=trial)
gg_k <- ggplot(df_k_iCl, aes(x=k, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

# in M
files <- list.files(file.path(outdir,"M"))
times <-  sapply(files, function(df) as.numeric(read.table(file.path(outdir,"M", df))))
m <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[2]))
trial <- sapply(strsplit(names(times), "_|[.]"), function(s) as.numeric(s[3]))
df_m_iCl <- data.frame(m=m, time=times, trial=trial)
gg_m <- ggplot(df_m_iCl, aes(x=m, y=time)) + geom_smooth(method='lm') + geom_point()
rm(times)

gg_iCl <- plot_grid(gg_d,gg_n, gg_m,gg_k)


### joint ###
df_gfa <- rbind.fill(df_m_gfa, df_k_gfa,df_d_gfa,df_n_gfa)
df_mofa <- rbind.fill(df_m, df_k,df_d,df_n)
df_iCluster <- rbind.fill(df_m_iCl, df_k_iCl,df_d_iCl,df_n_iCl)

df_gfa$method <- "gfa"
df_mofa$method <- "mofa"
df_iCluster$method <- "iCluster"

df <- rbind.fill(df_gfa, df_mofa, df_iCluster)
df <- melt(df, id.vars = c("time", "method", "trial"))
df$variable <- ifelse(as.character(df$variable)=="m", "Number of views M",
                      ifelse(as.character(df$variable)=="n", "Number of samples N",
                             ifelse(as.character(df$variable)=="k", "Number of factors K", "Number of features D")))
df %<>% filter( !is.na(value))
# pdf("plot_NA.pdf")
gg <- ggplot(df, aes(x=value, col=method, group=method, y=time/60)) +geom_smooth(method='lm') +
  stat_summary() + facet_wrap(~variable, scales = "free_x") +ylim(c(0,200)) + ylab("time [min]")
gg
# dev.off()
# png("plot_NA.png")
gg
# dev.off()
gg
