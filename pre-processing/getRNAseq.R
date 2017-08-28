# Function to get preprocessed RNAseq data
# inputs:
# file: location of RData object
# pat2include: patients ids to include
# minrs: minimum number of counts for a gene over all patietns to be included
# AnnoFileList: named list of files Bimoart biotype annotation files
# plotit: plot count distribution an minrs cut-off
# outdir, directory to save output to
# onlyCD19 include only CD19 selected samples
# topmRNA number of top variable genes to include
# noY: if true genes from Y chr are excluded

getRNAseq <-function(file, pat2include, minrs=100, AnnoFileList, 
                    plotit, outdir, onlyCD19=F, topmRNA=5000, noY=T){
  #Load object
  nameObj<-load(file)
  dds<-get(nameObj)
  
  #Subset to patients of interest
  dds<-dds[, colData(dds)$PatID %in% pat2include]
  
  #Filter out genes with low counts
  rs    <- rowSums(counts(dds))
  if(plotit){
  hist(rs[ rs < 500 ], breaks=seq(0, 500, by = 10), col = "skyblue")
  abline(v = minrs, col = "red")
  }
  dds<-dds[ rs >= minrs, ]
  
  #Normalize and VST
  dds<-estimateSizeFactors(dds)
  dds <- varianceStabilizingTransformation(dds) 
  colnames(dds)<-as.character(colData(dds)$PatID)
  
  #Select CD19 samples only
  if(onlyCD19) dds <- dds[, colData(dds)$RNAprep=="CD19+"]
  
  #Get annotations can check no overlap
  annoList <- lapply(AnnoFileList, function(file) read.csv(file = file,header=T,sep="\t",stringsAsFactors=F))
  stopifnot(!any(duplicated(Reduce(union, lapply(annoList, function(l) l$ens_id)))))
  
  #Remove Y chromosome genes
  if(noY) {
    noYensid <- lapply(annoList, function(sub) filter(sub, chr != "chrY")$ens_id)
    noYensid <- Reduce(union, noYensid)
    dds <- dds[rownames(dds) %in% noYensid,]
  }
    
  #Annotate Biotypes and save
  dds_sub_list<-lapply(names(annoList), function(biotype) {
    anno<-annoList[[biotype]]
    dds_sub <- dds[rownames(dds) %in% anno$ens_id,] %>% assay %>% t
    if(biotype=="mRNA") dds_sub<-dds_sub[, order(apply(dds_sub,2,var), decreasing = T)[1:min(topmRNA, ncol(dds_sub))]]
    save(dds_sub, file=file.path(outdir, paste(biotype,".RData", sep="")))
    # write.table(dds_sub, file=file.path(outdir, paste(biotype,".txt", sep="")),
    #             row.names=TRUE, col.names=TRUE, quote=F)
    dds_sub
  })
  names(dds_sub_list)<-names(annoList)

  #save
  save(dds_sub_list, file=file.path(outdir,"dds_list.RData"))
  
  return(dds_sub_list)
}