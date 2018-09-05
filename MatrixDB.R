## The R script to extract all extracellular matrix related genes from http://matrixdb.univ-lyon1.fr/

rm(list = ls(all=TRUE))

## install if necessary
# source("http://bioconductor.org/biocLite.R")
# biocLite("org.Hs.eg.db")
# install.packages("pacman")

## load library
pacman::p_load(org.Hs.eg.db, tcltk) 
# library(org.Hs.eg.db)
# library(tcltk)

## Check the keys
# keytypes(org.Hs.eg.db)

# Hold the errors
selectiq <- function(x) {
result = tryCatch({
  select(org.Hs.eg.db, keys = x, columns=c("ENSEMBL","ENTREZID","SYMBOL","GENENAME"), keytype="UNIPROT")

}, warning = function(warning_condition) {
  #warning-handler-code
  #return(NULL)
  return(F)
}, error = function(error_condition) {
  #error-handler-code
  #return(NA)
  return(F)
}, finally={
  #cleanup-code
})
  return(result)
}

# create a folder
mainDir <- getwd()
subDir <- "data"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)

# download files
URL <- list()

# load the files
URL[1] <- 'http://matrixdb.univ-lyon1.fr/download/proteins_ECM.csv'
URL[2] <- 'http://matrixdb.univ-lyon1.fr/download/proteins_Secreted.csv'
URL[3] <-  'http://matrixdb.univ-lyon1.fr/download//proteins_Membrane.csv'
t_ECM <- read.table(as.character(URL[1]), header = T, fill = T, stringsAsFactors = FALSE)
t_secreted <- read.table(as.character(URL[2]), header = T, fill = T, stringsAsFactors = FALSE)
t_membrane <- read.table(as.character(URL[3]), header = T, fill = T, stringsAsFactors = FALSE)

t_ECM <- cbind(Category = "ECM", t_ECM)
t_secreted <- cbind(Category = "Secreted", t_secreted)
t_membrane <- cbind(Category = "Membrane", t_membrane)

t_main <- rbind(t_ECM, t_secreted, t_membrane)

write.csv(t_main, file=paste0(subDir, "/all_MatrixDB.csv"), append = F, row.names = T)

# Read CSV
all_MatrixDB <- read.csv(paste0(subDir, "/all_MatrixDB.csv"), stringsAsFactors = FALSE)

all_MatrixDB$ENSEMBL <- all_MatrixDB$ENTREZID <- all_MatrixDB$SYMBOL <- all_MatrixDB$GENENAME <- ""

total <- length(all_MatrixDB$Uniprot.primary.AC)

# progress
pb <- tkProgressBar(title = "Progress bar", min = 0, max = total, width = 300)

#pb <- txtProgressBar(min = 0, max = how_many, style = 3)

for (i in 1:total){
  
  genes <- selectiq(all_MatrixDB$Uniprot.primary.AC[i])

  #setTxtProgressBar(pb, i)
  setTkProgressBar(pb, i, label=paste(round(i/total*100, 0), "% done"))
  
  if (genes != F){
    #print(genes)
    all_MatrixDB$ENSEMBL[i] <- genes$ENSEMBL 
    all_MatrixDB$ENTREZID[i] <- genes$ENTREZID
    all_MatrixDB$SYMBOL[i] <- genes$SYMBOL
    all_MatrixDB$GENENAME[i] <- genes$GENENAME
  }
}

close(pb)

write.csv(all_MatrixDB, file=paste0(subDir, "/all_MatrixDB_2.csv"), append = F, row.names = T)
