theme_scatter <- function() {
  theme(
    axis.text = element_text(size = rel(1), color = "black"),
    axis.title.y = element_text(size = rel(1.7), margin = margin(0, 15, 0, 0)),
    axis.title.x = element_text(size = rel(1.7), margin = margin(15, 0, 0, 0)),
    axis.line = element_line(colour = "black", size = 0.6),
    axis.ticks = element_line(colour = "black", size = 0.6),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    legend.key = element_rect(fill = "white"),
    legend.text = element_text(size = rel(1.2)),
    legend.title = element_text(size = rel(1.5))
  )
}

stripConc <- function (x) 
  vapply(strsplit(x, "_"), function(x) paste(x[-length(x)], collapse = "_"), 
         character(1))

deckel <- function(x, lower = -Inf, upper = +Inf) ifelse(x<lower, lower, ifelse(x>upper, upper, x))

getViab<-function(file, pat2include, 
                  badDrugs=c( "D_008",  "D_025"), 
                  conc2include = 2:5,
                  targetedDrugs= c("D_002", "D_003", "D_166", "D_082", "D_079", "D_012", "D_030", "D_063", "D_083") , 
                  conc4targeted = c(4,5),
                  chemoDrugs = c("D_006", "D_159", "D_010"),
                  conc4chemo = 3:5,
                  effectNum = 4,
                  effectVal = 0.7,
                  viab = 0.6, 
                  maxval = 1.1,
                  outdir,
                  plotit = T,
                  verbose = T){
  
  #Load object
  nameObj<-load(file)
  lpdAll<-get(nameObj)
  dr<-lpdAll[Biobase::fData(lpdAll)$type=="viab"]
  
  
  #Subset to patients of interest
  dr<-dr[, colnames(dr) %in% pat2include]
  
  #Select drug fulfilling requirements
  
  ##Filter out bad drugs and concentrations
  candDrugs <- rownames(dr)[ !(Biobase::fData(dr)$id %in% badDrugs) & Biobase::fData(dr)$subtype %in% conc2include]
  
  # Drugs to be included for sure
  targetedDrugs2include <- paste(rep(targetedDrugs, each = length(conc4targeted)), conc4targeted, sep="_" )
  chemoDrugs2include <- paste(rep(chemoDrugs, each = length(conc4chemo)), conc4chemo, sep="_" )
  
  ##Thresholds on viability effect
  # overallMean  <- rowMeans(exprs(dr)[candDrugs, ])
  # nthStrongest <- apply(exprs(dr)[candDrugs, ], 1, function(x) sort(x)[effectNum])
  # eligibleDrugs <- candDrugs[ overallMean >=viab & nthStrongest <= effectVal ] %>%
  #   union(targetedDrugs2include) %>% union(chemoDrugs2include)
  # if(plotit){
  # par(mfrow = c(1, 3))
  # hist(overallMean,  breaks = 30, col = "pink"); abline(v = viab,      col="blue")
  # hist(nthStrongest, breaks = 30, col = "pink"); abline(v =effectVal, col="blue")
  # plot(overallMean, nthStrongest)
  # abline(h = effectVal, v = viab, col = "blue")
  # }  
  
  # if(verbose){
  # message("Including p= ", length(eligibleDrugs), " drug response features")
  # message("Different drugs d = ",  length(unique(stripConc(eligibleDrugs))))
  # message("Concentration per drug:")
  # print(table(stripConc(eligibleDrugs)))
  # }
  
  #subset
  # dr<-dr[eligibleDrugs,, drop=FALSE ]
  
  #cut-off all viability balues above maxval
  # drmat <- t(deckel(exprs(dr), lower=0, upper=maxval))
  drmat <- t(deckel(Biobase::exprs(dr), lower=0, upper=Inf))
  
  #Save as view
  # save(drmat, file=file.path(outdir,"viab.RData"))
  # write.table(drmat, file=file.path(outdir,"viab.txt"),
  #             row.names=TRUE, col.names=TRUE, quote=F)
  
  return(drmat)
}

sample_colors <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}


# Expression of HSP proteins
# ```{r}
# 
# tmp <- getTrainData(model, views="mRNA", features=list(c("HSPA1A","HSPA6","HSPA1B","HSPA2","HSPB1","HSPE1")), as.data.frame = T) %>%
#   as.data.table %>% merge(df[,c("sample","cluster")],by="sample")
# 
# p <- ggplot(tmp, aes(x=feature,y=value)) +
#   geom_boxplot(aes(fill=cluster), outlier.shape = NA) +
#   labs(x="", y="Expression") +
#   guides(fill=guide_legend(title="Stress status")) +
#   theme(
#     axis.text.y = element_text(size = rel(1.2), color = "black"),
#     axis.text.x = element_text(size = rel(1.2), color = "black", angle=90, hjust=1, vjust=0.5),
#     axis.title.y = element_text(size = rel(1.4), margin = margin(0,15,0,0)),
#     axis.title.x = element_text(size = rel(1.4), margin = margin(15,0,0,0)),
#     axis.line = element_line(colour = "black", size = 0.5),
#     axis.ticks = element_line(colour = "black", size = 0.5),
#     panel.border = element_blank(),
#     panel.grid.major = element_blank(),
#     panel.grid.minor = element_blank(),
#     panel.background = element_blank(),
#     legend.key = element_rect(fill = "white"),
#     # legend.title = element_rect(fill = "white"),
#     legend.position = "right"
#   )
# print(p)
# 
# # pdf("/Users/ricard/CLL/ricard_analysis/out/stress/hsp_boxplots.pdf", width = 6.5, height = 5, useDingbats = F)
# # print(p)
# # dev.off()
# ```

