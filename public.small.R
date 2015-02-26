works_with_R("3.1.2",
             data.table="1.9.4")

bed <- fread("GSM916050_BiSeq_cpgMethylation_hippocampus_middle_BioSam_292.BiSeq.head100000.bed")
setnames(bed, c("chrom", "chromStart", "chromEnd", "pair.txt", "prop1000"))

## Parse the first occurance of pattern from each of several strings
## using (named) capturing regular expressions, returning a matrix
## (with column names).
str_match_perl <- function(string,pattern){
  stopifnot(is.character(string))
  stopifnot(is.character(pattern))
  stopifnot(length(pattern)==1)
  parsed <- regexpr(pattern,string,perl=TRUE)
  captured.text <- substr(string,parsed,parsed+attr(parsed,"match.length")-1)
  captured.text[captured.text==""] <- NA
  captured.groups <- if(is.null(attr(parsed, "capture.start"))){
    NULL
  }else{
    do.call(rbind,lapply(seq_along(string),function(i){
      st <- attr(parsed,"capture.start")[i,]
      if(is.na(parsed[i]) || parsed[i]==-1)return(rep(NA,length(st)))
      substring(string[i],st,st+attr(parsed,"capture.length")[i,]-1)
    }))
  }
  result <- cbind(captured.text,captured.groups)
  colnames(result) <- c("",attr(parsed,"capture.names"))
  result
}

pair.pattern <-
  paste0("(?<methylated>[0-9]+)",
         "/",
         "(?<total>[0-9]+)")
pair.mat <- str_match_perl(bed$pair.txt, pair.pattern)
stopifnot(!is.na(pair.mat[,1]))

bed$methylated <- as.integer(pair.mat[, "methylated"])
bed$total <- as.integer(pair.mat[, "total"])
with(bed, rbind(prop1000, round(methylated/total*1000)))[, 1:5]
with(bed, all.equal(prop1000, round(methylated/total*1000)))
with(bed, sum(prop1000 != round(methylated/total*1000)))
with(bed, table(prop1000 - round(methylated/total*1000)))

bed[, unmethylated := total - methylated]

public.small <-
  bed[, .(chrom, chromStart, chromEnd, methylated, unmethylated, total)]

save(public.small, file="public.small.RData")
