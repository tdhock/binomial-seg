works_with_R("3.1.2",
             data.table="1.9.4")

ichange.classes <- fread("ichange_classes.txt", header=FALSE)
setnames(ichange.classes, c("name", "class"))

csv.base <- "1840_Brain_BS_1.profile.cg_strand_combined.csv"
csv.bases <- dir("ichange_data")
ichange_classes <- character()
for(csv.base in csv.bases){
  name <- sub("_.*", "", csv.base)
  is.label <- grepl(name, ichange.classes$name)
  label <- ichange.classes[is.label, ]
  stopifnot(nrow(label) == 1)
  ichange_classes[[csv.base]] <- paste(label$class)
}

save(ichange_classes, file="ichange_classes.RData")
