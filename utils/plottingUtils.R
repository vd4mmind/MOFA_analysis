showTopWeightsAndColor <- function(model, view, factor, nfeatures = 5,
                                   manual_features=NULL, sign="positive", abs=TRUE,
                                   Features2color=NULL, col2highlight="red", maxL=NULL,
                                   scalePerView=F) {
  
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
  if (abs) W$value <- abs(W$value)
  
  if (sign=="positive") { W <- W[W$value>0,] } else if (sign=="negative") { W <- W[W$value<0,] }
  
  # Extract relevant features
  W <- W[with(W, order(-abs(value))), ]
  if (nfeatures>0) features <- head(W$feature,nfeatures) # Extract top hits
  if (!is.null(manual_features)) features <- W$feature[W$feature %in% manual_features] # Extract manual hits
  W <- W[W$feature %in% features,]
  
  # Sort according to loadings
  W <- W[with(W, order(-value, decreasing = T)), ]
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
