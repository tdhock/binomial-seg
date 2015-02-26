works_with_R("3.1.2",
             data.table="1.9.4")

load("ichange_classes.RData")

header.tmp <-
  paste('track',
        'type=bedGraph',
        'db=hg19',
        'export=yes',
        'visibility=full',
        'maxSegments=20',
        'alwaysZero=on',
        'share=mcgill.ca',
        'graphType=points',
        'yLineMark=0',
        'yLineOnOff=on',
        'name=%s',
        'description="%s"')

ichange.classes <- fread("ichange_classes.txt", header=FALSE)
setnames(ichange.classes, c("name", "class"))

csv.base <- "1840_Brain_BS_1.profile.cg_strand_combined.csv"
csv.bases <- dir("ichange_data")
for(csv.i in seq_along(csv.bases)){
  csv.base <- csv.bases[[csv.i]]
  cat(sprintf("%4d / %4d %s\n", csv.i, length(csv.bases), csv.base))
  ichange.class <- ichange_classes[[csv.base]]
  name <- sub("_.*", "", csv.base, perl=TRUE)
  label <- paste0(ichange.class, "_", name)

  csv.file <- file.path("ichange_data", csv.base)
  one <- fread(csv.file)

  chroms <- paste0("chr", c(1:22, "X", "Y"))
  chroms <- "chr22"
  some <- one[chr %in% chroms, ]
  ## ignore strand-specific methylation for now.
  dir.create("ichange_chr22", showWarnings = FALSE)
  for(out.col in c("total_meth", "total")){
    suffix <- paste0(out.col, ".bedGraph.gz")
    out.base <- sub("profile.*", suffix, csv.base)
    out.file <- file.path("ichange_chr22", out.base)
    out.cols <- c("chr", "start", "end", out.col)
    out.dt <- some[, out.cols, with=FALSE]
    header <- sprintf(header.tmp, label, label)
    con <- gzfile(out.file, "w")
    writeLines(header, con)
    write.table(out.dt, con, quote=FALSE, row.names=FALSE, col.names=FALSE)
    close(con)
  }
}
