# contains helper functions for plots in the CLL analysis


get_legend<-function(gg){
  tmp <- ggplot_gtable(ggplot_build(gg))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}


showTopWeightsAndColor <- function(model, view, factor, nfeatures = 5,
                                   manual_features=NULL, sign="positive", abs=TRUE,
                                   Features2color=NULL, col2highlight="red", maxL=NULL,
                                   scalePerView=F, orderBySign=FALSE) {
  
  # Sanity checks
  if (class(model) != "MOFAmodel") stop("'model' has to be an instance of MOFAmodel")
  stopifnot(all(view %in% viewNames(model)))  
  factor <- as.character(factor)
  stopifnot(factor %in% factorNames(model))
  if(!is.null(manual_features)) { stopifnot(class(manual_features)=="list"); stopifnot(all(Reduce(intersect,manual_features) %in% featureNames(model)[[view]]))  }
  if (sign=="negative") stopifnot(abs==FALSE)
  
  # Collect expectations  
  W <- getExpectations(model,"SW","E", as.data.frame = T)
  W <- W[W$factor==factor & W$view==view,]
  if(scalePerView) W$value <- W$value/max(abs(W$value))
  
  # Absolute value
  W$value4order <- W$value
  if (abs) W$value <- abs(W$value)
  if(!orderBySign) W$value4order <- W$value

  if (sign=="positive") { W <- W[W$value>0,] } else if (sign=="negative") { W <- W[W$value<0,] }
  
  # Extract relevant features
  W <- W[with(W, order(-abs(value))), ]
  if (nfeatures>0) features <- head(W$feature,nfeatures) # Extract top hits
  if (!is.null(manual_features)) features <- W$feature[W$feature %in% manual_features] # Extract manual hits
  W <- W[W$feature %in% features,]
  
  # Sort according to loadings
  W <- W[with(W, order(-value4order, decreasing = T)), ]
  W$feature <- factor(W$feature, levels=W$feature)
  W$highlight <- ifelse(W$feature %in% Features2color, "highlighted", "other")
  
  p <- ggplot(W,aes(x=feature, y=value, col= highlight)) +
    geom_point(size=3) +
    geom_segment(aes(xend=feature, yend=0), size=2) +
    # scale_colour_gradient(low="grey", high="black") +
    # scale_colour_manual(values=c("#F8766D","#00BFC4")) +
    # guides(colour = guide_legend(title.position="top", title.hjust = 0.5)) +
    coord_flip() +
    theme(
      axis.title.x = element_text(size=rel(1.3), color='black'),
      axis.title.y = element_blank(),
      axis.text.y = element_text(size=rel(1.5), hjust=1, color=ifelse(W$highlight=="highlighted", col2highlight, "black") ),
      axis.text.x = element_text(size=rel(1.5), color='black'),
      axis.ticks.y = element_blank(),
      axis.ticks.x = element_line(),
      legend.position='top',
      # legend.title=element_text(size=rel(1.5), color="black"),
      legend.title=element_blank(),
      legend.text=element_text(size=rel(1.3), color="black"),
      legend.key=element_rect(fill='transparent'),
      panel.background = element_blank()
      #aspect.ratio = .7
    ) + scale_color_manual(values=c("highlighted"=col2highlight,"other"="black")) +
    guides(color=F)
    if(orderBySign) p <- p +  ylim(0,max(W$value)+0.1)+ geom_text(label=ifelse(W$value4order>0, "+", "-"),y=max(W$value)+0.1, size=10)
  
  if(!is.null(maxL)) p <- p + ylim(0,maxL)
  
  if (sign=="negative") p <- p + scale_x_discrete(position = "top")
  if(abs & scalePerView) p <-  p + ylab(paste("Relative loading on factor", factor))  
  else if(abs & !scalePerView) p <- p + ylab(paste("Absolute loading on factor", factor))
  else if(!abs & scalePerView) p <- p + ylab(paste("Relative loading on factor", factor))
  else p <- p + ylab(paste("Loading on factor", factor))
  return(p)
  
}



plotDrugResponseCurve <- function(model, drugnm, groups=NULL, groupnm=""){
  data(conctab, package="pace")
  drugData2plot <-model@TrainData$Drugs[grepl(drugnm,rownames(model@TrainData$Drug)),]
  drugid <- rownames(drugs[drugs$name==drugnm, ])
  
  drugDF <- melt(drugData2plot, varnames = c("drug", "patient"), value.name = "viability")
  drugDF %<>% mutate(concentrationID = as.numeric(sapply(as.character(drug), function(x) strsplit(x, "_")[[1]][2])))
  drugDF %<>% mutate(concentration = as.numeric(conctab[drugid,paste0("c", concentrationID)]))
  if(!is.null(groups)) drugDF %<>% mutate(group = as.factor(groups[patient])) else drugDF$group <- factor(1)

  drugDF %<>% filter(!is.na(viability) & !is.na(group))
  summary_drugDF <-  drugDF %>% group_by(group, concentrationID, concentration) %>%
            dplyr::summarize(mean_viab = mean(viability), sd = sd(viability), n = length(viability))
  summary_drugDF$se <- summary_drugDF$sd/sqrt(summary_drugDF$n)

  p <- ggplot(summary_drugDF, aes(x=concentration, y=mean_viab, col=group, grou=group)) +
    geom_errorbar(aes(ymin=mean_viab-2*se, ymax=mean_viab + 2*se), width=0.1)+ geom_line(size=2) +
    ylab("viability") +ggtitle(drugnm) +theme_bw(base_size = 21) +
    xlab(expression(paste("Concentration [",mu,"M]"))) #+ scale_x_reverse()
  if(is.null(groups)) p <- p + guides(col=F) else p <- p + guides(col=guide_legend(title =groupnm))
  # print(p)
  return(p)
}

plotFlippedR2 <- function(r2.out, orderFactorsbyR2= TRUE, showtotalR2 = TRUE, horizontalSpaces = TRUE){
  
  fvar_mk <- r2out$R2PerFactor
  fvar_m <- r2out$R2Total

factorsNonconst <- factorNames(model)[-1]      
# Sort factors
      fvar_mk_df <- reshape2::melt(fvar_mk, varnames=c("factor","view"))
      fvar_mk_df$factor <- factor(fvar_mk_df$factor)
      fvar_mk_df$view <- factor(fvar_mk_df$view, levels = rev(c("Mutations", "mRNA", "Methylation", "Drugs")))
      if(orderFactorsbyR2) {factor_order <- order(rowSums(fvar_mk), decreasing = T) 
          } else factor_order <- rev(1:length(factorsNonconst))
      fvar_mk_df$factor <- factor(fvar_mk_df$factor, levels = factorsNonconst[factor_order])
     
      if(horizontalSpaces){
fvar_mk_df$view <-factor(fvar_mk_df$view, levels = rev(levels(fvar_mk_df$view)))
hm <- ggplot(fvar_mk_df, aes(factor, view)) +  facet_wrap(~view, scale="free_y", nrow=4)+
  geom_tile(aes(fill=value), color="black") +
  guides(fill=guide_colorbar(parse(text='R^2'))) +
  scale_fill_gradientn(colors=c("gray97","darkblue"), guide="colorbar") +
  xlab("Factor")  +# coord_flip()+ 
  theme_minimal() + 
  theme(text = element_text(size=25),
        # plot.margin = margin(5,5,5,5),
        plot.title = element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, hjust=0.5, vjust=0, color="black", size=rel(1.3)),
        # axis.text.y = element_blank(),
        # axis.text.x = element_blank(),
        axis.title.y = element_blank(),
        axis.line = element_blank(),
        axis.ticks =  element_blank(),
        panel.background = element_blank(),
        strip.background = element_blank(),
        strip.text.x = element_blank()
   ) 
} else {
  hm <- ggplot(fvar_mk_df, aes(view,factor)) + 
        geom_tile(aes(fill=value), color="black") +
        guides(fill=guide_colorbar("R2")) +
        scale_fill_gradientn(colors=c("gray97","darkblue"), guide="colorbar") +
        ylab("Factors") +
        theme(text = element_text(size=25),
          # plot.margin = margin(5,5,5,5),
          plot.title = element_text(hjust=0.5),
          axis.text.x = element_text(angle=0, hjust=0, vjust=1, color="black", size=rel(1.3)),
          axis.text.y = element_blank(),
          axis.title.y = element_blank(),
          axis.line = element_blank(),
          axis.ticks =  element_blank(),
          panel.background = element_blank()
          )  + coord_flip()
}

      hm <- hm  + 
      if (showtotalR2) {
        guides(fill=guide_colorbar("R2"))
      } else {
        guides(fill=guide_colorbar("Residual R2")) 
      } #+ ggtitle("Variance explained per factor") 

        
      # Plot 2: barplot with coefficient of determination (R2) per view
      fvar_m_df <- data.frame(view=names(fvar_m), R2=fvar_m)
      fvar_m_df$view <- factor(fvar_m_df$view, levels = rev(c("Mutations", "mRNA", "Methylation", "Drugs")))
      
      bplt <- ggplot( fvar_m_df, aes(x=view, y=R2)) + 
        # ggtitle("Total variance explained per view") +
        geom_bar(stat="identity", fill="deepskyblue4", width=0.9) +
        xlab("") + ylab(parse(text='R^2')) +
        scale_y_continuous(expand=c(0.01,0.01)) +
        theme(text = element_text(size=25),
          plot.margin = unit(c(1,2.4,0,0), "cm"),
          panel.background = element_blank(),
          plot.title = element_text(size=17, hjust=0.5),
          axis.ticks.y = element_blank(),
          axis.text.x = element_text(angle=0, hjust=0, vjust=1, color="black", size=rel(1.3)),
          #axis.title.y = element_blank(),
          # axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5)
          # axis.text.x = element_text(size=12, color="black"),
          # axis.title.x = element_text(size=13, color="black"),
          axis.line = element_line(size=rel(1.0), color="black")
            ) +coord_flip()
      
      # Join the two plots
      # Need to fix alignment using e.g. gtable...
      # gg_R2 <- gridExtra::arrangeGrob(hm, bplt, ncol=1, heights=c(length(factorsNonconst),7) )
      # gg_R2 <- gridExtra::arrangeGrob(bplt, hm, ncol=1, heights=c(1/2,1/2) )
      # gridExtra::grid.arrange(gg_R2)
      
      #p <- plot_grid(bplt, hm, align="h", nrow=1, rel_widths=c(2/5,3/5))
      gg_legend <- get_legend(hm)
      p <- plot_grid(hm+guides(fill=F),gg_legend,
                     bplt + theme(axis.text.y = element_blank()),
                     align="h", nrow=1, rel_widths=c(5/10,1/10, 4/10), axis="t")

      return(p)
}
