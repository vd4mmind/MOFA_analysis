library(plyr)
library(ggplot2)

res_dir = '/Users/ricard/CLL/scalability'

D = read.table(paste(res_dir, 'results/D.txt', sep='/'), header=FALSE)
M = read.table(paste(res_dir, 'results/M.txt', sep='/'), header=FALSE)
K = read.table(paste(res_dir, 'results/K.txt', sep='/'), header=FALSE)
N = read.table(paste(res_dir, 'results/N.txt', sep='/'), header=FALSE)

D = cbind(D, 'Number of features (D)')
M = cbind(M, 'Number of views (M)')
K = cbind(K, 'Number of factors (K)')
N = cbind(N, 'Number of samples (N)')

colnames(D) = c('val', 'time', 'param')
colnames(M) = c('val', 'time', 'param')
colnames(K) = c('val', 'time', 'param')
colnames(N) = c('val', 'time', 'param')

D = ddply(D, c('val', 'param'), summarise, time_mean=mean(time, na.rm=TRUE), sd=sd(time, na.rm=TRUE))
K = ddply(K, c('val', 'param'), summarise, time_mean=mean(time, na.rm=TRUE), sd=sd(time, na.rm=TRUE))
M = ddply(M, c('val', 'param'), summarise, time_mean=mean(time, na.rm=TRUE), sd=sd(time, na.rm=TRUE))
N = ddply(N, c('val', 'param'), summarise, time_mean=mean(time, na.rm=TRUE), sd=sd(time, na.rm=TRUE))

tmp = rbind(D, M)
tmp = rbind(tmp,  K)
all = rbind(tmp,  N)

sd_error_bars = aes(ymax = time_mean + sd, ymin=time_mean - sd)

p <- ggplot(all, aes(x=val, y=time_mean)) +
    geom_errorbar(sd_error_bars, width=.3, position=position_dodge(width=.9), alpha=0.25 ) +
    geom_point(alpha=0.7, size=1.1) +
    geom_smooth(method='lm', alpha=0.25) +
    facet_wrap(~param, scales='free') +
    labs(x="", y="Time (sec)") +
    theme_bw() + 
    theme(
      axis.title.y = element_text(size=rel(1.7), color="black"),
      axis.text=element_text(size=rel(1.0), color='black'),
      strip.text = element_text(size=rel(1.1), color="black")
    )
print(p)

pdf("/Users/ricard/CLL/scalability/out/scalability.pdf")
print(p)
dev.off()
