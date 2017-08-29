# Function to get mutation data
# inputs:
# file: location of mutCOM object
# pat2include: patients ids to include
# minObs: only include feautres with at least so many occurences


getMut <- function(file, pat2include, minObs=3){
  
  #Load object
  nameObj<-load(file)
  mut<-get(nameObj)
  mut<- channel(mut, "binary") %>% exprs

  #Exclude del13q14_bi and  _mon (only keeping _any)
  mut<-mut[, !grepl("mono$|bi$", colnames(mut))]
  
  #Subset to patients of interest
  mut<-mut[rownames(mut)%in% pat2include,]

  #drop feautres with too low incidence
  mut<-mut[, colSums(mut, na.rm = T)>=minObs]

  #drop patients with no measurements
  mut<-mut[apply(mut,1,function(r) !all(is.na(r))),]
  
  # save    
  save(mut, file=file.path(outdir,"mut.RData"))
  
  return(mut)
  }
