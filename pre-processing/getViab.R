# Function to get preprocessed drug response data
# inputs:
# file: location of drpar object
# pat2include: patients ids to include
# conc2include: concentrations to include
# badDrugs: drugs to be excluded ---- #default drugs that failes QC: NSC 74859, bortezomib.
# maxval: cut-off for viability values 
# outdir: directory to save output to

stripConc <- function (x) 
  vapply(strsplit(x, "_"), function(x) paste(x[-length(x)], collapse = "_"), 
         character(1))

deckel <- function(x, lower = -Inf, upper = +Inf) ifelse(x<lower, lower, ifelse(x>upper, upper, x))

getViab <- function(file, pat2include, 
                  badDrugs=c( "D_008",  "D_025"), 
                  conc2include = 1:5,
                  maxval = 1.1,
                  outdir){
  
  #Load object
  nameObj <- load(file)
  lpdAll <- get(nameObj)
  dr <- lpdAll[fData(lpdAll)$type=="viab"]
  
  
  #Subset to patients of interest
  dr <- dr[, colnames(dr) %in% pat2include]
    
  ##Filter out bad drugs and concentrations
  candDrugs <- rownames(dr)[ !(fData(dr)$id %in% badDrugs) & fData(dr)$subtype %in% conc2include]
  
  #subset
  dr<-dr[candDrugs,, drop=FALSE ]
  
  #cut-off all viability balues above maxval
  drmat <- t(deckel(exprs(dr), lower=0, upper=maxval))

  #Save as view
  save(drmat, file=file.path(outdir,"viab.RData"))

  return(drmat)
}
